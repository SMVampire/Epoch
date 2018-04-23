/*
	Author: Raimonds Virtoss - EpochMod.com

    Contributors: Aaron Clark

	Description:
	Action Menu Target Config

    Licence:
    Arma Public License Share Alike (APL-SA) - https://www.bistudio.com/community/licenses/arma-public-license-share-alike

    Github:
    https://github.com/EpochModTeam/Epoch/tree/release/Sources/epoch_config/Configs/CfgActionMenu/CfgActionMenu_target.hpp
*/

class build_upgrade
{
	condition = "dyna_buildMode select 0";
	//action = "dyna_cursorTarget call EPOCH_QuickUpgrade;"; //TODO: scripted dyna menu
	action = "";
	icon = "x\addons\a3_epoch_code\Data\UI\buttons\build_upgrade.paa";
	tooltipcode = "format['Upgrade %1',getText(configFile >> 'CfgVehicles' >> (typeof dyna_cursorTarget) >> 'displayName')]";
	class special {}; //uses external config, hardcoded
};
class build_remove
{
	condition = "dyna_buildMode select 1";
	action = "dyna_cursorTarget call EPOCH_removeBUILD;";
	icon = "x\addons\a3_epoch_code\Data\UI\buttons\build_remove.paa";
	tooltipcode = "format['Remove %1',getText(configFile >> 'CfgVehicles' >> (typeof dyna_cursorTarget) >> 'displayName')]";
};
class build_move
{
	condition = "dyna_buildMode select 2";
	action = "dyna_cursorTarget call EPOCH_fnc_SelectTargetBuild;";
	icon = "x\addons\a3_epoch_code\Data\UI\buttons\build_move.paa";
	tooltipcode = "format['Move %1',getText(configFile >> 'CfgVehicles' >> (typeof dyna_cursorTarget) >> 'displayName')]";
};

//Vehicle interaction
class veh_gear
{
	condition = "dyna_isVehicle && !dyna_locked";
	action = "call Epoch_client_gearVehicle;";
	icon = "x\addons\a3_epoch_code\Data\UI\buttons\player_inspect.paa";
	tooltip = "Inspect";
};
class veh_lock
{
	condition = "if (dyna_cursorTarget iskindof 'Bicycle') exitwith {false};dyna_isVehicle && !dyna_locked";
	action = "[dyna_cursorTarget, true, player, Epoch_personalToken] remoteExec ['EPOCH_server_lockVehicle',2];";
	icon = "x\addons\a3_epoch_code\Data\UI\buttons\pad_cannot_lock.paa";
	tooltip = "Lock";
};
class veh_unLock
{
	condition = "dyna_isVehicle && dyna_locked";
	action = "[dyna_cursorTarget, false, player, Epoch_personalToken] remoteExec ['EPOCH_server_lockVehicle',2];";
	icon = "x\addons\a3_epoch_code\Data\UI\buttons\pad_can_unlock.paa";
	tooltip = "Unlock";
};

//Trader interaction
class tra_talk
{
	condition = "dyna_isTrader";
	action = "dyna_cursorTarget call EPOCH_startInteractNPC;";
	icon = "x\addons\a3_epoch_code\Data\UI\buttons\talk_blue.paa";
	tooltip = "Talk";
};
class tra_shop
{
	condition = "dyna_isTrader";
	action = "call EPOCH_startNPCTraderMenu;";
	icon = "x\addons\a3_epoch_code\Data\UI\buttons\krypto.paa";
	tooltip = "Shop";
};

class player_takeCrypto
{
	condition = "dyna_isDeadPlayer || (dyna_cursorTarget getVariable [""Crypto"",0]) > 0";
	action = "dyna_cursorTarget call EPOCH_takeCrypto;";
	icon = "x\addons\a3_epoch_code\Data\UI\buttons\krypto.paa";
	tooltip = "Take Krypto";
};
class player_trade
{
	condition = "dyna_isPlayer";
	action = "[dyna_cursorTarget, player, Epoch_personalToken] call EPOCH_startTRADEREQ;";
	icon = "x\addons\a3_epoch_code\Data\UI\buttons\krypto.paa";
	tooltip = "Make Trade Request";
};
class player_trade_accept
{
	condition = "dyna_isPlayer && dyna_canAcceptTrade";
	action = "EPOCH_p2ptradeTarget = EPOCH_pendingP2ptradeTarget;call EPOCH_startTrade;";
	icon = "x\addons\a3_epoch_code\Data\UI\buttons\krypto.paa";
	tooltip = "Accept Trade Request";
};

//User action replacement
class maintain_jammer
{
	condition = "dyna_cursorTargetType isEqualTo 'PlotPole_EPOCH' && (damage dyna_cursorTarget < 1)";
	action = "dyna_cursorTarget call EPOCH_maintainIT;";
	icon = "x\addons\a3_epoch_code\Data\UI\buttons\build_maintain.paa";
	tooltip = "Maintain";
};
class select_jammer
{
	condition = "dyna_cursorTargetType isEqualTo 'PlotPole_EPOCH' && (damage dyna_cursorTarget < 1)";
	action = "[dyna_cursorTarget,player,Epoch_personalToken] remoteExec [""EPOCH_server_makeSP"",2];";
	icon = "x\addons\a3_epoch_code\Data\UI\buttons\player_inspect.paa";
	tooltip = "Make Spawnpoint";
};

//lock unlock
class unlock_lockbox
{
	condition = "(dyna_cursorTargetType in ['LockBox_EPOCH','LockBoxProxy_EPOCH']) && (dyna_cursorTarget getVariable ['EPOCH_Locked',false])";
	action = "dyna_cursorTarget call Epoch_secureStorageHandler";
	icon = "x\addons\a3_epoch_code\Data\UI\buttons\pad_can_unlock.paa";
	tooltip = "Unlock Lockbox";
};
class lock_lockbox
{
	condition = "(dyna_cursorTargetType in ['LockBox_EPOCH','LockBoxProxy_EPOCH']) && !(dyna_cursorTarget getVariable ['EPOCH_Locked',false])";
	action = "dyna_cursorTarget call Epoch_secureStorageHandler";
	icon = "x\addons\a3_epoch_code\Data\UI\buttons\pad_cannot_lock.paa";
	tooltip = "Lock Lockbox";
};
class unlock_safe
{
	condition = "(dyna_cursorTargetType in ['Safe_EPOCH','SafeProxy_EPOCH']) && (dyna_cursorTarget getVariable ['EPOCH_Locked',false])";
	action = "dyna_cursorTarget call Epoch_secureStorageHandler";
	icon = "x\addons\a3_epoch_code\Data\UI\buttons\pad_can_unlock.paa";
	tooltip = "Unlock Safe";
};
class lock_safe
{
	condition = "(dyna_cursorTargetType in ['Safe_EPOCH','SafeProxy_EPOCH']) && !(dyna_cursorTarget getVariable ['EPOCH_Locked',false])";
	action = "dyna_cursorTarget call Epoch_secureStorageHandler";
	icon = "x\addons\a3_epoch_code\Data\UI\buttons\pad_cannot_lock.paa";
	tooltip = "Lock Safe";
};

//pack
class pack_lockbox
{
	condition = "(dyna_cursorTargetType in ['LockBox_EPOCH','LockBoxProxy_EPOCH']) && (dyna_cursorTarget getVariable ['EPOCH_Locked',false])";
	action = "[dyna_cursorTarget,player,Epoch_personalToken] remoteExec ['EPOCH_server_packStorage',2];";
	icon = "x\addons\a3_epoch_code\Data\UI\buttons\build_pack.paa";
	tooltip = "Pack Lockbox";
};
class pack_safe
{
	condition = "(dyna_cursorTargetType in ['Safe_EPOCH','SafeProxy_EPOCH']) && (dyna_cursorTarget getVariable ['EPOCH_Locked',false])";
	action = "[dyna_cursorTarget,player,Epoch_personalToken] remoteExec ['EPOCH_server_packStorage',2];";
	icon = "x\addons\a3_epoch_code\Data\UI\buttons\build_pack.paa";
	tooltip = "Pack Safe";
};

class VehMaintanance
{
	condition = "dyna_isVehicle && !EPOCH_Vehicle_MaintainLock";
	action = "dyna_cursorTarget call EPOCH_client_VehicleMaintananceCheck;";
    icon = "x\addons\a3_epoch_code\Data\UI\buttons\Repair_man.paa";
	tooltip = "Vehicle Maintanance";
	class Repair
	{
		condition = "(!((EPOCH_VehicleRepairs select 0) isequalto []) || !((EPOCH_VehicleRepairs select 2) isequalto [])) && EPOCH_AdvancedVehicleRepair_Enabled";
		action = "";
		icon = "x\addons\a3_epoch_code\Data\UI\buttons\Repair_Wheel.paa";
		tooltip = "Repair Vehicle";
		class RepairHull
		{
			condition = "'hithull' in (EPOCH_VehicleRepairs select 0)";
			action = "[dyna_cursorTarget,'repair','hithull'] spawn EPOCH_client_VehicleMaintananceDo";
			icon = "x\addons\a3_epoch_code\Data\UI\buttons\Repair_HullBody.paa";
			tooltip = "Repair Hull";
		};
		class ReplaceHull
		{
			condition = "'hithull' in (EPOCH_VehicleRepairs select 2)";
			action = "[dyna_cursorTarget,'replace','hithull'] spawn EPOCH_client_VehicleMaintananceDo";
			icon = "x\addons\a3_epoch_code\Data\UI\buttons\Replace_HullBody.paa";
			tooltip = "Repair Hull";
		};
		class RepairEngine
		{
			condition = "'hitengine' in (EPOCH_VehicleRepairs select 0)";
			action = "[dyna_cursorTarget,'repair','hitengine'] spawn EPOCH_client_VehicleMaintananceDo";
			icon = "x\addons\a3_epoch_code\Data\UI\buttons\Repair_Engine.paa";
			tooltip = "Repair Engine";
		};
		class ReplaceEngine
		{
			condition = "'hitengine' in (EPOCH_VehicleRepairs select 2)";
			action = "[dyna_cursorTarget,'replace','hitengine'] spawn EPOCH_client_VehicleMaintananceDo";
			icon = "x\addons\a3_epoch_code\Data\UI\buttons\Replace_Engine.paa";
			tooltip = "Replace Engine";
		};
		class ReplaceGlass
		{
			condition = "'glass' in (EPOCH_VehicleRepairs select 0) || 'glass' in (EPOCH_VehicleRepairs select 2)";
			action = "[dyna_cursorTarget,'replace','glass'] spawn EPOCH_client_VehicleMaintananceDo";
			icon = "x\addons\a3_epoch_code\Data\UI\buttons\Replace_Glass.paa";
			tooltip = "Replace Glass";
		};
		class RepairBody
		{
			condition = "'hitbody' in (EPOCH_VehicleRepairs select 0)";
			action = "[dyna_cursorTarget,'repair','hitbody'] spawn EPOCH_client_VehicleMaintananceDo";
			icon = "x\addons\a3_epoch_code\Data\UI\buttons\Repair_HullBody.paa";
			tooltip = "Repair Body";
		};
		class ReplaceBody
		{
			condition = "'hitbody' in (EPOCH_VehicleRepairs select 2)";
			action = "[dyna_cursorTarget,'replace','hitbody'] spawn EPOCH_client_VehicleMaintananceDo";
			icon = "x\addons\a3_epoch_code\Data\UI\buttons\Replace_HullBody.paa";
			tooltip = "Repair Body";
		};
		class RepairFuel
		{
			condition = "'hitfuel' in (EPOCH_VehicleRepairs select 0)";
			action = "[dyna_cursorTarget,'repair','hitfuel'] spawn EPOCH_client_VehicleMaintananceDo";
			icon = "x\addons\a3_epoch_code\Data\UI\buttons\Repair_Fuel.paa";
			tooltip = "Repair Fuel Hose";
		};
		class RepairMainRotor
		{
			condition = "'hithrotor' in (EPOCH_VehicleRepairs select 0)";
			action = "[dyna_cursorTarget,'repair','hithrotor'] spawn EPOCH_client_VehicleMaintananceDo";
			icon = "x\addons\a3_epoch_code\Data\UI\buttons\Repair_MainRotor.paa";
			tooltip = "Repair Main Rotor";
		};
		class ReplaceFuel
		{
			condition = "'hitfuel' in (EPOCH_VehicleRepairs select 2)";
			action = "[dyna_cursorTarget,'replace','hitfuel'] spawn EPOCH_client_VehicleMaintananceDo";
			icon = "x\addons\a3_epoch_code\Data\UI\buttons\Repair_Fuel.paa";
			tooltip = "Replace Fuel Hose";
		};
		class ReplaceMainRotor
		{
			condition = "'hithrotor' in (EPOCH_VehicleRepairs select 2)";
			action = "[dyna_cursorTarget,'replace','hithrotor'] spawn EPOCH_client_VehicleMaintananceDo";
			icon = "x\addons\a3_epoch_code\Data\UI\buttons\Replace_MainRotor.paa";
			tooltip = "Replace Main Rotor";
		};
		class RepairTailRotor
		{
			condition = "'hitvrotor' in (EPOCH_VehicleRepairs select 0)";
			action = "[dyna_cursorTarget,'repair','hitvrotor'] spawn EPOCH_client_VehicleMaintananceDo";
			icon = "x\addons\a3_epoch_code\Data\UI\buttons\Repair_TailRotor.paa";
			tooltip = "Repair Tail Rotor";
		};
		class ReplaceTailRotor
		{
			condition = "'hitvrotor' in (EPOCH_VehicleRepairs select 2)";
			action = "[dyna_cursorTarget,'replace','hitvrotor'] spawn EPOCH_client_VehicleMaintananceDo";
			icon = "x\addons\a3_epoch_code\Data\UI\buttons\Replace_TailRotor.paa";
			tooltip = "Replace Tail Rotor";
		};
		class ReplaceWinch
		{
			condition = "'hitwinch' in (EPOCH_VehicleRepairs select 0) || 'hitwinch' in (EPOCH_VehicleRepairs select 2)";
			action = "[dyna_cursorTarget,'replace','hitwinch'] spawn EPOCH_client_VehicleMaintananceDo";
			icon = "x\addons\a3_epoch_code\Data\UI\buttons\Replace_SLG.paa";
			tooltip = "Replace Winch";
		};
		class RepairTire1
		{
			condition = "'hitlfwheel' in (EPOCH_VehicleRepairs select 0)";
			action = "[dyna_cursorTarget,'repair','hitlfwheel'] spawn EPOCH_client_VehicleMaintananceDo";
			icon = "x\addons\a3_epoch_code\Data\UI\buttons\Repair_Wheel.paa";
			tooltip = "Repair 1st Left Wheel";
		};
		class RepairTire2
		{
			condition = "'hitlf2wheel' in (EPOCH_VehicleRepairs select 0)";
			action = "[dyna_cursorTarget,'repair','hitlf2wheel'] spawn EPOCH_client_VehicleMaintananceDo";
			icon = "x\addons\a3_epoch_code\Data\UI\buttons\Repair_Wheel.paa";
			tooltip = "Repair 2nd Left Wheel";
		};
		class RepairTire3
		{
			condition = "'hitlmwheel' in (EPOCH_VehicleRepairs select 0)";
			action = "[dyna_cursorTarget,'repair','hitlmwheel'] spawn EPOCH_client_VehicleMaintananceDo";
			icon = "x\addons\a3_epoch_code\Data\UI\buttons\Repair_Wheel.paa";
			tooltip = "Repair 3rd Left Wheel";
		};
		class RepairTire4
		{
			condition = "'hitlbwheel' in (EPOCH_VehicleRepairs select 0)";
			action = "[dyna_cursorTarget,'repair','hitlbwheel'] spawn EPOCH_client_VehicleMaintananceDo";
			icon = "x\addons\a3_epoch_code\Data\UI\buttons\Repair_Wheel.paa";
			tooltip = "Repair 4th Left Wheel";
		};
		class RepairTire5
		{
			condition = "'hitrfwheel' in (EPOCH_VehicleRepairs select 0)";
			action = "[dyna_cursorTarget,'repair','hitrfwheel'] spawn EPOCH_client_VehicleMaintananceDo";
			icon = "x\addons\a3_epoch_code\Data\UI\buttons\Repair_Wheel.paa";
			tooltip = "Repair 1st Right Wheel";
		};
		class RepairTire6
		{
			condition = "'hitrf2wheel' in (EPOCH_VehicleRepairs select 0)";
			action = "[dyna_cursorTarget,'repair','hitrf2wheel'] spawn EPOCH_client_VehicleMaintananceDo";
			icon = "x\addons\a3_epoch_code\Data\UI\buttons\Repair_Wheel.paa";
			tooltip = "Repair 2nd Right Wheel";
		};
		class RepairTire7
		{
			condition = "'hitrmwheel' in (EPOCH_VehicleRepairs select 0)";
			action = "[dyna_cursorTarget,'repair','hitrmwheel'] spawn EPOCH_client_VehicleMaintananceDo";
			icon = "x\addons\a3_epoch_code\Data\UI\buttons\Repair_Wheel.paa";
			tooltip = "Repair 3rd Right Wheel";
		};
		class RepairTire8
		{
			condition = "'hitrbwheel' in (EPOCH_VehicleRepairs select 0)";
			action = "[dyna_cursorTarget,'repair','hitrbwheel'] spawn EPOCH_client_VehicleMaintananceDo";
			icon = "x\addons\a3_epoch_code\Data\UI\buttons\Repair_Wheel.paa";
			tooltip = "Repair 4th Right Wheel";
		};
		class ReplaceTire1
		{
			condition = "'hitlfwheel' in (EPOCH_VehicleRepairs select 2)";
			action = "[dyna_cursorTarget,'replace','hitlfwheel'] spawn EPOCH_client_VehicleMaintananceDo";
			icon = "x\addons\a3_epoch_code\Data\UI\buttons\Replace_Wheel.paa";
			tooltip = "Replace 1st Left Wheel";
		};
		class ReplaceTire2
		{
			condition = "'hitlf2wheel' in (EPOCH_VehicleRepairs select 2)";
			action = "[dyna_cursorTarget,'replace','hitlf2wheel'] spawn EPOCH_client_VehicleMaintananceDo";
			icon = "x\addons\a3_epoch_code\Data\UI\buttons\Replace_Wheel.paa";
			tooltip = "Replace 2nd Left Wheel";
		};
		class ReplaceTire3
		{
			condition = "'hitlmwheel' in (EPOCH_VehicleRepairs select 2)";
			action = "[dyna_cursorTarget,'replace','hitlmwheel'] spawn EPOCH_client_VehicleMaintananceDo";
			icon = "x\addons\a3_epoch_code\Data\UI\buttons\Replace_Wheel.paa";
			tooltip = "Replace 3rd Left Wheel";
		};
		class ReplaceTire4
		{
			condition = "'hitlbwheel' in (EPOCH_VehicleRepairs select 2)";
			action = "[dyna_cursorTarget,'replace','hitlbwheel'] spawn EPOCH_client_VehicleMaintananceDo";
			icon = "x\addons\a3_epoch_code\Data\UI\buttons\Replace_Wheel.paa";
			tooltip = "Replace 4th Left Wheel";
		};
		class ReplaceTire5
		{
			condition = "'hitrfwheel' in (EPOCH_VehicleRepairs select 2)";
			action = "[dyna_cursorTarget,'replace','hitrfwheel'] spawn EPOCH_client_VehicleMaintananceDo";
			icon = "x\addons\a3_epoch_code\Data\UI\buttons\Replace_Wheel.paa";
			tooltip = "Replace 1st Right Wheel";
		};
		class ReplaceTire6
		{
			condition = "'hitrf2wheel' in (EPOCH_VehicleRepairs select 2)";
			action = "[dyna_cursorTarget,'replace','hitrf2wheel'] spawn EPOCH_client_VehicleMaintananceDo";
			icon = "x\addons\a3_epoch_code\Data\UI\buttons\Replace_Wheel.paa";
			tooltip = "Replace 2nd Right Wheel";
		};
		class ReplaceTire7
		{
			condition = "'hitrmwheel' in (EPOCH_VehicleRepairs select 2)";
			action = "[dyna_cursorTarget,'replace','hitrmwheel'] spawn EPOCH_client_VehicleMaintananceDo";
			icon = "x\addons\a3_epoch_code\Data\UI\buttons\Replace_Wheel.paa";
			tooltip = "Replace 3rd Right Wheel";
		};
		class ReplaceTire8
		{
			condition = "'hitrbwheel' in (EPOCH_VehicleRepairs select 2)";
			action = "[dyna_cursorTarget,'replace','hitrbwheel'] spawn EPOCH_client_VehicleMaintananceDo";
			icon = "x\addons\a3_epoch_code\Data\UI\buttons\Replace_Wheel.paa";
			tooltip = "Replace 4th Right Wheel";
		};
		class RepairAvionics
		{
			condition = "'hitavionics' in (EPOCH_VehicleRepairs select 0) || 'hitavionics' in (EPOCH_VehicleRepairs select 2)";
			action = "[dyna_cursorTarget,'replace','hitavionics'] spawn EPOCH_client_VehicleMaintananceDo";
			icon = "x\addons\a3_epoch_code\Data\UI\buttons\Repair_Avionics.paa";
			tooltip = "Repair Avionics";
		};
	};
	class Remove
	{
		condition = "!((EPOCH_VehicleRepairs select 1) isequalto []) && EPOCH_AdvancedVehicleRepair_Enabled";
		action = "";
		icon = "x\addons\a3_epoch_code\Data\UI\buttons\Remove_Wheel.paa";
		tooltip = "Remove Parts";
		class RemoveEngine
		{
			condition = "'hitengine' in (EPOCH_VehicleRepairs select 1)";
			action = "[dyna_cursorTarget,'remove','hitengine'] spawn EPOCH_client_VehicleMaintananceDo";
			icon = "x\addons\a3_epoch_code\Data\UI\buttons\Remove_Engine.paa";
			tooltip = "Remove Engine";
		};
		class RemoveTire1
		{
			condition = "'hitlfwheel' in (EPOCH_VehicleRepairs select 1)";
			action = "[dyna_cursorTarget,'remove','hitlfwheel'] spawn EPOCH_client_VehicleMaintananceDo";
			icon = "x\addons\a3_epoch_code\Data\UI\buttons\Remove_Wheel.paa";
			tooltip = "Remove 1st Left Wheel";
		};
		class RemoveTire2
		{
			condition = "'hitlf2wheel' in (EPOCH_VehicleRepairs select 1)";
			action = "[dyna_cursorTarget,'remove','hitlf2wheel'] spawn EPOCH_client_VehicleMaintananceDo";
			icon = "x\addons\a3_epoch_code\Data\UI\buttons\Remove_Wheel.paa";
			tooltip = "Remove 2nd Left Wheel";
		};
		class RemoveTire3
		{
			condition = "'hitlmwheel' in (EPOCH_VehicleRepairs select 1)";
			action = "[dyna_cursorTarget,'remove','hitlmwheel'] spawn EPOCH_client_VehicleMaintananceDo";
			icon = "x\addons\a3_epoch_code\Data\UI\buttons\Remove_Wheel.paa";
			tooltip = "Remove 3rd Left Wheel";
		};
		class RemoveTire4
		{
			condition = "'hitlbwheel' in (EPOCH_VehicleRepairs select 1)";
			action = "[dyna_cursorTarget,'remove','hitlbwheel'] spawn EPOCH_client_VehicleMaintananceDo";
			icon = "x\addons\a3_epoch_code\Data\UI\buttons\Remove_Wheel.paa";
			tooltip = "Remove 4th Left Wheel";
		};
		class RemoveTire5
		{
			condition = "'hitrfwheel' in (EPOCH_VehicleRepairs select 1)";
			action = "[dyna_cursorTarget,'remove','hitrfwheel'] spawn EPOCH_client_VehicleMaintananceDo";
			icon = "x\addons\a3_epoch_code\Data\UI\buttons\Remove_Wheel.paa";
			tooltip = "Remove 1st Right Wheel";
		};
		class RemoveTire6
		{
			condition = "'hitrf2wheel' in (EPOCH_VehicleRepairs select 1)";
			action = "[dyna_cursorTarget,'remove','hitrf2wheel'] spawn EPOCH_client_VehicleMaintananceDo";
			icon = "x\addons\a3_epoch_code\Data\UI\buttons\Remove_Wheel.paa";
			tooltip = "Remove 2nd Right Wheel";
		};
		class RemoveTire7
		{
			condition = "'hitrmwheel' in (EPOCH_VehicleRepairs select 1)";
			action = "[dyna_cursorTarget,'remove','hitrmwheel'] spawn EPOCH_client_VehicleMaintananceDo";
			icon = "x\addons\a3_epoch_code\Data\UI\buttons\Remove_Wheel.paa";
			tooltip = "Remove 3rd Right Wheel";
		};
		class RemoveTire8
		{
			condition = "'hitrbwheel' in (EPOCH_VehicleRepairs select 1)";
			action = "[dyna_cursorTarget,'remove','hitrbwheel'] spawn EPOCH_client_VehicleMaintananceDo";
			icon = "x\addons\a3_epoch_code\Data\UI\buttons\Remove_Wheel.paa";
			tooltip = "Remove 4th Right Wheel";
		};
	};
	class UpgradeVehicle
	{
		condition = "dyna_isVehicle";
		action = "dyna_cursorTarget call EPOCH_client_upgradeVehicleCheck;";
		icon = "x\addons\a3_epoch_code\Data\UI\buttons\build_upgrade.paa";
		tooltip = "Upgrade Vehicle";
		class Upgrade0
		{
			condition = "(count Ignatz_VehicleUpgradeArray) > 0";
			action = "(Ignatz_VehicleUpgradeArray select 0) call EPOCH_client_upgradeVehicle";
			iconcode = "gettext (configfile >> 'CfgVehicles' >> (Ignatz_VehicleUpgradeArray select 0 select 1) >> 'picture')";
			tooltipcode = "format ['Upgrade to %1 - %2',(Ignatz_VehicleUpgradeArray select 0 select 2),(Ignatz_VehicleUpgradeArray select 0 select 3)]";
		};
		class Upgrade1
		{
			condition = "(count Ignatz_VehicleUpgradeArray) > 1";
			action = "(Ignatz_VehicleUpgradeArray select 1) call EPOCH_client_upgradeVehicle";
			iconcode = "gettext (configfile >> 'CfgVehicles' >> (Ignatz_VehicleUpgradeArray select 1 select 1) >> 'picture')";
			tooltipcode = "format ['Upgrade to %1 - %2',(Ignatz_VehicleUpgradeArray select 1 select 2),(Ignatz_VehicleUpgradeArray select 1 select 3)]";
		};
		class Upgrade2
		{
			condition = "(count Ignatz_VehicleUpgradeArray) > 2";
			action = "(Ignatz_VehicleUpgradeArray select 2) call EPOCH_client_upgradeVehicle";
			iconcode = "gettext (configfile >> 'CfgVehicles' >> (Ignatz_VehicleUpgradeArray select 2 select 1) >> 'picture')";
			tooltipcode = "format ['Upgrade to %1 - %2',(Ignatz_VehicleUpgradeArray select 2 select 2),(Ignatz_VehicleUpgradeArray select 2 select 3)]";
		};
		class Upgrade3
		{
			condition = "(count Ignatz_VehicleUpgradeArray) > 3";
			action = "(Ignatz_VehicleUpgradeArray select 3) call EPOCH_client_upgradeVehicle";
			iconcode = "gettext (configfile >> 'CfgVehicles' >> (Ignatz_VehicleUpgradeArray select 3 select 1) >> 'picture')";
			tooltipcode = "format ['Upgrade to %1 - %2',(Ignatz_VehicleUpgradeArray select 3 select 2),(Ignatz_VehicleUpgradeArray select 3 select 3)]";
		};
		class Upgrade4
		{
			condition = "(count Ignatz_VehicleUpgradeArray) > 4";
			action = "(Ignatz_VehicleUpgradeArray select 4) call EPOCH_client_upgradeVehicle";
			iconcode = "gettext (configfile >> 'CfgVehicles' >> (Ignatz_VehicleUpgradeArray select 4 select 1) >> 'picture')";
			tooltipcode = "format ['Upgrade to %1 - %2',(Ignatz_VehicleUpgradeArray select 4 select 2),(Ignatz_VehicleUpgradeArray select 4 select 3)]";
		};
	};
};

//Groups
class Groups
{
	condition = "dyna_isPlayer";
	action = "";
	icon = "x\addons\a3_epoch_code\Data\UI\buttons\group_menu_ca.paa";
	tooltip = "Groups Menu";
	class Group
	{
		condition = "dyna_isPlayer";
		action = "call EPOCH_Inventory_Group;";
		icon = "x\addons\a3_epoch_code\Data\UI\buttons\perm_group_menu_ca.paa";
		tooltip = "Perm Group Menu";
	};
	class TempGroup
	{
		condition = "dyna_isPlayer";
		action = "call EPOCH_Inventory_TempGroup;";
		icon = "x\addons\a3_epoch_code\Data\UI\buttons\temp_group_menu_ca.paa";
		tooltip = "Temp Group Menu";
	};
};
class player_group_requests
{
	condition = "dyna_isPlayer && !(Epoch_invited_GroupUIDs isEqualTo[])";
	action = "call EPOCH_Inventory_iGroup;";
	icon = "x\addons\a3_epoch_code\Data\UI\buttons\group_requests_ca.paa";
	tooltip = "Group Requests";
};
class player_tempGroup_requests
{
	condition = "dyna_isPlayer && !(Epoch_invited_tempGroupUIDs isEqualTo[])";
	action = "call EPOCH_Inventory_itempGroup;";
	icon = "x\addons\a3_epoch_code\Data\UI\buttons\group_requests_ca.paa";
	tooltip = "Temp Group Requests";
};

// Working defibrillator
class player_revive
{
	condition = "dyna_isDeadPlayer && ('ItemDefibrillator' in dyna_magazinesPlayer)";
	action = "[dyna_cursorTarget, player, Epoch_personalToken] remoteExec ['EPOCH_server_revivePlayer',2];";
	icon = "x\addons\a3_epoch_code\Data\UI\buttons\group_requests_ca.paa";
	tooltip = "Revive Player";
};

// Vehicle Keys
class give_keys_menu
{
	condition = "dyna_plyrHasKeys && dyna_isPlayer";
	action = "call EPOCH_client_getPlayerKeysArr";
	icon = "x\addons\a3_epoch_code\Data\UI\buttons\Drink.paa";
	tooltip = "Give Key";

	class keys_1
	{
		condition = "(count EPOCH_playerKeys > 0)";
		action = "EPOCH_fnc_server_transferKeys = [player,dyna_cursorTarget,0]; publicVariableServer ""EPOCH_fnc_server_transferKeys""; ";
		icon = "x\addons\a3_epoch_code\Data\UI\buttons\Drink.paa";
		tooltip = "format['%1 Keys for %2',((EPOCH_playerKeys select 0) select 0),getText(configFile >> 'CfgVehicles' >> ((EPOCH_playerKeys select 0) select 1) >> 'displayName')]";
	};

	class keys_2
	{
		condition = "(count EPOCH_playerKeys > 1)";
		action = "EPOCH_fnc_server_transferKeys = [player,dyna_cursorTarget,1]; publicVariableServer ""EPOCH_fnc_server_transferKeys""; ";
		icon = "x\addons\a3_epoch_code\Data\UI\buttons\Drink.paa";
		tooltip = "format['%1 Keys for %2',((EPOCH_playerKeys select 1) select 0),getText(configFile >> 'CfgVehicles' >> ((EPOCH_playerKeys select 1) select 1) >> 'displayName')]";
	};

	class keys_3
	{
		condition = "(count EPOCH_playerKeys > 2)";
		action = "EPOCH_fnc_server_transferKeys = [player,dyna_cursorTarget,2]; publicVariableServer ""EPOCH_fnc_server_transferKeys""; ";
		icon = "x\addons\a3_epoch_code\Data\UI\buttons\Drink.paa";
		tooltip = "format['%1 Keys for %2',((EPOCH_playerKeys select 2) select 0),getText(configFile >> 'CfgVehicles' >> ((EPOCH_playerKeys select 2) select 1) >> 'displayName')]";
	};

	class keys_4
	{
		condition = "(count EPOCH_playerKeys > 3)";
		action = "EPOCH_fnc_server_transferKeys = [player,dyna_cursorTarget,3]; publicVariableServer ""EPOCH_fnc_server_transferKeys""; ";
		icon = "x\addons\a3_epoch_code\Data\UI\buttons\Drink.paa";
		tooltip = "format['%1 Keys for %2',((EPOCH_playerKeys select 3) select 0),getText(configFile >> 'CfgVehicles' >> ((EPOCH_playerKeys select 3) select 1) >> 'displayName')]";
	};

	class keys_5
	{
		condition = "(count EPOCH_playerKeys > 4)";
		action = "EPOCH_fnc_server_transferKeys = [player,dyna_cursorTarget,4]; publicVariableServer ""EPOCH_fnc_server_transferKeys""; ";
		icon = "x\addons\a3_epoch_code\Data\UI\buttons\Drink.paa";
		tooltip = "format['%1 Keys for %2',((EPOCH_playerKeys select 4) select 0),getText(configFile >> 'CfgVehicles' >> ((EPOCH_playerKeys select 4) select 1) >> 'displayName')]";
	};

	class keys_6
	{
		condition = "(count EPOCH_playerKeys > 5)";
		action = "EPOCH_fnc_server_transferKeys = [player,dyna_cursorTarget,5]; publicVariableServer ""EPOCH_fnc_server_transferKeys""; ";
		icon = "x\addons\a3_epoch_code\Data\UI\buttons\Drink.paa";
		tooltip = "format['%1 Keys for %2',((EPOCH_playerKeys select 5) select 0),getText(configFile >> 'CfgVehicles' >> ((EPOCH_playerKeys select 5) select 1) >> 'displayName')]";
	};

	class keys_7
	{
		condition = "(count EPOCH_playerKeys > 6)";
		action = "EPOCH_fnc_server_transferKeys = [player,dyna_cursorTarget,6]; publicVariableServer ""EPOCH_fnc_server_transferKeys""; ";
		icon = "x\addons\a3_epoch_code\Data\UI\buttons\Drink.paa";
		tooltip = "format['%1 Keys for %2',((EPOCH_playerKeys select 6) select 0),getText(configFile >> 'CfgVehicles' >> ((EPOCH_playerKeys select 6) select 1) >> 'displayName')]";
	};

	class keys_8
	{
		condition = "(count EPOCH_playerKeys > 7)";
		action = "EPOCH_fnc_server_transferKeys = [player,dyna_cursorTarget,7]; publicVariableServer ""EPOCH_fnc_server_transferKeys""; ";
		icon = "x\addons\a3_epoch_code\Data\UI\buttons\Drink.paa";
		tooltip = "format['%1 Keys for %2',((EPOCH_playerKeys select 7) select 0),getText(configFile >> 'CfgVehicles' >> ((EPOCH_playerKeys select 7) select 1) >> 'displayName')]";
	};

	class keys_9
	{
		condition = "(count EPOCH_playerKeys > 8)";
		action = "EPOCH_fnc_server_transferKeys = [player,dyna_cursorTarget,8]; publicVariableServer ""EPOCH_fnc_server_transferKeys""; ";
		icon = "x\addons\a3_epoch_code\Data\UI\buttons\Drink.paa";
		tooltip = "format['%1 Keys for %2',((EPOCH_playerKeys select 8) select 0),getText(configFile >> 'CfgVehicles' >> ((EPOCH_playerKeys select 8) select 1) >> 'displayName')]";
	};

	class keys_10
	{
		condition = "(count EPOCH_playerKeys > 9)";
		action = "EPOCH_fnc_server_transferKeys = [player,dyna_cursorTarget,9]; publicVariableServer ""EPOCH_fnc_server_transferKeys""; ";
		icon = "x\addons\a3_epoch_code\Data\UI\buttons\Drink.paa";
		tooltip = "format['%1 Keys for %2',((EPOCH_playerKeys select 9) select 0),getText(configFile >> 'CfgVehicles' >> ((EPOCH_playerKeys select 9) select 1) >> 'displayName')]";
	};

	class keys_11
	{
		condition = "(count EPOCH_playerKeys > 10)";
		action = "EPOCH_fnc_server_transferKeys = [player,dyna_cursorTarget,10]; publicVariableServer ""EPOCH_fnc_server_transferKeys""; ";
		icon = "x\addons\a3_epoch_code\Data\UI\buttons\Drink.paa";
		tooltip = "format['%1 Keys for %2',((EPOCH_playerKeys select 10) select 0),getText(configFile >> 'CfgVehicles' >> ((EPOCH_playerKeys select 10) select 1) >> 'displayName')]";
	};

	class keys_12
	{
		condition = "(count EPOCH_playerKeys > 11)";
		action = "EPOCH_fnc_server_transferKeys = [player,dyna_cursorTarget,11]; publicVariableServer ""EPOCH_fnc_server_transferKeys""; ";
		icon = "x\addons\a3_epoch_code\Data\UI\buttons\Drink.paa";
		tooltip = "format['%1 Keys for %2',((EPOCH_playerKeys select 11) select 0),getText(configFile >> 'CfgVehicles' >> ((EPOCH_playerKeys select 11) select 1) >> 'displayName')]";
	};

	class keys_13
	{
		condition = "(count EPOCH_playerKeys > 12)";
		action = "EPOCH_fnc_server_transferKeys = [player,dyna_cursorTarget,12]; publicVariableServer ""EPOCH_fnc_server_transferKeys""; ";
		icon = "x\addons\a3_epoch_code\Data\UI\buttons\Drink.paa";
		tooltip = "format['%1 Keys for %2',((EPOCH_playerKeys select 12) select 0),getText(configFile >> 'CfgVehicles' >> ((EPOCH_playerKeys select 12) select 1) >> 'displayName')]";
	};

	class keys_14
	{
		condition = "(count EPOCH_playerKeys > 13)";
		action = "EPOCH_fnc_server_transferKeys = [player,dyna_cursorTarget,13]; publicVariableServer ""EPOCH_fnc_server_transferKeys""; ";
		icon = "x\addons\a3_epoch_code\Data\UI\buttons\Drink.paa";
		tooltip = "format['%1 Keys for %2',((EPOCH_playerKeys select 13) select 0),getText(configFile >> 'CfgVehicles' >> ((EPOCH_playerKeys select 13) select 1) >> 'displayName')]";
	};

	class keys_15
	{
		condition = "(count EPOCH_playerKeys > 14)";
		action = "EPOCH_fnc_server_transferKeys = [player,dyna_cursorTarget,14]; publicVariableServer ""EPOCH_fnc_server_transferKeys""; ";
		icon = "x\addons\a3_epoch_code\Data\UI\buttons\Drink.paa";
		tooltip = "format['%1 Keys for %2',((EPOCH_playerKeys select 14) select 0),getText(configFile >> 'CfgVehicles' >> ((EPOCH_playerKeys select 14) select 1) >> 'displayName')]";
	};

	class keys_16
	{
		condition = "(count EPOCH_playerKeys > 15)";
		action = "EPOCH_fnc_server_transferKeys = [player,dyna_cursorTarget,15]; publicVariableServer ""EPOCH_fnc_server_transferKeys""; ";
		icon = "x\addons\a3_epoch_code\Data\UI\buttons\Drink.paa";
		tooltip = "format['%1 Keys for %2',((EPOCH_playerKeys select 15) select 0),getText(configFile >> 'CfgVehicles' >> ((EPOCH_playerKeys select 15) select 1) >> 'displayName')]";
	};

	class keys_17
	{
		condition = "(count EPOCH_playerKeys > 16)";
		action = "EPOCH_fnc_server_transferKeys = [player,dyna_cursorTarget,16]; publicVariableServer ""EPOCH_fnc_server_transferKeys""; ";
		icon = "x\addons\a3_epoch_code\Data\UI\buttons\Drink.paa";
		tooltip = "format['%1 Keys for %2',((EPOCH_playerKeys select 16) select 0),getText(configFile >> 'CfgVehicles' >> ((EPOCH_playerKeys select 16) select 1) >> 'displayName')]";
	};

	class keys_18
	{
		condition = "(count EPOCH_playerKeys > 17)";
		action = "EPOCH_fnc_server_transferKeys = [player,dyna_cursorTarget,17]; publicVariableServer ""EPOCH_fnc_server_transferKeys""; ";
		icon = "x\addons\a3_epoch_code\Data\UI\buttons\Drink.paa";
		tooltip = "format['%1 Keys for %2',((EPOCH_playerKeys select 17) select 0),getText(configFile >> 'CfgVehicles' >> ((EPOCH_playerKeys select 17) select 1) >> 'displayName')]";
	};

	class keys_19
	{
		condition = "(count EPOCH_playerKeys > 18)";
		action = "EPOCH_fnc_server_transferKeys = [player,dyna_cursorTarget,18]; publicVariableServer ""EPOCH_fnc_server_transferKeys""; ";
		icon = "x\addons\a3_epoch_code\Data\UI\buttons\Drink.paa";
		tooltip = "format['%1 Keys for %2',((EPOCH_playerKeys select 18) select 0),getText(configFile >> 'CfgVehicles' >> ((EPOCH_playerKeys select 18) select 1) >> 'displayName')]";
	};

	class keys_20
	{
		condition = "(count EPOCH_playerKeys > 19)";
		action = "EPOCH_fnc_server_transferKeys = [player,dyna_cursorTarget,19]; publicVariableServer ""EPOCH_fnc_server_transferKeys""; ";
		icon = "x\addons\a3_epoch_code\Data\UI\buttons\Drink.paa";
		tooltip = "format['%1 Keys for %2',((EPOCH_playerKeys select 19) select 0),getText(configFile >> 'CfgVehicles' >> ((EPOCH_playerKeys select 19) select 1) >> 'displayName')]";
	};
};
