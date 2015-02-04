// -----------------------------------
// DEBUG LEVELS: From 0-9 are reserved.
// -----------------------------------
/*
0 = unclassified messages
1 =  bcombat FSM rinternal loop
2 = Skill related messages
3 = Target related messages
4 = Cover related messaged
5 = suppression.fsm event only
6 = danger.fsm
6 = tasks
7 = stance
8 = suppression help
9 = Incoming fire messages
10 = Event Handlers

30 = Move to cover
40 = Suppressive fire
50 = danger (bcombat_fnc_danger)
60 = hearing

*/
// -----------------------------------

bcombat_fnc_debug =
{
	private [ "_msg", "_level"];

	_level = _this select 1;
	
	if( bcombat_debug_enable && _level in bcombat_debug_levels) then
	{
		_msg = _this select 0;
		
		diag_log format["%1 [%2 v%3] Frame:%4 L%5: %6", time, bcombat_short_name, bcombat_version, diag_frameno, _level, _msg ];
		
		if( bcombat_debug_chat ) then 
		{
			player globalchat format["%1 - %2", time, _msg ];
		};
	};
};

bcombat_fnc_stats = {

	[] spawn {

		while {true} do 
		{
			_str2 = player getVariable ["bcombat_stats_throw_smoke", 0];
			_str3 = player getVariable ["bcombat_stats_move_cover", 0];
			_str4 = player getVariable ["bcombat_stats_surrender", 0];
			_str5 = player getVariable ["bcombat_stats_fire", 0];
			_str6 = player getVariable ["bcombat_stats_return_fire", 0];
			_str7 = player getVariable ["bcombat_stats_suppress", 0];
			_str8 = player getVariable ["bcombat_stats_watch_six", 0];
			_str9 = player getVariable ["bcombat_stats_hear", 0];
			_str10 = player getVariable ["bcombat_stats_hear_grenade", 0];
			_str11 = player getVariable ["bcombat_stats_hear_raw", 0];
			_str12 = player getVariable ["bcombat_stats_incoming_bullets1", 0];
			_str13 = player getVariable ["bcombat_stats_incoming_bullets2", 0];
			_str14 = player getVariable ["bcombat_stats_incoming_bullets3", 0];
			hintsilent format["TIME: %1\n--------\nsmoke: %2\ncover: %3\nsurrend: %4\nfire: %5\nreturn fire: %6\nsuppress: %7\nwatchsix: %8\nhear: %9\nhear grenade: %10\nhear RAW: %11\n BULLETS1: %12\n BULLETS2: %13\n BULLETS3: %14", time, _str2, _str3, _str4, _str5, _str6, _str7, _str8, _str9, _str10, _str11, _str12, _str13, _str14];
			sleep 1;
		};
	};
};


bcombat_fnc_debug_text = 
{
	sleep 1;

	while {true} do 
	{
		private ["_x"];
		
		waitUntil { bcombat_enable };
		{
			if(  !(_x getVariable["bcombat_text_debug", false]) && [_x] call bcombat_fnc_is_active) then // [_x] call bcombat_fnc_is_active &&
			{
				_x setVariable["bcombat_text_debug", true];
				
				_nul = [_x] spawn
				{
					disableserialization;
					private ["_unit", "_text","_pos","_display","_control","_w","_h","_minsDis","_dis","_alpha","_pos2D", "_color", "_marker"];
					
					_unit = _this select 0;
					if (isnil "BIS_fnc_3dCredits_n") then {BIS_fnc_3dCredits_n = 2733;};

					BIS_fnc_3dCredits_n cutrsc ["rscDynamicText","plain"];
					BIS_fnc_3dCredits_n = BIS_fnc_3dCredits_n + 1;

					_display = uinamespace getvariable "BIS_dynamicText";
					_control = _display displayctrl 9999;

					_w = 1;
					_h = 1.33;
					_fadeDis = 150;
					
					
					if( isNil { _unit getVariable "bcombat_debug_marker" } ) then
					{
						if( (side _unit) getFriend WEST < 0.6 ) then { _color = "ColorRed"; } else { _color = "ColorBlue"; };
						
						_marker = createMarker[ format["bcombat_markers_%1", _unit], position _unit];
						_marker setMarkerShape "ICON";
						_marker setMarkerType "mil_triangle";
						_marker setMarkerColor _color;

						_unit setVariable ["bcombat_debug_marker", _marker ];
					}
					else
					{
						_marker = _unit getVariable "bcombat_debug_marker";
					};

					while { alive _unit} do 
					{
						_pos = position _unit;
						_dis = player distance _pos;
						_alpha = (_dis / _fadeDis) min 1;
						_pos2D = worldtoscreen _pos;
						

						if (  ! ( visibleMap ) && count _pos2D  > 0 ) then
						{
							_level = _unit getVariable ["bcombat_suppression_level", 0];
						
							switch ( true ) do
							{
								case ( fleeing _unit ): { _color =  "#FF00FF"; };
								case ( _level == 0 ): { _color =  "#FFFFFF"; };
								case ( _level <= 25 ): { _color =  "#00CC00"; };
								case ( _level <= 50 ): { _color =  "#5555CC"; };
								case ( _level <= 75 ): { _color =  "#CCCC00"; };
								case ( _level <= 100 ): { _color =  "#CC0000"; };
							};
			
							_tgt = assignedTarget _unit;
							if(isnull _tgt) then { _tgt = "";};

							_tpos = (expecteddestination _unit) select 0;
							_mode = (expecteddestination _unit) select 1;
							_cmd = currentCommand _unit;
							_d = _unit distance _tpos;
								
							_task = "none";
							_t = _unit getVariable ["bcombat_task", nil];
							if( !(isNil "_t") ) then { _task = _t select 1; };
							
							_tgt = assignedtarget _unit;
							_tgt_dist =0;
							_kn =0;
							if(isNull _tgt ) then
							{
								_tgt = "";
	
								
							}
							else
							{
								_tgt_dist = _unit distance _tgt;
								_kn = _unit knowsabout _tgt;
							};
							
							_text = format["<t color='%1' size='0.42'>
								%2 Ld=%5<br/>
								Dmg=%18 Stp=%9 dst=%19<br/>
								lv=%3 (t=%4) Ac=%6 Cr=%7 Gn=%8<br/>
								Fle=%10 Atk=%11 Hid=%12<br/>
								%13 %14<br/>
								Cmd=%15 Mode=%23<br/>
								Tgt=%17 d=%21 kn=%22<br/>
								Tsk=%16<br/>
								Rng=%20<br/>
								OW=%24<br/>
								form=%25<br/>
								</t>",
								
								_color,
								
								_unit,
								_level, 
								( (_unit getVariable ["bcombat_suppression_timeout_mid", 0 ]) - time) max 0,
								formationleader _unit,
								
								ceil( (_unit skill "aimingAccuracy") * 10) / 10, 
								ceil( (_unit skill "courage") * 10) / 10, 
								ceil( (_unit skill "general") * 10) / 10,
								
								[_unit] call bcombat_fnc_is_stopped,
								fleeing _unit, 
								attackenabled _unit,
								isHidden _unit,
								
								combatmode _unit,
								behaviour _unit,
								currentCommand _unit,
								_task,
								
								format["%1", _tgt],
								ceil( damage _unit * 10) / 10,
								_d,
								[_unit ] call bcombat_weapon_max_range,
								_tgt_dist,
								_kn,
								_mode,
								_unit getVariable["bcombat_stop_overwatch", false],
								[_unit] call bcombat_fnc_in_formation
							];
								
							_control ctrlsetposition [
								(_pos2D select 0) - _w/2,
								(_pos2D select 1) - _h/2,
								_w,
								_h
							];

							_control ctrlsetstructuredtext parsetext ( format ["%1", _text ] );
							_control ctrlsetfade _alpha;
							_control ctrlcommit 0.01;
						}
						else
						{
							if( fleeing _unit) then 
							{
								_marker setMarkerType "mil_dot";
							}
							else
							{
								_marker setMarkerType "mil_triangle";
								_marker setMarkerDir (getdir _unit);
							};
							
							_marker setMarkerPos _pos;
							
							_control ctrlsetfade 1;
							_control ctrlcommit 0.01;
						};

						sleep 0.1;
					};
					
					_control ctrlsetfade 1;
					_control ctrlcommit 0.01;
					
					_marker = ( _unit getVariable "bcombat_debug_marker" );
					_marker setMarkerType "mil_destroy";
				};
			};
			
		} foreach allUnits;
		
		sleep 5;
	};
	
};

bcombat_fnc_debug_balloons = 
{
	private ["_handle"];

	_handle = [] spawn 
	{
		private ["_ball", "_marker", "_level", "_x", "_nul", "_color"];
		
		while { true } do
		{
			waitUntil { bcombat_enable };

			{
				if( [_x] call bcombat_fnc_is_active) then
				{
					if( isNil { _x getVariable "bcombat_debug_ball" } ) then
					{
						_ball = "Sign_Sphere25cm_F" createvehicle getposATL _x;  
						//_ball setObjectTexture [0,"#(argb,8,8,3)color(0.99,0.99,0.99,0.7,ca)"];  // white
						_ball attachTo [_x,[0,0,2.2]];   
						//_ball hideobject true;  
						
						if( (side _x) getFriend WEST < 0.6 ) then { _color = "ColorRed"; } else { _color = "ColorBlue"; };
						
						_marker = createMarker[ format["bcombat_markers_%1", _x], position _x];
						_marker setMarkerShape "ICON";
						_marker setMarkerType "mil_triangle";
						_marker setMarkerColor _color;

						_x setVariable ["bcombat_debug_ball", _ball ];
						_x setVariable ["bcombat_debug_marker", _marker ];

					}
					else
					{
						_ball = _x getVariable "bcombat_debug_ball";
						_marker = _x getVariable "bcombat_debug_marker";
					};

					if ( visibleMap  ) then
					{
						_marker setMarkerPos (position _x);
						
						if( fleeing _x) then 
						{
							_marker setMarkerType "mil_dot";
						}
						else
						{
							_marker setMarkerType "mil_triangle";
							_marker setMarkerDir (getDir _x);
						};
					};
	
					_level = _x getVariable ["bcombat_suppression_level", 0];
				
					switch ( true ) do
					{
		
						case ( fleeing _x ): {  
							_ball hideobject false;  
							_ball setObjectTexture [0,"#(argb,8,8,3)color(0.9,0.0,0.9,0.95,ca)"];  // purple
						};
						
						case ( _level == 0 ): {  
							_ball hideobject false;  
							_ball setObjectTexture [0,"#(argb,8,8,3)color(1,1,1,1)"];  // white
						};
						
						case ( _level <= 25 ): {  
							_ball hideobject false;  
							_ball setObjectTexture [0,"#(argb,8,8,3)color(0.1,0.9,0.1,0.95,ca)"];  // green
						};
					
						case ( _level <= 50 ): {  
							_ball hideobject false; 
							_ball setObjectTexture [0,"#(argb,8,8,3)color(0.1,0.1,0.9,0.95,ca)"];  // blue
						};
						
						case ( _level <= 75 ): {  
							_ball hideobject false; 
							_ball setObjectTexture [0,"#(argb,8,8,3)color(0.9,0.9,0.1,0.95,ca)"]; //yellow
						};
						
						case ( _level <= 100 ): {  
							_ball hideobject false; 
							_ball setObjectTexture [0,"#(argb,8,8,3)color(0.9,0.1,0.1,0.95,ca)"]; //red  
						};
					};
					
					// Stop / overwatch
					_so = _x getVariable["bcombat_stop_overwatch", false];
					_ball_so = _x getVariable ["bcombat_debug_ball_so", objNull ];
						
					if( _so ) then
					{
						if( isNull _ball_so ) then {
					
							_ball_so = "Sign_Sphere25cm_F" createvehicle getposATL _x;  
							_ball_so hideobject false;  
							_ball_so setObjectTexture [0,"#(argb,8,8,3)color(0.1,0.1,0.1,0.99,ca)"]; //red  
							_ball_so attachTo [_x,[0,0,2.7]];  
							_x setVariable ["bcombat_debug_ball_so", _ball_so ];
						};
					}
					else
					{
						if( !(isNull _ball_so) ) then {
							deletevehicle _ball_so;
						};
					};
				
				}
				else
				{
					if(  !(isNil { _x getVariable "bcombat_debug_ball" })  ) then
					{
						deleteVehicle ( _x getVariable "bcombat_debug_ball" );
						deleteMarker( _x getVariable "bcombat_debug_marker" );
						deletevehicle ( _x getVariable ["bcombat_debug_ball_so", objNull ] );
					};
				};
				
				
			} foreach allUnits;

			{
				if( !([_x] call bcombat_fnc_is_active) && ! ( isNil { _x getVariable "bcombat_debug_ball" } ) ) then
				{
					deleteVehicle ( _x getVariable "bcombat_debug_ball" );
					deleteMarker( _x getVariable "bcombat_debug_marker" );
					deletevehicle ( _x getVariable ["bcombat_debug_ball_so", objNull ] );
				};
				
			} foreach allDead;
			

			
			sleep 1;
		};
	};
};

bcombat_fnc_fps = 
{
	private ["_min", "_minfps", "_t0", "_t1", "_sum", "_dt"];
	
	sleep 1;
	
	_min = -1;
	_minfps = -1;
	_t0 = 0;
	_t1 = 0;
	_sum = 0;
	_dt=0;
	bcombat_fnc_is_active  = {true};

	while {true } do {
		
		_t0 = time;
		sleep .1;
		
		_t1 = time;
		_dt = _dt + _t1 - _t0;
		_minfps = diag_fpsmin;
		_sum = _sum + (diag_fps * (_t1 - _t0));

		if(_min == -1 || _minfps < _min) then 
		{
			_min = _minfps;
		};
		
		_msg = format["Time: %1\n FPS: %2\nFPS MIN: %3\nFPS AVG: %4", round(time), round(diag_fps), round(_min), round(_sum / _dt)];
		hintsilent _msg;
	};
};

bdetect_fnc_benchmark = 
{
	private ["_cnt"];
	
	if(isNil "bdetect_stats_max_bullets") then { bdetect_stats_max_bullets = 0; };
	if(isNil "bdetect_stats_min_fps") then { bdetect_stats_min_fps = 999; };
	if(isNil "bdetect_fired_bullets") then { bdetect_fired_bullets = []; };
	
	_nul = [] spawn 
	{
		sleep 5;
		
		while { true } do
		{
			_cnt = count ( bdetect_fired_bullets ) / 2;
			if( _cnt > bdetect_stats_max_bullets ) then { bdetect_stats_max_bullets = _cnt; };
			
			if( diag_fps < bdetect_stats_min_fps ) then { bdetect_stats_min_fps = diag_fps };
			hintsilent format["TIME: %1\nFPS: %2 (min: %3)\nBULLETS: %4 (max: %5)\nS.DELAY: %6 (Min FPS: %7)\nFIRED: %8 (W%9 E%10)\nTRACKED: %11\nDETECTED: %12\nBLACKLISTED: %13\nUNITS: %14\nKILLED: %15", 
			time, 
			diag_fps, 
			bdetect_stats_min_fps, 
			_cnt, 
			bdetect_stats_max_bullets, 
			bdetect_bullet_delay, 
			bdetect_fps_min,
			bdetect_fired_bullets_count,
			bdetect_fired_bullets_count_west,
			bdetect_fired_bullets_count_east,
			bdetect_fired_bullets_count_tracked,
			bdetect_fired_bullets_count_detected,
			bdetect_fired_bullets_count_blacklisted,
			bdetect_units_count,
			bdetect_units_count_killed];
			
			sleep .25;
		};
	};
};