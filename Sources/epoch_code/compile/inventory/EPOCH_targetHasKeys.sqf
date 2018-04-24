/*
	Author: Vampire - EpochMod.com

    Contributors:

	Description:
	   Checks with Server on whether or not object has vehicle keys on them

    Licence:
        Arma Public License Share Alike (APL-SA) - https://www.bistudio.com/community/licenses/arma-public-license-share-alike

    Github:
        https://github.com/EpochModTeam/Epoch/tree/release/Sources/epoch_code/compile/inventory/EPOCH_targetHasKeys.sqf

    Example:
        player call EPOCH_targetHasKeys;

    Parameter(s):
	   Target

	Returns:
	   BOOL
*/
//[[[cog import generate_private_arrays ]]]
private ["_target","_alreadyChecked"];
//[[[end]]]
params [["_target",objNull]];

if !(isNull _target) then {

    [_target] remoteExec ['EPOCH_fnc_server_targetHasKeys',2];

    _alreadyChecked = _target getVariable ["HAS_KEYS", false];

    _alreadyChecked
} else { false };
