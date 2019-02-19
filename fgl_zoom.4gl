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
#       fgl_zoom.4gl
#
#       January 2011 Reuben Barclay reuben@4js.com.au

#+ A generic zoom window
#+
#+ Add multi-lines of detail about this 4gl including expected usage
#+

IMPORT FGL fgldialog

PUBLIC type zoomColumnType  RECORD
      columnname STRING,         -- SQL columnname used in where clause
      title STRING,              -- Column heading
      width INTEGER,             -- Number of characters width to display
      format STRING,             -- 4gl format string
      datatypec STRING,          -- c)haracter, d)ate, f)loat, i)integer
      justify STRING,            -- text alignment, left, center, right
      excludeqbe BOOLEAN,        -- TRUE if column is not displayed in QBE mode
      excludelist BOOLEAN,       -- TRUE if column is not displayed in List mode
      includeinresult BOOLEAN,   -- TRUE if column is to be included in return values
      qbedefault STRING,         -- Default setting to use for column in QBE
      qbeforce BOOLEAN           -- Set to TRUE if field must have QBE criteria entered
END RECORD

PUBLIC TYPE zoomType  RECORD             -- The parameters controlling the behaviour of the zoom window
    -- parameters, users will define
   sql STRING,                   -- SQL string
   title STRING,                 -- Title in zoom window
   cancelvalue STRING,           -- value to be returned if no values selected
   noqbe BOOLEAN,                -- TRUE if no QBE screen
   nolist BOOLEAN,               -- TRUE if no list screen
   gotolist BOOLEAN,             -- TRUE if go straight to list
   autoselect BOOLEAN,           -- if 1 value returned, return straight away
   multiplerow BOOLEAN,          -- TRUE if multiple row selection allowed
   maxrow INTEGER,               -- Maxmimum number of rows to return
   freezeleft INTEGER,           -- Number of columns to freeze from left
   freezeright INTEGER,          -- Number of columns to freeze from right
   qbeforce BOOLEAN,             -- Set to TRUE if at least one field must have some QBE criteria entered
   column DYNAMIC ARRAY of zoomColumnType,
   -- return values
   result DYNAMIC ARRAY WITH DIMENSION 2 OF STRING, -- The values selected by the user to return to the calling program
    -- All these I'd rather were private, or least not settable outside
   where STRING,                   -- The where clause constructed by the QBE
   mode STRING,                    -- list | qbe
   window ui.Window,                -- Current Window
   form ui.Form,                    -- Current Form
   table_node om.DomNode,           -- The node corresponding to the table
   fields DYNAMIC ARRAY OF RECORD    -- List of fields and datatypes that will be in the display array/constrcut
        name STRING,
        type STRING
    END RECORD,
    data DYNAMIC ARRAY WITH DIMENSION 2 OF STRING
END RECORD











#+ Set the exception handling
PRIVATE FUNCTION exception()
   WHENEVER ANY ERROR RAISE
END FUNCTION



#+ Return the version number
PRIVATE FUNCTION version()
   RETURN "3.10.00"
END FUNCTION



#+ Initialize module
#+
#+ Initialize module and get it ready so that it can be used again
#+ 
#+ @code
#+ CALL fgl_zoom.init()
#+
{
FUNCTION init()
   INITIALIZE m_zoom.* TO NULL
   LET m_zoom.noqbe = FALSE
   LET m_zoom.nolist = FALSE
   LET m_zoom.gotolist = FALSE
   LET m_zoom.autoselect = FALSE
   LET m_zoom.maxrow = 0
   LET m_zoom.freezeleft = 0
   LET m_zoom.freezeright = 0
   LET m_zoom.qbeforce = FALSE
   CALL m_zoom.column.clear()
   
   INITIALIZE m_where TO NULL
   CALL m_zoom.result.clear()

   CALL m_data.clear()
   CALL m_fields.clear()
END FUNCTION
}

FUNCTION (z zoomType) init()
    INITIALIZE z.* TO NULL
    LET z.noqbe  = FALSE
    LET z.nolist = FALSE
    LET z.gotolist = FALSE
    LET z.autoselect = FALSE
    LET z.maxrow = 0
    LET z.freezeleft = 0
    LET z.freezeright = 0
    LET z.qbeforce = FALSE
END FUNCTION
      


-- Setters

#+ Set the specified parameter
#+
#+ Set the specified parameter.  This is intended for use when values are 
#! saved away in a database or XML file, you can loop through the database 
#! values or file values, call this function and it will then call the intended
#! function.
#+ 
#+ @code
#+ CALL fgl_zoom.property_set("title", "Select Value")
#+ 
#+ @param l_property STRING The name of the fgl_zoom property.
#+ @param l_value STRING The value of the property
#+ 
FUNCTION (z zoomType) set(l_property STRING, l_value STRING) RETURNS (BOOLEAN)

   CASE  l_property.toLowerCase().trim()
      WHEN "sql" LET z.sql = l_value
      WHEN "title" LET z.title = l_value
      WHEN "cancelvalue" LET z.cancelvalue =  l_value
      WHEN "noqbe" LET z.noqbe =l_value
      WHEN "nolist" LET z.nolist = l_value
      WHEN "gotolist" LET z.gotolist = l_value
      WHEN "autoselect" LET z.autoselect = l_value
      WHEN "multiplerow" LET z.multiplerow = l_value
      WHEN "maxrow" LET z.maxrow = l_value
      WHEN "freezeleft" LET z.freezeleft = l_value
      WHEN "freezeright" LET z.freezeright = l_value
      WHEN "qbeforce" LET z.qbeforce = l_value
      OTHERWISE RETURN FALSE
   END CASE
   RETURN TRUE
END FUNCTION


 
#+ Quickly define a column in the zoom window
#+
#+ Allow the developer to quickly define a column in the zoom window with one 
#+ line of code.  It will only include the first column defined in the result
#+ set, and will right justify numerical data.
#+ 
#+ @code
#+ CALL column_quick_set(1,"tabid", "i", 4, "Table ID")
#+ 
#+ @param i INTEGER The index of the column (value=1 for the first column)
#+ @param l_column_name STRING The name of the column in the database
#+ @param l_datatypec CHAR(1) The datatype of the column, values are (c)har, (i)nteger, (f)loat, (d)ate
#+ @param l_width INTEGER The width of the column.  Use 0 to use a default value.
#+ @param l_title STRING The column heading
#+
FUNCTION  (zc zoomColumnType) quick_set(l_column_name STRING, l_includeinresult BOOLEAN, l_datatypec CHAR(1), l_width INTEGER, l_title STRING) 

   LET zc.columnname = l_column_name
   LET zc.title = l_title
   LET zc.datatypec = l_datatypec
   IF l_width > 0 THEN
      LET zc.width = l_width
   END IF
   LET zc.includeinresult = l_includeinresult
   IF l_datatypec MATCHES "[fi]" THEN
      LET zc.justify ="right"
   END IF
END FUNCTION



#+ Automatically define the columns based on the SQL parameter
#+
#+ Rather than explicitly defining each column, use this method to quickly
#+ define the columns based on the SQL parameter.  You can still override any
#+ column parameter after this function using the normal functions.
#+ 
#+ @code
#+ CALL column_auto_set()
#+
FUNCTION (z zoomType) column_auto_set()
DEFINE l_sqlh base.SqlHandle
DEFINE l_sql STRING
DEFINE i INTEGER
DEFINE l_name STRING
DEFINE l_datatype STRING
DEFINE l_datatypec CHAR(1)
DEFINE l_width INTEGER
DEFINE l_title string
define l_includeinresult BOOLEAN

    LET l_sqlh = base.SqlHandle.create()

    -- assumes SQL has been set, uses 1=0 to avoid returning rows
    LET l_sql = SFMT(z.sql, "1=0")
   
    LET l_sqlh = base.SqlHandle.create()
    CALL l_sqlh.prepare(l_sql)
    CALL l_sqlh.open()

    CALL l_sqlh.fetch()
    FOR i = 1 TO l_sqlh.getResultCount()
        LET l_name = l_sqlh.getResultName(i)       
        let l_includeinresult = (i==1)
        LET l_datatype = l_sqlh.getResultType(i)

        CALL datatype_to_columnparam(l_datatype) RETURNING l_datatypec, l_width
        CALL columnname_to_title(l_name) RETURNING l_title

        CALL z.column[i].quick_set(l_name, l_includeinresult, l_datatypec, l_width, l_title)
    END FOR
    CALL l_sqlh.close()
END FUNCTION



PRIVATE FUNCTION datatype_to_columnparam(l_datatype)
DEFINE l_datatype STRING

DEFINE l_datatypec CHAR(1)
DEFINE l_width INTEGER

DEFINE i INTEGER
DEFINE l_pos1, l_pos2, l_pos3 INTEGER 
DEFINE l_d1, l_d2 INTEGER
DEFINE l_part1, l_part2 STRING
DEFINE l_on BOOLEAN

    # TODO test all possibilities, refine width values
    CASE
        WHEN l_datatype = "TINYINT"
            LET l_datatypec = "i"
            LET l_width = 4
        WHEN l_datatype = "SMALLINT"
            LET l_datatypec = "i"
            LET l_width = 6
        WHEN l_datatype = "INTEGER"
            LET l_datatypec = "i"
            LET l_width = 11
        WHEN l_datatype = "BIGINT"
            LET l_datatypec = "i"
            LET l_width = 11
        WHEN l_datatype = "DATE"
            LET l_datatypec = "d"
            LET l_width = 10
        WHEN l_datatype MATCHES "DECIMAL*"
            LET l_datatypec = "f"
            LET l_pos1 = l_datatype.getIndexOf("(",1)
            IF l_pos1 > 0 THEN
                LET l_pos2 = l_datatype.getIndexOf(",",l_pos1)
                IF l_pos2 = 0 THEN
                    LET l_pos2 = l_datatype.getIndexOf(")", l_pos1)
                    LET l_d1 = l_datatype.subString(l_pos1+1, l_pos2-1)
                    LET l_width = l_d1 + 1
                ELSE
                    LET l_pos3 = l_datatype.getIndexOf(")", l_pos2)
                    LET l_d1 = l_datatype.subString(l_pos1+1, l_pos2-1)
                    LET l_d2 = l_datatype.subString(l_pos2+1, l_pos3-1)
                    LET l_width = l_d1 + l_d2 + 2
                END IF
            ELSE
                LET l_width = 10
            END IF
        WHEN l_datatype MATCHES "FLOAT"
            LET l_datatypec = "f"
            
            LET l_width = 15
        WHEN l_datatype MATCHES "DATETIME*" 
            LET l_datatypec = "c"
            LET l_pos1 = l_datatype.getIndexOf(" ", 1)
            LET l_pos2 = l_datatype.getIndexOf(" ",l_pos1+1)
            LET l_pos3 = l_datatype.getIndexOf(" ",l_pos2+1)
            IF l_pos3 > 0 THEN
                LET l_part1 = l_datatype.subString(l_pos1+1, l_pos2-1)
                LET l_part2 = l_datatype.subString(l_pos3+1, l_datatype.getLength())
                LET l_part1 = l_part1.toUpperCase()
                LET l_part2 = l_part2.toUpperCase()
                LET l_width = 0
                LET l_on = FALSE
                FOR i = 1 TO 7
                    CASE 
                        WHEN i = 1 AND l_part1 = "YEAR" LET l_on = TRUE
                        WHEN i = 2 AND l_part1 = "MONTH" LET l_on = TRUE
                        WHEN i = 3 AND l_part1 = "DAY" LET l_on = TRUE
                        WHEN i = 4 AND l_part1 = "HOUR" LET l_on = TRUE
                        WHEN i = 5 AND l_part1 = "MINUTE" LET l_on = TRUE
                        WHEN i = 6 AND l_part1 = "SECOND" LET l_on = TRUE
                        WHEN i = 7 AND l_part1 MATCHES "FRACTION*" LET l_on = TRUE 
                    END CASE

                    IF l_on THEN
                        CASE 
                            WHEN i = 1 -- Year has 4 characters + 1 for delimiter
                                LET l_width = l_width + 5
                            WHEN i = 7 -- Fraction has characters determined by arg
                                LET l_pos1 = l_part2.getIndexOf("(",1)
                                LET l_pos2 = l_part2.getIndexOf(")",l_pos1+1)
                                IF l_pos2 > 0 THEN
                                    LET l_d1 = l_part2.subString(l_pos1+1, l_pos2-1)
                                    LET l_width = l_width + l_d1 + 1
                                ELSE
                                    LET l_width = l_width + 3
                                END IF
                            OTHERWISE -- Month, Day, Hour, Minute, Second have 2 characters + 1 for delimiter
                                LET l_width = l_width + 3
                        END CASE
                    END IF
                    
                    CASE 
                        WHEN i = 1 AND l_part2 = "YEAR" LET l_on = FALSE
                        WHEN i = 2 AND l_part2 = "MONTH" LET l_on = FALSE
                        WHEN i = 3 AND l_part2 = "DAY" LET l_on = FALSE
                        WHEN i = 4 AND l_part2 = "HOUR" LET l_on = FALSE
                        WHEN i = 5 AND l_part2 = "MINUTE" LET l_on = FALSE
                        WHEN i = 6 AND l_part2 = "SECOND" LET l_on =  FALSE
                        WHEN i = 7 AND l_part2 MATCHES "FRACTION*" LET l_on = FALSE 
                    END CASE
                END FOR
                LET l_width = l_width - 1  # subtract 1 for unused delimitere
            ELSE
                LET l_width = 19
            END IF
        WHEN l_datatype MATCHES "*CHAR*"
            LET l_datatypec = "c"
            LET l_pos1 = l_datatype.getIndexOf("(",1)
            IF l_pos1 > 0 THEN
                LET l_pos2 = l_datatype.getIndexOf(")",l_pos1)
                LET l_width = l_datatype.subString(l_pos1+1, l_pos2-1)
            ELSE
                LET l_width = 1
            END IF
            
        OTHERWISE
            LET l_datatypec = "c"
            LET l_width = 15
    END CASE

    RETURN l_datatypec, l_width
END FUNCTION



PRIVATE FUNCTION columnname_to_title(l_name)
DEFINE l_name STRING

DEFINE sb base.StringBuffer
DEFINE l_upper BOOLEAN
DEFINE i INTEGER
DEFINE l_char STRING

    LET sb = base.StringBuffer.create()
    CALL sb.append(l_name)
    
    # replace _ with space e.g. state_code becaomes state code
    CALL sb.replace("_"," ",0)

    # where there is upper character already, insert a space e.g StateCode becomes State Code
    # TODO test this bit
    FOR i = 2 TO sb.getLength()
        IF sb.getCharAt(i) MATCHES "[A-Z]" AND sb.getCharAt(i-1) NOT MATCHES "[A-Z]" THEN
            CALL sb.insertAt(" ",i)
            LET i = i + 1
        END IF
    END FOR

    # where there is space, make upper the next character e.g. State code becomes State Code
    LET l_upper = TRUE
    FOR i = 1 TO sb.getLength()
        LET l_char = sb.getCharAt(i)
        IF l_upper THEN
            CALL sb.replaceAt(i,1,l_char.toUpperCase())
            LET l_upper = FALSE
        END IF
        IF l_char = " " THEN
            LET l_upper = TRUE
        END IF
    END FOR
    RETURN sb.toString()
END FUNCTION
      

      
-- Executors



#+ Execute the zoom window
#+
#+ The actual display of the zoom window.  
#+ Developer should've called fgl_zoom.init() and the setter functions
#+ prior to calling this function.  
#+ After this function, the developer should then call the getter functions
#+ to determine what the user has selected
#+ 
#+ @code
#+ CALL fgl_zoom.execute()
#+
FUNCTION (z zoomType) execute()
DEFINE ok BOOLEAN
DEFINE l_message STRING
DEFINE i INTEGER

    -- Clear int_flag, can't guarantee that calling program will have done this
    LET int_flag =FALSE

    CALL z.fields.clear()
    FOR i = 1 TO z.column.getLength()
        LET z.fields[i].name = z.column[i].columnname
        CASE z.column[i].datatypec
            WHEN "i" LET z.fields[i].type = "INTEGER"
            WHEN "d" LET z.fields[i].type = "DATE"
            WHEN "f" LET z.fields[i].type = "FLOAT"
            OTHERWISE LET z.fields[i].type = "STRING"
        END CASE
    END FOR

    CALL z.result.clear()

    -- Set defaults, lower case all parameters, allow aliases before we validate
    CALL z.normalise()
    CALL z.validate() RETURNING ok, l_message
    IF NOT ok THEN
        LET z.mode = "cancel"
        CALL FGL_WINMESSAGE(%"fgl_zoom.window.title.error", SFMT(%"fgl_zoom.validate.wrapper", l_message),"stop")
        RETURN
    END IF

    OPEN WINDOW fgl_zoom WITH 1 ROWS, 1 COLUMNS ATTRIBUTES(STYLE="fgl_zoom", TEXT=%"fgl_zoom.window.title")   
    LET z.window = ui.Window.getCurrent()
    CALL z.create_form()
   
    -- Determine the first screen
    -- Normally this will be the QBE unless we have said go direct to the list
    -- or don't allow entry of a QBE
    IF z.gotolist OR z.noqbe THEN
        LET z.mode = "list"
        LET z.where = "1=1"
    ELSE
        LET z.mode = "qbe"
    END IF
   
    WHILE (z.mode = "qbe" OR z.mode = "list")
        -- Exit if Impossible conditions occur
        IF z.mode = "qbe" AND z.noqbe THEN
            LET z.mode = "cancel"
        END IF
        IF z.mode = "list" AND z.nolist THEN
            LET z.mode = "cancel"
        END IF
        CALL z.show_hide_columns(z.mode)
        CASE z.mode
            WHEN "qbe" CALL z.qbe()
            WHEN "list" CALL z.list()
        END CASE
    END WHILE
    CLOSE WINDOW fgl_zoom
END FUNCTION



#+ Execute the zoom window and return the selected value.
#+
#+ Helper function for the case where the zoom window is used to return 1 value.
#+ The developer can make this call and get the selected value passed back
#+ rather than having to use a getter function to extract it.
#+ Note: take care when using this function to consider the case of what happens
#+ if the user cancels out of the zoom window.  Typically you would set the
#+ cancelvalue to be the current value in the field so that if the user selects
#+ cancel the value is unchanged.
#+ 
#+ @code
#+ ...
#+ CALL fgl_zoom.cancelvalue_set(FGL_DIALOG_GETBUFFER())
#+ CALL FGL_DIALOG_SETBUFFER(fgl_zoom.call())
#+ 
#+ @return l_return STRING The value selected by the user, or if the user cancelled, the value defined to return in that event
#+
FUNCTION (z zoomType) call() RETURNS STRING
DEFINE l_return STRING

    CALL z.execute()
    IF z.mode = "cancel" THEN
        LET l_return = z.cancelvalue
    ELSE
        LET l_return =  z.result[1,1]
    END IF
    RETURN l_return
END FUNCTION



-- Getters



#+ Returns a pipe delimited list of the selected values
#+
#+ Returns a pipe delimited list of the selected values.  This value is suitable
#+ for displaying to a field in a CONSTRUCT statement, or being used in a 
#+ MATCHES clause of an SQL statement
#+ 
#+ @code
#+ DEFINE value STRING
#+ ...
#+ CONSTRUCT ...
#+    
#+    ON ACTION zoom
#+       CALL fgl_zoom.execute()
#+       DISPLAY fgl_zoom.qbe_get() TO field
#+
#+ @return l_return Pipe delimilted list of values selected
#+
FUNCTION (z zoomType) qbe_get() RETURNS STRING
DEFINE sb base.stringbuffer
DEFINE i INTEGER
DEFINE l_return STRING

    LET sb = base.StringBuffer.create() 
    CALL sb.clear()
    FOR i = 1 TO z.result.getLength()
        IF i > 1 THEN
            CALL sb.append("|")
        END IF
        CALL sb.append(z.result[i,1] CLIPPED)
    END FOR
    LET l_return =  sb.toString()
    RETURN l_return
END FUNCTION   




#+ Indicate if the user accepted the final screen
#+
#+ Returns TRUE if the user accepted the last dialog, returns FALSE otherwise
#+ i.e user cancelled in last dialog
#+ A possible alternative is to test if fgl_zoom.result_length_get() > 0
#+
#+ @code
#+ CALL fgl_zoom.execute()
#+ IF fgl_zoom.ok() THEN
#+    # user accepted the zoom window
#+ ELSE
#+    # user cancelled the zoom window
#+ END IF
#+
#+ @return ok BOOLEAN TRUE if user accepted the last dialog, FALSE otherwise
FUNCTION (z zoomType) ok() RETURNS (BOOLEAN)
DEFINE ok BOOLEAN
    LET ok = (z.mode = "accept")
    RETURN ok
END FUNCTION



#+ A QBE of the data to display in the zoom window.
#+
#+ A CONSTRUCT that allows the user to do a QBE for the data that will be 
#+ displayed in the zoom window.  If the query has been defined with some
#+ QBE defaults then these are displayed in the field during the BEFORE CONSTRUCT
#+ 
PRIVATE FUNCTION (z zoomType) qbe()
DEFINE i INTEGER
DEFINE l_where_previous STRING
DEFINE l_restore_previous BOOLEAN
DEFINE l_columns_with_qbe_entered SMALLINT
DEFINE l_current_field_qbe STRING
DEFINE d_c ui.Dialog


    -- Clear the screen
    LET d_c = NULL
    CLEAR FORM

    LET l_where_previous = z.where
    LET l_restore_previous = FALSE
    LET z.where = NULL

    LET d_c = ui.Dialog.createConstructByName(z.fields)

    -- Add events
    CALL d_c.addTrigger("ON ACTION close")
    CALL d_c.addTrigger("ON ACTION list")
    CALL d_c.addTrigger("ON ACTION accept")

    WHILE TRUE
        CASE d_c.nextEvent()
            WHEN "BEFORE CONSTRUCT" 
                IF z.nolist THEN
                    -- Leave the accept text as OK
                ELSE
                    CALL d_c.setActionText("accept",  %"fgl_zoom.action.accept.text.alternate")
                END IF
                MESSAGE %"fgl_zoom.before_construct"
            
                FOR i = 1 TO z.column.getLength()
                    -- Display the default value, will have to figure out type as well
                    IF z.column[i].qbedefault IS NOT NULL THEN
                        CALL d_c.setFieldValue(z.column[i].columnname,z.column[i].qbedefault)
                    END IF
                END FOR
                  
            WHEN "ON ACTION close"
                LET z.mode = "cancel"
                EXIT WHILE
                
            WHEN "ON ACTION list"
                LET z.mode = "list"
                LET l_restore_previous = TRUE
                EXIT WHILE
                
            WHEN "ON ACTION accept"
                -- test qbeforce
                LET l_columns_with_qbe_entered = 0
                FOR i = 1 TO z.column.getLength()
                    IF z.qbeforce OR z.column[i].qbeforce THEN
                        IF d_c.getQueryFromField(z.column[i].columnname) IS NOT NULL THEN
                            IF z.qbeforce THEN
                                LET l_columns_with_qbe_entered = l_columns_with_qbe_entered + 1
                            END IF
                        ELSE
                            IF z.column[i].qbeforce  THEN
                                ERROR %"fgl_zoom.error.column.qbeforce"
                                CALL d_c.nextField(z.column[i].columnname) 
                                CONTINUE WHILE
                            END IF
                        END IF
                    END IF
                END FOR
                IF z.qbeforce AND l_columns_with_qbe_entered = 0 THEN
                    ERROR %"fgl_zoom.error.qbeforce"
                    CALL d_c.nextField(d_c.getCurrentItem())
                    CONTINUE WHILE
                END IF
      
                IF z.nolist THEN
                    LET z.mode = "accept"
                ELSE
                    LET z.mode = "list"
                END IF
                
                -- Create SQL clause
                LET z.where = NULL
                FOR i = 1 TO z.fields.getLength()
                    LET l_current_field_qbe = d_c.getQueryFromField(z.column[i].columnname)
                    IF l_current_field_qbe IS NOT NULL THEN
                        IF z.where IS NULL THEN
                            LET z.where = l_current_field_qbe
                        ELSE
                            LET z.where = z.where," AND ", l_current_field_qbe
                        END IF
                    END IF
                END FOR
                IF z.where IS NULL THEN
                    LET z.where = "1=1"
                END IF
                EXIT WHILE
        END CASE
    END WHILE

    LET d_c = NULL

    -- set the where clause back to what it was previously
    IF l_restore_previous THEN
        IF l_where_previous IS NULL THEN
            LET z.where = "1=1"
        ELSE
            LET z.where = l_where_previous
        END IF
    END IF
END FUNCTION



#+ A DISPLAY ARRAY of the selected data allowing the user to select a row
#+
#+ A DISPLAY ARRAY of the selected data allowing the user to select a row.  Will
#+ not do the DISPLAY ARRAY if 0 rows found, if auto-select is enabled and only
#+ one row is found.  Will allow the user to navigate through the data using
#+ Find and Goto if these are enabled.  Will allow the user to select rows
#+ and paste them into clipboard or drag elsewhere
#+ 
PRIVATE FUNCTION (z zoomType) list()
DEFINE i INTEGER
DEFINE l_sql STRING
--DEFINE dnd ui.DragDrop
DEFINE ok INTEGER
DEFINE l_selected DYNAMIC ARRAY OF BOOLEAN
DEFINE l_maxrow_flg BOOLEAN

DEFINE l_datatocopy STRING

DEFINE l_sqlh base.SqlHandle
DEFINE l_row_count INTEGER
DEFINE l_row, l_column INTEGER

DEFINE d_da ui.Dialog
DEFINE l_event STRING

    LET d_da = NULL
    CALL z.data.clear()

    LET l_sql = SFMT(z.sql, z.where, z.columnlist_get())
   
    LET l_sqlh = base.SqlHandle.create()
    CALL l_sqlh.prepare(l_sql)
    CALL l_sqlh.open()

    LET l_maxrow_flg = FALSE
    LET l_row_count = 0
    WHILE TRUE
        CALL l_sqlh.fetch()
        IF SQLCA.SQLCODE=NOTFOUND THEN
            EXIT WHILE
        END IF
        LET l_row_count = l_row_count + 1

        IF z.maxrow > 0 THEN
            IF l_row_count > z.maxrow THEN
                LET l_maxrow_flg = TRUE
                EXIT WHILE
            END IF
        END IF

        FOR l_column = 1 TO l_sqlh.getResultCount()
            LET z.data[l_row_count, l_column] = l_sqlh.getResultValue(l_column)
        END FOR
    END WHILE
    CALL l_sqlh.close()

    CASE
        WHEN l_row_count = 0
            CALL FGL_WINMESSAGE(%"fgl_zoom.window.title.zoom", %"fgl_zoom.no_records_found", "stop")
            -- no records to display
            IF z.noqbe THEN
                LET z.mode = "cancel"
            ELSE
                LET z.mode = "qbe"
            END IF
        WHEN l_row_count = 1 AND z.autoselect 
            CALL z.add_row_to_result(1)
            LET z.mode = "accept"
        OTHERWISE
            LET d_da = ui.Dialog.createDisplayArrayTo(z.fields, "data")
            CALL d_da.addTrigger("ON ACTION copy")
            CALL d_da.addTrigger("ON ACTION copyall")
            CALL d_da.addTrigger("ON ACTION qbe")
            CALL d_da.addTrigger("ON ACTION selectnone")
            CALL d_da.addTrigger("ON ACTION selectall")    
            CALL d_da.addTrigger("ON ACTION print")

            CALL d_da.addTrigger("ON ACTION accept")
            CALL d_da.addTrigger("ON ACTION cancel")
            CALL d_da.addTrigger("ON ACTION close")

            FOR l_row  = 1 TO l_row_count
                CALL d_da.setCurrentRow("data", l_row)
                FOR l_column = 1 TO l_sqlh.getResultCount()
                    CALL d_da.setFieldValue(z.fields[l_column].name, z.data[l_row, l_column] )
                END FOR
            END FOR
            CALL d_da.setCurrentRow("data",1)

             WHILE TRUE
                LET l_event = d_da.nextEvent()
                CASE l_event
                    WHEN "BEFORE DISPLAY"
                        CALL d_da.setActionActive("accept", l_row_count > 0)
                        CALL d_da.setActionActive("qbe", NOT z.noqbe)
                        CALL d_da.setSelectionMode("data", z.multiplerow)
                        CALL d_da.setActionActive("selectall", z.multiplerow)
                        CALL d_da.setActionActive("selectnone", z.multiplerow)

                        IF l_maxrow_flg THEN
                            CALL FGL_WINMESSAGE(%"fgl_zoom.window.title.zoom", SFMT(%"fgl_zoom.max_rows_hit",z.maxrow), "info")
                        END IF
                    WHEN "BEFORE ROW"
                        MESSAGE SFMT(%"fgl_zoom.x_of_y", d_da.getCurrentRow("data"), l_row_count)
                        
                    #ON DRAG_START (dnd)
                        #CALL dnd.setOperation("copy")
                        
                    WHEN "ON ACTION copy"
                        CALL ui.Interface.frontCall("standard","cbset",d_da.selectionToString("data"),ok)
                        
                    WHEN "ON ACTION copyall"
                        -- if selectionmode=1 have to store away current values and reset
                        IF z.multiplerow THEN
                            -- save away current selected rows
                            CALL l_selected.clear()
                            FOR i = 1 TO l_row_count
                                LET l_selected[i] = d_da.isRowSelected("data",i)
                            END FOR
                        ELSE
                            CALL d_da.setSelectionMode("data",1)
                        END IF
                        CALL d_da.setSelectionRange("data",1,-1,1)
                        LET l_datatocopy =  d_da.selectionToString("data")

                        CALL ui.Interface.frontCall("standard","cbset",l_datatocopy,ok)
                        
                        CALL d_da.setSelectionRange("data",1,-1,0)
                        IF z.multiplerow THEN
                            -- restore previously selected rows
                            FOR i = 1 TO l_row_count
                                CALL d_da.setSelectionRange("data",i,i,l_selected[i])
                            END FOR
                        ELSE
                            CALL d_da.setSelectionMode("data",0)
                        END IF

                    WHEN "ON ACTION print"
                        CALL z.print()

                    WHEN "ON ACTION selectnone"
                        CALL d_da.setSelectionRange("data",1,l_row_count, FALSE)
               
                    WHEN "ON ACTION selectall"
                        CALL d_da.setSelectionRange("data",1,l_row_count, TRUE)

                    WHEN "ON ACTION cancel"
                        LET z.mode = "cancel"
                        EXIT WHILE

                    WHEN "ON ACTION qbe"
                        LET z.mode = "qbe"
                        EXIT WHILE
           
                    WHEN "ON ACTION close"
                        LET z.mode = "cancel"
                        EXIT WHILE

                    WHEN "ON ACTION data.accept" -- need this due to event sent on double click
                        GOTO lbl_accept
                    WHEN "ON ACTION accept"
                        LABEL lbl_accept:
                        IF z.mode = "list" THEN
                            IF z.multiplerow THEN
                                FOR l_row = 1 TO l_row_count
                                    IF d_da.isRowselected("data",l_row) THEN
                                        CALL z.add_row_to_result(l_row)
                                    END IF
                                END FOR
                            ELSE
                                CALL z.add_row_to_result(arr_curr())
                            END IF
                        END IF
                        LET z.mode = "accept"
                        EXIT WHILE
                    WHEN "AFTER ROW"
                        -- do nothing
                    OTHERWISE   
                        DISPLAY "Event not handled ", l_event
                END CASE
            END WHILE
    END CASE

    LET d_da = NULL
END FUNCTION


#+ Add passed in row to the list of selected rows
PRIVATE FUNCTION (z zoomType) add_row_to_result(l_row INTEGER)
DEFINE i,j,k INTEGER

   LET i = z.result.getLength() + 1
   LET k = 0
   FOR j = 1 TO z.column.getLength()
      IF z.column[j].includeinresult THEN
         LET k = k + 1
         LET z.result[i,k] = z.data[l_row,j]
      END IF
   END FOR
END FUNCTION



#+ Setup the columns to hide/show columns
PRIVATE FUNCTION  (z zoomType) show_hide_columns(l_mode STRING)
DEFINE i INTEGER
DEFINE l_hidden BOOLEAN

    FOR i =1 TO z.column.getLength()
        LET l_hidden = FALSE
        IF NOT l_hidden AND l_mode = "qbe" AND z.column[i].excludeqbe THEN
            LET l_hidden = TRUE
        END IF
        IF NOT l_hidden AND l_mode = "list" AND z.column[i].excludelist THEN
            LET l_hidden = TRUE
        END IF
        CALL z.form.setFieldHidden(z.column[i].columnname, l_hidden )
    END FOR
END FUNCTION



#+ Normalise the parameters input 
PRIVATE FUNCTION (z zoomType) normalise()
DEFINE i INTEGER

   LET z.sql = z.sql.trim()
   
   IF z.noqbe IS NULL THEN
      LET z.noqbe = FALSE
   END IF
   IF z.nolist IS NULL THEN
      LET z.nolist = FALSE
   END IF
   IF z.gotolist IS NULL THEN
      LET z.gotolist = FALSE
   END IF
   IF z.autoselect IS NULL THEN
      LET z.autoselect = FALSE
   END IF
   IF z.multiplerow IS NULL THEN
      LET z.multiplerow = FALSE
   END IF
   IF z.maxrow IS NULL THEN
      LET z.maxrow = 0
   END IF
   IF z.freezeleft IS NULL THEN
      LET z.freezeleft = 0
   END IF
   IF z.freezeright IS NULL THEN
      LET z.freezeright = 0
   END IF
  
   FOR i = 1 TO z.column.getLength()
      LET z.column[i].columnname = z.column[i].columnname.trim()

      -- Default column width to 10 if not set
      IF z.column[i].width IS NULL THEN
         LET z.column[i].width = 10
      END IF  
      
      LET z.column[i].datatypec = z.column[i].datatypec.toLowerCase()
      -- don't have a default, force developer to specify datatype
      -- allow these aliases
      CASE 
         WHEN z.column[i].datatypec MATCHES "char*" LET z.column[i].datatypec = "c"
         WHEN z.column[i].datatypec = "string" LET z.column[i].datatypec = "c"
         WHEN z.column[i].datatypec MATCHES "datetime*" LET z.column[i].datatypec = "c"
         WHEN z.column[i].datatypec MATCHES "interval*" LET z.column[i].datatypec = "c"

         WHEN z.column[i].datatypec = "tinyint" LET z.column[i].datatypec = "i"
         WHEN z.column[i].datatypec = "smallint" LET z.column[i].datatypec = "i"
         WHEN z.column[i].datatypec = "integer" LET z.column[i].datatypec = "i"
         WHEN z.column[i].datatypec = "bigint" LET z.column[i].datatypec = "i"
         WHEN z.column[i].datatypec MATCHES "decimal*0)" LET z.column[i].datatypec = "i"

         WHEN z.column[i].datatypec matches "decimal*" LET z.column[i].datatypec = "f"
         WHEN z.column[i].datatypec matches "float*" LET z.column[i].datatypec = "f"
         WHEN z.column[i].datatypec matches "money*" LET z.column[i].datatypec = "f"

         WHEN z.column[i].datatypec = "date" LET z.column[i].datatypec = "d"
      END CASE

      LET z.column[i].justify = z.column[i].justify.toLowerCase()
      -- Default justification is left
      IF z.column[i].justify.getLength() = 0 THEN
         LET z.column[i].justify = "left"
      END IF
      -- allow these aliases
      CASE z.column[i].justify 
         WHEN "l" LET z.column[i].justify = "left"
         WHEN "c" LET z.column[i].justify = "center"
         WHEN "r" LET z.column[i].justify = "right"
         WHEN "centre" LET z.column[i].justify = "center"
      END CASE
      
      IF z.column[i].excludeqbe IS NULL THEN
         LET z.column[i].excludeqbe = FALSE
      END IF
      
      IF z.column[i].excludelist IS NULL THEN
         LET z.column[i].excludelist = FALSE
      END IF
      
      IF z.column[i].includeinresult IS NULL THEN
         LET z.column[i].includeinresult = FALSE
      END IF

      IF z.column[i].qbeforce IS NULL THEN
         LET z.column[i].qbeforce = FALSE
      END IF
   END FOR  
   
END FUNCTION


#+ Test that the parameters passed in are OK
PRIVATE FUNCTION (z zoomType) validate() RETURNS (BOOLEAN, STRING)
DEFINE i INTEGER

   IF z.sql.getlength() > 0 THEN
      #OK
   ELSE
      RETURN FALSE, %"fgl_zoom.validate.sql_must_be_defined"
   END IF
   
   IF z.maxrow < 0 THEN
      RETURN FALSE, %"fgl_zoom.validate.max_row_must_be_positive"
   END IF

   IF z.freezeleft < 0 OR z.freezeleft > 8 THEN
      RETURN FALSE, %"fgl_zoom.validate.freezeleft_range"
   END IF

   IF z.freezeright < 0 OR z.freezeright > 8 THEN
      RETURN FALSE, %"fgl_zoom.validate.freezeright_range"
   END IF

   IF z.column.getLength() = 0 THEN
      RETURN FALSE, %"fgl_zoom.validate.column_defined_min"
   END IF
   IF z.column.getLength() > 9 THEN
      RETURN FALSE, %"fgl_zoom.validate.column_defined_max"
   END IF
   
   FOR i = 1 TO z.column.getLength()
      IF z.column[i].columnname.getLength() > 0 THEN
         #OK
      ELSE
         RETURN FALSE, SFMT(%"fgl_zoom.validate.column_X_defined",i)
      END IF

      IF z.column[i].width < 1 THEN
         RETURN FALSE, SFMT(%"fgl_zoom.validate.column_X_width_valid", i)
      END IF
      
      IF z.column[i].datatypec.getCharAt(1) MATCHES "[cdfi]" THEN
         #OK
      ELSE
         RETURN FALSE, SFMT(%"fgl_zoom.validate.column_X_datatype_valid",i)
      END IF

      CASE z.column[i].justify 
         WHEN "left"
         WHEN "center"
         WHEN "right"
         OTHERWISE
            RETURN FALSE, SFMT(%"fgl_zoom.validate.column_X_justify_valid",i)
      END CASE
   END FOR  
   
   RETURN TRUE,""
END FUNCTION






#+ 1 line summary if function
#+
#+ Multi-line description
#+ 
#+ @code
#+ Code Example with param and return defined
#+ 
#+ @param param1 Description
#+
#+ @return return1 Return parameter
#+
PRIVATE FUNCTION (z zoomType) columnlist_get() RETURNS (STRING)
DEFINE i INTEGER
DEFINE l_sb base.StringBuffer

    LET l_sb = base.StringBuffer.create()
    CALL l_sb.append(z.column[1].columnname)
    FOR i = 2 TO z.column.getLength()
        CALL l_sb.append(",")
        CALL l_sb.append(z.column[i].columnname)
    END FOR
    RETURN l_sb.toString()
END FUNCTION



#+ Append to the style a style to freeze columns
PRIVATE FUNCTION (z zoomType) append_freeze_style()
DEFINE l_style STRING

   IF z.freezeleft > 0 AND z.freezeleft <=8 THEN
      LET l_style= z.table_node.getAttribute("style")
      LET l_style= l_style.append(SFMT(" fgl_zoom_leftfreeze%1", z.freezeleft USING "&"))
      CALL z.table_node.setAttribute("style", l_style)
   END IF
   IF z.freezeright > 0 AND z.freezeright <=8 THEN
      LET l_style= z.table_node.getAttribute("style")
      LET l_style= l_style.append(SFMT(" fgl_zoom_rightfreeze%1", (9-z.column.getLength()+z.freezeright) USING "&"))
      CALL z.table_node.setAttribute("style", l_style)
   END IF
END FUNCTION


        
PRIVATE FUNCTION (z zoomType) print()
--DEFINE grw om.saxDocumentHandler
--DEFINE i INTEGER

    #TODO check this now generic fields in use
    CALL FGL_WINMESSAGE("Info","Not implemented yet","stop")
    RETURN
 {
   IF fgl_report_loadCurrentSettings("") THEN
      CALL fgl_report_setCallbackLocalization(TRUE)
      CALL fgl_report_setAutoformatType("FLAT LIST")
      CALL fgl_report_configureAutoformatOutput(NULL,8,NULL,m_zoom.title, create_report_field_string(),NULL)
      CALL fgl_report_configurePageSize("a4length","a4width")
      CALL fgl_report_configureXLSDevice(NULL,NULL,FALSE,NULL,NULL,NULL,TRUE) #preserve spaces and merge pages in XLS output
      CALL fgl_report_setTitle(m_zoom.title)

      CALL fgl_report_selectDevice("SVG")
      CALL fgl_report_selectPreview(TRUE)

      LET grw = fgl_report_commitCurrentSettings()

      START REPORT zoom_rpt TO XML HANDLER grw
      FOR i = 1 TO m_data.getLength()
         OUTPUT TO REPORT zoom_rpt(i)
      END FOR
      FINISH REPORT zoom_rpt
   END IF
   }
END FUNCTION


{
REPORT zoom_rpt(l_row)
DEFINE l_row INTEGER
DEFINE l_column INTEGER

FORMAT

ON EVERY ROW
    #PRINTX m_data[l_row].*
    FOR l_column = 1 TO m_data[l_row].getLength()
        PRINTX m_data[l_row,l_column];
    END FOR
    PRINT
END REPORT

FUNCTION report_getFieldCaption(matchName,fieldName)
DEFINE matchName, fieldName STRING

   CASE 
    -- TODO this code is wrong now I'm using dynamic dialog
      WHEN fieldName MATCHES "*field1*" RETURN m_zoom.column[1].title
      WHEN fieldName MATCHES "*field2*" RETURN m_zoom.column[2].title
      WHEN fieldName MATCHES "*field3*" RETURN m_zoom.column[3].title
      WHEN fieldName MATCHES "*field4*" RETURN m_zoom.column[4].title
      WHEN fieldName MATCHES "*field5*" RETURN m_zoom.column[5].title
      WHEN fieldName MATCHES "*field6*" RETURN m_zoom.column[6].title
      WHEN fieldName MATCHES "*field7*" RETURN m_zoom.column[7].title
      WHEN fieldName MATCHES "*field8*" RETURN m_zoom.column[8].title
      WHEN fieldName MATCHES "*field9*" RETURN m_zoom.column[9].title
      OTHERWISE
         RETURN fieldName
   END CASE
END FUNCTION

PRIVATE FUNCTION create_report_field_string()
DEFINE sb base.StringBuffer
DEFINE i INTEGER
DEFINE first BOOLEAN

   LET first = TRUE

   LET sb = base.StringBuffer.create()
   FOR i = 1 TO 9
      IF m_zoom.column[i].datatypec MATCHES "[cdfi]" AND NOT m_zoom.column[i].excludelist THEN
         IF NOT first THEN
            CALL sb.append(",")
         END IF
         LET first = FALSE
         CALL sb.append(SFMT("m_data.field%1%2", i USING "<", m_zoom.column[i].datatypec))
      END IF
   END FOR
   RETURN sb.toString()
END FUNCTION

}





PRIVATE FUNCTION (z zoomType) create_form()
DEFINE form_node, vbox_node, table_node, tablecolumn_node, widget_node, recordview_node, link_node om.DomNode
DEFINE i INTEGER

    -- create form in memory
    LET z.form = z.window.createForm("fgl_zoom")
    LET form_node = z.form.getNode()
    
    CALL form_node.setAttribute("width",10*z.column.getLength()+2)
    CALL form_node.setAttribute("height","16")

    LET vbox_node = form_node.createChild("VBox")
    CALL vbox_node.setAttribute("name","vbox")

    -- Create table node
    LET table_node = vbox_node.createChild("Table")
    CALL table_node.setAttribute("pageSize",15)
    CALL table_node.setAttribute("name","tablist")
    CALL table_node.setAttribute("style", "fgl_zoom")
    CALL table_node.setAttribute("height", "15ln")
    CALL table_node.setAttribute("tabName", "data")
    CALL table_node.setAttribute("doubleClick", "accept")
    
    -- TableColumn nodes
    FOR i = 1 TO z.column.getLength()
       
       LET tablecolumn_node = table_node.createChild("TableColumn")
       
       CALL tablecolumn_node.setAttribute("name",SFMT("formonly.%1", z.column[i].columnname))  #TODO
       CALL tablecolumn_node.setAttribute("sqlTabName","formonly")
       CALL tablecolumn_node.setAttribute("colName",z.column[i].columnname)  #TODO
       CALL tablecolumn_node.setAttribute("fieldId",(i-1) USING "<&")

       CALL tablecolumn_node.setAttribute("tabIndex", i USING "&")

       CASE z.column[i].datatypec 
           WHEN "c"
               CALL tablecolumn_node.setAttribute("sqlType", "VARCHAR")
               CALL tablecolumn_node.setAttribute("numAlign", "0")
           WHEN "d"
               CALL tablecolumn_node.setAttribute("sqlType", "DATE")
               CALL tablecolumn_node.setAttribute("numAlign", "0")
           WHEN "f"
               CALL tablecolumn_node.setAttribute("sqlType", "DECIMAL")
               CALL tablecolumn_node.setAttribute("numAlign", "1")
           WHEN "i"
               CALL tablecolumn_node.setAttribute("sqlType", "INTEGER")
               CALL tablecolumn_node.setAttribute("numAlign", "1")
       END CASE
    
       CALL tablecolumn_node.setAttribute("text", z.column[i].title)

       LET widget_node = tablecolumn_node.createChild("Edit")
       CALL widget_node.setAttribute("width",z.column[i].width)

       IF z.column[i].format IS NOT NULL THEN
           CALL widget_node.setAttribute("format", z.column[i].format)
       END IF
       
       IF z.column[i].justify IS NOT NULL THEN
           CALL widget_node.setAttribute("justify", z.column[i].justify)
       END IF
    END FOR

    -- Create record view
    LET recordview_node = form_node.createChild("RecordView")
    CALL recordview_node.setAttribute("tabName","formonly")

    -- Link nodes
    FOR i = 1 TO z.column.getLength()
        LET link_node = recordview_node.createChild("Link")
        CALL link_node.setAttribute("colName",z.column[i].columnname)
        CALL link_node.setAttribute("fieldIdRef",(i-1) USING "<&")
    END FOR
   
    CALL z.form.loadActionDefaults("fgl_zoom.4ad")
    CALL z.form.loadToolBar("fgl_zoom.4tb")
    CALL z.window.settext(z.title)
    LET z.table_node = z.form.findNode("Table","tablist")
    CALL z.append_freeze_style()
END FUNCTION



PRIVATE FUNCTION (z zoomType) init_fields()
DEFINE i INTEGER

    CALL z.fields.clear()
    FOR i = 1 TO z.column.getLength()
        LET z.fields[i].name = z.column[i].columnname
        -- TODO consider removing one character shortcut and force use of full datatype name
        CASE z.column[i].datatypec
            WHEN "i" LET z.fields[i].type = "INTEGER"
            WHEN "d" LET z.fields[i].type = "DATE"
            WHEN "f" LET z.fields[i].type = "FLOAT"
            OTHERWISE LET z.fields[i].type = "STRING"
        END CASE
    END FOR
END FUNCTION