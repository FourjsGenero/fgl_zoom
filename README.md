# fgl_zoom
Generic Zoom Window

## Compatability

The use of Dynamic Dialogs will make it difficult to port this code to Genero versions prior to 3.00.  The module was originally written using Genero 2.30 so if you use GitHub to retrieve old versions of the code, you can probably put something together but I would suggest you upgrade to at least 3.00.

## Install

To incorporate fgl_zoom into your own application.

Compile and llace fgl_zoom.42m, fgl_zoom.42s where they will be
found by FGLLDPATH, FGLRESOURCEPATH, DBPATH etc. as used by your application.

Merge the contents of fgl_zoom_test.4st into your applications own style file.
You may wish to amend the styles used in fgl_zoom_test.4st so that it matches 
your own applications look and feel.

Merge the contents of fgl_zoom.str into your own string localization mechanism.
You could do as the test program does and simple add fgl_zoom.42s to the list of
specified files by the fglrun.localization.file settings in FGLPROFILE.

IN your 4gl, simply add IMPORT FGL fgl_zoom and make the appropriate function calls to initialize and execute.  Look at the View Source functionality in the Example tab to see typical code pattern required in your program.


