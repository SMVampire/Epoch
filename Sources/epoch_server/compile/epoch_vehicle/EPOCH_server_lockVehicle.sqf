/*
	Author: Aaron Clark - EpochMod.com

    Contributors:

	Description:
    (Un)Lock Vehicles

    Licence:
    Arma Public License Share Alike (APL-SA) - https://www.bistudio.com/community/licenses/arma-public-license-share-alike

    Github:
    https://github.com/EpochModTeam/Epoch/tree/release/Sources/epoch_server/compile/epoch_vehicle/EPOCH_server_lockVehicle.sqf
*/
//[[[cog import generate_private_arrays ]]]
private ["_VehLockMessages","_msg","_crew","_driver","_isLocked","_lockOwner","_lockedOwner","_logic","_playerGroup","_playerUID","_response","_vehLockHiveKey","_vehSlot","_vehKeyed","_plyrKeys","_plyrHasKey","_matching","_secret","_rnd1","_vehHash"];
//[[[end]]]
params [
    ["_vehicle",objNull,[objNull]],
    ["_value",true,[true]],
    ["_player",objNull,[objNull]],
    ["_token","",[""]]
];

if (isNull _vehicle) exitWith {};
if !([_player,_token] call EPOCH_server_getPToken) exitWith {};
if (_player distance _vehicle > 20) exitWith {};

_VehLockMessages = ['CfgEpochClient' call EPOCH_returnConfig, "VehLockMessages", true] call EPOCH_fnc_returnConfigEntry;

// Prep for Key (un)lock
_vehKeyed = _vehicle call EPOCH_fnc_server_vehIsKeyed;
_plyrKeys = _player getVariable ["PLAYER_KEYS", [[],[]] ];
_plyrHasKey = false;
{
    if ((_x select 0) isEqualTo (typeOf _vehicle)) then {
        _matching = [_vehicle,(_x select 1)] call EPOCH_fnc_server_testVehKey;
        if (_matching) then {
            _plyrHasKey = true;
        };
    };
} forEach (_plyrKeys select 0);
//diag_log text format ["DEBUG: LockVeh Keys: isKeyed- %1 / _plyrKeys- %2 / plyrHasKey- %3 / Player- %4",_vehKeyed,_plyrKeys,_plyrHasKey,_player];

// Group access
_playerUID = getPlayerUID _player;
_playerGroup = _player getVariable["GROUP", ""];

_lockOwner = _playerUID;
if (_playerGroup != "") then {
	_lockOwner = _playerGroup;
};

// Remove this Hive call code in the future for speed
_lockedOwner = "-1";
_vehSlot = _vehicle getVariable["VEHICLE_SLOT", "ABORT"];
_vehLockHiveKey = format["%1:%2", (call EPOCH_fn_InstanceID), _vehSlot];
if (_vehSlot != "ABORT") then {
	_response = ["VehicleLock", _vehLockHiveKey] call EPOCH_fnc_server_hiveGETRANGE;
	if ((_response select 0) == 1 && (_response select 1) isEqualType [] && !((_response select 1) isEqualTo[])) then {
		_lockedOwner = _response select 1 select 0;
	};
}
else {
	_lockedOwner = _vehicle getvariable ["EPOCH_LockedOwner","-1"];
};

// get locked state
_isLocked = locked _vehicle in[2, 3];

_driver = driver _vehicle;
_crew = [];
{
	// only get alive crew
	if (alive _x) then {
		_crew pushBack _x;
	};
} forEach (crew _vehicle);

// With the switch to keys, only use Group (old style) if this is the first unlock since update
// Otherwise we need to use Key Logic

if !(_lockedOwner isEqualTo "-1") then {
    // Vehicle still locked with group system

    // if vehicle has a crew and player is not inside vehicle only allow locking if already owner
    _logic = if !(_crew isEqualTo []) then {
    	if (_player in _crew) then {
    		// allow unlock if player is the driver or is inside the vehicle with out a driver.
    		(_player isEqualTo _driver || isNull(_driver) || _lockedOwner == _lockOwner || !alive _driver)
    	} else {
    		// allow only if player is already the owner as they are not inside the occupied vehicle.
    		(_lockedOwner == _lockOwner)
    	};
    } else {
    	// vehicle has no crew, so allow only if: unlocked, is already the owner, vehicle has no owner.
    	(!_isLocked || _lockedOwner == _lockOwner || _lockedOwner == "-1")
    };

} else {
    // Vehicle is not locked by Group System. We need to use Key Logic.

    _logic = if !(_crew isEqualTo []) then {
    	if (_player in _crew) then {
    		// allow (un)lock if player is the driver or is inside the vehicle with out a driver, or has the keys
    		(_player isEqualTo _driver || isNull(_driver) || _plyrHasKey || !alive _driver)
    	} else {
    		// allow only if player has the keys and is outside the vehicle
    		(_plyrHasKey)
    	};
    } else {
    	// vehicle has no crew, so allow only if: unlocked, plyr has key, vehicle is unkeyed.
    	(!_isLocked || _plyrHasKey || !_vehKeyed)
    };
};

// Lockout mech
if (_logic) then {

    if (!_value) then {
        // re-allow damage (server-side) on first unlock
        if (_vehicle getVariable ["EPOCH_disallowedDamage", false]) then {
            _vehicle allowDamage true;
            _vehicle setVariable ["EPOCH_disallowedDamage", nil];
        };

        // If vehicle was unlocked by Group, give key to unlocker and convert
        if (!_vehKeyed && (_lockedOwner isEqualTo _lockOwner)) then {
            // Convert to New System
            _secret = ('epochserver' callExtension format['810|%1', 1]);

    		_rnd1 = ((typeOf _vehicle)+_secret) call EPOCH_fnc_server_hiveMD5;
            _vehHash = ((_rnd1)+(EPOCH_server_vehRandomKey)) call EPOCH_fnc_server_hiveMD5;

    		_vehicle setVariable ["VEHICLE_KEYHASH",_vehHash,true];

    		(_plyrKeys select 0) pushback [(typeOf _vehicle),_secret];
    		(_plyrKeys select 1) pushback 1;
    		_player setVariable ["PLAYER_KEYS",_plyrKeys];

            // Purge Group Lock
            ["VehicleLock", _vehLockHiveKey] call EPOCH_fnc_server_hiveDEL;

            // Force Vehicle Save
            [_vehicle,_secret] call EPOCH_server_save_vehicle;

            //diag_log text format ["DEBUG: LockVeh Keys: Secret- %1 / Hash- %2 / _plyrKeys- %3",_secret,_vehHash,str (_player getVariable ["PLAYER_KEYS", [] ])];
        };
    };

    // lock/unlock
	if (local _vehicle) then {
		_vehicle lock _value;
	} else {
		[_vehicle, _value] remoteExec ['EPOCH_client_lockVehicle',_vehicle];
	};
	if (_VehLockMessages) then {
		_msg = if (_value) then {"Vehicle Locked"} else {"Vehicle unlocked"};
		[_msg,5] remoteExec ["Epoch_Message",_player];
	};

    if (!_vehKeyed && (_lockedOwner isEqualTo _lockOwner) && !_value) then {
        // Inform for conversion
        ["A key was added to your keychain",5] remoteExec ["Epoch_Message",_player];
    };
}
else {
	if (_VehLockMessages) then {
        if (_vehKeyed) then {
            ["You do not have the keys",5] remoteExec ["Epoch_Message",_player];
        } else {
            ["You are not the owner",5] remoteExec ["Epoch_Message",_player];
        };
	};
};
