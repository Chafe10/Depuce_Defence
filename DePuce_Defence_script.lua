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
local M4QAIAI = import('/maps/DePuce_Defence/DePuce_Defence_M4QAIAI.lua')
local M4OrderAI = import('/maps/DePuce_Defence/DePuce_Defence_M4OrderAI.lua')
local M4SeraphimAI = import('/maps/DePuce_Defence/DePuce_Defence_M4SeraphimAI.lua')
local SeraphimNorthBaseAI = import('/maps/DePuce_Defence/DePuce_Defence_Seraphim_North_BaseAI.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Utilities = import('/lua/utilities.lua')
local OpStrings = import('/maps/DePuce_Defence/DePuce_Defence_strings.lua')

-- Global Variables
ObjCounter = 0
MapVersionNumber = "2017.01.06.1 BETA V5"
ScenarioInfo.PlayerCDR = {}
SpawnPlayerCDRTotal = 0
ACUDeathCounter = 0
NukeWaitSecondsDifficultyMultiplier = {1.2,1,0.8}
M2Started = false
M2CStarted = false
M3Started = false
M4BaseSpawned = false
M4Started = false
MissionFailed = false
ArmyColours = {{r=67, g=110, b=238},{r=232, g=10, b=10},{r=97, g=109, b=126},{r=250, g=250, b=0},{r=255, g=135, b=62},{r=255, g=255, b=255},{r=145, g=97, b=255},{r=255, g=136, b=255},{r=46, g=139, b=87},{r=19, g=28, b=211},{r=95, g=1, b=167},{r=255, g=50, b=255},{r=255, g=191, b=128},{r=183, g=101, b=24},{r=144, g=20, b=39},{r=47, g=79, b=79},{r=64, g=191, b=64},{r=102, g=255, b=204},}
ArmySetup = ScenarioInfo.ArmySetup


-- Army IDs
ScenarioInfo.QAI = 1
ScenarioInfo.Order = 2
ScenarioInfo.Seraphim = 3
ScenarioInfo.Science_Facility_Equium = 4
ScenarioInfo.Science_Facility_Bulwark = 5
ScenarioInfo.DePuce = 6
ScenarioInfo.Player1 = 7
ScenarioInfo.Player2 = 8
ScenarioInfo.Player3 = 9
ScenarioInfo.Player4 = 10
ScenarioInfo.Player5 = 11
ScenarioInfo.Player6 = 12

-- Local Variables
local QAI = ScenarioInfo.QAI
local Order = ScenarioInfo.Order
local Seraphim = ScenarioInfo.Seraphim
local Science_Facility_Equium = ScenarioInfo.Science_Facility_Equium
local Science_Facility_Bulwark = ScenarioInfo.Science_Facility_Bulwark
local DePuce = ScenarioInfo.DePuce
local Player1 = ScenarioInfo.Player1
local M1Timer = 3000
local M2Timer = 600
local M2BTimer = 180
local M2CTimer = 180
local M3Timer = 3000
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
	factionIdx = GetArmyBrain(7):GetFactionIndex()
	if factionIdx >3 then 
		Debug = true
		LOG("Player1 is seraphim activating debug mode")
	end
    ScenarioUtils.InitializeScenarioArmies()
	ScenarioFramework.SetPlayableArea('1ST_MISSION_AREA', false)
    ScenarioFramework.SetSharedUnitCap(3600)
	SetArmyUnitCap(Order, 4000)
	SetArmyUnitCap(Seraphim, 4000)
	SetArmyUnitCap(QAI, 1500)
	SetArmyUnitCap(DePuce, 2000)
	SetArmyUnitCap(Science_Facility_Equium, 150)
	SetArmyUnitCap(Science_Facility_Bulwark, 150)
	SetArmyColor('DePuce', 71, 114, 148)
	SetArmyColor('Science_Facility_Equium', 16, 16, 86)
	SetArmyColor('Science_Facility_Bulwark', 16, 16, 86)
	SetArmyColor('Order', 159, 216, 2)
	SetArmyColor('Seraphim', 167, 150, 2)
	SetArmyColor('QAI', 225, 70, 0)
	ScenarioInfo.NE_Town = ScenarioUtils.CreateArmyGroup('Science_Facility_Bulwark', 'North_East_Town')
	ScenarioInfo.NE_Science_Building = ScenarioUtils.CreateArmyUnit('Science_Facility_Bulwark', 'Science_Facility_Bulwark_Building')
	ScenarioFramework.CreateUnitDestroyedTrigger(M3S1CentreDestroyed, ScenarioInfo.NE_Science_Building)
	ScenarioInfo.NE_Science_Building:SetCustomName("Science Facility Bulwark")
	M2CivAI.Science_Facility_Equium_BaseAI()
	M2DePuceAI.DePuce_BaseAI()
    ScenarioInfo.DePuceACU = ScenarioFramework.SpawnCommander('DePuce', 'DePuce_ACU', false, 'CDR DePuce', true, DePuceDeath, 
    {'ResourceAllocation', 'AdvancedEngineering', 'T3Engineering', 'Shield','ShieldGeneratorField'})
	if Debug then
		ScenarioInfo.DePuceACU:SetCanTakeDamage(false)
	end
	ScenarioUtils.CreateArmyGroup('Seraphim', 'Seraphim_Jammer_Crystals')
	ScenarioUtils.CreateArmyGroup('Order', 'Order_Jammer_Crystals')
    GetArmyBrain(DePuce):SetResourceSharing(false)
    GetArmyBrain(Science_Facility_Equium):SetResourceSharing(false)
	GetArmyBrain(Science_Facility_Bulwark):SetResourceSharing(false)
	ScenarioInfo.NE_Science_Building:SetDoNotTarget(true)
	ScenarioInfo.NE_Science_Building:SetReclaimable(false)
	ScenarioInfo.SeraphimSCAU1 = ScenarioFramework.SpawnCommander('Seraphim', 'Seraphim_SACU', false, 'Iya-Ioz', false, false, 
	{'EngineeringThroughput', 'Overcharge', 'Shield'})
	ScenarioInfo.SeraphimSCAU2 = ScenarioFramework.SpawnCommander('Seraphim', 'Seraphim_SACU', false, 'Ah-Uhtheaez', false, false, 
	{'EngineeringThroughput', 'Overcharge', 'Shield'})
	SeraphimNorthBaseAI.Seraphim_North_BaseAI()
end

function OnStart()
    ForkThread(IntroMission1)
end

-----------
--Mission 1
-----------

function IntroMission1()
	Cinematics.EnterNISMode()
	tblArmy = ListArmies()
	local strCameraPlayer = tostring(tblArmy[GetFocusArmy()])						-- Converts the value from the table to string
	local CameraMarker = strCameraPlayer .. "Cam"									-- Concatenates the value with Cam. This is a camera info marker that is placed through the editor. e.g Player1Cam
	ForkThread(SpawnAllACUs)
	local VisMarker2 = ScenarioFramework.CreateVisibleAreaLocation(30, 'Order_M1_South_Base_Marker', 3, ArmyBrains[Player1])
	Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Start_ACU_Camera'), 0)
	ScenarioFramework.Dialogue(OpStrings.M1_Intro, nil, true)
	Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker(CameraMarker), 4)
    Cinematics.ExitNISMode()
    ScenarioInfo.MissionNumber = 1
    if Debug then
		local DebugVisMarker = ScenarioFramework.CreateVisibleAreaLocation(1200, 'Spawn_ACU_Vis_Marker', 0, ArmyBrains[Player1])
		LOG("Debug Vision Marker Enabled")
		M1Timer = 30
		M2Timer = 20
		M3Timer = 180
		M2BTimer = 30
		M2CTimer = 30
		LOG("M1 hard mode timer set to ".. M1Timer .." seconds")
		LOG("M2 Timer set to ".. M2Timer .." seconds")
		LOG("M3 hard mode timer set to ".. M3Timer .." seconds")
    end
	StartMission1()
end

function StartMission1()
    LOG('Starting Misson 1')
	M1OrderAI.Order_M1_South_BaseAI(SpawnPlayerCDRTotal)
	LOG("Players = " .. SpawnPlayerCDRTotal)
	if Difficulty >=2 then
		ScenarioUtils.CreateArmyGroup('QAI', 'QAI_Offscreen_Units_Medium')
		ScenarioUtils.CreateArmyGroup('Order', 'Order_Offscreen_Units_Medium')
		ScenarioUtils.CreateArmyGroup('Seraphim', 'Seraphim_Offscreen_Units_Medium')
		LOG("Off Screen Units Created")
		if Difficulty >=3 then
			ScenarioUtils.CreateArmyGroup('QAI', 'QAI_Offscreen_Units_Hard')
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
    LOG('Assigned Mission 1 Objective 1')
    ScenarioInfo.M1P1:AddResultCallback(
        function(result)
            if(result) then
				ObjCounter = ObjCounter + 1
				LOG("Objective Complete Counter:" .. ObjCounter)
				if(ObjCounter >= 10) then
					ForkThread(PlayerWin)
				end
				M1OrderAI.DisableBase()
				if not M2Started then
					M2Started = true
					LOG('Objective Complete. Starting Mission 2')
					ScenarioFramework.Dialogue(OpStrings.M1_Complete, IntroMission2, true)
				end
				if Difficulty >= 3 then
					ScenarioInfo.M1HT:ManualResult(true)
				end
            end
        end
    )
	table.insert(AssignedObjectives, ScenarioInfo.M1P1)
	if Difficulty >= 3 then
		--------------------------------
		--Mission 1 Hard Objective Timer
		--------------------------------
		ScenarioInfo.M1HT = Objectives.Timer(
			'secondary',                      -- type
			'incomplete',                   -- complete
			'Complete the objective before the timer reaches zero',  -- title
			'Intel suggests that we will need to proceed with the next stage of the mission when this timer runs out.',  -- description
			{                               -- target
				Timer = M1Timer,
				ExpireResult = 'failed',
			}
	    )
		ScenarioInfo.M1HT:AddResultCallback(
			function(result)
				if not (result) then
					if not M2Started then
						if not MissionFailed then
							M2Started = true
							ScenarioFramework.Dialogue(OpStrings.Generic_Reminder_1, IntroMission2, true)
						end
					end
				end
			end
	    )
		table.insert(AssignedObjectives, ScenarioInfo.M1HT)
	end
end

-----------
--Mission 2
-----------

function IntroMission2()
	LOG('Intro Mission 2')
	ScenarioInfo.Civ_Science_Building = ScenarioUtils.CreateArmyUnit('Science_Facility_Equium', 'Science_Facility_Equium_Building')
	ScenarioFramework.CreateUnitDestroyedTrigger(M2S1CentreDestroyed, ScenarioInfo.Civ_Science_Building)
	ScenarioInfo.Civ_Science_Building:SetReclaimable(false)
	ScenarioInfo.Civ_Science_Building:SetCustomName("Science Facility Equium")
	ScenarioFramework.SetPlayableArea('2ND_MISSION_AREA', true)
    ScenarioInfo.MissionNumber = 2
    StartMission2a()
end

--Mission 2
function StartMission2a()
	LOG('Starting Mission 2 Part 1/3')
	LOG('Starting Mission 2 Primary Objective 1')
	ScenarioFramework.Dialogue(OpStrings.DePuce_Angry, nil, true)
	ScenarioFramework.Dialogue(OpStrings.M2a_intro, nil, true)
	LOG('Timer Started')
	M2CivAI.Science_Facility_Equium_Base_Patrol()
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
				ObjCounter = ObjCounter + 1
				LOG("Objective Complete Counter:" .. ObjCounter)
				ScenarioFramework.Dialogue(OpStrings.M2b_intro, StartMission2b, true)
				if(ObjCounter >= 10) then
					ForkThread(PlayerWin)
				end
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
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'Order_M2_Scout', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'Order_M3_Air_Attack_Chain_1')
	platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'Order_M2_Scout', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'Order_M3_Air_Attack_Chain_4')
	LOG('Starting Mission 2 Part 2/3')
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
				ObjCounter = ObjCounter + 1
				LOG("Objective Complete Counter:" .. ObjCounter)
				if not M2CStarted then
					M2CStarted = true
					ScenarioFramework.Dialogue(OpStrings.M2c_intro, StartMission2c, true)
				end
				if(ObjCounter >= 10) then
					ForkThread(PlayerWin)
				end
				if Difficulty >= 3 then
					ScenarioInfo.M2BHT:ManualResult(true)
				end
            end
        end
    )
	table.insert(AssignedObjectives, ScenarioInfo.M2P3)
	WaitSeconds(1)
	if Difficulty >= 3 then
		--------------------------------
		--Mission 2B Hard Objective Timer
		--------------------------------
		ScenarioInfo.M2BHT = Objectives.Timer(
			'secondary',                      -- type
			'incomplete',                   -- complete
			'Complete the objective before the timer reaches zero',  -- title
			'Intel suggests that we will need to proceed with the next stage of the mission when this timer runs out.',  -- description
			{                               -- target
				Timer = M2BTimer,
				ExpireResult = 'failed',
			}
	    )
		ScenarioInfo.M2BHT:AddResultCallback(
			function(result)
				if not (result) then
					if not M2CStarted then
						if not MissionFailed then
							M2CStarted = true
							ScenarioFramework.Dialogue(OpStrings.Generic_Reminder_1, StartMission2c, true)
							ScenarioFramework.Dialogue(OpStrings.M2c_intro)
						end
					end
				end
			end
	    )
		table.insert(AssignedObjectives, ScenarioInfo.M2BHT)
	end
	-- M2 Order Assult Easy
	platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'Order_M2_ASF', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'Order_M3_Air_Attack_Chain_1')
	platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'Order_M2_Strat', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'Order_M3_Air_Attack_Chain_1')
	if SpawnPlayerCDRTotal >=2 then
		--More than 1 Player
		WaitSeconds(3)
		platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'Order_M2_ASF', 'GrowthFormation')
		ScenarioFramework.PlatoonPatrolChain(platoon, 'Order_M3_Air_Attack_Chain_1')
		platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'Order_M2_Strat', 'GrowthFormation')
		ScenarioFramework.PlatoonPatrolChain(platoon, 'Order_M3_Air_Attack_Chain_1')
	end
	if SpawnPlayerCDRTotal >=4 then
		--More than 3 Players
		WaitSeconds(3)
		platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'Order_M2_ASF', 'GrowthFormation')
		ScenarioFramework.PlatoonPatrolChain(platoon, 'Order_M3_Air_Attack_Chain_1')
		platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'Order_M2_Strat', 'GrowthFormation')
		ScenarioFramework.PlatoonPatrolChain(platoon, 'Order_M3_Air_Attack_Chain_1')
		platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'Order_M2_EXP', 'GrowthFormation')
		ScenarioFramework.PlatoonPatrolChain(platoon, 'Order_M3_Air_Attack_Chain_1')
	end
	-- M2 Order Assult Medium
	if Difficulty >=2 then
		WaitSeconds(4)
		platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'Order_M2_ASF', 'GrowthFormation')
		ScenarioFramework.PlatoonPatrolChain(platoon, 'Order_M3_Air_Attack_Chain_1')
		platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'Order_M2_Strat', 'GrowthFormation')
		ScenarioFramework.PlatoonPatrolChain(platoon, 'Order_M3_Air_Attack_Chain_1')
		if SpawnPlayerCDRTotal >=2 then
			--More than 1 Player
			WaitSeconds(4)
			platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'Order_M2_ASF', 'GrowthFormation')
			ScenarioFramework.PlatoonPatrolChain(platoon, 'Order_M3_Air_Attack_Chain_1')
			platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'Order_M2_Strat', 'GrowthFormation')
			ScenarioFramework.PlatoonPatrolChain(platoon, 'Order_M3_Air_Attack_Chain_1')
			platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'Order_M2_EXP', 'GrowthFormation')
			ScenarioFramework.PlatoonPatrolChain(platoon, 'Order_M3_Air_Attack_Chain_1')
		end
		if SpawnPlayerCDRTotal >=4 then
			--More than 3 Players
			WaitSeconds(4)
			platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'Order_M2_ASF', 'GrowthFormation')
			ScenarioFramework.PlatoonPatrolChain(platoon, 'Order_M3_Air_Attack_Chain_1')
			platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'Order_M2_Strat', 'GrowthFormation')
			ScenarioFramework.PlatoonPatrolChain(platoon, 'Order_M3_Air_Attack_Chain_1')
			platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'Order_M2_EXP', 'GrowthFormation')
			ScenarioFramework.PlatoonPatrolChain(platoon, 'Order_M3_Air_Attack_Chain_1')
		end
	end
	-- M2 Order Assult Hard
	if Difficulty >=3 then
		WaitSeconds(4)
		platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'Order_M2_ASF', 'GrowthFormation')
		ScenarioFramework.PlatoonPatrolChain(platoon, 'Order_M3_Air_Attack_Chain_1')
		platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'Order_M2_Strat', 'GrowthFormation')
		ScenarioFramework.PlatoonPatrolChain(platoon, 'Order_M3_Air_Attack_Chain_1')
		platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'Order_M2_EXP', 'GrowthFormation')
		ScenarioFramework.PlatoonPatrolChain(platoon, 'Order_M3_Air_Attack_Chain_1')
		if SpawnPlayerCDRTotal >=2 then
			--More than 1 Player
			WaitSeconds(4)
			platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'Order_M2_ASF', 'GrowthFormation')
			ScenarioFramework.PlatoonPatrolChain(platoon, 'Order_M3_Air_Attack_Chain_1')
			platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'Order_M2_Strat', 'GrowthFormation')
			ScenarioFramework.PlatoonPatrolChain(platoon, 'Order_M3_Air_Attack_Chain_1')
			platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'Order_M2_EXP', 'GrowthFormation')
			ScenarioFramework.PlatoonPatrolChain(platoon, 'Order_M3_Air_Attack_Chain_1')
		end
		if SpawnPlayerCDRTotal >=4 then
			--More than 3 Players
			WaitSeconds(4)
			platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'Order_M2_ASF', 'GrowthFormation')
			ScenarioFramework.PlatoonPatrolChain(platoon, 'Order_M3_Air_Attack_Chain_1')
			platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'Order_M2_Strat', 'GrowthFormation')
			ScenarioFramework.PlatoonPatrolChain(platoon, 'Order_M3_Air_Attack_Chain_1')
			platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'Order_M2_EXP', 'GrowthFormation')
			ScenarioFramework.PlatoonPatrolChain(platoon, 'Order_M3_Air_Attack_Chain_1')
		end
	end
	WaitSeconds(1)
	M3OrderAI.Order_M3_South_East_BaseAI(SpawnPlayerCDRTotal)
	WaitSeconds(1)
	M3SeraphimAI.Seraphim_M3_South_West_BaseAI(SpawnPlayerCDRTotal)
end
	
function StartMission2c()
	LOG('Starting Mission 2 Part 3/3')
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'Seraphim_M2_Scout', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'Seraphim_M3_Air_Attack_Chain_1')
	platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'Seraphim_M2_Scout', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'Seraphim_M3_Air_Attack_Chain_2')
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
				ObjCounter = ObjCounter + 1
				LOG("Objective Complete Counter:" .. ObjCounter)
				if not M3Started then
					M3Started = true
					ScenarioFramework.Dialogue(OpStrings.M2c_complete, StartMission3, true)
				end
				if(ObjCounter >= 10) then
					ForkThread(PlayerWin)
				end
				if Difficulty >= 3 then
					ScenarioInfo.M2CHT:ManualResult(true)
				end
			end
		end
	)
	table.insert(AssignedObjectives, ScenarioInfo.M2P4)
	if Difficulty >= 3 then
		--------------------------------
		--Mission 2C Hard Objective Timer
		--------------------------------
		ScenarioInfo.M2CHT = Objectives.Timer(
			'secondary',                      -- type
			'incomplete',                   -- complete
			'Complete the objective before the timer reaches zero',  -- title
			'Intel suggests that we will need to proceed with the next stage of the mission when this timer runs out.',  -- description
			{                               -- target
				Timer = M2CTimer,
				ExpireResult = 'failed',
			}
	    )
		ScenarioInfo.M2CHT:AddResultCallback(
			function(result)
				if not (result) then
					if not M3Started then
						if not MissionFailed then
							M3Started = true
							ScenarioFramework.Dialogue(OpStrings.Generic_Reminder_2, StartMission3, true)
						end
					end
				end
			end
	    )
		table.insert(AssignedObjectives, ScenarioInfo.M2CHT)
	end
	-- M2 Seraphim Assult Easy
	platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'Seraphim_M2_ASF', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'Seraphim_M3_Air_Attack_Chain_1')
	platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'Seraphim_M2_Strat', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'Seraphim_M3_Air_Attack_Chain_1')
	if SpawnPlayerCDRTotal >=2 then
		--More than 1 Player
		WaitSeconds(2)
		platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'Seraphim_M2_ASF', 'GrowthFormation')
		ScenarioFramework.PlatoonPatrolChain(platoon, 'Seraphim_M3_Air_Attack_Chain_1')
		platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'Seraphim_M2_Strat', 'GrowthFormation')
		ScenarioFramework.PlatoonPatrolChain(platoon, 'Seraphim_M3_Air_Attack_Chain_1')
	end
	if SpawnPlayerCDRTotal >=4 then
		--More than 3 Players
		WaitSeconds(2)
		platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'Seraphim_M2_ASF', 'GrowthFormation')
		ScenarioFramework.PlatoonPatrolChain(platoon, 'Seraphim_M3_Air_Attack_Chain_1')
		platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'Seraphim_M2_Strat', 'GrowthFormation')
		ScenarioFramework.PlatoonPatrolChain(platoon, 'Seraphim_M3_Air_Attack_Chain_1')
		platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'Seraphim_M2_EXP', 'GrowthFormation')
		ScenarioFramework.PlatoonPatrolChain(platoon, 'Seraphim_M3_Air_Attack_Chain_1')
	end
	-- M2 Seraphim Assult Medium
	if Difficulty >=2 then
		WaitSeconds(2)
		platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'Seraphim_M2_ASF', 'GrowthFormation')
		ScenarioFramework.PlatoonPatrolChain(platoon, 'Seraphim_M3_Air_Attack_Chain_1')
		platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'Seraphim_M2_Strat', 'GrowthFormation')
		ScenarioFramework.PlatoonPatrolChain(platoon, 'Seraphim_M3_Air_Attack_Chain_1')
		if SpawnPlayerCDRTotal >=2 then
			--More than 1 Player
			WaitSeconds(2)
			platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'Seraphim_M2_ASF', 'GrowthFormation')
			ScenarioFramework.PlatoonPatrolChain(platoon, 'Seraphim_M3_Air_Attack_Chain_1')
			platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'Seraphim_M2_Strat', 'GrowthFormation')
			ScenarioFramework.PlatoonPatrolChain(platoon, 'Seraphim_M3_Air_Attack_Chain_1')
			platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'Seraphim_M2_EXP', 'GrowthFormation')
			ScenarioFramework.PlatoonPatrolChain(platoon, 'Seraphim_M3_Air_Attack_Chain_1')
		end
		if SpawnPlayerCDRTotal >=4 then
			--More than 3 Players
			WaitSeconds(2)
			platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'Seraphim_M2_ASF', 'GrowthFormation')
			ScenarioFramework.PlatoonPatrolChain(platoon, 'Seraphim_M3_Air_Attack_Chain_1')
			platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'Seraphim_M2_Strat', 'GrowthFormation')
			ScenarioFramework.PlatoonPatrolChain(platoon, 'Seraphim_M3_Air_Attack_Chain_1')
			platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'Seraphim_M2_EXP', 'GrowthFormation')
			ScenarioFramework.PlatoonPatrolChain(platoon, 'Seraphim_M3_Air_Attack_Chain_1')
		end
	end
	-- M2 Seraphim Assult Hard
	if Difficulty >=3 then
		WaitSeconds(2)
		platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'Seraphim_M2_ASF', 'GrowthFormation')
		ScenarioFramework.PlatoonPatrolChain(platoon, 'Seraphim_M3_Air_Attack_Chain_1')
		platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'Seraphim_M2_Strat', 'GrowthFormation')
		ScenarioFramework.PlatoonPatrolChain(platoon, 'Seraphim_M3_Air_Attack_Chain_1')
		platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'Seraphim_M2_EXP', 'GrowthFormation')
		ScenarioFramework.PlatoonPatrolChain(platoon, 'Seraphim_M3_Air_Attack_Chain_1')
		if SpawnPlayerCDRTotal >=2 then
			--More than 1 Player
			WaitSeconds(2)
			platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'Seraphim_M2_ASF', 'GrowthFormation')
			ScenarioFramework.PlatoonPatrolChain(platoon, 'Seraphim_M3_Air_Attack_Chain_1')
			platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'Seraphim_M2_Strat', 'GrowthFormation')
			ScenarioFramework.PlatoonPatrolChain(platoon, 'Seraphim_M3_Air_Attack_Chain_1')
			platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'Seraphim_M2_EXP', 'GrowthFormation')
			ScenarioFramework.PlatoonPatrolChain(platoon, 'Seraphim_M3_Air_Attack_Chain_1')
		end
		if SpawnPlayerCDRTotal >=4 then
			--More than 3 Players
			WaitSeconds(2)
			platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'Seraphim_M2_ASF', 'GrowthFormation')
			ScenarioFramework.PlatoonPatrolChain(platoon, 'Seraphim_M3_Air_Attack_Chain_1')
			platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'Seraphim_M2_Strat', 'GrowthFormation')
			ScenarioFramework.PlatoonPatrolChain(platoon, 'Seraphim_M3_Air_Attack_Chain_1')
			platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'Seraphim_M2_EXP', 'GrowthFormation')
			ScenarioFramework.PlatoonPatrolChain(platoon, 'Seraphim_M3_Air_Attack_Chain_1')
		end
	end
end

-----------
--Mission 3
-----------

function StartMission3()
	if not MissionFailed then
		LOG('Starting Misson 3')
		ScenarioFramework.SetPlayableArea('3RD_MISSION_AREA', true)
		AICheats(Order, SpawnPlayerCDRTotal)
		AICheats(Seraphim, SpawnPlayerCDRTotal)
		M3SeraphimAI.Seraphim_M3_South_West_Base_Air_Attacks(SpawnPlayerCDRTotal)
		M3OrderAI.Order_M3_South_East_Base_Air_Attacks(SpawnPlayerCDRTotal)
		SeraphimNorthBaseAI.Seraphim_North_Base_M3_Land_Attacks(SpawnPlayerCDRTotal)
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
					ObjCounter = ObjCounter + 1
					LOG("Objective Complete Counter:" .. ObjCounter)
					LOG("Objective Complete")
					M3OrderAI.DisableBase()
					if(ObjCounter >= 10) then
						ForkThread(PlayerWin)
					end
					if not M4BaseSpawned then
						M4BaseSpawned = true
						ForkThread(SpawnMission4Base)
					end
					if ScenarioInfo.M3P2.Complete then
						M2S1CentreCheck()
						if Difficulty >= 3 then
							ScenarioInfo.M3HT:ManualResult(true)
						end
						if not M4Started then
							M4Started = true
							ScenarioFramework.Dialogue(OpStrings.M3_complete, StartMission4, true)
						end
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
						Category = categories.FACTORY + categories.ECONOMIC + categories.CONSTRUCTION + categories.xsb4301 + categories.xsb4302 + categories.xsb3104,
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
					ObjCounter = ObjCounter + 1
					LOG("Objective Complete Counter:" .. ObjCounter)
					LOG("Objective Complete")
					M3OrderAI.DisableBase()
					if(ObjCounter >= 10) then
						ForkThread(PlayerWin)
					end
					if not M4BaseSpawned then
						M4BaseSpawned = true
						ForkThread(SpawnMission4Base)
					end
					if ScenarioInfo.M3P1.Complete then
						M2S1CentreCheck()
						if Difficulty >= 3 then
							ScenarioInfo.M3HT:ManualResult(true)
						end
						if not M4Started then
							M4Started = true
							ScenarioFramework.Dialogue(OpStrings.M3_complete, StartMission4, true)
						end
					end
				end
			end
		)
		table.insert(AssignedObjectives, ScenarioInfo.M3P2)
		if Difficulty >= 3 then
			--------------------------------
			--Mission 3 Hard Objective Timer
			--------------------------------
			ScenarioInfo.M3HT = Objectives.Timer(
				'secondary',                      -- type
				'incomplete',                   -- complete
				'Complete the objective before the timer reaches zero',  -- title
				'Intel suggests that we will need to proceed with the next stage of the mission when this timer runs out.',  -- description
				{                               -- target
					Timer = M3Timer,
					ExpireResult = 'failed',
				}
		    )
			ScenarioInfo.M3HT:AddResultCallback(
				function(result)
					if not (result) then
						if not M4Started then
							if not MissionFailed then
								LOG("M3 Timer Expired")
								if not M4BaseSpawned then
									M4BaseSpawned = true
									ForkThread(SpawnMission4Base)
								end
								if not M4Started then
									M4Started = true
									ScenarioFramework.Dialogue(OpStrings.Generic_Reminder_2, StartMission4, true)
								end
							end
						end
					end
				end
		    )
			table.insert(AssignedObjectives, ScenarioInfo.M3HT)
		end
	end
end

-----------
--Mission 4
-----------

function SpawnMission4Base()
	M4QAIAI.QAI_M4_BaseAI(SpawnPlayerCDRTotal)
	WaitSeconds(1)
	M4SeraphimAI.Seraphim_M4_South_West_BaseAI(SpawnPlayerCDRTotal)
	WaitSeconds(1)
	M4OrderAI.Order_M4_South_East_BaseAI(SpawnPlayerCDRTotal)
	
	ScenarioInfo.OrderACU = ScenarioFramework.SpawnCommander('Order', 'Order_ACU', false, 'Cassandra', false, false, 
	{'Shield', 'ShieldHeavy', 'AdvancedEngineering', 'T3Engineering', 'HeatSink'})
	
	ScenarioInfo.SeraphimACU = ScenarioFramework.SpawnCommander('Seraphim', 'Seraphim_ACU', false, 'Thuum-Shavoh', false, false, 
	{'AdvancedEngineering', 'T3Engineering', 'RegenAura', 'AdvancedRegenAura', 'DamageStabilization', 'DamageStabilizationAdvanced'})
end

function StartMission4()
	LOG('Starting Mission 4')
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
	M4SeraphimAI.Seraphim_M4_Ythotha(SpawnPlayerCDRTotal)
	M4SeraphimAI.Seraphim_M4_Ahwassa(SpawnPlayerCDRTotal)
	SeraphimNorthBaseAI.Seraphim_North_Base_Ythotha(SpawnPlayerCDRTotal)
	SeraphimNorthBaseAI.Seraphim_North_Base_M4_Land_Attacks(SpawnPlayerCDRTotal)
	M4OrderAI.Order_M4_South_East_Base_Air_Attacks(SpawnPlayerCDRTotal)
	M4OrderAI.Order_M4_Galactic_Colossus()
	M4OrderAI.Order_M4_CZAR(SpawnPlayerCDRTotal)
	M4QAIAI.QAI_M4_Base_Air_Attacks(SpawnPlayerCDRTotal)
	ScenarioFramework.Dialogue(OpStrings.M4_intro1, nil, true)
	ScenarioInfo.MissionNumber = 4
	ScenarioInfo.Angry_Command_Centre = ScenarioUtils.CreateArmyUnit('QAI', 'Angry_Commander_Control_Centre')
	if Difficulty >= 3 then
		ScenarioInfo.AngryACU1 = ScenarioFramework.SpawnCommander('QAI', 'Angry_Commander1', false, 'Experimental Commander 1', false, false, 
		{'MicrowaveLaserGenerator', 'StealthGenerator', 'CloakingGenerator', 'CoolingUpgrade'})
	
		ScenarioInfo.AngryACU2 = ScenarioFramework.SpawnCommander('QAI', 'Angry_Commander2', false, 'Experimental Commander 2', false, false, 
		{'MicrowaveLaserGenerator', 'StealthGenerator', 'CloakingGenerator', 'CoolingUpgrade'})
	
		ScenarioInfo.AngryACU3 = ScenarioFramework.SpawnCommander('QAI', 'Angry_Commander3', false, 'Experimental Commander 3', false, false, 
		{'MicrowaveLaserGenerator', 'StealthGenerator', 'CloakingGenerator', 'CoolingUpgrade'})
	
		ScenarioInfo.AngryACU4 = ScenarioFramework.SpawnCommander('QAI', 'Angry_Commander4', false, 'Experimental Commander 4', false, false, 
		{'MicrowaveLaserGenerator', 'StealthGenerator', 'CloakingGenerator', 'CoolingUpgrade'})
	else
		ScenarioInfo.AngryACU1 = ScenarioFramework.SpawnCommander('QAI', 'Angry_Commander1', false, 'Experimental Commander 1', false, false, 
		{'MicrowaveLaserGenerator', 'ResourceAllocation', 'CoolingUpgrade'})
		
		ScenarioInfo.AngryACU2 = ScenarioFramework.SpawnCommander('QAI', 'Angry_Commander2', false, 'Experimental Commander 2', false, false, 
		{'MicrowaveLaserGenerator', 'ResourceAllocation', 'CoolingUpgrade'})
		
		ScenarioInfo.AngryACU3 = ScenarioFramework.SpawnCommander('QAI', 'Angry_Commander3', false, 'Experimental Commander 3', false, false, 
		{'MicrowaveLaserGenerator', 'ResourceAllocation', 'CoolingUpgrade'})
		
		ScenarioInfo.AngryACU4 = ScenarioFramework.SpawnCommander('QAI', 'Angry_Commander4', false, 'Experimental Commander 4', false, false, 
		{'MicrowaveLaserGenerator', 'ResourceAllocation', 'CoolingUpgrade'})
	end
	ScenarioInfo.AngryACU1:SetVeterancy(5)
	ScenarioInfo.AngryACU2:SetVeterancy(5)
	ScenarioInfo.AngryACU3:SetVeterancy(5)
	ScenarioInfo.AngryACU4:SetVeterancy(5)
	ScenarioInfo.AngryACU1:SetCanBeKilled(false)
	ScenarioInfo.AngryACU2:SetCanBeKilled(false)
	ScenarioInfo.AngryACU3:SetCanBeKilled(false)
	ScenarioInfo.AngryACU4:SetCanBeKilled(false)
	ScenarioInfo.AngryACU1:SetCanTakeDamage(false)
	ScenarioInfo.AngryACU2:SetCanTakeDamage(false)
	ScenarioInfo.AngryACU3:SetCanTakeDamage(false)
	ScenarioInfo.AngryACU4:SetCanTakeDamage(false)
	ScenarioInfo.Angry_Command_Centre:SetCustomName("QAI Science Facility")
	ScenarioFramework.SetPlayableArea('4TH_MISSION_AREA', true)
	AICheats(QAI, SpawnPlayerCDRTotal)
	AICheats(Order, SpawnPlayerCDRTotal)
	AICheats(Seraphim, SpawnPlayerCDRTotal)
	WaitSeconds(5)
	-------------------------------------------------------------------
	--Mission 4 Primary Objective 1 - Destroy the QAI science centre
	-------------------------------------------------------------------
	ScenarioInfo.M4P1 = Objectives.KillOrCapture(
		'primary',                      -- type
		'incomplete',                   -- complete
		'Destroy the QAI science centre',  -- title
		'Destroy the QAI science centre to make the experimental commanders killable',  -- description
		{                               -- target
			Units = {ScenarioInfo.Angry_Command_Centre},
			MarkUnits = true,
			AlwaysVisible = true,
		}
	)
	ScenarioInfo.M4P1:AddResultCallback(
		function(result)
			if(result) then
				ObjCounter = ObjCounter + 1
				LOG("Objective Complete Counter:" .. ObjCounter)
				ScenarioFramework.Dialogue(OpStrings.QAI_Centre_Destroyed)
				ScenarioFramework.Dialogue(OpStrings.M4_intro3, Destroyed_Science_Centre, true)
				if(ObjCounter >= 10) then
					ForkThread(PlayerWin)
				end
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
				ObjCounter = ObjCounter + 1
				LOG("Objective Complete Counter:" .. ObjCounter)
				if(ObjCounter >= 10) then
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
				ObjCounter = ObjCounter + 1
				LOG("Objective Complete Counter:" .. ObjCounter)
				if(ObjCounter >= 10) then
					ForkThread(PlayerWin)
				end
			end
		end
	)
	table.insert(AssignedObjectives, ScenarioInfo.M4P3)
	WaitSeconds(5)
	-------------------------------------------------------------------
	-- Mission 4 Secondary Objective 1 - Destroy Northern Seraphim Base
	-------------------------------------------------------------------
	ScenarioInfo.M4S1 = Objectives.CategoriesInArea(
		'secondary',                    # type
		'incomplete',                   # complete
		'Destroy the Northern Seraphim Base',    # title
		'Destroy the Northern Seraphim Base to stop the ground assault',  # description
		'kill',                         # action
		{                               # target
			MarkUnits = true,
			FlashVisible = true,
			Requirements = {
				{   
					Area = '4TH_MISSION_AREA',
					Category = categories.FACTORY + categories.ECONOMIC + categories.CONSTRUCTION + categories.xsb4301 + categories.xsb4302 + categories.xsb3104 + categories.xsl0301,
					CompareOp = '<=',
					Value = 0,
					ArmyIndex = Seraphim,
				},
			},
		}
	)
	ScenarioFramework.CreateTimerTrigger(M1P1Reminder1, 1500)
	LOG('Assigned Mission 4 Secondary Objective 1')
	ScenarioInfo.M4S1:AddResultCallback(
		function(result)
			if(result) then
				SeraphimNorthBaseAI.DisableBase()
			end
		end
	)
end

function AngryACUMove()
	local cmd = IssueMove({ScenarioInfo.AngryACU1}, ScenarioUtils.MarkerToPosition('Angry_Commander_Move_Marker_1'))
	local cmd = IssueMove({ScenarioInfo.AngryACU2}, ScenarioUtils.MarkerToPosition('Angry_Commander_Move_Marker_2'))
	local cmd = IssueMove({ScenarioInfo.AngryACU3}, ScenarioUtils.MarkerToPosition('Angry_Commander_Move_Marker_3'))
	local cmd = IssueMove({ScenarioInfo.AngryACU4}, ScenarioUtils.MarkerToPosition('DePuce_Base_Marker'))
end

function Destroyed_Science_Centre()
	ScenarioInfo.AngryACU1:SetCanBeKilled(true)
	ScenarioInfo.AngryACU2:SetCanBeKilled(true)
	ScenarioInfo.AngryACU3:SetCanBeKilled(true)
	ScenarioInfo.AngryACU4:SetCanBeKilled(true)
	ScenarioInfo.AngryACU1:SetCanTakeDamage(true)
	ScenarioInfo.AngryACU2:SetCanTakeDamage(true)
	ScenarioInfo.AngryACU3:SetCanTakeDamage(true)
	ScenarioInfo.AngryACU4:SetCanTakeDamage(true)
	ScenarioFramework.CreateUnitDestroyedTrigger(QAI_Angry_1, ScenarioInfo.AngryACU1)
	ScenarioFramework.CreateUnitDestroyedTrigger(QAI_Angry_2, ScenarioInfo.AngryACU2)
	ScenarioFramework.CreateUnitDestroyedTrigger(QAI_Angry_3, ScenarioInfo.AngryACU3)
	ScenarioFramework.CreateUnitDestroyedTrigger(QAI_Angry_4, ScenarioInfo.AngryACU4)
	-------------------------------------------------
	--Mission 4 Primary Objective 4 - Kill Angry ACUs
	-------------------------------------------------

	ScenarioInfo.M4P4 = Objectives.CategoriesInArea(
		'primary',                      # type
		'incomplete',                   # complete
		'Destroy the experimental command units',    # title
		'Eliminate the marked units.',  # description
		'kill',                         # action
		{                               # target
			MarkUnits = true,
			Requirements = {
				{   
					Area = '4TH_MISSION_AREA',
					Category = categories.url0001,
					CompareOp = '<=',
					Value = 0,
					ArmyIndex = QAI,
				},
			},
		}
	)
	ScenarioFramework.CreateTimerTrigger(M1P1Reminder1, 1500)
	LOG('Assigned Mission 4 Objective 4')
	ScenarioInfo.M4P4:AddResultCallback(
		function(result)
			if(result) then
				M4QAIAI.DisableBase()
				ObjCounter = ObjCounter + 1
				LOG("Objective Complete Counter:" .. ObjCounter)
				if(ObjCounter >= 10) then
					ForkThread(PlayerWin)
				end
			end
		end
	)
end

---------------
--Miscellaneous
---------------

function PlayerWin()
    ForkThread(
        function()
			ScenarioInfo.M2P2:ManualResult(true)
            if(not ScenarioInfo.OpEnded) then
                ScenarioFramework.EndOperationSafety()
                ScenarioFramework.FlushDialogueQueue()
				ScenarioFramework.Dialogue(OpStrings.DePuce_Win)
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
	ACUDeathCounter = ACUDeathCounter + 1
	LOG("ACU death counter: " .. ACUDeathCounter)
	LOG("ACU spawn counter: " .. SpawnPlayerCDRTotal)
	LOG('Player army ' .. Player.Sync.army .. ' ACU Killed')
	if ACUDeathCounter == SpawnPlayerCDRTotal/2 then
		ScenarioFramework.Dialogue(OpStrings.DePuceWorried1, nil, true)
	end
	if SpawnPlayerCDRTotal == ACUDeathCounter then
		MissionFailed = true
		if(not ScenarioInfo.OpEnded) then
			ScenarioFramework.CDRDeathNISCamera(Player)
			ScenarioFramework.EndOperationSafety()
			ScenarioFramework.FlushDialogueQueue()
			for k, v in AssignedObjectives do
				if(v and v.Active) then
					v:ManualResult(false)
				end
			end
			ScenarioFramework.Dialogue(OpStrings.Player_Commander_Dead, nil, true)
			ScenarioInfo.OpComplete = false
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

function DePuceDeath(Player)
	LOG("DePuce Died")
	if(not ScenarioInfo.OpEnded) then
		ScenarioInfo.M2P2:ManualResult(false)
		ScenarioFramework.CDRDeathNISCamera(Player)
		ScenarioFramework.FlushDialogueQueue()
		ScenarioFramework.Dialogue(OpStrings.DePuce_Death, nil, true)
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
	LOG('Science Facility Equim destroyed')
    if(ScenarioInfo.M2S1 and ScenarioInfo.M2S1.Active) then
        ScenarioInfo.M2S1:ManualResult(false)
	end
end

function M3S1CentreDestroyed()
	LOG('Science Facility Bulwark destroyed')
    if(ScenarioInfo.M3S1 and ScenarioInfo.M3S1.Active) then
        ScenarioInfo.M3S1:ManualResult(false)
	end
end

-- Checks if the science centre is alive. If it is then it completes the objective
function M2S1CentreCheck()
	LOG('Science centre check')
	if(ScenarioInfo.M2S1 and ScenarioInfo.M2S1.Active) then
		ScenarioInfo.M2S1:ManualResult(true)
		local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon("Science_Facility_Equium", "Spy_Satellite", 'AttackFormation')
		ScenarioFramework.PlatoonPatrolChain(platoon, "Spy_Satellite_Chain") 
		local OrderM4VisMarker = ScenarioFramework.CreateVisibleAreaLocation(100, 'Order_M4_South_East_Base_Marker', 0, ArmyBrains[Player1])			-- Creates a vision marker that is 100 in diameter at a specified marker that does not expire automatically for the first human player
		local QAIM4VisMarker = ScenarioFramework.CreateVisibleAreaLocation(50, 'QAI_M4_Base_Marker', 0, ArmyBrains[Player1])
		local SeraphimM4VisMarker = ScenarioFramework.CreateVisibleAreaLocation(100, 'Seraphim_M4_South_West_Base_Marker', 0, ArmyBrains[Player1])
		local SeraphimM4NorthVisMarker = ScenarioFramework.CreateVisibleAreaLocation(100, 'Seraphim_North_Base_Marker', 0, ArmyBrains[Player1])
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
	LaunchNuke(Seraphim, categories.xsb2401, "Spawn_ACU_Vis_Marker")
	
	WaitSeconds(600*NukeWaitSecondsDifficultyMultiplier[Difficulty])
	LaunchNuke(Seraphim, categories.xsb2401, "DePuce_Base_Marker")
	
	WaitSeconds(600*NukeWaitSecondsDifficultyMultiplier[Difficulty])
	LaunchNuke(Seraphim, categories.xsb2401, "Player6")
	
	WaitSeconds(600*NukeWaitSecondsDifficultyMultiplier[Difficulty])
	LaunchNuke(Seraphim, categories.xsb2401, "Mass 31")
	
	WaitSeconds(600*NukeWaitSecondsDifficultyMultiplier[Difficulty])
	LaunchNuke(Seraphim, categories.xsb2401, "Mass 01")
	
	WaitSeconds(600*NukeWaitSecondsDifficultyMultiplier[Difficulty])
	LaunchNuke(Seraphim, categories.xsb2401, "Player5")
	M4_Seraphim_Nuke_Loop()
end

function LaunchNuke(Army, NukeLauncherUnitID, Marker)											-- Examples of usage LaunchNuke(Seraphim, categories.xsb2401, "Seraphim_M4_Nuke_Marker_1") This will get all the experimental nuke launchers for the army Seraphim and will launch a nuke at Seraphim_M4_Nuke_Marker_1 NB: NukeLauncherUnitID needs to be in the following format: categories.unitID
	local NukeLauncher = ArmyBrains[Army]:GetListOfUnits(NukeLauncherUnitID, false)				-- Creates a table of all units beloning to the specified army faction that match the unit ID
	NukeLauncher[1]:GiveNukeSiloAmmo(1)															-- Gives the first unit in the table 1 missile to ensure that it launches
    IssueNuke({NukeLauncher[1]}, ScenarioUtils.MarkerToPosition(Marker))						-- Launches a strategic missile at a specified marker that was created in the map editor
end

function SpawnAllACUs()
	SpawnPlayerCDRTotal = SpawnPlayerCDRTotal + 1
	LOG("Spawning ACU")
	for iArmy, strArmy in pairs(tblArmy) do														-- This command gets each value and puts the integer in iArmy and the string in strArmy then loops the function for every row in the table e.g value from table [1] => "QAI" iArmy would be 1 and strArmy would be "QAI" as that is the first entry in the table, the order the table is generated is in the same order as the armies appear in the scenario file.
		if iArmy >= ScenarioInfo.Player1 then													-- Checks if iArmy is greater than or equal to the first human player
		Nickname = GetArmyBrain(strArmy).Nickname											-- Gets the Nickname (faf username) from the players army
		factionIdx = GetArmyBrain(strArmy):GetFactionIndex()								-- Gets the faction value from the players army
		if factionIdx >3 then factionIdx = 1 end											-- If the faction is greater than QAI (3) (as seraphim is 4) then it sets the faction as UEF (1)
		strFactionIdx = tostring(factionIdx)												-- Creates a variable that converts the faction integer into a string value
		if strArmy == 'Player1' then														-- If the army name is Player1 then it sets the army colour to someting based off the facton
			ArmyColourNum = ScenarioInfo.ArmySetup.Player1.ArmyColor
		end
		if strArmy == 'Player2' then
			ArmyColourNum = ScenarioInfo.ArmySetup.Player2.ArmyColor
		end
		if strArmy == 'Player3' then
			ArmyColourNum = ScenarioInfo.ArmySetup.Player3.ArmyColor
		end
		if strArmy == 'Player4' then
			ArmyColourNum = ScenarioInfo.ArmySetup.Player4.ArmyColor
		end
		if strArmy == 'Player5' then
			ArmyColourNum = ScenarioInfo.ArmySetup.Player5.ArmyColor
		end
		if strArmy == 'Player6' then
			ArmyColourNum = ScenarioInfo.ArmySetup.Player6.ArmyColor
		end
		SetArmyColor(strArmy, ArmyColours[ArmyColourNum].r, ArmyColours[ArmyColourNum].g, ArmyColours[ArmyColourNum].b)
			ScenarioInfo.PlayerCDR[iArmy] = ScenarioFramework.SpawnCommander(strArmy, strFactionIdx, 'Warp', 'CDR '..Nickname, true, PlayerDeath)
			if Debug then														-- Check if Debug = true
				ScenarioUtils.CreateArmyGroup(strArmy, 'Debug')					-- Creates the debug base
				AICheats(strArmy, nil, 100)											-- Sets cheat rate for the player
				ScenarioInfo.PlayerCDR[iArmy]:SetCanTakeDamage(false)
			end
		end
	end
end

function Defence_Satellite_Spawner()
	WaitSeconds(100)
	if(ScenarioInfo.M3S1 and ScenarioInfo.M3S1.Active) then
		ScenarioInfo.M3S1:ManualResult(true)
	end
	Satellite_Spawner("Science_Facility_Equium", "Defence_Satellite", "Defence_Satellite_Chain")
	WaitSeconds(40)
	Satellite_Spawner("Science_Facility_Equium", "Defence_Satellite", "Defence_Satellite_Chain")
	WaitSeconds(40)
	Satellite_Spawner("Science_Facility_Equium", "Defence_Satellite", "Defence_Satellite_Chain")
	WaitSeconds(40)
	Satellite_Spawner("Science_Facility_Equium", "Defence_Satellite", "Defence_Satellite_Chain")
	WaitSeconds(40)
	Satellite_Spawner("Science_Facility_Equium", "Defence_Satellite", "Defence_Satellite_Chain")
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

function QAI_Angry_1()
	ScenarioFramework.Dialogue(OpStrings.QAI_Angry_1)
end

function QAI_Angry_2()
	ScenarioFramework.Dialogue(OpStrings.QAI_Angry_2)
end

function QAI_Angry_3()
	ScenarioFramework.Dialogue(OpStrings.QAI_Angry_3)
end

function QAI_Angry_4()
	ScenarioFramework.Dialogue(OpStrings.QAI_Angry_4)
end

function Seraphim_Super_Nuke_Warning()
	ScenarioFramework.Dialogue(OpStrings.Seraphim_Super_Nuke_Warning)
	WaitSeconds(5)
	if not NE_Centre_Destroyed then 
		--------------------------------------------------------------------
		--Mission 3 Secondary Objective 1 - Protect science facility bulwark
		--------------------------------------------------------------------
		ScenarioInfo.M3S1 = Objectives.Basic(
			'secondary',                      # type
			'incomplete',                   # complete
			'Protect Science Facility Bulwark',  # title
			'Protect Science Facility Bulwark from a strategic missile',  # description
			'Protect',                         # action
			{
				MarkUnits = true,
				Units = {ScenarioInfo.NE_Science_Building}
			}
		)
		ScenarioInfo.M3S1:AddResultCallback(
			function(result)
				if result then
					ScenarioFramework.Dialogue(OpStrings.M3S1_complete, nil, false)
				end
			end
		)
		table.insert(AssignedObjectives, ScenarioInfo.M3S1)
	end
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