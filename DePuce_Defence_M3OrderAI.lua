local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Buff = import('/lua/sim/Buff.lua')

local Order_M3_South_East_Base = BaseManager.CreateBaseManager()
local Difficulty = ScenarioInfo.Options.Difficulty
local WaitForAttackSecondsMultiplier = {1.2,1,0.8}
local UnitModifier = {0.5,1,2}
local Order = 2

function Order_M3_South_East_BaseAI(PlayerCount)
    Order_M3_South_East_Base:Initialize(ArmyBrains[Order], 'Order_M3_South_East_Base', 'Order_M3_South_East_Base_Marker', 70, {Order_M3_South_East_Base = 600})
    Order_M3_South_East_Base:StartNonZeroBase({{6,8,12}, {3,4,6}})
    Order_M3_South_East_Base:SetActive('AirScouting', false)
	Order_M3_South_East_Base_Patrol(PlayerCount)
end

function Order_M3_South_East_Base_Patrol(PlayerCount)
    local opai = nil
	local Temp = {
		'Order_M3_Air_Patrol_Template',
		'NoPlan',
		{ 'uaa0303', 1, 5+PlayerCount/2, 'Attack', 'GrowthFormation' },   # T3 Air Superiority Fighter
		
	}
	local Builder = {
		BuilderName = 'Order_M3_Air_Patrol_Builder',
		PlatoonTemplate = Temp,
		InstanceCount = 2,
		Priority = 320,
		PlatoonType = 'Air',
		RequiresConstruction = true,
		LocationType = 'Order_M3_South_East_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'Order_M3_Patrol'}
		},
	}
	ArmyBrains[Order]:PBMAddPlatoon( Builder )
end

function Order_M3_South_East_Base_Air_Attacks(PlayerCount)
	Order_M3_South_East_Base:SetActive('AirScouting', true)
    local opai = nil
	local Temp = {
		'Order_M3_Air_Attack_Template_1',
		'NoPlan',
		{ 'uaa0203', 1, (8+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   # T2 Gunship
		{ 'xaa0305', 1, (14+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   # T3 Gunship
	}
	local Builder = {
		BuilderName = 'Order_M3_Air_Attack_Builder_1',
		PlatoonTemplate = Temp,
		InstanceCount = 3,
		Priority = 140,
		PlatoonType = 'Air',
		RequiresConstruction = true,
		LocationType = 'Order_M3_South_East_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'Order_M3_Air_Attack_Chain_1', 'Order_M3_Air_Attack_Chain_2', 'Order_M3_Air_Attack_Chain_3', 'Order_M3_Air_Attack_Chain_4'}
		},
	}
	ArmyBrains[Order]:PBMAddPlatoon( Builder )
	
	local Temp = {
		'Order_M3_Air_Attack_Template_2',
		'NoPlan',
		{ 'uaa0304', 1, (6+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   # T3 Bomber
	}
	local Builder = {
		BuilderName = 'Order_M3_Air_Attack_Builder_2',
		PlatoonTemplate = Temp,
		InstanceCount = 2,
		Priority = 130,
		PlatoonType = 'Air',
		RequiresConstruction = true,
		LocationType = 'Order_M3_South_East_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'Order_M3_Air_Attack_Chain_1', 'Order_M3_Air_Attack_Chain_2', 'Order_M3_Air_Attack_Chain_3', 'Order_M3_Air_Attack_Chain_4'}
		},
	}
	ArmyBrains[Order]:PBMAddPlatoon( Builder )
	
	local Temp = {
		'Order_M3_Air_Attack_Template_3',
		'NoPlan',
		{ 'uaa0303', 1, (6+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   # T3 Fighter
		{ 'uaa0304', 1, (8+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   # T3 Bomber
	}
	local Builder = {
		BuilderName = 'Order_M3_Air_Attack_Builder_3',
		PlatoonTemplate = Temp,
		InstanceCount = 1,
		Priority = 120,
		PlatoonType = 'Air',
		RequiresConstruction = true,
		LocationType = 'Order_M3_South_East_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'Order_M3_Air_Attack_Chain_1', 'Order_M3_Air_Attack_Chain_2', 'Order_M3_Air_Attack_Chain_3', 'Order_M3_Air_Attack_Chain_4'}
		},
	}
	ArmyBrains[Order]:PBMAddPlatoon( Builder )
end

function Order_M3_South_East_Base_Land_Attacks(PlayerCount)
    local opai = nil
	local Temp = {
		'Order_M3_Land_Attack_Template_1',
		'NoPlan',
		{ 'ual0307', 1, (4+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'AttackFormation' },  # T2 Shield Generator
		{ 'ual0303', 1, (8+PlayerCount)*UnitModifier[Difficulty], 'Attack', 'AttackFormation' },  # T3 Attack Bot
		{ 'ual0205', 1, (4+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'AttackFormation' },  # T2 AA
		{ 'ual0202', 1, (6+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'AttackFormation' },  # T2 Heavy Tank
		
	}
	local Builder = {
		BuilderName = 'Order_M3_Land_Attack_Builder_1',
		PlatoonTemplate = Temp,
		InstanceCount = 4,
		Priority = 120,
		PlatoonType = 'Land',
		RequiresConstruction = true,
		LocationType = 'Order_M3_South_East_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'Order_M3_Land_Attack_Chain_1', 'Order_M3_Land_Attack_Chain_2'}
		},
	}
	ArmyBrains[Order]:PBMAddPlatoon( Builder )
	
	local Temp = {
		'Order_M3_Land_Attack_Template_2',
		'NoPlan',
		{ 'ual0304', 1, (8+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'AttackFormation' },  # T3 Arty
		{ 'ual0307', 1, (4+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'AttackFormation' },  # T2 Shield Generator
		{ 'ual0205', 1, (4+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'AttackFormation' },  # T2 AA
		{ 'xal0305', 1, (6+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'AttackFormation' },  # T3 Sniper Bot
		{ 'ual0202', 1, (2+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'AttackFormation' },  # T2 Heavy Tank
		
	}
	local Builder = {
		BuilderName = 'Order_M3_Land_Attack_Builder_2',
		PlatoonTemplate = Temp,
		InstanceCount = 4,
		Priority = 120,
		PlatoonType = 'Land',
		RequiresConstruction = true,
		LocationType = 'Order_M3_South_East_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'Order_M3_Land_Attack_Chain_1', 'Order_M3_Land_Attack_Chain_2'}
		},
	}
	ArmyBrains[Order]:PBMAddPlatoon( Builder )
end

function DisableBase()
    if(Order_M3_South_East_Base) then
        Order_M3_South_East_Base:BaseActive(false)
        LOG('Order_M3_South_East_Base Disabled')
    end
end