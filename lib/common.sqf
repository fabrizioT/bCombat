// ---------------------------------------
// FUNCTIONS
// ---------------------------------------

// Benchmarking: 0.13s x 1000
bcombat_fnc_is_active = {	// bCOmbat is on, unit is man, alive, activated and on foot

	private [ "_unit", "_ret" ];
	
	_unit = _this select 0;
	_ret = false;
	
	if( bcombat_enable 
		&& !(isNil "bcombat_init_done")
		&& { alive _unit }
		&& { _unit isKindOf "CAManBase" }
		&& { str (side _unit) != "CIV" }
		&& { vehicle _unit == _unit }
	) then
	{
		if( count bcombat_allowed_sides > 0
			||  count bcombat_allowed_groups > 0
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

	private [ "_unit", "_enemy"];
	
	_enemy = _this select 1;

	((_this select 0) getHideFrom _enemy) distance _enemy
};

// Benchmarking: 0.5s - 1s x 1000
bcombat_fnc_is_visible = {

	private [ "_o1", "_o2", "_dist", "_ret" ];
	
	_o1 = _this select 0;
	_o2 = _this select 1;
	_dist = _o1 distance _o2;
	_ret = true;
	
	if( terrainintersectasl [eyepos _o1, eyepos _o2] ) then { 
		_ret = false; 
	} 
	else 
	{ 
		if( lineintersects [eyepos _o1, eyepos _o2, _o1, _o2] ) then 
		{ 
			if( _dist < 150 ) then 
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
	
	if( terrainintersectasl [eyepos _o1, aimpos _o2] ) then { 
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
	private ["_unit", "_weapon"];
	
	_unit = _this select 0;
	_weapon = format["%1", currentWeapon _unit];
	
	if( _weapon == "" ) then {
		_weapon = format["%1", primaryWeapon _unit];
	};

	//player globalchat format["error: %1  [%2] %3 %4 %5 - %6", _unit,  currentweapon _unit, side _unit, behaviour _unit,  primaryweapon _unit, getNumber(configFile >> "cfgWeapons" >> _weapon >> "Single" >> "maxRange") ];
	//diag_log format["error: %1  [%2] %3 %4 %5 - %6", _unit,  currentweapon _unit, side _unit, behaviour _unit,  primaryweapon _unit, getNumber(configFile >> "cfgWeapons" >> _weapon >> "Single" >> "maxRange" ) ];
	//hintc format["%1 %2 %3", _unit, _weapon, (getNumber(configFile >> "cfgWeapons" >> _weapon >> "Single" >> "maxRange" ) * (skill _unit ^ 0.2))];
	(getNumber(configFile >> "cfgWeapons" >> _weapon >> "Single" >> "maxRange" ) * (skill _unit ^ 0.2)) max 50
};

// Benchmarking: see bcombat_fnc_relativeDirTo
bcombat_fnc_relativeDirTo_signed = {

	private ["_posA","_posB","_dir"];

	_posA = getPosATL (_this select 0);
	_posB = getPosATL (_this select 1);

	_dir = (((_posB select 0) - (_posA select 0)) atan2 ((_posB select 1) - (_posA select 1)) - getdir (_this select 0))  % 360;

	if (_dir < 0) then { _dir = _dir + 360 };
	if (_dir > 180) then {_dir = _dir - 360};
	
	_dir
};

// Benchmarking: 0.24s x 1000
bcombat_fnc_relativeDirTo = {
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

// Benchmarking: <0.1s x 1000
bcombat_fnc_is_alive = 
{
	private ["_unit", "_ret"];
	
	_unit = _this select 0;
	_ret = true;
	
	if( isNull _unit || !( alive _unit ) ) then
	{
		_ret = false;
	};
	
	_ret;
};

// Benchmarking: 0.16s x 1000
bcombat_fnc_in_formation = 
{
	private [ "_unit", "_expos", "_ret" ];
	
	_unit = _this select 0;
	_expos = expecteddestination _unit;
	_ret = false;
	
	if( count _expos  > 0) then
	{
		if( _unit != leader _unit 
			&& { !(isPlayer _unit) } 
			&& { (currentCommand _unit) in  ['', 'MOVE'] } ) then 
		{
			if( [_unit] call bcombat_fnc_is_active
				&& (_expos select 1) in ["FORMATION PLANNED",  "DoNotPlanFormation"] ) then //"DoNotPlan",
			{
				_ret = true;
			};
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

// ---------------------------------------
// EVENT HANDLERS
// ---------------------------------------

bcombat_fnc_eh_fired = {

	private ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_bullet", "_msg"];
	
	_unit = _this select 0; 
	_weapon = _this select 1;
	//_muzzle = _this select 2;
	//_mode = _this select 3;
	//_ammo = _this select 4;
	//_magazine = _this select 5;
	_bullet = _this select 6;

	if( [_unit] call bcombat_fnc_is_active ) then 
	{
		if( bcombat_allow_hearing ) then 
		{
			if(  time - (_unit getVariable ["bcombat_fire_time", 0 ]) > 1 
				&& !([_unit, _weapon] call bcombat_fnc_weapon_is_silenced) 
			) then {
				
				[ _unit, _bullet] call bcombat_fnc_soundalert;
			};
		};

		//[ _unit] call bcombat_fnc_allow_fire;
		[ _unit, objNull] call bcombat_fnc_danger;
		
		_unit setVariable ["bcombat_fire_time", time]; 
		
		if( bcombat_debug_enable ) then {
			_msg = format["bcombat_fnc_eh_fired() - unit=%1", _unit ];
			[ _msg, 10 ] call bcombat_fnc_debug;
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

	if(  [_unit] call bcombat_fnc_is_active ) then 
	{
		if( bcombat_debug_enable ) then {
			_msg = format["bcombat_fnc_eh_handledamage() - unit=%1", _unit ];
			[ _msg, 10 ] call bcombat_fnc_debug;
		};
		
		if( bcombat_allow_friendly_capped_damage 
			&& { !(isPlayer _enemy ) }
			&& { !([_enemy, _unit] call bcombat_fnc_is_enemy) } 
		) then { 
			_body_part_damage = _body_part_damage min bcombat_friendly_fire_max_damage;
		};
		
		[ _unit, 11, bcombat_penalty_wounded, time + 5 + random 5, time + 10 + random 5, time + 15 + random 15, _enemy ] call bcombat_fnc_fsm_trigger;

		_body_part_damage;
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

		_list = nearestObjects [(getPosATL _enemy), ["Man", "Car"], _safedist] - [_unit];
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
	
	//hintc format["%1", _ret];
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
	
	if( _r2 > 0) then
	{
		_objects = nearestObjects [_p, ["HOUSE"], _r2] + (nearestObjects [_p, [], _r1 ]) -  (_unit nearTargets _r1) -  (_p nearObjects _r1 )  -  (_p nearroads _r1) - _blacklist; 
	}
	else
	{
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
				
				if(  ((getPosATL _x) select 2) < 0.2 && _dz > 1.5 && _dz < 30 && _min >= 0.3 && _max > 1 && _max / _min < 3.5) then // !(_x isKindOf "CaManBase") &&
				{
					// blacklisting
					private ["_r", "_offset"];
					
					_r = (getPosATL _x);
					
					if( _unit distance _r < 5) then	// too near, skip all
					{
	//player globalchat format["CLOSE: pos=%1 obj=%2 d=%3",_r, _x, _unit distance _r ];
						BreakTo "bcombat_fnc_find_cover_pos_loop";
					};
					
					if( _blacklist find (str _r) == -1 ) then
					{
						_ret = [_r, _x, 2];
	//player globalchat format["pos=%1 obj=%2 d=%3",_r, _x, _unit distance _r ];
						BreakTo "bcombat_fnc_find_cover_pos_loop";
					};

					// end blacklisting
				};
			};
			
		} foreach _objects;
	};

	
	//hintc format["%1", _blacklist];
	if( !isNil "_ret") then { _ret } else { nil }
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

// ---------------------------------------
// SCRIPTS
// ---------------------------------------

// Benchmarking: 0.16s x 1000
bcombat_fnc_unit_skill_set = 
{
	private [ "_unit", "_k" ];
	
	_unit = _this select 0;
	
	//hintc format["---> %1 %2 %3", skill _unit, _unit skill "spotDistance", _unit skillFinal "spotDistance"];
	_k = (skill _unit ) ^ .5 ;
	//_unit setskill [ "SpotDistance", _k];
	_unit setskill [ "Commanding", _k];
	_unit setskill [ "Endurance", _k];
	_unit setSkill [ "courage", _k];
	_unit setSkill [ "AimingSpeed", _k];
	_unit setSkill [ "SpotTime", _k];
	/*
	if( !([currentWeapon _unit] call bcombat_fnc_is_mgun) ) then
	{
		_unit setSkill [ "aimingAccuracy", (_unit skill "aimingAccuracy") ^ 1.25];
	};*/
	
	_unit setVariable [ "bcombat_skill", _unit skill "general"];
	_unit setVariable [ "bcombat_skill_ac", _unit skill "aimingAccuracy"];
	_unit setVariable [ "bcombat_skill_sh", _unit skill "aimingShake"];
	_unit setVariable [ "bcombat_skill_cr", _unit skill "courage"];
	_unit setVariable [ "bcombat_skill_sd", _unit skill "spotDistance"];

	if( bcombat_debug_enable ) then {
		_msg = format["bcombat_fnc_unit_skill_set() - unit=%1, weapon=%2, exp=%3, general=%4, accuracy=%5, skill=%6,", _unit, primaryWeapon _unit, 0, _unit skill "general", _unit skill "aimingAccuracy", skill _unit];
		[ _msg, 2 ] call bcombat_fnc_debug;
	};
};

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
		
		if( !( isPlayer _leader ) ) then 
		{
			(group _unit) setSpeedMode "FULL";
		};
		
		_leader setBehaviour "COMBAT";
	};
};

bcombat_fnc_fall_into_formation = {

	private [ "_unit", "_leader", "_pos"];
	
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
			
			//if( [ _unit ] call bcombat_fnc_speed == 0) then { _unit domove position _leader; sleep .1; };

			//_unit setDestination [ _pos, (_dest select 1), true];
			
			if( _unit distance _pos > bcombat_tightened_formation_max_distance ) then
			{
				//player globalchat format ["%4 - %1 fall into formation (%2) (%3)", _unit, _leader, _unit distance _pos, time];
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
		//&& _formleader != _leader
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
			&& { !(isNull _enemy) && _enemy distance _formleader < 400 }
			&& { _unit distance _expos > 50 }
			&& { _unit distance _expos < 250  }
			&& { (_unit distance _expos) > (_formleader distance _expos)  }
			&& _speed < 2
			 ) then 
		{

			if (_unit != formLeader _unit && _unit != leader _unit) then { 
				dostop _unit; 
			};
			
			_unit dowatch objNull;
			_unit setDestination [ _expos, "LEADER PLANNED", true];
			_unit forcespeed -1;
			_unit domove _expos;

			//player globalchat format["%1 - %2 MOVE TO %3 [dist: %4]", time, _unit, _expos,  (_unit distance _expos) ];
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
		&& { [ _unit1 ] call bcombat_fnc_speed < 3 } 
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
				diag_log format["%1 - %2: END rotation ang:%3, curr:%4, step:%5, %6/%7", time, _unit1, _ang, _n * _step, _step, _n, _steps];
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
	
	if( !(isPlayer _unit) && !([_unit] call bcombat_fnc_is_stopped) ) then
	{
		if( bcombat_debug_enable ) then {
			_msg = format["bcombat_fnc_stop() - BEGIN, unit=%1, timeout=%2, timeout_max=%3, firetime=%4", _unit, _unit getVariable ["bcombat_stop_t1", 0 ], _unit getVariable ["bcombat_stop_t2", 0 ], _unit getVariable ["bcombat_fire_time", 0]];
			[ _msg, 20 ] call bcombat_fnc_debug;
		};
			
		_handle = [_unit, _enemydist] spawn 
		{
			private [ "_unit", "_enemydist", "_msg", "_level_unstop"];
			
			_unit = _this select 0;
			_enemydist = _this select 1;
			_stopow = false;
			
			_unit forcespeed 0;
			
			if(  
				bcombat_stop_overwatch
				&& { ( bcombat_stop_overwatch_mode == 1 || [currentWeapon _unit] call bcombat_fnc_is_mgun ) }
				&& { leader _unit != player }
				&& { _unit != (formationLeader _unit) }
				&& { _unit != (leader _unit) }
				&& { leader _unit distance _unit < 100 }
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
					|| [ _unit ] call bcombat_fnc_speed > 1
					//|| !(canfire _unit) 
					|| time > _unit getVariable ["bcombat_stop_t2", 0 ]
					|| ( time > _unit getVariable ["bcombat_stop_t1", 0 ] && time - ( _unit getVariable ["bcombat_fire_time", 0]) > _unit getVariable ["bcombat_stop_dt", 0] ) 
					|| ( (_enemydist == 0 || _enemydist  > 25) && time > _unit getVariable ["bcombat_stop_t1", 0 ] && _unit getVariable ["bcombat_suppression_level", 0] > _level_unstop )
					//|| ( random 100 > 90 && random 100 < _unit getVariable ["bcombat_suppression_level", 0]  )
				); 
			}; 
			
			if( alive _unit ) then
			{
				_unit forcespeed -1;
				_unit setVariable ["bcombat_stop_handle", nil];
				
				if( _stopow ) then 
				{
					_unit setVariable["bcombat_stop_overwatch", false];
					_unit domove (position _unit);
					_unit dofollow (formationLeader _unit); 
					_unit enableAI "target";
				};

				if( bcombat_debug_enable ) then {
					_msg = format["bcombat_fnc_stop() - END, unit=%1, timeout=%2, timeout_max=%3, Deltafiretime=%4 [%5], level=%6", _unit, _unit getVariable ["bcombat_stop_t1", 0 ], _unit getVariable ["bcombat_stop_t2", 0 ], time - ( _unit getVariable ["bcombat_fire_time", 0]), _unit getVariable ["bcombat_fire_time", 0],  _unit getVariable ["bcombat_suppression_level", 0] ];
					[ _msg, 20 ] call bcombat_fnc_debug;
				};
				
				
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

// Benchmarking: 0.78s x 1000
bcombat_fnc_soundalert = {

	private [ "_unit", "_bulletspeed", "_units", "_groups", "_x" ];
		
	_unit = _this select 0;
	_bulletspeed = speed (_this select 1) / 3.6;
	_units = (_unit nearEntities ["CAManBase", _bulletspeed / 2]) - [_unit];
	_groups = [];

	{
		if( [_x] call bcombat_fnc_is_active
			&& { _bulletspeed > 360 }
			&& { !(group _x in _groups) }
			&& { !(isPlayer _x ) }
			&& { [_x, _unit] call bcombat_fnc_is_enemy }
			&& { random 1 <= (_x skill "general" ) }
		) then {
		
			_groups = _groups + [group _x];
		
			[leader _x, _unit] call bcombat_fnc_reveal;
			
			if( !(isPlayer(leader _x)) ) then
			{
				[ _x, 10, 1, 0, 5 + random 10, 30 + random 30, objNull ] call bcombat_fnc_fsm_trigger;
			};
		};
		
	} foreach _units;
	
}; 

// Benchmarking: 0.88s x 1000
bcombat_fnc_reveal = {

	private [ "_unit", "_enemy", "_visible", "_p", "_prc",  "_dist", "_kn", "_ang",  "_rv" ];

	if ( bcombat_allow_reveal ) then
	{
		_unit = _this select 0;
		_enemy = _this select 1;
		_visible = [_unit, _enemy] call bcombat_fnc_is_visible;
		_p = _unit getHideFrom _enemy;
		_prc = _p distance _enemy;
		
		if(_prc < 1.5 && _visible) then
		{
			_unit reveal [_enemy, 4 ];	
			_unit glanceAt _enemy;
		}
		else
		{
			_ang = [_unit, _enemy] call bcombat_fnc_relativeDirTo;
			_dist = _unit distance _enemy;
			
			_rv = 4 / ceil ( _dist / 50 +.1) / ceil ( _ang / 60 +.1); 
			if( !(_visible) ) then {_rv = _rv * .1;};
			
			_unit reveal [_enemy, _rv max 0.01 ];	
			
			if (_prc / _dist < .3 && !([_unit] call bcombat_fnc_has_task) ) then
			{
				_unit glanceAt _p;
				
				if( !(combatMode _unit in ["COMBAT"]) ) then
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

	if( [_unit] call bcombat_fnc_is_active ) then
	{
		switch ( true ) do
		{
			case ( _time > _timeout_mid && _speed >= 3.6 ): {  // sprint
				_st = "Up";
			};
			
			case ( _time > _timeout_mid && (_stance in ["Middle", "Down", "Up"] && unitpos _unit != "Auto" ) ): {  // crouch to move faster, when moving fast while prone
				_st = "Middle";
			};

			case ( _time > _timeout_min && _speed >= .6 ): {  // crouch to move faster, when moving fast while prone
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
					
					if( !(isNull _enemy) && _unit distance _enemy < 25 ) then
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

// Benchmarking: 0.11s x 1000
bcombat_fnc_allow_fire =
{
	private [ "_unit", "_grp"];
	
	_unit = _this select 0;	
	_grp = group _unit;
	
	if(combatMode _grp in ["GREEN"] ) then { _grp setCombatMode "YELLOW"; };
	if(combatMode _grp in ["WHITE"] ) then { _grp setCombatMode "RED"; };
};


/*
bcombat_fnc_is_mgun = {

	private ["_weapon", "_ret"];
	
	_weapon = str (_this select 0);
	_ret = ["lmg_", _weapon] call bcombat_fnc_in_str;
	
	if(!(_ret)) then {
		_ret = ["_sw_", _weapon] call bcombat_fnc_in_str;
	};
	
	_ret
};

bcombat_fnc_in_str = {

    private ["_needle","_haystack","_needleLen","_hay","_found"];
    _needle = [_this, 0, "", [""]] call BIS_fnc_param;
    _haystack = toArray ([_this, 1, "", [""]] call BIS_fnc_param);
    _needleLen = count toArray _needle;
    _hay = +_haystack;
    _hay resize _needleLen;
    _found = false;
    for "_i" from _needleLen to count _haystack do {
        if (toString _hay == _needle) exitWith {_found = true};
        _hay set [_needleLen, _haystack select _i];
        _hay set [0, "x"];
        _hay = _hay - ["x"]
    };
    _found
};

bcombat_fnc_relpos = {

	private ["_pos","_dist","_dir"];

	_pos  = _this select 0;
	_dist = _this select 1;
	_dir  = _this select 2;

	//if an object, not position, was passed in, then get its position
	if(typename _pos == "OBJECT") then {_pos = getpos _pos};

	//find position relative to passed position
	if (count _pos==3) then
	{
		_pos = [(_pos select 0) + _dist*sin _dir, (_pos select 1) + _dist*cos _dir, _pos select 2];
	}
	else
	{
		_pos = [(_pos select 0) + _dist*sin _dir, (_pos select 1) + _dist*cos _dir];
	};
	
	_pos
};
*/

/*
// Benchmarking: 0.12s x 1000
bcombat_fnc_is_on_foot = 
{
	private ["_unit", "_ret"];
	
	_unit = _this select 0;
	_ret = false;
	
	if( _unit isKindOf "CAManBase" && vehicle _unit == _unit) then
	{
		_ret = true;
	};
	
	_ret;
};
*/

bcombat_fnc_handle_grenade = 
{
	private  ["_unit", "_targets", "_enemy", "_gtime", "_utime"];
	
	_unit = _this select 0;
	_targets = player nearTargets (bcombat_grenades_distance select 1);
	
	Scopename "grenadeTargetsLoop";
		
	{
		_enemy = (_x select 4);
		
		if( !(isNull _enemy) 
			&& { [ _unit, _enemy] call bcombat_fnc_is_enemy }
			&& { [_unit, _enemy] call bcombat_fnc_knprec < 5  }
			&& { _enemy isKindOf "CAManBase"  }
			&& { vehicle _enemy == _enemy  }
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
				breakTo "grenadeTargetsLoop";
			};
		};
	} foreach _targets;
};

bcombat_fnc_handle_smoke_grenade = 
{
	private  ["_unit", "_enemy", "_gtime", "_utime"];
	
	_unit = _this select 0;
	_enemy = _this select 1;
	_gtime = (group _unit) getvariable ["bcombat_smoke_grenade_time", -99];
	_utime = _unit getvariable ["bcombat_smoke_grenade_time", -99];

	if( 
		[_unit, _enemy, bcombat_smoke_grenades_distance, 5] call bcombat_fnc_grenade_throwable 
		&& { time - _utime > ( bcombat_smoke_grenades_timeout select 0 ) }
		&& { time - _gtime > ( bcombat_smoke_grenades_timeout select 1 ) }
	) then {
	
		(group _unit) setvariable ["bcombat_smoke_grenade_time", time];
		_unit setvariable ["bcombat_smoke_grenade_time", time];
		
		[_unit, "bcombat_fnc_task_throw_smoke_grenade", 100, [_enemy]] call bcombat_fnc_task_set;
	};
};

bcombat_fnc_handle_targets = 
{
	private  ["_unit", "_timeout", "_maxdist", "_params", "_nenemy", "_targets", "_x"];
	
	_unit = _this select 0;
	_timeout = _this select 1;
	_maxdist = _this select 2;
	_params = _this select 3;
	_targets = [];

	while { alive _unit } do
	{
		waitUntil { bcombat_enable };
		waitUntil { [_unit] call bcombat_fnc_is_active && !(isPlayer _unit) };
		
		_nenemy = _unit findnearestenemy _unit;
		
		if( !(isNull _nenemy) && { random 1 <= (_unit skill "general" ) ^ 0.5} && { _unit distance _nenemy < bcombat_cqb_radar_max_distance } ) then
		{
			_targets = [_unit, _maxdist, _params] call bcombat_fnc_targets;
			
			{
				if( [_unit, _x] call bcombat_fnc_is_visible ) then
				{
					_unit reveal [_x, 4];
					_unit glanceAt _x;
					
					if( isNull (assignedTarget _unit)
						&& { !([_unit] call bcombat_fnc_has_task) }
						//&& _x == _targets select 0					
					) then {
						_unit dowatch _x;
						//player globalchat format[" ----> %1 WATCH  %2", _x, _unit];
					};
				}
				else
				{
					_unit reveal [_x, 2];
				};
				
			} foreach _targets;
			
			sleep (_timeout select 0);
		}
		else
		{
			sleep (_timeout select 1);
		};
		
		//player globalchat format["%1 - targets: %2 ---> %3 %4", _unit, _targets, _maxdist, _params];
	};
};

bcombat_fnc_targets = 
{
	private  ["_unit", "_maxdist", "_maxngle", "_minprec", "_minkn", "_maxspeed", "_targets", "_x", "_enemy", "_ret"];
	
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
		
		if( !(isNull _enemy) 
			&& { _enemy isKindOf "CAManBase"  }
			&& { vehicle _enemy == _enemy  }
			&& { _unit distance _enemy < _maxdist }
			&& { [ _unit, _enemy] call bcombat_fnc_is_enemy }
			&& { [_unit, _enemy] call bcombat_fnc_relativeDirTo < _maxangle }
			&& { [_unit, _enemy] call bcombat_fnc_knprec < _minprec }
			&& {  _unit knowsabout _enemy > _minkn }
			&& { [ _enemy ] call bcombat_fnc_speed < _maxspeed }
		) then
		{
			_ret set[ count _ret, _enemy];
		};
		
	} foreach _targets;
	
	_ret
};
