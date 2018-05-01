/*
	Author: Vampire - EpochMod.com

	Description:
	   Adds sanitized information about the keys an object has to the object

    Licence:
    Arma Public License Share Alike (APL-SA) - https://www.bistudio.com/community/licenses/arma-public-license-share-alike

    Github:
    https://github.com/EpochModTeam/Epoch/tree/release/Sources/epoch_server/compile/epoch_bases/EPOCH_server_targetKeyInfo.sqf

    Parameters
		Object

	Returns
		None
*/
//[[[cog import generate_private_arrays ]]]
private ["_target","_targetKeys","_return"];
//[[[end]]]

params [["_target",objNull]];

if (isNull _target) exitWith {};

_targetKeys = _target getVariable ["VEHICLE_KEYS", [[],[]] ];

_return = [];
if (count (_targetKeys select 0) > 0) then {
    {
        _return pushBack [(_x select 0),((_targetKeys select 1) select _forEachIndex),(_x select 2)];
    } forEach (_targetKeys select 0);
} else {
    _target setVariable ["KEY_INFO", [], true];
    _target setVariable ["HAS_KEYS", false, true];
};

if (count _return > 0) then {
    _target setVariable ["KEY_INFO", _return, true];
    _target setVariable ["HAS_KEYS", true, true];
};

//diag_log text format ["DEBUG: targetKeyInfo: target- %1 / targetKeys- %2 / return- %3",(typeOf _target),str _targetKeys,str _return];
