[![Actions Status](https://github.com/tbrowder/PDF-GraphPaper/actions/workflows/linux.yml/badge.svg)](https://github.com/tbrowder/PDF-GraphPaper/actions) [![Actions Status](https://github.com/tbrowder/PDF-GraphPaper/actions/workflows/macos.yml/badge.svg)](https://github.com/tbrowder/PDF-GraphPaper/actions) [![Actions Status](https://github.com/tbrowder/PDF-GraphPaper/actions/workflows/windows.yml/badge.svg)](https://github.com/tbrowder/PDF-GraphPaper/actions)

NAME
====

**PDF::GraphPaper** - Provides a binary to produce PDF graph grids on ISO paper sizes

SYNOPSIS
========

```raku
use PDF::GraphPaper;
```

DESCRIPTION
===========

**PDF::GraphPaper** is a module that allows the user to create a grid on a PDF page. It includes a binary program ('make-graph-paper') to create a single gridded PDF page on any standard ISO page size. Most users will use the 'Letter" (default) or 'A4' paper. 

The default user measurements are inches for page descriptions (such as margins and grid dimensions and placement) and PostScript points for font sizes and ajustments. Alternatively, the user can choose centimeters for page descriptions.

AUTHOR
======

Tom Browder (tbrowder@acm.org)

COPYRIGHT AND LICENSE
=====================

© 2025 Tom Browder

This library is free software; you may redistribute it or modify it under the Artistic License 2.0.

