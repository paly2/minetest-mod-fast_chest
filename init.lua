local USES = 100

local function chest_input(user, pos)
	local meta = minetest.get_meta(pos)
	local chestinv = meta:get_inventory()
	local userinv = user:get_inventory()
	
	for i, userstack in ipairs(userinv:get_list("main")) do
		if not userstack:is_empty() and userstack:get_name() ~= "fast_chest:chest_stick" then
			for index, cheststack in ipairs(chestinv:get_list("main")) do
				if cheststack:is_empty() then
					cheststack = userstack
					chestinv:set_stack("main", index, ItemStack(cheststack))
					userstack:clear()
					break
				end
			end
			if not userstack:is_empty() then -- If the stack has not be clear
				break
			end
		end
		userinv:set_stack("main", i, userstack)
	end
end

local function chest_output(user, pos)
	local meta = minetest.get_meta(pos)
	local chestinv = meta:get_inventory()
	local userinv = user:get_inventory()
	
	for i, cheststack in ipairs(chestinv:get_list("main")) do
		if not cheststack:is_empty() and cheststack:get_name() ~= "fast_chest:chest_stick" then
			for index, userstack in ipairs(userinv:get_list("main")) do
				if userstack:is_empty() then
					userstack = cheststack
					userinv:set_stack("main", index, ItemStack(userstack))
					cheststack:clear()
					break
				end
			end
			if not cheststack:is_empty() then -- If the stack has not be clear
				break
			end
		end
		chestinv:set_stack("main", i, cheststack)
	end
end


-- Stick registration
minetest.register_tool("fast_chest:chest_stick", {
	description = "Chest Stick (left-click input, SNEAK + right-click output)",
	inventory_image = "chest_stick.png",
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type == "node" then
			local node = minetest.get_node(pointed_thing.under)
			if node.name == "default:chest" or (node.name == "default:chest_locked" and minetest.get_meta(pointed_thing.under):get_string("owner") == user:get_player_name()) then
				chest_input(user, pointed_thing.under)
			end
		end
		if not minetest.setting_getbool("creative_mode") then
			itemstack:add_wear(65535 / (USES - 1))
		end
		return itemstack
	end,
	on_place = function(itemstack, user, pointed_thing)
		if pointed_thing.type == "node" then
			local node = minetest.get_node(pointed_thing.under)
			if node.name == "default:chest" or (node.name == "default:chest_locked" and minetest.get_meta(pointed_thing.under):get_string("owner") == user:get_player_name()) then
				chest_output(user, pointed_thing.under)
			end
		end
		if not minetest.setting_getbool("creative_mode") then
			itemstack:add_wear(65535 / (USES - 1))
		end
		return itemstack
	end,
})


-- Craft
minetest.register_craft({
	output = "fast_chest:chest_stick",
	recipe = {{"default:stick", "default:gold_ingot", "default:stick"}},
})
