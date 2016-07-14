
do 
	sty.ScrW = surface.ScreenWidth()
	sty.ScrH = surface.ScreenHeight()

	local function updateConstants()
		sty.scaleRatio = sty.ScrW / 1080.0
		if sty.scaleRatio < 0.6 then sty.scaleRatio = 0.5 end
	end

	updateConstants()

	hook.Add('HUDPaint', 'sty.screenSize', function()
		if sty.ScrW ~= surface.ScreenWidth() or sty.ScrH ~= surface.ScreenHeight() then
			sty.ScrW = surface.ScreenWidth()
			sty.ScrH = surface.ScreenHeight()
			updateConstants()
			hook.Call('STYScreenSizeChanged', nil, sty.ScrW, sty.ScrH)
		end
	end)
end

function sty.ScreenScale(size)
	return size * sty.scaleRatio
end

function sty.With(panel)
	return setmetatable({}, {
			__index = function(self, fnIndex)
				return function(_, ...) -- skip first arg cuz _ == self
					if _ ~= self then error("must use obj:fn(...) call syntax") end
					panel[fnIndex](panel, ...)
					return self
				end
			end,
			__call = function() return panel end
		})
end


function sty.LerpColor(frac1, color1, color2)
	local frac2 = 1 - frac1
	return Color(color1.r * frac1 + color2.r * frac2, color1.g * frac1 + color2.g * frac2, color1.b * frac1 + color2.b * frac2, color1.a * frac1 + color2.a * frac2)
end

function sty.Detour(obj, method, fn)
	if obj[method] then
		local old = obj[method]
		obj[method] = function(...)
			local a, b, c, d = old(...)
			if a ~= nil then return a, b, c, d end
			return fn(...)
		end
	else
		obj[method] = fn
	end
end

do
	local queue = {}
	if not IsValid(LocalPlayer()) then
		hook.Add('OnEntityCreated', 'sty.WaitForLocalPlayer', function(ent)
			if ent == LocalPlayer() then
				for k,v in ipairs(queue) do
					v()
				end
				table.Empty(queue)
				hook.Remove('OnEntityCreated', 'sty.WaitForLocalPlayer')
			end
		end)
	end

	function sty.WaitForLocalPlayer(func)
		if IsValid(LocalPlayer()) then
			func()
		else
			table.insert(queue, func)
		end
	end

end