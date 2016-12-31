local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Buff = import('/lua/sim/Buff.lua')

local Seraphim_M3_South_West_Base = BaseManager.CreateBaseManager()
local Difficulty = ScenarioInfo.Options.Difficulty
local WaitForAttackSecondsMultiplier = {1.2,1,0.8}
local UnitModifier = {0.5,1,2}
local Seraphim = 3

function Seraphim_M3_South_West_BaseAI(PlayerCount)
    Seraphim_M3_South_West_Base:Initialize(ArmyBrains[Seraphim], 'Seraphim_M3_South_West_Base', 'Seraphim_M3_South_West_Base_Marker', 80, {Seraphim_M3_South_West_Base = 600})
    Seraphim_M3_South_West_Base:StartNonZeroBase({{5,6,10}, {3,4,6}})
    Seraphim_M3_South_West_Base:SetActive('AirScouting', false)
	Seraphim_M3_South_West_Base_Patrol(PlayerCount)
end

function Seraphim_M3_South_West_Base_Patrol(PlayerCount)
    local opai = nil
	local Temp = {
		'Seraphim_M3_Patrol_Template',
		'NoPlan',
		{ 'xsa0303', 1, 5+PlayerCount/2, 'Attack', 'GrowthFormation' },  # T3 ASF
	}
	local Builder = {
		BuilderName = 'Seraphim_M3_Patrol_Builder',
		PlatoonTemplate = Temp,
		InstanceCount = 2,
		Priority = 310,
		PlatoonType = 'Air',
		RequiresConstruction = true,
		LocationType = 'Seraphim_M3_South_West_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'Seraphim_M3_Patrol'}
		},
	}
	ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
end

function Seraphim_M3_South_West_Base_Air_Attacks(PlayerCount)
	Seraphim_M3_South_West_Base:SetActive('AirScouting', true)
    local opai = nil
	local Temp = {
		'Seraphim_M3_South_West_Base_Air_Attack_Template_1',
		'NoPlan',
		{ 'xsa0203', 1, (14+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   # T2 Gunship
	}
	local Builder = {
		BuilderName = 'Seraphim_M3_South_West_Base_Air_Attack_Builder_1',
		PlatoonTemplate = Temp,
		InstanceCount = 3,
		Priority = 140,
		PlatoonType = 'Air',
		RequiresConstruction = true,
		LocationType = 'Seraphim_M3_South_West_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'Seraphim_M3_Air_Attack_Chain_1', 'Seraphim_M3_Air_Attack_Chain_2', 'Seraphim_M3_Air_Attack_Chain_3'}
		},
	}
	ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
	
	local Temp = {
		'Seraphim_M3_South_West_Base_Air_Attack_Template_2',
		'NoPlan',
		{ 'xsa0304', 1, (8+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   # T3 Bomber
	}
	local Builder = {
		BuilderName = 'Seraphim_M3_South_West_Base_Air_Attack_Builder_2',
		PlatoonTemplate = Temp,
		InstanceCount = 3,
		Priority = 110,
		PlatoonType = 'Air',
		RequiresConstruction = true,
		LocationType = 'Seraphim_M3_South_West_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'Seraphim_M3_Air_Attack_Chain_1', 'Seraphim_M3_Air_Attack_Chain_2', 'Seraphim_M3_Air_Attack_Chain_3'}
		},
	}
	ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

		local Temp = {
		'Seraphim_M3_South_West_Base_Air_Attack_Template_3',
		'NoPlan',
		{ 'xsa0303', 1, (8+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   # T3 Fighter
		{ 'xsa0304', 1, (6+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   # T3 Bomber
	}
	local Builder = {
		BuilderName = 'Seraphim_M3_South_West_Base_Air_Attack_Builder_3',
		PlatoonTemplate = Temp,
		InstanceCount = 2,
		Priority = 120,
		PlatoonType = 'Air',
		RequiresConstruction = true,
		LocationType = 'Seraphim_M3_South_West_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'Seraphim_M3_Air_Attack_Chain_1', 'Seraphim_M3_Air_Attack_Chain_2', 'Seraphim_M3_Air_Attack_Chain_3'}
		},
	}
	ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
end

function DisableBase()
    if(Seraphim_M3_South_West_Base) then
        Seraphim_M3_South_West_Base:BaseActive(false)
        LOG('Seraphim_M3_South_West_Base Disabled')
    end
end