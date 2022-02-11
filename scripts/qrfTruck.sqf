/*
	Author: Ryker

	Description:
	Sends a QRF truck to the given position. The truck will drop off the units, RTB and despawn automatically.

	Parameter(s):
		0:	ARRAY - Array of unit types to spawn. This will determine the amount of units spawned

		1:	STRING - Vehicle type to spawn as the transport

		2: Where should the truck spawn
			ARRAY - Map position to spawn the units to. e.g [100,150,0]
			STRING - Map marker name

		3: Where should the truck drop off the units
			ARRAY - Map position to spawn the units to. e.g [100,150,0]
			STRING - Map marker name
			
		4 (Optional): Side of the driver and the units. If no side is given, it will be determined by the vehicle class.
			SIDE - Side of the units (https://community.bistudio.com/wiki/Side)

	Returns:
	BOOL
*/

params [
	["_units", objNull, [["string", "string"]]],
	["_vehicleType", objNull, ["string"]],
	["_spawnPos", [0,0,0], [[0,0,0], "markerName"]],
	["_targetPos",[0,0,0], [[0,0,0], "markerName"]],
	["_side", objNull, [blufor]]
];

if (!isServer) exitWith {};

//////// VARIABLES ////////
_waitTime = 120; //Time in seconds that the script will wait until forcefully deleting the RTB truck
_roadDetectionRange = 100; //How far from the given spawn position should the script look for a road. If a road is found the truck will spawn on it.

// ERROR HANDLING //
if (!(typeName _spawnPos in ["STRING", "ARRAY"])) exitWith {
	["QRF Truck ERROR: 3rd paramater needs to be type STRING or ARRAY. You gave %1", typeName _spawnPos] call BIS_fnc_error;
};

if (!(typeName _targetPos in ["STRING", "ARRAY"])) exitWith {
	["QRF Truck ERROR: 4th paramater needs to be type STRING or ARRAY. You gave %1", typeName _spawnPos] call BIS_fnc_error;
};

if (_spawnPos isEqualTo objNull) exitWith {
	["QRF Truck ERROR: unable to parse second 3rd parameter"] call BIS_fnc_error;
};

if (_targetPos isEqualTo objNull) exitWith {
	["QRF Truck ERROR: unable to parse second 4th parameter"] call BIS_fnc_error;
};

if (count _units < 1 or (_units isEqualTo objNull)) exitWith {
	["QRF Truck ERROR: 1st paramater cannot be empty"] call BIS_fnc_error;
};

if (_vehicleType isEqualTo objNull) exitWith {
	["QRF Truck ERROR: 2nd paramater cannot be empty"] call BIS_fnc_error;
};

if (typeName _vehicleType != "STRING") exitWith {
	["QRF Truck ERROR: 2nd paramater must be a string"] call BIS_fnc_error;
};

// Find a safe position on a road
if (typeName _spawnPos == "STRING") then {
	_spawnPos = getMarkerPos _spawnPos;
};

if (typeName _targetPos == "STRING") then {
	_targetPos = getMarkerPos _targetPos;
};
 
_checkForDriver = {
	_vehicle = _this select 0;

	if (driver _vehicle isEqualTo objNull) then {
		createVehicleCrew _vehicle;
    	diag_log "QRF Truck: No driver spawned with vehicle. Creating crew...";
	};
};

// Find nearest road and get safe spawn pos
_nearestRoad = [_spawnPos, _roadDetectionRange, []] call BIS_fnc_nearestRoad;
_pos = [getPos _nearestRoad, 0, 10, 5] call BIS_fnc_findSafePos;

private ["_driver", "_vehicle", "_soldiers", "_group"];

// If no side was given
if (_side isEqualTo objNull) then {
	_vehicle = createVehicle [_vehicleType, _pos];
	[_vehicle] call _checkForDriver;
	_side = side driver _vehicle;
	_group = group driver _vehicle;
	diag_log "QRF Truck: No side given as parameter. Copying side from vehicle...";
} else { // If side was given
	_vehicle = createVehicle [_vehicleType, _pos];
	deleteVehicle (driver _vehicle);
	_group = createGroup _side;
	systemChat format ["%1	%2", _side, side _group];
	_driver = _group createUnit [_units select 0, _pos, [], 5, "NONE"];
	[_driver] joinSilent _group;
	_driver assignAsDriver _vehicle;
	[_driver] orderGetIn true;

	waitUntil {driver _vehicle == _driver};
};

// Create mounting units
_soldiers = [];
{
	_unit = _group createUnit [_x, _pos, [], 5, "CARGO"];
	_unit assignAsCargo _vehicle;
	[_unit] joinSilent _group;
	_soldiers pushBack _unit;
	sleep 0.2;
} forEach _units;

_vehicle setDir (getDir _nearestRoad - 90);
_driver = group (driver _vehicle);

// Transport/Unload
_wpUnload = _driver addWaypoint [_targetPos, 0, 3, "unload"];
_wpUnload setWaypointType "TR UNLOAD";

waitUntil {(_targetPos distance2D (getPos leader _group) < 20) and (speed _vehicle < 1)};

// Have the driver exit the group
_gDriver = createGroup _side;
[_driver] joinSilent _gDriver;

// Dismount and stop units from jumping back in.
_soldiers allowGetIn false;
_group leaveVehicle _vehicle;

// Move infrantry 20 meters behind the vehicle
_dir = getDir _vehicle;
_pos = (getPos _vehicle) getPos [20, _dir - 180];
_wpMove = _group addWaypoint [_pos, 5];
_wpMove setWaypointType "MOVE";

// Move vehicle forward. Doesn't quite work
(driver _vehicle) doMove ((getPos _vehicle) getPos [10, _dir]);

//RTB
_wpRTB = _gDriver addWaypoint [_spawnPos, 0, 4, "rtb"];
_wpRTB setWaypointType "MOVE";
_wpRTB setWaypointSpeed "FULL";

// Once the vehicle is far enough, allow the infantry to remount.
waitUntil {(getPos _vehicle) distance2D _targetPos > 50};
_soldiers allowGetIn true;

// Despawn truck when close to spawn or enough time has passed
_time = time + _waitTime;
waitUntil {(getPos _vehicle) distance2D _spawnPos < 50 or ((time == _time));};
deleteVehicle driver _vehicle;
deleteVehicle _vehicle;

true
// EOF