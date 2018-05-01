/*
	Author: Vampire - EpochMod.com

	Description:
	   Compares the information provided against a hash of the information in the database

    Licence:
    Arma Public License Share Alike (APL-SA) - https://www.bistudio.com/community/licenses/arma-public-license-share-alike

    Github:
    https://github.com/EpochModTeam/Epoch/tree/release/Sources/epoch_server/compile/epoch_bases/EPOCH_server_testVehKey.sqf

    Parameters
		0 - Vehicle Object
        1 - Vehicle Secret

	Returns
		BOOL
*/
//[[[cog import generate_private_arrays ]]]
private ["_vehicle","_testSecret","_vehDBHash","_testHash"];
//[[[end]]]

params [["_vehicle",objNull],["_testSecret",""]];

if (isNull _vehicle || {!alive _vehicle} || {_testSecret isEqualTo ""} || {_testSecret isEqualTo "NOKEY"}) then { false } else {
    _vehDBHash = _vehicle call EPOCH_server_hashVehicle;
    _testHash = "";
    if (_vehDBHash isEqualTo "NOKEY") then { true } else {
        _testHash = [_vehicle,_testSecret] call EPOCH_server_hashVehicle;

        if (_vehDBHash isEqualTo _testHash) then { true } else { false };
    };
};
