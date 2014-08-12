bcombat_fnc_bullet_incoming = 
{
	private [ "_unit", "_shooter", "_bullet",  "_bpos", "_pos", "_time", "_proximity", "_grp", "_visible", "_dist", "_penalty", "_speed", "_ang", "_x", "_hdiff", "_dt", "_cover" ];
	private ["_move_to_cover", "_nenemy"];
	
	_unit = _this select 0;		// unit being under fire
	_shooter = _this select 1;	// shooter
	
	if( [_unit] call bcombat_fnc_is_active ) then
	{
		if( 
			 _unit != _shooter 
			&& { !(captive _unit) }
			&& { _unit distance player < bcombat_degradation_distance } 
			&& { [_unit, _shooter] call bcombat_fnc_is_enemy }
		) then {
		
			_bullet = _this select 2;	// bullet object
			_bpos = _this select 3;	// bullet position
			_pos = _this select 4;	// starting position of bullet
			_time = _this select 5; // starting time of bullet
			_proximity = _bpos distance _unit;	// distance between _bullet and _unit
			_grp = group _unit;
			_visible = [_unit, _shooter] call bcombat_fnc_is_visible;
			_dist = _unit distance _shooter;
			_penalty = 0;
			_speed = [ _unit ] call bcombat_fnc_speed;
			_ang = [_unit, _shooter] call bcombat_fnc_relativeDirTo;
			_hdiff = ((getPosASL _shooter) select 2) - ((getPosASL _unit) select 2);
			_dt = time - (_unit getVariable ["bcombat_suppression_time", 1 ]);
			_move_to_cover = false;

			_grp setSpeedMode "FULL";
			
			if( _dt > bcombat_incoming_bullet_timeout ) then 
			{

				if( _visible ) then 
				{
					_penalty = bcombat_penalty_bullet;
					
					if( time - (_unit getVariable ["bcombat_suppression_time", -999 ]) > 300 && _unit getVariable ["bcombat_suppression_level", 0] == 0) then
					{
						_penalty  = _penalty + bcombat_penalty_enemy_contact;
					};
					
					/*
					if( behaviour _unit in ["SAFE"] && _unit getVariable ["bcombat_suppression_level", 0] == 0) then
					{
						_penalty  = _penalty + bcombat_penalty_safe_mode;
					};*/

					_penalty = _penalty + ( ( _ang / 180) * bcombat_penalty_flanking );
				
					if( [_unit, _shooter] call bcombat_fnc_knprec > 10 ) then { // isNull ( _unit findNearestEnemy _unit ) || 
						_penalty = _penalty + bcombat_penalty_enemy_unknown; 
					};
					
					if( bcombat_allow_lowerground_penalty ) then 
					{
						//player globalchat format["%1 %2 [%3 %4] [%5]", _unit, 1 + (( _hdiff / _dist ) min 1), _hdiff, _dist, _penalty ];
						_penalty = _penalty * ( 1 + ((( _hdiff / _dist ) min 1 ) max -0.5) );
					};
				};

				_penalty  = (round( _penalty * ( 1 - ( _unit getVariable "bcombat_skill") ) ) min 100) max 1;
				// player globalchat format["---> %1 --- %2 --- %3", _penalty, _unit, _unit knowsabout _shooter];		
				
				if( (_dist > bcombat_danger_distance ) 
					&& _unit getVariable ["bcombat_suppression_level", 0] < 10 ) then
				{
					if( _speed > 3.5 ) then
					{
						[ _unit, 1, _penalty, time, time + 10 + random 10, time + 15 + random 15, _shooter ] call bcombat_fnc_fsm_trigger;
					}
					else
					{
						[ _unit, 1, _penalty, time + 5, time + 10 + random 10, time + 15 + random 15, _shooter ] call bcombat_fnc_fsm_trigger;
					};
				}
				else
				{
					[ _unit, 1, _penalty, time + 5 + random 5, time + 10 + random 5, time + 15 + random 15, _shooter ] call bcombat_fnc_fsm_trigger;
				};
				
				_unit setVariable ["bcombat_suppression_time", time ];
				
				if( !(isPlayer _unit ) ) then 
				{
					if( _dt > 1 && { !(isPlayer (leader _unit)) }  ) then
					{
						// SAFE mode penalty
						if( behaviour (leader _unit) in ["SAFE", "CARELESS"] ) then 
						{
							{
								_x setBehaviour "COMBAT";
								[ _x, 15, bcombat_penalty_safe_mode, time, time + 15 + random 15, time + 30 + random 30, _shooter ] call bcombat_fnc_fsm_trigger;
								//player globalchat format["%1: penalty for SAFE mode applied", _x];
							} foreach units (group _unit);  
						};
						
						// Trigger surrender
						if( 
							bcombat_allow_surrender
							&& { !(captive _unit) }
							&& { random 200 > _dist }
						&& { _unit getVariable ["bcombat_suppression_level", 0] >= 75 }
						&& { (leader _unit) getVariable ["bcombat_suppression_level", 0] >= 50 }
						&& { !([player] in units (group _unit)) }
							&& { random 1 > (_unit skill "general" ) }
							//&& { fleeing _unit }
							//&& { _dist < 100 } //&& _dist > 0
							 
							&& { (getPosATL _shooter) select 2 < 1 }
							// && { [_shooter, _unit] call bcombat_fnc_relativeDirTo < 60 }
							&& { [_shooter, _unit] call bcombat_fnc_is_visible }
							//&& random 1 > (_unit skill "general") 
							) then {
							_nil = [ _unit ] spawn bcombat_surrender;
						};
		
						if( !(fleeing _unit) ) then
						{
							// MOVE TO COVER
							_nenemy = _unit findnearestEnemy _unit;
				
							// Unknown enemy, go to cover
							if(  ( isNull(_nenemy) || [_unit, _nenemy] call bcombat_fnc_knprec > 5 )
								&& { !(isHidden _unit) } 
								&& { _dist > 30 } ) then // && !([_unit] call bcombat_fnc_has_task)
							{ 	
								_move_to_cover = true;
							}
							else
							{
								if( 
									bcombat_allow_cover
									&& { !_move_to_cover}
									&& { _dist > 30 }
									&& { _visible }
									&& { !(isHidden _unit) } 
									&& { _unit getVariable ["bcombat_suppression_level", 0] > 5 || count(_unit nearroads 6) > 0 || random 50 < (_unit getVariable ["bcombat_suppression_level", 0]) }
									&& { ( _speed < 3 ) }
									&& { (_unit == leader _unit || bcombat_cover_mode == 1) }
									//&& { !([_unit] call bcombat_fnc_has_task) }
									// && { [_unit, _shooter] call bcombat_fnc_is_visible_head }
									//&& ( count(_unit nearroads 10) > 0 ) 
								) then { 
									_move_to_cover = true;
								};
							};
						
							// find cover object
							_cover = nil;
							if( _move_to_cover ) then
							{
								_cover = [_unit, _shooter, bcombat_cover_radius] call bcombat_fnc_find_cover_pos;
								
								//player globalchat format["#1 ---> %1 MOVE TO COVER %2", _unit, _cover];
							};
							
							if( !(isNil "_cover") ) then
							{
							//hintc format["%1", _cover];
								 //player globalchat format["#2 ---> %1 MOVE TO COVER (distance = %2 [%3] - kn = %4)", _unit, _unit distance _shooter, _unit distance (_cover select 0), _shooter knowsabout _unit];
								[_unit, "bcombat_fnc_task_move_to_cover", 100, [_cover]] call bcombat_fnc_task_set; 
							}
							else
							{
								// Smoke grenade
								if(
									bcombat_allow_smoke_grenades 
									&& { !( [_unit] call bcombat_fnc_has_task ) }
									&& { random 1 <= (_unit skill "general" ) ^ 0.5}
									//&& { _unit getVariable ["bcombat_suppression_level", 0] > 10 }
									&& { random 100 > (_unit getVariable ["bcombat_suppression_level", 0]) }
									&& { _dist > 50 }
									&& { "SmokeShell" in (magazines _unit) }
									&& { _unit == leader _unit || _unit == formLeader _unit ||  [ _unit ] call bcombat_fnc_speed < 3}
									&& { [_unit, _shooter] call bcombat_fnc_knprec < 25 }
									&& { [ _shooter ] call bcombat_fnc_speed < 3 }
								) then {
									//player globalchat format["%1 THROW SMOKE", _unit];
									[_unit, _shooter] call bcombat_fnc_handle_smoke_grenade;
								};
							};
							
						}; // end if fleeing
					};

					if( !(fleeing _unit) ) then
					{
						[_unit] call bcombat_fnc_allow_fire;
						[_unit, _shooter] call bcombat_fnc_reveal;
					};

					if(	bcombat_allow_fire_back && { !(fleeing _unit) } && { !(_move_to_cover) } ) then
					{
						// RETURN FIRE
						if ( 
							( random 1 <= (_unit skill "general" ) || isPlayer ( leader _unit ) )
							&&  { _visible }
							&& {  _speed < 3 || _dist < 50 }
							&&  { _dist < [ _unit ] call bcombat_weapon_max_range } 
							&&  { canFire _unit }  
							&& { _unit ammo (currentWeapon _unit) > 0  }
							&&  { !(combatMode _unit in ["BLUE"]) }  
							&&  { [_unit, _shooter] call bcombat_fnc_knprec < 2 }  
							&&  { ( isHidden _unit || _dist < 250 || [currentWeapon _unit] call bcombat_fnc_is_mgun) }  
							
							&&  { [_unit, _shooter] call bcombat_fnc_relativeDirTo < 75 || _speed < 1 }
							&&  { _dist < 30 || random 100 > _unit getVariable ["bcombat_suppression_level", 0]  } 
				
						) then { 
						
							// player globalchat format["%1 RETURN FIRE", _unit];
							[_unit, "bcombat_fnc_task_fire", 10, [_shooter, 2] ] call bcombat_fnc_task_set;
		
							if( bcombat_debug_enable) then {
								_msg = format["bcombat_fnc_bullet_incoming() - RETURN FIRE: unit=%1, enemy=%2, distance=%3, angle=%4", _unit, _shooter, _unit distance _shooter, [_unit, _shooter] call bcombat_fnc_relativeDirTo ];
								[ _msg, 8 ] call bcombat_fnc_debug;
							}
						}
						else
						{
							// SUPPRESSIVE FIRE 
							if( bcombat_allow_suppressive_fire 
								&& { !([_unit] call bcombat_fnc_has_task) }
								&& { [_unit, _shooter] call bcombat_fnc_relativeDirTo < 60 || _speed < 1 } 
								&& { ( random 1 <= (_unit skill "general" ) || isPlayer ( leader _unit ) ) }
								&& { [_unit, _shooter] call bcombat_fnc_knprec < 5 }  
								&& { canFire _unit } 
								&& { ( _unit getVariable ["bcombat_suppression_level", 0] <= 50 ) } 
								&& { _dist >  (bcombat_suppressive_fire_distance select 0) }
								&& { _dist <  (bcombat_suppressive_fire_distance select 1) }
								&& { random 1 <= (_unit skill "general" ) } 
								// && { _visible }
							)  then {
						
								if( [currentWeapon _unit] call bcombat_fnc_is_mgun ) then {
									[_unit, _shooter, (bcombat_suppressive_fire_duration select 1)] call bcombat_fnc_suppress; 
								}
								else
								{
									[_unit, _shooter, (bcombat_suppressive_fire_duration select 0)] call bcombat_fnc_suppress; 
								};
							};
						};
					};
				};
			
				if(	bcombat_allow_fire_back_group ) then
				{
					// Cover other units
					{
						if(!isPlayer _x 
							&& { _x != _unit } 
							&& { _x != _shooter }

							&& { !(captive _x) }
							&& { !(fleeing _x) }
							&& { canFire _x  }
							&& { !(combatMode _x in ["BLUE"]) }
							&& { ( random 1 <= (_x skill "general" ) || isPlayer ( leader _x ) ) }
							&& { [_x] call bcombat_fnc_is_active } 
							&& { ( isHidden _x || _x distance _shooter < bcombat_fire_back_group_max_enemy_distance ) } 
							&& { _unit distance _x < bcombat_fire_back_group_max_friend_distance }
							&& { _x distance _shooter < [_x] call bcombat_weapon_max_range }
							&& { ( _x getVariable ["bcombat_suppression_level", 0] <= 50 ) }
							&& { time - (_x getVariable ["bcombat_suppression_time", 1 ]) > bcombat_incoming_bullet_timeout }
							&& { [ _x ] call bcombat_fnc_speed < 3.5 }
							&& { [_unit, _shooter] call bcombat_fnc_knprec < 2 }
							&& { !([_x] call bcombat_fnc_has_task) }
							//&& { random 1 <= ((leader _x) skill "general" ) } 
							&& { random 100 > _x getVariable ["bcombat_suppression_level", 0] }
							// && { ( !(isPlayer (leader _x)) || ( currentCommand _x != "MOVE" || speed _x < 1) ) }
							&& { [_x, _shooter] call bcombat_fnc_relativeDirTo < 60 || speed _x < 1}
							&& { [_x, _shooter] call bcombat_fnc_is_visible }
							&& { _x ammo (currentWeapon _x) > 0  }
						) then {

							[_x, "bcombat_fnc_task_fire", 2 ,[_shooter, 1] ] call bcombat_fnc_task_set;
							//player globalchat format["%1 support %2", _x, _unit];
							if( bcombat_debug_enable ) then {
								_msg = format["bcombat_fnc_bullet_incoming() - HELP: helper unit=%1, suppressed unit=%2, enemy=%3, distance=%4, angle=%5", _x, _unit, _shooter, _x distance _shooter, [_x, _shooter] call bcombat_fnc_relativeDirTo ];
								[ _msg, 8 ] call bcombat_fnc_debug;
							};
						};
					} foreach units (group _unit);
				};
			};
			
			if( bcombat_debug_enable ) then {
				_msg = format["bcombat_fnc_bullet_incoming() - Unit=%1, bullet=%2, shooter=%3, proximity=%4, distance=%5, penalty=%6, skill=%7", _unit, _bullet, _shooter, _proximity, _unit distance _pos, _penalty, _unit getVariable "bcombat_skill" ];
				[ _msg, 9 ] call bcombat_fnc_debug;
			};
		};
	};
};

// Called ONLY from within danger.fsm
bcombat_fnc_suppression = 
{
	private [ "_unit", "_level", "_leader", "_grp", "_enemy", "_dist", "_k", "_msg"];

	_unit = _this select 0;
	_level = _this select 1;
	_leader = leader _unit;
	_grp = group _unit;
	_enemy = _unit findNearestEnemy _unit;
	_dist = _unit distance _enemy;
	
	if( [_unit] call bcombat_fnc_is_active ) then {
	
		_k = (( 100 - _level ) / 100) ^ 1.33; 

		_unit setSkill ["aimingAccuracy", ( (( _unit getVariable "bcombat_skill_ac" ) - 0.0 ) * _k ) max 0.1 ];
		_unit setSkill ["aimingShake", ( (( _unit getVariable "bcombat_skill_sh" ) - 0.0 ) * _k  ) max 0.1 ];
		_unit setSkill ["spotDistance", ( (( _unit getVariable "bcombat_skill_sd" ) - 0.0 ) * _k  ) max 0.1 ];
		
		_courage = (_unit getVariable ["bcombat_skill_cr", 0] ) * (_k ^ .5) * ( 1 - damage _unit / 2) ;
		_lcourage = (leader _unit) skill "courage";
		
		if(	!(fleeing _unit) 
			&& { _dist < 100 }
			&& { _unit ammo (primaryWeapon _unit) == 0 }
			&& { !(someammo _unit) }
		) then {
			_courage = .05;
		};
		
		_courage = _courage max 0.05;
		_unit setSkill ["courage", 	_courage ];
		
		// fleeing
		if( fleeing _unit) then
		{
			_unit forcespeed 20;
			_unit doWatch objNull;
		};
	
		if( bcombat_debug_enable ) then { 

			_msg = format["bcombat_fnc_suppression() - Unit=%1, suppression=%2, aimingAccuracy=[%3/%4], fleeing=%5", _unit, _level, ( _unit Skill "aimingAccuracy"), _unit getVariable "bcombat_skill_ac", fleeing _unit   ];
			[ _msg, 9 ] call bcombat_fnc_debug;
		};

	};
};

bcombat_surrender = 
{
	private ["_unit", "_h"];
	
	_unit = _this select 0;

	if( [_unit] call bcombat_fnc_is_active
		&& { !(isPlayer _unit) }
		// && { fleeing _unit }
	) then {

		_unit forcespeed 0;
		//_unit allowfleeing 1;
		_unit setcaptive true;
		_unit playmove "AmovPercMstpSsurWnonDnon"; 
		_unit disableAI "ANIM";

		[ _unit ] spawn {
			_unit = _this select 0;
			
			sleep 2;
			
			_h = "groundweaponholder" createVehicle getpos _unit;

			{ _h addweaponcargo [_x, 1]; } foreach weapons _unit;
			{ _h addmagazinecargo [_x,1]; } foreach magazines _unit;
			
			_h  setPos [(getPosATL _unit) select 0,(getPosATL _unit) select 1,0.00];

			/*
			_h = "weaponholder" createvehicle getposATL _unit;
		
			{
				_h addweaponcargo [_x, 1];
			} foreach weapons _unit;
			
			{
				_h addmagazinecargo [_x,1];
			} foreach magazines _unit;
			*/
			
			removeallweapons _unit;
		};
		/*
		while { [_unit] call bcombat_fnc_is_active 
			&& ( !(isNull (_unit findnearestenemy _unit)) 
			&& _unit distance (_unit findnearestenemy _unit) < 100  ) } do {
			//player globalchat format ["-> %1 %2 - %3", _unit findnearestenemy _unit, _unit distance (_unit findnearestenemy _unit)];
			sleep 1 + random 3;
		};

		if( [_unit] call bcombat_fnc_is_active ) then 
		{
			//_unit allowfleeing 0;
			_unit enableAI "ANIM";
			//sleep .1;
			_unit setcaptive false;
			_unit enableattack true;
			_unit setUnitpos "Auto";
			_unit forcespeed -1;
			_unit dofollow _unit;
			//_unit enableattack true;
		}
		*/
	};
};

bcombat_fnc_suppress = 
{
	private ["_unit","_enemy", "_duration"];
	
	_unit = _this select 0;
	_enemy = _this select 1;
	_duration = _this select 2;
	
	if( bcombat_debug_enable ) then {
		_msg = format["bcombat_fnc_suppress() - unit=%1, enemy=%2, duration=%3", _unit, _enemy, _duration ];
		[ _msg, 40 ] call bcombat_fnc_debug;
	};
	
	if( [_unit] call bcombat_fnc_is_active
		&& { !(fleeing _unit) }
		&& { !(captive _unit) } 
		&& { !(isPlayer _unit ) } 
		&& { canFire _unit } 
		&& { combatMode (group _unit) in ["RED", "YELLOW"] }  
	) then {
		_unit suppressFor _duration;
	};
};

bcombat_fnc_unit_handle_fleeing = {

	private ["_unit", "_ori_grp"];

	_unit = _this select 0;
	_ori_grp  = grpNull;
	 _unit allowfleeing 0;
	
	if( [_unit] call bcombat_fnc_is_active 
		&& { _unit getVariable ["bcombat_suppression_level", 0] > 75 }
		&& { (leader _unit) getVariable ["bcombat_suppression_level", 0] > 50 }
		&& { !([player] in units (group _unit)) }
		// && { random 100 > 65 }
		 && { _unit != leader _unit || count (units (group _unit)) == 1}
	) then {


		if( [_unit] call bcombat_fnc_has_task ) then
		{
			[_unit] call bcombat_fnc_task_clear;
		};
		
		_ori_grp = group _unit;
		
		if( count (units (group _unit)) > 1) then {
			[_unit] joinSilent grpNull;
			_unit dofollow _unit;
		};
		
		sleep .1;
		
		_unit allowfleeing 1;
		_unit forcespeed 20;
		_unit doWatch objNull;
		_unit setCombatMode "GREEN";
		_unit setUnitpos "Auto";

		sleep 30;
		
		while { [_unit] call bcombat_fnc_is_alive && (_unit skill "courage") < 0.25 } do 
		{
			sleep (5 + random 5);
		};
			
		if( [_unit] call bcombat_fnc_is_alive ) then
		{
			if( !(isNull _ori_grp) && count (units _ori_grp) > 0 && !(fleeing (leader _ori_grp))) then
			{
				[_unit] joinSilent _ori_grp;
				_unit dofollow (leader _ori_grp);
			};
		};
	};
};