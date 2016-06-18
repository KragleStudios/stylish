# stylish
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
```
figures out the perfect fontsize to fit the words "Hello world" in the dimensions provided.
