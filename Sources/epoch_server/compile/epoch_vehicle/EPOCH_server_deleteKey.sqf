/*
	Author: Vampire - EpochMod.com

	Description:
	   Removes a key from a player. This should only be remoteExecuted from the target player.

    Licence:
    Arma Public License Share Alike (APL-SA) - https://www.bistudio.com/community/licenses/arma-public-license-share-alike

    Github:
    https://github.com/EpochModTeam/Epoch/tree/release/Sources/epoch_server/compile/epoch_bases/EPOCH_server_deleteKey.sqf

    Parameters
		Player Object
        Client Owner
        Index

	Returns
		None
*/
//[[[cog import generate_private_arrays ]]]
private ["_player","_cid","_index","_caller","_playerKeys","_cnt","_vars"];
//[[[end]]]

params [["_player",objNull],["_cid",""],["_index",-1]];

if !(isNull _player || !isPlayer _player || _cid isEqualTo "" || _index isEqualTo -1) then {
    _caller = remoteExecutedOwner;
    if !(_caller isEqualTo _cid || _cid isEqualTo (owner _player) || (owner _player) isEqualTo _caller) exitWith {
        diag_log text format ["Epoch: ERROR player (%1) attempted to delete %2's keys!",_caller,(name _player)];
    };

    _playerKeys = _player getVariable ["VEHICLE_KEYS", [[],[]] ];
    if ((count (_playerKeys select 0) > 0) && ((count (_playerKeys select 0))-1 >= _index)) then {
        _cnt = (_playerKeys select 1) select _index;
        if (_cnt isEqualTo 1) then {
            _vars = (_playerKeys select 0) deleteAt _index;
            _cnt = (_playerKeys select 1) deleteAt _index;
        } else {
            _vars = (_playerKeys select 0) select _index;
            _cnt = (_playerKeys select 1) set [_index,(_cnt)-1];
        };
        _player setVariable ["VEHICLE_KEYS", _playerKeys];
        _player call EPOCH_server_targetKeyInfo;
        [_player, _player getVariable["VARS", []] ] call EPOCH_server_savePlayer;

        if (count (_playerKeys select 0) < 1) then {
            _player setVariable ["HAS_KEYS", false, true];
            _player call EPOCH_server_targetKeyInfo;
        };

        [format["You deleted a %1 key",(getText(configFile >> 'CfgVehicles' >> (_vars select 0) >> 'displayName'))],5] remoteExec ["Epoch_Message",_player];

        //diag_log text format ["DEBUG: deleteKey: player- %1 / cid- %2 / index- %3 / caller- %4 / plyrKeys- %5",_player,_cid,_index,_caller,str _playerKeys];
    };
};
