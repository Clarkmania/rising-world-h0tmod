-- Copyright (c) 2014, Jeffrey Clark. This file is licensed under the
-- Affero General Public License version 3 or later. See the COPYRIGHT file.

modController = {
	new = function()
		self = ModBase.new()
		self.name = "ModManager Controller"
		self.author = "h0tw1r3"
		self.version = 0.1

		self.commands['mod'] = {
			callback = function(event, command, action, optmod)
				if action == "list" or not action then
					for k,v in ipairs(ModManager.plugins) do
						event.player:sendTextMessage(string.format("#%d : %s v%f", k, v.name, v.version))
					end
				elseif action == "info" and optmod then
					optmod = tonumber(optmod)
					local mod = ModManager.plugins[optmod]
					if not mod then
						ModManager:sendPlayerCommandHelp(event.player, command, string.format("Mod id #%d not found", optmod))
					else
						event.player:sendTextMessage(string.format("Id:       %d", optmod))
						event.player:sendTextMessage(string.format("Name:     %s", mod.name))
						event.player:sendTextMessage(string.format("Version:  %f", mod.version))

						local command_names = get_keys(mod.commands)
						event.player:sendTextMessage(string.format("Commands: (%d) %s", #command_names, table.concat(command_names, ",")))

						local event_names = get_keys(mod.events)
						event.player:sendTextMessage(string.format("Events:   (%d) %s", #event_names, table.concat(event_names, ",")))

						event.player:sendTextMessage(string.format("Timers:   %d", sparse_count(mod.timers)))
					end
				else
					ModManager:sendPlayerCommandHelp(event.player, command, "Invalid command usage, see /help " .. command)
				end

				return CALLBACK_HANDLED
			end,
			help = {
				-- TODO: "disable <id#>",
				-- TODO: "enable <id#>",
				"info <id#>",
				"list"
			},
		}

		return self
	end
}
