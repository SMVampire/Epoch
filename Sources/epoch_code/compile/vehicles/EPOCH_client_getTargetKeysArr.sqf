/*
	Author: Vampire - EpochMod.com

    Contributors:

	Description:
	   Pulls target keys from EPOCH_fnc_server_targetKeyInfo funtion

    Licence:
        Arma Public License Share Alike (APL-SA) - https://www.bistudio.com/community/licenses/arma-public-license-share-alike

    Github:
        https://github.com/EpochModTeam/Epoch/tree/release/Sources/epoch_code/compile/functions/EPOCH_client_getTargetKeysArr.sqf

    Example:
        call EPOCH_client_getTargetKeysArr;

    Parameter(s):
		Target

	Returns:
    	BOOL
*/
//[[[cog import generate_private_arrays ]]]
private ["_select","_keyInfo","_class","_count","_name","_arr"];
//[[[end]]]
params [["_target",objNull]];

if !(isNull _target) then {

    [_target] remoteExec ['EPOCH_fnc_server_targetKeyInfo',2];

    _keyInfo = _target getVariable ["KEY_INFO", [] ];

    _arr = [];
    if (count _keyInfo > 0) then {
        EPOCH_targetKeys = _keyInfo;

        true
    } else {
        false
    };
} else { false };
