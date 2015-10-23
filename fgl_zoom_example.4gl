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
#       fgl_zoom_example.4gl
#
#       January 2011 Reuben Barclay reuben@4js.com.au

#+ Some examples of the generic zoom window in use
#+ 
#+ This shows the expected usage of the generic zoom routines in that I'd
#+ expect you would create some wrapper functions for each of the zooms that
#+ you'd want in your application i.e you'd defined a zoom_state() funciton in
#+ your application and then every time you have state code  in your application
#+ you would make that a BUTTONEDIT and an ON ACTION zoom that calls this
#+ zoom_state() function

IMPORT FGL fgl_zoom

DEFINE m_example RECORD
    state_code  CHAR(2),
    store_code INTEGER,
    customer_code INTEGER,
    country_code CHAR(3)
END RECORD



#+ Set the exception handling
PRIVATE FUNCTION exception()
    WHENEVER ANY ERROR RAISE
END FUNCTION



#+ Get the module ready for use
FUNCTION init()
    INITIALIZE m_example.* TO NULL
END FUNCTION



#+ Allow the user to run the various examples
FUNCTION test()
DEFINE l_mode STRING

DEFINE l_country_code CHAR(3)
DEFINE l_country_name CHAR(30)

    DIALOG ATTRIBUTES(UNBUFFERED)
        INPUT BY NAME m_example.* ATTRIBUTES(WITHOUT DEFAULTS=TRUE)
            ON ACTION zoom INFIELD state_code
                LET m_example.state_code = zoom_state(FGL_DIALOG_GETBUFFER())

            ON ACTION zoom INFIELD customer_code
                LET m_example.customer_code = zoom_customer(FGL_DIALOG_GETBUFFER())

            ON ACTION zoom INFIELD store_code
                LET m_example.store_code = zoom_store(FGL_DIALOG_GETBUFFER())

            ON ACTION zoom INFIELD country_code
                LET m_example.country_code = zoom_country(FGL_DIALOG_GETBUFFER())
              
            ON ACTION functionaltest
                LET l_mode = "functionaltest"
                EXIT DIALOG
            
            ON ACTION custom
                LET l_mode = "custom"
                EXIT DIALOG
                
            ON ACTION view_source INFIELD state_code  
                CALL show_function_source("zoom_state")

            ON ACTION view_source INFIELD customer_code 
                CALL show_function_source("zoom_customer")
                
            ON ACTION view_source INFIELD store_code 
                CALL show_function_source("zoom_store")

            ON ACTION view_source INFIELD country_code
                CALL show_function_source("zoom_country")

            ON ACTION CLOSE ATTRIBUTES(TEXT="view Source") 
                LET l_mode = "exit"
                EXIT DIALOG
        END INPUT
    END DIALOG

    RETURN l_mode
END FUNCTION



#+ A zoom window to select the state code
#+
#+ This example displays only the sname field and returns the state code
#+ It is ordered sname before code so that the visible sname column is used by 
#+ the goto functionality
PRIVATE FUNCTION zoom_state(l_current_value)
DEFINE l_current_value STRING

    CALL fgl_zoom.init()
    CALL fgl_zoom.noqbe_set(TRUE)
    CALL fgl_zoom.cancelvalue_set(l_current_value)
    CALL fgl_zoom.title_set("Select State")
    CALL fgl_zoom.sql_set("SELECT state_name, state_code FROM fgl_zoom_state ORDER BY state_name")
   
    CALL fgl_zoom.column_quick_set(1,"state_name","c",20, "State")
    CALL fgl_zoom.column_includeinresult_set(1,FALSE)
   
    CALL fgl_zoom.column_quick_set(2,"state_code","c", 0, "Code")
    CALL fgl_zoom.column_excludelist_set(2,TRUE)
    CALL fgl_zoom.column_includeinresult_set(2,TRUE)
   
    RETURN fgl_zoom.call()
END FUNCTION



#+ A simple zoom window to select the customer number
PRIVATE FUNCTION zoom_store(l_current_value)
DEFINE l_current_value STRING

    CALL fgl_zoom.init()
    CALL fgl_zoom.cancelvalue_set(l_current_value)
    CALL fgl_zoom.title_set("Select Store Code")
    CALL fgl_zoom.sql_set("SELECT %2 FROM fgl_zoom_store WHERE %1 ORDER BY store_num")
   
    CALL fgl_zoom.column_quick_set(1, "store_num", "i", 4, "Number")
    CALL fgl_zoom.column_quick_set(2, "store_name", "c", 20, "Name")
    CALL fgl_zoom.column_quick_set(3, "addr", "c", 20, "Address 1")
    CALL fgl_zoom.column_quick_set(4, "addr2", "c", 20, "Address 2")
    CALL fgl_zoom.column_quick_set(5, "city", "c", 15, "City")
    CALL fgl_zoom.column_quick_set(6, "state", "c", 2, "State")
    CALL fgl_zoom.column_quick_set(7, "zipcode", "c", 5, "Zipcode")
    CALL fgl_zoom.column_quick_set(8, "phone", "c", 18, "Phone")
   
    RETURN fgl_zoom.call()
END FUNCTION

 

#+ A slightly more complex zoom window to select the customer number
#+
#+ This example concatentates some of the fields together so that name, address 
#+ etc. are displayed as one column each.
PRIVATE FUNCTION zoom_customer(l_current_value)
DEFINE l_current_value STRING

    CALL fgl_zoom.init()
    CALL fgl_zoom.cancelvalue_set(l_current_value)
    CALL fgl_zoom.title_set("Select Customer Code")
    CALL fgl_zoom.sql_set("SELECT customer_num, trim(lname) ||', '||trim(fname),  company, trim(address1)||' '||trim(address2), city, state FROM fgl_zoom_customer WHERE %1 ORDER BY customer_num")

    CALL fgl_zoom.column_quick_set(1, "customer_num", "i", 4, "Code")
    CALL fgl_zoom.column_quick_set(2, "(trim(lname) ||', '||trim(fname))", "c", 10, "Name")
    CALL fgl_zoom.column_quick_set(3, "company", "c", 10, "Company")
    CALL fgl_zoom.column_quick_set(4, "(trim(address1)||' '||trim(address2))", "c", 20, "Address")
    CALL fgl_zoom.column_quick_set(5, "city", "c", 10, "City")
    CALL fgl_zoom.column_quick_set(6, "state", "c", 5, "State")

    CALL fgl_zoom.freezeleft_set(1)
   
    RETURN fgl_zoom.call()
END FUNCTION


#+ A simple zoom window to select a country code.
PRIVATE FUNCTION zoom_country(l_current_value)
DEFINE l_current_value STRING

    CALL fgl_zoom.init()
    CALL fgl_zoom.cancelvalue_set(l_current_value)
    CALL fgl_zoom.title_set("Select Country")
   
    CALL fgl_zoom.sql_set("select %2 FROM fgl_zoom_country WHERE %1 ORDER BY country_3letter")
        
    CALL fgl_zoom.gotolist_set(TRUE)
   
    CALL fgl_zoom.column_quick_set(1,"country_3letter","c",3,"Code")
    CALL fgl_zoom.column_quick_set(2,"country_name","c",30,"Name")
    CALL fgl_zoom.column_includeinresult_set(1,TRUE)
    CALL fgl_zoom.column_includeinresult_set(2,TRUE)

    RETURN fgl_zoom.call()
END FUNCTION



#+ show the source in each function
PRIVATE FUNCTION show_function_source(l_function)
DEFINE l_function STRING
DEFINE ch base.Channel
DEFINE l_line STRING
DEFINE sb base.StringBuffer
DEFINE l_read BOOLEAN

    LET l_read = FALSE
    
    LET sb = base.StringBuffer.create()
    LET ch = base.Channel.create()
    CALL ch.openFile("fgl_zoom_example.4gl","r")
    WHILE TRUE
        LET l_line = ch.readLine()
        IF ch.isEof() THEN
            EXIT WHILE
        END IF
        IF NOT l_read THEN
            IF l_line MATCHES  SFMT("*FUNCTION %1(*", l_function) THEN
                LET l_read = TRUE
            END IF
        END IF
        IF l_read THEN
            IF sb.getLength() > 0 THEN
                CALL sb.append("\n")
            END IF
            CALL sb.append(l_line)
        END IF
        IF l_read AND l_line = "END FUNCTION" THEN
            EXIT WHILE
        END IF
    END WHILE

    CALL FGL_WINMESSAGE("Info", sb.toString(),"")
END FUNCTION
        
    