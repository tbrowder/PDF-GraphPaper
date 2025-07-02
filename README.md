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

Ruled lines
-----------

With the `ruler` option, a single ruled line can be placed on a page with its origin, angle, and length units as desired.

The defaults are: origin X=0.5 inches, y=0 inches, angle=90 degrees, and length units of inches. The X axis is parallel to the bottom of the page, with magnitudes inreasing to the right.

Overlay
-------

The user may easily overlay grids or ruled lines on an existing PDF document by providing its name in an option:

    pdf-in=/path/to/pdf-file

Binary file `make-graph-paper`
------------------------------

The installed executable file, `make-graph-paper`, has the following required and optional arguments:

    $pdf-out,      # desired name of the new PDF file
                   # options:
    :$pdf-in,      # source PDF document for overlays; if used
                   #   it CANNOT be overwritten
    :$ruler=False, # if True, writes the default ruler, no grid
    :$force=False, # allow overwriting an existing input PDF
    :$spec=X,      # specification file for this run
    :$show-spec,   # if True, show a standard spcification file on STDOUT

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

