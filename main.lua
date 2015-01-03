-- Copyright (c) 2014, Jeffrey Clark. This file is licensed under the
-- Affero General Public License version 3 or later. See the COPYRIGHT file.

include("support.lua")

include("modmanager.lua")

include("testmod.lua")

ModManager:init()
mod = TestMod.new()
mod:attach(ModManager)

-- invoked by java
function onEnable ()
	log("onEnable begin")
	ModManager:list()
	log("onEnable end")
end
