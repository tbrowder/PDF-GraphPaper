[![Actions Status](https://github.com/tbrowder/PDF-GraphPaper/actions/workflows/linux.yml/badge.svg)](https://github.com/tbrowder/PDF-GraphPaper/actions) [![Actions Status](https://github.com/tbrowder/PDF-GraphPaper/actions/workflows/macos.yml/badge.svg)](https://github.com/tbrowder/PDF-GraphPaper/actions) [![Actions Status](https://github.com/tbrowder/PDF-GraphPaper/actions/workflows/windows.yml/badge.svg)](https://github.com/tbrowder/PDF-GraphPaper/actions)

NAME
====

**PDF::GraphPaper** - Provides a binary to produce PDF graph grids on ISO paper sizes

SYNOPSIS
========

```raku
use PDF::GraphPaper;
...
```

DESCRIPTION
===========

**PDF::GraphPaper** is a module that allows the user to create a grid on a PDF page. It includes a binary program ('make-graph-paper') to create a single gridded PDF page on any standard ISO page size. Most users will use the 'Letter" (default) or 'A4' paper.

The default user measurements are inches for page descriptions (such as margins and grid dimensions and placement) and PostScript points for font sizes and adjustments. Alternatively, the user may choose centimeters for page descriptions.

Grid scales
-----------

The default is not to add a scale. If added, the scales are added with numbers in the current units and increasing in magnitude to the top or right as approriate. The zero points are at the grid's X and Y origin and covering the edge lengths.

With the `scale-X` options, a scale can be added for the grid at X where X is `T`, `B`, `L`, or `R` for the grid's top, bottom, left, or right edge, respectively. The real effect of the "position" letter is to (1) specify its direction and (2) to specify which side of the ruled line the numbers and tick marks appear. The "top" and "bottom" scales are parallel to those edges of the paper while "left" and "right" scales are parallel to those edges.

The scales can be added without also creating the grid. In that case, they will be placed but using the default grid corners

The other way is to specify one or more scales using the `sparam` option for each desired scale. For example:

    sparam=L,36,36,500
    =end code.

    =head2 Overlay

    The user may easily overlay grids or ruled lines on an existing PDF
    document by providing its name in an option:

    =begin code
    pdf-in=/path/to/pdf-file

Binary file `make-graph-paper`
------------------------------

The installed executable file, `make-graph-paper`, has the following required and optional arguments:

    $pdf-out,           # desired name of the new PDF file
    # options:
    IO::Path :$pdf-in,  # source PDF document for overlays; if used
                        #   it CANNOT be overwritten
    Bool :$grid=True    # produce a grid per the specifications
    Bool :$force=False, # allow overwriting an existing input PDF
         :$spec=X,      # where IO::Path X is a specification file
                        #   for this run
    Bool :$show-spec,   # if True, show the default spcifications
                        #   on STDOUT
    Str  :$scale,       # if nonempty, has codes from set "tblr" for
                        #   adding one or more scales
    Str  :$sbbox,       # llx, lly, width, height for scales and no grid

The specification file
----------------------

This program, at execution time, will check for the existence of a specification file in the user's home directory at '\$HOME/pdf-graphpaper.cnf'.

If none is found, the built-in defaults will be used. Those defaults can be seen by using the `show-specs` option. You can also see them at this link: [SPECS](SPECS.md).

AUTHOR
======

Tom Browder (tbrowder@acm.org)

COPYRIGHT AND LICENSE
=====================

© 2025 Tom Browder

This library is free software; you may redistribute it or modify it under the Artistic License 2.0.

