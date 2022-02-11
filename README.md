# Arma 3 QRF script
This script was made for Manticore Operations to be used in their community missions and events.

## Usage
Place the `scripts` folder into the root of your mission file where mission.sqm is located.  

Call the script through [triggers](https://community.bistudio.com/wiki/Eden_Editor:_Trigger#Attributes) or [code](https://community.bistudio.com/wiki/execVM).

Trigger example:
```
call{_units = ["I_Soldier_SL_F","I_soldier_F","I_Soldier_LAT_F","I_Soldier_M_F","I_Soldier_TL_F","I_Soldier_AR_F","I_Soldier_A_F","I_medic_F"];
[_units, "B_Truck_01_covered_F", "start", "destination"] execVM "scripts\qrfTruck.sqf";}
```

### Parameters
_Check the code for more detailed explanation of required variable types._

__The 1st parameter__ is an array of the [units](https://community.bistudio.com/wiki/Arma_3:_CfgVehicles_WEST) you want to load into the vehicle. These units will be dismounting once the waypoint has been reached.
You can get this in Eden by pressing mouse 2 and selecting _Log -> Log Classes to Clipboard._
Just remember to add the quotes.

For ease of use it's usually worthwhile to assign these to a separate variable and pass it to the function (check above for example).
```
_units = ["I_Soldier_SL_F","I_soldier_F","I_Soldier_LAT_F","I_Soldier_M_F","I_Soldier_TL_F"];
```

__The 2nd parameter__ is the type of [vehicle](https://community.bistudio.com/wiki/Arma_3:_CfgVehicles_WEST) you want to use. You can get this in Eden by pressing mouse 2 and selecting _Log -> Log Classes to Clipboard._
Just remember to add the quotes. __Keep in mind if no 4th parameter is provided the side of the units will be determined by the vehicle!__
```
"B_Truck_01_covered_F"
```

__The 3rd parameter__ is the spawn location of the vehicle while the __The 4th parameter__ is the drop off location. Both can be [position](https://community.bistudio.com/wiki/Position) arrays or markers [(variable name)](https://community.bistudio.com/wiki/Eden_Editor:_Marker#Attributes).
```
[100,200,100] //Position array
"spawn1" // Markername
```

__The 4th parameter__ is optional and will determine the [side](https://community.bistudio.com/wiki/Side) of the units. __If no side is given it will be determined by the vehicle class!__
```
blufor, opfor, independent, civilian
```
