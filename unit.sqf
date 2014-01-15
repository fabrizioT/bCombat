_nul = [ _this select 0] spawn 
{
	waitUntil { !(isNil "bcombat_init_done") };
	
	private ["_unit", "_e", "_nil"];

	_unit = _this select 0;

	waitUntil { [_unit] call bcombat_fnc_is_active };
	
	if(!(bcombat_allow_fatigue)) then
	{
		_unit enableFatigue false;
	};
	
	[_unit] call bcombat_fnc_unit_skill_set;
	
	_e = _unit addEventHandler ["Fired", bcombat_fnc_eh_fired];
	_unit setvariable ["bcombat_eh_fired", _e ];
	
	_e = _unit addEventHandler ["HandleDamage", bcombat_fnc_eh_handledamage]; 
	_unit setvariable ["bcombat_eh_handledamage", _e ];

	_e = _unit addEventHandler ["Killed", bcombat_fnc_eh_killed];
	_unit setvariable [ "bcombat_eh_killed", _e ];
	
	if( [_unit] call bcombat_fnc_is_active
		&& bcombat_allow_grenades 
		&& bcombat_grenades_additional_number > 0) then
	{
		for "_n" from 0 to bcombat_grenades_additional_number step 1 do 
		{
			_unit addMagazine "HandGrenade"; 
		};
	};
	
	if( [_unit] call bcombat_fnc_is_active
		&& bcombat_allow_smoke_grenades 
		&& bcombat_smoke_grenades_additional_number > 0) then
	{
		for "_n" from 0 to bcombat_smoke_grenades_additional_number step 1 do 
		{
			_unit addMagazine "SmokeShell"; 
		};
	};
	
	if( bcombat_cqb_radar ) then
	{
		[ _unit, bcombat_cqb_radar_clock, bcombat_cqb_radar_max_distance, bcombat_cqb_radar_params ] spawn bcombat_fnc_handle_targets;
	};
				
	while { [_unit] call bcombat_fnc_is_alive } do 
	{
		waitUntil { [_unit] call bcombat_fnc_is_active };

		if( !(isPlayer _unit) )  then
		{
			if( _unit == leader _unit) then
			{
			
				_blacklist = (group _unit) getVariable ["bcombat_cover_blacklist", [] ];
				
				if( count _blacklist > 0 ) then
				{
					for "_n" from 0 to (count _blacklist) - 1 step 2 do 
					{
						if( _blacklist select (_n + 1) < time) then
						{
							_blacklist set[_n , -1];
							_blacklist set[ _n + 1  , -1];
						};	
					};
					
					_blacklist = _blacklist - [-1];
					(group _unit) setVariable ["bcombat_cover_blacklist", _blacklist];
				};
	
				_enemy = _unit findnearestEnemy _unit;
				
				if( !(isNull _enemy)) then
				{
					if (_unit distance _enemy < 500) then
					{
						_unit enableAttack true;
					}
					else
					{
						_unit enableAttack false;
					}
				}
				else
				{
					_unit enableAttack false;
				};
			};
			
			if( !(isPlayer leader _unit) 
				&&  _unit != leader _unit
				&& { !(player in (units (group _unit))) }
				&& { bcombat_allow_fleeing }
			) then {
				[_unit] call bcombat_fnc_unit_handle_fleeing;
			}
			else
			{
				_unit allowFleeing 0;
			};

			if( 
				[_unit] call bcombat_fnc_is_active
				&& !([_unit] call bcombat_fnc_has_task)
				&& !(fleeing _unit)
				&& !(captive _unit)
			) then 
			{
				if( bcombat_allow_grenades 
					&& { "HandGrenade" in (magazines _unit) }
					&& { random 1 <= (_unit skill "general" ) ^ 0.5}
					&& { random 100 > (_unit getVariable ["bcombat_suppression_level", 0]) }
				) then {
					[_unit] call bcombat_fnc_handle_grenade;
				}
				else
				{
					if( bcombat_allow_fast_move || isPlayer (leader _unit) ) then //  && isPlayer (leader _unit) 
					{
						[_unit] call bcombat_fnc_fast_move;
					}
					else
					{
						if( bcombat_allow_tightened_formation ) then //  && isPlayer (leader _unit) 
						{
							[_unit] call bcombat_fnc_fall_into_formation;
						};
					};
				};
			};
		};
		
		sleep ( (bcombat_features_clock select 0) + random ( (bcombat_features_clock select 1) - (bcombat_features_clock select 0) ) );
	};
};
