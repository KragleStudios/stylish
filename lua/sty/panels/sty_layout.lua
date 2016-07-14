vgui.Register('STYLayoutHorizontal', {
		Init = function(self)
			self:SetPadding(0)
		end,

		SetPadding = function(self, padding)
			self._padding = padding
		end,

		GetCellWidth = function(self, rowPanel, index)
			return rowPanel:GetWide()
		end,

		GetAvailableWidth = function(self)
			return self:GetWide() - self._padding * (#self:GetChildren() - 1)
		end,

		PerformLayout = function(self)
			local w, h = self:GetSize()

			local x = 0
			for k,v in ipairs(self:GetChildren()) do
				if v:GetTall() ~= h then v:SetTall(h) end
				local cellWidth = self:GetCellWidth(v, k)
				if v:GetWide() ~= cellWidth then v:SetWide(cellWidth) end
				v:SetPos(x, 0)
				x = x + cellWidth + self._padding
			end

			self:SetWide(x - self._padding)
		end,
	}, 'STYPanel')

vgui.Register('STYLayoutHorizontalFill', {
	GetMinSize = function(self) return self:GetSize() end,

	GetCellWidth = function(self, rowPanel, index)
		return self:GetAvailableWidth() / #self:GetChildren()
	end,
}, 'STYLayoutHorizontal')


vgui.Register('STYLayoutVertical', {
		Init = function(self)
			self:SetPadding(0)
		end,

		SetPadding = function(self, padding)
			self._padding = padding
		end,

		GetCellHeight = function(self, rowPanel, index)
			return rowPanel:GetTall()
		end,

		GetAvailableHeight = function(self)
			return self:GetTall() - self._padding * (#self:GetChildren() - 1)
		end,

		PerformLayout = function(self)
			local w, h = self:GetSize()

			local y = 0
			for k,v in ipairs(self:GetChildren()) do
				if v:GetWide() ~= w then v:SetWide(w) end
				local cellHeight = self:GetCellHeight(v, k)
				if v:GetTall() ~= cellHeight then v:SetTall(cellHeight) end
				v:SetPos(0, y)
				y = y + cellHeight + self._padding
			end

			self:SetTall(y - self._padding)
		end,

	}, 'STYPanel')

vgui.Register('STYLayoutVerticalFill', {
	GetMinSize = function(self) return self:GetSize() end,

	GetAvailableHeight = function(self, rowPanel, index)
		return self:GetAvailableWidth() / #self:GetChildren()
	end,
}, 'STYLayoutVertical')
