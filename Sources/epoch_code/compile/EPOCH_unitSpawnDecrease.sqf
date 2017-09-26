/*
	Author: Aaron Clark - EpochMod.com

    Contributors:

	Description:
	Antagonist spawn chance decrease function

    Licence:
    Arma Public License Share Alike (APL-SA) - https://www.bistudio.com/community/licenses/arma-public-license-share-alike

    Github:
    https://github.com/EpochModTeam/Epoch/tree/release/Sources/epoch_code/compile/EPOCH_unitSpawnDecrease.sqf
*/
//[[[cog import generate_private_arrays ]]]
private ["_index","_playerSpawnArray","_playerSpawnArrayKey"];
//[[[end]]]
params ["_spawnName", ["_decrease",1]];
_index = EPOCH_spawnIndex find _spawnName;
if (_index != -1) then{
	if (isNil "_playerSpawnArrayKey") then {_playerSpawnArrayKey = "EPOCH_playerSpawnArray"};
	_playerSpawnArray = missionNamespace getVariable [_playerSpawnArrayKey,[]];
	_playerSpawnArray set[_index, ((_playerSpawnArray select _index) - _decrease) max 0];
};
