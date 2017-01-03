local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Buff = import('/lua/sim/Buff.lua')

local Seraphim_North_Base = BaseManager.CreateBaseManager()
local Difficulty = ScenarioInfo.Options.Difficulty
local WaitForAttackSecondsMultiplier = {1.2,1,0.8}
local UnitModifier = {0.5,1,2}
local Seraphim = 3

function Seraphim_North_BaseAI()
    Seraphim_North_Base:Initialize(ArmyBrains[Seraphim], 'Seraphim_North_Base', 'Seraphim_North_Base_Marker', 90, {Seraphim_North_Base = 600})
    Seraphim_North_Base:StartNonZeroBase({{5,6,12}, {3,4,8}})
end

function Seraphim_North_Base_M3_Land_Attacks(PlayerCount)
    local opai = nil
	
	local Temp = {
		'Seraphim_North_Base_M3_Land_Attack_Template_3',
		'NoPlan',
		{ 'dslk004', 1, (4+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   # T3 Lightning Tank
		{ 'xsl0303', 1, (6+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },  # T3 Seige Tank
	}
	local Builder = {
		BuilderName = 'Seraphim_North_Base_M3_Land_Attack_Builder_1',
		PlatoonTemplate = Temp,
		InstanceCount = 2,
		Priority = 100,
		PlatoonType = 'Land',
		RequiresConstruction = true,
		LocationType = 'Seraphim_North_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'South_Land_Attack_Chain_R1', 'South_Land_Attack_Chain_R2'}
		},
	}
	ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

	local Temp = {
		'Seraphim_North_Base_M3_Land_Attack_Template_4',
		'NoPlan',
		{ 'xsl0303', 1, (10+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },  # T3 Seige Tank
	}
	local Builder = {
		BuilderName = 'Seraphim_North_Base_M3_Land_Attack_Builder_2',
		PlatoonTemplate = Temp,
		InstanceCount = 2,
		Priority = 110,
		PlatoonType = 'Land',
		RequiresConstruction = true,
		LocationType = 'Seraphim_North_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'South_Land_Attack_Chain_R1', 'South_Land_Attack_Chain_R2'}
		},
	}
	ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )	
end

function Seraphim_North_Base_M4_Land_Attacks(PlayerCount)
    local opai = nil
	local Temp = {
		'Seraphim_North_Base_M4_Land_Attack_Template_1',
		'NoPlan',
		{ 'xsl0307', 1, (4+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },  # T3 Shield Generator
		{ 'xsl0303', 1, (8+PlayerCount)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },  # T3 Siege Tank
		{ 'dslk004', 1, (8+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },  # T3 Lightning Tank
		{ 'xsl0202', 1, (4+PlayerCount)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },  # T2 Assualt Bot
		
	}
	local Builder = {
		BuilderName = 'Seraphim_North_Base_M4_Land_Attack_Builder_1',
		PlatoonTemplate = Temp,
		InstanceCount = 2,
		Priority = 230,
		PlatoonType = 'Land',
		RequiresConstruction = true,
		LocationType = 'Seraphim_North_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'South_Land_Attack_Chain_R1', 'South_Land_Attack_Chain_R2'}
		},
	}
	ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
	
	local Temp = {
		'Seraphim_North_Base_M4_Land_Attack_Template_3',
		'NoPlan',
		{ 'xsl0307', 1, (4+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   # T3 Shield Generator
		{ 'dslk004', 1, (4+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   # T3 Lightning Tank
		{ 'xsl0303', 1, (10+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },  # T3 Seige Tank
	}
	local Builder = {
		BuilderName = 'Seraphim_North_Base_M4_Land_Attack_Builder_3',
		PlatoonTemplate = Temp,
		InstanceCount = 4,
		Priority = 240,
		PlatoonType = 'Land',
		RequiresConstruction = true,
		LocationType = 'Seraphim_North_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'South_Land_Attack_Chain_R1', 'South_Land_Attack_Chain_R2'}
		},
	}
	ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

	local Temp = {
		'Seraphim_North_Base_M4_Land_Attack_Template_4',
		'NoPlan',
		{ 'xsl0304', 1, (6+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },  # T3 Mobile Arty
	}
	local Builder = {
		BuilderName = 'Seraphim_North_Base_M4_Land_Attack_Builder_4',
		PlatoonTemplate = Temp,
		InstanceCount = 4,
		Priority = 210,
		PlatoonType = 'Land',
		RequiresConstruction = true,
		LocationType = 'Seraphim_North_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'South_Land_Attack_Chain_R1', 'South_Land_Attack_Chain_R2'}
		},
	}
	ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )	
	
	local Temp = {
		'Seraphim_North_Base_M4_Land_Attack_Template_2',
		'NoPlan',
		{ 'xsl0307', 1, (4+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   # T3 Shield Generator
		{ 'xsl0205', 1, (4+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   # T2 AA		
		{ 'dslk004', 1, (4+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   # T3 Lightning Tank
		{ 'xsl0303', 1, (2+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   # T3 Seige Tank
		{ 'xsl0305', 1, (6+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   # T3 Sniper Bot
	}
	local Builder = {
		BuilderName = 'Seraphim_North_Base_M4_Land_Attack_Builder_2',
		PlatoonTemplate = Temp,
		InstanceCount = 2,
		Priority = 220,
		PlatoonType = 'Land',
		RequiresConstruction = true,
		LocationType = 'Seraphim_North_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'South_Land_Attack_Chain_R1', 'South_Land_Attack_Chain_R2'}
		},
	}
	ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
end

function Seraphim_North_Base_Ythotha(PlayerCount)
    local opai = nil
    local quantity = {}

    -- Ythotha Attack
    opai = Seraphim_North_Base:AddOpAI('Seraphim_M4_Ythotha_2',
        {
            Amount = (2+PlayerCount/2)*UnitModifier[Difficulty],
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'South_Land_Attack_Chain_R1', 'South_Land_Attack_Chain_R2'},
            },
            MaxAssist = 2*UnitModifier[Difficulty],
            Retry = true,
        }
    )
end

function DisableBase()
    if(Seraphim_North_Base) then
        Seraphim_North_Base:BaseActive(false)
        LOG('Seraphim_North_Base Disabled')
    end
end