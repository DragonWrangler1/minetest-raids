--since balrogs have 2400 hp and obsidian flans have 35 hp. The obsidian flan boss battle tries to have the total hp at 2400 or very close to it. So we know that we need approximately 69 obsidian flans spawned to have about equal hp of 1 balrog

-- Define the raid settings

local raid_settings = {
wave_interval = 30,         -- Time interval between waves in seconds
max_waves = math.random(2, 7),  -- Maximum number of waves
mobs_per_wave = {            -- Number of mobs spawned per wave, customizable per wave
	3,  -- Wave 1
        7, -- Wave 2
        9, -- Wave 3
        13, -- Wave 4
        20, -- Wave 5
        40, -- Wave 6
        69, -- Wave 7-- The Final wave and the deadliest
},

    spawn_radius = 20, -- Radius around player where mobs can spawn
    mob_types = {                -- Types of mobs to spawn, customizable per wave
        {"mobs_monster:stone_monster"},                        -- Wave 1
        {"mobs_monster:dungeon_master", "mobs_monster:land_guard"}, -- Wave 2
        {"mobs_monster:spider", "mobs_monster:spider", "mobs_monster:spider"},     -- Wave 3
        {"mobs_monster:stone_monster", "mobs_monster:stone_monster", "mobs_monster:obsidian_flan", "mobs_monster:obsidian_flan"}, -- Wave 4
        {"mobs_monster:obsidian_flan", "mobs_monster:land_guard", "mobs_monster:spider", "mobs_monster:obsidian_flan", "mobs_monster:dungeon_master"}, -- Wave 5
        {"mobs_monster:obsidian_flan", "mobs_monster:land_guard", "mobs_monster:obsidian_flan", "mobs_monster:obsidian_flan"}, -- Wave 6
        {"mobs_monster:obsidian_flan"}, -- Wave 7
    },
    --======================================================================================================================================--
    --===Reward and difficulty increase functions do not work properly and may cause the game to freeze, and or give unlimited rewards.  ===--
    --===Anyway since this is more multi player based, so the reward system is not needed                                                         ===--
    --======================================================================================================================================--
  --  difficulty_increase_interval = 300,  -- Interval for increasing difficulty (seconds)
 --   difficulty_scale = 0.1,       -- Difficulty scaling factor
    reward_items = {"default:diamond", "default:apple"}, -- Reward items given to players upon surviving the raid
    loot_table = {                -- Loot table, customizable per wave
        -- Wave 1
        {
	{"default:diamond", 0.1},
	{"default:apple", 0.5},
        },
        -- Wave 2
        {
	{"default:diamond", 0.2},
	{"default:apple", 0.6},
        },
        -- Wave 3
        {
	{"default:diamond", 0.3},
	{"default:apple", 0.7},
        },
        -- Wave 4
        {
	{"default:diamond", 0.4},
	{"default:apple", 0.8},
        },
        -- Wave 5
        {
	{"default:diamond", 0.5},
	{"default:apple", 0.9},
        },
        -- Wave 6
        {
	{"default:diamond", 0.6},
	{"default:gold_ingot", 0.9},
	},
    },
}

-- Track ongoing raid data
local raid_data = {}

-- Function to spawn a wave of mobs around a player
local function spawn_mob_wave(player, wave_number)
    local player_pos = player:get_pos()
    local mob_count = 0
    for i = 1, raid_settings.mobs_per_wave[wave_number] do
        local spawn_pos = {
	x = player_pos.x + math.random(-raid_settings.spawn_radius, raid_settings.spawn_radius),
	y = player_pos.y,
	z = player_pos.z + math.random(-raid_settings.spawn_radius, raid_settings.spawn_radius)
        }
        local mob_type = raid_settings.mob_types[wave_number][math.random(1, #raid_settings.mob_types[wave_number])]
        local mob_entity = minetest.add_entity(spawn_pos, mob_type)
     --   local luaentity = mob_entity:get_luaentity()
      --  luaentity.player_target = player
        mob_count = mob_count + 1
    end
    minetest.chat_send_player(player:get_player_name(), "Wave " .. wave_number .. " incoming!")
end

-- Function to initiate the mob raid event
local function start_mob_raid(player)
    local wave_number = 1
    local function spawn_next_wave()
        if wave_number <= raid_settings.max_waves and player and player:is_player() and player:get_hp() > 0 then
	spawn_mob_wave(player, wave_number)
	wave_number = wave_number + 1
	minetest.after(raid_settings.wave_interval, spawn_next_wave)
        end
    end
    spawn_next_wave()
end

if math.random (1, 1) == 1 then
	do start_mob_raid(player)
	end
end

--[[Function to increase raid difficulty over time
local function increase_difficulty()
    for i = 1, raid_settings.max_waves do
        raid_settings.mobs_per_wave[i] = raid_settings.mobs_per_wave[i] + math.floor(raid_settings.mobs_per_wave[i] * raid_settings.difficulty_scale)
    end
    minetest.after(raid_settings.difficulty_increase_interval, increase_difficulty)
end
]]
--[[ Function to reward players for surviving the raid
local function reward_players()

for player, _ in pairs(raid_data) do
        if player and player:is_player() then
           	local loot = {}

	for i = 1, raid_settings.max_waves do
                for _, item in ipairs(raid_settings.loot_table[i]) do
                    if math.random() < item[2] then

                        table.insert(loot, item[1])
				end
                	end

		end
            for _, item in ipairs(raid_settings.reward_items) do

                player:get_inventory():add_item("main", ItemStack(item))

	end

            for _, item in ipairs(loot) do

                player:get_inventory():add_item("main", ItemStack(item))

	end

            minetest.chat_send_player(player:get_player_name(), "You survived the raid and received a reward!")
		end
	end
end]]
local function reward_players()
end

minetest.register_privilege("event_manager", {
	description = "Used to Manage Events",
	give_to_singleplayer = false
})

-- Register a chat command to start the mob raid event
minetest.register_chatcommand("startraid", {
   	params = "",
    	description = "Starts a mob raid event",
    	privs = {event_manager = true},
    	func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if player then
	raid_data[player] = true
	start_mob_raid(player)
	return true, "Mob raid event started!"
        else
	return true, "Starting Mob Raid For Ingame Players"
        end
end,
})

-- Register globalstep to track raid data, increase difficulty, and reward players
minetest.register_globalstep(function(dtime)
-- increase_difficulty()
	minetest.after(raid_settings.wave_interval * raid_settings.max_waves, reward_players)
end)

--[[minetest.register_abm({
	nodenames = {"air"},  -- Example: trigger the raid when air is detected
	neighbors = {"air"},
	interval = 1,  -- Check every hour
	chance = 2,      -- 1 in 20 chance per check
	action = function(pos, node)
        local players = minetest.get_connected_players()
        if #players > 0 then

	local player = players[math.random(1, #players)]
	if not raid_data[player] then
		raid_data[player] = true
		start_mob_raid(player)

		end
		return true
	end
end,

})]]




