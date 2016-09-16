local sty = sty
local Panel = FindMetaTable('Panel')

vgui.Register('STYPanel', {
		Init = function() end,

		IsSTYPanel = function() return true end,

		GetVisibleChildren = function(self)
			local children = {}
			for k,v in ipairs(self:GetChildren()) do
				if v:IsVisible() then
					table.insert(children, v)
				end
			end
			return children
		end,

		GetRect = function(self)
			local x, y, w, h
			x, y = self:GetPos()
			w, h = self:GetSize()
			return x, y, w, h
		end,

		SetRect = function(self, x, y, w, h)
			self:SetPos(x, y)
			self:SetSize(w, h)
			return self
		end,

		SetPos = function(self, x, y)
			Panel.SetPos(self, x, y)
			return self
		end,

		SetSize = function(self, w, h)
			Panel.SetSize(self, w, h)
			return self
		end,

		-- apply the layout to the view
		ApplyLayout = function(self, layout)
			if self.ValidateLayout then
				self:ValidateLayout(layout)
			end

			for key, func in pairs(layout) do
				if not self[key] then
					self[key] = func
				else
					local oldFunc = self[key]
					self[key] = function(...)
						local a, b, c, d = oldFunc(...)
						if a ~= nil then return a, b, c, d end
						return func(...)
					end
				end
			end
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
		end,
	}, 'EditablePanel')
