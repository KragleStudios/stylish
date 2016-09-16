# CoreTypes
## Inset
An inset is a standard way of defining the left, right, top, and bottom content padding for a panel. It is different from a margin.
Insets are defined using
```Lua
sty.CreateInset(inset_for_all_sides)
```
or
```Lua
sty.CreateInset(left, right, top, bottom)
```
the internal representation of an inset is
```Lua
inset = {
	left = left,
	right = right,
	top = top,
	bottom = bottom,
	vertInset = top + bottom,
	horInset = left + right,
}
```
available meta methods are
```Lua
inset:HorizontalInset() -- returns top + bottom
inset:VerticalInset() -- returns left + right
inset:GetSizeInset(width, height) -- returns width - inset:HorizontalInset(), height - inset:VerticalInset()
```
