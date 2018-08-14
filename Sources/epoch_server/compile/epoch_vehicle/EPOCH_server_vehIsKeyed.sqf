/*
	Author: Vampire - EpochMod.com

	Description:
	   Checks whether a vehicle is keyed

    Licence:
    Arma Public License Share Alike (APL-SA) - https://www.bistudio.com/community/licenses/arma-public-license-share-alike

    Github:
    https://github.com/EpochModTeam/Epoch/tree/release/Sources/epoch_server/compile/epoch_bases/EPOCH_server_vehIsKeyed.sqf

    Parameters
		Object

	Returns
		BOOL
*/
//[[[cog import generate_private_arrays ]]]
private ["_vehicle","_vehHash","_vehSlot","_vehHiveKey","_response","_arr","_secret"];
//[[[end]]]

params [["_vehicle",objNull]];

_vehHash = _vehicle getVariable ["VEHICLE_KEYHASH",""];

if !(_vehHash isEqualTo "") then { true } else {
    // Vehicle has not been hashed - get hash now
    _vehSlot = _vehicle getVariable["VEHICLE_SLOT", "ABORT"];
    if (_vehSlot != "ABORT") then {
        _vehHiveKey = format ["%1:%2", (call EPOCH_fn_InstanceID),_vehSlot];

        _response = ["Vehicle", _vehHiveKey] call EPOCH_fnc_server_hiveGETRANGE;
        _response params ["_status","_arr"];

        if ((_response select 0) == 1 && (_response select 1) isEqualType []) then {
            if (count _arr > 10) then {
                _secret = _arr select 10;

                if (_secret isEqualTo "") then {
                    false
                } else {
                    true
                };
            } else { false };
        } else { false };
    } else { false };
};
