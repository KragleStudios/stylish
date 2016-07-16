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