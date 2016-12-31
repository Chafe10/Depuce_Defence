version = 3
ScenarioInfo = {
    name = 'DePuce Defence BETA V4',
    description = 'Defend Commander DePuce from enemy forces and slaughter any foe that tries to attack him.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    size = {2048, 2048},
    map = '/maps/DePuce_Defence/DePuce_Defence.scmap',
    save = '/maps/DePuce_Defence/DePuce_Defence_save.lua',
    script = '/maps/DePuce_Defence/DePuce_Defence_script.lua',
    norushradius = 0.000000,
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'QAI','Order','Seraphim','Science_Facility_Equium','Science_Facility_Bulwark','DePuce','Player1','Player2','Player3','Player4','Player5','Player6',} },
            },
            customprops = {
            },
        },
    }}
