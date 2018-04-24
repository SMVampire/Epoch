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
private ["_target"];
//[[[end]]]
params [["_target",objNull]];

if !(isNull _target) then {
    EPOCH_tmp_targetHasKeys = nil;

    [_target,player] remoteExec ['EPOCH_fnc_server_targetHasKeys',2];

    waitUntil{ !isNil "EPOCH_tmp_targetHasKeys" };

    if (EPOCH_tmp_targetHasKeys) then { true } else { false };

    EPOCH_tmp_targetHasKeys = nil;
} else { false };
