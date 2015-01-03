-- Copyright (c) 2014, Jeffrey Clark. This file is licensed under the
-- Affero General Public License version 3 or later. See the COPYRIGHT file.

TestMod = {
	new = function()
		self = ModBase.new()
		self.name = "Test"
		self.author = "h0tw1r3"
		self.version = 0.1

		self.events = {
			InventoryToChest = function(self, event)
				event:setCancel(true)
			end
		}
		return self
	end
}
