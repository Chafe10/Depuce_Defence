-- DePuce Defence
-- Author: Chafe10

local Objectives = import('/lua/ScenarioFramework.lua').Objectives
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local BaseManager = import('/lua/ai/opai/basemanager.lua')
local Buff = import('/lua/sim/Buff.lua')
local Cinematics = import('/lua/cinematics.lua')
local EffectUtilities = import('/lua/effectutilities.lua')
local M1OrderAI = import('/maps/DePuce_Defence/DePuce_Defence_M1OrderAI.lua')
local M3OrderAI = import('/maps/DePuce_Defence/DePuce_Defence_M3OrderAI.lua')
local M3SeraphimAI = import('/maps/DePuce_Defence/DePuce_Defence_M3SeraphimAI.lua')
local M2DePuceAI = import('/maps/DePuce_Defence/DePuce_Defence_M2DePuceAI.lua')
local M2CivAI = import('/maps/DePuce_Defence/DePuce_Defence_M2CivAI.lua')
local M4CybranAI = import('/maps/DePuce_Defence/DePuce_Defence_M4CybranAI.lua')
local M4OrderAI = import('/maps/DePuce_Defence/DePuce_Defence_M4OrderAI.lua')
local M4SeraphimAI = import('/maps/DePuce_Defence/DePuce_Defence_M4SeraphimAI.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Utilities = import('/lua/utilities.lua')
local OpStrings = import('/maps/DePuce_Defence/DePuce_Defence_strings.lua')

-- Global Variables
M3Counter = 0
M4Counter = 0
MapVersionNumber = "2016.12.10.1 BETA V2"
SpawnPlayerCDR = {0,0,0,0,0,0,0,0,0,0,0}
ScenarioInfo.PlayerCDR = {0,0,0,0,0,0,0,0,0,0,0}
SpawnPlayerCDRTotal = 0
ACU6Dead = 0
ACU7Dead = 0
ACU8Dead = 0
ACU9Dead = 0
ACU10Dead = 0
ACU11Dead = 0
ACUDeathCounter = 0
NukeWaitSecondsDifficultyMultiplier = {1.2,1,0.8}

-- Army IDs
ScenarioInfo.Cybran = 1
ScenarioInfo.Order = 2
ScenarioInfo.Seraphim = 3
ScenarioInfo.Civilians = 4
ScenarioInfo.DePuce = 5
ScenarioInfo.Player1 = 6
ScenarioInfo.Player2 = 7
ScenarioInfo.Player3 = 8
ScenarioInfo.Player4 = 9
ScenarioInfo.Player5 = 10
ScenarioInfo.Player6 = 11

-- Local Variables
local Cybran = ScenarioInfo.Cybran
local Order = ScenarioInfo.Order
local Seraphim = ScenarioInfo.Seraphim
local Civilians = ScenarioInfo.Civilians
local DePuce = ScenarioInfo.DePuce
local Player1 = ScenarioInfo.Player1
local M2Timer = 600
local ScienceCentreDestroyed = false
local NE_Centre_Destroyed = false

local AssignedObjectives = {}
local Difficulty = ScenarioInfo.Options.Difficulty
local CheatRate = {0.6,1,1.4}

-- Debug
local Debug = false
local SkipNIS1 = false
local SkipMission1 = false


--Startup
function OnPopulate(scenario)
	LOG('Map version = ' .. MapVersionNumber)
	factionIdx = GetArmyBrain(6):GetFactionIndex()
	if factionIdx >3 then 
		Debug = true
		LOG("Player1 is seraphim activating debug mode")
	end
    ScenarioUtils.InitializeScenarioArmies()
	ScenarioFramework.SetPlayableArea('1ST_MISSION_AREA', false)
    ScenarioFramework.SetSharedUnitCap(3600)
	SetArmyUnitCap(Order, 4000)
	SetArmyUnitCap(Seraphim, 4000)
	SetArmyUnitCap(Cybran, 1500)
	SetArmyUnitCap(DePuce, 2000)
	SetArmyUnitCap(Civilians, 500)
	SetArmyColor('DePuce', 128, 128, 180)
	SetArmyColor('Civilians', 160, 30, 200)
	SetArmyColor('Order', 159, 216, 2)
	SetArmyColor('Seraphim', 167, 150, 2)
	SetArmyColor('Cybran', 225, 70, 0)
	ScenarioUtils.CreateArmyGroup('Civilians', 'North_East_Town')
	ScenarioInfo.NE_Science_Building = ScenarioUtils.CreateArmyUnit('Civilians', 'NE_Science_Building')
	ScenarioFramework.CreateUnitDestroyedTrigger(M3S1CentreDestroyed, ScenarioInfo.NE_Science_Building)
	ScenarioInfo.NE_Science_Building:SetCustomName("Science Facility Bulwark")
	M2CivAI.Civ_Science_Facility_BaseAI()
	M2DePuceAI.DePuce_BaseAI()
    ScenarioInfo.DePuceACU = ScenarioFramework.SpawnCommander('DePuce', 'DePuce_ACU', false, 'CDR DePuce', true, DePuceDeath, 
    {'ResourceAllocation', 'AdvancedEngineering', 'T3Engineering', 'Shield','ShieldGeneratorField'})
    ScenarioInfo.DePuceSACU = ScenarioFramework.SpawnCommander('DePuce', 'DePuce_SACU', false, 'sCDR Blaze', false, false, 
    {'ResourceAllocation', 'AdvancedCoolingUpgrade', 'Shield','ShieldGeneratorField'})
	ScenarioUtils.CreateArmyGroup('Seraphim', 'Seraphim_Jammer_Crystals')
	ScenarioUtils.CreateArmyGroup('Order', 'Order_Jammer_Crystals')
    GetArmyBrain(DePuce):SetResourceSharing(false)
    GetArmyBrain(Civilians):SetResourceSharing(false)
end

function OnStart()
    ForkThread(IntroMission1)
	end

--Mission 1/

function IntroMission1()
	Cinematics.EnterNISMode()
	ForkThread(SpawnAllACUs)
	local VisMarker2 = ScenarioFramework.CreateVisibleAreaLocation(30, 'Order_M1_South_Base_Marker', 3, ArmyBrains[Player1])
	Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Start_ACU_Camera_2'), 0)
	ScenarioFramework.Dialogue(OpStrings.M1_Intro, nil, true)
	Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Start_ACU_Camera_1'), 2)
    Cinematics.ExitNISMode()
    ScenarioInfo.MissionNumber = 1
    if Debug then
		ForkThread(All_Reminders)
		local DebugVisMarker = ScenarioFramework.CreateVisibleAreaLocation(3000, 'Debug_Vision_Marker', 0, ArmyBrains[Player1])
		LOG("Debug Vision Marker Enabled")
		M2Timer = 20
		LOG("M2 Timer set to ".. M2Timer .." seconds")
    end
	StartMission1()
end

function StartMission1()
    LOG('Starting Misson 1')
	SpawnPlayerCDRTotal = SpawnPlayerCDR[6] + SpawnPlayerCDR[7] + SpawnPlayerCDR[8] + SpawnPlayerCDR[9] + SpawnPlayerCDR[10] + SpawnPlayerCDR[11]
	M1OrderAI.Order_M1_South_BaseAI(SpawnPlayerCDRTotal)
	LOG("Players = " .. SpawnPlayerCDRTotal)
	if Difficulty >=2 then
		ScenarioUtils.CreateArmyGroup('Cybran', 'Cybran_Offscreen_Units_Medium')
		ScenarioUtils.CreateArmyGroup('Order', 'Order_Offscreen_Units_Medium')
		ScenarioUtils.CreateArmyGroup('Seraphim', 'Seraphim_Offscreen_Units_Medium')
		LOG("Off Screen Units Created")
		if Difficulty >=3 then
			ScenarioUtils.CreateArmyGroup('Cybran', 'Cybran_Offscreen_Units_Hard')
			ScenarioUtils.CreateArmyGroup('Order', 'Order_Offscreen_Units_Hard')
			ScenarioUtils.CreateArmyGroup('Seraphim', 'Seraphim_Offscreen_Units_Hard')
		end
	end
	AICheats(Order, SpawnPlayerCDRTotal)
    ----------------------------------------------------------
    --Mission 1 Primary Objective 1 - Destroy Order South Base
    ----------------------------------------------------------
	ScenarioInfo.M1P1 = Objectives.CategoriesInArea(
    'primary',                      # type
    'incomplete',                   # complete
    'Destroy the order southern base',    # title
    'Eliminate the marked Order structures.',  # description
    'kill',                         # action
    {                               # target
        MarkUnits = true,
        FlashVisible = true,
		ShowFaction = 'Aeon',
        Requirements = {
            {   
                Area = 'Order_M1_South_Base_Area',
                Category = categories.FACTORY + categories.ECONOMIC + categories.CONSTRUCTION + categories.uab4301 + categories.uab4302 + categories.uab3104,
                CompareOp = '<=',
                Value = 0,
                ArmyIndex = Order,
            },
        },
    }
)
	ScenarioFramework.CreateTimerTrigger(M1P1Reminder1, 1500)
	ScenarioFramework.CreateTimerTrigger(Generic_Reminder_1, 5040)
    LOG('Assigned Mission 1 Objective 1')
    ScenarioInfo.M1P1:AddResultCallback(
        function(result)
            if(result) then
			    LOG('Objective Complete. Starting Mission 2')
				M1OrderAI.DisableBase()
				ScenarioFramework.Dialogue(OpStrings.M1_Complete, IntroMission2, true)
            end
        end
    )
	table.insert(AssignedObjectives, ScenarioInfo.M1P1)
	LOG('Starting Mission 2 Secondary Objective 1')
end

function IntroMission2()
	LOG('Intro Mission 2')
	ScenarioInfo.Civ_Science_Building = ScenarioUtils.CreateArmyUnit('Civilians', 'Civ_Science_Building')
	ScenarioFramework.CreateUnitDestroyedTrigger(M2S1CentreDestroyed, ScenarioInfo.Civ_Science_Building)
	ScenarioInfo.Civ_Science_Building:SetCustomName("Science Facility Equium")
	ScenarioFramework.SetPlayableArea('2ND_MISSION_AREA', true)
    ScenarioInfo.MissionNumber = 2
    StartMission2a()
end

--Mission 2
function StartMission2a()
	LOG('Starting Mission 2 Part 1/3')
	LOG('Starting Mission 2 Primary Objective 1')
	ScenarioFramework.Dialogue(OpStrings.M2a_intro, nil, true)
	LOG('Timer Started')
	M2CivAI.Civ_Science_Facility_Patrol()
    ---------------------------------------
    --Mission 2 Primary Objective 1 - Timer
    ---------------------------------------
    ScenarioInfo.M2P1 = Objectives.Timer(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Prepare for incoming air attacks',  -- title
        'Prepare your forces for the air attacks',  -- description
        {                               -- target
            Timer = M2Timer,
            ExpireResult = 'complete',
        }
   )
    ScenarioInfo.M2P1:AddResultCallback(
        function(result)
            if(result) then
				ScenarioFramework.Dialogue(OpStrings.M2b_intro, StartMission2b, true)
            end
        end
   )
    table.insert(AssignedObjectives, ScenarioInfo.M2P1)
    WaitSeconds(5)
    -----------------------------------------------
    --Mission 2 Primary Objective 2 - Defend DePuce
    -----------------------------------------------
    ScenarioInfo.M2P2 = Objectives.Basic(
        'primary',                      # type
        'incomplete',                   # complete
        'Defend DePuce',                 # title
        'Ensure that DePuce survives',  # description
        'Protect',                         # action
        {                               # target
            MarkUnits = true,
            Units = {ScenarioInfo.DePuceACU},
        }
   )
    table.insert(AssignedObjectives, ScenarioInfo.M2P2)
    # Secondary Objectives
	WaitSeconds(5)
	ForkThread(M2ProtectCivScience)
end

function M2ProtectCivScience()
	LOG('Starting Mission 2 Secondary Objective 1')
    -------------------------------------------------------------------
    --Mission 2 Secondary Objective 1 - Protect	Science Facility Equium
    -------------------------------------------------------------------
    ScenarioInfo.M2S1 = Objectives.Basic(
        'secondary',                      # type
        'incomplete',                   # complete
        'Protect Science Facility Equium',  # title
        'Protect Science Facility Equium from enemy attacks',  # description
		'Protect',                         # action
        {
			MarkUnits = true,
			Units = {ScenarioInfo.Civ_Science_Building}
        }
	)
    ScenarioInfo.M2S1:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(OpStrings.M2S1_complete, nil, false)
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M2S1)
end

function StartMission2b()
	LOG('Starting Mission 2 Part 2/3')
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'Order_M2_Scout_1', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'Order_M3_Air_Attack_Chain_1')

	platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'Order_M2_Scout_2', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'Order_M3_Air_Attack_Chain_2')
	
	platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'Order_M2_Air_Assault_Easy', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'Order_M3_Air_Attack_Chain_1')
	WaitSeconds(1)
	if Difficulty >=2 then
		platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'Order_M2_Air_Assault_Medium', 'AttackFormation')
		ScenarioFramework.PlatoonPatrolChain(platoon, 'Order_M3_Air_Attack_Chain_1')
		platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'Order_M2_Air_Assault_EXP_Med', 'AttackFormation')
		ScenarioFramework.PlatoonPatrolChain(platoon, 'Order_M3_Air_Attack_Chain_1')
		if SpawnPlayerCDRTotal >=4 then
			platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'Order_M2_Air_Assault_Med_More_Than_2', 'AttackFormation')
			ScenarioFramework.PlatoonPatrolChain(platoon, 'Order_M3_Air_Attack_Chain_1')
		end
	end
	WaitSeconds(1)
	if Difficulty >=3 then
		platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'Order_M2_Air_Assault_Hard', 'AttackFormation')
		ScenarioFramework.PlatoonPatrolChain(platoon, 'Order_M3_Air_Attack_Chain_1')
		platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'Order_M2_Air_Assault_EXP_Hard', 'AttackFormation')
		ScenarioFramework.PlatoonPatrolChain(platoon, 'Order_M3_Air_Attack_Chain_1')
		if SpawnPlayerCDRTotal >=4 then
			platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'Order_M2_Air_Assault_Hard_More_Than_2', 'AttackFormation')
			ScenarioFramework.PlatoonPatrolChain(platoon, 'Order_M3_Air_Attack_Chain_1')
			platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'Order_M2_Air_Assault_EXP_Hard_More_Than_2', 'AttackFormation')
			ScenarioFramework.PlatoonPatrolChain(platoon, 'Order_M3_Air_Attack_Chain_1')
		end
	end
	WaitSeconds(1)
	M3OrderAI.Order_M3_South_East_BaseAI(SpawnPlayerCDRTotal)
	WaitSeconds(1)
    ---------------------------------------------------------------
    --Mission 2 Primary Objective 3 - Survive the Order Air Assualt
    ---------------------------------------------------------------
ScenarioInfo.M2P3 = Objectives.CategoriesInArea(
    'primary',                      # type
    'incomplete',                   # complete
    'Survive the Order air assualt',    # title
    'Eliminate the marked Order units.',  # description
    'kill',                         # action
    {                               # target
        MarkUnits = true,
		ShowFaction = 'Aeon',
        Requirements = {
            {   
                Area = 'M2_Attack_Zone',
                Category = categories.ALLUNITS,
                CompareOp = '<=',
                Value = 0,
                ArmyIndex = Order,
            },
        },
    }
)
    LOG('Assigned Mission 2 Objective 3')
    ScenarioInfo.M2P3:AddResultCallback(
        function(result)
            if(result) then
				ScenarioFramework.Dialogue(OpStrings.M2c_intro, StartMission2c, true)
            end
        end
    )
	table.insert(AssignedObjectives, ScenarioInfo.M2P3)
	WaitSeconds(1)
	M3SeraphimAI.Seraphim_M3_South_West_BaseAI(SpawnPlayerCDRTotal)
end
	
function StartMission2c()
	LOG('Starting Mission 2 Part 3/3')
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'Seraphim_M2_Air_Assault_Easy', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'Seraphim_M3_Air_Attack_Chain_1')
	WaitSeconds(1)
	if Difficulty >=2 then
		platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'Seraphim_M2_Air_Assault_Medium', 'AttackFormation')
		ScenarioFramework.PlatoonPatrolChain(platoon, 'Seraphim_M3_Air_Attack_Chain_1')
		platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'Seraphim_M2_Air_Assault_EXP_Medium', 'AttackFormation')
		ScenarioFramework.PlatoonPatrolChain(platoon, 'Seraphim_M3_Air_Attack_Chain_1')
		if SpawnPlayerCDRTotal >=4 then
			platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'Seraphim_M2_Air_Assault_Med_More_Than_2', 'AttackFormation')
			ScenarioFramework.PlatoonPatrolChain(platoon, 'Seraphim_M3_Air_Attack_Chain_1')
		end
	end
	WaitSeconds(1)
	if Difficulty >=3 then
		platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'Seraphim_M2_Air_Assault_Hard', 'AttackFormation')
		ScenarioFramework.PlatoonPatrolChain(platoon, 'Seraphim_M3_Air_Attack_Chain_1')
		platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'Seraphim_M2_Air_Assault_EXP_Hard', 'AttackFormation')
		ScenarioFramework.PlatoonPatrolChain(platoon, 'Seraphim_M3_Air_Attack_Chain_1')
		if SpawnPlayerCDRTotal >=4 then
			platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'Seraphim_M2_Air_Assault_Hard_More_Than_2', 'AttackFormation')
			ScenarioFramework.PlatoonPatrolChain(platoon, 'Seraphim_M3_Air_Attack_Chain_1')
			platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'Seraphim_M2_Air_Assault_EXP_Hard_More_Than_2', 'AttackFormation')
			ScenarioFramework.PlatoonPatrolChain(platoon, 'Seraphim_M3_Air_Attack_Chain_1')
		end
	end	
	WaitSeconds(1)
    --------------------------------------------------------------
    --Mission 2 Primary Objective 4 - Survive the Seraphim Assualt
    --------------------------------------------------------------
ScenarioInfo.M2P4 = Objectives.CategoriesInArea(
    'primary',                      # type
    'incomplete',                   # complete
    'Survive the Seraphim air assualt',    # title
    'Eliminate the marked Seraphim units.',  # description
    'kill',                         # action
    {                               # target
        MarkUnits = true,
		ShowFaction = 'Seraphim',
        Requirements = {
            {   
                Area = 'M2_Attack_Zone',
                Category = categories.ALLUNITS,
                CompareOp = '<=',
                Value = 0,
                ArmyIndex = Seraphim,
            },
        },
    }
)
    LOG('Assigned Mission 2 Objective 4')
    ScenarioInfo.M2P4:AddResultCallback(
        function(result)
            if(result) then
				ScenarioFramework.Dialogue(OpStrings.M2c_complete, StartMission3, true)
            end
        end
    )
	table.insert(AssignedObjectives, ScenarioInfo.M2P4)
end

function StartMission3()
    LOG('Starting Misson 3')
	ScenarioFramework.SetPlayableArea('3RD_MISSION_AREA', true)
	AICheats(Order, SpawnPlayerCDRTotal)
	AICheats(Seraphim, SpawnPlayerCDRTotal)
	M3SeraphimAI.Seraphim_M3_South_West_Base_Air_Attacks(SpawnPlayerCDRTotal)
	M3SeraphimAI.Seraphim_M3_South_West_Base_Land_Attacks(SpawnPlayerCDRTotal)
	M3OrderAI.Order_M3_South_East_Base_Air_Attacks(SpawnPlayerCDRTotal)
	M3OrderAI.Order_M3_South_East_Base_Land_Attacks(SpawnPlayerCDRTotal)
	ScenarioFramework.Dialogue(OpStrings.M3_intro, nil, true)
    ---------------------------------------------------------------
    --Mission 3 Primary Objective 1 - Destroy Order South East Base
    ---------------------------------------------------------------
ScenarioInfo.M3P1 = Objectives.CategoriesInArea(
    'primary',                      # type
    'incomplete',                   # complete
    'Destroy the Order south eastern base',    # title
    'Eliminate the marked Order structures and units.',  # description
    'kill',                         # action
    {                               # target
        MarkUnits = true,
        FlashVisible = true,
		ShowFaction = 'Aeon',
        Requirements = {
            {   
                Area = 'Order_M3_South_East_Base_Area',
                Category = categories.FACTORY + categories.ECONOMIC + categories.CONSTRUCTION + categories.uab4301 + categories.uab4302 + categories.uab3104,
                CompareOp = '<=',
                Value = 0,
                ArmyIndex = Order,
            },
        },
    }
)
    LOG('Assigned Mission 3 Objective 1')
    ScenarioInfo.M3P1:AddResultCallback(
        function(result)
            if(result) then
			    LOG("Objective Complete")
				M3Counter = M3Counter + 1
				M3OrderAI.DisableBase()
				if M3Counter == 1 then
					ForkThread(SpawnMission4Base)
				end
				if M3Counter >= 2 then
					ScenarioFramework.Dialogue(OpStrings.M3_complete, StartMission4, true)
				end
            end
        end
    )
	table.insert(AssignedObjectives, ScenarioInfo.M3P1)
	WaitSeconds(5)
    ------------------------------------------------------------------
    --Mission 3 Primary Objective 2 - Destroy Seraphim South West Base
    ------------------------------------------------------------------
	ScenarioInfo.M3P2 = Objectives.CategoriesInArea(
    'primary',                      # type
    'incomplete',                   # complete
    'Destroy the Seraphim south western base',    # title
    'Eliminate the marked Seraphim structures and units.',  # description
    'kill',                         # action
    {                               # target
        MarkUnits = true,
        FlashVisible = true,
		ShowFaction = 'Seraphim',
        Requirements = {
            {   
                Area = 'Seraphim_M3_South_West_Base_Area',
                Category = categories.FACTORY + categories.ECONOMIC + categories.CONSTRUCTION + categories.uab4301 + categories.uab4302 + categories.uab3104,
                CompareOp = '<=',
                Value = 0,
                ArmyIndex = Seraphim,
            },
        },
    }
)
	ScenarioFramework.CreateTimerTrigger(M3P2Reminder1, 600)
    LOG('Assigned Mission 3 Objective 2')
	ScenarioFramework.CreateTimerTrigger(Seraphim_Super_Nuke_Warning, 15)
    ScenarioInfo.M3P2:AddResultCallback(
        function(result)
            if(result) then
			    LOG("Objective Complete")
				M3Counter = M3Counter + 1
				M3SeraphimAI.DisableBase()
				if M3Counter == 1 then
					ForkThread(SpawnMission4Base)
				end
				if M3Counter >= 2 then
					ScenarioFramework.Dialogue(OpStrings.M3_complete, StartMission4, true)
				end
            end
        end
    )
	table.insert(AssignedObjectives, ScenarioInfo.M3P2)
end

function SpawnMission4Base()
	M4CybranAI.Cybran_M4_BaseAI(SpawnPlayerCDRTotal)
	WaitSeconds(1)
	M4SeraphimAI.Seraphim_M4_South_West_BaseAI(SpawnPlayerCDRTotal)
	WaitSeconds(1)
	M4OrderAI.Order_M4_South_East_BaseAI(SpawnPlayerCDRTotal)
end

function StartMission4()
	LOG('Starting Mission 4')
    SetAlliance(Order, Civilians, 'Neutral')
	M2S1CentreCheck()
	ForkThread(Defence_Satellite_Spawner)
	ForkThread(M4_Seraphim_Nuke)
	ScenarioFramework.CreateTimerTrigger(M4P1Reminder1, 600)
	ScenarioFramework.CreateTimerTrigger(M4P2Reminder1, 900)
	ScenarioFramework.CreateTimerTrigger(M4P3Reminder1, 1200)
	if Difficulty == 1 then
		ScenarioUtils.CreateArmyGroup('Order', 'Order_M4_Artillery_Easy')
	end
	if Difficulty == 2 then
		ScenarioUtils.CreateArmyGroup('Order', 'Order_M4_Artillery_Medium')
	end
	if Difficulty >= 3 then
		ScenarioUtils.CreateArmyGroup('Order', 'Order_M4_Artillery_Hard')
	end
	M4SeraphimAI.Seraphim_M4_South_West_Base_Air_Attacks(SpawnPlayerCDRTotal)
	M4SeraphimAI.Seraphim_M4_South_West_Base_Land_Attacks(SpawnPlayerCDRTotal)
	M4SeraphimAI.Seraphim_M4_Ythotha(SpawnPlayerCDRTotal)
	M4SeraphimAI.Seraphim_M4_Ahwassa(SpawnPlayerCDRTotal)
	M4OrderAI.Order_M4_South_East_Base_Air_Attacks(SpawnPlayerCDRTotal)
	M4OrderAI.Order_M4_South_East_Base_Land_Attacks(SpawnPlayerCDRTotal)
	M4OrderAI.Order_M4_Galactic_Colossus(SpawnPlayerCDRTotal)
	M4OrderAI.Order_M4_CZAR(SpawnPlayerCDRTotal)
	M4CybranAI.Cybran_M4_Base_Land_Attacks(SpawnPlayerCDRTotal)
	M4CybranAI.Cybran_M4_Base_Air_Attacks(SpawnPlayerCDRTotal)
	ScenarioFramework.Dialogue(OpStrings.M4_intro1, nil, true)
    ScenarioInfo.MissionNumber = 4
	ScenarioInfo.Angry_Command_Centre = ScenarioUtils.CreateArmyUnit('Cybran', 'Angry_Commander_Control_Centre')
	
    ScenarioInfo.OrderACU = ScenarioFramework.SpawnCommander('Order', 'Order_ACU', false, 'Cassandra', false, false, 
    {'Shield', 'ShieldHeavy', 'AdvancedEngineering', 'T3Engineering', 'HeatSink'})
	
    ScenarioInfo.SeraphimACU = ScenarioFramework.SpawnCommander('Seraphim', 'Seraphim_ACU', false, 'Thuum-Shavoh', false, false, 
    {'AdvancedEngineering', 'T3Engineering', 'RegenAura', 'AdvancedRegenAura', 'DamageStabilization', 'DamageStabilizationAdvanced'})
	if Difficulty >= 3 then
		ScenarioInfo.AngryACU1 = ScenarioFramework.SpawnCommander('Cybran', 'Angry_Commander1', false, 'Experimental Commander 1', false, false, 
		{'MicrowaveLaserGenerator', 'StealthGenerator', 'CloakingGenerator', 'CoolingUpgrade'})
	
		ScenarioInfo.AngryACU2 = ScenarioFramework.SpawnCommander('Cybran', 'Angry_Commander2', false, 'Experimental Commander 2', false, false, 
		{'MicrowaveLaserGenerator', 'StealthGenerator', 'CloakingGenerator', 'CoolingUpgrade'})
	
		ScenarioInfo.AngryACU3 = ScenarioFramework.SpawnCommander('Cybran', 'Angry_Commander3', false, 'Experimental Commander 3', false, false, 
		{'MicrowaveLaserGenerator', 'StealthGenerator', 'CloakingGenerator', 'CoolingUpgrade'})
	
		ScenarioInfo.AngryACU4 = ScenarioFramework.SpawnCommander('Cybran', 'Angry_Commander4', false, 'Experimental Commander 4', false, false, 
		{'MicrowaveLaserGenerator', 'StealthGenerator', 'CloakingGenerator', 'CoolingUpgrade'})
	else
		ScenarioInfo.AngryACU1 = ScenarioFramework.SpawnCommander('Cybran', 'Angry_Commander1', false, 'Experimental Commander 1', false, false, 
		{'MicrowaveLaserGenerator', 'ResourceAllocation', 'CoolingUpgrade'})
		
		ScenarioInfo.AngryACU2 = ScenarioFramework.SpawnCommander('Cybran', 'Angry_Commander2', false, 'Experimental Commander 2', false, false, 
		{'MicrowaveLaserGenerator', 'ResourceAllocation', 'CoolingUpgrade'})
		
		ScenarioInfo.AngryACU3 = ScenarioFramework.SpawnCommander('Cybran', 'Angry_Commander3', false, 'Experimental Commander 3', false, false, 
		{'MicrowaveLaserGenerator', 'ResourceAllocation', 'CoolingUpgrade'})
		
		ScenarioInfo.AngryACU4 = ScenarioFramework.SpawnCommander('Cybran', 'Angry_Commander4', false, 'Experimental Commander 4', false, false, 
		{'MicrowaveLaserGenerator', 'ResourceAllocation', 'CoolingUpgrade'})
	end
	ScenarioInfo.AngryACU1:SetVeterancy(5)
	ScenarioInfo.AngryACU2:SetVeterancy(5)
	ScenarioInfo.AngryACU3:SetVeterancy(5)
	ScenarioInfo.AngryACU4:SetVeterancy(5)
	ScenarioInfo.AngryACU1:SetCanBeKilled( false )
	ScenarioInfo.AngryACU2:SetCanBeKilled( false )
	ScenarioInfo.AngryACU3:SetCanBeKilled( false )
	ScenarioInfo.AngryACU4:SetCanBeKilled( false )
	ScenarioFramework.SetPlayableArea('4TH_MISSION_AREA', true)
	AICheats(Cybran, SpawnPlayerCDRTotal)
	AICheats(Order, SpawnPlayerCDRTotal)
	AICheats(Seraphim, SpawnPlayerCDRTotal)
	WaitSeconds(5)
    -------------------------------------------------------------------
    --Mission 4 Primary Objective 1 - Destroy the cybran science centre
    -------------------------------------------------------------------
    ScenarioInfo.M4P1 = Objectives.KillOrCapture(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy the cybran science centre',  -- title
        'Destroy the cybran science centre to make the experimental commanders killable',  -- description
        {                               -- target
            Units = {ScenarioInfo.Angry_Command_Centre},
            MarkUnits = true,
            AlwaysVisible = true,
        }
    )
    ScenarioInfo.M4P1:AddResultCallback(
        function(result)
            if(result) then
			M4Counter = M4Counter + 1
			ScenarioFramework.Dialogue(OpStrings.M4_intro3, Destroyed_Science_Centre, true)
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M4P1)
	ForkThread(AngryACUMove)
	WaitSeconds(5)
    ------------------------------------------------
    --Mission 4 Primary Objective 2 - Kill Order ACU
    ------------------------------------------------
    ScenarioInfo.M4P2 = Objectives.KillOrCapture(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy the Order commander',  -- title
        'Destroy the Order commander',  -- description
        {                               -- target
            Units = {ScenarioInfo.OrderACU},
            MarkUnits = true,
        }
    )
    ScenarioInfo.M4P2:AddResultCallback(
        function(result)
            if(result) then
				ScenarioFramework.Dialogue(OpStrings.Order_Dead)
				M4OrderAI.DisableBase()
				M4Counter = M4Counter + 1
				if(M4Counter >= 7) then
					ForkThread(PlayerWin)
				end
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M4P2)
	WaitSeconds(5)
    ----------------------------------------------------
    -- Mission 4 Primary Objective 3 - Kill Seraphim ACU
    ----------------------------------------------------
    ScenarioInfo.M4P3 = Objectives.KillOrCapture(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy the Seraphim commander',  -- title
        'Destroy the Seraphim commander',  -- description
        {                               -- target
            Units = {ScenarioInfo.SeraphimACU},
            MarkUnits = true,
        }
    )
    ScenarioInfo.M4P3:AddResultCallback(
        function(result)
            if(result) then
				ScenarioFramework.Dialogue(OpStrings.Seraphim_Dead)
				M4SeraphimAI.DisableBase()
				M4Counter = M4Counter + 1
				if(M4Counter >= 7) then
					ForkThread(PlayerWin)
				end
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M4P3)
end

function AngryACUMove()
	local cmd = IssueMove({ScenarioInfo.AngryACU1}, ScenarioUtils.MarkerToPosition('Angry_Commander_Move_Marker_1'))
	local cmd = IssueMove({ScenarioInfo.AngryACU2}, ScenarioUtils.MarkerToPosition('Angry_Commander_Move_Marker_2'))
	local cmd = IssueMove({ScenarioInfo.AngryACU3}, ScenarioUtils.MarkerToPosition('Angry_Commander_Move_Marker_3'))
	local cmd = IssueMove({ScenarioInfo.AngryACU4}, ScenarioUtils.MarkerToPosition('Angry_Commander_Move_Marker_4'))
end

function Destroyed_Science_Centre()
    ScenarioInfo.AngryACU1:SetCanBeKilled( true )
    ScenarioInfo.AngryACU2:SetCanBeKilled( true )
    ScenarioInfo.AngryACU3:SetCanBeKilled( true )
    ScenarioInfo.AngryACU4:SetCanBeKilled( true )
    --------------------------------------------------
    --Mission 4 Primary Objective 4 - Kill Angry ACU 1
    --------------------------------------------------
    ScenarioInfo.M4P4 = Objectives.KillOrCapture(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy experimental ACU 1',  -- title
        'Destroy experimental ACU 1',  -- description
        {                               -- target
            Units = {ScenarioInfo.AngryACU1},
            MarkUnits = true,
            AlwaysVisible = true,
        }
    )
    ScenarioInfo.M4P4:AddResultCallback(
        function(result)
            if(result) then
				ScenarioFramework.Dialogue(OpStrings.QAI_Angry_1)
				M4Counter = M4Counter + 1
				if(M4Counter >= 7) then
					ForkThread(PlayerWin)
				end
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M4P4)
	WaitSeconds(5)
    --------------------------------------------------
    --Mission 4 Primary Objective 5 - Kill Angry ACU 2
    --------------------------------------------------
    ScenarioInfo.M4P5 = Objectives.KillOrCapture(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy experimental ACU 2',  -- title
        'Destroy experimental ACU 2',  -- description
        {                               -- target
            Units = {ScenarioInfo.AngryACU2},
            MarkUnits = true,
            AlwaysVisible = true,
        }
    )
    ScenarioInfo.M4P5:AddResultCallback(
        function(result)
            if(result) then
				ScenarioFramework.Dialogue(OpStrings.QAI_Angry_2)
				M4Counter = M4Counter + 1
				if(M4Counter >= 7) then
					ForkThread(PlayerWin)
				end
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M4P5)
	WaitSeconds(5)
    --------------------------------------------------
    --Mission 4 Primary Objective 6 - Kill Angry ACU 3
    --------------------------------------------------
    ScenarioInfo.M4P6 = Objectives.KillOrCapture(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy experimental ACU 3',  -- title
        'Destroy experimental ACU 3',  -- description
        {                               -- target
            Units = {ScenarioInfo.AngryACU3},
            MarkUnits = true,
            AlwaysVisible = true,
        }
    )
    ScenarioInfo.M4P6:AddResultCallback(
        function(result)
            if(result) then
				ScenarioFramework.Dialogue(OpStrings.QAI_Angry_3)
				M4Counter = M4Counter + 1
				if(M4Counter >= 7) then
					ForkThread(PlayerWin)
				end
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M4P6)
	WaitSeconds(5)
    --------------------------------------------------
    --Mission 4 Primary Objective 7 - Kill Angry ACU 4
    --------------------------------------------------
    ScenarioInfo.M4P7 = Objectives.KillOrCapture(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy experimental ACU 4',  -- title
        'Destroy experimental ACU 4',  -- description
        {                               -- target
            Units = {ScenarioInfo.AngryACU4},
            MarkUnits = true,
            AlwaysVisible = true,
        }
    )
    ScenarioInfo.M4P7:AddResultCallback(
        function(result)
            if(result) then
				ScenarioFramework.Dialogue(OpStrings.QAI_Angry_4)
				M4Counter = M4Counter + 1
				if(M4Counter >= 7) then
					ForkThread(PlayerWin)
				end
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M4P7)
end

function PlayerWin()
    ForkThread(
        function()
            if(not ScenarioInfo.OpEnded) then
                ScenarioFramework.EndOperationSafety()
                ScenarioFramework.FlushDialogueQueue()
                ScenarioInfo.OpComplete = true
				ForkThread(
					function()
						WaitSeconds(5)
						UnlockInput()
						KillGame()
					end
				)
            end
        end
    )
end

function PlayerDeath(Player)
	if SpawnPlayerCDR[6] == 1 then
		if ScenarioInfo.PlayerCDR[6]:IsDead() then
			ACU6Dead = 1
		end
	end
	if SpawnPlayerCDR[7] == 1 then
		if ScenarioInfo.PlayerCDR[7]:IsDead() then
			ACU7Dead = 1
		end
	end
	if SpawnPlayerCDR[8] == 1 then
		if ScenarioInfo.PlayerCDR[8]:IsDead() then
			ACU8Dead = 1
		end
	end
	if SpawnPlayerCDR[9] == 1 then
		if ScenarioInfo.PlayerCDR[9]:IsDead() then
			ACU9Dead = 1
		end
	end
	if SpawnPlayerCDR[10] == 1 then
		if ScenarioInfo.PlayerCDR[10]:IsDead() then
			ACU10Dead = 1
		end
	end
	if SpawnPlayerCDR[11] == 1 then
		if ScenarioInfo.PlayerCDR[11]:IsDead() then
			ACU11Dead = 1
		end
	end
	ACUDeathCounter = ACU6Dead + ACU7Dead + ACU8Dead + ACU9Dead + ACU10Dead + ACU11Dead
	LOG("ACU death counter: " .. ACUDeathCounter)
	LOG("ACU spawn counter: " .. SpawnPlayerCDRTotal)
	LOG('Player army ' .. Player.Sync.army .. ' ACU Killed')
	if Debug then
	    ForkThread(
        function()
		LOG("Debug spawner initialised")
		WaitSeconds(5)
		if SpawnPlayerCDR[6] == 1 then						--Check if Player1 ACU spawned
			if ScenarioInfo.PlayerCDR[6]:IsDead() then		--Check if Player1 ACU has been killed
				SpawnPlayerCDR[6] = 0						--If Player1 ACU has spawned and has been killed then set SpawnPlayerCDR[1] to 0
			end
		end
		if SpawnPlayerCDR[7] == 1 then
			if ScenarioInfo.PlayerCDR[7]:IsDead() then
				SpawnPlayerCDR[7] = 0
			end
		end
		if SpawnPlayerCDR[8] == 1 then
			if ScenarioInfo.PlayerCDR[8]:IsDead() then
				SpawnPlayerCDR[8] = 0
			end
		end
		if SpawnPlayerCDR[9] == 1 then
			if ScenarioInfo.PlayerCDR[9]:IsDead() then
				SpawnPlayerCDR[9] = 0
			end
		end
		if SpawnPlayerCDR[10] == 1 then
			if ScenarioInfo.PlayerCDR[10]:IsDead() then
				SpawnPlayerCDR[10] = 0
			end
		end
		if SpawnPlayerCDR[11] == 1 then
			if ScenarioInfo.PlayerCDR[11]:IsDead() then
				SpawnPlayerCDR[11] = 0
			end
		end
		ForkThread(SpawnAllACUs)
        end
        )
	else
	if SpawnPlayerCDRTotal == ACUDeathCounter then
		if(not ScenarioInfo.OpEnded) then
			ScenarioFramework.CDRDeathNISCamera(Player)
			ScenarioFramework.EndOperationSafety()
			ScenarioFramework.FlushDialogueQueue()
			ScenarioFramework.Dialogue(OpStrings.Player_Commander_Dead, nil, true)
			ScenarioInfo.OpComplete = false
			for k, v in AssignedObjectives do
				if(v and v.Active) then
					v:ManualResult(false)
				end
			end
			ForkThread(
				function()
					WaitSeconds(5)
					UnlockInput()
					KillGame()
				end
			)
		end
	end
end
end

function DePuceDeath(Player)
	LOG("DePuce Died")
	if Debug then
		LOG("Debug is active")
	else
	if(not ScenarioInfo.OpEnded) then
		ScenarioFramework.CDRDeathNISCamera(Player)
		ScenarioFramework.FlushDialogueQueue()
		ScenarioFramework.EndOperationSafety()
		ScenarioInfo.OpComplete = false
		for k, v in AssignedObjectives do
			if(v and v.Active) then
				v:ManualResult(false)
			end
		end
		ForkThread(
			function()
				WaitSeconds(5)
				UnlockInput()
				KillGame()
			end
		)
		end
	end
end

function KillGame()
    UnlockInput()
    
    local allPrimaryCompleted = true
    local allSecondaryCompleted = true
    
    for _, v in AssignedObjectives do
        if (v == ScenarioInfo.M1P1 or v == ScenarioInfo.M2P1) then
            allPrimaryCompleted = allPrimaryCompleted and v.Complete
        else
            allSecondaryCompleted = allSecondaryCompleted and v.Complete
        end
    end
    
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, allPrimaryCompleted, allSecondaryCompleted)
end

-- Sets cheats for the specified Army. If Value is not defined then it defaults to 4. Usage: AICheats(Army, Value) e.g AICheats(Player, 100) 
function AICheats(Army, PlayerCount, Value)
	if Value == nil then Value = 2 end
	if PlayerCount == nil then PlayerCount = 2 end
	buffBuildDef = Buffs['CheatBuildRate']
	buffBuildAffects = buffBuildDef.Affects
	buffBuildAffects.BuildRate.Mult = (Value+PlayerCount/2)*CheatRate[Difficulty]
	
	buffDef = Buffs['CheatIncome']
	buffAffects = buffDef.Affects
	buffAffects.EnergyProduction.Mult = (Value+PlayerCount/2)*CheatRate[Difficulty]
	buffAffects.MassProduction.Mult = (Value+PlayerCount/2)*CheatRate[Difficulty]
		for _, u in GetArmyBrain(Army):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
			Buff.ApplyBuff(u, 'CheatBuildRate')
			Buff.ApplyBuff(u, 'CheatIncome')
		end
	LOG('Cheats for ' .. Army .. ' applied successfully. Value = ' .. (Value+PlayerCount/2)*CheatRate[Difficulty])
end

-- If the science centre is destroyed then it will change the variable ScienceCentreDestroyed to true and fail the objective
function M2S1CentreDestroyed()
	ScienceCentreDestroyed = true
	LOG('Science centre destroyed')
    if(ScenarioInfo.M2S1 and ScenarioInfo.M2S1.Active) then
        ScenarioInfo.M2S1:ManualResult(false)
	end
end

function M3S1CentreDestroyed()
	NE_Centre_Destroyed = true
	LOG('Science centre destroyed')
    if(ScenarioInfo.M3S1 and ScenarioInfo.M3S1.Active) then
        ScenarioInfo.M3S1:ManualResult(false)
	end
end

-- Checks if the science centre is alive. If it is then it completes the objective
function M2S1CentreCheck()
	LOG('Science centre check')
	if not ScienceCentreDestroyed then
		if(ScenarioInfo.M2S1 and ScenarioInfo.M2S1.Active) then
			ScenarioInfo.M2S1:ManualResult(true)
			local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon("Civilians", "Spy_Satellite", 'AttackFormation')
			ScenarioFramework.PlatoonPatrolChain(platoon, "Spy_Satellite_Chain")
			local OrderVisMarker = ScenarioFramework.CreateVisibleAreaLocation(100, 'Order_M4_South_East_Base_Marker', 0, ArmyBrains[Player1])			-- Creates a vision marker that is 100 in diameter at a specified marker that does not expire automatically for the first human player
			local CybranVisMarker = ScenarioFramework.CreateVisibleAreaLocation(50, 'Cybran_M4_Base_Marker', 0, ArmyBrains[Player1])
			local SeraphimVisMarker = ScenarioFramework.CreateVisibleAreaLocation(100, 'Seraphim_M4_South_West_Base_Marker', 0, ArmyBrains[Player1])
		end
	end
end

function M4_Seraphim_Nuke()
    WaitSeconds(10*NukeWaitSecondsDifficultyMultiplier[Difficulty])
	LaunchNuke(Seraphim, categories.xsb2401, "Seraphim_M4_Nuke_Marker_1")						-- Nuke warning shot
	ScenarioFramework.Dialogue(OpStrings.Nuke_Launched_Town)
	ForkThread(M4_Seraphim_Nuke_Loop)
end

function M4_Seraphim_Nuke_Loop()
	WaitSeconds(600*NukeWaitSecondsDifficultyMultiplier[Difficulty])
	LaunchNuke(Seraphim, categories.xsb2401, "Seraphim_M4_Nuke_Marker_2")
	
	WaitSeconds(600*NukeWaitSecondsDifficultyMultiplier[Difficulty])
	LaunchNuke(Seraphim, categories.xsb2401, "Seraphim_M4_Nuke_Marker_3")
	
	WaitSeconds(600*NukeWaitSecondsDifficultyMultiplier[Difficulty])
	LaunchNuke(Seraphim, categories.xsb2401, "Seraphim_M4_Nuke_Marker_4")
	
	WaitSeconds(600*NukeWaitSecondsDifficultyMultiplier[Difficulty])
	LaunchNuke(Seraphim, categories.xsb2401, "Seraphim_M4_Nuke_Marker_5")
	
	WaitSeconds(600*NukeWaitSecondsDifficultyMultiplier[Difficulty])
	LaunchNuke(Seraphim, categories.xsb2401, "Seraphim_M4_Nuke_Marker_6")
	
	WaitSeconds(600*NukeWaitSecondsDifficultyMultiplier[Difficulty])
	LaunchNuke(Seraphim, categories.xsb2401, "Seraphim_M4_Nuke_Marker_7")
	M4_Seraphim_Nuke_Loop()
end

function LaunchNuke(Army, NukeLauncherUnitID, Marker)											-- Examples of usage LaunchNuke(Seraphim, categories.xsb2401, "Seraphim_M4_Nuke_Marker_1") This will get all the experimental nuke launchers for the army Seraphim and will launch a nuke at Seraphim_M4_Nuke_Marker_1 NB: NukeLauncherUnitID needs to be in the following format: categories.unitID
	local NukeLauncher = ArmyBrains[Army]:GetListOfUnits(NukeLauncherUnitID, false)				-- Creates a table of all units beloning to the specified army faction that match the unit ID
	NukeLauncher[1]:GiveNukeSiloAmmo(1)															-- Gives the first unit in the table 1 missile to ensure that it launches
    IssueNuke({NukeLauncher[1]}, ScenarioUtils.MarkerToPosition(Marker))						-- Launches a strategic missile at a specified marker that was created in the map editor
end

function SpawnAllACUs()
	local tblArmy = ListArmies()
	LOG("Spawning ACU")
	for iArmy, strArmy in pairs(tblArmy) do														-- This command gets each value and puts the integer in iArmy and the string in strArmy then loops the function for every row in the table e.g value from table [1] => "Cybran" iArmy would be 1 and strArmy would be "Cybran" as that is the first entry in the table, the order the table is generated is in the same order as the armies appear in the scenario file.
		if iArmy >= ScenarioInfo.Player1 then													-- Checks if iArmy is greater than or equal to the first human player
			if SpawnPlayerCDR[iArmy] == 0 then													-- Check if the ACU has spawned if it has the it ends the function
			Nickname = GetArmyBrain(strArmy).Nickname											-- Gets the Nickname (faf username) from the players army
			factionIdx = GetArmyBrain(strArmy):GetFactionIndex()								-- Gets the faction value from the players army
			if factionIdx >3 then factionIdx = 1 end											-- If the faction is greater than cybran (3) (as seraphim is 4) then it sets the faction as UEF (1)
			strFactionIdx = tostring(factionIdx)												-- Creates a variable that converts the faction integer into a string value
			if strArmy == 'Player1' then														-- If the army name is Player1 then it sets the army colour to someting based off the facton
				if factionIdx ==1 then SetArmyColor('Player1', 41, 41, 225) end					-- If the player is UEF then set the army colour as blue
				if factionIdx ==2 then SetArmyColor('Player1', 36, 182, 36) end					-- If the player is Aeon then set the army colour as green
				if factionIdx ==3 then SetArmyColor('Player1', 231, 3, 3) end					-- If the player is Cybran then set the army colour as red
			end
			if strArmy == 'Player2' then
				if factionIdx ==1 then SetArmyColor('Player2', 71, 114, 148) end
				if factionIdx ==2 then SetArmyColor('Player2', 16, 86, 16) end
				if factionIdx ==3 then SetArmyColor('Player2', 255, 170, 170) end
			end
			if strArmy == 'Player3' then
				if factionIdx ==1 then SetArmyColor('Player3', 133, 148, 255) end
				if factionIdx ==2 then SetArmyColor('Player3', 102, 153, 0) end
				if factionIdx ==3 then SetArmyColor('Player3', 255, 102, 153) end
			end
			if strArmy == 'Player4' then
				if factionIdx ==1 then SetArmyColor('Player4', 41, 40, 140) end
				if factionIdx ==2 then SetArmyColor('Player4', 0, 255, 0) end
				if factionIdx ==3 then SetArmyColor('Player4', 165, 40, 40) end
			end
			if strArmy == 'Player5' then
				if factionIdx ==1 then SetArmyColor('Player5', 0, 51, 153) end
				if factionIdx ==2 then SetArmyColor('Player5', 46, 139, 87) end
				if factionIdx ==3 then SetArmyColor('Player5', 80, 10, 10) end
			end
			if strArmy == 'Player6' then
				if factionIdx ==1 then SetArmyColor('Player6', 0, 0, 102) end
				if factionIdx ==2 then SetArmyColor('Player6', 180, 255, 180) end
				if factionIdx ==3 then SetArmyColor('Player6', 255, 100, 100) end
			end
				ScenarioInfo.PlayerCDR[iArmy] = ScenarioFramework.SpawnCommander(strArmy, strFactionIdx, 'Warp', 'CDR '..Nickname, true, PlayerDeath)
				if Debug then														-- Check if Debug = true
					ScenarioUtils.CreateArmyGroup(strArmy, 'Debug')					-- Creates the debug base
					AICheats(strArmy, nil, 100)											-- Sets cheat rate for the player
				end
				SpawnPlayerCDR[iArmy] = 1											-- Sets SpawnPlayerCDR[Integer] as 1 e.g SpawnPlayerCDR[6] if Player1 as Player1 is Army 6
			end
		end
	end
end

function Defence_Satellite_Spawner()
	WaitSeconds(90)
	if(ScenarioInfo.M2S1 and ScenarioInfo.M2S1.Active) then
		ScenarioInfo.M2S1:ManualResult(true)
	end
	Satellite_Spawner("Civilians", "Defence_Satellite", "Defence_Satellite_Chain")
	WaitSeconds(40)
	Satellite_Spawner("Civilians", "Defence_Satellite", "Defence_Satellite_Chain")
	WaitSeconds(40)
	Satellite_Spawner("Civilians", "Defence_Satellite", "Defence_Satellite_Chain")
	WaitSeconds(40)
	Satellite_Spawner("Civilians", "Defence_Satellite", "Defence_Satellite_Chain")
	WaitSeconds(40)
	Satellite_Spawner("Civilians", "Defence_Satellite", "Defence_Satellite_Chain")
	WaitSeconds(40)
	Satellite_Spawner("Civilians", "Defence_Satellite", "Defence_Satellite_Chain")
end

function Satellite_Spawner(Army, Group, Chain)
	if ScenarioInfo.NE_Science_Building:IsDead() then
		LOG("Science Facility Bulwark is destroyed not spawning defence satellite")
	else
		local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon(Army, Group, 'AttackFormation')
		ScenarioFramework.PlatoonPatrolChain(platoon, Chain)
	end
end

---------------------
-- Objective Reminders
---------------------
function M1P1Reminder1()
    if(ScenarioInfo.M1P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.M1P1_Reminder_1)
    end
end

function Generic_Reminder_1()
        ScenarioFramework.Dialogue(OpStrings.Generic_Reminder_1)
        ScenarioFramework.CreateTimerTrigger(Generic_Reminder_2, 2520)
end

function Generic_Reminder_2()
    ScenarioFramework.Dialogue(OpStrings.Generic_Reminder_2)
	ScenarioFramework.CreateTimerTrigger(Generic_Reminder_1, 2520)
end

function M3S1Reminder1()
    if(ScenarioInfo.M1P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.M3S1_Reminder)
    end
end

function M3P2Reminder1()
   if(ScenarioInfo.M3P2.Active) then
        ScenarioFramework.Dialogue(OpStrings.M3P2_Reminder_1)
   end
end

function M4P1Reminder1()
    if(ScenarioInfo.M4P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.M4P1_Reminder_1)
   end
end

function M4P2Reminder1()
    if(ScenarioInfo.M4P2.Active) then
        ScenarioFramework.Dialogue(OpStrings.M4P2_Reminder_1)
    end
end

function M4P3Reminder1()
    if(ScenarioInfo.M4P3.Active) then
        ScenarioFramework.Dialogue(OpStrings.M4P3_Reminder_1)
		ScenarioFramework.CreateTimerTrigger(M4P3Reminder2, 1500)
    end
end

function M4P3Reminder2()
    if(ScenarioInfo.M4P3.Active) then
        ScenarioFramework.Dialogue(OpStrings.M4P3_Reminder_2)
    end
end

function Seraphim_Super_Nuke_Warning()
	ScenarioFramework.Dialogue(OpStrings.Seraphim_Super_Nuke_Warning)
	WaitSeconds(5)
	if not NE_Centre_Destroyed then 
		--------------------------------------------------------------------
		--Mission 3 Secondary Objective 1 - Protect science facility bulwark
		--------------------------------------------------------------------
		ScenarioInfo.M3S1 = Objectives.CategoriesInArea(
			'secondary',                      # type
			'incomplete',                   # complete
			'Protect Science Facility Bulwark',  # title
			'Protect Science Facility Bulwark by bulding two strategic missile defences in the north east town.',  # description
			'Build',                         # action
			{
				MarkArea = false,
				Category = categories.uab4302 + categories.ueb4302 + categories.urb4302 + categories.xsb4302,
				Requirements = {
					{ Area = 'NE_Town_Area', Category = categories.uab4302 + categories.ueb4302 + categories.urb4302 + categories.xsb4302, CompareOp = '>=', Value = 2 },
				}
			}
	   )
		ScenarioInfo.M3S1:AddResultCallback(
			function(result)
				if result then
					LOG("Mission 3 Secondary Objective 1 Complete")
				end
			end
		)
		table.insert(AssignedObjectives, ScenarioInfo.M3S1)
		ScenarioFramework.CreateTimerTrigger(M3S1Reminder1, 700)
	end
end

function All_Reminders()
	M1P1Reminder1()
	Generic_Reminder_1()
	Generic_Reminder_2()
	M3S1Reminder1()
	M4P1Reminder1()
	M4P2Reminder1()
	M4P3Reminder1()
	M4P3Reminder2()
	ScenarioFramework.Dialogue(OpStrings.QAI_Angry_1)
	ScenarioFramework.Dialogue(OpStrings.QAI_Angry_2)
	ScenarioFramework.Dialogue(OpStrings.QAI_Angry_3)
	ScenarioFramework.Dialogue(OpStrings.QAI_Angry_4)
	ScenarioFramework.Dialogue(OpStrings.Seraphim_Super_Nuke_Warning)
	ScenarioFramework.Dialogue(OpStrings.Nuke_Launched_Town)
	ScenarioFramework.Dialogue(OpStrings.Order_Dead)
	ScenarioFramework.Dialogue(OpStrings.Seraphim_Dead)
end

-- Prints tables in the game log. usage: print_r ( table ) e.g print_r ( ScenarioInfo.PlayerCDR )
function print_r ( t )  
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            LOG(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        LOG(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        LOG(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        LOG(indent.."["..pos..'] => "'..val..'"')
                    else
                        LOG(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                LOG(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        LOG(tostring(t).." {")
        sub_print_r(t,"  ")
        LOG("}")
    else
        sub_print_r(t,"  ")
    end
    LOG()
end