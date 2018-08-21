/*
	Author: Vampire - EpochMod.com

	Description:
	   Allows for the transfer of keys between players

    Licence:
    Arma Public License Share Alike (APL-SA) - https://www.bistudio.com/community/licenses/arma-public-license-share-alike

    Github:
    https://github.com/EpochModTeam/Epoch/tree/release/Sources/epoch_server/compile/epoch_bases/EPOCH_server_transferKeys.sqf

    Parameters
        0 - Player 1 Object
        1 - Player 2 Object
        2 - Index

	Returns
		None
*/
//[[[cog import generate_private_arrays ]]]
private ["_player1","_player2","_index","_p1Keys","_p2Keys","_cnt","_vars","_alrHasKey"];
//[[[end]]]

params [["_player1",objNull],["_player2",objNull],["_index",0]];

// TODO -- Add more valid player checking?

if !(isNull _player1 || isNull _player2 || local _player1 || local _player2 || !isPlayer _player1 || !isPlayer _player2) then {
    _p1Keys = _player1 getVariable ["VEHICLE_KEYS", [[],[]] ];
    _p2Keys = _player2 getVariable ["VEHICLE_KEYS", [[],[]] ];

    if ((count (_p1Keys select 0) > 0) && ((count (_p1Keys select 0))-1 >= _index)) then {
        // Take from Player 1
        _cnt = (_p1Keys select 1) select _index;
        if (_cnt > 1) then {
            _vars = (_p1Keys select 0) select _index;
            (_p1Keys select 1) set [_index,(_cnt)-1];
        } else {
            _vars = (_p1Keys select 0) deleteAt _index;
            _cnt = (_p1Keys select 1) deleteAt _index;
        };
        _player1 setVariable ["VEHICLE_KEYS", _p1Keys];
        _player1 call EPOCH_server_targetKeyInfo;
        [_player1, _player1 getVariable["VARS", []] ] call EPOCH_server_savePlayer;

        // Give to Player 2
        _alrHasKey = [(_vars select 0),(_vars select 1),(_vars select 2),_player2] call EPOCH_server_alreadyHasKey;
        if (_alrHasKey isEqualType 0) then {
            _cnt = (_p2Keys select 1) select _index;
            (_p2Keys select 1) set [_alrHasKey,(_cnt)+1];
        } else {
            (_p2Keys select 0) pushBack _vars;
            (_p2Keys select 1) pushBack 1;
        };
        _player2 setVariable ["VEHICLE_KEYS", _p2Keys];
        _player2 setVariable ["HAS_KEYS", true, true];
        _player2 call EPOCH_server_targetKeyInfo;
        [_player2, _player2 getVariable["VARS", []] ] call EPOCH_server_savePlayer;

        [format["You gave %1 a key to a %2",(name _player2),(getText(configFile >> 'CfgVehicles' >> (_vars select 0) >> 'displayName'))],5] remoteExec ["Epoch_Message",_player1];
        [format["You received a key to a %1",(getText(configFile >> 'CfgVehicles' >> (_vars select 0) >> 'displayName'))],5] remoteExec ["Epoch_Message",_player2];
    };

    //diag_log text format ["DEBUG: transferKeys: play1- %1 / play2- %2 / index- %3 / p1keys- %4 / p2keys-%5",(name _player1),(name _player2),_index,str _p1Keys,str _p2Keys];
};
