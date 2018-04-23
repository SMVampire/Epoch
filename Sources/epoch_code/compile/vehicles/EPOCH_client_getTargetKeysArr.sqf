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
    EPOCH_tmp_targetKeyInfo = nil;

    [_target,player] remoteExec ['EPOCH_fnc_server_targetHasKeys',2];

    waitUntil{!isNil "EPOCH_tmp_targetKeyInfo"};

    _keyInfo = EPOCH_tmp_targetKeyInfo;
    EPOCH_tmp_targetKeyInfo = nil;

    _arr = [];
    if (count (_keyInfo select 0) > 0) then {
        _class = ((_keyInfo select 0) select _select);
        _count = ((_keyInfo select 1) select _select);

        _name = getText(configFile >> 'CfgVehicles' >> _class >> 'displayName');

        _arr pushBack [_name,_count];

        EPOCH_targetKeys = _arr;

        true
    } else {
        false
    };
} else { false };
