-- split_plant_name splits a node name, like "farming:wheat_8"
-- to "farming:wheat" and "8".
local function split_plantname(nodename)
	return string.match(nodename, "(.+)_(%d+)")
end

-- get_plantname_from_seedname returns a full plantname (modname + plantname)
-- from a seed node name.
local function get_plantname_from_seedname(nodename)
	local modname, plantname = string.match(nodename, "(.+):seed_(.+)")
	if (not modname) or (not plantname) then
		return nil
	end
	return modname .. ":" .. plantname
end

-- plants_maxsize represents a table that contains base plant names
-- and its maximum size.
local plants_maxsize = {}

-- register plants_maxsize table.
minetest.after(0, function()
	for nodename, _ in pairs(minetest.registered_nodes) do
		if minetest.get_item_group(nodename, "plant") > 0 then
			local plantname, size = split_plantname(nodename)
			if (not plantname) or (not size) then
				break
			end

			if not plants_maxsize[plantname] or plants_maxsize[plantname] < size then
				plants_maxsize[plantname] = size
			end
		end
	end
end)

-- grow_up grows up a plant that exists at position pos.
local function grow_up(pos, plantname)
	local maxsize = plants_maxsize[plantname]
	local new_nodename = plantname .. "_" .. tostring(maxsize)

	minetest.set_node(pos, {name = new_nodename})
end

-- can_grow_tree represents whether trees can be grown by this mod.
local can_grow_tree =
	default.can_grow and default.grow_sapling

-- on_use is a callback that called when speedgrow is used.
local function on_use(itemstack, user, pointed_thing)
	if pointed_thing.under == nil then
		return nil
	end
	local position = pointed_thing.under
	local node = minetest.get_node(position)

	if minetest.get_item_group(node.name, "plant") > 0 then
		local plantname, size = split_plantname(node.name)
		if (not plantname) or (not size) then
			return nil
		end
		grow_up(position, plantname)

	elseif minetest.get_item_group(node.name, "seed") > 0 then
		local plantname = get_plantname_from_seedname(node.name)
		if not plantname then
			return nil
		end
		grow_up(position, plantname)

	elseif can_grow_tree and minetest.get_item_group(node.name, "sapling") > 0 then
		if default.can_grow(position) then
			default.grow_sapling(position)
		end
	end
	return nil
end

-- register a definition of speedgrow.
minetest.register_craftitem("speedgrow:speedgrow", {
	description      = "Speedgrow",
	inventory_image  = "speedgrow.png",
	wield_image      = "speedgrow.png",
	stack_max        = 1,
	groups           = {speedgrow = 1},
	on_use           = on_use,
})

-- register a craft of speedgrow.
minetest.register_craft{
	output = "speedgrow:speedgrow",
	recipe = {
		{"default:leaves", "default:leaves", "default:leaves"},
		{"default:leaves",   "default:tree", "default:leaves"},
		{              "",   "default:tree",               ""},
	},
}
