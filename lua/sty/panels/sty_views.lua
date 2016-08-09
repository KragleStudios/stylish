local surface = surface

vgui.Register('STYButton', {
	Init = function(self)
		self._label = Label('', self)
	end,

	AddAltText = function(self, altText)
		local restoreText = nil
		sty.Detour(self, 'OnCursorEntered', function(self)
			restoreText = self._label:GetText()
			self._label:SetText(altText)
			self:InvalidateLayout()
		end)

		sty.Detour(self, 'OnCursorExited', function(self)
			self._label:SetText(restoreText)
			self:InvalidateLayout()
		end)

		return self
	end,

	DoClick = function(self)
		-- OVERRIDE
	end,

	SetFont = function(self, font)
		assert(type(font) ~= 'string', 'must be a sty.Font')
		self.font = font

		return self
	end,

	SetText = function(self, text)
		self._label:SetText(text)

		return self
	end,

	PerformLayout = function(self)
		if self.font then
			self._label:SetFont(self.font:fitToView(self:GetWide() - 5, self:GetTall() * 0.7, self._label:GetText()))
		end
		self._label:SizeToContents()
		self._label:Center()
	end,

	PaintHovered = function(self, w, h)
		-- OVERRIDE
	end,

	PaintPressed = function(self, w, h)
		-- OVERRIDE
	end,

	PaintNormal = function(self, w, h)
		-- OVERRIDE
	end,

	OnMousePressed = function(self, ...)
		self._pressed = true
	end,

	OnMouseReleased = function(self)
		self._pressed = false
		self:DoClick()
	end,


	Paint = function(self, w, h)
		if self._pressed then
			if not input.IsMouseDown(MOUSE_LEFT) and not input.IsMouseDown(MOUSE_RIGHT) then
				self._pressed = false
			end
			self:PaintPressed(w, h)
		elseif self:IsHovered() then
			self:PaintHovered(w, h)
		else
			self:PaintNormal(w, h)
		end
	end,
}, 'STYPanel')

vgui.Register('STYImage', {
	Init = function(self)
		self._material = nil
	end,

	SetMaterial = function(self, mat)
		if type(mat) == 'string' then
			mat = Material(mat)
		end
		self._material = mat
	end,

	SetColor = function(self, color)
		self._color = color
	end,

	Paint = function(self, w, h)
		if not self._material then return end
		surface.SetMaterial(self._material)
		surface.SetDrawColor(self._color or color_white)
		surface.DrawTexturedRect(0, 0, w, h)
	end,
})



vgui.Register('STYMultiPage', {
	Init = function(self)
		self._pages = {}
		self._animTime = 0.15
	end,

	SetAnimDuration = function(self, duration)
		self._animTime = duration
	end,

	CurPage = function(self)
		return self._pages[#self._pages]
	end,

	PushPage = function(self, panel, onDone)
		local curpage = self:CurPage()
		curpage:MoveTo(-self:GetWide(), 0, self._animTime, 0, -1, function()
			curpage:SetVisible(false)
		end)

		table.insert(self._pages, page)

		panel:SetParent(self)
		panel:SetSize(self:GetSize())
		panel:SetPos(self:GetWide(), 0)
		panel:SetVisible(true)
		panel:MoveTo(0, 0, self._animTime, 0, -1, onDone)
	end,

	PopPage = function(self, onDone)
		local curpage = self:CurPage()
		curpage:MoveTo(self:GetWide(), 0, self._animTime, 0, -1, function()
			curpage:SetVisible(false)
			curpage:Remove()
		end)

		self._pages[#self._pages] = nil

		local curPage = self:CurPage()
		curpage:SetVisible(true)
		curpage:MoveTo(-self:GetWide(), 0, self._animTime, 0, -1, onDone)

	end,

	PerformLayout = function(self)
		local w, h = self:GetSize()

		for k, panel in ipairs(self._pages) do
			panel:SetSize(w, h)
		end
	end,
}, 'STYPanel')
