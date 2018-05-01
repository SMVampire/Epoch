/*
	Author: Vampire - EpochMod.com

	Description:
	   Allows the transfer of keys into and out of storage (buildables and vehicles)

    Licence:
    Arma Public License Share Alike (APL-SA) - https://www.bistudio.com/community/licenses/arma-public-license-share-alike

    Github:
    https://github.com/EpochModTeam/Epoch/tree/release/Sources/epoch_server/compile/epoch_bases/EPOCH_server_transferKeysStorage.sqf

    Parameters
		0 - Object 1
        1 - Object 2
        2 - Index

	Returns
		None
*/
//[[[cog import generate_private_arrays ]]]
private ["_obj1","_obj2","_index","_isStor1","_isStor2","_isVeh1","_isVeh2","_obj1Keys","_cnt","_vars","_alrHasKey","_obj2Keys"];
//[[[end]]]

params [["_obj1",objNull],["_obj2",objNull],["_index",0]];

if !(isNull _obj1 || isNull _obj2) then {
    _isStor1 = _obj1 call EPOCH_server_isStorageObj;
    _isStor2 = _obj2 call EPOCH_server_isStorageObj;

    _isVeh1 = if (alive _obj1 && !(locked _obj1 in [2,3])) then { ((_obj1 isKindOf 'LandVehicle') || (_obj1 isKindOf 'Air') || (_obj1 isKindOf 'Ship') || (_obj1 isKindOf 'Tank')) } else {false};
    _isVeh2 = if (alive _obj2 && !(locked _obj2 in [2,3])) then { ((_obj2 isKindOf 'LandVehicle') || (_obj2 isKindOf 'Air') || (_obj2 isKindOf 'Ship') || (_obj2 isKindOf 'Tank')) } else {false};

    if (isPlayer _obj1 && !isPlayer _obj2 && (_isStor2 || _isVeh2)) then {
        _obj1Keys = _obj1 getVariable ["VEHICLE_KEYS", [[],[]] ];
        if ((count (_obj1Keys select 0) > 0) && ((count (_obj1Keys select 0))-1 >= _index)) then {

            // Take from Player
            _cnt = (_obj1Keys select 1) select _index;
            if (_cnt isEqualTo 1) then {
                _vars = (_obj1Keys select 0) deleteAt _index;
                _cnt = (_obj1Keys select 1) deleteAt _index;
            } else {
                _vars = (_obj1Keys select 0) select _index;
                _cnt = (_obj1Keys select 1) set [_index,(_cnt)-1];
            };
            _obj1 setVariable ["VEHICLE_KEYS", _obj1Keys];
            _obj1 call EPOCH_server_targetKeyInfo;
            [_obj1, _obj1 getVariable["VARS", []] ] call EPOCH_server_savePlayer;

            // Store on Object
            _alrHasKey = [(_vars select 0),(_vars select 1),(_vars select 2),_obj2] call EPOCH_server_alreadyHasKey;
            _obj2Keys = _obj2 getVariable ["VEHICLE_KEYS", [[],[]] ];
            if (_alrHasKey isEqualType 0) then {
                (_obj2Keys select 1) set [_alrHasKey,(_cnt)+1];
            } else {
                (_obj2Keys select 0) pushBack _vars;
                (_obj2Keys select 1) pushBack _cnt;
            };
            _obj2 setVariable ["VEHICLE_KEYS", _obj2Keys];
            _obj2 setVariable ["HAS_KEYS", true, true];
            _obj2 call EPOCH_server_targetKeyInfo;
            [[_obj2]] call EPOCH_server_save_vehicles;

            [format["You stored a %1 key",(getText(configFile >> 'CfgVehicles' >> (_vars select 0) >> 'displayName'))],5] remoteExec ["Epoch_Message",_obj1];
        };

        //diag_log text format ["DEBUG: transferKeysStor: obj1- %1 / obj2- %2 / index- %3 / obj1Keys- %4",(name _obj1),(typeOf _obj2),_index,str _obj1Keys];
    };
    if (!isPlayer _obj1 && isPlayer _obj2 && (_isStor1 || _isVeh1)) then {
        _obj1Keys = _obj1 getVariable ["VEHICLE_KEYS", [[],[]] ];
        if ((count (_obj1Keys select 0) > 0) && ((count (_obj1Keys select 0))-1 >= _index)) then {

            // Take from Object
            _cnt = (_obj1Keys select 1) select _index;
            if (_cnt isEqualTo 1) then {
                _vars = (_obj1Keys select 0) deleteAt _index;
                _cnt = (_obj1Keys select 1) deleteAt _index;
            } else {
                _vars = (_obj1Keys select 0) select _index;
                _cnt = (_obj1Keys select 1) set [_index,(_cnt)-1];
            };
            _obj1 setVariable ["VEHICLE_KEYS", _obj1Keys];
            _obj1 call EPOCH_server_targetKeyInfo;
            [[_obj1]] call EPOCH_server_save_vehicles;

            // Give to Player
            _alrHasKey = [(_vars select 0),(_vars select 1),(_vars select 2),_obj2] call EPOCH_server_alreadyHasKey;
            _obj2Keys = _obj2 getVariable ["VEHICLE_KEYS", [[],[]] ];
            if (_alrHasKey isEqualType 0) then {
                (_obj2Keys select 1) set [_alrHasKey,(_cnt)+1];
            } else {
                (_obj2Keys select 0) pushBack _vars;
                (_obj2Keys select 1) pushBack _cnt;
            };
            _obj2 setVariable ["VEHICLE_KEYS", _obj2Keys];
            _obj2 setVariable ["HAS_KEYS", true, true];
            _obj2 call EPOCH_server_targetKeyInfo;
            [_obj2, _obj2 getVariable["VARS", []] ] call EPOCH_server_savePlayer;

            [format["You've taken a %1 key",(getText(configFile >> 'CfgVehicles' >> (_vars select 0) >> 'displayName'))],5] remoteExec ["Epoch_Message",_obj2];
        };

        //diag_log text format ["DEBUG: transferKeysStor: obj1- %1 / obj2- %2 / index- %3 / obj1Keys- %4",(typeof _obj1),(name _obj2),_index,str _obj1Keys];
    };
};
