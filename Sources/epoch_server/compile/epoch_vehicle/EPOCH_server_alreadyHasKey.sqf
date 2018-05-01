/*
	Author: Vampire - EpochMod.com

	Description:
	   Checks if an object (player, vehicle, or buildable) already has a key for the vehicle

    Licence:
    Arma Public License Share Alike (APL-SA) - https://www.bistudio.com/community/licenses/arma-public-license-share-alike

    Github:
    https://github.com/EpochModTeam/Epoch/tree/release/Sources/epoch_server/compile/epoch_bases/EPOCH_server_alreadyHasKey.sqf

    Parameters
		OBJECT

	Returns
		BOOL on FAIL (FALSE)
        INDEX on SUCCESS (for easier adding of keys)
*/
//[[[cog import generate_private_arrays ]]]
private ["_type","_secret","_target","_return","_keys","_color"];
//[[[end]]]

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
