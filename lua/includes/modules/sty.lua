if SERVER then
	AddCSLuaFile()
	AddCSLuaFile("sty/load_sh.lua")
end

require 'ra'
include("sty/load_sh.lua")