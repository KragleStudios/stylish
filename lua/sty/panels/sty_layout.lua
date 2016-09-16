local Panel = FindMetaTable('Panel')

vgui.Register('STYScrollablePanelBase', {
	Init = function(self)
		self._pContentView = vgui.Create('STYPanel', self)
		self._nGutterSize = 10
		self._nScrollOffsetX = 0
		self._nScrollOffsetY = 0

		self:SetScrollRate(40)
		self:SetHorizontalScrollBarClass('STYScrollBarHorizontal')
		self:SetVerticalScrollBarClass('STYScrollBarVertical')

		self:InvalidateLayout()
	end,

	--[[
	OnChildAdded = function(self, panel)
		if panel.IsScrollBar and panel:IsScrollBar() then
			return true
		end
		panel:SetParent(self._pContentView)
		return false
	end,
	]]

	-- public
	SetScrollRate = function(self, scrollRate)
		self._nScrollRate = scrollRate
	end,

	SetHorizontalScrollBarClass = function(self, class)
		if IsValid(self._pHorizontalScrollBar) then
			self._pHorizontalScrollBar:Remove()
		end
		self._pHorizontalScrollBar = vgui.Create(class, self)
		self:InvalidateLayout()
	end,

	SetVerticalScrollBarClass = function(self, class)
		if IsValid(self._pVerticalScrollBar) then
			self._pVerticalScrollBar:Remove()
		end
		self._pVerticalScrollBar = vgui.Create(class, self)
		self:InvalidateLayout()
	end,

	SetScrollBarGutterSize = function(self, gutterSize)
		self._nGutterSize = gutterSize
		self:InvalidateLayout()
		return self
	end,

	GetScrollBarGutterSize = function(self)
		return self._nGutterSize
	end,

	GetContentViewSize = function(self)
		local w, h = self:GetSize()
		if self._bHorizontalScrollBarEnabled then
			h = h - self._nGutterSize
		end
		if self._bVerticalScrollBarEnabled then
			w = w - self._nGutterSize
		end
		return w, h
	end,

	SetHorizontalScrollBarEnabled = function(self, bEnabled)
		if not self._bPerformingLayout and bEnabled ~= self._bHorizontalScrollBarEnabled then
			self:InvalidateLayout()
		end
		self._bHorizontalScrollBarEnabled = bEnabled
		return self
	end,

	SetVerticalScrollBarEnabled = function(self, bEnabled)
		if not self._bPerformingLayout and bEnabled ~= self._bVerticalScrollBarEnabled then
			self:InvalidateLayout()
		end
		self._bVerticalScrollBarEnabled = bEnabled
		return self
	end,

	SetScrollXOffset = function(self, offset)
		self._nScrollOffsetX = math.Clamp(offset, 0, math.max(0, self._contentW - self._pContentView:GetWide()))
		self:UpdateScrollBars()
		self:UpdateContentLayout(self._pContentView:GetSize())
		return self
	end,

	SetScrollXFraction = function(self, fraction)
		self:SetScrollXOffset(self._contentW * fraction)
		return self
	end,

	GetScrollXOffset = function(self)
		return self._nScrollOffsetX
	end,

	SetScrollYOffset = function(self, offset)
		self._nScrollOffsetY = math.Clamp(offset, 0, math.max(0, self._contentH - self._pContentView:GetTall()))
		self:UpdateScrollBars()
		self:UpdateContentLayout(self._pContentView:GetSize())
		return self
	end,

	SetScrollYFraction = function(self, fraction)
		self:SetScrollYOffset(self._contentH * fraction)
		return self
	end,

	GetScrollYOffset = function(self)
		return self._nScrollOffsetY
	end,

	-- private
	UpdateScrollBars = function(self)
		if self._bHorizontalScrollBarEnabled then
			self._pHorizontalScrollBar:SetScroll(
				self._nScrollOffsetX / (self._contentW - self._pContentView:GetWide()),
				self._contentW
			)
		end
		if self._bVerticalScrollBarEnabled then
			self._pVerticalScrollBar:SetScroll(
				self._nScrollOffsetY / (self._contentH - self._pContentView:GetTall()),
				self._contentH
			)
		end
	end,

	PerformLayout = function(self)
		self._bPerformingLayout = true

		local w, h = self:GetSize()

		-- update the content view and scroll bars
		local contentW, contentH = self:CalculateContentSizeForFrame(self:GetSize())
		self:SetHorizontalScrollBarEnabled(contentW > w)
		self:SetVerticalScrollBarEnabled(contentH > h)

		local contentViewW, contentViewH = self:GetContentViewSize()
		self._pContentView:SetSize(contentViewW, contentViewH)

		contentW, contentH = self:CalculateContentSizeForFrame(contentW, contentH)
		self._contentW, self._contentH = contentW, contentH

		-- clamp scroll offsets and update scrollbars
		if self:GetScrollXOffset() > contentW - contentViewW then
			self:SetScrollXOffset(self:GetScrollXOffset())
		end

		if self:GetScrollYOffset() > contentH - contentViewH then
			self:SetScrollYOffset(self:GetScrollYOffset())
		end

		print('enabled scrollbars: ', self._bHorizontalScrollBarEnabled, self._bVerticalScrollBarEnabled)
		print('content view w: ', contentViewW, 'content view h: ', contentViewH)
		print('contentW: ', contentW, ' contentH: ', contentH)
		self._pHorizontalScrollBar:SetVisible(self._bHorizontalScrollBarEnabled)
		self._pVerticalScrollBar:SetVisible(self._bVerticalScrollBarEnabled)
		self._pHorizontalScrollBar:SetPos(0, contentViewH)
		self._pHorizontalScrollBar:SetSize(contentViewW, h - contentViewH)
		self._pVerticalScrollBar:SetPos(contentViewW, 0)
		self._pVerticalScrollBar:SetSize(w - contentViewW, contentViewH)
		self:UpdateScrollBars()

		self._bPerformingLayout = false

		self:UpdateContentLayout(self._pContentView:GetSize())
	end,

	UpdateContentLayout = function(self)

	end,

	OnMouseWheeled = function(self, delta)
		if self._bVerticalScrollBarEnabled then
			self:SetScrollYOffset(self:GetScrollYOffset() - delta * self._nScrollRate)
		else
			self:SetScrollXOffset(self:GetScrollYOffset() - delta * self._nScrollRate)
		end
	end,
}, 'STYPanel')


vgui.Register('STYScrollBarVertical', {
	Init = function(self)
		self._totalHeight = 10
		self._fraction = 10
	end,

	SetScroll = function(self, fraction, totalHeight)
		self._fraction = fraction
		self._totalHeight = totalHeight
	end,

	IsScrollBar = function() return true end,

	GetBarHeight = function(self)
		local h = self:GetTall()
		return h * h / self._totalHeight
	end,

	UpdateParentScroll = function(self)
		local parent = self:GetParent()
		self:GetParent():SetScrollYFraction(self._mouseY / self:GetTall())
	end,

	Think = function(self)
		if self._bPressed then
			local x, y = self:LocalToScreen(0, 0)
			local yoffset = gui.MouseY() - y - self:GetBarHeight() * 0.5
			self._mouseY = yoffset
			self:UpdateParentScroll()

			if not input.IsMouseDown(MOUSE_LEFT) then
				self._bPressed = false
			end
		end
	end,

	OnMousePressed = function(self)
		self._bPressed = true
		self:Think()
		self:UpdateParentScroll()
	end,

	Paint = function(self, w, h)
		surface.SetDrawColor(0, 0, 0, 155)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(255,255,255,255)
		local barH = self:GetBarHeight()
		surface.DrawRect(0, self._fraction * (h - barH), w, barH)
	end,
})

vgui.Register('STYScrollBarHorizontal', {
	Init = function(self)
		self._totalWidth = 10
		self._fraction = 0
	end,

	SetScroll = function(self, fraction, totalWidth)
		self._fraction = fraction
		self._totalWidth = totalWidth or 10
	end,

	IsScrollBar = function() return true end,

	GetBarWidth = function(self)
		local w = self:GetWide()
		return w * w / self._totalWidth
	end,

	UpdateParentScroll = function(self)
		local parent = self:GetParent()
		self:GetParent():SetScrollXFraction(self._mouseX / self:GetWide())
	end,

	Think = function(self)
		if self._bPressed then
			local x, y = self:LocalToScreen(0, 0)
			local xoffset = gui.MouseX() - x
			self._mouseX = xoffset - self:GetBarWidth() * 0.5
			self:UpdateParentScroll()

			if not input.IsMouseDown(MOUSE_LEFT) then
				self._bPressed = false
			end
		end
	end,

	OnMousePressed = function(self)
		self._bPressed = true
		self:Think()
		self:UpdateParentScroll()
	end,

	Paint = function(self, w, h)
		surface.SetDrawColor(0, 0, 0, 155)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(255,255,255,255)
		local barW = self:GetBarWidth()
		surface.DrawRect(0, self._fraction * (h - barW), barW, h)
	end,
})

vgui.Register('STYScrollPanel', {
	Init = function(self)
		self.BaseClass.Init(self)
		self._contentPanel = vgui.Create('STYPanel', self._pContentView)
	end,

	--[[
	OnChildAdded = function(self, panel)
		if self.BaseClass.OnChildAdded(self, panel) then return end
		panel:SetParent(self._contentPanel)
		self:InvalidateLayout()
	end,
	]]

	CalculateContentSizeForFrame = function(self)
		local maxx, maxy = 20, 20
		for k,v in ipairs(self._contentPanel:GetChildren()) do
			local x,y = v:GetPos()
			local w,h = v:GetSize()
			if x + w > maxx then maxx = x + w end
			if y + h > maxy then maxy = y + h end
		end
		self._contentPanel:SetSize(maxx, maxy)
		return maxx, maxy
	end,

	UpdateContentLayout = function(self, contentW, contentH)
		local xoffset, yoffset = self:GetScrollXOffset(), self:GetScrollYOffset()
		self._contentPanel:SetPos(0, -yoffset)
	end,

}, 'STYScrollablePanelBase')


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


vgui.Register('myPanelClass', {
	Init = function(self)
		print("hello world")
	end,

	CalculateContentSizeForFrame = function(self, w, h)
		return 500, 3000
	end,

	Paint = function(self, w, h)
		surface.SetDrawColor(220, 220, 220, 220)
		surface.DrawRect(0, 0, w, h)
	end,
}, 'STYScrollablePanelBase')

concommand.Add('sty_testscroll', function()
	if IsValid(_SCROLLPANEL) then _SCROLLPANEL:Remove() end
	print("HELLO WORLD")
	_SCROLLPANEL = vgui.Create('STYScrollPanel')
	_SCROLLPANEL:SetSize(ScrW() * 0.5, ScrH() * 0.5)
	_SCROLLPANEL:Center()
	_SCROLLPANEL:MakePopup()
	_SCROLLPANEL.Paint = function(self, w, h)
		surface.SetDrawColor(220, 220, 220, 220)
		surface.DrawRect(0, 0, w, h)
	end

	for i = 1, 1000 do
		local label = Label('hello ' .. i, _SCROLLPANEL._contentPanel)
		label:SetPos(39, i * 20)
		label:SizeToContents()
		label:SetTextColor(color_black)
	end
	--[[
	for i = 1, 1000 do
		local label = Label('hello ' .. i, _SCROLLPANEL._contentPanel)
		label:SetPos(i * 100, 39 )
		label:SizeToContents()
		label:SetTextColor(color_black)
	end]]
end)
