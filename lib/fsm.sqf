// _thisFSM (to get handle from within FSM)
bcombat_fnc_fsm_trigger = 
{
	private [ "_unit", "_event", "_penalty", "_timeout_min", "_timeout_mid", "_timeout_max", "_enemy", "_fsm", "_msg" ];
	
	_unit = _this select 0;	
	_event = _this select 1;	
	_penalty = _this select 2;	
	_timeout_min = _this select 3;	
	_timeout_mid = _this select 4;	
	_timeout_max = _this select 5;	
	_enemy = _this select 6;	

	if ( !(isPlayer _unit ) ) then //&& lifestate _unit == "HEALTHY"
	{
		
		
		[ _unit, _enemy] call bcombat_fnc_danger;

		_fsm = nil;
		
		if( !( isNil { _unit getVariable "bcombat_fsm" } ) ) then
		{
			_fsm = ( _unit getVariable "bcombat_fsm" );
			
			if( completedFSM _fsm ) then
			{
				_unit setVariable [ "bcombat_fsm", nil ];
				_fsm = nil;
			};
		};
		
		if( isNil "_fsm" ) then
		{
			_fsm = _unit execFSM "\@bcombat\fsm\suppression.fsm";
			_unit setVariable [ "bcombat_fsm", _fsm ];
			
			if( bcombat_debug_enable && side _unit == WEST) then {
				_msg = format["FSM unit=%1 - started", _unit ];
				[ _msg, 5 ] call bcombat_fnc_debug;
			};
		};

		if(_penalty > _unit getVariable ["bcombat_suppression_penalty", 0 ]) then {
		
			_unit setVariable ["bcombat_suppression_penalty", _penalty ];
			
			_penalty_hit = (100 - (_unit getVariable ["bcombat_suppression_level", 0])) * _penalty / 100;
		
			_unit setVariable ["bcombat_suppression_level",  ceil((_unit getVariable ["bcombat_suppression_level", 0]) + _penalty_hit) max 0 min 100 ];
		};
		
		if( _timeout_min > _unit getVariable ["bcombat_suppression_timeout_min", 0 ]) then {
			_unit setVariable ["bcombat_suppression_timeout_min", _timeout_min ];
		};
		
		if( _timeout_mid > _unit getVariable ["bcombat_suppression_timeout_mid", 0 ]) then {
			_unit setVariable ["bcombat_suppression_timeout_mid", _timeout_mid ];
		};
		
		if( _timeout_max > _unit getVariable ["bcombat_suppression_timeout_max", 0 ]) then {
			_unit setVariable ["bcombat_suppression_timeout_max", _timeout_max ];
		};
		
		_unit setVariable ["bcombat_suppression_enemy", _enemy ];
		_unit setVariable ["bcombat_suppression_event", _event ];
		
		_fsm setFSMVariable [ "_event", _event ]; // instantly trigger fsm event

		if( bcombat_debug_enable ) then {
			_msg = format["FSM event=%2, unit=%1, penalty=%3, timeout=%4", _unit, _event, _penalty, _timeout_max];
			[ _msg, 5 ] call bcombat_fnc_debug;
		};
		
		_fsm
	};
};

bcombat_fnc_process_danger_queue = 
{
	private ["_unit", "_queue", "_penalty", "_timeout_min", "_timeout_mid", "_timeout_max", "_enemy", "_processed", "_ret", "_dictionary", "_priors", "_cause", "_dangerPos", "_dangerUntil", "_enemy", "_hash", "_x", "_c", "_v"];
	
	_unit = _this select 0;
	_queue = _this select 1;
	_penalty = 0;
	_timeout_min = 0;
	_timeout_mid = 0;
	_timeout_max = 0;
	_enemy = objNull;
	_processed = [];
	_ret = [-1, [1,1,1], 0, objNull];
	
	_dictionary = 
	[
		[bcombat_penalty_enemy_contact, 0, (15 + random 15), (60 + random 30) ],	//0 enemy detected
		[0, 0, 0, 0],	//1 fired near
		[bcombat_penalty_wounded, 10, 15 + random 15, 60 + random 30],	//2	 being hit
		[bcombat_penalty_enemy_close, 0, 15 + random 15, 60 + random 30],	//3	enemy near
		[bcombat_penalty_explosion, 10, 15 + random 15, 60 + random 30],	//4	explosion near
		[bcombat_penalty_casualty, 0, 15 + random 15, 60 + random 30],	//5 friendly dead
		[0, 0, 0, 0],	//6 enemy dead
		[bcombat_penalty_scream, 0, 0, 60 + random 30],	//7 being hit, screaming
		[0, 0, 0, 0]	//8 fire upon enemy
	];

	 // 0, 1, 2, 3, 4, 5, 6, 7, 8
	_priors = [20, 4, 8, 3, 5, 12, 1, 0, 15];
		
	{
		_cause = _x select 0;
		_dangerPos = _x select 1;
		_dangerUntil = _x select 2;
		_enemy = _x select 3;
		
		_hash = format["%1-%2", _enemy, _cause ];
		_p = 0;
		
		// Filter out non-suppressing / problematic events such as "fired near" and "dead enemy"
		// those are causing problems within campaign intro
		// Filtering events of type "enemy detected" having null enemy
		if(  !(_cause in [1,6]) 
			&& { vehicle _unit != vehicle _enemy }
			&& { ( !(_cause in[0,3,8]) || !isNull(_enemy) ) } 
			&& { ( _unit distance _dangerPos < 1000 ) }
			&& { _processed find _hash == -1 }
		) then {

			_processed set [count _processed, _hash];
			_c = _dictionary select _cause;
			
			_p = _c select 0;
			
			if( _cause in [4] )	then // explosives
			{
				_penalty = _penalty + _p * ( 1 - (((_unit distance _dangerPos) min 100 )/ 100));
			}
			else
			{
				_penalty = _penalty + _p;
			};

			_v = time + (_c select 1);
			if(_v > _timeout_min) then {
				_timeout_min = _v;
			};
			
			_v = time + (_c select 2);
			if(_v > _timeout_mid) then {
				_timeout_mid = _v;
			};
			
			_v = time + (_c select 3);
			if(_v > _timeout_max) then {
				_timeout_max = _v;
			};

			if( _cause in [0,3,8]) Then
			{
				[_unit, _enemy] call bcombat_fnc_reveal;
			};

			if( _priors select _cause > _ret select 0 ) then
			{
				_ret = _x;
			};
			
			if( bcombat_debug_enable ) then {
				_msg = format["bcombat_fnc_process_danger_queue() - Unit=%1, Enemy=%2, Cause=%3, Penalty=%4, Penalty sum=%5, distance1=%6, distance2=%7", _unit, _enemy, _cause, _p, _penalty, _unit distance _enemy, _unit distance _dangerPos];
				[ _msg, 1 ] call bcombat_fnc_debug;
			};
		};

	} forEach _queue;
	

	if( _penalty > 0 ) then
	{
		_penalty = (( _penalty * ( 1 - ( _unit getVariable ["bcombat_skill",1] ) ) ) min 100) max 1;

		if( _unit getVariable ["bcombat_suppression_event", 0 ] != 1) then 
		{
			[ _unit, 9, _penalty, _timeout_min, _timeout_mid, _timeout_max, objNull ] call bcombat_fnc_fsm_trigger;
		}
		else
		{
			//diag_log format["%1 ### DOUBLE bcombat_fnc_fsm_trigger() call on %2", time, _unit];
		};
	};
	
	_ret
};