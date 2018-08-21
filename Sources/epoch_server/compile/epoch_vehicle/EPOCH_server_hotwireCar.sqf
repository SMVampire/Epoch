/*
	Author: Vampire - EpochMod.com

    Contributors:

	Description:
    Allows for the Hotwire of vehicles

    Licence:
    Arma Public License Share Alike (APL-SA) - https://www.bistudio.com/community/licenses/arma-public-license-share-alike

    Github:
    https://github.com/EpochModTeam/Epoch/tree/release/Sources/epoch_server/compile/epoch_vehicle/EPOCH_server_hotwireCar.sqf
*/
//[[[cog import generate_private_arrays ]]]
private [];
//[[[end]]]

params [["_player", objNull],["_token","",[""]]];

if (isNull _player || !isPlayer _player || _token isEqualTo "") exitWith {};
if !([_player, _token] call EPOCH_server_getPToken) exitWith {};

// Get Target Vehicle
_target = (nearestObjects[(getPosATL _player), ["LandVehicle", "Ship", "Air", "Tank"], 20]) select 0;

if (isNil "_target" || {isNull _target} || {(_player distance _target > 9)}) exitWith {
    ["No Nearby Vehicles to Hotwire", 5] remoteExec ['Epoch_message',_player];
};

// Check it is Keyed
_vehSlot = _vehicle getVariable["VEHICLE_SLOT", "ABORT"];
_tmpVeh = (_vehSlot isEqualTo "ABORT");
_isKeyed = [_target] call EPOCH_server_vehIsKeyed;

if (!_isKeyed || _tmpVeh) exitWith {
    ["Nearest Vehicle Has No Key", 5] remoteExec ['Epoch_message',_player];
};

// Consume the Hotwire
_removeItem = {([_player,"ItemHotwire",1] call BIS_fnc_invRemove) == 1};

if (!_removeItem) exitWith {
    ["Hotwire Not Found", 5] remoteExec ['Epoch_message',_player];
};

// See if the player wins
if (random 100 >= 90) then {
    // Player Wins

    _pKeys = _player getVariable ["VEHICLE_KEYS", [[],[]] ];
    _vehHiveKey = format ["%1:%2", (call EPOCH_fn_InstanceID),_vehSlot];

    _response = ["Vehicle", _vehHiveKey] call EPOCH_fnc_server_hiveGETRANGE;
    _response params ["_status","_arr"];

    if ((_response select 0) == 1 && (_response select 1) isEqualType []) then {
        _secret = _arr select 10;
        _color = _arr select 11;

        if (_secret isEqualTo "") then {
            _keySecret = "NOKEY";
        } else {
            _keySecret = _secret;
        };

        if !(_keySecret isEqualTo "NOKEY") then {
            // Check Player Has Key Already
            _alrHasKey = [(typeOf _target),(_secret),(_color),_player] call EPOCH_server_alreadyHasKey;
            _vars = [(typeOf _target),(_secret),(_color)];

            if (_alrHasKey isEqualType 0) then {
                _cnt = (_pKeys select 1) select _alrHasKey;
                (_pKeys select 1) set [_alrHasKey,(_cnt)+1];
            } else {
                (_pKeys select 0) pushBack [_vars];
                (_pKeys select 1) pushBack 1;
            };

            // Give Key
            _player setVariable ["VEHICLE_KEYS", _pKeys];
            _player setVariable ["HAS_KEYS", true, true];
            _player call EPOCH_server_targetKeyInfo;
            [_player, _player getVariable["VARS", []] ] call EPOCH_server_savePlayer;

            ["My Hotwiring Worked!", 5] remoteExec ['Epoch_message',_player];

        } else {
            ["Error Hotwiring Vehicle", 5] remoteExec ['Epoch_message',_player];
        };
    } else {
        ["Error Hotwiring Vehicle", 5] remoteExec ['Epoch_message',_player];
    };
} else {
    // Player Loses
    _msgs = [
        "Damn! It broke!",
        "I think it caught fire...",
        "Damn hotwire glitched.",
        "It Failed!",
        "Useless junk failed!"
    ];
    [(selectRandom _msgs), 5] remoteExec ['Epoch_message',_player];
};
