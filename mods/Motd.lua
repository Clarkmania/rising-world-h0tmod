-- Copyright (c) 2014, Jeffrey Clark. This file is licensed under the
-- Affero General Public License version 3 or later. See the COPYRIGHT file.

modMotd = {
	new = function()
		self = ModBase.new()
		self.name = "Message of the day"
		self.author = "h0tw1r3"
		self.version = 0.1

		-- init stuff
		db:queryupdate("CREATE TABLE IF NOT EXISTS `motd` (`ID` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, `time` INTEGER, `message` VARCHAR);");

		self.broadcastMotd = function(self)
			server:brodcastTextMessage(self:prettyMotd())
		end

		self.prettyMotd = function(self, motd)
			if not motd then motd = self:getMotd() end
			return string.format("[#FFA500]** %s -- %s", motd.message, os.date("%x %X", motd.time))
		end

		self.getMotd = function(self)
			-- TODO: cache result
			local motd = { time = 0, message = "No message of the day" }
    			result = db:query("SELECT * FROM motd ORDER BY time DESC LIMIT 1;")
			if result:next() then
				motd.time = result:getInt("time")
				motd.message = result:getString("message")
			end
			result:close()

			return motd
		end

		self.commands['motd'] = {
			callback = function(event, command, action, message)
				if not action then
					event.player:sendTextMessage(self:prettyMotd())
				elseif action == "broadcast" then
					if ModManager:hasPermission(event.player, PERM_ADMIN) then
						self:broadcastMotd()
					end
				elseif action == "list" then
					-- TODO
					ModManager:sendPlayerCommandHelp(event.player, command, "list not implemented yet")
				elseif action == "set" and message then
					if ModManager:hasPermission(event.player, PERM_ADMIN) then
						db:queryupdate("INSERT INTO motd (time, message) VALUES (strftime('%s', 'now'), '" .. message .. "')")
						event.player:sendTextMessage("motd set")
					end
				else
					ModManager:sendPlayerCommandHelp(event.player, command, "Invalid command usage, see /help " .. command)
				end
				return CALLBACK_HANDLED
			end,
			help = {
				"set <message>",
				"broadcast => send motd to all players",
				"list      => show last 5 messages",
				"          => show motd",
			}
		}

		self.timers['Broadcast'] = {
			-- Broadcast motd every 60 minutes, forever
			frequency = 3600,
			count = -1,
			callback = function() self:broadcastMotd() end
		}

		self.events['PlayerSpawn'] = {
			callback = function(event)
				event.player:sendTextMessage(self:prettyMotd())
			end,
		}

		return self
	end
}
