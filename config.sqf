// -----------------------
// CORE bCombat FEATURES
// -----------------------

// Description: toggle bCombat on (true) or off (false)

bcombat_enable = true;								// (Boolean) Toggle feature on / off

// Description: minimum timeout since last incoming bullet, for the current one to cause suppression.
// As default no more than 5 ( = 1 / 0.2 ) bullets / second would cause suppression on a single AI unit.
// Please be careful tweaking bcombat_incoming_bullet_timeout. 
// Lowering it can cause CPU overhead as well as excessive suppression-related penalties.

bcombat_incoming_bullet_timeout = 0.2;				// (Seconds) minimum timeout between bullets
bcombat_danger_distance = 200; 						// (Meters) Minimum distance from shooter, for groups to automatically switch to "combat" behaviour
bcombat_features_clock = [3,6];						// (Seconds) Additional features clocking [minimum timeout, maximum timeout]
bcombat_damage_multiplier = 1;						// (0-1) Damage multiplier. Zero makes units invulnerable.

// -----------------------
// CORE bDetect FEATURES
// -----------------------

bdetect_bullet_max_distance = 750;  				// (Meters) Maximum travelled distance for a bullet (to cause suppression)
bdetect_bullet_max_lifespan = 2; 					// (Seconds) Maximum lifespan for bullet
bdetect_bullet_max_proximity = 6.5; 				// (Meters) Maximum distance from unit for bullet (to cause suppression)
bdetect_bullet_max_height =  6.5;  					// (Meters) Maximum height on ground for bullet (to cause suppression)

// -----------------------------------------------------------------------------------------------------
// bCombat SUPPRESSION CONFIGURATION
// -----------------------------------------------------------------------------------------------------

// Description: Bullet penalty
// Triggered: whenever under fire and a close bullet is intercepted
// Effect: Up to 5% of skill penalty is applied

bcombat_penalty_bullet = 5; 						// (Percent) %

// Description: Flanking penalty
// Triggered: whenever under fire and shooter is firing from flank / back, 
// Effect: Adds up to 5% further skill penalty 

bcombat_penalty_flanking = 5; 						// (Percent) %

// Description: Enemy unknown penalty
// Adds further penalty to bcombat_penalty_bullet
// Triggered: whenever under fire, if shooter is unknown 
// Effect: Adds up to 5% further skill penalty

bcombat_penalty_enemy_unknown = 5; 					// (Percent) %

// Description: Enemy contact penalty
// Triggered: on first enemy contact or on further contact after area clear
// Effect: up to 30% skill penalty, due to combat stress

bcombat_penalty_enemy_contact = 25; 				// (Percent) %

// Description: Explosion / ricochet penalty
// Triggered: on shell exploding nearby, or close ricochet
// Effect: up to 5% skill penalty

bcombat_penalty_explosion = 5;						// (Percent) %

// Description: Casualty penalty
// Triggered: when a dead unit from same group is discovered
// Effect: up to 15% skill penalty

bcombat_penalty_casualty = 15; 						// (Percent) %

// Description: wounds  penalty
// Triggered: when a unit gets wounded
// Effect: up to 10% skill penalty

bcombat_penalty_wounded = 10; 						// (Percent) %

// Description: penalty recovery rate
// Triggered: once per second, if no penalty raising events have been triggered
// Effect: up to 2% skill recovery, halved if unit is wounded

bcombat_penalty_recovery = 3; 						// (Percent) %

// -----------------------------------------------------------------------------------------------------
// bCombat OPTIONAL FEATURES CONFIGURATION
// -----------------------------------------------------------------------------------------------------

// Description: fast movement
// Triggered: if active and destination is at medium distance (50-500m.)
// Effect: formation is breaked, units move individually towards destination picking different routes and using cover
// Known issues: units may sometimes bunch at destination

bcombat_allow_fast_move = false;					// (Boolean) Toggle feature on / off

// Description: fast rotation
// Triggered: if a known target is on flank / back
// Effect: depending on stance, unit swivels faster towards target
// Known issues: sometimes rotation "animation" is a bit rough
// NOTE: Deprecated as of v0.15 - please keep it set to false

bcombat_allow_fast_rotate = false;					// (Boolean) Toggle feature on / off

// Description: custom fleeing behaviour
// Triggered: when morale is broken
// Effect: unit leaves formation and moves away. As long as group is not destroyed it will join it back after some morale recovery.

bcombat_allow_fleeing = true; 						// (Boolean) Toggle feature on / off

// Description: surrender behaviour
// Triggered: seldom, when morale is broken and fleeing
// Effect: unit plays a surrender animation and gets locked there as captive
// Note: needs bcombat_allow_fleeing = true

bcombat_allow_surrender = true;						// (Boolean) Toggle feature on / off

// Description: slow down leader
// Triggered: whenever a target of opportunity is spotted, or under fire
// Effect: leader stops to shoot, further observe or to return fire
// NOTE: Deprecated as of v0.14 - please keep it set to false

bcombat_slow_leaders = false;						// (Boolean) Toggle feature on / off

// Description: return fire on shooter
// Triggered: if unit is under fire and has line of sight on shooter
// Effect: return fire on shooter. Unit may blind fire as long as bcombat_allow_suppressive_fire = true

bcombat_allow_fire_back = true; 					// (Boolean) Toggle feature on / off

// Description: return fire onto enemy threatening another unit from same group
// Triggered: when a close unit (same group) comes under fire
// Effect: return fire on shooter. Unit may blind fire as long as bcombat_allow_suppressive_fire = true

bcombat_allow_fire_back_group = true; 				// (Boolean) Toggle feature on / off
bcombat_fire_back_group_max_enemy_distance = 250; 	// (Number) Maximum distance (meters) of the threatening enemy
bcombat_fire_back_group_max_friend_distance = 250; 	// (Number) Maximum distance (meters) of the friendly unit being threatened

// Description: suppressive fire / blind fire
// Triggered: when unit has no clean line of sight on known enemy.
// Effect: units bursts fire towards enemy perceived position, eventually through soft cover .
// Known issues (tied to "suppressFor" scripting command problems / limitations): 
// * much inaccurate at short distance 
// * unit may fire through thick objects

bcombat_allow_suppressive_fire = true;				// (Boolean) Toggle feature on / off
bcombat_suppressive_fire_duration = [0.1, 0.2]; 	// (Array) [seconds of suppressive fire for common unit, seconds of suppressive fire for for autorifleman/machinegunner]
bcombat_suppressive_fire_distance = [50, 250]; 		// (Array) [minimum distance from target, maximum distance from target]

// Description: enhanced hearing
// Triggered: whenever some nearby explosion / gunshot is heard
// Effect: unit is hinted about the shooter, depending on criteria such as visibility and distance. 

bcombat_allow_hearing = true;						// (Boolean) Toggle feature on / off
bcombat_allow_hearing_coef = 2;						// (Number) Bullet speed / bcombat_allow_hearing_coef = max. hearing distance (e.g. 800 meters/sec : 2 = max. hearing distance 400m.)
bcombat_allow_hearing_grenade_distance = 200;		// (Meters) Max. distance for grenade hearing

// Description: CQB hand grenade throwing
// Triggered: whenever unit has a hand grenade + enemy is known and near
// Effect: a grenade is thrown
// Known issues: possible frendly fire issues

bcombat_allow_grenades = true;						// (Boolean) Toggle feature on / off
bcombat_grenades_additional_number = 0; 			// (Number) number of additional grenades to be automatically ADDED to unit loadout
bcombat_grenades_distance = [6,45,6]; 				// (Array) [ minimum distance, maximum distance, min. distance from target for friendly units] 
bcombat_grenades_timeout = [10, 5];					// (Array) [ unit timeout, group timeout ]
bcombat_grenades_no_los_only = true; 				// (Boolean) Whether enemy should be out of line-of-sight, for a unit to throw grenade

// Description: smoke grenade throwing
// Triggered: whenever unit get under fire while moving slow, or if unit is leader or formation leader
// Effect: a smoke grenade is thrown

bcombat_allow_smoke_grenades = true;					// (Boolean) Toggle feature on / off
bcombat_smoke_grenades_additional_number = 1; 			// (Number) number of additional smoke grenades to be automatically ADDED to unit loadou
bcombat_smoke_grenades_distance = [75,300,25]; 			// (Array) [ minimum distance, maximum distance, min. distance from target for friendly units] 
bcombat_smoke_grenades_timeout = [15, 5];				// (Array) [ unit timeout, group timeout ]

// Description: investigation behavoiur
// Triggered: if no enemy is known and some explosion / gunshot is heard, or another unit from same group gets killed
// Effect: unit may move to event position
// Note: needs bcombat_allow_hearing = true

bcombat_allow_investigate = true;					// (Boolean) Toggle feature on / off
bcombat_investigate_max_distance = 250;				// (Number) maximum distance from unit, for position to be investigated
	
// Description: allow fatigue
// Effect: allows for vanilla fatigue effects

bcombat_allow_fatigue = false;						// (Boolean) Toggle feature on / off

// Description: evasive movement to (nearby) cover
// Triggered: whenever under fire and enemy is in line of sight or unit is close to roads
// Effect: unit moves towards some nearby object / building to get some cover
// Known issues: this behaviour is known to be overriden by vanilla AI under some circumstances

bcombat_allow_cover = true;							// (Boolean) Toggle feature on / off
bcombat_cover_mode = 1;								// (0,1) 0 = apply only to leader, 1 = apply to all units
bcombat_cover_radius = [15,0]; 					// (Array) [ maximum distance from object, maximum distance from building] 

// Description: "target and chase" behaviour
// Triggered: whenever unit has no target and it's close to a enemy
// Effect: unit locks enemy as target moves towards its position

bcombat_allow_targeting = true;						// (Boolean) Toggle feature on / off
bcombat_targeting_max_distance = [50, 150];			// (Array) [ maximum distance, maximum distance if combatMode is "RED"] 

// Description: tighten formation
// Triggered: whenever some in-formation unit falls behind
// Effect: unit is automatically ordered to fall back into formation
// Known issues: for player led groups thightened formation is breaking the ADVANCE command

bcombat_allow_tightened_formation = true;			// (Boolean) Toggle feature on / off
bcombat_tightened_formation_max_distance = 50;		// (Meters) Maximum distance a unit can go off formation before being ordered to fall back

// Description: friendly fire damage cap
// Triggered: whenever unit is hit by a friendly unit (player excluded)
// Effect: limit max. damage to 0-1( 1 = no limit)

bcombat_allow_friendly_capped_damage = true;  		// (Boolean) Toggle feature on / off
bcombat_friendly_fire_max_damage = 0.8;				// (0-1) damage cap ( 0 = allow no damage )

// Description: stop / overwatch
// Triggered: on unit following leader or formation leader
// Effect: unit is allowed to provide prolonged suppressive fire, while rest of formation moves on

bcombat_stop_overwatch = true;    					// (Boolean) Toggle feature on / off
bcombat_stop_overwatch_mode = 0;    				// (0,1) 0 = apply only to machinegunners, 1 = apply to all units 
bcombat_stop_overwatch_max_distance	= [100, 200];	// (Array) [max distance from leader to begin overwatch, max distance from leader to (force) end overwatch] 

// Description: CQB awareness imporvements
// Triggered: on short distance
// Effect: depending on skill, unit is made more aware of nearby known threats
// NOTE: this feature may cause sensible computational overhead. Set options wisely.

bcombat_cqb_radar = true;    						// (Boolean) Toggle feature on / off
bcombat_cqb_radar_clock = [0.5, 2];    				// (Seconds) internal feaures clocking. Never use values below 0.1 ( = 10 times / second).
bcombat_cqb_radar_max_distance = 100;    			// (Meters) Features are activated under this distance
bcombat_cqb_radar_params = [95, 5, 0, 5];			// (Array) [max. angle, min. precision, min. knowsabout, max enemy .speed] - Don't edit this.

// Description: misc animations as a tribute to "tonyRanger"
// Triggered: seldom, when under fire
// Effect: a prone rolling animation is played to evade enemy fire

bcombat_fancy_moves = true;     					// (Boolean) Toggle feature on / off
bcombat_fancy_moves_frequency = 0.1;    			// (0-1) Probability of occurring. 0=never (0%), 1=all the time (100%). 

// -----------------------------------------------------------------------------------------------------
// bCombat MISC CALLS
// -----------------------------------------------------------------------------------------------------

//[] spawn bcombat_fnc_debug_text; // Uncomment this line to activare bCombat debug text overlays (as alternative to bcombat_fnc_debug_balloons or bcombat_fnc_fps)
call bcombat_fnc_debug_balloons; // Uncomment this line to activare bCombat debug balloons (as alternative to bcombat_fnc_debug_text or bcombat_fnc_fps)

call bdetect_fnc_benchmark; // Uncomment this line to activate bDetect live stats panel (as alternative to bcombat_fnc_fps)
// [] spawn bcombat_fnc_fps; // Uncomment this line to activate FPS stats panel (as alternative to bdetect_fnc_benchmark;)

OnMapSingleClick "player setpos _pos"; // Uncomment this line to make player able to instantly move to any position by single clicking the map
player allowdamage false;
player setcaptive true;

// bdetect_startup_hint = false;
// bcombat_startup_hint = false;
