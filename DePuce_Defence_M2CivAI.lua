local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Buff = import('/lua/sim/Buff.lua')

local Civ_Science_Facility = BaseManager.CreateBaseManager()
local Difficulty = ScenarioInfo.Options.Difficulty
local UnitModifier = {2,1,0.5}
local Civilians = 4

function Civ_Science_Facility_BaseAI()
    Civ_Science_Facility:Initialize(ArmyBrains[Civilians], 'Civ_Science_Facility', 'Civ_Science_Facility_Marker', 40, {Civ_Science_Facility = 600})
    Civ_Science_Facility:StartNonZeroBase({{4,3,2}, {2,1,1}})
    Civ_Science_Facility:SetActive('AirScouting', false)
    Civ_Science_Facility:SetActive('LandScouting', false)
end

function Civ_Science_Facility_Patrol()
	Civ_Science_Facility:SetActive('AirScouting', true)
    local opai = nil
	local Temp = {
		'Civ_Science_Facility_Patrol_Template_1',
		'NoPlan',
		{ 'delk002', 1, 1, 'Attack', 'GrowthFormation' },   # T3 AA
		
	}
	local Builder = {
		BuilderName = 'Civ_Science_Facility_Patrol_Builder_1',
		PlatoonTemplate = Temp,
		InstanceCount = 1,
		Priority = 320,
		PlatoonType = 'Land',
		RequiresConstruction = true,
		LocationType = 'Civ_Science_Facility',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'Civilian_M2_Patrol_1'}
		},
	}
	ArmyBrains[Civilians]:PBMAddPlatoon( Builder )
	
	local Temp = {
		'Civ_Science_Facility_Patrol_Template_2',
		'NoPlan',
		{ 'delk002', 1, 1, 'Attack', 'GrowthFormation' },   # T3 AA
		
	}
	local Builder = {
		BuilderName = 'Civ_Science_Facility_Patrol_Builder_2',
		PlatoonTemplate = Temp,
		InstanceCount = 1,
		Priority = 310,
		PlatoonType = 'Land',
		RequiresConstruction = true,
		LocationType = 'Civ_Science_Facility',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'Civilian_M2_Patrol_2'}
		},
	}
	ArmyBrains[Civilians]:PBMAddPlatoon( Builder )
end