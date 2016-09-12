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

vgui.Register('STYTextBox', {
	Init = function(self)
		self._label = Label('', self)
		self._font = nil
		self:SetInset(0)
		self:SetAlign('left')
	end,

	SetFont = function(self, font)
		self._font = font
		self:InvalidateLayout()
		return self
	end,

	SetText = function(self, text)
		self._label:SetText(text)
		self:InvalidateLayout()
		return self
	end,

	GetText = function(self)
		return self._label:GetText()
	end,

	SetInset = function(self, ...)
		self._inset = sty.CreateInset(...)
		self:InvalidateLayout()
		return self
	end,

	SetAlign = function(self, align)
		self._align = align
		self:InvalidateLayout()
		return self
	end,

	PerformLayout = function(self)
		self._label:SetSize(self._inset:GetSizeInset(self:GetSize()))
		if self._font then
			self._label:SetFont(self._font:fitToView(self._label:GetWide(), self._label:GetTall(), self._label:GetText()))
		end
		self._label:SizeToContents()
		local y = self._inset.top + (self:GetTall() - self._inset.vertInset - self._label:GetTall()) * 0.5
		if self._align == 'center' or not self._align then
			self._label:SetPos(self._inset.left + (self:GetWide() - self._inset.horInset - self._label:GetWide()) * 0.5, y)
		elseif self._align == 'left' then
			self._label:SetPos(self._inset.left, y)
		elseif self._align == 'right' then
			self._label:SetPos(self:GetWide() - self._inset.right - self._label:GetWide(), y)
		end
	end,
}, 'STYPanel')

vgui.Register('STYImage', {
	Init = function(self)
		self._inset = 0
	end,
	SetMaterial = function(self, material)
		if type(material) == 'string' then
			material = Material(material)
		end
		self._material = material
		return self
	end,
	SetBackgroundColor = function(self, color)
		self._bgColor = color
		return self
	end,
	SetInset = function(self, ...)
		self._inset = sty.CreateInset(...)
		return self
	end,

	Paint = function(self, w, h)
		if self._bgColor then
			surface.SetDrawColor(self._bgColor)
			surface.DrawRect(0, 0, w, h)
		end
		if sef._material then
			local inset = self._inset
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(self._material)
			surface.DrawTexturedRect(inset.left, inset.top, w - inset.horInset, h - inset.vertInset)
		end
	end,
}, 'STYPanel')
