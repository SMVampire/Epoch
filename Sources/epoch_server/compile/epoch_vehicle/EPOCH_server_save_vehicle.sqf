/*
	Author: Aaron Clark - EpochMod.com

    Contributors:

	Description:
    Save Storage Object

    Licence:
    Arma Public License Share Alike (APL-SA) - https://www.bistudio.com/community/licenses/arma-public-license-share-alike

    Github:
    https://github.com/EpochModTeam/Epoch/tree/release/Sources/epoch_server/compile/epoch_vehicle/EPOCH_server_save_vehicle.sqf
*/
//[[[cog import generate_private_arrays ]]]
private ["_VAL","_baseType","_colorSlot","_hitpoints","_inventory","_vehHiveKey","_vehSlot","_provSecret","_response","_status","_oldVeh","_vehSecret","_storedKeys","_provColor","_keyColor"];
//[[[end]]]
params [["_vehicle",objNull],["_provSecret",""],["_provColor",""]];

if (!isNull _vehicle) then {

	if (!alive _vehicle) exitWith {diag_log format["DEBUG DEAD VEHICLE SKIPPED SAVE: %1 %2", _vehicle]};
	_vehSlot = _vehicle getVariable["VEHICLE_SLOT", "ABORT"];
	if (_vehSlot != "ABORT") then {

		_vehHiveKey = format ["%1:%2", (call EPOCH_fn_InstanceID),_vehSlot];

		_hitpoints = (getAllHitPointsDamage _vehicle) param [2,[]];

		_inventory = _vehicle call EPOCH_server_CargoSave;

		_colorSlot = _vehicle getVariable ["VEHICLE_TEXTURE",0];
		_baseType = _vehicle getVariable ["VEHICLE_BASECLASS",""];

		// Call DB for Key Secret
		_vehSecret = "";
		_response = ["Vehicle", _vehHiveKey] call EPOCH_fnc_server_hiveGETRANGE;
		_response params ["_status","_oldVeh"];
		if (_status == 1 && (_response select 1) isEqualType []) then {
			if (count _oldVeh > 10) then {
				_vehSecret = _oldVeh select 10;
				_keyColor = _oldVeh select 11;
				if (_vehSecret isEqualTo "") then {
					_vehSecret = _provSecret; // Use provided secret - DB secret is empty string
					_keyColor = _provColor;
				};
			} else {
				if (count _oldVeh == 0) then {
					// First Spawn - Use provided secret
					_vehSecret = _provSecret;
					_keyColor = _provColor;
				};
			};
		} else {
			_vehSecret = _provSecret; // Use provided secret - vehicle has never been saved
			_keyColor = _provColor;
		};

		_storedKeys = _vehicle getVariable ["VEHICLE_KEYS", [[],[]] ];

		//diag_log text format ["DEBUG: Save Vehicle: Class- %1 / Slot- %2 / provSecret- %3 / vehSecret- %4",(typeOf _vehicle),_vehSlot,_provSecret,_vehSecret];

		_VAL = [typeOf _vehicle,[getposworld _vehicle,vectordir _vehicle,vectorup _vehicle,true],damage _vehicle,_hitpoints,fuel _vehicle,_inventory,[true,magazinesAllTurrets _vehicle],_colorSlot,_baseType,(getPlateNumber _vehicle),_vehSecret,_keyColor,_storedKeys];
		["Vehicle", _vehHiveKey, EPOCH_expiresVehicle, _VAL] call EPOCH_fnc_server_hiveSETEX;
	};
};
