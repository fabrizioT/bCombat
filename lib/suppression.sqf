bcombat_fnc_bullet_incoming = 
{
	private [ "_unit", "_shooter", "_bullet",  "_bpos", "_pos", "_time", "_proximity", "_grp", "_visible", "_dist", "_penalty", "_speed", "_ang", "_x" ];
	
	_unit = _this select 0;		// unit being under fire
	_shooter = _this select 1;	// shooter
	
	if( [_unit] call bcombat_fnc_is_active ) then
	{
		if( 
			!(fleeing _unit) 
			&& { _unit != _shooter }
			&& { !(captive _unit) }
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
		
			if( time - (_unit getVariable ["bcombat_suppression_time", 0 ]) > bcombat_incoming_bullet_timeout ) then 
			{
				if( !(isPlayer _unit ) ) then 
				{
					[_unit] call bcombat_fnc_allow_fire;
					[_unit, _shooter] call bcombat_fnc_reveal;
				
					_penalty = bcombat_penalty_bullet;
					
					if( _visible ) then {
						_penalty = _penalty + ( ( _ang / 180) * bcombat_penalty_flanking );
						
						if( [_unit, _shooter] call bcombat_fnc_knprec > 10 ) then { // isNull ( _unit findNearestEnemy _unit ) || 
							_penalty = _penalty + bcombat_penalty_enemy_unknown; 
						};
					};
					
					// Smoke grenade
					if(
						bcombat_allow_smoke_grenades 
						&& { random 1 <= (_unit skill "general" ) ^ 0.5}
						//&& { _unit getVariable ["bcombat_suppression_level", 0] > 10 }
						&& { random 100 > (_unit getVariable ["bcombat_suppression_level", 0]) }
						&& { _dist > 50 }
						&& { "SmokeShell" in (magazines _unit) }
						&& { _unit == leader _unit || _unit == formLeader _unit ||  [ _unit ] call bcombat_fnc_speed < 3}
						&& { !( [_unit] call bcombat_fnc_has_task ) }
						&& { [_unit, _shooter] call bcombat_fnc_knprec < 25 }
						&& { [ _shooter ] call bcombat_fnc_speed < 3 }
					) then {
						//hintc format["has=%1 dist=%2 prec=%3 spd=%4 tsk=%5", "SmokeShell" in (magazines _unit), _dist, [_unit, _shooter] call bcombat_fnc_knprec < 25, [ _shooter ] call bcombat_fnc_speed, [_unit] call bcombat_fnc_has_task];
					
						[_unit, _shooter] call bcombat_fnc_handle_smoke_grenade;
					}
					else
					{
						// move to cover
						if( 
							bcombat_allow_cover
							&& { _dist > 50 }
							&& { _visible }
							&& { _unit getVariable ["bcombat_suppression_level", 0] > 10 }
							&& { !(isPlayer (leader _unit)) }
							&& { ( _speed < 3 || count(_unit nearroads 6) > 0 ) }
							&& { (_unit == leader _unit || bcombat_cover_mode == 1) }
							&& { !([_unit] call bcombat_fnc_has_task) }
							&& { [_unit, _shooter] call bcombat_fnc_is_visible_head }
							//&& ( count(_unit nearroads 10) > 0 ) 
						) then { //&& [_unit] call bcombat_fnc_speed == 0 // !(isHidden _unit) ||
						
							[_unit, "bcombat_fnc_task_move_to_cover", 100, [bcombat_cover_radius, objNull]] call bcombat_fnc_task_set;  
						};
						
					};
					
					_penalty  = (round( _penalty * ( 1 - ( _unit getVariable "bcombat_skill" ) ) ) min 100) max 1;
					
					if( (_dist > 250 || _speed > 3.5) 
						&& _unit getVariable ["bcombat_suppression_level", 0] < 10 ) then
					{
						[ _unit, 1, _penalty, 0, time + 10 + random 10, time + 15 + random 15, _shooter ] call bcombat_fnc_fsm_trigger;
					}
					else
					{
						[ _unit, 1, _penalty, time + 5 + random 5, time + 10 + random 5, time + 15 + random 15, _shooter ] call bcombat_fnc_fsm_trigger;
					};
					
					if(	bcombat_allow_fire_back ) then
					{
						// Return fire
						if ( 
							random 1 <= (_unit skill "general" ) 
							&&  { _dist < [_unit ] call bcombat_weapon_max_range } 
							&&  { canFire _unit }  
							&&  { !(combatMode _unit in ["BLUE"]) }  
							&&  { [_unit, _shooter] call bcombat_fnc_knprec < 2 }  
							&&  { ( isHidden _unit || _dist < 150 || _speed < 3 || [currentWeapon _unit] call bcombat_fnc_is_mgun) }  
							&&  { _visible }
							&& 
							{ ( 
								( random 100 > _unit getVariable ["bcombat_suppression_level", 0] )  // && ( _unit getVariable ["bcombat_suppression_level", 0] <= 65 )
								|| _dist < 25
								|| [_unit, _shooter] call bcombat_fnc_relativeDirTo < 75
							) }
							
						) then { // RETURN FIRE 

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
								&& { [_unit, _shooter] call bcombat_fnc_relativeDirTo < 45 } 
								&& { random 1 <= (_unit skill "general" ) }
								&& { canFire _unit } 
								&& { ( _unit getVariable ["bcombat_suppression_level", 0] <= 65 ) } 
								&& { _dist >  (bcombat_suppressive_fire_distance select 0) }
								&& { _dist <  (bcombat_suppressive_fire_distance select 1) }
								&& { random 1 <= (_unit skill "general" ) } 
								&& { _visible }
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
							&& { vehicle _x  == _x }
							&& { !(captive _x) }
							&& { canFire _x  }
							&& { !(combatMode _x in ["BLUE"]) }
							&& { random 1 <= (_x skill "general" ) }
							&& { [_x] call bcombat_fnc_is_active } 
							&& { ( isHidden _x || _x distance _shooter < bcombat_fire_back_group_max_enemy_distance ) } 
							&& { _unit distance _x < bcombat_fire_back_group_max_friend_distance }
							&& { _x distance _shooter < [_x] call bcombat_weapon_max_range }
							&& { ( _x getVariable ["bcombat_suppression_level", 0] <= 30 ) }
							&& { time - (_x getVariable ["bcombat_suppression_time", 1 ]) > .2 }
							&& { ([0,0] distance (velocity _x)) < 3 }
							&& { [_unit, _shooter] call bcombat_fnc_knprec < 2 }
							&& { !([_x] call bcombat_fnc_has_task) }
							//&& { random 1 <= ((leader _x) skill "general" ) } 
							&& { random 100 > _x getVariable ["bcombat_suppression_level", 0] }
							&& { ( !(isPlayer (leader _x)) || ( currentCommand _x != "MOVE" || speed _x < 1) ) }
							&& { [_x, _shooter] call bcombat_fnc_relativeDirTo < 60 }
							&& { [_x, _shooter] call bcombat_fnc_is_visible }
						) then {

							[_x, "bcombat_fnc_task_fire", 2 ,[_shooter, 1] ] call bcombat_fnc_task_set;
						
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
			//_unit doTarget objNull;
			//_unit setcombatmode "GREEN";
		};
	
		if( bcombat_debug_enable ) then { 

			_msg = format["bcombat_fnc_suppression() - Unit=%1, suppression=%2, aimingAccuracy=[%3/%4], fleeing=%5", _unit, _level, ( _unit Skill "aimingAccuracy"), _unit getVariable "bcombat_skill_ac", fleeing _unit   ];
			[ _msg, 9 ] call bcombat_fnc_debug;
		};
		
		// Trigger surrender
		if( 
			bcombat_allow_surrender
			&& { !(captive _unit) }
			&& { fleeing _unit }
			&& { _dist < 150 } //&& _dist > 0
			&& { random 150 > _dist }
			&& { [_enemy, _unit] call bcombat_fnc_relativeDirTo < 60 }
			&& { [_enemy, _unit] call bcombat_fnc_is_visible }
			//&& random 1 > (_unit skill "general") 
			) then {
			_nil = [ _unit ] spawn bcombat_surrender;
		};
	};
};

bcombat_surrender = 
{
	private ["_unit", "_h"];
	
	_unit = _this select 0;

	if( [_unit] call bcombat_fnc_is_active
		&& { !(isPlayer _unit) }
		&& { fleeing _unit }
	) then {

		_unit forcespeed 0;
		_unit setcaptive true;
		_unit playmove "AmovPercMstpSsurWnonDnon"; 
		_unit disableAI "ANIM";

		[ _unit ] spawn {
			_unit = _this select 0;
			
			sleep 2;
			
			_h = "groundweaponholder" createVehicle getpos _unit;

			{
				_h addweaponcargo [_x, 1];
			} foreach weapons _unit;

			{
				_h addmagazinecargo [_x,1];
			} foreach magazines _unit;
			
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
		&& { _unit != leader _unit }
		//&& random 1 < .7
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
		_unit setUnitpos "Auto";
		
		//_unit disablaAI "TARGET";
		//_unit disablaAI "FSM";
		//_unit setcombatmode "GREEN";
	
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