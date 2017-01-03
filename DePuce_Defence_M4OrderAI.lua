local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Buff = import('/lua/sim/Buff.lua')

local Order_M4_South_East_Base = BaseManager.CreateBaseManager()
local Difficulty = ScenarioInfo.Options.Difficulty
local WaitForAttackSecondsMultiplier = {1.2,1,0.8}
local UnitModifier = {0.5,1,2}
local Order = 2

function Order_M4_South_East_BaseAI(PlayerCount)
    Order_M4_South_East_Base:Initialize(ArmyBrains[Order], 'Order_M4_South_East_Base', 'Order_M4_South_East_Base_Marker', 90, {Order_M4_South_East_Base = 600})
    Order_M4_South_East_Base:StartNonZeroBase({{10,16,24}, {6,10,16}})
	Order_M4_South_East_Base_Patrol(PlayerCount)
    end

function Order_M4_South_East_Base_Patrol(PlayerCount)
    local opai = nil
	local Temp = {
		'Order_M4_Patrol_Builder_1',
		'NoPlan',
		{ 'uaa0303', 1, (6+PlayerCount/2), 'Attack', 'GrowthFormation' },   # T3 Air Superiority Fighter
		
	}
	local Builder = {
		BuilderName = 'Order_M4_Patrol_Builder_1',
		PlatoonTemplate = Temp,
		InstanceCount = 2,
		Priority = 320,
		PlatoonType = 'Air',
		RequiresConstruction = true,
		LocationType = 'Order_M4_South_East_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
		PlatoonData = {
			PatrolChains = {'Order_M4_Patrol'}
		},
	}
	ArmyBrains[Order]:PBMAddPlatoon( Builder )
	
	local Temp = {
		'Order_M4_Patrol_Template_2',
		'NoPlan',
		{ 'xaa0305', 1, (6+PlayerCount/2), 'Attack', 'GrowthFormation' },   # T3 AA Gunship
		
	}
	local Builder = {
		BuilderName = 'Order_M4_Patrol_Builder_2',
		PlatoonTemplate = Temp,
		InstanceCount = 2,
		Priority = 310,
		PlatoonType = 'Air',
		RequiresConstruction = true,
		LocationType = 'Order_M4_South_East_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'Order_M4_Patrol'}
		},
	}
	ArmyBrains[Order]:PBMAddPlatoon( Builder )
end	
	
function Order_M4_South_East_Base_Air_Attacks(PlayerCount)
    Order_M4_South_East_Base:SetActive('AirScouting', true)
    local opai = nil
	local Temp = {
		'Order_M4_Air_Attack_Template_1',
		'NoPlan',
		{ 'uaa0203', 1, (10+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   # T2 Gunship
		{ 'xaa0305', 1, (8+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   # T3 Gunship
	}
	local Builder = {
		BuilderName = 'Order_M4_Air_Attack_Builder_1',
		PlatoonTemplate = Temp,
		InstanceCount = 2,
		Priority = 140,
		PlatoonType = 'Air',
		RequiresConstruction = true,
		LocationType = 'Order_M4_South_East_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'Order_M4_Air_Attack_Chain_1', 'Order_M4_Air_Attack_Chain_2', 'Order_M4_Air_Attack_Chain_3'}
		},
	}
	ArmyBrains[Order]:PBMAddPlatoon( Builder )
	
	local Temp = {
		'Order_M4_Air_Attack_Template_2',
		'NoPlan',
		{ 'uaa0304', 1, (8+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   # T3 Bomber
	}
	local Builder = {
		BuilderName = 'Order_M4_Air_Attack_Builder_2',
		PlatoonTemplate = Temp,
		InstanceCount = 2,
		Priority = 110,
		PlatoonType = 'Air',
		RequiresConstruction = true,
		LocationType = 'Order_M4_South_East_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'Order_M4_Air_Attack_Chain_1', 'Order_M4_Air_Attack_Chain_2', 'Order_M4_Air_Attack_Chain_3'}
		},
	}
	ArmyBrains[Order]:PBMAddPlatoon( Builder )

		local Temp = {
		'Order_M4_Air_Attack_Template_3',
		'NoPlan',
		{ 'uaa0303', 1, (8+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   # T3 Fighter
		{ 'uaa0304', 1, (6+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   # T3 Bomber
	}
	local Builder = {
		BuilderName = 'Order_M4_Air_Attack_Builder_3',
		PlatoonTemplate = Temp,
		InstanceCount = 2,
		Priority = 120,
		PlatoonType = 'Air',
		RequiresConstruction = true,
		LocationType = 'Order_M4_South_East_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'Order_M4_Air_Attack_Chain_1', 'Order_M4_Air_Attack_Chain_2', 'Order_M4_Air_Attack_Chain_3'}
		},
	}
	ArmyBrains[Order]:PBMAddPlatoon( Builder )
end

function Order_M4_South_East_Base_Land_Attacks(PlayerCount)
    local opai = nil
	local Temp = {
		'Order_M4_Land_Attack_Template_1',
		'NoPlan',
		{ 'ual0307', 1, (4+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },  # T2 Shield Generator
		{ 'ual0303', 1, (8+PlayerCount)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },  # T3 Attack Bot
		{ 'dalk003', 1, (6+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },  # T3 AA
		{ 'ual0205', 1, (2+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },  # T2 AA
		{ 'ual0202', 1, (4+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },  # T2 Heavy Tank
		
	}
	local Builder = {
		BuilderName = 'Order_M4_Land_Attack_Builder_1',
		PlatoonTemplate = Temp,
		InstanceCount = 2,
		Priority = 120,
		PlatoonType = 'Land',
		RequiresConstruction = true,
		LocationType = 'Order_M4_South_East_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'Order_M4_Land_Attack_Chain_1', 'Order_M4_Land_Attack_Chain_2'}
		},
	}
	ArmyBrains[Order]:PBMAddPlatoon( Builder )

	local Temp = {
		'Order_M4_Land_Attack_Template_2',
		'NoPlan',
		{ 'ual0307', 1, (4+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },  # T2 Shield Generator
		{ 'ual0303', 1, (6+PlayerCount)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },  # T3 Sniper Bot
		{ 'ual0304', 1, (6+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },  # T3 Shield Disrupter
		{ 'dalk003', 1, (4+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },  # T3 AA
		{ 'ual0205', 1, (2+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },  # T2 AA
		
	}
	local Builder = {
		BuilderName = 'Order_M4_Land_Attack_Builder_2',
		PlatoonTemplate = Temp,
		InstanceCount = 2,
		Priority = 120,
		PlatoonType = 'Land',
		RequiresConstruction = true,
		LocationType = 'Order_M4_South_East_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'Order_M4_Land_Attack_Chain_1', 'Order_M4_Land_Attack_Chain_2'}
		},
	}
	ArmyBrains[Order]:PBMAddPlatoon( Builder )
end

function Order_M4_Galactic_Colossus()
    local opai = nil
    local quantity = {}

    -- Galactic Colossus Defence
    opai = Order_M4_South_East_Base:AddOpAI('Order_M4_Galactic_Colossus_1',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'Order_M4_Galactic_Colossus_Defence_1',
            },
            MaxAssist = 2*UnitModifier[Difficulty],
            Retry = true,
        }
    )

    opai = Order_M4_South_East_Base:AddOpAI('Order_M4_Galactic_Colossus_1',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'Order_M4_Galactic_Colossus_Defence_2',
            },
            MaxAssist = 2*UnitModifier[Difficulty],
            Retry = true,
        }
    )
end

function Order_M4_CZAR(PlayerCount)
    local opai = nil
    local quantity = {}

	-- CZAR Attack
    opai = Order_M4_South_East_Base:AddOpAI('Order_M4_CZAR',
        {
            Amount = (2+PlayerCount/2)*UnitModifier[Difficulty],
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M4_Air_Attack_Chain_1', 'Order_M4_Air_Attack_Chain_2', 'Order_M4_Air_Attack_Chain_3'},
            },
            MaxAssist = 2*UnitModifier[Difficulty],
            Retry = true,
        }
    )
end

function DisableBase()
    if(Order_M4_South_East_Base) then
        Order_M4_South_East_Base:BaseActive(false)
        LOG('Order_M4_South_East_Base Disabled')
    end
    for _, platoon in ArmyBrains[Order]:GetPlatoonsList() do
        platoon:Stop()
        ArmyBrains[Order]:DisbandPlatoon(platoon)
    end
    LOG('All Order Platoons stopped')
end