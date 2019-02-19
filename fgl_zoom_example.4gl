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
    country_code CHAR(3),
    auto_code INTEGER,
    state_code_label CHAR(2)
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
DEFINE l_state_code CHAR(2)
DEFINE l_state_name CHAR(20)

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

            ON ACTION zoom INFIELD auto_code
                LET m_example.auto_code = zoom_auto(FGL_DIALOG_GETBUFFER())

            ON ACTION zoom INFIELD state_code_label
                CALL zoom_state_label() RETURNING l_state_code, l_state_name
                IF l_state_code IS NOT NULL THEN
                    LET m_example.state_code_label = l_state_code
                    DISPLAY l_state_name TO state_name_label
                END IF
                
              
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

            ON ACTION view_source INFIELD auto_code
                CALL show_function_source("zoom_auto")

            ON ACTION view_source INFIELD state_code_label
                CALL show_function_source("zoom_state_label")

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
DEFINE state_zoom fgl_zoom.zoomType

    CALL state_zoom.init()
    LET state_zoom.noqbe =TRUE
    LET state_zoom.cancelvalue = l_current_value
    LET state_zoom.title = "Select State"
    LET state_zoom.sql ="SELECT state_name, state_code FROM fgl_zoom_state ORDER BY state_name"
   
    CALL state_zoom.column[1].quick_set("state_name", FALSE, "c",20, "State")
   
    CALL state_zoom.column[2].quick_set("state_code", TRUE, "c", 0, "Code")
    LET state_zoom.column[2].excludelist = TRUE
   
    RETURN state_zoom.call()
END FUNCTION




#+ A simple zoom window to select the store code
PRIVATE FUNCTION zoom_store(l_current_value)
DEFINE l_current_value string
define store_zoom fgl_zoom.zoomType

    CALL store_zoom.init()
    LET store_zoom.cancelvalue = l_current_value
    LET store_zoom.title = "Select Store Code"
    LET store_zoom.sql = "SELECT %2 FROM fgl_zoom_store WHERE %1 ORDER BY store_num"
   
    CALL store_zoom.column[1].quick_set("store_num", true, "i", 4, "Number")
    CALL store_zoom.column[2].quick_set("store_name", false, "c", 20, "Name")
    CALL store_zoom.column[3].quick_set("addr", false,"c", 20, "Address 1")
    CALL store_zoom.column[4].quick_set("addr2", false, "c", 20, "Address 2")
    CALL store_zoom.column[5].quick_set("city",false, "c", 15, "City")
    CALL store_zoom.column[6].quick_set("state",false, "c", 2, "State")
    CALL store_zoom.column[7].quick_set("zipcode",false, "c", 5, "Zipcode")
    CALL store_zoom.column[8].quick_set("phone",false, "c", 18, "Phone")
   
    RETURN store_zoom.call()
END FUNCTION

 

#+ A slightly more complex zoom window to select the customer number
#+
#+ This example concatentates some of the fields together so that name, address 
#+ etc. are displayed as one column each.
PRIVATE FUNCTION zoom_customer(l_current_value)
DEFINE l_current_value string
define customer_zoom zoomType


    CALL customer_zoom.init()
    LET customer_zoom.cancelvalue =l_current_value
    LET customer_zoom.title ="Select Customer Code"
    LET customer_zoom.sql = "SELECT %2 FROM fgl_zoom_customer WHERE %1 ORDER BY customer_num"

    CALL customer_zoom.column[1].quick_set("customer_num", true, "i", 4, "Code")
    CALL customer_zoom.column[2].quick_set("(trim(lname) ||', '||trim(fname))", false, "c", 10, "Name")
    CALL customer_zoom.column[3].quick_set("company", false, "c", 10, "Company")
    CALL customer_zoom.column[4].quick_set("(trim(address1)||' '||trim(address2))", false, "c", 20, "Address")
    CALL customer_zoom.column[5].quick_set("city", false, "c", 10, "City")
    CALL customer_zoom.column[6].quick_set("state", false, "c", 5, "State")

    LET customer_zoom.freezeleft = 1
   
    RETURN customer_zoom.call()
    RETURN NULL
END FUNCTION


#+ A simple zoom window to select a country code.
PRIVATE FUNCTION zoom_country(l_current_value)
DEFINE l_current_value string
define country_zoom zoomType


    CALL country_zoom.init()
    LET country_zoom.cancelvalue = l_current_value
    LET country_zoom.title = "Select Country"
   
    LET country_zoom.sql = "select %2 FROM fgl_zoom_country WHERE %1 ORDER BY country_3letter"
        
    LET country_zoom.gotolist =TRUE
   
    CALL country_zoom.column[1].quick_set("country_3letter", true, "c",3,"Code")
    CALL country_zoom.column[2].quick_set("country_name", false, "c",30,"Name")

    RETURN country_zoom.call()
END FUNCTION



#+ A zoom window to select the state code
#+
#+ This example displays only the sname field and returns the state code
#+ It is ordered sname before code so that the visible sname column is used by 
#+ the goto functionality
PRIVATE FUNCTION zoom_auto(l_current_value)
DEFINE l_current_value STRING
DEFINE auto_zoom fgl_zoom.zoomType

    CALL auto_zoom.init()
    LET auto_zoom.noqbe =TRUE
    LET auto_zoom.cancelvalue = l_current_value
    LET auto_zoom.title = "Select Value"
    LET auto_zoom.sql ="SELECT id, desc, date_created, time_created, quantity, price FROM fgl_zoom_test WHERE %1 ORDER BY id"
    CALL auto_zoom.column_auto_set()
    
    RETURN auto_zoom.call()
END FUNCTION



#+ A zoom window to select the state code
#+
#+ This example displays only the sname field and returns the state code
#+ It is ordered sname before code so that the visible sname column is used by 
#+ the goto functionality
PRIVATE FUNCTION zoom_state_label()
DEFINE l_state_code CHAR(2)
DEFINE l_state_name CHAR(20)
define state_label_zoom zoomType

 
    CALL state_label_zoom.init()
    LET state_label_zoom.noqbe = TRUE
    LET state_label_zoom.title = "Select State"
    LET state_label_zoom.sql = "SELECT state_code, state_name FROM fgl_zoom_state ORDER BY state_name"
   
    CALL state_label_zoom.column[1].quick_set("state_code", true, "c",2, "Code")   
    CALL state_label_zoom.column[2].quick_set("state_name", true, "c", 20, "Name")

    CALL state_label_zoom.execute()
    IF state_label_zoom.ok() THEN
        LET l_state_code = state_label_zoom.result[1,1]
        LET l_state_name = state_label_zoom.result[1,2]
    END IF
    RETURN l_state_code, l_state_name

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







        
    