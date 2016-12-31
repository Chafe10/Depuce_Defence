local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Buff = import('/lua/sim/Buff.lua')

local Science_Facility_Equium_Base = BaseManager.CreateBaseManager()
local Difficulty = ScenarioInfo.Options.Difficulty
local Science_Facility_Equium = 4

function Science_Facility_Equium_BaseAI()
    Science_Facility_Equium_Base:Initialize(ArmyBrains[Science_Facility_Equium], 'Science_Facility_Equium_Base', 'Science_Facility_Equium_Marker', 40, {Science_Facility_Equium_Base = 330})
    Science_Facility_Equium_Base:StartNonZeroBase({{2,2,2}, {2,2,2}})
    Science_Facility_Equium_Base:SetActive('AirScouting', false)
    Science_Facility_Equium_Base:SetActive('LandScouting', false)
end

function Science_Facility_Equium_Base_Patrol()
	Science_Facility_Equium_Base:SetActive('AirScouting', true)
    local opai = nil
	local Temp = {
		'Science_Facility_Equium_Base_Patrol_Template_1',
		'NoPlan',
		{ 'delk002', 1, 1, 'Attack', 'GrowthFormation' },   # T3 AA
		
	}
	local Builder = {
		BuilderName = 'Science_Facility_Equium_Base_Patrol_Builder_1',
		PlatoonTemplate = Temp,
		InstanceCount = 1,
		Priority = 320,
		PlatoonType = 'Land',
		RequiresConstruction = true,
		LocationType = 'Science_Facility_Equium_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'Civilian_M2_Patrol_1'}
		},
	}
	ArmyBrains[Science_Facility_Equium]:PBMAddPlatoon( Builder )
	
	local Temp = {
		'Science_Facility_Equium_Base_Patrol_Template_2',
		'NoPlan',
		{ 'delk002', 1, 1, 'Attack', 'GrowthFormation' },   # T3 AA
		
	}
	local Builder = {
		BuilderName = 'Science_Facility_Equium_Base_Patrol_Builder_2',
		PlatoonTemplate = Temp,
		InstanceCount = 1,
		Priority = 310,
		PlatoonType = 'Land',
		RequiresConstruction = true,
		LocationType = 'Science_Facility_Equium_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'Civilian_M2_Patrol_2'}
		},
	}
	ArmyBrains[Science_Facility_Equium]:PBMAddPlatoon( Builder )
end