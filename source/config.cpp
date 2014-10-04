class CfgPatches
{
	class bcombat
	{
		units[] = { };
		weapons[] = { };
		requiredAddons[] = {"A3_Characters_F", "CBA_Extended_EventHandlers"};
		version = "0.17";
		versionStr = "0.17";
		versionDesc= "bCombat | infantry AI mod";
		versionAr[] = {0,17,0};
		author[] = {"fabrizio_T"};
	};
};

class Extended_PostInit_EventHandlers {
    class bcombat {
        clientInit = "call compile preprocessFileLineNumbers '\@bcombat\bcombat.sqf'";
    };
}; 

class CfgVehicles
{
 class Land;
 class Man: Land{};
 class CAManBase: Man
 {
  fsmDanger = "@bcombat\fsm\danger.fsm";
 };
};

class CfgAISkill
{
	aimingAccuracy[] = {0,0,1,1};
	aimingSpeed[] = {0,0.5,1,1};
	aimingShake[] = {0,0.01,1,1};
	endurance[] = {0,0,1,1};
	spotDistance[] = {0,0.2,1,0.6};
	spotTime[] = {0,0.01,1,1};
	courage[] = {0,0,1,1};
	reloadSpeed[] = {0,0.25,1,1};
	commanding[] = {0,0.25,1,1};
	general[] = {0,0,1,1};
};

//#include "\userconfig\bcombat\bcombat_config.hpp"

