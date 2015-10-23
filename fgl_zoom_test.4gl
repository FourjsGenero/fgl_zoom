#
#       (c) Copyright 2011, Four Js AsiaPac - www.4js.com.au/local
#
#       MIT License (http://www.opensource.org/licenses/mit-license.php)
#
#       Permission is hereby granted, free of charge, to any person
#       obtaining a copy of this software and associated documentation
#       files (the "Software"), to deal in the Software without restriction,
#       including without limitation the rights to use, copy, modify, merge,
#       publish, distribute, sublicense, and/or sell copies of the Software,
#       and to permit persons to whom the Software is furnished to do so,
#       subject to the following conditions:
#
#       The above copyright notice and this permission notice shall be
#       included in all copies or substantial portions of the Software.
#
#       THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#       EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
#       OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
#       NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
#       BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
#       ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
#       CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#       THE SOFTWARE.
#
#       fgl_zoom_test.4gl
#
#       January 2011 Reuben Barclay reuben@4js.com.au

#+ Controlling program for tests of generic zoom
#+
#+ Allows testing of the generic zoom routine.  

IMPORT FGL fgldialog

IMPORT FGL fgl_zoom_custom
IMPORT FGL fgl_zoom_example
IMPORT FGL fgl_zoom_functionaltest
IMPORT FGL fgl_zoom_testdata

MAIN
DEFINE w ui.Window
DEFINE f ui.Form
DEFINE l_mode STRING
 
    DEFER INTERRUPT 
    DEFER QUIT
    OPTIONS INPUT WRAP 
    OPTIONS FIELD ORDER FORM

    WHENEVER ANY ERROR CALL fgl_zoom_test_error
   
    CALL STARTLOG("fgl_zoom_test.log")

    CALL ui.Interface.loadStyles("fgl_zoom_test")

    CONNECT TO ":memory:+driver='dbmsqt'" 
    IF NOT fgl_zoom_testdata.create() THEN
        CALL fgl_zoom_test_error()
        EXIT PROGRAM 1
    END IF
    IF NOT fgl_zoom_testdata.populate() THEN
        CALL fgl_zoom_test_error()
        EXIT PROGRAM 1
    END IF
  
    CLOSE WINDOW SCREEN

    CALL fgl_zoom_custom.init()
    CALL fgl_zoom_example.init()
    CALL fgl_zoom_functionaltest.init()

    OPEN WINDOW fgl_zoom_test WITH FORM "fgl_zoom_test"
    LET w = ui.Window.getCurrent()
    LET f = w.getForm()   

    LET l_mode = "custom"
   
    WHILE l_mode != "exit"
        CASE l_mode
            WHEN "custom"           
                LET l_mode = fgl_zoom_custom.test()
            WHEN "example"          
                LET l_mode = fgl_zoom_example.test()
            WHEN "functionaltest"   
                LET l_mode = fgl_zoom_functionaltest.test()
            OTHERWISE                
                LET l_mode = "exit"
        END CASE
    END WHILE
    CLOSE WINDOW fgl_zoom_test
END MAIN



FUNCTION fgl_zoom_test_error()
   CALL FGL_WINMESSAGE("Error","An error has occured with fgl_zoom_test","stop")
   EXIT PROGRAM 1
END FUNCTION