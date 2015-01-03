-- Copyright (c) 2014, Jeffrey Clark. This file is licensed under the
-- Affero General Public License version 3 or later. See the COPYRIGHT file.

modWelcomeMessage = {
	new = function()
		self = ModBase.new()
		self.name = "Welcome Message"
		self.author = "h0tw1r3"
		self.version = 0.1

		self.restart = os.time()

		self.events = {
			PlayerSpawn = function(event)
				event.player:sendTextMessage(string.format("[#00FFCC]Welcome to the server %s! Last restart was %s.", event.player:getPlayerName(), os.date("%x %X", self.restart)))
			end
		}

		return self
	end
}
