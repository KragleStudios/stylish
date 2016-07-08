local Panel = FindMetaTable('Panel')

function Panel:_PassEventUp(selector, source, ...)
	if self[selector] then
		self[selector](source, ...)
	else
		self:GetParent():_PassEventUp(selector, source, ...)
	end
end

function Panel:Dispatch(selector, ...)
	self:_PassEventUp(selector, self, ...)
end

function Panel:On(event, callback)
	if not self._events then self._events = {} end
	if not self._events[event] then self._events[event] = {} end
	table.insert(self._events[event], callback)
end

function Panel:RemoveListener(event, callback)
	if self._events and self._events[event] then
		for k,v in ipairs(self._events[event]) do
			if v == callback then
				table.remove(self._events[event], k)
				break
			end
		end
	end
end

function Panel:Call(event, ...)
	if self._events and self._events[event] then
		for _, fn in ipairs(self._events[event]) do
			fn(...)
		end
	end
end

function Panel:FindParentThatMatches(fn)
	if fn(self) then return self end
	return self:GetParent():FindParentThatMatches(fn)
end

function Panel:FindChildrenThatMatch(fn)
	local tbl = {}
	self:_FindChildrenThatMatch(fn, tbl)
	return tbl
end

function Panel:_FindChildrenThatMatch(fn, tbl)
	for k,v in pairs(self:GetChildren()) do
		if fn(v) then tbl[#tbl + 1] = v end
		v:_FindChildrenThatMatch(fn, tbl)
	end
end

function Panel:GetX()
	local x = self:GetPos()
	return x
end

function Panel:GetY()
	local _, y = self:GetPos()
	return y
end

function Panel:SetX(x)
	self:SetPos(x, self:GetY())
end

function Panel:SetY(y)
	self:SetPos(self:GetX(), y)
end

function Panel:GetMinSize()
	return self.minWidth or 0, self.maxWidth or 0
end

function Panel:GetMaxSize()
	return self.maxWidth or math.huge, self.maxHeight or math.huge 
end

function Panel:IsFixedHorizontally()
	return true
end

function Panel:IsFixedVertically()
	return true 
end
