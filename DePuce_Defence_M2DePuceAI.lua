local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Buff = import('/lua/sim/Buff.lua')

local DePuce_Base = BaseManager.CreateBaseManager()
local Difficulty = ScenarioInfo.Options.Difficulty
local WaitForAttackSecondsMultiplier = {0.8,1,1.2}
local UnitModifier = {2,1,0.5}
local DePuce = 5

function DePuce_BaseAI()
    DePuce_Base:Initialize(ArmyBrains[DePuce], 'DePuce_Base', 'DePuce_Base_Marker', 150, {DePuce_Base = 30})
    DePuce_Base:StartNonZeroBase({{4,4,4}, {3,3,3}})
    DePuce_Base:SetActive('AirScouting', false)
end