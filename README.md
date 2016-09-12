# stylish by thelastpenguin
A UI library that's fabulous

# Fonts
stylish manages your fonts for you!
```
coolvetica = sty.Font({
  font = 'coolvetica',
  weight = 500
})
```
will define a fontface coolvetica with weight 500. Note the conspicuous abscence of the size parameter. This is because stylish
can now generate this font at any size you may need i.e.
```
coolvetica:atSize(12)
```
returns the hashed name of a font which matches the definition with size 12. Say you want your font to fit into a rectangle of 100 x 100 pixels
```
coolvetica:fitToView(100, 100, "Hello world")
coolvetica:fitToView(panel, 'Hello world')
coolvetica:fitToView(panel, inset, 'Hello world')
```
figures out the perfect fontsize to fit the words "Hello world" in the dimensions provided.

# Panel Classes
## TODO
 - STYPanel - a basic stylish panel
   - STYContainer - a constrained container. Allows for expanding horizontally, expanding vertically, or both, or neither.
   - STYContentPanel - an auto expanding panel i.e. text
     - STYTextView - a paragraph of text. Expands horizontally then vertically to it's container
     - STYLabel - a simple single line label. Expands horizontally.
     - STYTableView - a simple table view with headers and sections. Can be customized by a delegate.
     - STYImage - a simple view for working with images icons or models. Abstracts them all.
   - STYScrollView - a scroll view that holds an STYContainer and allows it to scroll on it's width, it's height, or both.
