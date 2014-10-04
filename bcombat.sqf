// ----------------------------------------
// bcombat | combat framework
// ----------------------------------------
// Author: Fabrizio_T 
// License: GNU/GPL
// ----------------------------------------

// IMPORTANT - DO NOT REMOVE the following line
if( !(isNil "bcombat") ) exitWith{}; 
bcombat = true; // avoid having multiple instances running

// -----------------------------
// Configuration
// -----------------------------

if(isNil "bcombat_enable") then { bcombat_enable = true; }; 	

bcombat_debug_enable = false;
bcombat_debug_levels = [1,6,8];
bcombat_debug_chat = true;

bcombat_name 		= "bcombat AI Infantry mod"; 
bcombat_short_name 	= "bcombat"; 
bcombat_version 	= "0.17";

// -----------------------------
// files preload
// -----------------------------

call compile preprocessFileLineNumbers "\@bcombat\lib\debug.sqf"; 
call compile preprocessFileLineNumbers "\@bcombat\config.sqf"; 

// -----------------------------
// Configuration defaults
// -----------------------------

// Toggle
if(isNil "bcombat_enable") then { bcombat_enable = true }; 													// Toggle mod on / off 
if(isNil "bcombat_dev_mode") then { bcombat_dev_mode = false }; 											// Toggle mod on / off 

// Debug
if(isNil "bcombat_startup_hint") then { bcombat_startup_hint = true; }; 									// toggle to Enable / Disable bDetect startup Hint.
if(isNil "bcombat_debug_enable") then { bcombat_debug_enable = false; }; 									// toggle to Enable / Disable debug messages.
if(isNil "bcombat_debug_chat") then { bcombat_debug_chat = false; }; 										// show debug messages also in globalChat.
if(isNil "bcombat_debug_levels") then { bcombat_debug_levels = [0,1,2,3,4,5,6,7,8,9]; }; 					// filter debug messages by included levels. 

// Activate only sides / groups / units 
if(isNil "bcombat_allowed_sides") then { bcombat_allowed_sides = []; };										// Alpha feature please don't change
if(isNil "bcombat_allowed_groups") then { bcombat_allowed_groups = []; };									// Alpha feature please don't change 
if(isNil "bcombat_allowed_units") then { bcombat_allowed_units = []; };										// Alpha feature please don't change 

// Features degradation threshold distance
if(isNil "bcombat_degradation_distance") then { bcombat_degradation_distance = 1250; }; 

// Lower ground penalty
if(isNil "bcombat_allow_lowerground_penalty") then { bcombat_allow_lowerground_penalty = true; }; 	

// Damage multiplier
if(isNil "bcombat_damage_multiplier") then { bcombat_damage_multiplier = 1; }; 	

// Units internal clock (for optional features)
if(isNil "bcombat_features_clock") then { bcombat_features_clock = 3; }; 							

// Switch to danger distance
if(isNil "bcombat_danger_distance") then { bcombat_danger_distance = 250; };	

// Reveal threats faster
if(isNil "bcombat_allow_reveal") then { bcombat_allow_reveal = true; }; 	

// Fatigue
if(isNil "bcombat_allow_fatigue") then { bcombat_allow_fatigue = false; }; 		

// Return fire / cover other units (same group)
if(isNil "bcombat_allow_fire_back") then { bcombat_allow_fire_back = true; }; 				
if(isNil "bcombat_allow_fire_back_group") then { bcombat_allow_fire_back_group = true; }; 		
if(isNil "bcombat_fire_back_group_max_friend_distance") then { bcombat_fire_back_group_max_friend_distance = 250; }; 
if(isNil "bcombat_fire_back_group_max_enemy_distance") then { bcombat_fire_back_group_max_enemy_distance = 250; }; 

// Slow down leaders
if(isNil "bcombat_slow_leaders") then { bcombat_slow_leaders = false; }; 	

// Fast rotation
if(isNil "bcombat_allow_fast_rotate") then { bcombat_allow_fast_rotate = false; };		

// Fleeing
if(isNil "bcombat_allow_fleeing") then { bcombat_allow_fleeing = true; }; 	

// Minimum timeout between incoming bullets
if(isNil "bcombat_incoming_bullet_timeout") then { bcombat_incoming_bullet_timeout = 0.2; }; 	

// Minimum timeout for danger.fsm looping
if(isNil "bcombat_danger_fsm_timeout") then { bcombat_danger_fsm_timeout = 0.1; }; 
	

// Suppression-related params
if(isNil "bcombat_penalty_bullet") then { bcombat_penalty_bullet = 4; }; 		
if(isNil "bcombat_penalty_flanking") then { bcombat_penalty_flanking = 4; }; 
if(isNil "bcombat_penalty_scream") then { bcombat_penalty_scream = 0; }; 				
if(isNil "bcombat_penalty_enemy_unknown") then { bcombat_penalty_enemy_unknown = 4; };		
if(isNil "bcombat_penalty_enemy_contact") then { bcombat_penalty_enemy_contact = 25; }; 	
if(isNil "bcombat_penalty_enemy_close") then { bcombat_penalty_enemy_close = 0; };			
if(isNil "bcombat_penalty_casualty") then { bcombat_penalty_casualty = 20; }; 		
if(isNil "bcombat_penalty_wounded") then { bcombat_penalty_wounded = 10; };				
if(isNil "bcombat_penalty_explosion") then { bcombat_penalty_explosion = 4; };	
if(isNil "bcombat_penalty_safe_mode") then { bcombat_penalty_safe_mode = 35; };	
if(isNil "bcombat_penalty_recovery") then { bcombat_penalty_recovery = 2; };		

// Investigate
if(isNil "bcombat_allow_investigate") then { bcombat_allow_investigate = false; }; 		
if(isNil "bcombat_investigate_max_distance") then { bcombat_investigate_max_distance = 200; }; 		

// Move to cover
if(isNil "bcombat_allow_cover") then { bcombat_allow_cover = false; }; 
if(isNil "bcombat_cover_mode") then { bcombat_cover_mode = 0; }; 		
if(isNil "bcombat_cover_radius") then { bcombat_cover_radius = [15,0]; }; 	

// Hand grenades
if(isNil "bcombat_allow_grenades") then { bcombat_allow_grenades = false; }; 				
if(isNil "bcombat_grenades_additional_number") then { bcombat_grenades_additional_number = 0; };
if(isNil "bcombat_grenades_distance") then { bcombat_grenades_distance = [6,60,6]; }; 			
if(isNil "bcombat_grenades_no_los_only") then { bcombat_grenades_no_los_only = true; }; 			

// Smoke grenades
if(isNil "bcombat_allow_smoke_grenades") then { bcombat_allow_smoke_grenades = false; }; 				
if(isNil "bcombat_grenades_additional_number") then { bcombat_smoke_grenades_additional_number = 0; }; 	
if(isNil "bcombat_grenades_distance") then { bcombat_smoke_grenades_distance = [75,300,25]; }; 		

// Targeting / Chasing units in CQB
if(isNil "bcombat_allow_targeting") then { bcombat_allow_targeting = false; }; 			
if(isNil "bcombat_targeting_max_distance") then { bcombat_targeting_max_distance = [50,150]; }; 	

// Enhanced hearing
if(isNil "bcombat_allow_hearing") then { bcombat_allow_hearing = false; }; 		
if(isNil "bcombat_allow_hearing_grenade_distance") then { bcombat_allow_hearing_grenade_distance = 200; }; 	
if(isNil "bcombat_allow_hearing_coef") then { bcombat_allow_hearing_coef = 2; }; 	

// Surrender
if(isNil "bcombat_allow_surrender") then { bcombat_allow_surrender = false; };		

// Suppressive fire
if(isNil "bcombat_allow_suppressive_fire") then { bcombat_allow_suppressive_fire = false; };			
if(isNil "bcombat_suppressive_fire_duration") then { bcombat_suppressive_fire_duration = [0.2, 0.5]; };	
if(isNil "bcombat_suppressive_fire_distance") then { bcombat_suppressive_fire_distance = [50, 250]; };	

// Fast movement
if(isNil "bcombat_allow_fast_move") then { bcombat_allow_fast_move = false; };	

// Automatic formation fallback
if(isNil "bcombat_allow_tightened_formation") then { bcombat_allow_tightened_formation  = false; };			
if(isNil "bcombat_tightened_formation_max_distance") then { bcombat_tightened_formation_max_distance = 50; };	

// Cap friendly fire
if(isNil "bcombat_allow_friendly_capped_damage") then { bcombat_allow_friendly_capped_damage = false; }; 
if(isNil "bcombat_friendly_fire_max_damage") then { bcombat_friendly_fire_max_damage = 0.5; }; 				

// Stop / overwatch
if(isNil "bcombat_stop_overwatch") then { bcombat_stop_overwatch = false; }; 
if(isNil "bcombat_stop_overwatch_mode") then { bcombat_stop_overwatch_mode = 0; }; 
if(isNil "bcombat_stop_overwatch_max_distance") then { bcombat_stop_overwatch_max_distance = [100, 200]; }; 

// Fancy moves
if(isNil "bcombat_fancy_moves") then { bcombat_fancy_moves = false; }; 
if(isNil "bcombat_fancy_moves_frequency") then { bcombat_fancy_moves_frequency = 0; }; 

// Remove all night googles
if(isNil "bcombat_remove_nvgoggles") then { bcombat_remove_nvgoggles = false; }; 

// AI minimum skill if in player's group
if(isNil "bcombat_skill_min_player_group") then { bcombat_skill_min_player_group = 0; }; 

// Prone stance minimal distance
if(isNil "bcombat_stance_prone_min_distance") then { bcombat_stance_prone_min_distance = 25; }; 

// Skill multiplier (0-1) range
if(isNil "bcombat_skill_multiplier") then { bcombat_skill_multiplier = 1; }; 

// Skill linearity
if(isNil "bcombat_skill_linearity") then { bcombat_skill_linearity = 1; }; 


// -----------------------------
// Libs loading
// -----------------------------

if( !(bcombat_enable) ) exitWith{};
call compile preprocessFileLineNumbers "\@bcombat\bdetect.sqf"; 
call compile preprocessFileLineNumbers "\@bcombat\lib\common.sqf";  
call compile preprocessFileLineNumbers "\@bcombat\lib\suppression.sqf"; 
call compile preprocessFileLineNumbers "\@bcombat\lib\fsm.sqf";  
call compile preprocessFileLineNumbers "\@bcombat\lib\task.sqf";

_nil = [] spawn 
{
	// -----------------------------
	// bDetect init
	// -----------------------------

	bdetect_enable = true;
	bdetect_debug_enable = false;
	bdetect_debug_levels = [];		
	bdetect_debug_chat = true;			
	bdetect_mp_enable = false; 
	bdetect_degradation_distance = bcombat_degradation_distance;
	bdetect_callback = "bcombat_fnc_bullet_incoming";
	
	call bdetect_fnc_init;
	waitUntil { !(isNil "bdetect_init_done") };
	
	// -----------------------------
	// bCombat init
	// -----------------------------

	if( bcombat_debug_enable ) then {
		_msg = format["%1 v%2 has started", bcombat_short_name, bcombat_version];
		[ _msg, 0 ] call bcombat_fnc_debug;
	};
	
	if( bcombat_startup_hint ) then {
		_msg = format["%1 v%2 has started", bcombat_short_name, bcombat_version];
		hintSilent _msg;
	};
};

// -----------------------------
// LOOP
// -----------------------------

[] spawn
{
	sleep 1;
	bcombat_init_done = true; 

	while { true } do 
	{
		if( bcombat_enable ) then
		{
			{
				_unit = _x;
				
				if(  [_unit] call bcombat_fnc_is_active ) then 
				{
					if( isNil { _unit getvariable ["bcombat_init_done", nil ] } ) then 
					{
						_unit call bcombat_fnc_unit_initialize;
					};
					
					/*	if(  _unit ammo (currentweapon _unit) ==0) then { hintc format["%1 ... %2 ... %3", _unit, (currentweapon _unit), _unit ammo (currentweapon _unit)]; }; */
					
					_unit setskill [ "SpotDistance", ( _unit getVariable [ "bcombat_skill_sd", 0] )  * ( _unit call bcombat_fnc_visibility_multiplier ) ];
					
					if( behaviour (leader _unit) == "COMBAT" && speedMode (group _unit) != "FULL") then 
					{
						(group _unit) setSpeedMode "FULL";
					};
					
					if( bcombat_skill_min_player_group > 0 ) then
					{
						[_unit, bcombat_skill_min_player_group] call bcombat_fnc_set_min_group_skill;
					};
					
					if( 
						!(isPlayer _unit)  
						&& { !(fleeing _unit) } 
						&& { !(captive _unit) } 
						&& { _unit distance player < bcombat_degradation_distance }
					) then {
						// unstuck unit
						if( 
							canmove _unit
							&& [ _unit ] call bcombat_fnc_speed == 0 
							&& { !([_unit] call bcombat_fnc_is_stopped) }
							&& { !([_unit] call bcombat_fnc_has_task) }
							&& { _unit == formLeader _unit }
							&& { leader _unit == _unit || _unit distance (leader _unit) > 25 }
							&& { _unit distance ((expecteddestination _unit) select 0) < 2 && ((expecteddestination _unit) select 1) == "LEADER PLANNED" }
						) then {
						
//hintc("unstuck unit");
//player setpos (position _unit);
							
							_unit domove getPos _unit;
							_unit dofollow (leader _unit);
						};
						
						if( bcombat_allow_targeting 
							&& { !(isPlayer (leader _unit)) }							
								&& { canmove _unit }
								&& { canfire _unit }
								&& { unitready _unit }
								&& { _unit getVariable ["bcombat_suppression_level", 0] <= 25  } 
								&& { random 100 > _unit getVariable ["bcombat_suppression_level", 0] } 
								&& { damage _unit < 0.25 } 
								&& { !([_unit] call bcombat_fnc_has_task) }
						) then {
						
							// Chase target
							_target = assignedTarget _unit;
							_dist = _unit distance _target;
							
							if(!isNull _target
								&& { _dist  < (bcombat_targeting_max_distance select 0) || ( combatMode _unit == "RED" && _dist < (bcombat_targeting_max_distance select 1) ) } 
								&& { !([_unit, _target] call bcombat_fnc_is_visible) }
								&& { [_unit, _target] call bcombat_fnc_knprec < 10 }
								&& { [_unit, getPosATL _target] call bcombat_fnc_unit_can_inspect_pos }
							) then {
							
								//hintc format["-------> %1 chase %2", _unit, _target];
								_unit doTarget _target;
								_unit doWatch _target;
								_unit domove getPosATL _target;
								// player setpos (getpos _unit);
							};
						};
						
						_enemy = _unit findnearestEnemy _unit;
						
						// Avoid individually attacking in urban areas
						if( _unit == leader _unit) then
						{
							_unit call bcombat_fnc_blacklist_purge;
		
							if( !(fleeing _unit) ) then
							{
								if( !(isNull _enemy) 
									&& { _unit distance _enemy <= 250 } 
									&& { count (nearestObjects [_unit, ["house"], 50]) < 5 } 
								) then 
								{
									_unit enableAttack true;
								}
								else
								{
									_unit enableAttack false;
								};
							};
						};
						
						// CQB
						/* if( !(isNull _enemy) ) then { [ _unit, _enemy ] call bcombat_fnc_set_firemode; }; */

						if( !(isNull _enemy) 
							&& { bcombat_cqb_radar }
							&& { _unit distance _enemy < bcombat_cqb_radar_max_distance * 1.1}  	
							&& { random 1 <= (_unit skill "general" ) }
							&& { isNil { _unit getVariable ["bcombat_cqb_lock", nil] } }
							) then
						{
							_unit setVariable ["bcombat_cqb_lock", true];
							//hintc format["%1 CQB activated", _unit]; sleep .5;
							[_unit, bcombat_cqb_radar_clock, bcombat_cqb_radar_max_distance, bcombat_cqb_radar_params] spawn bcombat_fnc_cqb;
						};

						if( 
							bcombat_allow_fleeing
							&& { !(player in (units (group _unit))) }
							&& { !(fleeing _unit) }
						) then {
							[_unit] call bcombat_fnc_unit_handle_fleeing;
						}
						else
						{
							// _unit allowFleeing 0;
						};

						if( !([_unit] call bcombat_fnc_has_task) ) then 
						{
							_throw_grenade = false;
							
							if( bcombat_allow_grenades 
								&& { combatmode _unit in ["RED", "YELLOW"] }
								&& { !(isNull _enemy) } 
								&& { _unit distance _enemy < ( bcombat_grenades_distance select 1 ) }
								&& { "HandGrenade" in (magazines _unit) }
								&& { random 1 <= (_unit skill "general" ) ^ 0.5}
								&& { random 100 > (_unit getVariable ["bcombat_suppression_level", 0]) }
							) then {
								_throw_grenade = [_unit] call bcombat_fnc_handle_grenade;
								// player globalchat format["grenade check %1 - %2 %3", _unit distance _enemy, _unit, _enemy];
							};
							
							if( !(_throw_grenade) ) then 
							{
								if( bcombat_allow_fast_move || isPlayer (leader _unit) ) then //  && isPlayer (leader _unit) 
								{
									[_unit] call bcombat_fnc_fast_move;
								};

								if( bcombat_allow_tightened_formation ) then //  && isPlayer (leader _unit) 
								{
									[_unit] call bcombat_fnc_fall_into_formation;
								};
							}
						};
					};
				};

			} foreach allUnits;
		};
		
		//player globalchat format["-------> %1", time];
		
		sleep bcombat_features_clock;
	};
};