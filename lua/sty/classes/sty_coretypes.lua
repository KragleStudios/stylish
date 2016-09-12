-- INSETS
local inset_mt = {}
sty.inset_mt = inset_mt
inset_mt.__index = inset_mt

function inset_mt:HorizontalInset()
	return self.horInset
end

function inset_mt:VerticalInset()
	return self.vertInset
end

function inset_mt:GetSizeInset(width, height)
	return width - self:HorizontalInset(), height - self:VerticalInset()
end

sty.CreateInset = function(left, right, top, bottom)
	if right == nil then
		return sty.CreateInset(left, left, left, left)
	end
	return setmetatable({
		left = left,
		right = right,
		top = top,
		bottom = bottom,
		vertInset = top + bottom,
		horInset = left + right,
	}, inset_mt)
end
sty.ZeroInset = sty.CreateInset(0)
