/*
	Author: Vampire - EpochMod.com

    Contributors:

	Description:
    Allows for the purchasing of keys from traders

    Licence:
    Arma Public License Share Alike (APL-SA) - https://www.bistudio.com/community/licenses/arma-public-license-share-alike

    Github:
    https://github.com/EpochModTeam/Epoch/tree/release/Sources/epoch_server/compile/epoch_vehicle/EPOCH_server_purchaseKey.sqf
*/
//[[[cog import generate_private_arrays ]]]
private ["_trader","_player","_token","_index","_hasKeys","_isTrader","_cIndex","_vars","_current_crypto","_playerCryptoLimit","_playerCryptoLimitMin","_playerCryptoLimitMax","_pKeys","_cnt"];
//[[[end]]]

params [["_trader", objNull],["_player", objNull],["_token","",[""]],["_index", 0]];

if (isNull _trader || isPlayer _trader || isNull _player || !isPlayer _player || _token isEqualTo "") exitWith {};

_hasKeys = _player getVariable ["HAS_KEYS", false];
_isTrader = ((_trader getVariable['AI_SLOT', -1]) != -1) && !(isPlayer _trader);

if (!_hasKeys || !_isTrader) exitWith {};
if !([_player, _token] call EPOCH_server_getPToken) exitWith{};

// Check player has crypto
_cIndex = EPOCH_customVars find "Crypto";
_vars = _player getVariable["VARS", call EPOCH_defaultVars_SEPXVar];
_current_crypto = _vars select _cIndex;

if (_current_crypto >= EPOCH_pkey_price) then {
    // Charge Player
    _playerCryptoLimit = EPOCH_customVarLimits select _cIndex;
    _playerCryptoLimit params ["_playerCryptoLimitMax","_playerCryptoLimitMin"];
    _current_crypto = ((_current_crypto - EPOCH_pkey_price) min _playerCryptoLimitMax) max _playerCryptoLimitMin;

    _vars set[_cIndex, _current_crypto];
    _player setVariable["VARS", _vars];

    _current_crypto remoteExec ['EPOCH_effectCrypto',_leader];

    // Give Key
    _pKeys = _player getVariable ["VEHICLE_KEYS", [[],[]] ];

    if ((count (_pKeys select 0) > 0) && ((count (_pKeys select 0))-1 >= _index)) then {
        _cnt = (_pKeys select 1) select _index;
        (_pKeys select 1) set [_index,(_cnt)+1];

        _player setVariable ["VEHICLE_KEYS", _pKeys];
        _player setVariable ["HAS_KEYS", true, true];
        _player call EPOCH_server_targetKeyInfo;
        [_player, _player getVariable["VARS", []] ] call EPOCH_server_savePlayer;

        ["You have been given a duplicate key", 5] remoteExec ['Epoch_message',_player];

        //diag_log text format ["DEBUG: purchaseKey: name- %1 / keys- %2 / index- %3",(name _player),str _pKeys,_index];
    } else {
        ["You do not have that key to duplicate", 5] remoteExec ['Epoch_message',_player];
    };
} else {
    ["You do not have enough crypto to pruchase a key", 5] remoteExec ['Epoch_message',_player];
};
