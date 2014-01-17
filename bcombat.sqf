// ----------------------------------------
// bcombat | combat framework
// ----------------------------------------
// Version: 0.16
// Date: 16/01/2014
// Author: Fabrizio_T 
// License: GNU/GPL
// ----------------------------------------

// IMPORTANT - DO NOT REMOVE the following line
if( !(isNil "bcombat") ) exitWith{}; bcombat = true; // avoid having multiple instances running

// -----------------------------
// Configuration
// -----------------------------

if(isNil "bcombat_enable") then { bcombat_enable = true; }; 	

bcombat_debug_enable = false;
bcombat_debug_levels = [1];//[1,6,8];
bcombat_debug_chat = true;

bcombat_name 		= "bcombat AI Infantry mod"; 
bcombat_short_name 	= "bcombat"; 
bcombat_version 	= "0.16";

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

// Lower ground penalty
if(isNil "bcombat_allow_lowerground_penalty") then { bcombat_allow_lowerground_penalty = true; }; 	

// Damage multiplier
if(isNil "bcombat_damage_multiplier") then { bcombat_damage_multiplier = 1; }; 	

// Units internal clock (for optional features)
if(isNil "bcombat_features_clock") then { bcombat_features_clock = [3,5]; }; 							

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
	
	bcombat_init_done = true; 
};
