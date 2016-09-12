sty = {}

sty.version = '1.0.0'

sty.include_cl = SERVER and AddCSLuaFile or include
sty.include_sv = SERVER and include or function() end
sty.include_sh = function(...)
	if SERVER then AddCSLuaFile(...) end
	return include(...)
end

-- pfoolproof integration
if file.Exists('includes/modules/pfoolproof.lua', 'LUA') then
	require 'pfoolproof'
	sty.addon = pfoolproof.registerAddon('Stylish-UI-Framework', sty.version)
end

if sty.addon then
	local function wrapIncludeHelper(func)
		return function(filePath)
			filePath = 'sty/' .. filePath
			if not file.Exists('includes/modules/pfoolproof.lua', 'LUA') then
				sty.addon:fatalError("Failed to load file " .. filePath .. ". File does not exist.")
			end
			return func(filePath)
		end
	end
	sty.include_cl = wrapIncludeHelper(sty.include_cl)
	sty.include_sv = wrapIncludeHelper(sty.include_sv)
	sty.include_sh = wrapIncludeHelper(sty.include_sh)
end


-- finish loading stylish
sty.include_cl 'sty_core_cl.lua'
sty.include_cl 'sty_fonts_cl.lua'
sty.include_cl 'sty_util_cl.lua'

sty.include_cl 'classes/sty_coretypes.lua'

sty.include_cl 'panels/sty_panel.lua'
sty.include_cl 'panels/sty_layout.lua'
sty.include_cl 'panels/sty_views.lua'
