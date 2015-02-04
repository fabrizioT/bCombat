// ---------------------------------------
// FUNCTIONS
// ---------------------------------------

/*
bcombat_fnc_array_invert = {

	private [ "_arr", "_n", "_ret" ];
	
	_arr = _this select 0;
	_ret = [];
	
	for "_n" from  (count(_arr) - 1) to 0 step -1 do {
		_ret set[ count _ret, _arr select _n];
	};
	
	_ret
};
*/

/*
bcombat_fnc_is_curator = {

	private ["_ret", "_x", "_curator"];
	
	_ret = false;
	
	Scopename "isCuratorMain";
	
	{
		_curator = getAssignedCuratorUnit _x;
		
	//	diag_log format[">>> %1 - %2 - %3", _curator , getAssignedCuratorUnit _x, (call BIS_fnc_listCuratorPlayers)];

		if( _curator  == _this ) then 
		{
			_ret = true;
			breakTo "isCuratorMain";
		};
		
	} foreach allCurators;
	
	_ret
};
*/

// Benchmarking: 0.13s x 1000
bcombat_fnc_is_active = {	// bCombat is on, unit is man, alive, activated and on foot

	private [ "_unit", "_ret" ];
	
	_unit = _this select 0;
	_ret = false;
	
	// diag_log format["%1 - unit=%2 isplayer=%3 - %4 - %5", time, _unit, isplayer _unit, (_unit call BIS_fnc_isCurator), _unit call bcombat_fnc_is_curator ];
	
	if( bcombat_enable 
		&& !(isNil "bcombat_init_done")
		// && 	{ _unit getVariable ["bcombat_init_done", false ] }
		&& { alive _unit }
		&& { local _unit }
		&& { simulationEnabled _unit }
		&& { (vehicle _unit) isKindOf "CAManBase" }
		&& { str (side _unit) != "CIV" }
		&& { vehicle _unit == _unit }
	) then
	{
		if( count bcombat_allowed_sides > 0
			|| count bcombat_allowed_groups > 0
			|| count bcombat_allowed_units > 0 ) then
		{
			if(  side _unit in bcombat_allowed_sides 
			 || group _unit in bcombat_allowed_groups 
			 || _unit in bcombat_allowed_units) then
			{
				_ret = true;
			};
		}
		else
		{
			_ret = true;
		};
	};

	_ret
};

// Benchmarking: <0.1s x 1000
bcombat_fnc_is_stopped =
{
	private [ "_unit", "_handle", "_ret" ];
	
	_unit = _this select 0;
	_handle = _unit getVariable ["bcombat_stop_handle", nil];
	_ret = false;
	
	if( !(isNil "_handle") ) then { _ret = true; };
	
	_ret
};

// Benchmarking: <0.1s x 1000
bcombat_fnc_knprec = {

	private ["_enemy"];
	
	_enemy = _this select 1;

	((_this select 0) getHideFrom _enemy) distance _enemy
};

// Benchmarking: 0.5s - 1s x 1000
bcombat_fnc_is_visible = {

	private [ "_o1", "_o2", "_ret" ];
	
	_o1 = _this select 0;
	_o2 = _this select 1;
	_ret = true;
	
	if( terrainintersectasl [eyepos _o1, eyepos _o2] ) then { 
		_ret = false; 
	} 
	else 
	{ 
		if( lineintersects [eyepos _o1, eyepos _o2, _o1, _o2] ) then 
		{ 
			if( _o1 distance _o2 < 150 ) then 
			{ 
				if(lineintersects [aimpos _o1, aimpos _o2, _o1, _o2]) then
				{
					_ret = false; 
				}
			}
			else
			{
				_ret = false; 
			};
		};
	};

	_ret
};

// Benchmarking: 
bcombat_fnc_is_visible_head = {

	private [ "_o1", "_o2", "_dist", "_ret" ];
	
	_o1 = _this select 0;
	_o2 = _this select 1;
	_dist = _o1 distance _o2;
	_ret = true;
	
	if( terrainintersectasl [eyepos _o1, aimpos _o2] ) then 
	{ 
		_ret = false; 
	} 
	else 
	{ 
		if(lineintersects [eyepos _o1, aimpos _o2, _o1, _o2]) then
		{
			_ret = false; 
		};
	};

	_ret
};

// Benchmarking: 0.38s 
bcombat_fnc_is_visible_simple = {

	private [ "_o1", "_o2", "_dist", "_ret" ];
	
	_o1 = _this select 0;
	_o2 = _this select 1;
	_dist = _o1 distance _o2;
	_ret = true;
	
	if( terrainintersectasl [aimpos _o1, aimpos _o2] ) then { 
		_ret = false; 
	} 
	else 
	{ 
		if(lineintersects [aimpos _o1, aimpos _o2, _o1, _o2]) then
		{
			_ret = false; 
		};
	};

	_ret
};

// Benchmarking: 0.12s x 1000
bcombat_fnc_stance_get = {

	private ["_ret"];
	
	_ret = "Up";
	
	switch ( stance (_this select 0) ) do
	{
		case "CROUCH": { _ret = "Middle"; };
		case "PRONE": { _ret = "Down"; };
	};

	_ret
};

// Benchmarking: <0.1s x 1000
bcombat_fnc_speed = {
	[0,0] distance (velocity (_this select 0))
};

// Benchmarking: 0.17s x 1000
bcombat_weapon_max_range =
{
	private ["_unit", "_weapon", "_max"];
	
	_unit = _this select 0;
	_weapon = currentWeapon _unit;//format["%1", currentWeapon _unit];
	
	if( _weapon == "" ) then {
		_weapon = format["%1", primaryWeapon _unit];
	};

	_max = getNumber(configFile >> "cfgWeapons" >> _weapon >> "Single" >> "maxRange" );
	
	if(_max < 50) then { 
		_max = getNumber(configFile >> "cfgWeapons" >> _weapon >> "far_optic2" >> "maxRange" ); 
	};
	
	if(_max < 50) then { 
		_max = getNumber(configFile >> "cfgWeapons" >> _weapon >> "far_optic1" >> "maxRange" ); 
	};
	
	if(_max < 50) then { 
		//player globalchat format["%1 %2", _weapon, getNumber(configFile >> "cfgWeapons" >> _weapon  )];
		if( _weapon == primaryWeapon _unit) then { _max = 500; };
	};

	//diag_log format["error: %1  [%2] %3 %4 %5 - %6", _unit,  currentweapon _unit, side _unit, behaviour _unit,  primaryweapon _unit, getNumber(configFile >> "cfgWeapons" >> _weapon >> "Single" >> "maxRange" ) ];
	(_max  * 1.0 * (skill _unit ^ 0.15)) max 50
};

// Benchmarking: see bcombat_fnc_relativeDirTo
bcombat_fnc_relativeDirTo_signed = { // (-180 to 180)

	private ["_posA","_posB","_dir"];

	_posA = getPosATL (_this select 0);
	_posB = getPosATL (_this select 1);

	_dir = (((_posB select 0) - (_posA select 0)) atan2 ((_posB select 1) - (_posA select 1)) - getdir (_this select 0))  % 360;

	if (_dir < -180) then { _dir = _dir + 360 };
	if (_dir > 180) then {_dir = _dir - 360};
	
	_dir
};

// Benchmarking: 0.24s x 1000
bcombat_fnc_relativeDirTo = { // (0 to 180)
	abs (_this call bcombat_fnc_relativeDirTo_signed)
};

// Benchmarking: 0.1s x 1000
bcombat_fnc_is_enemy = 
{
	private ["_ret"];
	
	_ret = false;
	if( (side (_this select 0)) getFriend (side (_this select 1)) < 0.6 ) then
	{
		_ret = true;
	};
	
	_ret;
};

bcombat_fnc_is_friendly = 
{
	private ["_ret"];
	
	_ret = false;
	if( (side (_this select 0)) getFriend (side (_this select 1)) >= 0.6 ) then
	{
		_ret = true;
	};
	
	_ret;
};

// Benchmarking: <0.1s x 1000
bcombat_fnc_is_alive = 
{
	private ["_unit", "_ret"];
	
	_unit = _this select 0;
	_ret = true;
	
	if( isNull _unit || !( alive _unit ) ) then { _ret = false; };
	
	_ret
};

// Benchmarking: 0.16s x 1000
bcombat_fnc_in_formation = 
{
	private [ "_unit", "_expos", "_cmd", "_ret" ];
	
	_unit = _this select 0;
	_expos = expecteddestination _unit;
	_ret = false;
	_cmd = currentCommand _unit;
	
	if( count _expos  > 0) then
	{
		if( _unit != leader _unit 
			&& { _unit != formLeader _unit }
			&& { !(isPlayer _unit) } 
			&& { [_unit] call bcombat_fnc_is_active }
			&& { 
				(_cmd in  ['', 'MOVE'] && (_expos select 1) in ["DoNotPlanFormation",  "DoNotPlan"]) 
				|| (_cmd in ['', 'MOVE'] && (_expos select 1) in ["FORMATION PLANNED"]) // danger mode
			} 
			
		) then {
			_ret = true;
		};
	};
	
	_ret
};

// Benchmarking: 0.17s x 1000
bcombat_fnc_weapon_is_silenced = {

	private ["_unit", "_weapon", "_items", "_ret"];

	_unit  = _this select 0; 
	_weapon  = _this select 1; 
	_ret = false;

	if (_weapon == primaryWeapon _unit) then
	{
		_items = primaryWeaponItems _unit;
		
		if ("muzzle_snds_H" in _items || 
			"muzzle_snds_L" in _items || 
			"muzzle_snds_acp" in _items
		) then { _ret = true; };
	}
	else
	{
		if (_weapon == handgunWeapon _unit) then
		{
			_items = handgunItems _unit;
			
			if ("muzzle_snds_L" in _items || 
				"muzzle_snds_H" in _items || 
				"muzzle_snds_acp" in _items
			) then { _ret = true; };
		};
	};
	
	_ret
};

bcombat_fnc_building_position =
{
	private ["_building", "_unit", "_enemy", "_dist", "_ret", "_i"];
	
	_building	= _this select 0;
	_unit	= _this select 1;
	_enemy	= _this select 2;
	_dist = -1;
	_ret = nil;
	_i = 0;
	
	while { (_building buildingPos _i) select 0 != 0 } do 
	{ 
		_pos = _building buildingPos _i;
		
		if( _dist == -1 || _enemy distance _pos < _dist) then
		{
			_dist = _enemy distance _pos;
			_ret = _pos;
		};
		
		_i = _i + 1;
	};	

	_ret
};

// Benchmarking: 0.9-0.98s x 1000
bcombat_fnc_find_cover_pos = {

	private ["_unit", "_dist", "_grp", "_ret", "_n", "_p", "_pos", "_r1", "_r2", "_blacklist", "_objects"];

	_unit = _this select 0;
	_enemy = _this select 1;
	_dist = _this select 2; 
	_grp = group _unit;
	_ret = nil;
			
	_p = (getPosATL _unit);
	_r1 = _dist select 0;
	_r2 = _dist select 1;
	
	_blacklist = _grp getVariable ["bcombat_cover_blacklist", [] ];
	_objects = [];
	
	if( _r2 > 0) then {
		_objects = nearestObjects [_p, ["HOUSE"], _r2] + (nearestObjects [_p, [], _r1 ]) -  (_unit nearTargets _r1) -  (_p nearObjects _r1 )  -  (_p nearroads _r1) - _blacklist; 
	} else {
		_objects = (nearestObjects [_p, [], _r1 ]) - (nearestObjects [_p, ["HOUSE"], _r1]) - (_unit nearTargets _r1) -  (_p nearObjects _r1 )  -  (_p nearroads _r1) - _blacklist; 
	};
	
	Scopename "bcombat_fnc_find_cover_pos_loop";
	
	if (count _objects > 0) then 
	{
		{
			private ["_bbox", "_dx", "_dy", "_dz", "_min", "_max", "_msg"];
			
			if ( _x isKindOf "HOUSE" && (_x buildingPos 0) select 0 != 0 ) then
			{
				// blacklisting
				private ["_r", "_offset"];
				
				_r = [_x, _unit, _enemy ] call bcombat_fnc_building_position;
				
				if( _blacklist find (str _r) == -1 ) then
				{
					if( _unit distance _r < 5) then	// too near, skip all
					{
						BreakTo "bcombat_fnc_find_cover_pos_loop";
					};
					
					_ret = [_r, _x, 1];

					BreakTo "bcombat_fnc_find_cover_pos_loop";
				};
				// end blacklisting
			}
			else
			{
				_bbox = boundingBoxReal _x;
				
				_dx = ((_bbox select 1) select 0) - ((_bbox select 0) select 0);
				_dy = ((_bbox select 1) select 1) - ((_bbox select 0) select 1);
				_dz = ((_bbox select 1) select 2) - ((_bbox select 0) select 2);
				_min = (_dx min _dy);
				_max = (_dx max _dy);
				
				if(  ((getPosATL _x) select 2) < 0.2 
					&& { _dz > 1.5 }
					&& { _dz < 30 }
					&& { _min >= 0.3 }
					&& { _max > 1 }
					&& { _max / _min < 3.5 }
					// && { count ( nearestObjects [ (getPosATL _x), ["CaManBase"], 5] ) == 0 }
				) then // !(_x isKindOf "CaManBase") &&
				{
					// blacklisting
					private ["_r", "_offset"];
					
					_r = (getPosATL _x);
					
					if( _unit distance _r < 5) then	// too near, skip all
					{
						BreakTo "bcombat_fnc_find_cover_pos_loop";
					};
					
					if( _blacklist find (str _r) == -1 ) then
					{
						_ret = [_r, _x, 2];
						
						BreakTo "bcombat_fnc_find_cover_pos_loop";
					};

					// end blacklisting
				};
			};
			
		} foreach _objects;
	};

	
	if( !isNil "_ret") then { 
	
		if( bcombat_debug_enable ) then {
			_msg = format["bcombat_fnc_find_cover_pos() - FOUND: unit = %1, ret = %2, blacklist = %3", _unit, _ret, _blacklist];
			[ _msg, 30 ] call bcombat_fnc_debug;   
		};

		_ret 
	
	} else { 

		if( bcombat_debug_enable ) then {
			_msg = format["bcombat_fnc_find_cover_pos() - FAILED: unit = %1", _unit];
			[ _msg, 30 ] call bcombat_fnc_debug;   
		};
		
		nil 
	};
};

// Benchmarking: 0.23s x 1000
bcombat_fnc_grenade_throwable = 
{
	private ["_unit", "_enemy", "_safedist",  "_mindist", "_maxdist", "_safedist", "_maxhdiff", "_hdiff", "_distance", "_h", "_p", "_p1", "_p2", "_pm", "_list", "_fn", "_ret"];

	_unit = _this select 0; 
	_enemy = _this select 1; 
	_mindist = (_this select 2) select 0;
	_maxdist = (_this select 2) select 1;
	_safedist = (_this select 2) select 2;
	_maxhdiff = _this select 3;
	
	_hdiff 	=  abs(((getPosATL _unit) select 2) - ((getPosATL _enemy) select 2));
	_distance = _unit distance _enemy;
	_ret = false;
		
	_h = (getPosATL _enemy) select 2;
	
	if( _distance > _mindist 
		&& { _distance < _maxdist }
		&& { _hdiff < _maxhdiff }
		&& { _h < 0.5 } ) then
	{
		_p = getPosASL _unit;
		_p set[2, (eyepos _unit) select 2];

		_p1 = [_p select 0, _p select 1, _p select 2]; 
		
		_p2 = eyepos _enemy;
		_pm = [((_p1 select 0) + (_p2 select 0))/2, ((_p1 select 1) + (_p2 select 1))/2, ((_p1 select 2) + (_p2 select 2))/2 +_distance/2];

		_list = nearestObjects [(getPosATL _enemy), ["CaManBase", "Car"], _safedist] - [_unit];
		_fn  = _unit countFriendly _list;

		if( _fn == 0 ) then 
		{
			if( !(terrainintersectasl [_p1, _pm]) && !(terrainintersectasl [_p2, _pm]) ) then
			{
				if( !(lineintersects [_p1, _pm, _unit, _enemy]) && !(lineintersects [_p2, _pm, _unit, _enemy]) ) then
				{
					_ret = true;
				};
			};
		};
	};

	_ret
};

// Benchmarking: 0.12-0.16s x 1000
bcombat_fnc_is_mgun =
{
	private ["_gun", "_ret", "_d"];

	_gun = _this select 0;
	_ret = false;
	
	_d = getNumber (configFile >> "CfgWeapons" >> format["%1", _gun]  >> "aidispersioncoefx") ;
	
	if(_d > 10) then { _ret = true; };

	_ret
};

bcombat_fnc_random_pos = {
	private ["_pos", "_radius", "_ret"];
	
	_pos = _this select 0;
	_radius = _this select 1;
	
	[ (_pos select 0) - _radius + random ( _radius * 2), (_pos select 1) - _radius + random ( _radius * 2), (_pos select 2)  ]
};

/*
bcombat_fnc_set_firemode = {

	private ["_unit", "_enemy ", "_dist", "_weapon", "_ammo"];
	
	_unit = _this select 0;
	_enemy = _this select 1;
	_dist = _unit distance _enemy;
	_weapon = currentWeapon player;
	_ammo = _unit ammo _weapon;
	
	_unit setAmmo [_weapon, 0];
	_unit forceWeaponFire [_weapon, "Single"];//"FullAuto"
	_unit setAmmo [_weapon, _ammo];
};
*/

// ---------------------------------------
// EVENT HANDLERS
// ---------------------------------------

bcombat_fnc_eh_fired = {

	private ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_bullet", "_bulletspeed", "_msg"];
	
	_unit = _this select 0; 
	_weapon = _this select 1;
	_muzzle = _this select 2;
	//_mode = _this select 3;
	//_ammo = _this select 4;
	//_magazine = _this select 5;
	_bullet = _this select 6;
	_bulletspeed = speed _bullet / 3.6;
	
	if( [_unit] call bcombat_fnc_is_active && { _unit distance player < bcombat_degradation_distance } ) then 
	{
		// throwing distance tweaks
		if( _muzzle in ["HandGrenadeMuzzle", "SmokeShellMuzzle"] ) then
		{
			private ["_p", "_v", "_k", "_vx", "_vy", "_vz"]; 
			
			// Grenade
			if( !(isNil {_unit getVariable ["bcombat_grenade_lock", nil ]}) ) then
			{
				_p = getPosASL _bullet;
				_v = velocity _bullet;
				_k = ( (( _unit getvariable "bcombat_grenade_distance")   ) / 65) ^ 0.5;

				_vx = (_v select 0) * _k * 1.0;
				_vz = (_v select 1) * _k * 1.0;
				_vy = (_vx ^ 2 + _vz ^ 2 ) ^ 0.5;//(_v select 2) * _k * 3;
				
				_bullet setPosASL [_p select 0, _p select 1, (_p select 2) + 0.5]; 
				_bullet setvelocity [_vx, _vz, _vy];
				
				_unit setvariable ["bcombat_grenade_lock", nil];
				_unit setvariable ["bcombat_grenade_distance", nil];
				_unit setvariable ["bcombat_grenade_h", nil];
			
			}
			else
			{
				if( !(isNil {_unit getVariable ["bcombat_smoke_grenade_lock", nil ]})  ) then 
				{
					_p = getPosASL _bullet;
					_v = velocity _bullet;
					_k = ( ((( _unit getvariable "bcombat_smoke_grenade_distance") * 1 ) min 100 )  / 45) ^ 0.5 ;
					
					_vx = (_v select 0) * _k * 0.5;
					_vz = (_v select 1) * _k * 0.5;
					//_vy = (_v select 2) * _k * 1.1;
					_vy = ((_vx ^ 2 + _vz ^ 2 ) ^ 0.5) ;//(_v select 2) * _k * 3;
					
					_bullet setPosASL [_p select 0, _p select 1, (_p select 2) + 0.5]; 
					_bullet setvelocity [_vx, _vz, _vy];

					_unit setvariable ["bcombat_smoke_grenade_distance", nil];
					_unit setvariable ["bcombat_smoke_grenade_lock", nil];
				};
			};
		};
		
		if( bcombat_allow_hearing && { time - (_unit getVariable ["bcombat_fire_time", 0 ]) > 1 } ) then 
		{
			if( typeof _bullet == "GrenadeHand" 
				//&& { isNil { _unit getVariable ["bcombat_smoke_grenade_lock", nil ] } } 
			) then
			{
player setVariable ["bcombat_stats_hear_grenade", (player getVariable ["bcombat_stats_hear_grenade", 0]) + 1];
				[ _unit, _bullet, getPosATL _bullet, bcombat_allow_hearing_grenade_distance ] spawn bcombat_fnc_soundalert_grenade;
			} 
			else 
			{
				if( _bulletspeed  > 360 
					&& { !(currentWeapon _unit in ["Throw", "Put"]) } 
					&& { !([_unit, _weapon] call bcombat_fnc_weapon_is_silenced) }					
				) then {
player setVariable ["bcombat_stats_hear", (player getVariable ["bcombat_stats_hear", 0]) + 1];
					[ _unit, _bullet, getPosATL _bullet, ( _bulletspeed  / bcombat_allow_hearing_coef) ] call bcombat_fnc_soundalert;
				}
			};
		};
		
		//[ _unit, objNull] call bcombat_fnc_danger;
		_unit setVariable ["bcombat_fire_time", time]; 
		
		if( bcombat_debug_enable ) then {
			_msg = format["bcombat_fnc_eh_fired() - unit=%1", _unit ];
			[ _msg, 10 ] call bcombat_fnc_debug;
		};
	}
	else
	{
	};
};

bcombat_fnc_eh_hit = {

	private ["_unit", "_enemy", "_damage", "_isenemy"];
	
	_unit = _this select 0;
	_enemy = _this select 1; 
	_damage = _this select 2;
	_isenemy = [_unit, _enemy ] call bcombat_fnc_is_enemy;
	
	if( _damage > .01 && { _isenemy || isNull _enemy }  && { [_unit] call bcombat_fnc_is_active } ) then 
	{
		//	player globalchat format["%1 hit by %2 (%3)", _unit, _enemy, _damage];
		[ _unit, 11, bcombat_penalty_wounded, time + 5 + random 5, time + 10 + random 5, time + 15 + random 15, _enemy ] call bcombat_fnc_fsm_trigger;
		
		if( _isenemy 
			&& { [_unit, _enemy] call bcombat_fnc_knprec < 2 }
			&& { _unit ammo (currentWeapon _unit) > 0  }
			&& { canfire _unit }
			//&& { [_unit, _shooter] call bcombat_fnc_relativeDirTo < 75 }
			&& { _unit getVariable ["bcombat_suppression_level", 0] < 35 }
		) then {
			[_unit, "bcombat_fnc_task_fire", 11, [_enemy, 2] ] call bcombat_fnc_task_set;
			// player globalchat format["%1 RETURN FIRE ON by %2", _unit, _enemy];
		};
	};
};

bcombat_fnc_eh_handledamage = {

	private ["_unit", "_body_part", "_body_part_damage", "_enemy", "_ammo", "_msg"];
		
	_unit = _this select 0; // Unit the EH is assigned to
	_body_part = _this select 1; // Selection (=body part) that was hit
	_body_part_damage = _this select 2; // Damage to the above selection (sum of dealt and prior damage)
	_enemy = _this select 3; //Source of damage (returns the unit if no source)
	_ammo = _this select 4; // Ammo classname of the projectile that dealt the damage (returns "" if no projectile)

	if( [_unit] call bcombat_fnc_is_active && { !(isPlayer _unit ) } ) then //&& { _body_part != "" }
	{
		if( !(isNull _enemy) ) then {
			_body_part_damage = _body_part_damage * bcombat_damage_multiplier;
		};
		
		if( bcombat_debug_enable ) then {
			_msg = format["bcombat_fnc_eh_handledamage() - unit=%1", _unit ];
			[ _msg, 10 ] call bcombat_fnc_debug;
		};
		
		if( bcombat_allow_friendly_capped_damage 
			&& { !(isPlayer _enemy ) }
			&& { [_enemy, _unit] call bcombat_fnc_is_friendly } 
		) then { 
			_body_part_damage = _body_part_damage min bcombat_friendly_fire_max_damage;
		};
		
		_body_part_damage
	};
};

bcombat_fnc_eh_killed = {

	private ["_unit", "_killer", "_msg"];
	
	_unit = _this select 0; 
	_killer = _this select 1; 
	
	if(  [_unit] call bcombat_fnc_is_active ) then 
	{
		if( bcombat_allow_friendly_capped_damage 
			&& { alive _killer }
			&& { !(isPlayer _killer) }
		) then {
			if(rating _killer < 0) then { _killer addrating - (rating _killer); };
		};
		
		if( bcombat_debug_enable ) then {
			_msg = format["bcombat_fnc_eh_killed() - unit=%1, killer=%2, distance=%3, weapon=%4, accuracy=%5", _unit, _killer, _unit distance _killer, currentWeapon _killer, _killer skill "aimingAccuracy" ];
			[ _msg, 101 ] call bcombat_fnc_debug;
		};
	};
};

// Benchmarking: 0.16s x 1000
bcombat_fnc_unit_skill_set = 
{
	private [ "_unit", "_skill", "_k" ];
	
	_unit = _this select 0;
	_skill = _this select 1;

	if( isNil { _unit getVariable [ "bcombat_skill_orig", nil] } ) then
	{
		_unit setVariable [ "bcombat_skill_orig", skill _unit ];
	};
	
	_unit setSkill ((_skill * bcombat_skill_multiplier) ^ bcombat_skill_linearity);
	// hintc format["%1 %2 %3", _unit, _unit skill "general", _unit skill "aimingAccuracy" ];
	
	_k = _skill ^ .5 ;
	
	_unit setskill [ "Commanding", _k];
	_unit setSkill [ "courage", _k min 0.5];
	_unit setSkill [ "AimingSpeed", _k];
	// _unit setSkill [ "aimingShake", _k];
	//_unit setSkill [ "SpotTime", _k];
	//_unit setskill [ "Endurance", _k];
	
	/*
	if( [currentWeapon _unit] call bcombat_fnc_is_mgun ) then {
		_unit setSkill [ "aimingAccuracy", ((_skill ^ 1.25) min 0.9) max 0.02];
	};*/

	_unit setVariable [ "bcombat_skill", _skill ];
	_unit setVariable [ "bcombat_skill_sh", _skill];
	_unit setVariable [ "bcombat_skill_sd", _skill];
	_unit setVariable [ "bcombat_skill_st", _skill];
	_unit setVariable [ "bcombat_skill_cm", _skill];
	_unit setVariable [ "bcombat_skill_ac", _unit skill "aimingAccuracy"];
	_unit setVariable [ "bcombat_skill_cr", _unit skill "courage"];
	
	if( bcombat_debug_enable ) then {
		_msg = format["bcombat_fnc_unit_skill_set() - unit=%1, weapon=%2, exp=%3, general=%4, accuracy=%5, skill=%6,", _unit, primaryWeapon _unit, 0, _unit skill "general", _unit skill "aimingAccuracy", skill _unit];
		[ _msg, 2 ] call bcombat_fnc_debug;
	};
};

bcombat_fnc_blacklist_purge = {

	private["_array", "_n"];
	
	_array = (group _this) getVariable ["bcombat_cover_blacklist", [] ];
	
	if( count _array > 0 ) then
	{
		for "_n" from 0 to (count _array) - 1 step 2 do 
		{
			if( _array select (_n + 1) < time) then
			{
				_array set[_n , -1];
				_array set[ _n + 1  , -1];
			};	
		};
		
		_array = _array - [-1];
	};
	
	(group _this) setVariable ["bcombat_cover_blacklist", _array ];
	
	_array
};

bcombat_fnc_set_min_group_skill = {

	private["_unit", "_skill"];
	
	_unit = _this select 0;
	_skill = _this select 1;
	
	if ( player in (units group _unit)
		&& { _skill > _unit getVariable [ "bcombat_skill", skill _unit ] }
	) then {
	
		[_unit, _skill ] call bcombat_fnc_unit_skill_set;
		// player globalchat format ["%1 is given %2 skill", _unit, bcombat_skill_min_player_group];
	}
	else
	{
		if ( !( player in (units group _unit) )
			&& { _unit getVariable [ "bcombat_skill_orig", skill _unit ] < _unit getVariable [ "bcombat_skill", skill _unit ] }
		) then {
			[_unit, _unit getVariable [ "bcombat_skill_orig", skill _unit ] ] call bcombat_fnc_unit_skill_set;
			// player globalchat format ["%1 has skill reset to %2", _unit, _unit getVariable [ "bcombat_skill_orig", skill _unit ]];
		};
	};
};
				
bcombat_fnc_unit_initialize = {

	private ["_e", "_n"];

	//player globalchat format["Initializing %1 ...", _this];
	
	if( bcombat_remove_nvgoggles ) then
	{
		_this call bcombat_fnc_remove_nvg;
	};

	if( !(bcombat_allow_fatigue) ) then
	{
		_this enableFatigue false;
	};
	
	[_this, skill _this] call bcombat_fnc_unit_skill_set;

	if( isNil { _this getvariable ["bcombat_eh_fired", nil ] } ) then {
		_e = _this addEventHandler ["Fired", bcombat_fnc_eh_fired];
		_this setvariable ["bcombat_eh_fired", _e ];
	};

	if( isNil { _this getvariable ["bcombat_fnc_eh_hit", nil ] } ) then {
		_e = _this addEventHandler ["Hit", bcombat_fnc_eh_hit];
		_this setvariable [ "bcombat_eh_hit", _e ];
	};

	if( isNil { _this getvariable ["bcombat_fnc_eh_killed", nil ] } ) then {
		_e = _this addEventHandler ["Killed", bcombat_fnc_eh_killed];
		_this setvariable [ "bcombat_eh_killed", _e ];
	};

	if( isNil { _this getvariable ["bcombat_eh_handledamage", nil ] } ) then {
		_e = _this addEventHandler ["HandleDamage", bcombat_fnc_eh_handledamage]; 
		_this setvariable ["bcombat_eh_handledamage", _e ];
	};
	
	_this setVariable ["bcombat_init_done", true ];
	
	if( [_this] call bcombat_fnc_is_active
		&& bcombat_allow_grenades 
		&& bcombat_grenades_additional_number > 0) then
	{
		for "_n" from 0 to bcombat_grenades_additional_number step 1 do 
		{
			_this addMagazine "HandGrenade"; 
		};
	};
	
	if( [_this] call bcombat_fnc_is_active
		&& bcombat_allow_smoke_grenades 
		&& bcombat_smoke_grenades_additional_number > 0) then
	{
		for "_n" from 0 to bcombat_smoke_grenades_additional_number step 1 do 
		{
			_this addMagazine "SmokeShell"; 
		};
	};
};

bcombat_fnc_remove_nvg = {

	_this unassignitem "NVGoggles"; 
	_this unassignitem "NVGoggles_OPFOR"; 
	_this unassignitem "NVGoggles_INDEP"; 
	_this removeitem "NVGoggles";
	_this removeitem "NVGoggles_OPFOR";
	_this removeitem "NVGoggles_INDEP";
};

// ---------------------------------------
// SCRIPTS
// ---------------------------------------

// Benchmarking: 0.1s x 1000
bcombat_fnc_danger =
{
	private [ "_unit", "_enemy", "_leader", "_grp", "_cmode"];
	
	_unit = _this select 0;	
	_enemy = _this select 1;	
	_leader = leader _unit;
	
	if( !(behaviour _leader in ["COMBAT", "STEALTH"]) && _unit distance _enemy < bcombat_danger_distance ) then
	{
		if( bcombat_debug_enable ) then {
			_msg = format["bcombat_fnc_danger() - unit=%1, enemy=%2, distance=%3", _unit, _enemy,_unit distance _enemy ];
			[ _msg, 50 ] call bcombat_fnc_debug;
		};
		/*
		if( !( isPlayer _leader ) ) then 
		{
			(group _unit) setSpeedMode "FULL";
		};*/
		
		_leader setBehaviour "COMBAT";
		
	};
};

bcombat_fnc_fall_into_formation = {

	private [ "_unit", "_leader", "_pos"];
	
	// AI led: formation planned + no order = reached destination
	// Player led: doNotPlan + no order = reached destination
	
	_unit = _this select 0;
	_leader = formLeader _unit;
	
	if(
		[_unit] call bcombat_fnc_is_active
		&& { !(isPlayer _unit) }
		&& { !(fleeing _unit) }
		&& { !(captive _unit) }
		&& { canmove _unit }
		//&& [_leader] call bcombat_fnc_is_active
		//&& _formleader == _leader
		&& { _unit != _leader }
		//&& _unit distance _leader > (( count (units _grp) * 6 ) max 25)
		&& { [_unit] call bcombat_fnc_in_formation }
		&& { !([_unit] call bcombat_fnc_is_stopped) }
		&& { !([_unit] call bcombat_fnc_has_task) }
	) then
	{
		_dest = expecteddestination _unit;
		
		if( count _dest > 0) then { 
		
			_pos = _dest select 0; 

			if( _unit distance _pos > bcombat_tightened_formation_max_distance ) then
			{
				//player globalchat format["---> %1 fall into formation", _unit];
				_unit dowatch objNull;
				_unit dofollow _leader;
			};
		};
	};
};

bcombat_fnc_fast_move = {

	private [ "_unit", "_grp", "_leader", "_formleader", "_speed", "_expos", "_dest", "_mode"];

	_unit = _this select 0;	
	_grp = group _unit;
	_leader = leader _grp;
	_formleader = formationLeader _unit;

	if( 
		[_unit] call bcombat_fnc_is_active
		&& { ( behaviour _unit == "COMBAT" ) } // || _mode == "LEADER PLANNED"
		&& { currentcommand _unit == "MOVE" }
		&& { !(isPlayer _unit) }
		&& { !(fleeing _unit) }
		&& { !(captive _unit) }
		&& { [_leader] call bcombat_fnc_is_active }		
		&& { !(fleeing _leader) }
		&& { !(captive _leader) }
		&& { [_formleader] call bcombat_fnc_is_active }
		&& { !(fleeing _formleader) }
		&& { !(captive _formleader) }
		&& { _formleader != _unit }
		&& { !( [_unit] call bcombat_fnc_has_task ) }
		&& { !( [_unit] call bcombat_fnc_is_stopped ) }
		) then
	{	

		_speed = [ _unit ] call bcombat_fnc_speed;
		_expos = getposATL _formleader;
		_mode = (expecteddestination _unit) select 1;
		_dest = expecteddestination _formleader;
		_enemy = _unit findnearestenemy _unit;

		if( count _dest > 0) then { _expos = _dest select 0; };

		if (_unit != formLeader _unit && _unit != leader _unit) then { 
			_expos  = [_expos, 15] call bcombat_fnc_random_pos;
		};

		if(  count _expos > 0
			&& { !(isNull _enemy) && _enemy distance _formleader < 250 }
			&& { _unit distance _expos > 100 }
			&& { _unit distance _expos < 1000  }
			&& { (_unit distance _expos) > (_formleader distance _expos)  }
			&& _speed < 3.5
			 ) then 
		{

			if (_unit != formLeader _unit && _unit != leader _unit) then { 
				dostop _unit; 
			};

			_unit dowatch objNull;
			// _unit setDestination [ _expos, "LEADER PLANNED", true];
			_unit forcespeed -1;
			
			_unit domove _expos;
			// player globalchat format["%1 - %2 MOVE TO %3 [dist: %4]", time, _unit, _expos,  (_unit distance _expos) ];
		};
	};
};

// Benchmarking: 0.12s x 1000
bcombat_fnc_lookat = {

	private ["_unit1", "_unit2", "_minang", "_force", "_ang", "_steps", "_step", "_dt", "_n"];
	
	_unit1 = _this select 0;
	_unit2 = _this select 1;
	_minang = _this select 2;
	_force = _this select 3;
	
	_unit1 dowatch _unit2;

	if ( ( bcombat_allow_fast_rotate || _force )
		&& { isNil { _unit1 getVariable ["bcombat_rotating", nil] } }  
		&& { !(isPlayer _unit1) }
		//&& { [ _unit1 ] call bcombat_fnc_speed < 3 } 
	) then {

		_unit1 setVariable ["bcombat_rotating", true];
	
		_ang = [_unit1, _unit2] call bcombat_fnc_relativeDirTo_signed;
		_dir = direction _unit1;
		
		if(stance _unit1 == "PRONE") then
		{
			_step = 6;
			_dt = 0.03;
		}
		else
		{
			_step = 12;
			_dt = 0.03;
		};
		
		if( abs _ang > _minang ) then 
		{
			_steps = ceil ((abs _ang) / _step);
			_step = round(_ang * 10 / _steps) / 10;

			_n=0;
			for "_n" from 1 to _steps do {
				_unit1 setDir (_dir + _n * _step  );
				sleep (_dt);
			};
			
			//_unit1 setDir (_dir + _ang );
		};	
		
		_unit1 setVariable ["bcombat_rotating", nil ];
	}
	else
	{
		if( [ _unit1 ] call bcombat_fnc_speed == 0 ) then
		{
			_unit1 lookAt _unit2;
		}
	};
};

bcombat_fnc_move_team =
{
	private ["_unit", "_pos", "_members"];
	
	_unit = _this select 0;
	_pos = _this select 1;
	
	_members = [];
	
	if (count units _unit > 1) then
	{
		{ 
			if( _x != _unit && _unit == formLeader _x) then {
				_members set [count _members, _x];
			};
			
		} foreach units _unit;
	};
	
	_unit domove _pos;
	
	{
		_x dofollow _unit;
		
	} foreach _members;
};


bcombat_fnc_stop =
{
	private [ "_unit", "_timeout", "_timeout_max", "_enemydist", "_msg", "_handle" ];
	
	_unit = _this select 0;
	_timeout = _this select 1;
	_timeout_max = _this select 2;
	_timeout_fire = _this select 3;
	_enemydist = _this select 4; // optional
	
	_unit setVariable ["bcombat_stop_dt", _timeout_fire ];
	_unit setVariable ["bcombat_stop_t1", time + _timeout ];
	_unit setVariable ["bcombat_stop_t2", time + _timeout_max ];
	
	if( !(isPlayer _unit) && { !([_unit] call bcombat_fnc_is_stopped) } ) then
	{
		if( bcombat_debug_enable ) then {
			_msg = format["bcombat_fnc_stop() - BEGIN, unit=%1, timeout=%2, timeout_max=%3, firetime=%4", _unit, _unit getVariable ["bcombat_stop_t1", 0 ], _unit getVariable ["bcombat_stop_t2", 0 ], _unit getVariable ["bcombat_fire_time", 0]];
			[ _msg, 20 ] call bcombat_fnc_debug;
		};
			
		_unit forcespeed 0;
		
		_handle = [_unit, _enemydist] spawn 
		{
			private [ "_unit", "_enemydist", "_msg", "_level_unstop"];

			_unit = _this select 0;
			_enemydist = _this select 1;
			_enemydist = _this select 1;
			_stopow = false;

			//player globalchat format["%1 %2", _unit, currentWeapon _unit];
			
			if(  
				bcombat_stop_overwatch
				&& { ( bcombat_stop_overwatch_mode == 1 || [currentWeapon _unit] call bcombat_fnc_is_mgun ) }
				&& { leader _unit != player }
				&& { _unit != (formationLeader _unit) }
				&& { _unit != (leader _unit) }
				&& { leader _unit distance _unit < (bcombat_stop_overwatch_max_distance select 0) }
				&& { random 100 > _unit getVariable ["bcombat_suppression_level", 0] }
			) then {
				
				_stopow = true;
				_unit setVariable["bcombat_stop_overwatch", true];
				dostop _unit;
				_unit disableAI "target";
			};
			
			_level_unstop = ( ( _unit getVariable ["bcombat_suppression_level", 0] ) + 10) max 30;
			
			sleep .5;
			waitUntil { 
				(!([_unit] call bcombat_fnc_is_active)
					//|| { [ _unit ] call bcombat_fnc_speed > 0.5 }
					//|| !(canfire _unit) 
					// || { leader _unit == _unit }
					|| { _stopow && (((leader _unit) distance _unit) > (bcombat_stop_overwatch_max_distance select 1) || leader _unit == _unit ) } 
					|| { time > _unit getVariable ["bcombat_stop_t2", 0 ] }
					|| { time > _unit getVariable ["bcombat_stop_t1", 0 ] && time - ( _unit getVariable ["bcombat_fire_time", 0]) > _unit getVariable ["bcombat_stop_dt", 0] }
					|| { (_enemydist == 0 || _enemydist  > 25) && time > _unit getVariable ["bcombat_stop_t1", 0 ] && _unit getVariable ["bcombat_suppression_level", 0] > _level_unstop }
					//|| ( random 100 > 90 && random 100 < _unit getVariable ["bcombat_suppression_level", 0]  )
				); 
			}; 
			
			if( alive _unit ) then
			{
				_unit forcespeed -1;
				
				if( _stopow ) then 
				{
					_unit setVariable["bcombat_stop_overwatch", false];
					
					_unit enableAI "target";
					
					_unit domove (position (leader _unit));
					
					if( formationLeader _unit != _unit) then 
					{
						_unit dofollow (formationLeader _unit);  
					}
					else
					{
						_unit dofollow (leader _unit);  
					};
					
					
				};
				
				if( bcombat_debug_enable ) then {
					_msg = format["bcombat_fnc_stop() - END, unit=%1, timeout=%2, timeout_max=%3, Deltafiretime=%4 [%5], level=%6", _unit, _unit getVariable ["bcombat_stop_t1", 0 ], _unit getVariable ["bcombat_stop_t2", 0 ], time - ( _unit getVariable ["bcombat_fire_time", 0]), _unit getVariable ["bcombat_fire_time", 0],  _unit getVariable ["bcombat_suppression_level", 0] ];
					[ _msg, 20 ] call bcombat_fnc_debug;
				};
				
				_unit setVariable ["bcombat_stop_handle", nil];
			};
		};
		
		_unit setVariable ["bcombat_stop_handle", _handle];
	}
	else
	{
		if( bcombat_debug_enable ) then {
			_msg = format["bcombat_fnc_stop() - CONTINUE, unit=%1, timeout=%2, timeout_max=%3, firetime=%4", _unit, _unit getVariable ["bcombat_stop_t1", 0 ], _unit getVariable ["bcombat_stop_t2", 0 ], _unit getVariable ["bcombat_fire_time", 0]];
			[ _msg, 20 ] call bcombat_fnc_debug;
		};
	};
	
	if (true) exitWith {};
};

bcombat_fnc_soundalert_grenade = {

	private [ "_unit", "_grenade", "_pos", "_maxdist"];
	
	_unit  = _this select 0;
	_grenade = _this select 1;
	_pos =  _this select 2;
	_maxdist = _this select 3;
	
	waitUntil { isNull _grenade };

	[ _unit, _grenade, _pos, _maxdist ] call bcombat_fnc_soundalert;
};

bcombat_fnc_unit_get_destination = {

	private [ "_pos", "_dist" ];
	_pos = (expecteddestination _this) select 0;
	_distance = _this distance _pos;
	if(_distance > 99999) then { _distance = 0; };
	
	[_pos, _distance]
};

bcombat_fnc_unit_can_inspect_pos = {
	
	private [ "_unit", "_pos", "_wpdata", "_dstdata", "_dist", "_ret" ];
	
	_unit = _this select 0;
	_pos = _this select 1;
	_ret = false;
	
	if( count _this < 3 ) then {
		_wpdata = (group _unit) call bcombat_fnc_group_get_waypoint;
	} else {
		_wpdata = _this select 2;
	};
	
	if( count _this < 4 ) then {
		_dstdata = _unit call bcombat_fnc_unit_get_destination;
	} else {
		_dstdata = _this select 3;
	};
	
	if (  _pos distance (_wpdata select 0) < (_wpdata select 1) 
		// && ( _pos distance _unit ) < (_dstdata select 1) / 2
		&&  _pos distance (_dstdata select 0) < (_wpdata select 1) 
	) then {
		_ret = true;
	};
	
	// player globalchat format["%6 - %1 <--- %2 < %3  - %4 < %5", _ret, _pos distance (_wpdata select 0), (_wpdata select 1) , (_dstdata select 1), (_pos distance _unit) / 2, _unit ];
	_ret
};


bcombat_fnc_group_get_waypoint = {

	private [  "_n", "_wtype", "_radius", "_done" ];
	
	_n = (currentWaypoint _this);
	_wtype = WaypointType [_this, _n];
	_radius =  waypointCompletionRadius [_this, _n];
	_done = false;

	// GUARD, CYCLE, DISMISS are not terminating WP typres
	
	if(  _wtype == "" ) then
	{
		_n = _n - 1;
		_wtype = WaypointType [_this, _n];
		_radius =  waypointCompletionRadius [_this, _n];
		_done = true;
	};
	
	if( combatMode _this in  ["GREEN", "BLUE"] ) then { 
		_radius = 0; 
	}
	else
	{
		if(_radius == 0 && _wtype in ["HOLD", "SENTRY"]) then { 
			_radius = 100; 
		};
		
		if(_radius == 0 && _wtype in ["MOVE"]) then { 
			_radius = 250; 
		};
		
		if(_radius == 0 && _wtype in ["SAD", "DESTROY", "GUARD", ""]) then { 
			_radius = 500; 
		};
	};
	
	if( combatMode _this in  ["RED", "WHITE"] ) then { _radius = _radius * 2; };

	[  waypointPosition [_this, _n], _radius, _wtype, _done ]
	
};

// Benchmarking: 0.78s x 1000
bcombat_fnc_soundalert = {

	private [ "_unit", "_bullet", "_pos", "_maxdist", "_units", "_groups", "_x", "_prec", "_ppos", "_wtype", "_nenemy" ];

	_unit = _this select 0;
	_bullet = _this select 1;
	_pos =  (_this select 2) ;
	_maxdist = _this select 3;
	_units = (_pos nearEntities ["CAManBase", _maxdist]) - [_unit];
	//_groups = [];

	{
		if( [_x] call bcombat_fnc_is_active
			&& { _x == leader _x }
			&& { !(isPlayer _x ) }
			&& { [_x, _unit] call bcombat_fnc_is_enemy }
			
		) then {
		
			if( bcombat_debug_enable ) then {
				_msg = format["bcombat_fnc_soundalert() - unit = %1, bullet = %2, distance = %3, prec = %4", _unit, _bullet, _pos distance _x, [_x, _unit] call bcombat_fnc_knprec];
				[ _msg, 60 ] call bcombat_fnc_debug;   
			};
		
			// player setVariable ["bcombat_stats_hear_raw", (player getVariable ["bcombat_stats_hear_raw", 0]) + 1];
		 player globalchat format["%1 [%2/%4] HEARD -> %3", _unit, _maxdist, _x, _unit distance _x];
			// diag_log format["%1 [%2] HEARD -> %3", _unit, _maxdist, _x];
			
			[_x, _unit] call bcombat_fnc_reveal;
			
			/*
			// reveal once per group
			if( !(group _x in _groups) ) then
			{
				_groups = _groups + [group _x];
				[_x, _unit] call bcombat_fnc_reveal;
			};*/
			
			if( !(isPlayer(leader _x)) && { [_x, _unit] call bcombat_fnc_knprec >= 2 } ) then
			{
				private ["_nenemy", "_d1", "_d2"];
				
				// Switch to aware if needed
				if( behaviour _x in ["SAFE"] ) then
				{
					_x setBehaviour "AWARE";
				};

				if ( _pos distance _x < bcombat_danger_distance ) then {
					[ _x, objNull] call bcombat_fnc_danger;
				};
				
				if(  _x getVariable ["bcombat_suppression_level", 0] < 5) then {
					[ _x, 10, 1, 0, 5 + random 10, 30 + random 30, objNull ] call bcombat_fnc_fsm_trigger;
				};
				
				if ( _x distance _unit < bcombat_investigate_max_distance 
					&& { _x distance _unit > 25 }
					&& { [_x, _unit] call bcombat_fnc_knprec > 5}
					&& { time - ( _x getVariable ["bcombat_investigate_time", -15])  > 15  }
					&& { [_x, _pos] call bcombat_fnc_unit_can_inspect_pos } 
				) then
				{
			
					_nenemy = _x findNearestEnemy _x;
					
					if(  isNull _nenemy  ||  _nenemy == _unit  ) then 
					{
						//_prec =  [_x, _unit] call bcombat_fnc_knprec;
						//_ppos = [_pos, ((_pos distance _x) / 10) min _prec] call bcombat_fnc_random_pos; // perceived enemy position
				
						[_x, _pos, [_x, _unit] call bcombat_fnc_knprec] call bcombat_fnc_investigate;
					};
				};
			};
		};
	} foreach _units;
}; 

bcombat_fnc_visibility_multiplier  = {

	private [ "_maxdist", "_items" ];
	
	_maxdist = 1;
	_items = assignedItems _this;

	if( sunOrMoon == 0 ) then
	{ 
		if( "NVGoggles" in _items
			|| "NVGoggles_OPFOR" in _items
			|| "NVGoggles_INDEP" in _items
		) then {
	
			_maxdist = 0.8;
		} else {
			_maxdist = 0.5; //( 0.65 * ( moonIntensity ) ) max .1;
		};
	};
	
	// player globalchat format["%6, ---> %1 [%2] [%3] [%4] [%5]", ( _maxdist * ( 1 - ( fog ^ 2 ) / 2 ) * ( skill _unit ^ 0.5 ) ) max 0.1, sunormoon, fog, skill _unit, moonintensity, _unit ];
	( _maxdist * ( 1 - ( fog ^ 2 ) / 2 ) ) max 0.1
	
};

// Benchmarking: 0.88s x 1000
bcombat_fnc_reveal = {

	private [ "_unit", "_enemy", "_visible", "_p", "_prc",  "_dist", "_ang",  "_rv", "_isSilenced" ];

	if ( bcombat_allow_reveal ) then
	{
		_unit = _this select 0;
		_enemy = _this select 1;
		_visible = [_unit, _enemy] call bcombat_fnc_is_visible;
		_p = _unit getHideFrom _enemy;
		_prc = _p distance _enemy;
		_dist = _unit distance _enemy;
		_ang = [_unit, _enemy] call bcombat_fnc_relativeDirTo; // (0-180)
		
		_isSilenced = [_enemy, currentWeapon _enemy] call bcombat_fnc_weapon_is_silenced;
		
		if(_prc < 2 
			&& { _ang < 104 } 
			&& { _visible } 
			
			&& { !(_isSilenced) }
			
			&& { _dist < ( 150 * ( _unit call bcombat_fnc_visibility_multiplier ) ) } ) then
		{
			_unit reveal [_enemy, 4 ];	
			_unit glanceAt _enemy;
		}
		else
		{
			_rv = ( 4 /  ( ( _dist / 100 ) max 1)  / ( ( _ang / 45 ) max 1 ) ) / ( ((count units (group _unit)) max 1 ) ^ 0.5 ); 

			if( !(_visible) ) then {_rv = _rv * .25;};
			if( _isSilenced ) then {_rv = _rv * .25;};
			
			//diag_log format["%1 (ang:%2) (dist:%3)", _rv, _ang, _dist];
			// player globalchat format["%1 (ang:%2) (dist:%3)", _rv, _ang, _dist];

			_unit reveal [_enemy, _rv max 0.01 ];	
			
			if (_prc / _dist < .5 && !([_unit] call bcombat_fnc_has_task) ) then
			{
				_unit glanceAt _p;
				
				if( !(combatMode _unit in ["COMBAT","STEALTH"]) ) then
				{
					_unit dowatch _p;
				};
			};
		};
	};
};

// Benchmarking: 0.66s x 1000
bcombat_fnc_stance_set = {

	private ["_unit", "_timeout_min", "_timeout_mid", "_timeout_max",  "_stance", "_speed", "_st", "_time", "_enemy"];
	
	_unit = _this select 0;
	_timeout_min = _this select 1;
	_timeout_mid = _this select 2;
	_timeout_max = _this select 3;
	_stance = [ _unit ] call bcombat_fnc_stance_get;
	_speed = [ _unit ] call bcombat_fnc_speed;
	_st = "";
	_time = time;

	_task = (_unit getVariable ["bcombat_task", [nil,""] ]) select 1;
	_dest = (expecteddestination _unit) select 0;
		
	if( [_unit] call bcombat_fnc_is_active ) then
	{
		switch ( true ) do
		{
			// move to cover stance override
			case ( _task == "bcombat_fnc_task_move_to_cover" && ( _unit distance _dest > 5 ) && _speed > 0 ): {
				_st = "Up";
				_unit forcespeed 20;
			};
		
			case ( _time > _timeout_mid && _speed >= 2.75 ): {  // sprint
				_st = "Up";
			};
			
			case ( _time > _timeout_mid && (_stance in ["Middle", "Down", "Up"] && unitpos _unit != "Auto" ) ): {  // crouch to move faster, when moving fast while prone
				_st = "Middle";
			};

			case ( _time > _timeout_min && _speed >= .8 ): {  // crouch to move faster, when moving fast while prone
				_st = "Middle";
			};
			
			case ( _time < _timeout_min  ): 
			{ 
				if( (getPosATL _unit) select 2 > .25 ) then 
				{
					_st = "Middle";
				}
				else
				{
					_enemy = _unit findnearestenemy _unit;
					
					if( !(isNull _enemy) && _unit distance _enemy < bcombat_stance_prone_min_distance ) then
					{
						_st = "Middle";
					}
					else
					{
						_st = "Down";
					};
				};
			};
			
			case (  _time < _timeout_max  ): { 
					_st = "Middle";
			};
			
			case (  _time > _timeout_max): {  // ||  _speed <= 2 stay down, when lightly suppressed and under recent fire or moving slow
				_st = "Auto";
			};
		};
	
		if( bcombat_debug_enable ) then {
			_msg = format["bcombat_fnc_stance_set() - unit=%1, stance=%2 (is=%5), current h=%3, speed=%4", _unit, _st, ((aimpos _unit) select 2) - ((getPosASL _unit) select 2),_speed, _stance ];
			[ _msg, 7 ] call bcombat_fnc_debug;
		};

		if(_st == _stance ) then { _st = "";};
	};
	
	_st
};

/*
// Benchmarking: 0.11s x 1000
bcombat_fnc_allow_fire =
{
	private [ "_unit", "_grp"];
	
	_unit = _this select 0;	
	_grp = group _unit;
	
	if(combatMode _grp in ["GREEN"] ) then { _grp setCombatMode "YELLOW"; };
	if(combatMode _grp in ["WHITE"] ) then { _grp setCombatMode "RED"; };
};
*/

bcombat_fnc_handle_grenade = 
{
	private  ["_unit", "_targets", "_enemy", "_gtime", "_utime", "_ret"];
	
	_unit = _this select 0;
	_targets = _unit nearTargets (bcombat_grenades_distance select 1);
	_ret = false;
	
	Scopename "grenadeTargetsLoop";
		
	{
		_enemy = (_x select 4);
		
		if( !(isNull _enemy) 
			&& { [ _unit, _enemy] call bcombat_fnc_is_enemy }
			&& { [_unit, _enemy] call bcombat_fnc_knprec < 5  }
			&& { [_enemy] call bcombat_is_targetable }
			&& { [ _enemy ] call bcombat_fnc_speed < 3 }
			&& { ( !(bcombat_grenades_no_los_only) || !([_unit, _enemy] call bcombat_fnc_is_visible_simple) ) }
		) then
		{
			_gtime = (group _unit) getvariable["bcombat_grenade_time", -99];
			_utime = _unit getvariable ["bcombat_grenade_time", -99];

			if( 
				time - _utime > ( bcombat_grenades_timeout select 0 )
				&& { time - _gtime > ( bcombat_grenades_timeout select 1 ) }
				&& { [_unit, _enemy, bcombat_grenades_distance, 5] call bcombat_fnc_grenade_throwable }
			) then {
			

				(group _unit) setvariable ["bcombat_grenade_time", time];
				_unit setvariable ["bcombat_grenade_time", time];
				
				[_unit, "bcombat_fnc_task_throw_grenade", 100, [_enemy]] call bcombat_fnc_task_set;
				_ret = true;
				breakTo "grenadeTargetsLoop";
			};
		};
	} foreach _targets;
	
	_ret
};

bcombat_fnc_handle_smoke_grenade = 
{
	private  ["_unit", "_enemy", "_gtime", "_utime", "_ret"];
	
	_unit = _this select 0;
	_enemy = _this select 1;
	_gtime = (group _unit) getvariable ["bcombat_smoke_grenade_time", -99];
	_utime = _unit getvariable ["bcombat_smoke_grenade_time", -99];
	_ret = false;

	if( 
		[_unit, _enemy, bcombat_smoke_grenades_distance, 5] call bcombat_fnc_grenade_throwable 
		&& { time - _utime > ( bcombat_smoke_grenades_timeout select 0 ) }
		&& { time - _gtime > ( bcombat_smoke_grenades_timeout select 1 ) }
	) then {
	
		(group _unit) setvariable ["bcombat_smoke_grenade_time", time];
		_unit setvariable ["bcombat_smoke_grenade_time", time];
		
		[_unit, "bcombat_fnc_task_throw_smoke_grenade", 100, [_enemy]] call bcombat_fnc_task_set;
		_ret = true;
	};
	
	_ret
};

bcombat_fnc_cqb = 
{
	private  ["_unit", "_timeout", "_maxdist", "_params", "_nenemy", "_targets", "_target", "_targetLow", "_x", "_t", "_sl", "_targetDist", "_targetDistLow"];
	
	_unit = _this select 0;
	_timeout = _this select 1;
	_maxdist = _this select 2;
	_params = _this select 3;
	_targets = [];
	
	_t = time + 30;

	while { time < _t 
		&& { _unit distance player < bcombat_degradation_distance } 
		&& { [_unit] call bcombat_fnc_is_alive } 
		&& { !(fleeing _unit) } 
		&& { !(captive _unit) } 
		// && { random 1 <= (_unit skill "general" ) } // ^ .5 
	} do {
	

		_nenemy = _unit findnearestenemy _unit;
	
		if( !(isNull _nenemy) && { _unit distance _nenemy < bcombat_cqb_radar_max_distance * 1.1 } ) then
		{
			_t = time + 60;
			_sl = (_timeout select 0);
		}
		else
		{
			_sl = (_timeout select 1);
		};
			
		if( random 1 <= (_unit skill "general" )  
			&& { !([_unit] call bcombat_fnc_has_task) } 
			&& { random 100 > _unit getVariable ["bcombat_suppression_level", 0]  }
		) then
		{	
			_targets = [_unit, _maxdist, _params] call bcombat_fnc_targets;
			//_targets = [_targets] call bcombat_fnc_array_invert;
			
			_target = objNull;
			_targetLow = objNull;
			_targetDist = 1000;
			_targetDistLow = 1000;
				
			if( count _targets > 0 ) then 
			{
				{
					if( 
						[_unit, _x] call bcombat_fnc_is_visible 
						&& {  [_unit, _x] call bcombat_fnc_relativeDirTo < 104 } 
					) then {
					
						_unit reveal [_x, 4];
						_unit glanceAt _x;
						
						if( ( isNull (assignedTarget _unit) || _x == (assignedTarget _unit) || !([_unit, (assignedTarget _unit)] call bcombat_fnc_is_visible) )
							&& { _unit distance _x < _targetDist } 
						) then {
							_target = _x;
							_targetDist = _unit distance _x;
						};
						
					}
					else
					{
						_unit reveal [_x, (_unit knowsabout _x) * 1.01];
						_unit glanceAt _x;
						/*
						if( ( isNull (assignedTarget _unit) || _x == (assignedTarget _unit) || !([_unit, (assignedTarget _unit)] call bcombat_fnc_is_visible) )
							&& { _unit distance _x < _targetDistLow } 
						) then {
							_targetLow = _x;
							_targetDistLow = _unit distance _x;
						};
						*/
					};

				} foreach _targets;
			};
			
			
			//player globalchat format["%1 -----> %2 ---> [%3 %4]", time, _targets,  _target, _targetLow];	
			
			if( !(isNull _target) && combatMode _unit in ["RED", "YELLOW"] ) then {
				_unit glanceAt _target;
				_unit dowatch _target;
			};
			
			//if( isNull _target && !(isNull _targetLow)) then { _target = _targetLow; };
			
			if( combatMode _unit in ["RED", "YELLOW"]
				// && { _unit distance _target < bcombat_cqb_radar_max_distance }
				
				&& { !(isNull _target) }
				&& { [_unit, _target] call bcombat_fnc_is_visible  }
				&& { canfire _unit  }
				&& { _unit ammo (currentWeapon _unit) > 0  }
				&& { alive _target } 
				&& { !([_unit] call bcombat_fnc_has_task) }
				&& { [_unit, _target] call bcombat_fnc_knprec < 2 } 
				&& { [_unit, _target] call bcombat_fnc_relativeDirTo < 104 } ) then 
			{
				//player globalchat  format["----> %1 attack %2", _unit, _target];
				[_unit, "bcombat_fnc_task_fire", 1 , [_target, 1]] call bcombat_fnc_task_set; 
				
			};
			
		};
		
		sleep _sl;
	};
	
	_unit setVariable ["bcombat_cqb_lock", nil];
	
	if(true) exitWith{};
};

bcombat_is_targetable = 
{
	private  ["_ret", "_unit"];
	_unit = _this select 0;
	
	_ret = [_unit] call bcombat_is_on_foot;

	_ret
};

bcombat_is_on_foot = 
{
	private  ["_unit"];
	
	_unit = _this select 0;
	_ret = false;
	
	if( vehicle _unit == _unit 
		&& { alive _unit }
		&& { _unit isKindOf "CAManBase" }
	) then { _ret = true; };
	
	_ret
};

bcombat_fnc_targets = 
{
	private  ["_unit", "_maxdist", "_maxangle", "_minprec", "_minkn", "_maxspeed", "_targets", "_x", "_enemy", "_ret"];
	
	_unit = _this select 0;
	_maxdist = _this select 1;
	_maxangle = (_this select 2) select 0;
	_minprec = (_this select 2) select 1;
	_minkn = (_this select 2) select 2;
	_maxspeed = (_this select 2) select 3;
	_targets = _unit nearTargets _maxdist;
	_ret = [];
	
	{
		_enemy = (_x select 4);

		//diag_log format["%1 - %2 - %3 - %4 - %5", _enemy, _maxspeed, alive _enemy, damage _enemy, typeof _enemy];
		if(  !(isNull _enemy) 
			&& { [ _enemy ] call bcombat_is_targetable }
			&& { [ _enemy ] call bcombat_fnc_speed < _maxspeed }
			&& { [ _unit, _enemy ] call bcombat_fnc_is_enemy }
			&& { [ _unit, _enemy ] call bcombat_fnc_relativeDirTo < _maxangle }
			&& { [ _unit, _enemy ] call bcombat_fnc_knprec < _minprec }
			&& { _unit distance _enemy < ( 200 * ( _unit call bcombat_fnc_visibility_multiplier ) ) }
			&& { _unit distance _enemy < _maxdist }
		) then
		{
			_ret set[ count _ret, _enemy];
		};
		
	} foreach _targets;
	
	_ret
};

bcombat_fnc_investigate = {

	private ["_leader", "_group", "_prec", "_unit", "_pos", "_rand", "_nearpos", "_unitsByDistance"];
	
	_leader = _this select 0;
	_pos = _this select 1;
	_prec = _this select 2;
	_group = group _leader ;
	//_rand = 0.9;
	_cnt = floor (random ((count units _group) / 2));
	
	if( count units _group == 1 ) then { _rand = 0.45; };
	if( _pos distance _leader > 50 )  then { _rand = _rand / 2; };
	
	_unitsByDistance = [ units _group,[],{_pos distance _x},"ASCEND"] call BIS_fnc_sortBy;
	
//player globalchat format["----> %1 investigate [%2]", _leader, _rand];
	
	{
		if( 
			canfire _x
			&& { _cnt < 2 }
			// && { random 1 < _rand }
			//&& { _x != _leader || count units _group == 1}
			&& { canMove _x }
			//&& { [_x] call bcombat_fnc_in_formation }
			&& { !(fleeing _x) }
			&& { !(captive _x) }
			&& { !( [_x] call bcombat_fnc_has_task ) }
			&& { !( [_x] call bcombat_fnc_is_stopped ) }
			
		) then {
		
			// player globalchat format["----> %1 investigate %2 [d=%3]", _x, _pos, _pos distance _x];
			if( _prec > 5 ) then 
			{
				_nearpos = [_pos, (_prec min ((_leader distance _pos) / 2) ) max 5 ] call bcombat_fnc_random_pos;
				_x domove _nearpos;
				//player setpos _nearpos;
				//hintc("NEAR");
			}
			else
			{
				_x domove _rpos;
				//player setpos _pos;
				//hintc("EXACT");
			};
			
			_leader setVariable ["bcombat_investigate_time", time];
			
			_cnt = _cnt + 1;
		};
	
	} foreach _unitsByDistance;
};