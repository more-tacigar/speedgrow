------------------------------------------------------------
-- Copyright (c) 2016 tacigar
-- https://github.com/tacigar/speedgrow
------------------------------------------------------------

-- 自作MODのデバッグ時に植物を完全に成長させたい場面が多々あったので作成
-- 主にデバッグ用のMODです

local function split_plant_name(nodename)
	return string.match(nodename, "(.+)_(%d+)")
end

local function split_seed_plant_name(nodename)
	local pattern = "(.+):seed_(.+)"
	return string.match(nodename, pattern)
end

local function combine_plant_and_size(plantname, size)
	return plantname.."_"..tostring(size)
end

local tree_grow_flag = default.can_grow and default.grow_sapling

local plants = {}
minetest.after(0, function()
	for nodename, _ in pairs(minetest.registered_nodes) do
		if minetest.get_item_group(nodename, "plant") > 0 then
			local plantname, size = split_plant_name(nodename)
			if not plants[plantname] or plants[plantname] < size then
				plants[plantname] = size
			end
		end
	end
end)

minetest.register_craftitem("speedgrow:speedgrow", {
	description = "Speedgrow",
	inventory_image = "speedgrow.png",
	stack_max = 1,

	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.under == nil then return end
		local pos = pointed_thing.under
		local node = minetest.get_node(pos)
		if minetest.get_item_group(node.name, "plant") > 0 then
			local plantname, size = split_plant_name(node.name)
			local newsize = plants[plantname]
			local newnode_name = combine_plant_and_size(plantname, newsize)
			minetest.set_node(pos, {name = newnode_name})
		elseif minetest.get_item_group(node.name, "seed") > 0 then
			local modname, pn = split_seed_plant_name(node.name)
			local plantname = modname..":"..pn
			local size = plants[plantname]
			local newnode_name = combine_plant_and_size(plantname, size)
			minetest.set_node(pos, {name = newnode_name})
		elseif tree_grow_flag
			and minetest.get_item_group(node.name, "sapling") > 0 then
				if default.can_grow(pos) then
					default.grow_sapling(pos)
				end
			end
			return nil
		end,
	})
