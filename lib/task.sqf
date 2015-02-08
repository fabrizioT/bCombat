bcombat_fnc_task_set =
{
	private ["_unit", "_task", "_priority", "_args", "_handle", "_msg"];
		
	_unit = _this select 0;
	_task = _this select 1; 
	_priority = _this select 2; 
	_args = _this select 3; 
	
	if( [_unit] call bcombat_fnc_is_active ) then 
	{
		if( [ _unit, _priority ] call bcombat_fnc_task_check_priority ) then
		{
			if( [_unit] call bcombat_fnc_has_task ) then
			{
				[_unit] call bcombat_fnc_task_clear;
			};
			
			_unit setVariable ["bcombat_task", [ "", _task, _priority, _args ] ];
			_handle = [_unit, _task, _priority, _args] spawn ( call compile format["%1", _task] );
			_unit setVariable ["bcombat_task", [ _handle, _task, _priority, _args ] ];
			
			if( bcombat_debug_enable ) then {
				_msg = format["bcombat_fnc_task_set() - unit=%1, task=%2, priority=%3, args=%4, handle=%5", _unit, _task, _priority, _args, _handle];
				[ _msg, 6 ] call bcombat_fnc_debug;
			};	
		};
	};
};

bcombat_fnc_has_task =
{
	private ["_unit", "_task", "_ret", "_msg"];
		
	_unit = _this select 0;
	_ret = false;
	_task = _unit getVariable ["bcombat_task", nil ];
	
	if( !( isNil "_task" ) ) then
	{
		_ret = true;
	};
	
	_ret
};

bcombat_fnc_task_check_priority =
{
	private ["_unit", "_priority", "_task", "_ret", "_handle", "_msg"];
	
	_unit = _this select 0;
	_priority = _this select 1;
	
	_task = _unit getVariable ["bcombat_task", nil ];
	_ret = true;

	if( [_unit] call bcombat_fnc_is_active ) then 
	{
		if( !( isNil "_task" ) ) then
		{
			_handle = _task select 0;
			
			if(  _priority <= _task select 2 ) then
			{	
				_ret = false;
				
				if( bcombat_debug_enable) then {
					_msg = format["bcombat_fnc_task_check_priority() - BLOCKED, unit=%1, priority=%2", _unit, _priority];
					[ _msg, 6 ] call bcombat_fnc_debug;
				};
			};
		};
	}
	else
	{
		_ret = false;
	};
	
	_ret
};

bcombat_fnc_task_clear =
{	
	private ["_unit", "_task", "_handle", "_msg"];

	_unit = _this select 0;
	
	if( alive _unit ) then 
	{
		if( bcombat_debug_enable) then {
			_msg = format["bcombat_fnc_task_clear() - unit=%1", _unit];
			[ _msg, 6 ] call bcombat_fnc_debug;
		};

		_task = _unit getVariable ["bcombat_task", nil ];
		
		if( bcombat_debug_enable) then {
			_msg = format["bcombat_fnc_task_clear() - unit=%1, task=%2", _unit, _task];
			[ _msg, 6 ] call bcombat_fnc_debug;
		};
		
		if( !( isNil "_task" ) ) then
		{

			_unit enableAI "autotarget";
			_unit enableAI "target";
			_unit enableAI "MOVE";
			_unit enableAI "FSM";
			
			_handle = _task select 0;
			
			if ( !(scriptDone _handle) ) then { terminate _handle; };
		};
		
		_unit setVariable ["bcombat_task", nil];
	};
};

bcombat_fnc_task_fire =
{
	private ["_unit", "_task", "_priority", "_args", "_enemy", "_mode", "_mgun", "_timeout", "_dist", "_speed", "_msg"];

	_unit = _this select 0;
	_task = _this select 1; 
	_priority = _this select 2; 
	_args  = _this select 3; 
	_enemy = _args select 0;
	_mode = _args select 1;	// 1 normal, 2 under fire
	_mgun = [currentWeapon _unit] call bcombat_fnc_is_mgun;
	
	_unit disableAI "autotarget";
	
	// Keep currently assigned target, if in LOS
	_atarget = assignedtarget _unit;
	if( !(isNull _atarget) 
		&& { _unit != _atarget }
		&& { _atarget != _enemy  }
		&& { alive _atarget }
		&& { _mode == 1 }
	) then {
		if( [ _unit, _atarget] call bcombat_fnc_is_visible ) then
		{
			//player globalchat format["%1 - Target changed from %2 to %3", _unit, _enemy, _atarget];
			_enemy = _atarget;
			_unit doWatch _atarget;
		};
	};
	
	_timeout = 2;
	_dist = _unit distance _enemy;
	_speed = [ _unit ] call bcombat_fnc_speed;
	_visible = [ _unit, _enemy] call bcombat_fnc_is_visible;
	
	if( [_unit] call bcombat_fnc_is_active
		&& { _unit != _enemy }
		&& { !(fleeing _unit) } 
		&& { !(isPlayer _unit ) }
		) then 
	{
		if( bcombat_debug_enable ) then {
			_msg = format["bcombat_fnc_task_fire() - BEGIN, unit=%1, enemy=%2, distance=%3, mode=%4, vis=%5, firetime=%6", _unit, _enemy, _dist, _mode, [_unit, _enemy] call bcombat_fnc_is_visible, _unit getVariable ["bcombat_fire_time", 0]];
			[ _msg, 6 ] call bcombat_fnc_debug;
		};

		//if( [_unit, _enemy] call bcombat_fnc_knprec <= 2 || _dist < 150 ) then
		if( true ) then
		{		
			//_unit reveal [_enemy, 4];
			_unit glanceAt _enemy; 
			_unit doWatch _enemy; 
			sleep .01;

			if( combatMode (group _unit) in ["RED", "YELLOW"]  ) then
			{
				if( bcombat_allow_targeting 
					&& { _dist < (bcombat_targeting_max_distance select 0) || ( combatMode _unit == "RED" && _dist < (bcombat_targeting_max_distance select 1) ) } 
					&& { !(isPlayer (leader _unit)) } 
					&& { damage _unit < 0.25 } 
				    && { _unit getVariable ["bcombat_suppression_level", 0] <= 25  } 
					&& { random 100 > _unit getVariable ["bcombat_suppression_level", 0] } 
				) then {
					_unit doWatch _enemy;
					_unit doTarget _enemy;
				};

				if( _visible ) then 
				{
					if( _mode == 2 ) then
					{
						if( 
							_speed < 3.5 ||
							(assignedTarget _unit) == _enemy ||
							_dist < 25 || 
							[_unit, _enemy] call bcombat_fnc_relativeDirTo < 75 ||
							isHidden _unit ||
							{
								_dist < 250 
								&& ( !([_unit] call bcombat_fnc_in_formation) || _unit distance (formationLeader _unit) < 50 ) 
							}
						) then
						{
							if( _mgun ) then {
								[_unit, 10 + random 10, 20 + random 30, 5,_dist] call bcombat_fnc_stop;
							}
							else
							{
								[_unit, 3, 5 + random 5, 3, _dist] call bcombat_fnc_stop;
							};
						};
					}
					else
					{
						if(  
							 _speed < 3 ||
							 (assignedTarget _unit) == _enemy ||
							_dist < 25 || 
							isHidden _unit ||
							[_unit, _enemy] call bcombat_fnc_relativeDirTo < 75 ||
							{
								_dist < 250 
								&& ( !([_unit] call bcombat_fnc_in_formation) || _unit distance (formationLeader _unit) < 50 ) 
							}
						) then
						{
							
							if( _mgun ) then {
							
								[_unit, 10 + random 10, 20 + random 30, 5, _dist] call bcombat_fnc_stop;
							}
							else
							{
								[_unit, 3, 5 + random 5, 3, _dist] call bcombat_fnc_stop;
							};
						};
					
					};
	
					_unit suppressFor 0;
					_unit dofire _enemy;
				}
				else
				{
					if( bcombat_allow_suppressive_fire 
						&& { _mode == 1 } 
						&& { currentWeapon _unit == primaryWeapon _unit }
						&& { _unit ammo (currentWeapon _unit) > 10 }
						&& { _dist < (bcombat_suppressive_fire_distance select 1) }
						&& { _dist > (bcombat_suppressive_fire_distance select 0) }
					) then { 
					
						_unit suppressFor 0;
						if( [currentWeapon _unit] call bcombat_fnc_is_mgun ) then 
						{
							[_unit, _enemy, (bcombat_suppressive_fire_duration select 1)] call bcombat_fnc_suppress; 
						}
						else
						{
							[_unit, _enemy, (bcombat_suppressive_fire_duration select 0)] call bcombat_fnc_suppress; 
						};
					
					};
				};
			};
			
			sleep _timeout;
		};
	};
	
	if( [_unit] call bcombat_fnc_is_alive ) then 
	{
		_unit enableAI "autotarget";
		_unit setVariable ["bcombat_task", nil];
		
		if( bcombat_debug_enable ) then {
			_msg = format["bcombat_fnc_task_fire() - END, unit=%1, enemy=%2, distance=%3, mode=%4, vis=%5, firetime=%6", _unit, _enemy, _dist, _mode, [_unit, _enemy] call bcombat_fnc_is_visible, _unit getVariable ["bcombat_fire_time", 0]];
			[ _msg, 6 ] call bcombat_fnc_debug;
		};
	};
	
	if (true) exitWith {};
};

bcombat_fnc_task_move_to_cover =
{
	private ["_unit", "_task", "_priority", "_args", "_cover", "_grp", "_blacklist",  "_cover",  "_msg", "_pos", "_type", "_dist", "_timeout1", "_timeout2"];

	_unit = _this select 0;
	_task = _this select 1; 
	_priority = _this select 2; 
	_args  = _this select 3;
	//_radius = _args select 0;
	_cover = _args select 0;
	//_enemy = _args select 1;
	_grp = group _unit;
	
	
	
	if( bcombat_debug_enable ) then {
		_msg = format["bcombat_fnc_task_move_to_cover() - unit = %1, cover = %2", _unit, _cover];
		[ _msg, 30 ] call bcombat_fnc_debug;   
	};
	
	sleep random .1;
	
	//if( !(isNil "_cover") ) then 
	//{
		private [];
		
		_pos = _cover select 0;
		_type = _cover select 2;
		_dist =  _unit distance _pos;
		_timeout1 = time + 10;
		_timeout2 = 0;
		
		if( _type == 1) Then // building with positions
		{
			_timeout1 = time + 15 + random 15;
			_timeout2 = 30 + random 30;
		};
		
		if( bcombat_debug_enable ) then {
			_msg = format["bcombat_fnc_task_move_to_cover() - BEGIN, unit=%1 distance=%2, args=%3", _unit,  _dist, _args];
			[ _msg, 6 ] call bcombat_fnc_debug;
		};
	
		if( _dist > 5 ) then
		{
			_unit disableAI "target";
			_unit disableAI "autotarget";
			//_unit disableAI "FSM";
			
			_unit doWatch objNull;
			dostop _unit;
			sleep .05;
			
			//_unit domove _pos;
			_unit moveTo _pos;
			_unit forcespeed 20;
			
			//_unit setDestination [ _pos , "LEADER PLANNED", true];

			while { alive _unit 
					&& { !(unitready _unit) }
				&& { time < _timeout1 }
				&& { _unit distance _pos > 2 }
					//&& { !(movetofailed _unit) } 
					//&& { !(movetocompleted _unit) }
				//&& { currentCommand _unit == "STOP" }
			} do {
			
				sleep .5;
				
				_unit doWatch objNull;
	
				_unit forcespeed 20;
					
				/*
				//if( !(unitready _unit) )  then 
				{ 
					if( [ _unit ] call bcombat_fnc_speed < 1 ) then 
					{
							//_unit moveTo _pos;
							
						//_unit domove _pos;
						//_unit setDestination [ _pos , "LEADER PLANNED", false];
					};
				};
				*/
			};
			
			
			_unit enableAI "autotarget";
			_unit enableAI "target";
			//_unit enableAI "FSM";
			_unit forcespeed -1;
			
			/*
			if( 
				(  (currentCommand _unit != "STOP" && _unit distance _pos < 2) || moveToCompleted _unit) // || (unitready _unit && _unit distance _pos < 2.5)
			) then
			{
				
				_timeout2  = 0;
				
				if( _type == 1 ) then  {
				//hintc("OK1");
					_timeout2 = time + 60 +random 30;
				} else {
					_timeout2 = time + 5 +random 10;
				};
				
				waitUntil { time > _timeout2 };
			};
			
			 _unit domove (getPosATL _unit);
			 */
		};
	//};
	
	_unit setVariable ["bcombat_task", nil];
	if (true) exitWith {};
};


bcombat_fnc_task_throw_grenade = 
{
	private ["_unit", "_task", "_priority", "_args", "_enemy", "_pos", "_p", "_distance", "_h", "_ang", "_eh", "_w", "_msg"];

	_unit = _this select 0;
	_task = _this select 1; 
	_priority = _this select 2; 
	_args = _this select 3;
	_enemy = _args select 0;

	_w = format["%1", currentWeapon _unit];
	sleep .01;
	if(_w == "") then { _w = format["%1", primaryWeapon _unit]; };
	
	_distance = (_unit distance _enemy)  ;
	_distance = _distance + random( (_distance / 5) * ( 1 - (_unit Skill "aimingAccuracy") ) );
	
	_h 	= 0;//((getPosASL _unit) select 2) - ((getPosASL _enemy) select 2);

	_unit forcespeed 0;	
	_unit disableAI "TARGET";
	_unit disableAI "AUTOTARGET";
	_unit disableAI "FSM";
	
	_unit setvariable ["bcombat_grenade_lock", true];
	_unit setvariable ["bcombat_grenade_distance", _distance];
	_unit setvariable ["bcombat_grenade_h", _h];
	_unit selectWeapon "throw"; 
	
	sleep .05;
	
	[_unit, _enemy, 0, true] call bcombat_fnc_lookat;
	
	_ang = [_unit, _enemy] call bcombat_fnc_relativeDirTo_signed;
	
	_unit forcespeed 0;
	_unit setDir ((direction _unit) + _ang);
	
	//_unit fire ['HandGrenadeMuzzle', 'HandGrenadeMuzzle', 'HandGrenade'];
	_unit forceWeaponFire ["HandGrenadeMuzzle","HandGrenadeMuzzle"];

	sleep 2.5;

	_unit selectWeapon _w;

	_unit enableAI "TARGET";
	_unit enableAI "AUTOTARGET";
	_unit enableAI "FSM";
	
	_unit forcespeed -1;
	
	_unit setVariable ["bcombat_task", nil];
	if (true) exitWith {};
};

bcombat_fnc_task_throw_smoke_grenade = 
{
	private ["_unit", "_task", "_priority", "_args", "_enemy", "_pos", "_distance", "_h", "_ang", "_eh", "_w", "_msg", "_p"];

	_unit = _this select 0;
	_task = _this select 1; 
	_priority = _this select 2; 
	_args = _this select 3;
	_enemy = _args select 0;

	_w = format["%1", currentWeapon _unit];
	sleep .01;
	if(_w == "") then { _w = format["%1", primaryWeapon _unit]; };
	
	_distance = _unit distance _enemy;
	_h 	= ((getPosASL _unit) select 2) - ((getPosASL _enemy) select 2);

	_unit forcespeed 0;
	_unit disableAI "FSM";	
	//_unit disableAI "MOVE";	
	_unit disableAI "TARGET";
	_unit disableAI "AUTOTARGET";

	_unit setvariable ["bcombat_smoke_grenade_lock", true];
	_unit setvariable ["bcombat_smoke_grenade_distance", _distance];
	_unit selectWeapon "throw"; 
	
	sleep .05;
	
	[_unit, _enemy, 0, true] call bcombat_fnc_lookat;
	
	_ang = [_unit, _enemy] call bcombat_fnc_relativeDirTo_signed;
	
	_unit forcespeed 0;
	_unit setDir ((direction _unit) + _ang);
	//_unit fire ["HandGrenadeMuzzle","HandGrenadeMuzzle","HandGrenade"];
	
	_unit forceWeaponFire ["SmokeShellMuzzle","SmokeShellMuzzle"];

	sleep 2.5;
	
	_unit selectWeapon _w;

	//_unit enableAI "MOVE";
	_unit enableAI "TARGET";
	_unit enableAI "AUTOTARGET";
	_unit enableAI "FSM";
	
	_unit forcespeed -1;
	
	_unit setVariable ["bcombat_task", nil];
	if (true) exitWith {};
};