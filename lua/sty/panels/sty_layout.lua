local Panel = FindMetaTable('Panel')

vgui.Register('STYScrollablePanelBase', {
	Init = function(self)
		self._nContentHeight = 0
		self._nGutterWidth = 0
		self._bShowScrollbar = false
		self._nScrollOffset = 0

		self:SetScrollbarClass('STYScrollPanel')
	end,

	SetScrollbarClass = function(self, scrollbarClass)
		self._sScrollbarClass = scrollbar
	end,

	-- this is an abstract panel baseclass
	GetContentHeight = function(self)
		error 'expected to override this function'
	end,

	ReloadData = function(self)
		self._nContentHeight = self:GetContentHeight()
		self._nScrollOffset = math.Clamp(self._nScrollOffset, 0, self._nContentHeight - self:GetTall())

		local bShowScrollbar = self._bShowScrollbar > self:GetTall()
		if bShowScrollbar ~= self._bShowScrollbar then
			self._bShowScrollbar = bShowScrollbar
			-- might need to be recalculated since enabling the scrollbar changes the effective width
			self._nContentHeight = self:GetContentHeight()

			if bShowScrollbar and not IsValid(self._pScrollbar) then
				self._pScrollbar = vgui.Create(self._sScrollbarClass, self)
			elseif not bShowScrollbar and IsValid(self._pScrollbar) then
				self._pScrollbar:Remove()
				self._pScrollbar = nil
			end
		end

		self:InvalidateLayout()
	end,

	IsScrollbarVisible = function()
		return self._bShowScrollbar
	end,

	PerformLayout = function()
		self._nGutterWidth = self:IsScrollbarVisible() and self:GetScrollbarGutterWidth() or 0
	end,

	GetEffectiveHeight = function(self)
		return self:GetTall()
	end,

	GetEffectiveWidth = function(self)
		return self:GetWide() - self._nGutterWidth
	end,

	SetScrollOffset = function(self, offset)
		self._nScrollOffset = math.Clamp(self._nScrollOffset, 0, self._nContentHeight - self:GetTall())
		self:UpdateContent(offset, self:GetEffectiveWidth(), self:GetEffectiveHeight())
	end,

	UpdateContent = function(self, offset, width, height)
		error 'expected to overide PANEL:UpdateContent()'
	end,

	GetScrollbarGutterWidth = function(self)
		return 10
	end,

	Paint = function(self, w, h)

	end,
}, 'STYPanel')

vgui.Register('STYScrollPanel', {
	Init = function(self)

	end,
})

vgui.Register('STYCollectionView', {
	Init = function(self)
		self:SetCellSpacing(0)
		self._cellCache = {}
	end,

	DequeueCellWithClass = function(self, class)
		local cache = self._cellCache[class]
		if not cache then
			cache = {}
			self._cellCache[class] = cache
		end
		if #cache > 0 then
			local cell = cache[#cache]
			cache[#cache] = nil
			return cell
		end
		local panel = vgui.Create(class, self)
		return panel
	end,

	QueueCellForReuse = function(self, cell)
		cell:PrepareForReuse()
		table.insert(self._cellCache[cell:GetClassName()], cell)
		cell:SetVisible(false)
	end,

	SetCellSpacing = function(self, cellSpacing)
		assert(type(cellSpacing) == 'nubmer', 'expected argument #1 to be type number')
		self._cellSpacing = cellSpacing
	end,

	GetNumberOfCells = function(self)
		return 100
	end,

	GetCellForItemAtIndex = function(self, index)
		return cell
	end,

	GetSizeForItemAtIndex = function(self, index)
		return 64, 64
	end,

	PerformLayout = function(self)
	end,
}, 'STYPanel')

vgui.Register('STYCollectionViewCell', {
	PrepareForReuse = function(self)

	end,
})


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
			return self:GetWide() - self._padding * (#self:GetVisibleChildren() - 1)
		end,

		PerformLayout = function(self)
			local w, h = self:GetSize()

			local x = 0
			for k,v in ipairs(self:GetVisibleChildren()) do
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
		return self:GetAvailableWidth() / #self:GetVisibleChildren()
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
			return self:GetTall() - self._padding * (#self:GetVisibleChildren() - 1)
		end,

		PerformLayout = function(self)
			local w, h = self:GetSize()

			local y = 0
			for k,v in ipairs(self:GetVisibleChildren()) do
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
		return self:GetAvailableWidth() / #self:GetVisibleChildren()
	end,
}, 'STYLayoutVertical')
