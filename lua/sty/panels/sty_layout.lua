local kAXIS_VERTICAL = 1
local kAXIS_HORIZONTAL = 2
local function translateDirectionNameToEnum(dirName)
	if type(expandDirection) == 'string' then
		dirName = dirName:lower()
		if dirName == 'vertical' then
			dirName = kEXPAND_VERTICAL
		elseif dirName == 'horizontal' then
			dirName = kEXPAND_HORIZONTAL
		else
			error("unrecognized expansion direction " .. dirName .. ". Please use one of 'horizontal' or 'vertical'")
		end
	end
	return dirName
end

local kWIDTH = 1
local kHEIGHT = 2
local kXPOS = 3
local kYPOS = 4
vgui.Register('STYCollectionView', {
	Init = function(self)
		self._cvPadding = 0
		self._cvNumberOfSections = 0
		self._cvSections = {}

		self:SetExpandDirection(kAXIS_VERTICAL)
		self:SetLayoutDirection(kAXIS_HORIZONTAL)
	end,

	SetExpandDirection = function(self, expandDirection)
		self._eExpandDirection = translateDirectionNameToEnum(expandDirection)
	end,

	SetLayoutDirection = function(self, layoutDirection)
		self._eLayoutDirection = translateDirectionNameToEnum(layoutDirection)
	end,

	SetHorizontalPadding = function(self, horizontalPadding)
		self._nHorizontalPadding = horizontalPadding
	end,

	SetVerticalPadding = function(self, horizontalPadding)
		self._nHorizontalPadding = horizontalPadding
	end,

	CollectionViewNumberOfSections = function(self)
		error 'CollectionViewNumberOfSections() not implemented'
	end,

	CollectionViewNumberOfItemsInSectionWithIndex = function(self, sectionIndex)
		error 'CollectionViewNumberOfItemsInSectionWithIndex(self, sectionIndex) not implemented'
	end,

	CollectionViewSizeOfItemAtIndexPath = function(self, secIndex, itemIndex)
		error 'CollectionViewSizeOfItemAtIndexPath(self, sectionIndex, itemIndexInSection)'
	end,

	CollectionViewSizeOfItemAtIndex = function(self, index, contentViewW, contentViewH)
		error 'CollectionViewSizeOfItemAtIndex(self, index, contentViewW, contentViewH)'
	end,

	CollectionViewPanelForItemAtIndex = function(self, index, expectedWidth, expectedHeight)
		error 'CollectionViewPanelForItemAtIndex(self, index, expectedWidth, expectedHeight)'
	end,

	ReloadData = function(self)


		-- refresh the layout calculations
		self:RefreshLayout()
	end,

	ReloadSectionAtIndex = function(self, sectionIndex)

	end,

	RefreshLayout = function()
		local contentViewW, contentViewH = self:GetCOntentViewSize()

		local x = 0
		local y = 0
		for i = 1, #items do

		end
	end,

	ScrollViewCalculateContentSizeForFrame = function(self)
	end,

	ScrollViewPerformContentLayout = function(self, contentW, contentH)
		local offsetX, offsetY = self:GetScrollOffsets()

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

	for i = 1, 100 do
		local label = Label('hello ' .. i, _SCROLLPANEL)
		label:SetPos(39, i * 20)
		label:SizeToContents()
		label:SetTextColor(color_black)
	end

	for i = 1, 100 do
		local label = Label('hello ' .. i, _SCROLLPANEL)
		label:SetPos(i * 100, 39)
		label:SizeToContents()
		label:SetTextColor(color_black)
	end
end)
