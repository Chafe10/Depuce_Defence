local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Buff = import('/lua/sim/Buff.lua')

local Seraphim_M4_South_West_Base = BaseManager.CreateBaseManager()
local Difficulty = ScenarioInfo.Options.Difficulty
local WaitForAttackSecondsMultiplier = {1.2,1,0.8}
local UnitModifier = {0.5,1,2}
local Seraphim = 3

function Seraphim_M4_South_West_BaseAI(PlayerCount)
    Seraphim_M4_South_West_Base:Initialize(ArmyBrains[Seraphim], 'Seraphim_M4_South_West_Base', 'Seraphim_M4_South_West_Base_Marker', 90, {Seraphim_M4_South_West_Base = 600})
    Seraphim_M4_South_West_Base:StartNonZeroBase({{5,6,10}, {3,4,6}})
    Seraphim_M4_South_West_Base:SetActive('AirScouting', false)
	Seraphim_M4_South_West_Base_Patrol(PlayerCount)
end

function Seraphim_M4_South_West_Base_Patrol(PlayerCount)
    local opai = nil
	local Temp = {
		'Seraphim_M4_Patrol_Template',
		'NoPlan',
		{ 'xsa0303', 1, (6+PlayerCount/2), 'Attack', 'GrowthFormation' },  # T3 ASF
	}
	local Builder = {
		BuilderName = 'Seraphim_M4_Patrol_Builder',
		PlatoonTemplate = Temp,
		InstanceCount = 2,
		Priority = 310,
		PlatoonType = 'Air',
		RequiresConstruction = true,
		LocationType = 'Seraphim_M4_South_West_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'Seraphim_M4_Patrol'}
		},
	}
	ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
end
	

function Seraphim_M4_South_West_Base_Land_Attacks(PlayerCount)
    local opai = nil
	local Temp = {
		'Seraphim_M4_South_West_Base_Land_Attack_Template_1',
		'NoPlan',
		{ 'xsl0307', 1, (4+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },  # T3 Shield Generator
		{ 'xsl0303', 1, (8+PlayerCount)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },  # T3 T3 Siege Tank
		{ 'dslk004', 1, (8+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },  # T3 Lightning Tank
		{ 'xsl0202', 1, (4+PlayerCount)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },  # T2 Assualt Bot
		
	}
	local Builder = {
		BuilderName = 'Seraphim_M4_South_West_Base_Land_Attack_Builder_1',
		PlatoonTemplate = Temp,
		InstanceCount = 3,
		Priority = 230,
		PlatoonType = 'Land',
		RequiresConstruction = true,
		LocationType = 'Seraphim_M4_South_West_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'Seraphim_M4_Land_Attack_Chain_1', 'Seraphim_M4_Land_Attack_Chain_2'}
		},
	}
	ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
	
	local Temp = {
		'Seraphim_M4_South_West_Base_Land_Attack_Template_2',
		'NoPlan',
		{ 'xsl0307', 1, (4+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   # T3 Shield Generator
		{ 'xsl0205', 1, (4+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   # T2 AA		
		{ 'dslk004', 1, (4+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   # T3 Lightning Tank
		{ 'xsl0303', 1, (2+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   # T3 Seige Tank
		{ 'xsl0305', 1, (6+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   # T3 Sniper Bot
	}
	local Builder = {
		BuilderName = 'Seraphim_M4_South_West_Base_Land_Attack_Builder_2',
		PlatoonTemplate = Temp,
		InstanceCount = 2,
		Priority = 220,
		PlatoonType = 'Land',
		RequiresConstruction = true,
		LocationType = 'Seraphim_M4_South_West_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'Seraphim_M4_Land_Attack_Chain_1', 'Seraphim_M4_Land_Attack_Chain_2'}
		},
	}
	ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
end

function Seraphim_M4_South_West_Base_Air_Attacks(PlayerCount)
	Seraphim_M4_South_West_Base:SetActive('AirScouting', true)
	local opai = nil
	local Temp = {
		'Seraphim_M4_South_West_Base_Air_Attack_Template_1',
		'NoPlan',
		{ 'xsa0203', 1, (12+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   # T2 Gunship
	}
	local Builder = {
		BuilderName = 'Seraphim_M4_South_West_Base_Air_Attack_Builder_1',
		PlatoonTemplate = Temp,
		InstanceCount = 3,
		Priority = 120,
		PlatoonType = 'Air',
		RequiresConstruction = true,
		LocationType = 'Seraphim_M4_South_West_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'Seraphim_M4_Air_Attack_Chain_1', 'Seraphim_M4_Air_Attack_Chain_2'}
		},
	}
	ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
	
	local Temp = {
		'Seraphim_M4_South_West_Base_Air_Attack_Template_2',
		'NoPlan',
		{ 'xsa0303', 1, (8+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   # T3 Fighter
		{ 'xsa0304', 1, (10+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   # T3 Bombers
	}
	local Builder = {
		BuilderName = 'Seraphim_M4_South_West_Base_Air_Attack_Builder_2',
		PlatoonTemplate = Temp,
		InstanceCount = 3,
		Priority = 110,
		PlatoonType = 'Air',
		RequiresConstruction = true,
		LocationType = 'Seraphim_M4_South_West_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'Seraphim_M4_Air_Attack_Chain_1', 'Seraphim_M4_Air_Attack_Chain_2'}
		},
	}
	ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
	
end

function Seraphim_M4_Ythotha(PlayerCount)
    local opai = nil
    local quantity = {}

    -- Ythotha Defence
    opai = Seraphim_M4_South_West_Base:AddOpAI('Seraphim_M4_Ythotha_1',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'Seraphim_M4_Ythotha_Defence_1',
            },
            MaxAssist = 2*UnitModifier[Difficulty],
            Retry = true,
        }
    )
	
    opai = Seraphim_M4_South_West_Base:AddOpAI('Seraphim_M4_Ythotha_1',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'Seraphim_M4_Ythotha_Defence_2',
            },
            MaxAssist = 2*UnitModifier[Difficulty],
            Retry = true,
        }
    )
    -- Ythotha Attack
    opai = Seraphim_M4_South_West_Base:AddOpAI('Seraphim_M4_Ythotha_1',
        {
            Amount = (2+PlayerCount/2)*UnitModifier[Difficulty],
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Seraphim_M4_Land_Attack_Chain_1', 'Seraphim_M4_Land_Attack_Chain_2'},
            },
            MaxAssist = 2*UnitModifier[Difficulty],
            Retry = true,
        }
    )
end

function Seraphim_M4_Ahwassa(PlayerCount)
    local opai = nil
    local quantity = {}

	-- Ahwassa Attack
    opai = Seraphim_M4_South_West_Base:AddOpAI('Seraphim_M4_Ahwassa',
        {
            Amount = (2+PlayerCount/4)*UnitModifier[Difficulty],
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Seraphim_M4_Air_Attack_Chain_1', 'Seraphim_M4_Air_Attack_Chain_2'},
            },
            MaxAssist = 2*UnitModifier[Difficulty],
            Retry = true,
        }
    )
end

function DisableBase()
    if(Seraphim_M4_South_West_Base) then
        Seraphim_M4_South_West_Base:BaseActive(false)
        LOG('Seraphim_M4_South_West_Base Disabled')
    end
    for _, platoon in ArmyBrains[Seraphim]:GetPlatoonsList() do
        platoon:Stop()
        ArmyBrains[Seraphim]:DisbandPlatoon(platoon)
    end
    LOG('All Seraphim Platoons stopped')
end