-- Copyright (c) 2014, Jeffrey Clark. This file is licensed under the
-- Affero General Public License version 3 or later. See the COPYRIGHT file.

EVENTS = {
	"ChestItemDrop",
	"ChestToInventory",
	"InventoryToChest",
	"ItemDrop",
	"NpcDeath",
	"NpcHit",
	"NpcSpawn",
	"PlayerBlockDestroy",
	"PlayerBlockPlace",
	"PlayerChangePosition",
	"PlayerChestDestroy",
	"PlayerChestPlace",
	"PlayerChestRemove",
	"PlayerCommand",
	"PlayerConnect",
	"PlayerConstructionDestroy",
	"PlayerConstructionPlace",
	"PlayerConstructionRemove",
	"PlayerConsumeItem",
	"PlayerDamage",
	"PlayerDeath",
	"PlayerDisconnect",
	"PlayerEnterChunk",
	"PlayerEnterWorldpart",
	"PlayerGrassRemove",
	"PlayerHit",
	"PlayerObjectDestroy",
	"PlayerObjectPickup",
	"PlayerObjectPlace",
	"PlayerObjectRemove",
	"PlayerObjectStatusChange",
	"PlayerPicking",
	"PlayerQuickslotChange",
	"PlayerRespawn",
	"PlayerSpawn",
	"PlayerTerrainDestroy",
	"PlayerTerrainFill",
	"PlayerText",
	"PlayerVegetationDestroy",
	"PlayerVegetationPickup",
	"PlayerVegetationPlace",
	"UpdateEvent",
}

ModManager = {
	hooks = {},
	commands = {},
	plugins = {},
	_eventProxy = {},

	init = function(self)
		self:log("init mod manager (does nothing yet)")
	end,

	list = function(self)
		for _,v in pairs(self.plugins) do
			self:log("%s %d", v.name, v.version)
		end
	end,

	register = function(self, plugin)
		for _,v in pairs(self.plugins) do
			if v == plugin then
				self:log("plugin already registered")
				return false
			end
		end
		if plugin:register(self) then
			self:log("register success")
			table.insert(self.plugins, plugin)
		end
	end,

	unregister = function(self, plugin)
		for k,v in pairs(self.plugins) do
			if v == plugin then
				if plugin:unregister(self) then
					table.remove(self.plugins, k)
					self:log("unregister success")
				end
				return true
			end
		end
		return false
	end,

	hook = function(self,params)
		if not in_array(EVENTS, params.event) then
			self:log("unknown event hook %s", params.event)
			return false
		end

		if not self.hooks[params.event] then
			-- FIXME: eventname deref
			local eventname = params.event
			self._eventProxy[eventname] = function(self,event) self.hookEvents(self, eventname, event) end
			self.hooks[params.event]={}

			if not addEvent(params.event, self._eventProxy[eventnamt]) then
				self:log("hook failed: %s", params.event)
				return false
			end
		end
		table.insert(self.hooks[params.event], params.callback)
		self:log("hooked: %s", params.event)
	end,

	unhook = function(self,params)
		if self.hooks[params.event] then
			for i = #self.hooks[params.event],1,-1 do
				if self.hooks[params.event][i] == params.callback then
					table.remove(self.hooks[params.event], i)
					self:log("unhooked: %s", params.event)
					break
				end
			end
		end
	end,

	hookEvents = function(self,name,event)
		self:log("handling event %s", name)
	end,

	log = function(self,...)
		local arg = table.pack(...)
		arg[1] = "ModManager: " .. arg[1]
		log(table.unpack(arg))
	end
}

ModBase = {
	new = function()
		local self = {
			-- local vars
			name = "Unknown",
			author = "Unknown",
			version = 0,
			events = {},
		}

		self.attach = function(self,modmanager)
			self:log('attach begin')
			local x = modmanager:register(self)
			self:log('attach end')
			return x
		end

		self.detach = function(self,modmanager)
			return modmanager:unregister(self)
		end

		self.register = function(self,modmanager)
			self:log('register begin')
			local x = true
			for k,v in pairs(self.events) do
				if not modmanager:hook{event=k,callback=v} then
					x = false
					break
				end
			end
			self:log('register end')
			return x
		end

		self.unregister = function(self,modmanager)
			self:log('unregister begin')
			for k,v in pairs(self.events) do
				modmanager:unhook{event=k,callback=v}
			end
			self:log('unregister end')
			return true
		end

		self.log = function(self,...)
			local arg = table.pack(...)
			arg[1] = self.name .. ": " .. arg[1]
			log(table.unpack(arg))
		end

		return self
	end,
}
