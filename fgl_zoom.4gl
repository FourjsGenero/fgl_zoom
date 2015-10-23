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
IMPORT xml

DEFINE m_zoom RECORD             -- The parameters controlling the behaviour of the zoom window
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
   column DYNAMIC ARRAY OF RECORD
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
END RECORD

DEFINE m_zoom_result DYNAMIC ARRAY WITH DIMENSION 2 OF STRING -- The values selected by the user to return to the calling program

-- List of fields and datatypes that will be in the display array/constrcut
DEFINE m_fields DYNAMIC ARRAY OF RECORD
    name STRING,
    type STRING
END RECORD

DEFINE m_data DYNAMIC ARRAY WITH DIMENSION 2 OF STRING

DEFINE m_where STRING    -- The where clause constructed by the QBE
DEFINE m_mode STRING     -- list | qbe

DEFINE m_window ui.Window       -- Current window
DEFINE m_form ui.Form           -- Current form
DEFINE m_table_node om.DomNode       -- The node corresponding to the table



#+ Set the exception handling
PRIVATE FUNCTION exception()
   WHENEVER ANY ERROR RAISE
END FUNCTION



#+ Return the version number
PRIVATE FUNCTION version()
   RETURN "3.00.00"
END FUNCTION



#+ Initialize module
#+
#+ Initialize module and get it ready so that it can be used again
#+ 
#+ @code
#+ CALL fgl_zoom.init()
#+
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
   CALL m_zoom_result.clear()

   CALL m_data.clear()
   CALL m_fields.clear()
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
FUNCTION property_set(l_property, l_value)
DEFINE l_property STRING
DEFINE l_value STRING

   LET l_property = l_property.toLowerCase()
   LET l_property = l_property.trim()
   CASE l_property
      WHEN "sql" CALL sql_set(l_value)
      WHEN "title" CALL title_set(l_value)
      WHEN "cancelvalue" CALL cancelvalue_set(l_value)
      WHEN "noqbe" CALL noqbe_set(l_value)
      WHEN "nolist" CALL nolist_set(l_value)
      WHEN "gotolist" CALL gotolist_set(l_value)
      WHEN "autoselect" CALL autoselect_set(l_value)
      WHEN "multiplerow" CALL multiplerow_set(l_value)
      WHEN "maxrow" CALL maxrow_set(l_value)
      WHEN "freezeleft" CALL freezeleft_set(l_value)
      WHEN "freezeright" CALL freezeright_set(l_value)
      WHEN "qbeforce" CALL qbeforce_set(l_value)
      OTHERWISE RETURN FALSE
   END CASE
   RETURN TRUE
END FUNCTION



#+ Set the specified column parameter
#+
#+ Set the specified column parameter.  This is intended for use when values are 
#! saved away in a database or XML file, you can loop through the database 
#! values or file values, call this function and it will then call the intended
#! function.
#+ 
#+ @code
#+ CALL fgl_zoom.property_column_set("title", 1, "Description")
#+ 
#+ @param l_property STRING The name of the fgl_zoom property.
#+ @param i INTEGER The column index
#+ @param l_value STRING The value of the property
#+ 
FUNCTION property_column_set(l_property, i, l_value)
DEFINE l_property STRING
DEFINE i INTEGER
DEFINE l_value STRING

   LET l_property = l_property.toLowerCase()
   LET l_property = l_property.trim()
   IF i < 1 THEN
      RETURN FALSE
   END IF
   CASE l_property
      WHEN "columnname" CALL column_columnname_set(i, l_value)
      WHEN "title" CALL column_title_set(i, l_value)
      WHEN "width" CALL column_width_set(i, l_value)
      WHEN "format" CALL column_format_set(i, l_value)
      WHEN "datatypec" CALL column_datatypec_set(i, l_value)
      WHEN "justify" CALL column_justify_set(i, l_value)
      WHEN "excludeqbe" CALL column_excludeqbe_set(i, l_value)
      WHEN "excludelist" CALL column_excludelist_set(i, l_value)
      WHEN "includeinresult" CALL column_includeinresult_set(i, l_value)
      WHEN "qbedefault" CALL column_qbedefault_set(i, l_value)
      WHEN "qbeforce" CALL column_qbeforce_set(i, l_value)
      OTHERWISE RETURN FALSE
   END CASE
   RETURN TRUE
END FUNCTION



#+ Set the sql parameter
#+
#+ Set the sql parameter.  This is the SQL that will be executed to populate 
#+ the zoom window.  The SQL clause can have two special placeholders, %1 and %2
#+ that will be replaced before the SQL statement is executed.
#+
#+ %1 is where the result of the QBE will be populated, so most SQL's will have
#+ WHERE %1.  This will typically only vary for sub-queries, unions, or where
#+ you add your own filter to the SQL statement
#+
#+ %2 allows you to not have to list the columns but simply rely on the column
#+ definitions defined by the columnset methods
#+ SELECT %2 FROM systables WHERE %1
#+ 
#+ @code
#+ CALL fgl_zoom.sql_set("SELECT tabid, tabname FROM systables WHERE %1")
#+ or
#+ CALL fgl_zoom.sql_set("SELECT %2 FROM systables WHERE %1")
#+ 
#+ @param l_sql STRING The SQL to be used to populate the zoom window
#+
FUNCTION sql_set(l_sql)
DEFINE l_sql STRING

   LET m_zoom.sql = l_sql
END FUNCTION



#+ Set the title parameter
#+
#+ Set the title parameter.  This is used in the title of the zoom window
#+ 
#+ @code
#+ CALL fgl_zoom.title_set("Select Value")
#+ 
#+ @param l_title STRING The string used as the title of the zoom window.
#+
FUNCTION title_set(l_title)
DEFINE l_title STRING

   LET m_zoom.title = l_title
END FUNCTION



#+ Set the cancelvalue parameter
#+
#+ Set the cancelvalue parameter.  Used as the return value if the user selects
#+ cancel or close in the zoom window.  THis will tpyically be set to the
#+ current value of the field.
#+ 
#+ @code
#+ CALL fgl_zoom.cancelvalue_set(FGL_DIALOG_GETBUFFER())
#+ 
#+ @param l_cancelvalue STRING The value to return if the user selects cancel
#+
FUNCTION cancelvalue_set(l_cancelvalue)
DEFINE l_cancelvalue STRING

   LET m_zoom.cancelvalue = l_cancelvalue
END FUNCTION



#+ Set the noqbe parameter
#+
#+ Set the noqbe parameter.  Indicates if the zoom window will have a QBE window
#+ Typically you would set this value to TRUE if you knew the maximum number
#+ of values returned will be small, otherwise the default is FALSE
#+ Note: this is distinct from the gotolist parameter which controls which 
#+ window is first displayed.
#+ If this function is not called, the value is set to FALSE
#+ 
#+ @code
#+ CALL fgl_zoom.noqbe_set(TRUE)
#+ 
#+ @param l_noqbe BOOLEAN TRUE if we are not going to have a QBE window, FALSE otherwise
#+
FUNCTION noqbe_set(l_noqbe)
DEFINE l_noqbe BOOLEAN

   LET m_zoom.noqbe = l_noqbe
END FUNCTION



#+ Set the nolist parameter
#+
#+ Set the nolist parameter.  Indicates if the zoom window will have a List 
#+ window. Typically you would set this value to TRUE if you only wanted to 
#+ return a WHERE clause, otherwise the default is FALSE
#+ If this function is not called, the value is set to FALSE
#+ 
#+ @code
#+ CALL fgl_zoom.nolist_set(TRUE)
#+ 
#+ @param l_nolist BOOLEAN TRUE if we are not going to have a list window, FALSE otherwise
#+
FUNCTION nolist_set(l_nolist)
DEFINE l_nolist BOOLEAN

   LET m_zoom.nolist = l_nolist
END FUNCTION



#+ Set the gotolist parameter
#+
#+ Set the gotolist parameter.  Indicates if the QBE or List window will be
#+ displayed first.  A value of TRUE will result in the List window being 
#+ displayed first, otherwise if FALSE the QBE window will be displayed first.
#+ Typically you would set this value to TRUE if you knew the maximum number of 
#+ values displayed was small and you could allow the user to view the entire 
#+ list.
#+ If this function is not called, the value is set to FALSE and the QBE window
#+ is displayed first
#+ 
#+ @code
#+ CALL fgl_zoom.gotolist_set(TRUE)
#+ 
#+ @param gotolist BOOLEAN TRUE for the first window to be the List window, FALSE otherwise
#+
FUNCTION gotolist_set(l_gotolist)
DEFINE l_gotolist BOOLEAN

   LET m_zoom.gotolist = l_gotolist
END FUNCTION



#+ Set the autoselect parameter
#+
#+ Set the autoselect parameter.  Controls what happens if the zoom window QBE 
#+ only returns one row of data.  If this parameter is set to TRUE then the
#+ zoom window will automatically return this one row of data.  If set to FALSE
#+ then the user will have to select this row in order to return it
#+ If this funciton is not called, the value is set to FALSE, and the user has
#+ to select the one row of data.
#+ 
#+ @code
#+ CALL fgl_zoom.autoselect_set(TRUE)
#+ 
#+ @param l_autoselect BOOLEAN TRUE if we will automatically return if the QBE results in one row
#+
FUNCTION autoselect_set(l_autoselect)
DEFINE l_autoselect BOOLEAN

   LET m_zoom.autoselect = l_autoselect
END FUNCTION



#+ Set the multiplerow parameter
#+
#+ Set the multiplerow parameter.  Controls if the list window allows the user
#+ to select one row of data, or multiple rows.  TRUE will allow the user to
#+ select multiple rows, FALSE will restruct the user to selecting one row.
#+ Typically you would set this to TRUE if the zoom window is called from a
#+ CONSTRUCT statement or is being used to populate an array.
#+ If this function is not called, the value is set to FALSE, and the user can
#+ only select one row of data.
#+ 
#+ @code
#+ CALL fgl_zoom.multiplerow_set(TRUE)
#+ 
#+ @param l_multiplerow BOOLEAN TRUE to allow selection of multiple rows, FALSE otherwise.
#+
FUNCTION multiplerow_set(l_multiplerow)
DEFINE l_multiplerow BOOLEAN

   LET m_zoom.multiplerow = l_multiplerow
END FUNCTION



#+ Set the maxrow parameter
#+
#+ Set the maxrow parameter.  Controls the maximum number of rows that will be
#+ returned to the list window.  If this is set to 0, or not defined then the 
#+ maximum number of rows is unlimited
#+ 
#+ @code
#+ CALL fgl_zoom.maxrow_set(100)
#+ 
#+ @param maxrow INTEGER The maximum number of rows to return to the list window.  Set to 0 for unlimited
#+
FUNCTION maxrow_set(l_maxrow)
DEFINE l_maxrow INTEGER

   LET m_zoom.maxrow = l_maxrow
END FUNCTION




#+ Set the freezeleft parameter
#+
#+ Set the freezeleft parameter.  Controls the number of columns to initially
#+ freeze from the left hand side
#+ 
#+ @code
#+ CALL fgl_zoom.freezeleft_set(2)
#+ 
#+ @param freezeleft INTEGER Number of columns to initially freeze
#+
FUNCTION freezeleft_set(l_freezeleft)
DEFINE l_freezeleft INTEGER

   LET m_zoom.freezeleft = l_freezeleft
END FUNCTION


#+ Set the freezeright parameter
#+
#+ Set the freezeright parameter.  Controls the number of columns to initially
#+ freeze from the right hand side
#+ 
#+ @code
#+ CALL fgl_zoom.freezeright_set(2)
#+ 
#+ @param freezeright INTEGER Number of columns to initially freeze
#+
FUNCTION freezeright_set(l_freezeright)
DEFINE l_freezeright INTEGER

   LET m_zoom.freezeright = l_freezeright
END FUNCTION


#+ Set the qbeforce parameter
#+
#+ Set the qbeforce parameter.  Controls if at least one field must have
#+ some QBE criteria entered
#+ 
#+ @code
#+ CALL fgl_zoom.qbeforce_set(TRUE)
#+ 
#+ @param qbeforce BOOLEAN TRUE if at least one field must have QBE criteria entered, FALSE otherwise
#+
FUNCTION qbeforce_set(l_qbeforce)
DEFINE l_qbeforce BOOLEAN

   LET m_zoom.qbeforce = l_qbeforce
END FUNCTION



#+ Set the i'th column columnname parameter
#+
#+ Set the i'th column columnname parameter.  Typically set to the corresponding 
#+ column in the SQL statement.  This value is used in creating the WHERE 
#+ clause.
#+ 
#+ @code
#+ CALL fgl_zoom.column_columnname_set(1,"tabid")
#+ 
#+ @param i INTEGER The column index
#+ @param l_columnname STRING The columnname of the database column
#+
FUNCTION column_columnname_set(i, l_columnname)
DEFINE i INTEGER
DEFINE l_columnname STRING

   LET m_zoom.column[i].columnname = l_columnname
END FUNCTION



#+ Set the i'th column title parameter
#+
#+ Set the i'th column title parameter.  This then becomes the column heading
#+ in the zoom window
#+ 
#+ @code
#+ CALL fgl_zoom.column_title_set(1,"ID")
#+ 
#+ @param i INTEGER The column index
#+ @param l_title STRING The title or columnheading of the i'th column
#+
FUNCTION column_title_set(i, l_title)
DEFINE i INTEGER
DEFINE l_title STRING

   LET m_zoom.column[i].title = l_title
END FUNCTION



#+ Set the i'th column width parameter
#+
#+ Set the i'th column width parameter.  This controls the width of the column
#+ in the zoom window.  If not defined, the column will be given a width of
#+ 10 characters
#+ 
#+ @code
#+ CALL fgl_zoom.column_width_set(1,10)
#+ 
#+ @param i INTEGER The column index
#+ @param l_title STRING The width of the i'th column
#+
FUNCTION column_width_set(i, l_width)
DEFINE i INTEGER
DEFINE l_width INTEGER

   LET m_zoom.column[i].width = l_width
END FUNCTION



#+ Set the i'th column format parameter
#+
#+ Set the i'th column format parameter.  Used to control the appearance of the
#+ values in a column.  The value is as per the 4GL format property
#+ 
#+ @code
#+ CALL fgl_zoom.column_format_set(1,"###,##&.&&")
#+ 
#+ @param i INTEGER The column index
#+ @param l_format STRING The format property for the i'th column
#+
FUNCTION column_format_set(i, l_format)
DEFINE i INTEGER
DEFINE l_format STRING

   LET m_zoom.column[i].format = l_format
END FUNCTION



#+ Set the i'th column datatypec parameter
#+
#+ Set the i'th column datatypec parameter.  Values accepted are (c)har,
#+ (f)loat/decimal, (i)nteger, (d)ate.  This value controls what can be
#+ entered in the QBE field and the sort order.  All datatypes should be mapped
#+ to the closest equivalent.  DATETIME and INTERVAL map to (c)har as these
#+ fields have the same sort property.
#+ 
#+ @code
#+ CALL fgl_zoom.column_datatypec_set(1,"c")
#+ 
#+ @param i INTEGER The column index
#+ @param l_datatypec CHAR(1) The datatype of the i'th column
#+
FUNCTION column_datatypec_set(i, l_datatypec)
DEFINE i INTEGER
DEFINE l_datatypec CHAR(1)

   LET m_zoom.column[i].datatypec = l_datatypec
END FUNCTION



#+ Set the i'th column justify parameter
#+
#+ Set the i'th column justify parameter.  This value controls the justification
#+ used to display the i'th column.  If not defined it will be set to left 
#+ except for floats and integers in which case it will right justify.
#+ 
#+ @code
#+ CALL fgl_zoom.column_justify_set(1,"right")
#+ 
#+ @param i INTEGER The column index
#+ @param l_justify STRING The justification of the i'th column
#+
FUNCTION column_justify_set(i, l_justify)
DEFINE i INTEGER
DEFINE l_justify STRING

   LET m_zoom.column[i].justify = l_justify
END FUNCTION



#+ Set the i'th column excludeqbe parameter
#+
#+ Set the i'th column excludeqbe parameter.  Set to TRUE if you do not want
#+ the column to appear in the QBE window, otherwise the default of FALSE will
#+ include this column in the QBE window.
#+ Typically would set to TRUE if the column would not be valid in the CONSTRUCT
#+ statement, perhaps because it is an expression or is a code you want to hide
#+ from the end-user
#+ 
#+ @code
#+ CALL fgl_zoom.column_excludeqbe_set(1, TRUE)
#+ 
#+ @param i INTEGER The column index
#+ @param l_excludeqbe BOOLEAN Set to TRUE to exclude the column from the QBE window
#+
FUNCTION column_excludeqbe_set(i, l_excludeqbe)
DEFINE i INTEGER
DEFINE l_excludeqbe BOOLEAN

   LET m_zoom.column[i].excludeqbe = l_excludeqbe
END FUNCTION



#+ Set the i'th column excludelist parameter
#+
#+ Set the i'th column excludelist parameter.  Set to TRUE if you do not want 
#+ the column to appear in the List window, otherwise the default of FALSE will
#+ this column in the List window.
#+ Typically you would set to TRUE if you did not want the user to see this 
#+ column e.g. a code or serial value.
#+ 
#+ @code
#+ CALL fgl_zoom.column_excludelist_set(1, TRUE)
#+ 
#+ @param i INTEGER The column index
#+ @param l_excludelist BOOLEAN Set to TRUE to exclude the column from the List window
#+
FUNCTION column_excludelist_set(i, l_excludelist)
DEFINE i INTEGER
DEFINE l_excludelist BOOLEAN

   LET m_zoom.column[i].excludelist = l_excludelist
END FUNCTION



#+ Set the i'th column includeinresult parameter
#+
#+ Set the i'th column includeinresult parameter.  Set to TRUE if you want the 
#+ column to appear in the list of columns that are returned to the end-user,
#+ otherwise the default of FALSE will exclude this column from the list of 
#+ returned columns.
#+ Typically you would only set this to TRUE for the first column.
#+ YOu can also use this in conjunction with the above two parameters to hide
#+ an id or code value from the user but return this id or code to the calling
#+ program in much the same way COMBOBOX's hide the 4gl variable
#+ 
#+ @code
#+ CALL fgl_zoom.column_includeinresult_set(1,TRUE)
#+ 
#+ @param i INTEGER The column index
#+ @param l_includeinresult BOOLEAN Set to TRUE to include the column in the result list
#+
FUNCTION column_includeinresult_set(i, l_includeinresult)
DEFINE i INTEGER
DEFINE l_includeinresult BOOLEAN

   LET m_zoom.column[i].includeinresult = l_includeinresult
END FUNCTION



#+ Set the i'th column qbedefault parameter
#+
#+ Set the i'th column qbedefault parameter.  This is the value that will appear
#+ in the CONSTRUCT as the initial QBE criteria for this field
#+ 
#+ @code
#+ CALL fgl_zoom.column_qbedefault_set(1,">0")
#+ 
#+ @param i INTEGER The column index
#+ @param l_qbedefault STRING The default QBE criteria for this field
#+
FUNCTION column_qbedefault_set(i, l_qbedefault)
DEFINE i INTEGER
DEFINE l_qbedefault STRING

   LET m_zoom.column[i].qbedefault = l_qbedefault
END FUNCTION



#+ Set the i'th column qbeforce parameter
#+
#+ Set the i'th column qbeforce parameter.  This determines if the field
#+ must have some QBE criteria entered
#+ 
#+ @code
#+ CALL fgl_zoom.column_qbeforce_set(1,TRUE)
#+ 
#+ @param i INTEGER The column index
#+ @param l_qbeforce BOOLEAN TRUE if this field must have some QBE criteria entered, FALSE otherwise
#+
FUNCTION column_qbeforce_set(i, l_qbeforce)
DEFINE i INTEGER
DEFINE l_qbeforce BOOLEAN

   LET m_zoom.column[i].qbeforce = l_qbeforce
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
#+ @param column_name STRING The name of the column in the database
#+ @param datatypec CHAR(1) The datatype of the column, values are (c)har, (i)nteger, (f)loat, (d)ate
#+ @param width INTEGER The width of the column.  Use 0 to use a default value.
#+ @param title STRING The column heading
#+
FUNCTION column_quick_set(i, l_column_name, l_datatypec, l_width, l_title) 
DEFINE i INTEGER
DEFINE l_column_name STRING
DEFINE l_datatypec CHAR(1)
DEFINE l_width INTEGER
DEFINE l_title STRING

   CALL column_columnname_set(i,l_column_name)
   CALL column_title_set(i,l_title)
   CALL column_datatypec_set(i,l_datatypec)
   IF l_width > 0 THEN
      CALL column_width_set(i, l_width)
   END IF
   CALL column_includeinresult_set(i,i=1)
   IF l_datatypec MATCHES "[fi]" THEN
      CALL column_justify_set(i,"right")
   END IF
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
FUNCTION execute()
DEFINE ok BOOLEAN
DEFINE l_message STRING
DEFINE i INTEGER

    -- Clear int_flag, can't guarantee that calling program will have done this
    LET int_flag =FALSE

    CALL m_fields.clear()
    FOR i = 1 TO m_zoom.column.getLength()
        LET m_fields[i].name = m_zoom.column[i].columnname
        CASE m_zoom.column[i].datatypec
            WHEN "i" LET m_fields[i].type = "INTEGER"
            WHEN "d" LET m_fields[i].type = "DATE"
            WHEN "f" LET m_fields[i].type = "FLOAT"
            OTHERWISE LET m_fields[i].type = "STRING"
        END CASE
    END FOR

    CALL m_zoom_result.clear()

    -- Set defaults, lower case all parameters, allow aliases before we validate
    CALL normalise()
    CALL validate() RETURNING ok, l_message
    IF NOT ok THEN
        LET m_mode = "cancel"
        CALL FGL_WINMESSAGE(%"fgl_zoom.window.title.error", SFMT(%"fgl_zoom.validate.wrapper", l_message),"stop")
        RETURN
    END IF

    OPEN WINDOW fgl_zoom WITH 1 ROWS, 1 COLUMNS ATTRIBUTES(STYLE="fgl_zoom", TEXT=%"fgl_zoom.window.title")   
    LET m_window = ui.Window.getCurrent()
    CALL create_form()
   
    -- Determine the first screen
    -- Normally this will be the QBE unless we have said go direct to the list
    -- or don't allow entry of a QBE
    IF m_zoom.gotolist OR m_zoom.noqbe THEN
        LET m_mode = "list"
        LET m_where = "1=1"
    ELSE
        LET m_mode = "qbe"
    END IF
   
    WHILE (m_mode = "qbe" OR m_mode = "list")
        -- Exit if Impossible conditions occur
        IF m_mode = "qbe" AND m_zoom.noqbe THEN
            LET m_mode = "cancel"
        END IF
        IF m_mode = "list" AND m_zoom.nolist THEN
            LET m_mode = "cancel"
        END IF
        CALL show_hide_columns(m_mode)
        CASE m_mode
            WHEN "qbe" CALL zoom_qbe()
            WHEN "list" CALL zoom_list()
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
FUNCTION call()
DEFINE l_return STRING

    CALL execute()
    IF m_mode = "cancel" THEN
        LET l_return = m_zoom.cancelvalue
    ELSE
        LET l_return =  m_zoom_result[1,1]
    END IF
    RETURN l_return
END FUNCTION



-- Getters



#+ Get the where clause entered by the user in the QBE window
#+
#+ Get the where clause entered by the user in the QBE window
#+ 
#+ @code
#+ DEFINE where_clause STRING
#+ ...
#+ CALL fgl_zoom.execute()
#+ LET where_clause = fgl_zoom.where_get()
#+
#+ @return m_where STRING The where clause as entered by the user in the QBE window
#+
FUNCTION where_get()
    RETURN m_where
END FUNCTION



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
FUNCTION qbe_get()
DEFINE sb base.stringbuffer
DEFINE i INTEGER
DEFINE l_return STRING

    LET sb = base.StringBuffer.create() 
    CALL sb.clear()
    FOR i = 1 TO m_zoom_result.getLength()
        IF i > 1 THEN
            CALL sb.append("|")
        END IF
        CALL sb.append(m_zoom_result[i,1] CLIPPED)
    END FOR
    LET l_return =  sb.toString()
    RETURN l_return
END FUNCTION   



#+ Returns the value selected by the user in the specified row and column
#+
#+ Returns the value selected by the user in the specified row and column.
#+ Note, that the specified row is based on the selected rows, not the actual 
#+ rows, and that the specified column is based on the defined columns to 
#+ return a value from.
#+ Typical usage would be with 1,1 as the parameters.  If multi-row select is
#+ allowed then the row number would reflect the row selected.
#+ The column parameter would exclude the columns where includeinresult is
#+ set to FALSE
#+ 
#+ @code
#+ CALL fgl_zoom.execute()
#+ DISPLAY "Value selected is ... ", fgl_zoom.result_get(1,1)
#+ 
#+ @param i INTEGER
#+
#+ @return l_return STRING The value as selected by the user
#+
FUNCTION result_get(l_row,l_col)
DEFINE l_row,l_col INTEGER
DEFINE l_return STRING

    CASE 
        WHEN l_row > result_length_get()
            INITIALIZE l_return TO NULL
        WHEN l_col > result_rowlength_get(l_row)
            INITIALIZE l_return TO NULL
        OTHERWISE
            LET l_return = m_zoom_result[l_row,l_col]
    END CASE
    RETURN l_return
END FUNCTION



#+ Returns the number of rows selected
#+
#+ Returns the number of rows selected
#+ 
#+ @code
#+ CALL fgl_zoom.multiplerow(TRUE)
#+ CALL fgl_zoom.execute()
#+ DISPLAY "Number of rows selected is ... ", fgl_zoom.result_length_get()
#+ 
#+ @return l_return INTEGER The number of rows selected by the user
#+
FUNCTION result_length_get()
DEFINE l_return INTEGER

    LET l_return =  m_zoom_result.getLength()
    RETURN l_return
END FUNCTION



#+ Returns the number of column values returned from the selected row
#+
#+ Returns the number of column values returned from the selected row.  At this
#+ stage it is expected that this will return the same value for all rows.
#+ A column can be excluded from the result list by setting the includeinresult
#+ parameter to FALSE
#+ 
#+ @code
#+ CALL fgl_zoom.execute()
#+ DISPLAY "Number of columns selected in row 1 is ... ", fgl_zoom.result_rowlength_get(1)
#+
#+ @param l_row INTEGER The row number to get the number of columns from
#+ 
#+ @return l_return INTEGER The number of columns in the row selected by the user
#+
FUNCTION result_rowlength_get(l_row)
DEFINE l_row INTEGER
DEFINE l_return INTEGER

    LET l_return =   m_zoom_result[l_row].getLength()
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
FUNCTION ok()
DEFINE ok BOOLEAN
    LET ok = (m_mode = "accept")
    RETURN ok
END FUNCTION



#+ A QBE of the data to display in the zoom window.
#+
#+ A CONSTRUCT that allows the user to do a QBE for the data that will be 
#+ displayed in the zoom window.  If the query has been defined with some
#+ QBE defaults then these are displayed in the field during the BEFORE CONSTRUCT
#+ 
PRIVATE FUNCTION zoom_qbe()
DEFINE i INTEGER
DEFINE l_where_previous STRING
DEFINE l_restore_previous BOOLEAN
DEFINE l_columns_with_qbe_entered SMALLINT
DEFINE l_current_field_qbe STRING
DEFINE d_c ui.Dialog


    -- Clear the screen
    LET d_c = NULL
    CLEAR FORM

    LET l_where_previous = m_where
    LET l_restore_previous = FALSE
    LET m_where = NULL

    LET d_c = ui.Dialog.createConstructByName(m_fields)

    -- Add events
    CALL d_c.addTrigger("ON ACTION close")
    CALL d_c.addTrigger("ON ACTION list")
    CALL d_c.addTrigger("ON ACTION accept")

    WHILE TRUE
        CASE d_c.nextEvent()
            WHEN "BEFORE INPUT" -- BUG Change to BEFORE CONSTRUCT when fixed
                IF m_zoom.nolist THEN
                    -- Leave the accept text as OK
                ELSE
                    CALL action_text_set("accept", %"fgl_zoom.action.accept.text.alternate")
                END IF
                MESSAGE %"fgl_zoom.before_construct"
            
                FOR i = 1 TO m_zoom.column.getLength()
                    -- Display the default value, will have to figure out type as well
                    IF m_zoom.column[i].qbedefault IS NOT NULL THEN
                        CALL d_c.setFieldValue(m_zoom.column[i].columnname,m_zoom.column[i].qbedefault)
                    END IF
                END FOR
                  
            WHEN "ON ACTION close"
                LET m_mode = "cancel"
                EXIT WHILE
                
            WHEN "ON ACTION list"
                LET m_mode = "list"
                LET l_restore_previous = TRUE
                EXIT WHILE
                
            WHEN "ON ACTION accept"
                -- test qbeforce
                LET l_columns_with_qbe_entered = 0
                FOR i = 1 TO m_zoom.column.getLength()
                    IF m_zoom.qbeforce OR m_zoom.column[i].qbeforce THEN
                        IF d_c.getQueryFromField(m_zoom.column[i].columnname) IS NOT NULL THEN
                            IF m_zoom.qbeforce THEN
                                LET l_columns_with_qbe_entered = l_columns_with_qbe_entered + 1
                            END IF
                        ELSE
                            IF m_zoom.column[i].qbeforce  THEN
                                ERROR %"fgl_zoom.error.column.qbeforce"
                                CALL d_c.nextField(m_zoom.column[i].columnname) 
                                CONTINUE WHILE
                            END IF
                        END IF
                    END IF
                END FOR
                IF m_zoom.qbeforce AND l_columns_with_qbe_entered = 0 THEN
                    ERROR %"fgl_zoom.error.qbeforce"
                    CALL d_c.nextField(d_c.getCurrentItem())
                    CONTINUE WHILE
                END IF
      
                IF m_zoom.nolist THEN
                    LET m_mode = "accept"
                ELSE
                    LET m_mode = "list"
                END IF
                
                -- Create SQL clause
                LET m_where = NULL
                FOR i = 1 TO m_fields.getLength()
                    LET l_current_field_qbe = d_c.getQueryFromField(m_zoom.column[i].columnname)
                    IF l_current_field_qbe IS NOT NULL THEN
                        IF m_where IS NULL THEN
                            LET m_where = l_current_field_qbe
                        ELSE
                            LET m_where = m_where," AND ", l_current_field_qbe
                        END IF
                    END IF
                END FOR
                IF m_where IS NULL THEN
                    LET m_where = "1=1"
                END IF
                EXIT WHILE
        END CASE
    END WHILE

    LET d_c = NULL

    -- set the where clause back to what it was previously
    IF l_restore_previous THEN
        IF l_where_previous IS NULL THEN
            LET m_where = "1=1"
        ELSE
            LET m_where = l_where_previous
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
PRIVATE FUNCTION zoom_list()
DEFINE i INTEGER
DEFINE l_sql STRING
DEFINE dnd ui.DragDrop
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
    CALL m_data.clear()

    LET l_sql = SFMT(m_zoom.sql, m_where, columnlist_get())
   
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

        IF m_zoom.maxrow > 0 THEN
            IF l_row_count > m_zoom.maxrow THEN
                LET l_maxrow_flg = TRUE
                EXIT WHILE
            END IF
        END IF

        FOR l_column = 1 TO l_sqlh.getResultCount()
            LET m_data[l_row_count, l_column] = l_sqlh.getResultValue(l_column)
        END FOR
    END WHILE
    CALL l_sqlh.close()

    CASE
        WHEN l_row_count = 0
            CALL FGL_WINMESSAGE(%"fgl_zoom.window.title.zoom", %"fgl_zoom.no_records_found", "stop")
            -- no records to display
            IF m_zoom.noqbe THEN
                LET m_mode = "cancel"
            ELSE
                LET m_mode = "qbe"
            END IF
        WHEN l_row_count = 1 AND m_zoom.autoselect 
            CALL zoom_add_row_to_result(1)
            LET m_mode = "accept"
        OTHERWISE
            LET d_da = ui.Dialog.createDisplayArrayTo(m_fields, "data")
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
                    CALL d_da.setFieldValue(m_fields[l_column].name, m_data[l_row, l_column] )
                END FOR
            END FOR
            CALL d_da.setCurrentRow("data",1)

             WHILE TRUE
                LET l_event = d_da.nextEvent()
                CASE l_event
                    WHEN "BEFORE DISPLAY"
                        CALL d_da.setActionActive("accept", l_row_count > 0)
                        CALL d_da.setActionActive("qbe", NOT m_zoom.noqbe)
                        CALL d_da.setSelectionMode("data", m_zoom.multiplerow)
                        CALL d_da.setActionActive("selectall", m_zoom.multiplerow)
                        CALL d_da.setActionActive("selectnone", m_zoom.multiplerow)

                        IF l_maxrow_flg THEN
                            CALL FGL_WINMESSAGE(%"fgl_zoom.window.title.zoom", SFMT(%"fgl_zoom.max_rows_hit",m_zoom.maxrow), "info")
                        END IF
                    WHEN "BEFORE ROW"
                        MESSAGE SFMT(%"fgl_zoom.x_of_y", d_da.getCurrentRow("data"), l_row_count)
                        
                    #ON DRAG_START (dnd)
                        #CALL dnd.setOperation("copy")
                        
                    WHEN "ON ACTION copy"
                        CALL ui.Interface.frontCall("standard","cbset",d_da.selectionToString("data"),ok)
                        
                    WHEN "ON ACTION copyall"
                        -- if selectionmode=1 have to store away current values and reset
                        -- otherwise if can do this
                        IF m_zoom.multiplerow THEN
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

                        CASE ui.Interface.getFrontEndName() 
                            WHEN "GDC"
                                -- For GDC, display to GWC TextEdit
                                CALL ui.Interface.frontCall("standard","cbset",l_datatocopy,ok)
                            WHEN "GWC"
                                OPEN WINDOW clip WITH FORM "fgl_zoom_webcopy" ATTRIBUTES(STYLE="fgl_zoom", TEXT="Select All and Copy to Clipboard")
                                INPUT BY NAME l_datatocopy ATTRIBUTES(WITHOUT DEFAULTS=TRUE, ACCEPT=FALSE)
                                LET int_flag = 0
                                CLOSE WINDOW clip
                        END CASE
                
                        CALL d_da.setSelectionRange("data",1,-1,0)
                        IF m_zoom.multiplerow THEN
                            -- restore previoulsy selected rows
                            FOR i = 1 TO l_row_count
                                CALL d_da.setSelectionRange("data",i,i,l_selected[i])
                            END FOR
                        ELSE
                            CALL d_da.setSelectionMode("data",0)
                        END IF

                    WHEN "ON ACTION print"
                        CALL zoom_print()

                    WHEN "ON ACTION selectnone"
                        CALL d_da.setSelectionRange("data",1,l_row_count, FALSE)
               
                    WHEN "ON ACTION selectall"
                        CALL d_da.setSelectionRange("data",1,l_row_count, TRUE)

                    WHEN "ON ACTION cancel"
                        LET m_mode = "cancel"
                        EXIT WHILE

                    WHEN "ON ACTION qbe"
                        LET m_mode = "qbe"
                        EXIT WHILE
           
                    WHEN "ON ACTION close"
                        LET m_mode = "cancel"
                        EXIT WHILE

                    WHEN "ON ACTION data.accept" -- need this due to event sent on double click
                        GOTO lbl_accept
                    WHEN "ON ACTION accept"
                        LABEL lbl_accept:
                        IF m_mode = "list" THEN
                            IF m_zoom.multiplerow THEN
                                FOR l_row = 1 TO l_row_count
                                    IF d_da.isRowselected("data",l_row) THEN
                                        CALL zoom_add_row_to_result(l_row)
                                    END IF
                                END FOR
                            ELSE
                                CALL zoom_add_row_to_result(arr_curr())
                            END IF
                        END IF
                        LET m_mode = "accept"
                        EXIT WHILE
                    OTHERWISE   
                        DISPLAY "Event not handled ", l_event
                END CASE
            END WHILE
    END CASE

    LET d_da = NULL
END FUNCTION


#+ Add passed in row to the list of selected rows
PRIVATE FUNCTION zoom_add_row_to_result(l_row)
DEFINE l_row INTEGER
DEFINE i,j,k INTEGER

   LET i = m_zoom_result.getLength() + 1
   LET k = 0
   FOR j = 1 TO m_zoom.column.getLength()
      IF m_zoom.column[j].includeinresult THEN
         LET k = k + 1
         LET m_zoom_result[i,k] = m_data[l_row,j]
      END IF
   END FOR
END FUNCTION



#+ Setup the columns to hide/show columns
PRIVATE FUNCTION show_hide_columns(l_mode)
DEFINE l_mode STRING
DEFINE i INTEGER
DEFINE l_hidden BOOLEAN

    FOR i =1 TO m_zoom.column.getLength()
        LET l_hidden = FALSE
        IF NOT l_hidden AND l_mode = "qbe" AND m_zoom.column[i].excludeqbe THEN
            LET l_hidden = TRUE
        END IF
        IF NOT l_hidden AND l_mode = "list" AND m_zoom.column[i].excludelist THEN
            LET l_hidden = TRUE
        END IF
        CALL m_form.setFieldHidden(m_zoom.column[i].columnname, l_hidden )
    END FOR
END FUNCTION



#+ Normalise the parameters input 
PRIVATE FUNCTION normalise()
DEFINE i INTEGER

   LET m_zoom.sql = m_zoom.sql.trim()
   
   IF m_zoom.noqbe IS NULL THEN
      LET m_zoom.noqbe = FALSE
   END IF
   IF m_zoom.nolist IS NULL THEN
      LET m_zoom.nolist = FALSE
   END IF
   IF m_zoom.gotolist IS NULL THEN
      LET m_zoom.gotolist = FALSE
   END IF
   IF m_zoom.autoselect IS NULL THEN
      LET m_zoom.autoselect = FALSE
   END IF
   IF m_zoom.multiplerow IS NULL THEN
      LET m_zoom.multiplerow = FALSE
   END IF
   IF m_zoom.maxrow IS NULL THEN
      LET m_zoom.maxrow = 0
   END IF
   IF m_zoom.freezeleft IS NULL THEN
      LET m_zoom.freezeleft = 0
   END IF
   IF m_zoom.freezeright IS NULL THEN
      LET m_zoom.freezeright = 0
   END IF
  
   FOR i = 1 TO m_zoom.column.getLength()
      LET m_zoom.column[i].columnname = m_zoom.column[i].columnname.trim()

      -- Default column width to 10 if not set
      IF m_zoom.column[i].width IS NULL THEN
         LET m_zoom.column[i].width = 10
      END IF  
      
      LET m_zoom.column[i].datatypec = m_zoom.column[i].datatypec.toLowerCase()
      -- don't have a default, force developer to specify datatype
      -- allow these aliases
      CASE 
         WHEN m_zoom.column[i].datatypec MATCHES "char*" LET m_zoom.column[i].datatypec = "c"
         WHEN m_zoom.column[i].datatypec = "string" LET m_zoom.column[i].datatypec = "c"
         WHEN m_zoom.column[i].datatypec MATCHES "datetime*" LET m_zoom.column[i].datatypec = "c"
         WHEN m_zoom.column[i].datatypec MATCHES "interval*" LET m_zoom.column[i].datatypec = "c"

         WHEN m_zoom.column[i].datatypec = "tinyint" LET m_zoom.column[i].datatypec = "i"
         WHEN m_zoom.column[i].datatypec = "smallint" LET m_zoom.column[i].datatypec = "i"
         WHEN m_zoom.column[i].datatypec = "integer" LET m_zoom.column[i].datatypec = "i"
         WHEN m_zoom.column[i].datatypec = "bigint" LET m_zoom.column[i].datatypec = "i"
         WHEN m_zoom.column[i].datatypec MATCHES "decimal*0)" LET m_zoom.column[i].datatypec = "i"

         WHEN m_zoom.column[i].datatypec matches "decimal*" LET m_zoom.column[i].datatypec = "f"
         WHEN m_zoom.column[i].datatypec matches "float*" LET m_zoom.column[i].datatypec = "f"
         WHEN m_zoom.column[i].datatypec matches "money*" LET m_zoom.column[i].datatypec = "f"

         WHEN m_zoom.column[i].datatypec = "date" LET m_zoom.column[i].datatypec = "d"
      END CASE

      LET m_zoom.column[i].justify = m_zoom.column[i].justify.toLowerCase()
      -- Default justification is left
      IF m_zoom.column[i].justify.getLength() = 0 THEN
         LET m_zoom.column[i].justify = "left"
      END IF
      -- allow these aliases
      CASE m_zoom.column[i].justify 
         WHEN "l" LET m_zoom.column[i].justify = "left"
         WHEN "c" LET m_zoom.column[i].justify = "center"
         WHEN "r" LET m_zoom.column[i].justify = "right"
         WHEN "centre" LET m_zoom.column[i].justify = "center"
      END CASE
      
      IF m_zoom.column[i].excludeqbe IS NULL THEN
         LET m_zoom.column[i].excludeqbe = FALSE
      END IF
      
      IF m_zoom.column[i].excludelist IS NULL THEN
         LET m_zoom.column[i].excludelist = FALSE
      END IF
      
      IF m_zoom.column[i].includeinresult IS NULL THEN
         LET m_zoom.column[i].includeinresult = FALSE
      END IF

      IF m_zoom.column[i].qbeforce IS NULL THEN
         LET m_zoom.column[i].qbeforce = FALSE
      END IF
   END FOR  
   
END FUNCTION


#+ Test that the parameters passed in are OK
PRIVATE FUNCTION validate()
DEFINE i INTEGER

   IF m_zoom.sql.getlength() > 0 THEN
      #OK
   ELSE
      RETURN FALSE, %"fgl_zoom.validate.sql_must_be_defined"
   END IF
   
   IF m_zoom.maxrow < 0 THEN
      RETURN FALSE, %"fgl_zoom.validate.max_row_must_be_positive"
   END IF

   IF m_zoom.freezeleft < 0 OR m_zoom.freezeleft > 8 THEN
      RETURN FALSE, %"fgl_zoom.validate.freezeleft_range"
   END IF

   IF m_zoom.freezeright < 0 OR m_zoom.freezeright > 8 THEN
      RETURN FALSE, %"fgl_zoom.validate.freezeright_range"
   END IF

   IF m_zoom.column.getLength() = 0 THEN
      RETURN FALSE, %"fgl_zoom.validate.column_defined_min"
   END IF
   IF m_zoom.column.getLength() > 9 THEN
      RETURN FALSE, %"fgl_zoom.validate.column_defined_max"
   END IF
   
   FOR i = 1 TO m_zoom.column.getLength()
      IF m_zoom.column[i].columnname.getLength() > 0 THEN
         #OK
      ELSE
         RETURN FALSE, SFMT(%"fgl_zoom.validate.column_X_defined",i)
      END IF

      IF m_zoom.column[i].width < 1 THEN
         RETURN FALSE, SFMT(%"fgl_zoom.validate.column_X_width_valid", i)
      END IF
      
      IF m_zoom.column[i].datatypec.getCharAt(1) MATCHES "[cdfi]" THEN
         #OK
      ELSE
         RETURN FALSE, SFMT(%"fgl_zoom.validate.column_X_datatype_valid",i)
      END IF

      CASE m_zoom.column[i].justify 
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
PRIVATE FUNCTION columnlist_get()
DEFINE i INTEGER
DEFINE l_sb base.StringBuffer

    LET l_sb = base.StringBuffer.create()
    CALL l_sb.append(m_zoom.column[1].columnname)
    FOR i = 2 TO m_zoom.column.getLength()
        CALL l_sb.append(",")
        CALL l_sb.append(m_zoom.column[i].columnname)
    END FOR
    RETURN l_sb.toString()
END FUNCTION



#+ Append to the style a style to freeze columns
PRIVATE FUNCTION append_freeze_style()
DEFINE l_style STRING

   IF m_zoom.freezeleft > 0 AND m_zoom.freezeleft <=8 THEN
      LET l_style= m_table_node.getAttribute("style")
      LET l_style= l_style.append(SFMT(" fgl_zoom_leftfreeze%1", m_zoom.freezeleft USING "&"))
      CALL m_table_node.setAttribute("style", l_style)
   END IF
   IF m_zoom.freezeright > 0 AND m_zoom.freezeright <=8 THEN
      LET l_style= m_table_node.getAttribute("style")
      LET l_style= l_style.append(SFMT(" fgl_zoom_rightfreeze%1", (9-m_zoom.column.getLength()+m_zoom.freezeright) USING "&"))
      CALL m_table_node.setAttribute("style", l_style)
   END IF
END FUNCTION



#+ Change the text attribute of an action
PRIVATE FUNCTION action_text_set(l_action, l_text)
DEFINE l_action STRING
DEFINE l_text STRING

DEFINE w ui.Window
DEFINE f ui.Form

DEFINE n om.DomNode

   LET w = ui.Window.getCurrent()
   LET f = w.getForm()
   LET n = w.findNode("Action",l_action)
   CALL n.setAttribute("text", l_text)
END FUNCTION



        
PRIVATE FUNCTION zoom_print()
DEFINE grw om.saxDocumentHandler
DEFINE i INTEGER

    #TODO check this now generic fields in use
 
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
END FUNCTION



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







PRIVATE FUNCTION create_form()
DEFINE form_node, vbox_node, table_node, tablecolumn_node, widget_node, recordview_node, link_node om.DomNode
DEFINE i INTEGER

    -- create form in memory
    LET m_form = m_window.createForm("fgl_zoom")
    LET form_node = m_form.getNode()
    
    CALL form_node.setAttribute("width",10*m_zoom.column.getLength()+2)
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
    FOR i = 1 TO m_zoom.column.getLength()
       
       LET tablecolumn_node = table_node.createChild("TableColumn")
       
       CALL tablecolumn_node.setAttribute("name",SFMT("formonly.%1", m_zoom.column[i].columnname))  #TODO
       CALL tablecolumn_node.setAttribute("sqlTabName","formonly")
       CALL tablecolumn_node.setAttribute("colName",m_zoom.column[i].columnname)  #TODO
       CALL tablecolumn_node.setAttribute("fieldId",(i-1) USING "<&")

       CALL tablecolumn_node.setAttribute("tabIndex", i USING "&")

       CASE m_zoom.column[i].datatypec 
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
    
       CALL tablecolumn_node.setAttribute("text", m_zoom.column[i].title)

       LET widget_node = tablecolumn_node.createChild("Edit")
       CALL widget_node.setAttribute("width",m_zoom.column[i].width)

       IF m_zoom.column[i].format IS NOT NULL THEN
           CALL widget_node.setAttribute("format", m_zoom.column[i].format)
       END IF
       
       IF m_zoom.column[i].justify IS NOT NULL THEN
           CALL widget_node.setAttribute("justify", m_zoom.column[i].justify)
       END IF
    END FOR

    -- Create record view
    LET recordview_node = form_node.createChild("RecordView")
    CALL recordview_node.setAttribute("tabName","formonly")

    -- Link nodes
    FOR i = 1 TO m_zoom.column.getLength()
        LET link_node = recordview_node.createChild("Link")
        CALL link_node.setAttribute("colName",m_zoom.column[i].columnname)
        CALL link_node.setAttribute("fieldIdRef",(i-1) USING "<&")
    END FOR
   
    CALL m_form.loadActionDefaults("fgl_zoom.4ad")
    CALL m_form.loadToolBar("fgl_zoom.4tb")
    CALL m_window.settext(m_zoom.title)
    LET m_table_node = m_form.findNode("Table","tablist")
    CALL append_freeze_style()
END FUNCTION



PRIVATE FUNCTION init_fields()
DEFINE i INTEGER

    CALL m_fields.clear()
    FOR i = 1 TO m_zoom.column.getLength()
        LET m_fields[i].name = m_zoom.column[i].columnname
        -- TODO consider removing one character shortcut and force use of full datatype name
        CASE m_zoom.column[i].datatypec
            WHEN "i" LET m_fields[i].type = "INTEGER"
            WHEN "d" LET m_fields[i].type = "DATE"
            WHEN "f" LET m_fields[i].type = "FLOAT"
            OTHERWISE LET m_fields[i].type = "STRING"
        END CASE
    END FOR
END FUNCTION