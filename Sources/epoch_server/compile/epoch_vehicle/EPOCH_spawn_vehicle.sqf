/*
	Author: Aaron Clark - EpochMod.com

    Contributors:

	Description:
    Vehicle Spawn Function

    Licence:
    Arma Public License Share Alike (APL-SA) - https://www.bistudio.com/community/licenses/arma-public-license-share-alike

    Github:
    https://github.com/EpochModTeam/Epoch/tree/release/Sources/epoch_server/compile/epoch_vehicle/EPOCH_spawn_vehicle.sqf
*/
//[[[cog import generate_private_arrays ]]]
private ["_availableColorsConfig","_cfgEpochVehicles","_color","_colors","_count","_marker","_maxDamage","_removemagazinesturret","_removeweapons","_selections","_serverSettingsConfig","_textureSelectionIndex","_textures","_vehLockHiveKey","_vehObj","_secret"];
//[[[end]]]
params ["_vehClass","_position","_direction","_locked","_slot",["_player",objNull],["_can_collide","CAN_COLLIDE"],["_spawnLoot",false],["_spawnDamaged",true]];
if !(isClass (configFile >> "CfgVehicles" >> _vehClass)) exitWith {objNull};
_serverSettingsConfig = configFile >> "CfgEpochServer";
_removeweapons = [_serverSettingsConfig, "removevehweapons", []] call EPOCH_fnc_returnConfigEntry;
_removemagazinesturret = [_serverSettingsConfig, "removevehmagazinesturret", []] call EPOCH_fnc_returnConfigEntry;
_disableVehicleTIE = [_serverSettingsConfig, "disableVehicleTIE", true] call EPOCH_fnc_returnConfigEntry;
_vehObj = createVehicle[_vehClass, [random 500,random 500, 500], [], 0, "CAN_COLLIDE"];
// turn off BIS randomization
_vehObj setVariable ["BIS_enableRandomization", false];
if !(isNull _vehObj) then{
	_vehObj call EPOCH_server_setVToken;

	// add random damage to vehicle (avoid setting engine or fuel to 100% damage to prevent instant destruction)
	if (_spawnDamaged) then {
		{
			_maxDamage = if (_x in ["HitEngine","HitFuel","HitHull"]) then {0.8} else {1};
			_vehObj setHitIndex [_forEachIndex,((random 1 max 0.1) min _maxDamage)];
		} forEach ((getAllHitPointsDamage _vehObj) param [0,[]]);
	};
	// make vehicle immune from further damage.
	_vehObj allowDamage false;

	// Set Direction and position
	if (_direction isEqualType []) then{
		_vehObj setposATL _position;
		_vehObj setVectorDirAndUp _direction;
	} else {
		_vehObj setposATL _position;
		_vehObj setdir _direction;
	};
	// Normalize vehicle inventory
	clearWeaponCargoGlobal    _vehObj;
	clearMagazineCargoGlobal  _vehObj;
	clearBackpackCargoGlobal  _vehObj;
	clearItemCargoGlobal	  _vehObj;

	if !(_removeweapons isequalto []) then {
		{
			_vehObj removeWeaponGlobal _x;
		} foreach _removeweapons;
	};
	if !(_removemagazinesturret isequalto []) then {
		{
			_vehObj removeMagazinesTurret _x;
		} foreach _removemagazinesturret;
	};

	// Disable Termal Equipment
	if (_disableVehicleTIE) then {
		_vehObj disableTIEquipment true;
	};

	// Vehicle Lock
	_vehObj lock _locked;

	// randomize fuel TODO push min max to config
	_vehObj setFuel ((random 1 max 0.1) min 0.9);

	// get colors from config
	_cfgEpochVehicles = 'CfgEpochVehicles' call EPOCH_returnConfig;
	_availableColorsConfig = (_cfgEpochVehicles >> _vehClass >> "availableColors");
	if (isArray(_availableColorsConfig)) then{

	  _textureSelectionIndex = (_cfgEpochVehicles >> _vehClass >> "textureSelectionIndex");
	  _selections = if (isArray(_textureSelectionIndex)) then{ getArray(_textureSelectionIndex) } else { [0] };
	  _colors = getArray(_availableColorsConfig);
	  _textures = _colors select 0;
	  _color = floor(random(count _textures));
	  _count = (count _colors) - 1;
	  {
		if (_count >= _forEachIndex) then{
		  _textures = _colors select _forEachIndex;
		};
		_vehObj setObjectTextureGlobal[_x, (_textures select _color)];
	  } forEach _selections;
	  _vehObj setVariable["VEHICLE_TEXTURE", _color];
	};

	// add random loots
	if (_spawnLoot) then {
	  if (_vehClass isKindOf "Ship") then{
		[_vehObj, "VehicleBoat"] call EPOCH_serverLootObject;
	  } else {
		[_vehObj, "Vehicle"] call EPOCH_serverLootObject;
	  };
	};

	// Set slot used by vehicle
	_vehObj setVariable["VEHICLE_SLOT", _slot, true];

	// Lock vehicle for owner
	if (_locked && !isNull _player) then {
		// Create key for vehicle and give to player
		_secret = ('epochserver' callExtension format['810|%1', 1]);

		_rnd1 = (_vehClass+_secret) call EPOCH_fnc_server_hiveMD5;
		_vehHash = ((_rnd1)+(EPOCH_server_vehRandomKey)) call EPOCH_fnc_server_hiveMD5;

		_vehObj setVariable ["VEHICLE_KEYHASH",_vehHash];

		_plyrKeys = _player getVariable ["PLAYER_KEYS", [[],[]] ];
		(_plyrKeys select 0) pushback [_vehClass,_secret];
		(_plyrKeys select 1) pushback 1;
		_player setVariable ["PLAYER_KEYS",_plyrKeys];
	};
	_vehObj setVariable ["VEHICLE_KEYS", [[],[]] ];

	// new Dynamicsimulation
	if([configFile >> "CfgEpochServer", "vehicleDynamicSimulationSystem", true] call EPOCH_fnc_returnConfigEntry)then
	{
		_vehObj enableSimulationGlobal false; // turn it off until activated by dynamicSim
		_vehObj enableDynamicSimulation true;
	};

	// SAVE VEHICLE
	if (isNil "_secret") then {
		_vehObj call EPOCH_server_save_vehicle;
	} else {
		[_vehObj,_secret] call EPOCH_server_save_vehicle;
	};

	// Event Handlers
	_vehObj call EPOCH_server_vehicleInit;

	// Markers
	if (EPOCH_DEBUG_VEH) then{
	  _marker = createMarker[str(_position), _position];
	  _marker setMarkerShape "ICON";
	  _marker setMarkerType "mil_dot";
	  _marker setMarkerText _vehClass;
	};

	// Add to A3 remains collector
	addToRemainsCollector[_vehObj];

	// make vehicle mortal again
	_vehObj allowDamage true;

	//diag_log text format ["DEBUG: Spawn Vehicle: Class- %1 / Pos- %2 / Dir- %3 / Slot- %4 / player- %5 / Nil Secret?- %6",_vehClass,_position,_direction,_slot,_player,(isNil "_secret")];

} else {
	diag_log format["DEBUG: Failed to create vehicle: %1", _this];
};

_vehObj
