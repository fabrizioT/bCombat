while { true } do 
{
	_t1 = time;
	_count = count allUnits;
	_i = 0;
	
	{
		_unit = _x;
		
		if( bcombat_enable && { !(isPlayer _unit) } && { [_unit] call bcombat_fnc_is_alive } )  then
		{
			if( isNil { _unit getvariable ["bcombat_init_done", nil ] } ) then 
			{
				// player globalchat format["Initializing %1 ...", _unit];
				
				_unit setvariable ["bcombat_init_done", true ];
				
				if( bcombat_remove_nvgoggles ) then
				{
					_unit unassignitem "NVGoggles"; 
					_unit unassignitem "NVGoggles_OPFOR"; 
					_unit unassignitem "NVGoggles_INDEP"; 
					_unit removeitem "NVGoggles";
					_unit removeitem "NVGoggles_OPFOR";
					_unit removeitem "NVGoggles_INDEP";
				};

				if( !(bcombat_allow_fatigue) ) then
				{
					_unit enableFatigue false;
				};
				
				[_unit] call bcombat_fnc_unit_skill_set;
				
				if( isNil { _unit getvariable ["bcombat_eh_fired", nil ] } ) then {
					_e = _unit addEventHandler ["Fired", bcombat_fnc_eh_fired];
					_unit setvariable ["bcombat_eh_fired", _e ];
				};

				if( isNil { _unit getvariable ["bcombat_fnc_eh_hit", nil ] } ) then {
					_e = _unit addEventHandler ["Hit", bcombat_fnc_eh_hit];
					_unit setvariable [ "bcombat_eh_hit", _e ];
				};

				if( isNil { _unit getvariable ["bcombat_fnc_eh_killed", nil ] } ) then {
					_e = _unit addEventHandler ["Killed", bcombat_fnc_eh_killed];
					_unit setvariable [ "bcombat_eh_killed", _e ];
				};

				if( isNil { _unit getvariable ["bcombat_eh_handledamage", nil ] } ) then {
					_e = _unit addEventHandler ["HandleDamage", bcombat_fnc_eh_handledamage]; 
					//if( _unit == player ) then { hintc format["%1", _e];  };	
					_unit setvariable ["bcombat_eh_handledamage", _e ];
				};
				
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
			};
			
			if( _unit distance player < bcombat_degradation_distance ) then
			{
				_unit setskill [ "SpotDistance", ( _unit getVariable [ "bcombat_skill_sd", 0] ) * 2 * ( [_unit] call bcombat_fnc_visibility_multiplier ) ];
				
				//hintc format["%1 (%2)", _unit skillfinal "spotDistance", ( _unit getVariable [ "bcombat_skill_sd", 0] )];
				//player globalchat format[" ---->%1 %2 %3 [%4]", _unit, (_unit skill "SpotDistance"), _unit getVariable [ "bcombat_skill_sd", 0], _unit distance player];
				//diag_log format[" ---->%1 %2 %3 [%4]", _unit, (_unit skill "SpotDistance"), _unit getVariable [ "bcombat_skill_sd", 0], _unit distance player];
			
				_enemy = _unit findnearestEnemy _unit;
				
				if( !(isNull _enemy) ) then
				{
					[ _unit, _enemy ] call bcombat_fnc_set_firemode;
				};
				
				// CQB
				if( !(isNull _enemy) && { _unit distance _enemy < bcombat_cqb_radar_max_distance } ) then
				{
					if( isNil { _unit getVariable ["bcombat_cqb_lock", nil] } ) then
					{
						_unit setVariable ["bcombat_cqb_lock", true];
						//player globalchat format["%1 CQB activated", _unit];
						[_unit, bcombat_cqb_radar_clock, bcombat_cqb_radar_max_distance, bcombat_cqb_radar_params] spawn bcombat_fnc_cqb;
					};
				};
				
				if( _unit == leader _unit) then
				{
				/*
					if( behaviour _unit == "COMBAT") then
					{
						(group _unit) setSpeedMode "FULL";
					};*/
				
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
					&& { _unit != leader _unit }
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
					[_unit] call bcombat_fnc_has_task
					&& !(fleeing _unit)
					&& !(captive _unit)
				) then 
				{
					if( bcombat_allow_grenades 
						&& { _i mod 2 == 0}
						&& { !(isNull _enemy) } 
						&& { _unit distance _enemy < ( bcombat_grenades_distance select 1 ) }
						&& { "HandGrenade" in (magazines _unit) }
						&& { random 1 <= (_unit skill "general" ) ^ 0.5}
						&& { random 100 > (_unit getVariable ["bcombat_suppression_level", 0]) }
					) then {
						//player globalchat format["%1 - %2 %3", _unit distance _enemy, _uni, _enemy];
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
		};
		
		_i = _i +1;
		if( _i mod 10 == 0) then { sleep 0.01; };
		
	} foreach allUnits;
	
	// player globalchat format["----->%1 / %2 / %3", count allunits, count allgroups , time - _t1];
	//diag_log format["----->%1 / %2 / %3", count allunits, count allgroups ,_t2 - _t1];
	//sleep ( (bcombat_features_clock select 0) + random ( (bcombat_features_clock select 1) - (bcombat_features_clock select 0) ) );
	sleep 3;
};