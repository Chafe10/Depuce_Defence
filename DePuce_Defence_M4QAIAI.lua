local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Buff = import('/lua/sim/Buff.lua')

local QAI_M4_Base = BaseManager.CreateBaseManager()
local Difficulty = ScenarioInfo.Options.Difficulty
local WaitForAttackSecondsMultiplier = {1.2,1,0.8}
local UnitModifier = {0.5,1,2}
local QAI = 1

function QAI_M4_BaseAI(PlayerCount)
    QAI_M4_Base:Initialize(ArmyBrains[QAI], 'QAI_M4_Base', 'QAI_M4_Base_Marker', 50, {QAI_M4_Base = 600})
    QAI_M4_Base:StartNonZeroBase({{5,6,10}, {3,4,6}})
    QAI_M4_Base:SetActive('AirScouting', false)
	QAI_M4_Patrols(PlayerCount)
end

function QAI_M4_Patrols(PlayerCount)
	local Temp = {
		'QAI_M4_Patrol_Template',
		'NoPlan',
		{ 'ura0303', 1, (4+PlayerCount/2), 'Attack', 'GrowthFormation' },   # T3 ASF
	}
	local Builder = {
		BuilderName = 'QAI_M4_Patrol_Builder',
		PlatoonTemplate = Temp,
		InstanceCount = 2,
		Priority = 400,
		PlatoonType = 'Air',
		RequiresConstruction = true,
		LocationType = 'QAI_M4_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'QAI_M4_Patrol'}
		},
	}
	ArmyBrains[QAI]:PBMAddPlatoon( Builder )
end


function QAI_M4_Base_Land_Attacks(PlayerCount)
	local Temp = {
		'QAI_Land_Attack1',
		'NoPlan',
		{ 'xrl0305', 1, (6+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   # Brick
		{ 'url0303', 1, (6+PlayerCount)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   # Loyalist
		{ 'drlk001', 1, (2+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   # T3 Scorpion AA
	}
	local Builder = {
		BuilderName = 'QAI_Land_Attack_Builder1',
		PlatoonTemplate = Temp,
		InstanceCount = 2,
		Priority = 110,
		PlatoonType = 'Land',
		RequiresConstruction = true,
		LocationType = 'QAI_M4_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'QAI_M4_Land_Attack_Chain_1', 'QAI_M4_Land_Attack_Chain_2'}
		},
	}
	ArmyBrains[QAI]:PBMAddPlatoon( Builder )
	
	local Temp = {
		'QAI_Land_Attack2',
		'NoPlan',
		{ 'xrl0305', 1, (2+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   # Brick
		{ 'drlk001', 1, (2+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   # T3 Scorpion AA
		{ 'url0304', 1, (6+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   # T3 Mobile Arty
	}
	local Builder = {
		BuilderName = 'QAI_Land_Attack_Builder2',
		PlatoonTemplate = Temp,
		InstanceCount = 2,
		Priority = 100,
		PlatoonType = 'Land',
		RequiresConstruction = true,
		LocationType = 'QAI_M4_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'QAI_M4_Land_Attack_Chain_1', 'QAI_M4_Land_Attack_Chain_2'}
		},
	}
	ArmyBrains[QAI]:PBMAddPlatoon( Builder )
end

function QAI_M4_Base_Air_Attacks(PlayerCount)
	local Temp = {
		'QAI_Air_Attack1',
		'NoPlan',
		{ 'xra0305', 1, (6+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   # T3 Gunship
		{ 'ura0203', 1, (6+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   # T2 Gunship
	}
	local Builder = {
		BuilderName = 'QAI_Air_Attack_Builder1',
		PlatoonTemplate = Temp,
		InstanceCount = 1,
		Priority = 110,
		PlatoonType = 'Air',
		RequiresConstruction = true,
		LocationType = 'QAI_M4_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'QAI_M4_Air_Attack_Chain_1', 'QAI_M4_Air_Attack_Chain_2'}
		},
	}
	ArmyBrains[QAI]:PBMAddPlatoon( Builder )
	
	local Temp = {
		'QAI_Air_Attack2',
		'NoPlan',
		{ 'ura0304', 1, (4+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   # T3 Bomber
		{ 'ura0303', 1, (6+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   # T3 Fighter
	}
	local Builder = {
		BuilderName = 'QAI_Air_Attack_Builder2',
		PlatoonTemplate = Temp,
		InstanceCount = 2,
		Priority = 100,
		PlatoonType = 'Air',
		RequiresConstruction = true,
		LocationType = 'QAI_M4_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'QAI_M4_Air_Attack_Chain_1', 'QAI_M4_Air_Attack_Chain_2'}
		},
	}
	ArmyBrains[QAI]:PBMAddPlatoon( Builder )
end

function DisableBase()
    if(QAI_M4_Base) then
        QAI_M4_Base:BaseActive(false)
        LOG('QAI_M4_Base Disabled')
    end
end