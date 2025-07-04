unit module PDF::GraphPaper::Vars;

# A list in desired order of the current attributes.
constant @valid-keys is export = [ 

"units",
"media",
"orientation",
"margins",
"margin-t",
"margin-b",
"margin-l",
"margin-r",

"cell-size-x",

"cell-size-y",

"page-width",
"page-height",

"major-grids",
"minor-grids",
"cells-per-grid",
"cell-linewidth",
"mid-grid-linewidth",

"grid-linewidth",

# 6 more attrs
"scale-t",
"scale-b",
"scale-l",
"scale-r",
"grid-origin-x",
"grid-origin-y",

];
