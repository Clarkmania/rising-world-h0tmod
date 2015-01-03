-- Copyright (c) 2014, Jeffrey Clark. This file is licensed under the
-- Affero General Public License version 3 or later. See the COPYRIGHT file.

db = getDatabase()
server = getServer()

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
	plugins = {},
	_eventProxy = {},

	init = function(self)
		self:log("Init (does nothing yet)")
	end,

	list = function(self)
		for _,v in pairs(self.plugins) do
			self:log("%s version %f", v.name, v.version)
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
			self:dlog("register success")
			table.insert(self.plugins, plugin)
		end
	end,

	unregister = function(self, plugin)
		for k,v in pairs(self.plugins) do
			if v == plugin then
				if plugin:unregister(self) then
					table.remove(self.plugins, k)
					self:dlog("unregister success")
				end
				return true
			end
		end
		return false
	end,

	hook = function(self,params)
		if not in_array(EVENTS, params.event) then
			self:log("Unknown event hook %s", params.event)
			return false
		end

		if not self.hooks[params.event] then
			local eventname = params.event
			self._eventProxy[eventname] = function(event) ModManager:callEvents(eventname, event) end
			self.hooks[params.event]={}

			if not addEvent(params.event, self._eventProxy[eventname]) then
				self:log("hook failed: %s", params.event)
				return false
			end
		end
		table.insert(self.hooks[params.event], params.callback)
		self:dlog("hooked: %s", params.event)
		return true
	end,

	unhook = function(self,params)
		if self.hooks[params.event] then
			for i = #self.hooks[params.event],1,-1 do
				if self.hooks[params.event][i] == params.callback then
					table.remove(self.hooks[params.event], i)
					self:dlog("unhooked: %s", params.event)
					break
				end
			end
		end
	end,

	addTimer = function(self,name,timer)
		local x = setTimer(timer.callback, timer.frequency, timer.count)
		timer.id = x
		return true
	end,

	removeTimer = function(self,name,timer)
		return (killTimer(timer.id) == nil)
	end,

	callEvents = function(self,name,event)
		if type(self.hooks[name]) == "table" then
			-- parse the command
			local extra = {}
			if name == "PlayerCommand" then
				if string.sub(event.command,1,1) == "/" then
					extra = explode("%s+", event.command, 3)
					extra[1] = string.sub(string.lower(extra[1]), 2)
				end
			end
			for _,v in pairs(self.hooks[name]) do
				-- If callback successful, stop looping for more hooks
				-- NOTE: extra[1] or nil is a necessary luaj bug work-around
				if v.callback(event, table.unpack(extra)) then
					break
				end
			end
		end
	end,

	sendPlayerCommandHelp = function(self,player,name,text)
		if type(text) == "table" then
			for _,v in ipairs(text) do
				player:sendTextMessage("[#00C5C5]/" .. name .. " [#00B5B5]" .. v)
			end
		else
			player:sendTextMessage("[#00C5C5]/" .. name .. " [#00B5B5]" .. text)
		end
	end,

	sendPlayerCommandList = function(self,player,commandlist)
		for v,_ in pairs(commandlist) do
			if v ~= "help" then
				player:sendTextMessage("[#00C5C5]/" .. v)
			end
		end
	end,

	log = function(self,...)
		local arg = table.pack(...)
		arg[1] = "ModManager: " .. arg[1]
		log(table.unpack(arg))
	end,

	dlog = function(self,...)
		if _G['debugEnabled'] then
			self:log(...)
		end
	end
}

ModBase = {
	new = function()
		local self = {
			-- local vars
			name = "Unknown",
			author = "Unknown",
			version = 0,
			timers = {},
			manager = nil,
		}

		-- Default help command processor
		self.commands = {
			help = {
				callback = function(event, command, action, ...)
					if action then
						if self.commands[action] and self.commands[action]['help'] then
							ModManager:sendPlayerCommandHelp(event.player, action, self.commands[action].help)
							-- Tell ModManager the command request has been fulfilled
							return true
						end
					else
						ModManager:sendPlayerCommandList(event.player, self.commands)
					end
				end,
			},
		}

		-- Default event handler for help command
		self.events = {
			PlayerCommand = {
				callback = function(event, command, ...)
					if self.commands[command] and self.commands[command].callback then
						self.commands[command].callback(event, command, ...)
					end
				end,
			}
		}

		self.attach = function(self,modmanager)
			self:dlog('attach begin')
			local x = modmanager:register(self)
			self:dlog('attach end')
			if x then self.manager = modmanager end
			return x
		end

		self.detach = function(self,modmanager)
			local x = modmanager:unregister(self)
			if x then self.manager = nil end
			return x
		end

		self.register = function(self,modmanager)
			self:dlog('register begin')
			local x = true
			for k,v in pairs(self.events) do
				if not modmanager:hook{event=k,callback=v} then
					x = false
					break
				end
			end
			if x then
				for k,v in pairs(self.timers) do
					if not modmanager:addTimer(k, v) then
						-- FIXME: unhook also
						x = false
						break
					end
				end
			end
			self:dlog('register end')
			return x
		end

		self.unregister = function(self,modmanager)
			self:dlog('unregister begin')
			for k,v in pairs(self.events) do
				modmanager:unhook{event=k,callback=v}
			end
			for k,v in pairs(self.timers) do
				modmanager:removeTimer(k, v)
			end
			self:dlog('unregister end')
			return true
		end

		self.log = function(self,...)
			local arg = table.pack(...)
			arg[1] = self.name .. ": " .. arg[1]
			log(table.unpack(arg))
		end

		self.dlog = function(self,...)
			if _G['debugEnabled'] then
				self:log(...)
			end
		end

		return self
	end,
}
