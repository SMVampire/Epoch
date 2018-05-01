/*
	Author: Vampire - EpochMod.com

	Description:
	   Checks that the target has the keys to a vehicle

    Licence:
    Arma Public License Share Alike (APL-SA) - https://www.bistudio.com/community/licenses/arma-public-license-share-alike

    Github:
    https://github.com/EpochModTeam/Epoch/tree/release/Sources/epoch_server/compile/epoch_bases/EPOCH_server_targetHasKeys.sqf

    Parameters
		Target Object

	Returns
		BOOL
*/
//[[[cog import generate_private_arrays ]]]
private ["_target","_return","_tarKeys"];
//[[[end]]]

params [["_target",objNull]];

_return = false;
if !(isNull _target) then {
    _tarKeys = _target getVariable ["VEHICLE_KEYS", [[],[]] ];
    if (count (_tarKeys select 0) > 0) then {
        _return = true;
        _target setVariable ["HAS_KEYS", true, true];
    };
};

//diag_log text format ["DEBUG: targetHasKeys: target- %1 / tarKeys- %2 / return- %3",(typeOf _target),str (_tarKeys),_return];

_return
