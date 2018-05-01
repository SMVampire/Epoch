/*
	Author: Vampire - EpochMod.com

	Description:
	Checks if an Epoch buildable allows inventory storage

    Licence:
    Arma Public License Share Alike (APL-SA) - https://www.bistudio.com/community/licenses/arma-public-license-share-alike

    Github:
    https://github.com/EpochModTeam/Epoch/tree/release/Sources/epoch_server/compile/epoch_bases/EPOCH_server_isStorageObj.sqf

    Parameters
		CLASS or OBJECT

	Returns
		BOOL
*/
//[[[cog import generate_private_arrays ]]]
private ["_obj","_type","_cfgBaseBuilding","_staticClassConfig","_staticClass"];
//[[[end]]]

params [["_obj",objNull]];

if (_obj isEqualType "") then {
    _type = _obj;
} else {
    _type = typeOf _obj;
};

_cfgBaseBuilding = 'CfgBaseBuilding' call EPOCH_returnConfig;
_staticClassConfig = (_cfgBaseBuilding >> _type >> "staticClass");
if (isText _staticClassConfig) then {
    _staticClass = getText(_staticClassConfig);
    if (_staticClass isKindOf "Buildable_Storage" || _staticClass isKindOf "Constructions_lockedstatic_F" || _staticClass isKindOf 'Secure_Storage_Temp') then{
        true
    } else { false };
} else { false };
