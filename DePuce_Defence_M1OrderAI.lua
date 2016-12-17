local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Buff = import('/lua/sim/Buff.lua')

local Order_M1_South_Base = BaseManager.CreateBaseManager()
local Difficulty = ScenarioInfo.Options.Difficulty
local WaitForAttackSecondsMultiplier = {1.2,1,0.8}
local UnitModifier = {0.5,1,2}
local Order = 2

function Order_M1_South_BaseAI(PlayerCount)
    Order_M1_South_Base:Initialize(ArmyBrains[Order], 'Order_M1_South_Base', 'Order_M1_South_Base_Marker', 40, {Order_M1_South_Base = 600})
    Order_M1_South_Base:StartNonZeroBase({{5,6,10}, {3,4,6}})
    Order_M1_South_Base:SetActive('AirScouting', true)
    Order_M1_South_Base:SetActive('LandScouting', false)
    Order_M1_South_BaseLandPatrols(PlayerCount)
    ForkThread(function()
		WaitSeconds(200*WaitForAttackSecondsMultiplier[Difficulty])
		Order_M1_South_BaseLandAttacksT1(PlayerCount)
		WaitSeconds(240*WaitForAttackSecondsMultiplier[Difficulty])
		Order_M1_South_BaseAirAttacksT1(PlayerCount)
		WaitSeconds(300*WaitForAttackSecondsMultiplier[Difficulty])
		Order_M1_South_BaseLandAttacksT2(PlayerCount)
		Order_M1_South_BaseAirAttacksT2(PlayerCount)
		WaitSeconds(700*WaitForAttackSecondsMultiplier[Difficulty])
		Order_M1_South_BaseLandAttacksT3(PlayerCount)
		WaitSeconds(180*WaitForAttackSecondsMultiplier[Difficulty])
		Order_M1_South_BaseAirAttacksT3(PlayerCount)
    end)
end

function Order_M1_South_BaseLandPatrols(PlayerCount)
	local Temp = {
		'T2LandPatrolTemplate1',
		'NoPlan',
		{ 'ual0202', 1, (8+PlayerCount/2), 'Attack', 'GrowthFormation' },   -- Heavy Tank
		{ 'ual0205', 1, (4+PlayerCount/2), 'Attack', 'GrowthFormation' },   -- Flak AA
		{ 'ual0307', 1, (4+PlayerCount/2), 'Attack', 'GrowthFormation' },   -- Mobile Sheild
	}
	local Builder = {
		BuilderName = 'T2LandPatrolBuilder1',
		PlatoonTemplate = Temp,
		InstanceCount = 1,
		Priority = 400,
		PlatoonType = 'Land',
		RequiresConstruction = true,
		LocationType = 'Order_M1_South_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'Order_M1_South_Base_Patrol'}
		},
	}
	ArmyBrains[Order]:PBMAddPlatoon( Builder )
end
	
function Order_M1_South_BaseLandAttacksT1(PlayerCount)
	--Order O1 T1 Land AI attacks
    local opai = nil
	local Temp = {
		'T1LandAttackTemplate3',
		'NoPlan',
		{ 'ual0106', 1, (10+PlayerCount)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },  -- Light Attack Bot
	}
	local Builder = {
		BuilderName = 'T1LandAttackBuilder3',
		PlatoonTemplate = Temp,
		InstanceCount = 2,
		Priority = 120,
		PlatoonType = 'Land',
		RequiresConstruction = true,
		LocationType = 'Order_M1_South_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'Order_M1_South_Base_Chain2', 'Order_M1_South_Base_Chain1'}
		},
	}
	ArmyBrains[Order]:PBMAddPlatoon( Builder )
	
	local Temp = {
		'T1LandAttackTemplate1',
		'NoPlan',
		{ 'ual0201', 1, (6+PlayerCount)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   -- Light Tank
		{ 'ual0106', 1, (8+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },  -- Light Attack Bot
	}
	local Builder = {
		BuilderName = 'T1LandAttackBuilder1',
		PlatoonTemplate = Temp,
		InstanceCount = 1,
		Priority = 110,
		PlatoonType = 'Land',
		RequiresConstruction = true,
		LocationType = 'Order_M1_South_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'Order_M1_South_Base_Chain2', 'Order_M1_South_Base_Chain1'}
		},
	}
	ArmyBrains[Order]:PBMAddPlatoon( Builder )
	
	local Temp = {
		'T1LandAttackTemplate2',
		'NoPlan',
		{ 'ual0103', 1, (8+PlayerCount)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   -- Light Arty
		{ 'ual0106', 1, (2+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   -- Light Attack Bot
	}
	local Builder = {
		BuilderName = 'T1LandAttackBuilder2',
		PlatoonTemplate = Temp,
		InstanceCount = 1,
		Priority = 100,
		PlatoonType = 'Land',
		RequiresConstruction = true,
		LocationType = 'Order_M1_South_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'Order_M1_South_Base_Chain2', 'Order_M1_South_Base_Chain1'}
		},
	}
	ArmyBrains[Order]:PBMAddPlatoon( Builder )
end

function Order_M1_South_BaseLandAttacksT2(PlayerCount)
	--Order O1 T2 Land AI attacks
    local opai = nil
	
	local Temp = {
		'T2LandAttackTemplate3',
		'NoPlan',
		{ 'ual0202', 1, (6+PlayerCount)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   -- Heavy Tank
	}
	local Builder = {
		BuilderName = 'T2LandAttackBuilder3',
		PlatoonTemplate = Temp,
		InstanceCount = 1,
		Priority = 230,
		PlatoonType = 'Land',
		RequiresConstruction = true,
		LocationType = 'Order_M1_South_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'Order_M1_South_Base_Chain2', 'Order_M1_South_Base_Chain1'}
		},
	}
	ArmyBrains[Order]:PBMAddPlatoon( Builder )
	
	local Temp = {
		'T2LandAttackTemplate1',
		'NoPlan',
		{ 'ual0202', 1, (8+PlayerCount)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   -- Heavy Tank
		{ 'ual0205', 1, (2+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   -- Flak
		{ 'xal0203', 1, (4+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   -- Med Tank
	}
	local Builder = {
		BuilderName = 'T2LandAttackBuilder1',
		PlatoonTemplate = Temp,
		InstanceCount = 1,
		Priority = 220,
		PlatoonType = 'Land',
		RequiresConstruction = true,
		LocationType = 'Order_M1_South_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'Order_M1_South_Base_Chain2', 'Order_M1_South_Base_Chain1'}
		},
	}
	ArmyBrains[Order]:PBMAddPlatoon( Builder )
	
	local Temp = {
		'T2LandAttackTemplate2',
		'NoPlan',
		{ 'ual0111', 1, (6+PlayerCount)*UnitModifier[Difficulty], 'Artillery', 'GrowthFormation' },  -- Mobile Missile Launcher
		{ 'ual0205', 1, (2+PlayerCount/2)*UnitModifier[Difficulty], 'Artillery', 'GrowthFormation' },   -- Flak
	}
	local Builder = {
		BuilderName = 'T2LandAttackBuilder2',
		PlatoonTemplate = Temp,
		InstanceCount = 2,
		Priority = 210,
		PlatoonType = 'Land',
		RequiresConstruction = true,
		LocationType = 'Order_M1_South_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'Order_M1_South_Base_Chain2', 'Order_M1_South_Base_Chain1'}
		},
	}
	ArmyBrains[Order]:PBMAddPlatoon( Builder )
	
end

function Order_M1_South_BaseLandAttacksT3(PlayerCount)
	--Order O1 T3 Land AI attacks
    local opai = nil
	
	local Temp = {
		'T3LandAttackTemplate1',
		'NoPlan',
		{ 'ual0304', 1, (6+PlayerCount/2)*UnitModifier[Difficulty], 'Artillery', 'GrowthFormation' },   -- T3 Mobile Arty
		
	}
	local Builder = {
		BuilderName = 'T3LandAttackBuilder1',
		PlatoonTemplate = Temp,
		InstanceCount = 1,
		Priority = 310,
		PlatoonType = 'Land',
		RequiresConstruction = true,
		LocationType = 'Order_M1_South_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'Order_M1_South_Base_Chain2', 'Order_M1_South_Base_Chain1'}
		},
	}
	ArmyBrains[Order]:PBMAddPlatoon( Builder )
	
	local Temp = {
		'T3LandAttackTemplate2',
		'NoPlan',
		{ 'dal0310', 1, (2+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'AttackFormation' },   -- T3 Shield Disrupter
	}
	local Builder = {
		BuilderName = 'T3LandAttackBuilder2',
		PlatoonTemplate = Temp,
		InstanceCount = 2,
		Priority = 320,
		PlatoonType = 'Land',
		RequiresConstruction = true,
		LocationType = 'Order_M1_South_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'Order_M1_South_Base_Chain2', 'Order_M1_South_Base_Chain1'}
		},
	}
	ArmyBrains[Order]:PBMAddPlatoon( Builder )
	
	local Temp = {
		'T3LandAttackTemplate3',
		'NoPlan',
		{ 'xal0305', 1, (4+PlayerCount)*UnitModifier[Difficulty], 'Attack', 'AttackFormation' },   -- T3 Sniper Bot
	}
	local Builder = {
		BuilderName = 'T3LandAttackBuilder3',
		PlatoonTemplate = Temp,
		InstanceCount = 1,
		Priority = 330,
		PlatoonType = 'Land',
		RequiresConstruction = true,
		LocationType = 'Order_M1_South_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'Order_M1_South_Base_Chain2', 'Order_M1_South_Base_Chain1'}
		},
	}
	ArmyBrains[Order]:PBMAddPlatoon( Builder )
	
	local Temp = {
		'T3LandAttackTemplate4',
		'NoPlan',
		{ 'ual0303', 1, (4+PlayerCount)*UnitModifier[Difficulty], 'Attack', 'AttackFormation' },   -- T3 Assault Bot
	}
	local Builder = {
		BuilderName = 'T3LandAttackBuilder4',
		PlatoonTemplate = Temp,
		InstanceCount = 3,
		Priority = 340,
		PlatoonType = 'Land',
		RequiresConstruction = true,
		LocationType = 'Order_M1_South_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'Order_M1_South_Base_Chain2', 'Order_M1_South_Base_Chain1'}
		},
	}
	ArmyBrains[Order]:PBMAddPlatoon( Builder )
end

function Order_M1_South_BaseAirAttacksT1(PlayerCount)
	--Order O1 T1 Land AI attacks
    local opai = nil
	
	local Temp = {
		'T1AirAttackTemplate1',
		'NoPlan',
		{ 'uaa0103', 1, (4+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   -- T1 Bombers
	}
	local Builder = {
		BuilderName = 'T1AirAttackBuilder1',
		PlatoonTemplate = Temp,
		InstanceCount = 3,
		Priority = 110,
		PlatoonType = 'Air',
		RequiresConstruction = true,
		LocationType = 'Order_M1_South_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'Order_M1_South_Base_Chain_Air_1', 'Order_M1_South_Base_Chain_Air_2', 'Order_M1_South_Base_Chain_Air_3'}
		},
	}
	ArmyBrains[Order]:PBMAddPlatoon( Builder )
end

function Order_M1_South_BaseAirAttacksT2(PlayerCount)
	--Order O1 T2 Land AI attacks
    local opai = nil
	
	local Temp = {
		'T2AirAttackTemplate1',
		'NoPlan',
		{ 'uaa0203', 1, (8+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   -- T2 Gunship
	}
	local Builder = {
		BuilderName = 'T2AirAttackBuilder1',
		PlatoonTemplate = Temp,
		InstanceCount = 2,
		Priority = 220,
		PlatoonType = 'Air',
		RequiresConstruction = true,
		LocationType = 'Order_M1_South_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'Order_M1_South_Base_Chain_Air_1', 'Order_M1_South_Base_Chain_Air_2', 'Order_M1_South_Base_Chain_Air_3'}
		},
	}
	ArmyBrains[Order]:PBMAddPlatoon( Builder )
	
	local Temp = {
		'T2AirAttackTemplate2',
		'NoPlan',
		{ 'xaa0202', 1, (6+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },  -- T2 Fighter
	}
	local Builder = {
		BuilderName = 'T2AirAttackBuilder2',
		PlatoonTemplate = Temp,
		InstanceCount = 2,
		Priority = 210,
		PlatoonType = 'Air',
		RequiresConstruction = true,
		LocationType = 'Order_M1_South_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'Order_M1_South_Base_Chain_Air_1', 'Order_M1_South_Base_Chain_Air_2', 'Order_M1_South_Base_Chain_Air_3'}
		},
	}
	ArmyBrains[Order]:PBMAddPlatoon( Builder )
end

function Order_M1_South_BaseAirAttacksT3(PlayerCount)
	--Order O1 T2 Land AI attacks
    local opai = nil
	
	local Temp = {
		'T3AirAttackTemplate1',
		'NoPlan',
		{ 'uaa0203', 1, (4+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   -- T2 Gunship
		{ 'xaa0305', 1, (6+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },   -- T3 Gunship
	}
	local Builder = {
		BuilderName = 'T3AirAttackBuilder1',
		PlatoonTemplate = Temp,
		InstanceCount = 2,
		Priority = 330,
		PlatoonType = 'Air',
		RequiresConstruction = true,
		LocationType = 'Order_M1_South_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'Order_M1_South_Base_Chain_Air_1', 'Order_M1_South_Base_Chain_Air_2', 'Order_M1_South_Base_Chain_Air_3'}
		},
	}
	ArmyBrains[Order]:PBMAddPlatoon( Builder )
	
	local Temp = {
		'T2AirAttackTemplate2',
		'NoPlan',
		{ 'uaa0303', 1, (6+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },  -- T3 Fighter
	}
	local Builder = {
		BuilderName = 'T3AirAttackBuilder2',
		PlatoonTemplate = Temp,
		InstanceCount = 1,
		Priority = 310,
		PlatoonType = 'Air',
		RequiresConstruction = true,
		LocationType = 'Order_M1_South_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'Order_M1_South_Base_Chain_Air_1', 'Order_M1_South_Base_Chain_Air_2', 'Order_M1_South_Base_Chain_Air_3'}
		},
	}
	ArmyBrains[Order]:PBMAddPlatoon( Builder )
	
	local Temp = {
		'T3AirAttackTemplate3',
		'NoPlan',
		{ 'uaa0304', 1, (4+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },  -- T3 Bomber
		{ 'uaa0303', 1, (2+PlayerCount/2)*UnitModifier[Difficulty], 'Attack', 'GrowthFormation' },  -- T3 Fighter
	}
	local Builder = {
		BuilderName = 'T3AirAttackBuilder3',
		PlatoonTemplate = Temp,
		InstanceCount = 3,
		Priority = 320,
		PlatoonType = 'Air',
		RequiresConstruction = true,
		LocationType = 'Order_M1_South_Base',
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
			PatrolChains = {'Order_M1_South_Base_Chain_Air_1', 'Order_M1_South_Base_Chain_Air_2', 'Order_M1_South_Base_Chain_Air_3'}
		},
	}
	ArmyBrains[Order]:PBMAddPlatoon( Builder )
end

function DisableBase()
    if(Order_M1_South_Base) then
        Order_M1_South_Base:BaseActive(false)
        LOG('Order_M1_South_Base Disabled')
    end
end