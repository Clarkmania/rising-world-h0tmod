-- Copyright (c) 2014, Jeffrey Clark. This file is licensed under the
-- Affero General Public License version 3 or later. See the COPYRIGHT file.

include("support.lua")

include("modmanager.lua")

include("mods/WelcomeMessage.lua")

ModManager:init()
WelcomeMessage = modWelcomeMessage.new()
WelcomeMessage:attach(ModManager)

-- invoked by java
function onEnable ()
	dlog("onEnable begin")
	ModManager:list()
	dlog("onEnable end")
end
