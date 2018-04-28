/*
	Author: Aaron Clark - EpochMod.com

    Contributors:

	Description:
    Starts main functions

    Licence:
    Arma Public License Share Alike (APL-SA) - https://www.bistudio.com/community/licenses/arma-public-license-share-alike

    Github:
    https://github.com/EpochModTeam/Epoch/tree/release/Sources/epoch_server/init/server_init.sqf
*/
//[[[cog import generate_private_arrays ]]]
private ["_ReservedSlots","_SideHQ1","_SideHQ2","_SideHQ3","_abortAndError","_allBunkers","_allowedVehicleIndex","_allowedVehicleListName","_allowedVehiclesList","_allowedVehiclesListArray","_animationStates","_blacklist","_bunkerCounter","_bunkerLocations","_bunkerLocationsKey","_cfgServerVersion","_channelColor","_channelNumber","_channelTXT","_clientVersion","_colCount","_config","_configSize","_configVersion","_customRadioactiveLocations","_date","_dateChanged","_debug","_debugLocation","_distance","_epochConfig","_epochWorldPath","_existingStock","_firstBunker","_hiveVersion","_index","_indexStock","_instanceID","_list","_loc1","_locName","_locPOS","_locSize","_location","_locations","_markers","_markertxt","_maxColumns","_maxRows","_memoryPoints","_modelInfo","_nearBLObj","_newBunkerCounter","_object","_originalLocation","_pOffset","_pos","_radio","_radioactiveLocations","_radioactiveLocationsTmp","_radius","_response","_rng","_rngChance","_rowCount","_sapper","_score","_scriptHiveKey","_seed","_selectedBunker","_serverConfig","_serverSettingsConfig","_servicepoints","_size","_startTime","_staticDateTime","_staticFuelSources","_timeDifference","_valuesAndWeights","_veh","_vehicleCount","_vehicleSlotLimit","_worldSize"];
//[[[end]]]
_startTime = diag_tickTime;
missionNamespace setVariable ['Epoch_ServerVersion', getText(configFile >> "CfgMods" >> "Epoch" >> "version"), true];
diag_log format["Epoch: Starting ArmA3 Epoch Server, Version %1. Note: If server crashes directly after this point check that Redis is running and the connection info is correct.",Epoch_ServerVersion];

_abortAndError = {
    // kick all players with reverse BE kicks
    true remoteExec ['EPOCH_client_rejectPlayer',-2, true];
    // flood server rpt with reason
    for "_i" from 0 to 15 do {
        diag_log _this;
    };
};

_cfgServerVersion = configFile >> "CfgServerVersion";
_serverSettingsConfig = configFile >> "CfgEpochServer";
_epochConfig = configFile >> "CfgEpoch";

_clientVersion = getText(_cfgServerVersion >> "client");
_configVersion = getText(_cfgServerVersion >> "config");
_hiveVersion = getText(_cfgServerVersion >> "hive");

if (_clientVersion != Epoch_ServerVersion) exitWith{
    format["Epoch: Version mismatch! Current: %2 Needed: %1", _clientVersion, Epoch_ServerVersion] call _abortAndError;
};
if (_configVersion != getText(configFile >> "CfgPatches" >> "A3_server_settings" >> "epochVersion")) exitWith {
    format["Epoch: Config file needs updated! Current: %1 Needed: %2", _configVersion, getText(configFile >> "CfgPatches" >> "A3_server_settings" >> "epochVersion")] call _abortAndError;
};
if (isClass(getMissionConfig "CfgEpochClient") && _configVersion != getText(getMissionConfig "CfgEpochClient" >> "epochVersion")) exitWith{
	format["Epoch: Mission Config file needs updated! Current: %1 Needed: %2", _configVersion, getText(getMissionConfig "CfgEpochClient" >> "epochVersion")] call _abortAndError;
};
if (("epochserver" callExtension "") != _hiveVersion) exitWith {
    format["Epoch: Server DLL mismatch! Current: %1 Needed: %2", "epochserver" callExtension "",_hiveVersion] call _abortAndError;
};

_serverConfig = call compile ("epochserver" callExtension "000");
EPOCH_fn_InstanceID = compileFinal (str (_serverConfig select 0));
_instanceID = call EPOCH_fn_InstanceID;
if (isNil "_instanceID") exitWith{
    "Epoch: InstanceID missing!" call _abortAndError;
};

EPOCH_modCUPWeaponsEnabled = (getNumber (configFile >> "CfgPatches" >> "CUP_Weapons_WeaponsCore" >> "requiredVersion") > 0);
EPOCH_modCUPVehiclesEnabled = (getNumber (configFile >> "CfgPatches" >> "CUP_WheeledVehicles_Core" >> "requiredVersion") > 0);
if (EPOCH_modCUPWeaponsEnabled) then {
    diag_log "Epoch: CUP Weapons detected";
};
if (EPOCH_modCUPVehiclesEnabled) then {
    diag_log "Epoch: CUP Vehicles detected";
};

// detect if Ryan's Zombies and Deamons mod is present
if (["CfgEpochClient", "ryanZombiesEnabled", true] call EPOCH_fnc_returnConfigEntryV2) then {
    EPOCH_mod_Ryanzombies_Enabled = (parseNumber (getText (configFile >> "CfgPatches" >> "Ryanzombies" >> "version")) >= 4.5);
    if (EPOCH_mod_Ryanzombies_Enabled) then {
        diag_log "Epoch: Ryanzombies detected";
		missionNamespace setVariable ["EPOCH_mod_Ryanzombies_Enabled", true, true];
    };
} else {
    EPOCH_mod_Ryanzombies_Enabled = false;
};

// detect if Mad Arma is present
if (["CfgEpochClient", "madArmaEnabled", true] call EPOCH_fnc_returnConfigEntryV2) then {
    EPOCH_mod_madArma_Enabled = (parseNumber (getText (configFile >> "CfgPatches" >> "bv_wheels" >> "version")) >= 2016);
    if (EPOCH_mod_madArma_Enabled) then {
        diag_log "Epoch: Mad Arma detected";
		missionNamespace setVariable ["EPOCH_mod_madArma_Enabled", true, true];
    };
} else {
    EPOCH_mod_madArma_Enabled = false;
};

diag_log "Epoch: Init Variables";
call compile preprocessFileLineNumbers "\epoch_server\init\server_variables.sqf";
call compile preprocessFileLineNumbers "\epoch_server\init\server_securityfunctions.sqf";

// Enable Dynamic simulation
_dynSimToggle = [_serverSettingsConfig, "enableDynamicSimulationSystem", true] call EPOCH_fnc_returnConfigEntry;
enableDynamicSimulationSystem _dynSimToggle;
if(_dynSimToggle)then
{
	"IsMoving" setDynamicSimulationDistanceCoef ([_serverSettingsConfig, "isMovingCoefValue", 2] call EPOCH_fnc_returnConfigEntry);
	"Group" setDynamicSimulationDistance ([_serverSettingsConfig, "groupDynSimDistance", 500] call EPOCH_fnc_returnConfigEntry);
	"Vehicle" setDynamicSimulationDistance ([_serverSettingsConfig, "vehicleDynSimDistance", 350] call EPOCH_fnc_returnConfigEntry);
	"EmptyVehicle" setDynamicSimulationDistance ([_serverSettingsConfig, "emptyVehicleDynSimDistance", 250] call EPOCH_fnc_returnConfigEntry);
	"Prop" setDynamicSimulationDistance ([_serverSettingsConfig, "propDynSimDistance", 50] call EPOCH_fnc_returnConfigEntry);
};
["I", _instanceID, "86400", ["CONTINUE"]] call EPOCH_fnc_server_hiveSETEX;
diag_log format["Epoch: Start Hive, Instance ID: '%1'", _instanceID];

diag_log "Epoch: Init Connect/Disconnect handlers";

onPlayerConnected {}; // seems this is needed or addMissionEventHandler "PlayerConnected" does not work. as of A3 1.60
addMissionEventHandler ["PlayerConnected", {
    params ["_id","_uid","_name","_jip","_owner"];
    // TODO: diabled STEAMAPI - Vac ban check needs reworked.
    // "epochserver" callExtension format["001|%1", _uid];
    // diag_log format["playerConnected:%1", _this];
    ["PlayerData", _uid, EPOCH_expiresPlayer, [_name]] call EPOCH_fnc_server_hiveSETEX;
    ['Connected', [_uid, _name]] call EPOCH_fnc_server_hiveLog;
}];

addMissionEventHandler ["HandleDisconnect", {_this call EPOCH_server_onPlayerDisconnect}];

diag_log "Epoch: Setup Side Settings";
//set side status
_SideHQ1 = createCenter resistance;
_SideHQ2 = createCenter east;
_SideHQ3 = createCenter west;
RESISTANCE setFriend [WEST, 0];
WEST setFriend [RESISTANCE, 0];
RESISTANCE setFriend [EAST, 0];
EAST setFriend [RESISTANCE, 0];
// friendly
EAST setFriend[WEST, 1];
WEST setFriend[EAST, 1];

diag_log format["Epoch: Setup World Settings for %1",worldName];
//World Settings
_worldSize = worldSize;
_epochWorldPath = _epochConfig >> worldName;
if (isClass _epochWorldPath) then {
    _configSize = getNumber(_epochWorldPath >> "worldSize");
    if (_configSize > 0) then {
      _worldSize = _configSize;
    };
};
epoch_centerMarkerPosition = getMarkerPos "center";
if (epoch_centerMarkerPosition isEqualTo [0,0,0]) then {
    diag_log "Epoch: Error cannot find center marker!";
};
EPOCH_dynamicVehicleArea = _worldSize / 2;

// custom radio channels
EPOCH_customChannels = [];
for "_i" from 0 to 9 do {
    _radio = configfile >> "CfgWeapons" >> format["EpochRadio%1", _i];
    _channelTXT = getText(_radio >> "displayName");
    // _channelNumber = getNumber(_radio >> "channelID");
    _channelColor = getArray(_radio >> "channelColor");
    _index = radioChannelCreate[_channelColor, _channelTXT, "%UNIT_NAME", []];
    EPOCH_customChannels pushBack _index;
};

//Execute Server Functions
diag_log "Epoch: Loading buildings";
EPOCH_BuildingSlotsLimit call EPOCH_server_loadBuildings;

diag_log "Epoch: Loading teleports and static props";
call EPOCH_server_createTeleport;

diag_log "Epoch: Loading NPC traders";
EPOCH_NPCSlotsLimit call EPOCH_server_loadTraders;

diag_log "Epoch: Spawning NPC traders";
call EPOCH_server_spawnTraders;

diag_log "Epoch: Preparing Vehicle Keys";
EPOCH_server_vehRandomKey = ('epochserver' callExtension format['810|%1', 1]); // Only Reference on Server Side
EPOCH_server_keyColors = ["blue","brown","coral","cream","cyan","green","grey","lavender","lime","magenta","maroon","mint","navy","olive","orange","pink","purple","red","teal","yellow"];

// TODO --> Move Functions to Files
EPOCH_fnc_server_hashVehicle = {
    // Takes Vehicle Information and provides hash back
    private ["_vehicle","_keySecret","_vehSlot","_vehHiveKey","_response","_arr","_secret","_keySecret","_rnd1","_return"];

    params [["_vehicle",objNull],["_keySecret",""]];

    if (_keySecret isEqualTo "") then {
        // Get secret from DB
        _vehSlot = _vehicle getVariable["VEHICLE_SLOT", "ABORT"];
    	if (_vehSlot != "ABORT") then {
            _vehHiveKey = format ["%1:%2", (call EPOCH_fn_InstanceID),_vehSlot];

            _response = ["Vehicle", _vehHiveKey] call EPOCH_fnc_server_hiveGETRANGE;
    		_response params ["_status","_arr"];

            if ((_response select 0) == 1 && (_response select 1) isEqualType []) then {
                if (count _arr > 10) then {
    				_secret = _arr select 9;

                    if (_secret isEqualTo "") then {
                        _keySecret = "NOKEY";
                    } else {
                        _keySecret = _secret;
                    };
    			};
            };
        };
    };

    if !(_keySecret isEqualTo "NOKEY") then {
        _rnd1 = ((typeOf _vehicle)+_keySecret) call EPOCH_fnc_server_hiveMD5;
        _return = ((_rnd1)+(EPOCH_server_vehRandomKey)) call EPOCH_fnc_server_hiveMD5;
    } else {
        _return = "NOKEY";
    };

    //diag_log text format ["DEBUG: hashVehicle: vehicle- %1 / secret- %2 / serverKey- %3 / hash- %4",(typeOf _vehicle),_keySecret,(EPOCH_server_vehRandomKey),_return];

    _return
};

EPOCH_fnc_server_vehIsKeyed = {
    // Returns BOOL on whether vehicle is keyed
    private ["_vehicle","_vehHash","_vehSlot","_vehHiveKey","_response","_arr","_secret"];

    params [["_vehicle",objNull]];

    _vehHash = _vehicle getVariable ["VEHICLE_KEYHASH",""];

    if !(_vehHash isEqualTo "") then { true } else {
        // Vehicle has not been hashed - get hash now
        _vehSlot = _vehicle getVariable["VEHICLE_SLOT", "ABORT"];
        if (_vehSlot != "ABORT") then {
            _vehHiveKey = format ["%1:%2", (call EPOCH_fn_InstanceID),_vehSlot];

            _response = ["Vehicle", _vehHiveKey] call EPOCH_fnc_server_hiveGETRANGE;
            _response params ["_status","_arr"];

            if ((_response select 0) == 1 && (_response select 1) isEqualType []) then {
                if (count _arr > 10) then {
                    _secret = _arr select 9;

                    if (_secret isEqualTo "") then {
                        false
                    } else {
                        true
                    };
                } else { false };
            } else { false };
        } else { false };
    };
};

EPOCH_fnc_server_targetHasKeys = {
    // Returns BOOL on whether target has keys
    // Exists to prevent Client from being able to access vehicle keys variable
    private ["_target","_return","_tarKeys"];

    params [["_target",objNull]];

    _return = false;
    if !(isNull _target) then {
        _tarKeys = _target getVariable ["VEHICLE_KEYS", [[],[]] ];
        if (count (_tarKeys select 0) > 0) then {
            _return = true;
            _target setVariable ["HAS_KEYS", true, true];
        };
    };

    //diag_log text format ["DEBUG: targetHasKeys: target- %1 / tarKeys- %2 / return- %3",(typeOf _target),str (_tarKeys),_return];

    _return
};

EPOCH_fnc_server_targetKeyInfo = {
    // Sets Information about target keys - NO SECRETS
    private ["_target","_targetKeys","_return"];

    params [["_target",objNull]];

    if (isNull _target) exitWith {};

    _targetKeys = _target getVariable ["VEHICLE_KEYS", [[],[]] ];

    _return = [];
    if (count (_targetKeys select 0) > 0) then {
        {
            _return pushBack [(_x select 0),((_targetKeys select 1) select _forEachIndex),(_x select 2)];
        } forEach (_targetKeys select 0);
    } else {
        _target setVariable ["KEY_INFO", [], true];
        _target setVariable ["HAS_KEYS", false, true];
    };

    if (count _return > 0) then {
        _target setVariable ["KEY_INFO", _return, true];
        _target setVariable ["HAS_KEYS", true, true];
    };

    //diag_log text format ["DEBUG: targetKeyInfo: target- %1 / targetKeys- %2 / return- %3",(typeOf _target),str _targetKeys,str _return];
};

EPOCH_fnc_server_transferKeys = {
    // Transfer Vehicle Keys from one player to another
    private ["_player1","_player2","_index","_p1Keys","_p2Keys","_cnt","_vars","_alrHasKey"];

    params [["_player1",objNull],["_player2",objNull],["_index",0]];

    // Add more valid player checking?

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
            _player1 call EPOCH_fnc_server_targetKeyInfo;
            [_player1, _player1 getVariable["VARS", []] ] call EPOCH_server_savePlayer;

            // Give to Player 2
            _alrHasKey = [(_vars select 0),(_vars select 1),(_vars select 2),_player2] call EPOCH_fnc_server_alreadyHasKey;
            if (_alrHasKey isEqualType 0) then {
                (_p2Keys select 1) set [_alrHasKey,(_cnt)+1];
            } else {
                (_p2Keys select 0) pushBack _vars;
                (_p2Keys select 1) pushBack _cnt;
            };
            _player2 setVariable ["VEHICLE_KEYS", _p2Keys];
            _player2 setVariable ["HAS_KEYS", true, true];
            _player2 call EPOCH_fnc_server_targetKeyInfo;
            [_player2, _player2 getVariable["VARS", []] ] call EPOCH_server_savePlayer;

            [format["You gave %1 a key to a %2",(name _player2),(getText(configFile >> 'CfgVehicles' >> (_vars select 0) >> 'displayName'))],5] remoteExec ["Epoch_Message",_player1];
            [format["You received a key to a %1",(getText(configFile >> 'CfgVehicles' >> (_vars select 0) >> 'displayName'))],5] remoteExec ["Epoch_Message",_player2];
        };

        //diag_log text format ["DEBUG: transferKeys: play1- %1 / play2- %2 / index- %3 / p1keys- %4 / p2keys-%5",(name _player1),(name _player2),_index,str _p1Keys,str _p2Keys];
    };
};

EPOCH_fnc_server_transferKeysStorage = {
    // Transfer Keys from Storage && Vehicles to player or vice versa
    // OBJ1 to OBJ2
    private ["_obj1","_obj2","_index","_isStor1","_isStor2","_isVeh1","_isVeh2","_obj1Keys","_cnt","_vars","_alrHasKey","_obj2Keys"];

    params [["_obj1",objNull],["_obj2",objNull],["_index",0]];

    if !(isNull _obj1 || isNull _obj2) then {
        _isStor1 = _obj1 call EPOCH_fnc_server_isStorageObj;
        _isStor2 = _obj2 call EPOCH_fnc_server_isStorageObj;

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
                _obj1 call EPOCH_fnc_server_targetKeyInfo;
                [_obj1, _obj1 getVariable["VARS", []] ] call EPOCH_server_savePlayer;

                // Store on Object
                _alrHasKey = [(_vars select 0),(_vars select 1),(_vars select 2),_obj2] call EPOCH_fnc_server_alreadyHasKey;
                _obj2Keys = _obj2 getVariable ["VEHICLE_KEYS", [[],[]] ];
                if (_alrHasKey isEqualType 0) then {
                    (_obj2Keys select 1) set [_alrHasKey,(_cnt)+1];
                } else {
                    (_obj2Keys select 0) pushBack _vars;
                    (_obj2Keys select 1) pushBack _cnt;
                };
                _obj2 setVariable ["VEHICLE_KEYS", _obj2Keys];
                _obj2 setVariable ["HAS_KEYS", true, true];
                _obj2 call EPOCH_fnc_server_targetKeyInfo;
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
                _obj1 call EPOCH_fnc_server_targetKeyInfo;
                [[_obj1]] call EPOCH_server_save_vehicles;

                // Give to Player
                _alrHasKey = [(_vars select 0),(_vars select 1),(_vars select 2),_obj2] call EPOCH_fnc_server_alreadyHasKey;
                _obj2Keys = _obj2 getVariable ["VEHICLE_KEYS", [[],[]] ];
                if (_alrHasKey isEqualType 0) then {
                    (_obj2Keys select 1) set [_alrHasKey,(_cnt)+1];
                } else {
                    (_obj2Keys select 0) pushBack _vars;
                    (_obj2Keys select 1) pushBack _cnt;
                };
                _obj2 setVariable ["VEHICLE_KEYS", _obj2Keys];
                _obj2 setVariable ["HAS_KEYS", true, true];
                _obj2 call EPOCH_fnc_server_targetKeyInfo;
                [_obj2, _obj2 getVariable["VARS", []] ] call EPOCH_server_savePlayer;

                [format["You've taken a %1 key",(getText(configFile >> 'CfgVehicles' >> (_vars select 0) >> 'displayName'))],5] remoteExec ["Epoch_Message",_obj2];
            };

            //diag_log text format ["DEBUG: transferKeysStor: obj1- %1 / obj2- %2 / index- %3 / obj1Keys- %4",(typeof _obj1),(name _obj2),_index,str _obj1Keys];
        };
    };
};

EPOCH_fnc_server_deleteKey = {
    // Drops a key the player has
    private ["_player","_cid","_index","_caller","_playerKeys","_cnt","_vars"];

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
            _player call EPOCH_fnc_server_targetKeyInfo;
            [_player, _player getVariable["VARS", []] ] call EPOCH_server_savePlayer;

            if (count (_playerKeys select 0) < 1) then {
                _player setVariable ["HAS_KEYS", false, true];
                _player call EPOCH_fnc_server_targetKeyInfo;
            };

            [format["You deleted a %1 key",(getText(configFile >> 'CfgVehicles' >> (_vars select 0) >> 'displayName'))],5] remoteExec ["Epoch_Message",_player];

            //diag_log text format ["DEBUG: deleteKey: player- %1 / cid- %2 / index- %3 / caller- %4 / plyrKeys- %5",_player,_cid,_index,_caller,str _playerKeys];
        };
    };
};

EPOCH_fnc_server_alreadyHasKey = {
    // Checks whether the object already has the provided key on it
    // If it does, we don't want to give duplicates, just more copies
    // Returns BOOL on FAIL or INDEX NUMBER on SUCCESS
    private ["_type","_secret","_target","_return","_keys","_color"];

    params [["_type",""],["_secret",""],["_color",""],["_target",objNull]];

    if !(_type isEqualTo "" || _secret isEqualTo "" || _color isEqualTo "" || isNull _target) then {
        _return = false;
        _keys = _target getVariable ["VEHICLE_KEYS", [[],[]] ];
        if (count (_keys select 0) > 0) then {
            {
                if (_x isEqualTo [_type,_secret,_color]) then {
                    _return = _forEachIndex;
                };
            } forEach (_keys select 0);

            _return
        } else { false };
    } else { false };
};

EPOCH_fnc_server_testVehKey = {
    // Takes provided vehicle secret and compares it to DB hash
    // Returns BOOL on accepted or failed
    private ["_vehicle","_testSecret","_vehDBHash","_testHash"];

    params [["_vehicle",objNull],["_testSecret",""]];

    if (isNull _vehicle || {!alive _vehicle} || {_testSecret isEqualTo ""} || {_testSecret isEqualTo "NOKEY"}) then { false } else {
        _vehDBHash = _vehicle call EPOCH_fnc_server_hashVehicle;
        _testHash = "";
        if (_vehDBHash isEqualTo "NOKEY") then { true } else {
            _testHash = [_vehicle,_testSecret] call EPOCH_fnc_server_hashVehicle;

            if (_vehDBHash isEqualTo _testHash) then { true } else { false };
        };
    };
};

EPOCH_fnc_server_isStorageObj = {
    // Returns BOOL on whether the class/obj provided is buildable storage
    private ["_obj","_type","_cfgBaseBuilding","_staticClassConfig","_staticClass"];

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
};

diag_log "Epoch: Loading vehicles";
// Vehicle slot limit set to total of all allowed limits
_allowedVehicleIndex = if (EPOCH_modCUPVehiclesEnabled) then {if (EPOCH_mod_madArma_Enabled) then {3} else {1}} else {if (EPOCH_mod_madArma_Enabled) then {2} else {0}};
_allowedVehicleListName = ["allowedVehiclesList","allowedVehiclesList_CUP","allowedVehiclesList_MAD","allowedVehiclesList_MADCUP"] select _allowedVehicleIndex;
if !(EPOCH_forcedVehicleSpawnTable isEqualTo "") then {
    _allowedVehicleListName = EPOCH_forcedVehicleSpawnTable;
};
// do something here

_allowedVehiclesList = getArray(_epochConfig >> worldName >> _allowedVehicleListName);
_vehicleSlotLimit = 0;
{_vehicleSlotLimit = _vehicleSlotLimit + (_x select 1)} forEach _allowedVehiclesList;
_ReservedVehSlots = [_serverSettingsConfig, "ReservedVehSlots", 50] call EPOCH_fnc_returnConfigEntry;
_vehicleSlotLimit = _vehicleSlotLimit + _ReservedVehSlots;
if (EPOCH_useOldLoadVehicles) then {
    _vehicleSlotLimit call EPOCH_load_vehicles_old;
} else {
    _vehicleSlotLimit call EPOCH_load_vehicles;
};
diag_log "Epoch: Spawning vehicles";
_allowedVehiclesListArray = [];
{
    _x params ["_vehClass","_velimit"];
     _vehicleCount = {(_x getvariable ["VEHICLE_BaseClass",typeOf _x]) == _vehClass} count vehicles;

    // Load how many of this vehicle are in stock at any trader.
    _indexStock = EPOCH_traderStoredVehicles find _vehClass;
    if (_indexStock != -1) then {
        _existingStock = EPOCH_traderStoredVehiclesCnt select _indexStock;
        _vehicleCount = _vehicleCount + _existingStock;
    };

    for "_i" from 1 to (_velimit-_vehicleCount) do {
        _allowedVehiclesListArray pushBack _vehClass;
    };
} forEach _allowedVehiclesList;
[_allowedVehiclesListArray] call EPOCH_spawn_vehicles;

diag_log "Epoch: Loading storage";
EPOCH_StorageSlotsLimit call EPOCH_load_storage;

diag_log "Epoch: Loading static loot";
call EPOCH_server_spawnBoatLoot;

[] execFSM "\epoch_server\system\server_monitor.fsm";

// Setting Server Date and Time
_dateChanged = false;
_date = date;

_staticDateTime = [_serverSettingsConfig, "StaticDateTime", []] call EPOCH_fnc_returnConfigEntry;
_timeDifference = [_serverSettingsConfig, "timeDifference", 0] call EPOCH_fnc_returnConfigEntry;

if (_staticDateTime isEqualto []) then {
    _response = "epochserver" callExtension "510";
    if (_response != "") then {
        diag_log format ["Epoch: Set Real Time: %1", _response];
        _date = parseSimpleArray _response;
        _date resize 5;
        _date set[0, (_date select 0) + 21];
        _date set[3, (_date select 3) + _timeDifference];
        _dateChanged = true;
    };
} else {
    {
        if (_x != 0) then {
            _date set [_forEachIndex, _x];
            _dateChanged = true;
        };
    }forEach _staticDateTime;
};
if (_dateChanged) then {
    setDate _date;
    //add 1 min to be 100% correct
    _date set [4, (_date select 4) + 1];
    _date spawn {
        uiSleep 60;
        setDate _this;
    };
};

_config = 'CfgServicePoint' call EPOCH_returnConfig;
_servicepoints = getArray (_config >> worldname >> 'ServicePoints');
{
	_pos = _x;
	_markertxt = "Service Point";
	if (count _x > 3) then {
		_pos = _x select 0;
		if ((_x select 3) isequaltype "") then {
			_markertxt = _x select 3;
		};
	};
	if !(_markertxt isequalto "") then {
		_markers = ["ServicePoint", _pos,_markertxt] call EPOCH_server_createGlobalMarkerSet;
		if !(surfaceiswater _pos) then {
			"Land_HelipadCircle_F" createvehicle _pos;
		};
	};
} forEach _ServicePoints;

// Remove Auto-Refuel from all maps
if ([_serverSettingsConfig, "disableAutoRefuel", false] call EPOCH_fnc_returnConfigEntry) then {
    // get all fuel source objects on the map (Note: this maybe slow consider refactor with another command)
    _staticFuelSources = ((epoch_centerMarkerPosition nearObjects ['Building',EPOCH_dynamicVehicleArea]) select {getFuelCargo _x > 0});
    // globalize all fuel sources
    missionNamespace setVariable ["EPOCH_staticFuelSources", _staticFuelSources, true];
}
else {
	// Remove Auto-Refuel in PlotPole-Range
	if ([_serverSettingsConfig, "disableFuelNearPlots", true] call EPOCH_fnc_returnConfigEntry) then {
		_buildingJammerRange = ["CfgEpochClient", "buildingJammerRange", 75] call EPOCH_fnc_returnConfigEntryV2;
		_staticFuelSources = [];
		{
			{
				_staticFuelSources pushback _x;
			} foreach (((_x nearObjects ['Building',_buildingJammerRange]) select {getFuelCargo _x > 0}));

		} foreach (allmissionobjects "Plotpole_EPOCH");
		missionNamespace setVariable ["EPOCH_staticFuelSources", _staticFuelSources, true];
	};
};

// set time multiplier
setTimeMultiplier ([_serverSettingsConfig, "timeMultiplier", 1] call EPOCH_fnc_returnConfigEntry);

// globalize tax rate
missionNamespace setVariable ["EPOCH_taxRate", [_serverSettingsConfig, "taxRate", 0.1] call EPOCH_fnc_returnConfigEntry, true];

// pick random radioactive locations
_radioactiveLocations = getArray(_epochConfig >> worldName >> "radioactiveLocations");
_blacklist = getArray(_epochConfig >> worldName >> "radioactiveLocBLObjects");
_distance = getNumber(_epochConfig >> worldName >> "radioactiveLocBLDistance");
_radioactiveLocationsTmp = [];
if !(_radioactiveLocations isEqualTo []) then {
	private _locations = nearestLocations[epoch_centerMarkerPosition, _radioactiveLocations, EPOCH_dynamicVehicleArea];
	if !(_locations isEqualTo []) then {
		{
			_locPOS = locationPosition _x;
			_nearBLObj = nearestObjects [_locPOS, _blacklist, _distance];
			if!(_nearBLObj isEqualTo [])then{_locations = _locations - [_x]};
		}forEach _locations;
		for "_i" from 0 to ((getNumber(_epochConfig >> worldName >> "radioactiveLocationsCount"))-1) do
		{
			if (_locations isEqualTo []) exitWith {};
			private _selectedLoc = selectRandom _locations;
			_locations = _locations - [_selectedLoc];
			_locSize = size _selectedLoc;
			_radius = sqrt((_locSize select 0)^2 + (_locSize select 1)^2);
			_locName = (str(_selectedLoc)) splitString " ";
			_radioactiveLocationsTmp pushBack [_locName,[random 666,_radius]];
			private _position = locationPosition _selectedLoc;
			_markers = ["Radiation", _position] call EPOCH_server_createGlobalMarkerSet;
		};
	};
	_customRadioactiveLocations = getArray(_epochConfig >> worldName >> "customRadioactiveLocations");
	if !(_customRadioactiveLocations isEqualTo []) then {
		{
			_x params [["_position",[0,0,0]],["_radius",0],["_className",""] ];
			if ((!(_position isEqualTo [0,0,0]) && !(_radius isEqualTo 0) && !(_className isEqualTo "")) && ((nearestObjects [_position, _blacklist, _distance]) isEqualTo [])) then{
				_object = (_x select 2) createVehicle _position;
				_object setVariable ["EPOCH_Rads",[random 666,(_x select 1)],true];
				_markers = ["Radiation", _position] call EPOCH_server_createGlobalMarkerSet;
				_object setVariable ["EPOCH_MarkerSet",_markers,true];
			}else{
				diag_log "EPOCHDebug:Check your custom radioactive locations for errors or blacklisted locations";
			};
		}forEach _customRadioactiveLocations;
	};
};
missionNamespace setVariable ["EPOCH_radioactiveLocations", _radioactiveLocationsTmp, true];

// spawn bunkers, just in VR for now.
if (worldName == "VR") then {
	_debug = true;
	_debugLocation = getMarkerPos "respawn_west";
	_memoryPoints = ["one","two","three","four"];
	_bunkerCounter = 0;
	_newBunkerCounter = 0;

	// size
	_maxRows = 30;
	_maxColumns = 30;

	_rngChance = 0; // Lower this to spawn more positions
	_scriptHiveKey = "EPOCH:DynamicBunker"; // do not change

	_bunkerLocationsKey = format ["%1:%2", _instanceID, worldname]; // change instance id to force a new map to be generated.
	_response = [_scriptHiveKey, _bunkerLocationsKey] call EPOCH_fnc_server_hiveGETRANGE;
	_response params [["_status",0],["_data",[]] ];

	_firstBunker = objNull;
	_bunkerLocations = [];

	// check for proper return and data type
	if (_status == 1 && _data isEqualType [] && !(_data isEqualTo [])) then {
		_bunkerLocations = _data;

		// spawn cached bunkers
		{
			if (_x isEqualType [] && !(_x isEqualTo [])) then {
				_x params ["_selectedBunker", "_posWorld", ["_memoryPointsStatus",[]] ];
				_object = createSimpleObject [_selectedBunker, _posWorld];
				if (isNull _firstBunker) then {_firstBunker = _object;};
				{
					_object animate [_x,(_memoryPointsStatus param [_forEachIndex,1]),true];
				} forEach _memoryPoints;
				_bunkerCounter = _bunkerCounter + 1;
			};
		} forEach _bunkerLocations;

	} else {

		// generate new bunker
		_size = 13.08;

		_allBunkers = [];
		_newBunkerCounter = 0;
		// Generate Seed
		_seed = random 999999;
		diag_log format["Generating bunker with seed: %1",_seed];
		_location = _debugLocation;
		_originalLocation = +_location;
		_valuesAndWeights = [
			"bunker_epoch", 0.2, // empty bunker
			"bunker_epoch_01", 0.1, // tall concrete maze 1
			"bunker_epoch_02", 0.05, // Epoch Corp storage
			// "bunker_epoch_03", 0.01, // save for xmas
			"bunker_epoch_04", 0.05, // generator room
			// "bunker_epoch_05", 0.01, // invisible walls
			"bunker_epoch_06", 0.05, // jail
			"bunker_epoch_07", 0.05, // clone chamber
			"bunker_epoch_08", 0.01, // epoch celebration room
			"bunker_epoch_09", 0.05, // tallest concrete walls
			"bunker_epoch_10", 0.05, // knee high concrete walls
			"bunker_epoch_11", 0.1, // sewer
			"bunker_epoch_12", 0.05, // concrete mid wall
			"bunker_epoch_13", 0.05, // tall concrete maze 2
			"bunker_epoch_14", 0.08, // odd concrete walls
			"bunker_epoch_15", 0.05   // concrete mid wall maze
		];
		_rowCount = 0;
		_colCount = 0;
		//spawn x number of connected bunkers.
		while {true} do {
			if (_colCount > _maxColumns) exitWith {};
			_rng = _seed random [_location select 0,_location select 1];
			if (_rng > _rngChance) then {
				_selectedBunker = selectRandomWeighted _valuesAndWeights;
				_object = createVehicle [_selectedBunker, _location, [], 0, "CAN_COLLIDE"];
				if (isNull _firstBunker) then {_firstBunker = _object;};
				_allBunkers pushBack _object;
				_newBunkerCounter = _newBunkerCounter + 1;
			};
			_location set [0,(_location select 0) + _size];
			_rowCount = _rowCount + 1;
			if (_rowCount >= _maxRows) then {
				_rngChance = 0.3;
				_colCount = _colCount + 1;
				_rowCount = 0;
				_location set [0,_originalLocation select 0];
				_location set [1,(_location select 1) + _size];
			};
		};
		_score = 0;
		{
			_veh = _x;
			_animationStates = [];
			{
				_pOffset = _veh selectionPosition _x;
				if !(_pOffset isEqualTo [0,0,0]) then {
					_loc1 = _veh modelToWorldVisual _pOffset;
					_list = _loc1 nearObjects ["bunker_epoch", 1];
					if !(_list isEqualTo []) then {
						_score = _score + 1;
						_animationStates pushBack 0;
						_veh animate [_x,0];
					} else {
						_animationStates pushBack 1;
						_veh animate [_x,1];
					};
				};
			} forEach _memoryPoints;
			_modelInfo = getModelInfo _veh;
			_bunkerLocations pushBack [_modelInfo select 1, getPosWorld _veh, _animationStates, _score];
		} forEach _allBunkers;

		// save to DB
		[_scriptHiveKey, _bunkerLocationsKey, _bunkerLocations] call EPOCH_fnc_server_hiveSET;
	};

	// move respawn point into first bunker.
	if (!(isNull _firstBunker) && {_firstBunker distance _debugLocation > 1}) then {
		deleteMarker "respawn_west";
		createMarker ["respawn_west", getposATL _firstBunker];
	};

	if (_debug) then {
	    diag_log format["DEBUG: Spawned %1 Existing Bunker",_bunkerCounter];
	    if (_newBunkerCounter > 0) then {
	        diag_log format["DEBUG: Spawned %1 New Bunker.",_newBunkerCounter];
	    };
	};
};



// start accepting logins
missionNamespace setVariable ["EPOCH_SERVER_READY", true, true];

// spawn a single sapper to preload
_sapper = createAgent ["Epoch_Sapper_F", [0,0,0], [], 0, "CAN_COLLIDE"];
_sapper setDamage 1;
_sapper enableSimulationGlobal false;

diag_log format ["Epoch: Server Start Complete: %1 seconds",diag_tickTime-_startTime];

// unit test start
if (EPOCH_enableUnitTestOnStart isEqualTo 1) then {
    call EPOCH_fnc_server_hiveUnitTest;
    EPOCH_enableUnitTestOnStart = nil;
};
