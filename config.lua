Config = {}

---------------------------------
-- shop settings
---------------------------------
Config = {
    BlackmarketShopItems = {
        { name = 'weapon_thrown_molotov', amount = 50, price = 5 },
    },
    PersistStock = true, --should stock save in database and load it after restart, to 'remember' stock value before restart
}

---------------------------------
-- settings
---------------------------------
Config.LawAlertActive = true
Config.LawAlertChance = 20 -- 20% chance of informing the law
Config.OutLawIncrease = 1 -- outlaw status increase for using blood money wash
Config.WashTime       = 1000 -- amount of time per 1 x bloodmoney
Config.MaxWash        = 50 -- maximum blood money to wash each time

---------------------------------
-- npc settings
---------------------------------
Config.DistanceSpawn = 20.0
Config.FadeIn = true

---------------------------------
-- npc locations
---------------------------------
Config.BlackmarketLocations = {
    {
        name = 'Theves Landing Blackmarket',
        prompt = 'blackmarket1',
        coords = vector3(-1396.49, -2291.90, 43.52),
        npcmodel = `mp_u_M_M_lom_rhd_smithassistant_01`,
        npccoords = vector4(-1396.49, -2291.90, 43.52, 310.10),
        showblip = true
    },
}
