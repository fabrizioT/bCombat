bLibFuncFindSuitablePlace =
{
	_ret = nil;
	
	private ["_center", "_minDist", "_maxDist", "_objectStr", "_pos"];

	_center = _this select 0;
	_minDist = _this select 1;
	_maxDist = _this select 2;
	_objectStr = _this select 3;
	_pos = _center findEmptyPosition [_minDist, _maxDist,_objectStr];
	
	if (count _pos > 0) then { _ret = _pos; };
	
	_ret
};


bLibFuncFindForestedPlaces = {

	private ["_center", "_radius", "_number", "_ret", "_p"];
	
	_center = _this select 0;
	_radius = _this select 1;
	
	_ret = nil;
	_prec = _radius / 20;
	_count = _radius / 10;
	
	_p = selectBestPlaces [_center, _radius, "forest - sea", 2, 20];
	
	//hintc format["%1", _p];
	
	if( count _p > 0) then
	{
		_ret = [];
		_i=0;
		{
			_i=_i+1;
			_name = format["mrk_%1", _i];
			
			_marker = createMarker [ _name, _x select 0];
			_marker setMarkerShape "ICON";
			_marker setMarkerType "mil_dot";

			_ret = _ret + [_x select 0];
			
		} foreach _p;
	};

	_ret
};


bLibScriptBuildObject =
{
	private ["_unit", "_pos", "_ang", "_buildPos", "_objectClass"];
	
	_unit = _this select 0;
	_pos = _this select 1;
	_objectClass = _this select 2;
	
	_hpos = (_pos select 2);
	_ang = random 360;
	_buildPos =  [ ((_pos select 0) + (2.5 * sin(_ang))) , ((_pos select 1) + (2.5 * cos(_ang))) ];
	
	
	//dostop _unit;
	//_unit domove _buildPos;

	dostop _unit;
	sleep .05;
	_unit moveTo _buildPos;
	

	
	sleep 1;

	waitUntil { unitReady _unit || _unit distance _buildPos < 2};
	
	_unit setPos _buildPos;
	_unit lookAt _pos;
	
	sleep 1;
	
	_unit playmove "MountSide"; 
	//"m2s2bodyguard"
	//_unit disableAI "ANIM";
	//sleep 5;

	_obj = _objectClass createVehicle [(_pos select 0), (_pos select 1), ( _hpos -2)];
	_timeout = time + 5;
	
	while { time < _timeout} do
	{
		_obj setPos [(_pos select 0), (_pos select 1), ( _hpos + 2 * ((time - _timeout) / 5) ) ];
		sleep 0.2;
	};
	
	_obj setPos _pos;
	//_unit domove getPos (formleader _unit);
	
	dostop _unit;
	sleep .05;
	_unit moveTo getPos (formleader _unit);
	
	
	
	_unit lookAt objNull;
};




[] spawn 
{
sleep 1;

_unit = buddy;
_candidatePos = [getPos _unit, 1000] call bLibFuncFindForestedPlaces;

if(count _candidatePos > 0) then 
{
	{
		scopeName "loop1";
		
		sleep .1;
		
		_pos = [_x, 5, 25, "Land_TentA_F"] call bLibFuncFindSuitablePlace;
		
		/*
		_isFlat = (position _preview) isflatempty [
		(sizeof typeof _preview) / 2,	//--- Minimal distance from another object
		0,				//--- If 0, just check position. If >0, select new one
		0.7,				//--- Max gradient
		(sizeof typeof _preview),	//--- Gradient area
		0,				//--- 0 for restricted water, 2 for required water,
		false,				//--- True if some water can be in 25m radius
		_preview			//--- Ignored object
	];*/
	
		_size = sizeof "Land_TentA_F";
		_nroads = count (_pos nearRoads 50);
		_isFlat = _pos isflatempty [0, 0, 0.5, 10, 0, false];
	
	player globalchat format["%1 --- %2", _nroads, _isFlat];
	
		if( !(isNil {_pos}) && _nroads == 0 && count _isFlat > 0) then { // && count _isFlat > 0
			hintc format["%1", _pos];
			
			//player setPos _x;
			_unit setPos _x;
			
			[_unit, _pos, "Land_TentA_F"] spawn bLibScriptBuildObject;
			
			breakOut "loop1";
		}
		
	} foreach _candidatePos;
};

};

//b= [buddy, getPos buddy, "Land_TentA_F"] spawn bLibScriptBuildObject;

