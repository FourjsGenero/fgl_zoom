For initial installation instructions, read INSTALL_TEST.txt
For instructions on how to incorporate in your programs, read INSTALL.txt
For license conditions read LICENSE.txt
For file listing read FILELIST.txt
For compatability refer COMPATABILITY.txt
For changes refer CHANGES.txt



Introduction
------------

fgl_zoom is intended as a Generic Zoom / Lookup / Query window

For a given SELECT SQL statement, it allows you to add some QBE criteria, list 
rows that match the criteria, and return selected value(s)/row(s) to the calling 
program.

It is intended that you would create some wrapper routines that wrap around 
a series of fgl_zoom calls e.g.

IMPORT FGL fgl_zoom

FUNCTION zoom_tabid()
DEFINE tabid INTEGER
   CALL fgl_zoom.init()
   CALL fgl_zoom.sql_set("SELECT tabid, tabname FROM systables WHERE %1")
   CALL fgl_zoom.column_quick_set(1,"tabid","i",4,"ID")  
   CALL fgl_zoom.column_quick_set(2,"tabname","c",20,"Name")
   CALL fgl_zoom.call() RETURNING tabid
   RETURN tabid
END FUNCTION

and you would call your wrapper routine from your DIALOG statements e.g.

ON ACTION zoom INFIELD tabid
   LET tabid = zoom_tabid()

   

Intended usage would follow this broad pattern.

To clear the fgl_zoom settings, use the following call

CALL fgl_zoom.init()

To configure, you can use one or more of the following functions

CALL fgl_zoom.sql_set(sql)                - define the SQL used in the zoom.  This SQL should have %1 where the where clause will be substituted with the result of the QBE
CALL fgl_zoom.title_set(STRING)           - set the title of the zoom window
CALL fgl_zoom.cancelvalue_set(STRING)     - the value to return if user cancels 
CALL fgl_zoom.noqbe_set(BOOLEAN)          - set to true if you dont want the QBE window to appear
CALL fgl_zoom.nolist_set(BOOLEAN)         - set to true if you dont want the List of results to appear
CALL fgl_zoom.gotolist_set(BOOLEAN)       - set to true to dislay the results first without initially doing a QBE
CALL fgl_zoom.autoselect_set(BOOLEAN)     - set to true if you want the window to return immediately if only row is found
CALL fgl_zoom.multiplerow_set(BOOLEAN)    - set to true to allow the user to select multiple row

For each column specified in the call to fgl_zoom.sql_set() you would specify one or more of the following functions

CALL fgl_zoom.column_column_set(COLUMN, STRING)           - The SQL column name
CALL fgl_zoom.column_title_set(COLUMN, STRING)            - The title of the column
CALL fgl_zoom.column_format_set(COLUMN, STRING)           - The format to display the column
CALL fgl_zoom.column_datatypec_set(COLUMN, ["c"|"d"|"f"|"i"]) - Set the datatype of the column, (c)har, (d)ate, (f)loat, (i)nteger
CALL fgl_zoom.column_width_set(COLUMN, INTEGER)           - The width of the column
CALL fgl_zoom.column_justify_set(COLUMN, ["left"|"right"|"center"]) - Set the justification of the column
CALL fgl_zoom.column_excludeqbe_set(COLUMN, BOOLEAN)      - Set to true to exclude column from QBE
CALL fgl_zoom.column_excludelist_set(COLUMN, BOOLEAN)     - Set to true to exclude column from result list)
CALL fgl_zoom.column_includeinresult_set(COLUMN, BOOLEAN) - Set to true to include column in return values
CALL fgl_zoom.column_qbedefault_set(COLUMN, STRING)       - Default expression to set in QBE field

To ease programming an ease of access function is provided to set a column 
quickly in one line

CALL fgl_zoom.column_quick_set(COLUMN,column_name, datatypec, width, title)

This calls column_column_set, column_datatypec_set, column_width_set, 
column_title_set as well as callling column_justify_set(right) if it is a 
numeric field.  It also sets includeinresult_set to TRUE for the first column, FALSE
for the other columns





To execute the zoom window, there is a choice of 2 methods

CALL fgl_zoom.call() RETURNING STRING - Execute the zoom window and return the value in the first column of the first row selected

OR

CALL fgl_zoom.execute()               - Execute the zoom window

You then make one or more of the following calls to get the values selected and additional info

CALL fgl_zoom.result_get(ROW,COLUMN) RETURNING STRING  - Return the value in the specified ROW,COLUMN of the selected rows
CALL fgl_zoom.result_length_get() RETURNING INTEGER    - Return the number of rows selected

CALL fgl_zoom.where_get() RETURNING STRING             - Return the QBE clause generated in the QBE screen
CALL fgl_zoom.qbe_get() RETURNING STRING               - Return the selected values pipe delimited suitable for inclusion in a CONSTRUCT field
CALL fgl_zoom.result_rowlength_get() RETURNING INTEGER - Return the number of columns in the result selected



The following is an examle of a simple zoom window call

CALL fgl_zoom.init()
CALL fgl_zoom.sql_set("SELECT tabid, tabname FROM systables WHERE %1")
CALL fgl_zoom.column_quick_set(1,"tabid","i",4,"ID")  
CALL fgl_zoom.column_quick_set(2,"tabname","c",20,"Name")
CALL fgl_zoom.call() RETURNING tabid



INSPIRATION

The routines here are based on Quanta's query_win().  This can be found in
the IIUG repository (http://www.iiug.org/software/index_I4GL.html)

Century also had a similar routine that ran off database entries.  It would be
possible to implement these routines to run off some database or XML 
configuration so that changes didn't require compilation.