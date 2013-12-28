// ----------------------------------------
// bcombat | combat framework
// ----------------------------------------
// Version: 0.15
// Date: 23/12/2013
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

bcombat_name 		= "bcombat | AI Combat mod"; 
bcombat_short_name 	= "bcombat"; 
bcombat_version 	= "0.15";

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

// Debug
if(isNil "bcombat_startup_hint") then { bcombat_startup_hint = true; }; 									// toggle to Enable / Disable bDetect startup Hint.
if(isNil "bcombat_debug_enable") then { bcombat_debug_enable = false; }; 									// toggle to Enable / Disable debug messages.
if(isNil "bcombat_debug_chat") then { bcombat_debug_chat = false; }; 										// show debug messages also in globalChat.
if(isNil "bcombat_debug_levels") then { bcombat_debug_levels = [0,1,2,3,4,5,6,7,8,9]; }; 					// filter debug messages by included levels. 

// Activate only sides / groups / units 
if(isNil "bcombat_allowed_sides") then { bcombat_allowed_sides = []; };										// Alpha feature please don't change
if(isNil "bcombat_allowed_groups") then { bcombat_allowed_groups = []; };									// Alpha feature please don't change 
if(isNil "bcombat_allowed_units") then { bcombat_allowed_units = []; };										// Alpha feature please don't change 

// Units internal clock (for optional features)
if(isNil "bcombat_unit_clock") then { bcombat_unit_clock = [3,6]; }; 										// 

// Switch to danger distance
if(isNil "bcombat_danger_distance") then { bcombat_danger_distance = 250; };								// Minimum distance from shooter for groups switching to "combat" behaviour

// Reveal threats faster
if(isNil "bcombat_allow_reveal") then { bcombat_allow_reveal = true; }; 									// true = allow enhanced revealing of enemy upon event (please don't disable this)

// Fatigue
if(isNil "bcombat_allow_fatigue") then { bcombat_allow_fatigue = false; }; 									// true =  enable fatigue

// Return fire / cover other units (same group)
if(isNil "bcombat_allow_fire_back") then { bcombat_allow_fire_back = true; }; 								// true = units fire back when under fire
if(isNil "bcombat_allow_fire_back_group") then { bcombat_allow_fire_back_group = true; }; 					// true = units fire back when other units (same group) are under fire
if(isNil "bcombat_fire_back_group_max_friend_distance") then { bcombat_fire_back_group_max_friend_distance = 250; }; 
if(isNil "bcombat_fire_back_group_max_enemy_distance") then { bcombat_fire_back_group_max_enemy_distance = 250; }; 

// Slow down leaders
if(isNil "bcombat_slow_leaders") then { bcombat_slow_leaders = false; }; 									// true =  make group leaders stop often to open fire (as in vanilla ArmA3)

// Fast rotation
if(isNil "bcombat_allow_fast_rotate") then { bcombat_allow_fast_rotate = true; };							// true = allow acceleration of unit rotation speed. Good for prone stance, when fired from flanks / back

// Fleeing
if(isNil "bcombat_allow_fleeing") then { bcombat_allow_fleeing = true; }; 									// true = allow custom fleeing

// Minimum timeout between incoming bullets
if(isNil "bcombat_incoming_bullet_timeout") then { bcombat_incoming_bullet_timeout = 0.2; }; 		

// Suppression-related params
if(isNil "bcombat_penalty_bullet") then { bcombat_penalty_bullet = 4; }; 									// max relative % of unit skill loss
if(isNil "bcombat_penalty_flanking") then { bcombat_penalty_flanking = 4; }; 								// max relative % of unit skill loss - adding to bcombat_penalty_bullet!
if(isNil "bcombat_penalty_scream") then { bcombat_penalty_scream = 0; }; 									// max relative % of unit skill loss
if(isNil "bcombat_penalty_enemy_unknown") then { bcombat_penalty_enemy_unknown = 4; };						// max relative % of unit skill loss - adding to bcombat_penalty_bullet!
if(isNil "bcombat_penalty_enemy_contact") then { bcombat_penalty_enemy_contact = 25; }; 					// max relative % of unit skill loss
if(isNil "bcombat_penalty_enemy_close") then { bcombat_penalty_enemy_close = 0; };							// max relative % of unit skill loss
if(isNil "bcombat_penalty_casualty") then { bcombat_penalty_casualty = 20; }; 								// max relative % of unit skill loss
if(isNil "bcombat_penalty_wounded") then { bcombat_penalty_wounded = 10; };									// max relative % of unit skill loss
if(isNil "bcombat_penalty_explosion") then { bcombat_penalty_explosion = 4; };								// max relative % of unit skill loss
if(isNil "bcombat_penalty_recovery") then { bcombat_penalty_recovery = 2; };								// max relative % of unit skill loss

// Investigate
if(isNil "bcombat_allow_investigate") then { bcombat_allow_investigate = false; }; 							//  true =  enable investigations for close explosions, corpses (same group)
if(isNil "bcombat_investigate_max_distance") then { bcombat_investigate_max_distance = 200; }; 				// investigation max. distance

// Move to cover
if(isNil "bcombat_allow_cover") then { bcombat_allow_cover = false; }; 										// true = unit move to custom cover
if(isNil "bcombat_cover_mode") then { bcombat_cover_mode = 0; }; 											// 0 = only leader; 1 = all units
if(isNil "bcombat_cover_radius") then { bcombat_cover_radius = [15,35]; }; 									// [radius for objects, radius for buildings]

// Hand grenades
if(isNil "bcombat_allow_grenades") then { bcombat_allow_grenades = false; }; 								// true = custom grenade throwing for CQB
if(isNil "bcombat_grenades_additional_number") then { bcombat_grenades_additional_number = 0; }; 			// number of additional grenades to be automatically added to any units
if(isNil "bcombat_grenades_distance") then { bcombat_grenades_distance = [6,60,6]; }; 						// [min. distance, max. distance]
if(isNil "bcombat_grenades_no_los_only") then { bcombat_grenades_no_los_only = true; }; 					// whether enemy should be out of line-of-sight

// Smoke grenades
if(isNil "bcombat_allow_smoke_grenades") then { bcombat_allow_smoke_grenades = false; }; 					// true = custom smoke grenade throwing
if(isNil "bcombat_grenades_additional_number") then { bcombat_smoke_grenades_additional_number = 0; }; 		// number of additional smoke grenades to be automatically added to any units
if(isNil "bcombat_grenades_distance") then { bcombat_smoke_grenades_distance = [75,300,25]; }; 					// [min. distance, max. distance]

// Targeting / Chasing units in CQB
if(isNil "bcombat_allow_targeting") then { bcombat_allow_targeting = false; }; 								// true = allow automating chasing / targeting of close units
if(isNil "bcombat_targeting_max_distance") then { bcombat_targeting_max_distance = [50,150]; }; 			// [Max. Distance, Max. Distance for RED combat mode]

// Enhanced hearing
if(isNil "bcombat_allow_hearing") then { bcombat_allow_hearing = false; }; 									// true = allow hearing of light weapons sound across distance, NEEDS "bcombat_allow_reveal = true"

// Surrender
if(isNil "bcombat_allow_surrender") then { bcombat_allow_surrender = false; };								// true = allow surrendering ( unit plays animation and stays there, weapons are dropped)

// Suppressive fire
if(isNil "bcombat_allow_suppressive_fire") then { bcombat_allow_suppressive_fire = false; };				// true = allow units to do blind suppression fire 
if(isNil "bcombat_suppressive_fire_duration") then { bcombat_suppressive_fire_duration = [0.2, 0.5]; };	// [secs. for unit, sec. for machinegunner]
if(isNil "bcombat_suppressive_fire_distance") then { bcombat_suppressive_fire_distance = [50, 250]; };		// [min.distance, max. distance]

// Fast movement
if(isNil "bcombat_allow_fast_move") then { bcombat_allow_fast_move = false; };								// true = allow storming move. Units move individually towards destination, ignoring formation

// Automatic formation fallback
if(isNil "bcombat_allow_tightened_formation") then { bcombat_allow_tightened_formation  = false; };			// true = allow forcing distant units to fall into formation
if(isNil "bcombat_tightened_formation_max_distance") then { bcombat_tightened_formation_max_distance = 50; };	//

// Cap friendly fire
if(isNil "bcombat_allow_friendly_capped_damage") then { bcombat_allow_friendly_capped_damage = false; }; 	// true = allow damage cap for friendly fire
if(isNil "bcombat_friendly_fire_max_damage") then { bcombat_friendly_fire_max_damage = 0.5; }; 				// damage cap for frendly fire

// Stop / overwatch
if(isNil "bcombat_stop_overwatch") then { bcombat_stop_overwatch = false; }; 
if(isNil "bcombat_stop_overwatch_mode") then { bcombat_stop_overwatch_mode = 0; }; 

// Fanncy moves
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
