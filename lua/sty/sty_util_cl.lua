
do 
	hook.Add('Initialize', 'sty.screenSize', function()
		vgui.CreateFromTable {
			Base = 'Panel',
			PerformLayout = function()
				sty.scaleRatio = ScrW() / 1080.0
				if sty.scaleRatio < 0.6 then sty.scaleRatio = 0.5 end
				hook.Call('STYScreenSizeChanged', nil, ScrW(), ScrH())
			end,
		}:ParentToHUD()
	end)
end

function sty.ScreenScale(size)
	return size * sty.scaleRatio
end

function sty.With(panel)
	return setmetatable({}, {
			__index = function(self, fnIndex)
				return function(_, ...) -- skip first arg cuz _ == self
					if _ ~= self then error('must use obj:fn(...) call syntax') end
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


local cursorPositions = {}
function sty.SaveCursor(key)
	cursorPositions[key] = ra.fn.storeArgs(input.GetCursorPos())
end

function sty.RestoreCursor(key)
	if cursorPositions[key] then
		input.SetCursorPos(cursorPositions[key]())
	end
end


function sty.CalcInsetSize(inset, x, y)
	return x - 2 * inset, y - 2 * inset 
end

function sty.CalcInsetPos(inset, x, y)
	return inset + x, inset + y 
end
