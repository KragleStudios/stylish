
local cache = {}

function aui.Font(fontData)
	local str = {}
	for k,v in pairs(fontData) do
		str[#str + 1] = util.CRC(tostring(k)) .. util.CRC(tostring(v))
	end
	table.sort(str)
	local hash = util.CRC(table.concat(str, '-'))
	cache[hash] = {}

	local obj = {
		atSize = function(self, size)
			if not cache[hash][size] then 
				local name = 'f' .. hash .. ':' .. size
				cache[hash][size] = name

				surface.CreateFont(name, ra.util.extend(fontData, {
						size = size
					}))
			end
			return cache[hash][size]
		end,

		_fitToView = function(self, width, height, text, min, max)
			local avg = math.floor((min + max) * 0.5)
			if avg == min or avg == max then return avg end
			
			local fontName = self:atSize(avg)
			surface.SetFont(fontName)
			local w, h = surface.GetTextSize(text)
			print (w, h)
			if w > width or w > height then
				return self:_fitToView(width, height, text, min, avg)
			else
				return self:_fitToView(width, height, text, avg, max)
			end
		end,

		fitToView = function(self, width, height, text)
			return self:_fitToView(width, height, text, 2, 128)
		end
	}
	return obj
end