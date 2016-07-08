vgui.Register('STYPanel', {
		Init = function() end,
		IsSTYPanel = function() return true end,
		GetMinSize = function(self)
			return self:GetSize() -- assume it's already as small as it can be
		end,
		GetPreferredSize = function(self)
			return self:GetMinSize() -- usually you want to be as small as possible
		end,


		-- @utilities
		MoveToRight = function(self)
			self:SetX(self:GetParent():GetWide() - self:GetWide())
		end,
		MoveToLeft = function(self)
			self:SetX(0)
		end,
		MoveToTop = function(self)
			self:SetY(0)
		end,
		MoveToBottom = function(self)
			self:SetY(self:GetParent():GetTall() - self:GetTall())
		end
	})