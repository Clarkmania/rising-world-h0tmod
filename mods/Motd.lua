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
			local motd = self:getMotd()
			if motd.time > 0 then
				server:brodcastTextMessage("[#FFA500]** ".. motd.message)
			end
		end

		self.getMotd = function(self)
			local motd = { time = 0 }
    			result = db:query("SELECT * FROM motd ORDER BY time DESC LIMIT 1;")
			if result:next() then
				motd.time = result:getInt("time")
				motd.message = result:getString("message")
			end
			result:close()

			return motd
		end

		self.commands['setmotd'] = {
			callback = function(event, message, ...)
				db:queryupdate("INSERT INTO motd (time, message) VALUES (strftime('%s', 'now'), '" .. message .. "')")
				event.player:sendTextMessage("motd set")
			end,
			help = {
				"<message>"
			}
		}

		self.timers['motd'] = {
			-- Broadcast motd every 60 minutes, forever
			frequency = 3600,
			count = -1,
			callback = function() self:broadcastMotd() end
		}

		self.events['PlayerSpawn'] = {
			callback = function(event)
				local motd = self:getMotd()
				if motd.time > 0 then
					event.player:sendTextMessage("[#FFA500]** ".. motd.message)
				end
			end,
		}

		return self
	end
}
