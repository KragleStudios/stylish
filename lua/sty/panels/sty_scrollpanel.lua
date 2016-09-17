sty.SHOW_SCROLLBAR_HORIZONTAL = 1
sty.SHOW_SCROLLBAR_VERTICAL = 2

vgui.Register('STYScrollablePanelBase', {
	Init = function(self)
		self.__bInitialSetup = true
		self.__pContentView = vgui.Create('STYPanel', self)
		self.__nGutterSize = 10
		self.__nScrollOffsetX = 0
		self.__nScrollOffsetY = 0
		self.__bSmoothScroll = true
		self.__nSmoothScrollMomentum = 0
		self:SetScrollRate(40)
		self:SetHorizontalScrollBarClass('STYScrollBarHorizontal')
		self:SetVerticalScrollBarClass('STYScrollBarVertical')

		self:SetScrollBarFlags(sty.SHOW_SCROLLBAR_HORIZONTAL + sty.SHOW_SCROLLBAR_VERTICAL)

		self.__bInitialSetup = false

		self:InvalidateLayout()
	end,

	SetScrollBarFlags = function(self, flags)
		self.__bShowHorizontalScrollBar = bit.band(sty.SHOW_SCROLLBAR_HORIZONTAL, flags) > 0
		self.__bShowVerticalScrollBar = bit.bor(sty.SHOW_SCROLLBAR_VERTICAL, flags) > 0
		self:InvalidateLayout()
	end,

	OnChildAdded = function(self, panel)
		if self.__bInitialSetup then return true end
		panel:SetParent(self.__pContentView)
		return false
	end,

	-- public
	SetScrollRate = function(self, scrollRate)
		self.__nScrollRate = scrollRate
	end,

	SetHorizontalScrollBarClass = function(self, class)
		if IsValid(self.__pHorizontalScrollBar) then
			self.__pHorizontalScrollBar:Remove()
		end
		self.__pHorizontalScrollBar = vgui.Create(class, self)
		self:InvalidateLayout()
	end,

	SetVerticalScrollBarClass = function(self, class)
		if IsValid(self.__pVerticalScrollBar) then
			self.__pVerticalScrollBar:Remove()
		end
		self.__pVerticalScrollBar = vgui.Create(class, self)
		self:InvalidateLayout()
	end,

	SetScrollBarGutterSize = function(self, gutterSize)
		self.__nGutterSize = gutterSize
		self:InvalidateLayout()
		return self
	end,

	GetScrollBarGutterSize = function(self)
		return self.__nGutterSize
	end,

	GetContentView = function(self)
		return self.__pContentView
	end,

	GetContentViewSize = function(self)
		return self.__pContentView:GetSize()
	end,

	SetHorizontalScrollBarEnabled = function(self, bEnabled)
		if not self.__bShowVerticalScrollBar then return end

		if not self.__bPerformingLayout and bEnabled ~= self.__bHorizontalScrollBarEnabled then
			self:InvalidateLayout()
		end
		self.__bHorizontalScrollBarEnabled = bEnabled
		return self
	end,

	SetVerticalScrollBarEnabled = function(self, bEnabled)
		if not self.__bShowVerticalScrollBar then return end

		if not self.__bPerformingLayout and bEnabled ~= self.__bVerticalScrollBarEnabled then
			self:InvalidateLayout()
		end
		self.__bVerticalScrollBarEnabled = bEnabled
		return self
	end,

	SetScrollXOffset = function(self, offset)
		self.__nScrollOffsetX = math.Clamp(offset, 0, math.max(0, self.__contentW - self.__pContentView:GetWide()))
		self:UpdateScrollBars()
		self:ScrollViewPerformContentLayout(self.__pContentView:GetSize())
		return self
	end,

	SetScrollXFraction = function(self, fraction)
		self:SetScrollXOffset(self.__contentW * fraction)
		return self
	end,

	GetScrollXOffset = function(self)
		return self.__nScrollOffsetX
	end,

	SetScrollYOffset = function(self, offset)
		self.__nScrollOffsetY = math.Clamp(offset, 0, math.max(0, self.__contentH - self.__pContentView:GetTall()))
		self:UpdateScrollBars()
		self:ScrollViewPerformContentLayout(self.__pContentView:GetSize())
		return self
	end,

	SetScrollYFraction = function(self, fraction)
		self:SetScrollYOffset(self.__contentH * fraction)
		return self
	end,

	GetScrollYOffset = function(self)
		return self.__nScrollOffsetY
	end,

	GetScrollOffsets = function(self)
		return self.__nScrollOffsetX, self.__nScrollOffsetY
	end,

	-- private
	UpdateScrollBars = function(self)
		if self.__bHorizontalScrollBarEnabled then
			self.__pHorizontalScrollBar:SetScroll(
				self.__nScrollOffsetX / (self.__contentW - self.__pContentView:GetWide()),
				self.__contentW
			)
		end
		if self.__bVerticalScrollBarEnabled then
			self.__pVerticalScrollBar:SetScroll(
				self.__nScrollOffsetY / (self.__contentH - self.__pContentView:GetTall()),
				self.__contentH
			)
		end
	end,

	PerformLayout = function(self)
		self.__bPerformingLayout = true

		local w, h = self:GetSize()

		-- update the content view and scroll bars
		local contentW, contentH = self:ScrollViewCalculateContentSizeForFrame(self:GetSize())
		self:SetHorizontalScrollBarEnabled(contentW > w)
		self:SetVerticalScrollBarEnabled(contentH > h)

		local contentViewW, contentViewH = self:GetSize()
		if self.__bHorizontalScrollBarEnabled then
			contentViewH = contentViewH - self.__nGutterSize
		end
		if self.__bVerticalScrollBarEnabled then
			contentViewW = contentViewW - self.__nGutterSize
		end
		self.__pContentView:SetSize(contentViewW, contentViewH)

		contentW, contentH = self:ScrollViewCalculateContentSizeForFrame(contentW, contentH)
		self.__contentW, self.__contentH = contentW, contentH

		-- clamp scroll offsets and update scrollbars
		if self:GetScrollXOffset() > contentW - contentViewW then
			self:SetScrollXOffset(self:GetScrollXOffset())
		end

		if self:GetScrollYOffset() > contentH - contentViewH then
			self:SetScrollYOffset(self:GetScrollYOffset())
		end

		self.__pHorizontalScrollBar:SetVisible(self.__bHorizontalScrollBarEnabled)
		self.__pVerticalScrollBar:SetVisible(self.__bVerticalScrollBarEnabled)
		self.__pHorizontalScrollBar:SetPos(0, contentViewH)
		self.__pHorizontalScrollBar:SetSize(contentViewW, h - contentViewH)
		self.__pVerticalScrollBar:SetPos(contentViewW, 0)
		self.__pVerticalScrollBar:SetSize(w - contentViewW, contentViewH)
		self:UpdateScrollBars()

		self.__bPerformingLayout = false

		self:ScrollViewPerformContentLayout(self.__pContentView:GetSize())
	end,

	ScrollViewPerformContentLayout = function(self, contentW, contentH)
		error 'ScrollViewPerformContentLayout not implemented'
		-- CLIENT MUST IMPLEMENT THIS
	end,

	ScrollViewCalculateContentSizeForFrame = function(self, frameW, frameH)
		error 'ScrollViewCalculateContentSizeForFrame not implemented'
	end,

	Think = function(self)
		if self.__bSmoothScroll and (self.__nSmoothScrollMomentum > 0.5 or self.__nSmoothScrollMomentum < -0.5) then
			if self.__bVerticalScrollBarEnabled then
				self:SetScrollYOffset(self:GetScrollYOffset() + self.__nSmoothScrollMomentum)
			else
				self:SetScrollXOffset(self:GetScrollYOffset() + self.__nSmoothScrollMomentum)
			end
			self.__nSmoothScrollMomentum = Lerp(FrameTime() * 30, self.__nSmoothScrollMomentum, 0)
		end
	end,

	OnMouseWheeled = function(self, delta)
		if self.__bVerticalScrollBarEnabled then
			self:SetScrollYOffset(self:GetScrollYOffset() - delta * self.__nScrollRate)
		else
			self:SetScrollXOffset(self:GetScrollYOffset() - delta * self.__nScrollRate)
		end
		if self.__bSmoothScroll then
			self.__nSmoothScrollMomentum = -delta * self.__nScrollRate
			self.__nSmoothScrollMomentum = -delta * self.__nScrollRate
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
		surface.DrawRect(self._fraction * (w - barW), 0, barW, h)
	end,
})

vgui.Register('STYScrollPanel', {
	Init = function(self)
		self.BaseClass.Init(self)
		self.__bInitialSetup = true
		self._contentPanel = vgui.Create('STYPanel', self:GetContentView())
		self.__bInitialSetup = false
	end,

	OnChildAdded = function(self, panel)
		if self.BaseClass.OnChildAdded(self, panel) then return end
		panel:SetParent(self._contentPanel)
		self:InvalidateLayout()
	end,

	ScrollViewCalculateContentSizeForFrame = function(self)
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

	-- this is really the equivalent of PerformLayout
	ScrollViewPerformContentLayout = function(self, contentW, contentH)
		local xoffset, yoffset = self:GetScrollXOffset(), self:GetScrollYOffset()
		self._contentPanel:SetPos(-xoffset, -yoffset)
	end,

}, 'STYScrollablePanelBase')
