// -------------------------------------------------------------------------------------------
// bDetect | bullet detection framework
// -------------------------------------------------------------------------------------------
// Version: 0.81 BETA
// Date: 28/10/2013
// Author: Fabrizio_T, Ollem (MP code)
// Additional code: TPW
// File Name: bdetect.sqf
// License: GNU/GPL
// -------------------------------------------------------------------------------------------
// BEGINNING OF FRAMEWORK CODE
// -------------------------------------------------------------------------------------------

// -------------------------------------------------------------------------------------------
// Constants
// -------------------------------------------------------------------------------------------

bdetect_name 		= "bDetect | Bullet Detection Framework"; 
bdetect_name_short 	= "bDetect"; 
bdetect_version 	= "0.81 BETA";
	
// -------------------------------------------------------------------------------------------
// Global variables
// -------------------------------------------------------------------------------------------

// You should set these variables elsewhere, don't edit them here since they're default. 
// See bottom of this file for framework initialization example.
if(isNil "bdetect_enable") then { bdetect_enable = true; }; 													// (Boolean, Default true) Toggle to Enable / Disable bdetect altogether.
if(isNil "bdetect_startup_hint") then { bdetect_startup_hint = true; }; 										// (Boolean, Default true) Toggle to Enable / Disable bDetect startup Hint.
if(isNil "bdetect_debug_enable") then { bdetect_debug_enable = false; }; 										// (Boolean, Default false) Toggle to Enable / Disable debug messages.
if(isNil "bdetect_debug_chat") then { bdetect_debug_chat = false; }; 											// (Boolean, Default false) Show debug messages also in globalChat.
if(isNil "bdetect_debug_levels") then { bdetect_debug_levels = [0,1,2,3,4,5,6,7,8,9]; }; 						// (Array, Default [0,1,2,3,4,5,6,7,8,9]) Filter debug messages by included levels. 
if(isNil "bdetect_callback") then { bdetect_callback = "bdetect_fnc_callback"; }; 								// (String, Default "bdetect_fnc_callback") Name for your own callback function
if(isNil "bdetect_callback_mode") then { bdetect_callback_mode = "spawn"; }; 									// (String, Default "spawn") Allowed values: "call" or "spawn"
if(isNil "bdetect_fps_adaptation") then { bdetect_fps_adaptation = true; }; 									// (Boolean, Default true) Whether bDetect should try to keep over "bdetect_fps_min" FPS while degrading quality of detection
if(isNil "bdetect_fps_min") then { bdetect_fps_min = 15; }; 													// (Number, Default 20) The minimum FPS you wish to keep
if(isNil "bdetect_fps_calc_each_x_frames") then { bdetect_fps_calc_each_x_frames = 16; }; 						// (Number, Default 16) FPS check is done each "bdetect_fps_min" frames. 1 means each frame.
if(isNil "bdetect_eh_assign_cycle_wait") then { bdetect_eh_assign_cycle_wait = 10; }; 							// (Seconds, Default 10). Wait duration foreach cyclic execution of bdetect_fnc_eh_loop()
if(isNil "bdetect_bullet_min_delay") then { bdetect_bullet_min_delay = 0.1; }; 									// (Seconds, Default 0.1) Minimum time between 2 consecutive shots fired by an unit for the last bullet to be tracked. Very low values may cause lag.
if(isNil "bdetect_bullet_max_delay") then { bdetect_bullet_max_delay = 2; }; 									// (Seconds, Default 2)
if(isNil "bdetect_bullet_initial_min_speed") then { bdetect_bullet_initial_min_speed = 360; }; 					// (Meters/Second, Default 360) Bullets slower than this are ignored.
if(isNil "bdetect_bullet_max_proximity") then { bdetect_bullet_max_proximity = 6; }; 							// (Meters, Default 10) Maximum proximity to unit for triggering detection
if(isNil "bdetect_bullet_min_distance") then { bdetect_bullet_min_distance = 20; }; 							// (Meters, Default 25) Bullets having travelled less than this distance are ignored
if(isNil "bdetect_bullet_max_distance") then { bdetect_bullet_max_distance = 750; }; 							// (Meters, Default 500) Bullets havin travelled more than distance are ignored
if(isNil "bdetect_bullet_max_lifespan") then { bdetect_bullet_max_lifespan = 2; }; 								// (Seconds, Default 0.7) Bullets living more than these seconds are ignored
if(isNil "bdetect_bullet_max_height") then { bdetect_bullet_max_height = 6; }; 									// (Meters, Default 8)  Bullets going higher than this -and- diverging from ground are ignored
if(isNil "bdetect_bullet_skip_mags") then { bdetect_bullet_skip_mags = []; }; 									// (Array) Skip these bullet types altogether. Example: ["30rnd_9x19_MP5", "30rnd_9x19_MP5SD", "15Rnd_9x19_M9"]
if(isNil "bdetect_mp_enable") then { bdetect_mp_enable = true; }; 												// (Boolean, Default true) Toggle to Enable / Disable MP experimental support
if(isNil "bdetect_mp_use_onEachFrame") then { bdetect_mp_use_onEachFrame = false; }; 							// (Boolean, Default true) Pre-frame Detection using "onEachFrame" scripting command, avalilable since ArmA 2 OA 1.62.98866
if(isNil "bdetect_mp_per_frame_emulation") then { bdetect_mp_per_frame_emulation = false; }; 					// (Boolean, Default false) Toggle to Enable / Disable experimental server per-frame-execution emulation
if(isNil "bdetect_mp_per_frame_emulation_frame_d") then { bdetect_mp_per_frame_emulation_frame_d = 0.02; };  	// (Seconds, Default 0.02) Experimental server per-frame-execution emulation timeout
if(isNil "bdetect_units_kindof") then { bdetect_units_kindof = ["CaManBase"]; }; 								// CfgVehicles classes being subject to suppression effects, example: ["Man","StaticWeapon","Car","Tank","Air"]

// Please NEVER edit the variables below.
if(isNil "bdetect_fired_bullets") then { bdetect_fired_bullets = []; };
if(isNil "bdetect_fired_bullets_count") then { bdetect_fired_bullets_count = 0; };
if(isNil "bdetect_fired_bullets_count_west") then { bdetect_fired_bullets_count_west = 0; };
if(isNil "bdetect_fired_bullets_count_east") then { bdetect_fired_bullets_count_east = 0; };
if(isNil "bdetect_fired_bullets_count_tracked") then { bdetect_fired_bullets_count_tracked = 0; };
if(isNil "bdetect_fired_bullets_count_detected") then { bdetect_fired_bullets_count_detected = 0; };
if(isNil "bdetect_fired_bullets_count_blacklisted") then { bdetect_fired_bullets_count_blacklisted = 0; };	
if(isNil "bdetect_units_count") then { bdetect_units_count = 0; };
if(isNil "bdetect_units_count_killed") then { bdetect_units_count_killed = 0; };
if(isNil "bdetect_fps") then { bdetect_fps = bdetect_fps_min; };
if(isNil "bdetect_bullet_delay") then { bdetect_bullet_delay = bdetect_bullet_min_delay; };
if(isNil "bdetect_frame_tstamp") then { bdetect_frame_tstamp = 0; };
if(isNil "bdetect_frame_min_duration") then { bdetect_frame_min_duration = 0.015; };	// 60fps

// -------------------------------------------------------------------------------------------
// Functions
// -------------------------------------------------------------------------------------------

bdetect_fnc_per_frame_emulation = 
{
    private ["_fnc", "_msg"];   

	if( bdetect_debug_enable ) then {
		_msg = format["bdetect_fnc_per_frame_emulation() has started"];
		[ _msg, 8 ] call bdetect_fnc_debug;
	};
		
    while { true } do {
	
        call bdetect_fnc_detect;
        sleep bdetect_mp_per_frame_emulation_frame_d;
    };
};

bdetect_fnc_init = 
{
    private [ "_msg", "_nul" ];

	if( bdetect_debug_enable ) then {
		_msg = format["%1 v%2 is starting ...", bdetect_name_short, bdetect_version];
		[ _msg, 0 ] call bdetect_fnc_debug;
	};

	// bullet speed converted to kmh
	bdetect_bullet_initial_min_speed = bdetect_bullet_initial_min_speed * 3.6;

	// Add per-frame execution of time-critical function
	if( bdetect_mp_enable && bdetect_mp_per_frame_emulation ) then {  // emulated, per-timeout (MP)	
		_nul = [] spawn bdetect_fnc_per_frame_emulation;
	} 
	else 
	{ 
		// native per-frame (SP)
		if(bdetect_mp_use_onEachFrame) then
		{
			onEachFrame { call bdetect_fnc_detect; };
		}
		else
		{
			[bdetect_fnc_detect,0] call cba_fnc_addPerFrameHandler;   
		};
	};
	
	// Assign event handlers to any units (even spawned ones)
	bdetect_spawned_loop_handler = [] spawn bdetect_fnc_eh_loop;   
};

// Keep searching units for newly spawned ones and assign fired EH to them
bdetect_fnc_eh_loop =
{
	private [ "_x", "_msg"];

	while { true } do // iteratively add EH to all units spawned at runtime
	{
		{ [_x] call bdetect_fnc_eh_add; } foreach allUnits;	// Loop onto all units
			
		if( isNil "bdetect_init_done" ) then 
		{ 
			bdetect_init_done = true; 
			
			if( bdetect_debug_enable ) then {
				_msg = format["%1 v%2 has started", bdetect_name_short, bdetect_version];
				[ _msg, 0 ] call bdetect_fnc_debug;
			};
			
			if( bdetect_startup_hint ) then {
				_msg = format["%1 v%2 has started", bdetect_name_short, bdetect_version];
				hint _msg;
			};
		};
		
		sleep bdetect_eh_assign_cycle_wait;
	};
};

bdetect_fnc_eh_add =
{
    private ["_unit", "_vehicle", "_e", "_msg"];
	
    _unit = _this select 0;
    _vehicle = assignedVehicle _unit;
    if( isNull _vehicle && _unit != vehicle _unit ) then { _vehicle =  vehicle _unit };

	if(  ( isNil { _unit getVariable "bdetect_fired_eh" }))  then
    {
        _e = _unit addEventHandler ["Fired", bdetect_fnc_fired];
        _unit setVariable ["bdetect_fired_eh", _e]; 
        
        _e = _unit addEventHandler ["Killed", bdetect_fnc_killed];
        _unit setVariable ["bdetect_killed_eh", _e]; 
     		
        bdetect_units_count = bdetect_units_count + 1;
        
		if( bdetect_debug_enable ) then {
			_msg = format["bdetect_fnc_eh_add() - unit=%1, FIRED + KILLED EH assigned ", _unit];
			[ _msg, 3 ] call bdetect_fnc_debug;    
		};
    };
	
    // handling vehicles
    if( 
		!( isNull _vehicle ) 
		&& isNil { _vehicle getVariable "bdetect_fired_eh" } 
	) then {  
		
		_e = _vehicle addEventHandler ["Fired", bdetect_fnc_fired];  
		_vehicle setVariable ["bdetect_fired_eh", _e]; 
		
		_e = _vehicle addEventHandler ["Killed", bdetect_fnc_killed];        
		_vehicle setVariable ["bdetect_killed_eh", _e]; 

		bdetect_units_count = bdetect_units_count + 1;            
		
		if( bdetect_debug_enable ) then {
			_msg = format["bdetect_fnc_eh_add() - vehicle=%1, FIRED + KILLED EH assigned", _vehicle];
			[ _msg, 3 ] call bdetect_fnc_debug;    
		};
    };
};

// Killed EH payload
bdetect_fnc_killed =
{
	private ["_unit", "_killer", "_e", "_msg"];
	
	_unit = _this select 0;
	_killer = _this select 1;
		
	// Remove FIRED EH
	if( !isNil{ _unit getVariable "bdetect_fired_eh" } ) then
	{
		_e = _unit getVariable "bdetect_fired_eh";
		_unit removeEventHandler ["fired", _e];
		_unit setVariable ["bdetect_fired_eh", nil];

		if( bdetect_debug_enable ) then {
			_msg = format["bdetect_fnc_killed() - unit=%1, FIRED EH unassigned", _unit];
			[ _msg, 3 ] call bdetect_fnc_debug;    
		};
	};
	
	// Remove (local) KILLED EH
	if( !isNil{ _unit getVariable "bdetect_killed_eh" } ) then
	{
		//_e = _unit getVariable "bdetect_killed_eh";
		//_unit removeEventHandler ["Killed", _e];// bug: in ArmA2 1.61  beta removing this cause all others killed EH to be removed?
		
		_unit setVariable ["bdetect_killed_eh", nil];

		if( bdetect_debug_enable ) then {
			_msg = format["bdetect_fnc_killed() - unit=%1, KILLED EH unassigned", _unit];
			[ _msg, 3 ] call bdetect_fnc_debug;    
		};
	};
	
	bdetect_units_count_killed = bdetect_units_count_killed + 1;
};

// Fired EH payload
bdetect_fnc_fired =
{
 	private ["_unit", "_weapon", "_muzzle", "_magazine", "_bullet", "_speed", "_msg", "_time", "_dt"];

	if( bdetect_enable ) then
	{
		_unit = _this select 0;
		_weapon = _this select 1;
		_muzzle = _this select 2;
		_mode = _this select 3;
		_ammo = _this select 4;
		_magazine = _this select 5;
		_bullet = _this select 6;
		_speed = speed _bullet;
		_time = time; //diag_tickTime
		_dt = _time - ( _unit getVariable ["bdetect_fired_time", 0] );
		
		bdetect_fired_bullets_count = bdetect_fired_bullets_count + 1;
	
		if( ( side _unit ) getFriend WEST >= .6 ) then {
			bdetect_fired_bullets_count_west = bdetect_fired_bullets_count_west + 1;
		} else {
			bdetect_fired_bullets_count_east = bdetect_fired_bullets_count_east + 1;
		};
		
		if( _dt > bdetect_bullet_delay 
		&& !( _magazine in bdetect_bullet_skip_mags ) 
		&& _speed > bdetect_bullet_initial_min_speed ) then {
			
			_unit setVariable ["bdetect_fired_time", _time]; 
			
			// Append info to bullets array
			[ _bullet, _unit, _time ] call bdetect_fnc_bullet_add;
			
			bdetect_fired_bullets_count_tracked = bdetect_fired_bullets_count_tracked + 1;
			
			if( bdetect_debug_enable ) then {
				_msg = format["bdetect_fnc_fired() - Tracking: bullet=%1, shooter=%2, speed=%3, type=%4, _dt=%5", _bullet, _unit, _speed, typeOf _bullet, _dt ];
				[ _msg, 2 ] call bdetect_fnc_debug;
			};
		}
		else
		{
			if( bdetect_debug_enable ) then {
				_msg = format["bdetect_fnc_fired() - Skipping: bullet=%1, shooter=%2, speed=%3 [min:%8], type=%4, _dt=%5 [min:%6 max:%7]", _bullet, _unit, _speed, typeOf _bullet, _dt, bdetect_bullet_min_delay, bdetect_bullet_max_delay, bdetect_bullet_initial_min_speed];
				[ _msg, 2 ] call bdetect_fnc_debug;
			};
		};
	};
};

// Time-critical detection function, to be executed per-frame
bdetect_fnc_detect =         
{        
	private ["_tot", "_msg"];
	
	if( bdetect_enable ) then
	{
		private ["_t", "_dt"];
		
		_t = time; //diag_tickTime
		_dt = _t - bdetect_frame_tstamp;

		if( _dt >= bdetect_frame_min_duration ) then
		{

			bdetect_frame_tstamp = _t;
			
			if( bdetect_debug_enable && diag_frameno % 32 == 0) then {
				_msg = format["bdetect_fnc_detect() - Frame: duration=%1 (min=%2), FPS=%3", _dt , bdetect_frame_min_duration, diag_fps ];
				[ _msg, 1 ] call bdetect_fnc_debug;
			};
			
			if( bdetect_fps_adaptation && diag_frameno % bdetect_fps_calc_each_x_frames == 0) then {
				call bdetect_fnc_diag_min_fps;
			};
			
			_tot = count bdetect_fired_bullets;

			if ( _tot > 0 ) then 
			{ 
				[ _tot, _t ] call bdetect_fnc_detect_sub;
			};
		};
		
		bdetect_fired_bullets = bdetect_fired_bullets - [-1];
	};
};

// Subroutine executed within bdetect_fnc_detect()
bdetect_fnc_detect_sub = 
{
	private ["_tot", "_t", "_n", "_bullet", "_data", "_shooter", "_pos", "_time", "_blacklist", "_update_blacklist", "_bpos", "_dist", "_units", "_x", "_data", "_nul"];
	
	_tot = _this select 0;
	_t = _this select 1;
	
	for "_n" from 0 to _tot - 1 step 2 do 
	{
		_bullet = bdetect_fired_bullets select _n;
		_data = bdetect_fired_bullets select (_n + 1);
		_shooter = _data select 0;
		_pos = _data select 1;
		_time = _data select 2;
		_blacklist = _data select 3;
		_update_blacklist = false;
		
		if( !( isnull _bullet ) ) then
		{
			_bpos = getPosATL _bullet;
			_dist = _bpos distance _pos;	

			if( bdetect_debug_enable ) then {
				_msg = format["bdetect_fnc_detect_sub() - Flying: bullet=%1, lifespan=%2, distance=%3, speed=%4, position=%5", _bullet, _t - _time, round _dist, round (speed _bullet / 3.6), getPosASL _bullet];
				[ _msg, 2 ] call bdetect_fnc_debug;
			};
		};			

		if( isNull _bullet 
		|| !(alive _bullet) 
		|| _t - _time > bdetect_bullet_max_lifespan 
		|| _dist > bdetect_bullet_max_distance	
		|| speed _bullet < bdetect_bullet_initial_min_speed // funny rebounds handling
		|| ( ( _bpos select 2) > bdetect_bullet_max_height && ( ( vectordir _bullet ) select 2 ) > 0.2 ) 
		) then {
			
			[ _bullet ] call bdetect_fnc_bullet_tag_remove;
		}
		else
		{
			if( _dist > bdetect_bullet_min_distance	) then {
			
				_units = _bpos nearEntities [ bdetect_units_kindof, bdetect_bullet_max_proximity];
				
				{
		
					if( _x != _shooter && local _x  ) then //&& lifestate _x == "ALIVE"
					{
			
					
						if( _x in _blacklist ) then 
						{
							bdetect_fired_bullets_count_blacklisted = bdetect_fired_bullets_count_blacklisted + 1;
							
							if( bdetect_debug_enable ) then {
								_msg = format["bdetect_fnc_detect_sub() - blacklisted: bullet=%1, unit=%2, shooter=%3", _bullet, _x, _shooter];
								[ _msg, 5 ] call bdetect_fnc_debug;
							};
						}
						else
						{
							_blacklist set [ count _blacklist, _x];
							_update_blacklist = true;
							
							bdetect_fired_bullets_count_detected = bdetect_fired_bullets_count_detected + 1;
									
							// compile callback name into function
							bdetect_callback_compiled = call compile format["%1", bdetect_callback];

							
							if( bdetect_callback_mode == "spawn" ) then {
								_nul = [ _x, _shooter, _bullet, _bpos, _pos, _time ] spawn bdetect_callback_compiled;
							} else {
								[ _x, _shooter, _bullet, _bpos, _pos, _time ] call bdetect_callback_compiled;
							};
							
							if( bdetect_debug_enable ) then {
								_msg = format["bdetect_fnc_detect_sub() - *** CLOSE BULLET ***: unit=%1, bullet=%2, shooter=%3, proximity=%4, data=%5", _x, _bullet, _shooter, round (_x distance _bpos), _data];
								[ _msg, 9 ] call bdetect_fnc_debug;
							};
						};
					};
					
				} foreach _units;
					
				if(_update_blacklist) then {
					bdetect_fired_bullets set[ _n + 1, [_shooter, _pos, _time, _blacklist] ]; // Update blacklist
				};
			};
		};
	};
};

// Adapt frequency of some bullet checking depending on minimum FPS
bdetect_fnc_diag_min_fps =
{
	private ["_fps", "_msg"];

	_fps = diag_fps;
	
	if( _fps < bdetect_fps_min * 1.1) then
	{
		if( bdetect_bullet_delay  < bdetect_bullet_max_delay ) then {
		
			bdetect_bullet_delay = ( ( bdetect_bullet_delay + 0.2) min bdetect_bullet_max_delay );
		
			if( bdetect_debug_enable ) then {
				_msg = format["bdetect_fnc_diag_min_fps() - FPS = %1, bdetect_bullet_delay = %2", _fps, bdetect_bullet_delay];
				[ _msg, 1 ] call bdetect_fnc_debug;
			};
		};
	}
	else
	{
		if( bdetect_bullet_delay > bdetect_bullet_min_delay ) then {
		
			bdetect_bullet_delay = (bdetect_bullet_delay - 0.1) max bdetect_bullet_min_delay;
		
			if( bdetect_debug_enable ) then {
				_msg = format["bdetect_fnc_diag_min_fps() - FPS = %1, bdetect_bullet_delay = %2", _fps, bdetect_bullet_delay];
				[ _msg, 1 ] call bdetect_fnc_debug;
			};
		};
	};
	
	bdetect_fps = _fps;
};

// Add a bullet to bdetect_fired_bullets 
bdetect_fnc_bullet_add = 
{
	private ["_bullet", "_shooter", "_pos", "_time",  "_msg", "_n"];
	
	_bullet = _this select 0; 	// bullet object
	_shooter = _this select 1;	// shooter
	_pos = getPosATL _bullet;	// bullet start position
	_time = _this select 2;		// bullet shoot time
	
	_n = count bdetect_fired_bullets;
	bdetect_fired_bullets set [ _n,  _bullet  ];
	bdetect_fired_bullets set [ _n + 1, [ _shooter, _pos, _time, [] ] ];
	
	if( bdetect_debug_enable ) then {
		_msg = format["bdetect_fnc_bullet_add() - Bullet=%1, shooter=%2, bullets(%3)= %4", _bullet, _shooter, _n / 2, bdetect_fired_bullets];
		[ _msg, 2] call bdetect_fnc_debug;		
	};
};

// Tag a bullet to be removed from bdetect_fired_bullets 
bdetect_fnc_bullet_tag_remove = 
{
	private ["_bullet", "_n", "_msg" ];

	_bullet = _this select 0;
	_n = bdetect_fired_bullets find _bullet;
	
	if( _n != -1 ) then
	{
		bdetect_fired_bullets set[ _n, -1 ];
		bdetect_fired_bullets set[ _n + 1, -1 ];

		if( bdetect_debug_enable ) then {
			_msg = format["bdetect_fnc_bullet_tag_remove() - tagging null/expired bullet to be removed"];
			[ _msg, 2 ] call bdetect_fnc_debug;
		};
	};
};

// Prototype for callback function to be executed within bdetect_fnc_detect
bdetect_fnc_callback = 
{
	private [ "_unit", "_shooter", "_bullet", "_bpos", "_pos", "_time", "_proximity", "_msg" ];
	
	_unit = _this select 0;		// unit being under fire
	_shooter = _this select 1;	// shooter
	_bullet = _this select 2;	// bullet object
	_bpos = _this select 3;	// bullet position
	_pos = _data select 4;	// starting position of bullet
	_time = _data select 5; // starting time of bullet
	_proximity = _bpos distance _unit;	// distance between _bullet and _unit

	if( bdetect_debug_enable ) then {
		_msg = format["bdetect_fnc_callback() - unit=%1, bullet=%2, shooter=%3, proximity=%4, data=%5", _unit, _bullet, _shooter, _proximity, _data];
		[ _msg, 9 ] call bdetect_fnc_debug;
	};
};

// function to display and log stuff (into .rpt file) level zero is intended only for builtin messages
bdetect_fnc_debug =
{
	private [ "_msg", "_level"];
	
	/*
	DEBUG LEVELS: 
	From 0-9 are reserved.
	
	0 = Startup / unclassified messages
	1 = Frames / FPS related messages
	2 = "bdetect_fired_bullets" related messages
	3 = EH related messages
	...
	5 = Unit blacklist messages
	...
	8 = MP related messages
	9 = Unit detection related messages
	*/
	
	_level = _this select 1;
	
	if( bdetect_debug_enable && _level in bdetect_debug_levels) then
	{
		_msg = _this select 0;
		diag_log format["%1 [%2 v%3] Frame:%4 L%5: %6", time, bdetect_name_short, bdetect_version, diag_frameno, _level, _msg ];
		
		if( bdetect_debug_chat ) then {
			player globalchat format["%1 - %2", time, _msg ];
		};
	};
};

// -------------------------------------------------------------------------------------------
// END OF FRAMEWORK CODE
// -------------------------------------------------------------------------------------------
// BELOW: Example for running the framework
// The below commented code is not part of the framework, just an example of how to run it
// -------------------------------------------------------------------------------------------
/*
// Cut & paste the following code into your own sqf. file.
// Place "bdetect.sqf" into your own mission folder.

// First load the framework
call compile preprocessFileLineNumbers "bdetect.sqf";  // CAUTION: comment this line if you wish to execute the framework from -within- bdetect.sqf file

// Set any optional configuration variables whose value should be other than Default (see all the defined variables in bdetect.sqf, function bdetect_fnc_init() ). 
// Below some examples.
bdetect_debug_enable = true;		// Example only - Enable debug / logging in .rpt file. Beware, full levels logging may be massive.
bdetect_debug_levels = [0,9];		// Example only - Log only some basic messages (levels 0 and 9). Read comment about levels meanings into "bdetect.sqf, function bdetect_fnc_debug()
bdetect_debug_chat = true;			// Example only - log also into globalChat.

// Now name your own unit callback function (the one that will be triggered when a bullet is detected close to an unit)
bdetect_callback = "my_function";

// Define your own callback function and its contents, named as above. Here's a prototypical function: 
my_function = {
	private [ "_unit", "_shooter", "_bullet", "_bpos", "_pos", "_time", "_proximity", "_msg" ];
	
	_unit = _this select 0;		// unit being under fire
	_shooter = _this select 1;	// shooter
	_bullet = _this select 2;	// bullet object
	_bpos = _this select 3;	// bullet position
	_pos = _this select 4;	// starting position of bullet
	_time = _this select 5; // starting time of bullet
	_proximity = _bpos distance _unit;	// distance between _bullet and _unit

	_msg = format["my_function() - [%1] close to bullet %2 fired by %3, proximity=%4m, data=%5", _unit, _bullet, _shooter, _proximity, _data];
	[ _msg, 9 ] call bdetect_fnc_debug;
};

// Now initialize framework
sleep 5; // wait some seconds if you want to load other scripts
call bdetect_fnc_init;

// Wait for framework to be fully loaded
waitUntil { !(isNil "bdetect_init_done") };

// You are done. Optional: care to activate display of some runtime stats ?
sleep 5;	// wait some more seconds for CPU load to normalize
call bdetect_fnc_benchmark; 

// All done, place your other fancy stuff below ...
*/