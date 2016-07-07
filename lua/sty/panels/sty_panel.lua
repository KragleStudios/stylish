vgui.Register('STYPanel', {
		Init = function() end,
		IsSTYPanel = function() return true end,
		GetMinSize = function(self)
			return self:GetSize() -- assume it's already as small as it can be
		end,
		GetPreferredSize = function(self)
			return self:GetMinSize() -- usually you want to be as small as possible
		end
	})