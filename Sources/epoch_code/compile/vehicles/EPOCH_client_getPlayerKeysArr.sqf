/*
	Author: Vampire - EpochMod.com

    Contributors:

	Description:
	   Pulls player keys from EPOCH_fnc_server_playerKeyInfo funtion

    Licence:
        Arma Public License Share Alike (APL-SA) - https://www.bistudio.com/community/licenses/arma-public-license-share-alike

    Github:
        https://github.com/EpochModTeam/Epoch/tree/release/Sources/epoch_code/compile/functions/EPOCH_client_getPlayerKeysArr.sqf

    Example:
        call EPOCH_client_getPlayerKeysArr;

    Parameter(s):
		NONE

	Returns:
    	BOOL
*/
//[[[cog import generate_private_arrays ]]]
private ["_select","_keyInfo","_class","_count","_name","_arr"];
//[[[end]]]

EPOCH_fnc_server_playerKeyInfo = player;
publicVariableServer "EPOCH_fnc_server_playerKeyInfo";
waitUntil{!isNil "EPOCH_tmp_playerKeyInfo"};

_keyInfo = EPOCH_tmp_playerKeyInfo;
EPOCH_tmp_playerKeyInfo = nil;

_arr = [];
if (count (_keyInfo select 0) > 0) then {
    _class = ((_keyInfo select 0) select _select);
    _count = ((_keyInfo select 1) select _select);

    _name = getText(configFile >> 'CfgVehicles' >> _class >> 'displayName');

    _arr pushBack [_name,_count];

    EPOCH_playerKeys = _arr;

    true
} else {
    false
};
