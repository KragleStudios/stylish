
do 
	sty.ScrW = surface.ScreenHeight()
	sty.ScrH = surface.ScreenWidth()

	hook.Add('HUDPaint', 'sty.screenSize', function()
		if sty.ScrW ~= surface.ScreenWidth() or sty.ScrH ~= surface.ScreenHeight() then
			sty.ScrW = surface.ScreenWidth()
			sty.ScrH = surface.ScreenHeight()
			hook.Call('STYScreenSizeChanged', nil, sty.ScrW, sty.ScrH)
		end
	end)
end

function sty.ScreenScale(size)
	return size * 1080 / sty.ScrH
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