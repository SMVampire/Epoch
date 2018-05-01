/*
	Author: Vampire - EpochMod.com

	Description:
	   Hashes vehicle information from the database

    Licence:
    Arma Public License Share Alike (APL-SA) - https://www.bistudio.com/community/licenses/arma-public-license-share-alike

    Github:
    https://github.com/EpochModTeam/Epoch/tree/release/Sources/epoch_server/compile/epoch_bases/EPOCH_server_hashVehicle.sqf

    Parameters
		0 - Vehicle Object
        1 - Vehicle Secret

	Returns
		STRING - Hash
*/
//[[[cog import generate_private_arrays ]]]
private ["_vehicle","_keySecret","_vehSlot","_vehHiveKey","_response","_arr","_secret","_keySecret","_rnd1","_return"];
//[[[end]]]

params [["_vehicle",objNull],["_keySecret",""]];

if (_keySecret isEqualTo "") then {
    // Get secret from DB
    _vehSlot = _vehicle getVariable["VEHICLE_SLOT", "ABORT"];
    if (_vehSlot != "ABORT") then {
        _vehHiveKey = format ["%1:%2", (call EPOCH_fn_InstanceID),_vehSlot];

        _response = ["Vehicle", _vehHiveKey] call EPOCH_fnc_server_hiveGETRANGE;
        _response params ["_status","_arr"];

        if ((_response select 0) == 1 && (_response select 1) isEqualType []) then {
            if (count _arr > 10) then {
                _secret = _arr select 9;

                if (_secret isEqualTo "") then {
                    _keySecret = "NOKEY";
                } else {
                    _keySecret = _secret;
                };
            };
        };
    };
};

if !(_keySecret isEqualTo "NOKEY") then {
    _rnd1 = ((typeOf _vehicle)+_keySecret) call EPOCH_fnc_server_hiveMD5;
    _return = ((_rnd1)+(EPOCH_server_vehRandomKey)) call EPOCH_fnc_server_hiveMD5;
} else {
    _return = "NOKEY";
};

//diag_log text format ["DEBUG: hashVehicle: vehicle- %1 / secret- %2 / serverKey- %3 / hash- %4",(typeOf _vehicle),_keySecret,(EPOCH_server_vehRandomKey),_return];

_return
