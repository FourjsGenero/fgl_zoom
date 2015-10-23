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
#       fgl_zoom_functionaltest.4gl
#
#       January 2011 Reuben Barclay reuben@4js.com.au

#+ Allow testing of specific generic zoom window options
#+
#+ Test the generic zoom by allowing the effect of individual options to be 
#+ observed.  The user can select from a number of different zoom options, all 
#+ of which highlight an individual configurations setting

IMPORT FGL fgl_zoom

DEFINE m_functionaltest RECORD
   default, qbedefault, straight2list, noqbe, excludeqbe, excludelist, union, subquery, autoselect1, autoselect2, maxrow20, qbeforce3, qbeforce4 INTEGER,
   nolist, qbe, choosecolumn STRING
END RECORD
DEFINE m_functionaltest_twocolumn RECORD
   twocolumn1 INTEGER, twocolumn2 STRING
END RECORD
DEFINE m_functionaltest_single DYNAMIC ARRAY OF RECORD
   id INTEGER
END RECORD
DEFINE m_functionaltest_multiple DYNAMIC ARRAY OF RECORD
   id INTEGER, desc STRING
END RECORD



#+ set the exception handling
PRIVATE FUNCTION exception()
   WHENEVER ANY ERROR RAISE
END FUNCTION



#+ initialise functionaltest parameters
FUNCTION init()
   INITIALIZE m_functionaltest.* TO NULL
   INITIALIZE m_functionaltest_twocolumn.* TO NULL
   CALL m_functionaltest_single.clear()
   CALL m_functionaltest_multiple.clear()
END FUNCTION



#+ test individual features
#+
#+ Allow a user to test individual features of generic zoom by starting with
#+ a basic test, as defined by base_init() and then add extra calls to test
#+ the effect of various parameters.
FUNCTION test()
DEFINE i INTEGER
DEFINE l_mode STRING

   DIALOG ATTRIBUTES(UNBUFFERED)
   INPUT BY NAME m_functionaltest.*  ATTRIBUTES(WITHOUT DEFAULTS=TRUE, NAME="main")

      -- A zoom using the default options
      ON ACTION zoom INFIELD default
         CALL base_init()
         CALL fgl_zoom.title_set("Default Values")
         LET m_functionaltest.default = fgl_zoom.call()

      -- A zoom where some QBE defaults are specified.
      -- Use these where the data table has a large number of rows
      -- and you don't want all rows searched if the user simply presses ENTER
      ON ACTION zoom INFIELD qbedefault
         CALL base_init()
         CALL fgl_zoom.column_qbedefault_set(1,"<100")
         CALL fgl_zoom.column_qbedefault_set(2,"A:MZ")
         CALL fgl_zoom.column_qbedefault_set(3,SFMT(">='%1'",(TODAY-365)))
         CALL fgl_zoom.column_qbedefault_set(4,"<12:00:00")
         CALL fgl_zoom.column_qbedefault_set(5,">100")
         CALL fgl_zoom.column_qbedefault_set(6,">100")
         CALL fgl_zoom.title_set("Default QBE Values")
         LET m_functionaltest.qbedefault = fgl_zoom.call()
         
      -- A zoom that goes straight to list
      -- Use this when you know the number of rows is not too large
      ON ACTION zoom INFIELD straight2list
         CALL base_init()
         CALL fgl_zoom.gotolist_set(TRUE)
         CALL fgl_zoom.title_set("Straight to List")
         LET m_functionaltest.straight2list = fgl_zoom.call()

      -- Disable the QBE button
      ON ACTION zoom INFIELD noqbe
         CALL base_init()
         CALL fgl_zoom.noqbe_set(TRUE)
         CALL fgl_zoom.title_set("No QBE")
         LET m_functionaltest.noqbe = fgl_zoom.call()

      -- If the QBE results in one row being selected, return straight away
      -- Don't force the user to select the only row
      ON ACTION zoom INFIELD autoselect1
         CALL base_init()
         CALL fgl_zoom.autoselect_set(TRUE)
         CALL fgl_zoom.column_qbedefault_Set(1,"1")
         CALL fgl_zoom.title_set("AutoSelect")
         LET m_functionaltest.autoselect1 = fgl_zoom.call()

      -- Similar to above, but there is no QBE so it looks like it the zoom
      -- populates the value straight away
      ON ACTION zoom INFIELD autoselect2
         CALL base_init()
         CALL fgl_zoom.autoselect_set(TRUE)
         CALL fgl_zoom.noqbe_set(TRUE)
         CALL fgl_zoom.sql_set("SELECT %2 FROM fgl_zoom_test WHERE %1 AND id=1")
         CALL fgl_zoom.title_set("AutoSelect")
         LET m_functionaltest.autoselect2 = fgl_zoom.call()

      -- Limit the maximum number of rows that are returned.  Normally this also
      -- forces the user to enter some appropriate QBE parameters
      ON ACTION zoom INFIELD maxrow20
         CALL base_init()
         CALL fgl_zoom.maxrow_set(20)
         CALL fgl_zoom.title_set("Max 20 rows returned")
         LET m_functionaltest.maxrow20 = fgl_zoom.call()

      -- A zoom that forces the user to enter some QBE criteria
      -- Use this 
      ON ACTION zoom INFIELD qbeforce3
         CALL base_init()
         CALL fgl_zoom.qbeforce_set(TRUE)
         CALL fgl_zoom.title_set("Force QBE")
         LET m_functionaltest.qbeforce3 = fgl_zoom.call()

      -- A zoom that forces the user to enter some QBE criteria
      -- Use this 
      ON ACTION zoom INFIELD qbeforce4
         CALL base_init()
         CALL fgl_zoom.column_qbeforce_set(1, TRUE)
         CALL fgl_zoom.title_set("Force QBE in first column")
         LET m_functionaltest.qbeforce4 = fgl_zoom.call()

      -- Control what column is returned
      ON ACTION zoom INFIELD choosecolumn
         CALL base_init()
         CALL fgl_zoom.column_includeinresult_set(1,FALSE)
         CALL fgl_zoom.column_includeinresult_set(2,TRUE)
         CALL fgl_zoom.title_set("Return the second column in the result")
         LET m_functionaltest.choosecolumn = fgl_zoom.call()

      -- Exclude a column from the QBE, but display it in the list
      ON ACTION zoom INFIELD excludeqbe
         CALL base_init()
         CALL fgl_zoom.column_excludeqbe_set(1,TRUE)
         CALL fgl_zoom.title_set("Exclude a column from the QBE")
         LET m_functionaltest.excludeqbe = fgl_zoom.call()

      -- Exclude a column from the list, but display it in the QBE
      ON ACTION zoom INFIELD excludelist
         CALL base_init()
         CALL fgl_zoom.column_excludelist_set(1,TRUE)
         CALL fgl_zoom.title_set("Exclude a column from the list")
         LET m_functionaltest.excludelist = fgl_zoom.call()

      -- Only show the QBE.  Use as a generic way to enter a where clause
      ON ACTION zoom INFIELD nolist
         CALL base_init()
         CALL fgl_zoom.title_set("Return a Where Clause")
         CALL fgl_zoom.nolist_set(TRUE)
         CALL fgl_zoom.execute()
         LET m_functionaltest.nolist = fgl_zoom.where_get()

      -- For use with a CONSTRUCT statement, return the QBE construct clause
      -- that could be used to select the selected values i.e pipe delimited
      ON ACTION zoom INFIELD qbe
         CALL base_init()
         CALL fgl_zoom.title_set("Return equivalent of a QBE Construct Clause")
         CALL fgl_zoom.multiplerow_set(TRUE)
         CALL fgl_zoom.execute()
         LET m_functionaltest.qbe = fgl_zoom.qbe_get()


      -- An example with a UNION clause in the SQL
      -- The important thing to consider is should the WHERE clause be added
      -- to both sides of the UNION?
      ON ACTION zoom INFIELD union
         CALL base_init()
         CALL fgl_zoom.sql_set("SELECT id, desc, date_created, time_created, quantity, price, '******' FROM fgl_zoom_test WHERE %1 AND quantity < 100 UNION SELECT id, desc, date_created, time_created, quantity, price, '' FROM fgl_zoom_test WHERE %1 AND quantity >= 100 ORDER BY 1")
         CALL fgl_zoom.title_set("A UNION SQL")
         CALL fgl_zoom.column_quick_set(7,"(constant)","c", 6, "Low Stock")
         CALL fgl_zoom.column_excludeqbe_set(7, TRUE)
         LET m_functionaltest.union = fgl_zoom.call()

      -- An example with a subquery in the SQL
      -- The important thing to consider is where should the where clause be 
      -- added
      ON ACTION zoom INFIELD subquery
         CALL base_init()
         CALL fgl_zoom.sql_set("SELECT id, desc, date_created, time_created, quantity, price, 1+(SELECT COUNT(*) FROM fgl_zoom_test b WHERE %1 AND a.quantity < b.quantity) FROM fgl_zoom_test a WHERE %1 " )
         CALL fgl_zoom.title_set("A SQL with a sub-query")
         CALL fgl_zoom.column_quick_set(7,"rank","i", 4,"Qty Rank")
         CALL fgl_zoom.column_excludeqbe_set(7, TRUE)
         LET m_functionaltest.subquery = fgl_zoom.call() 

      END INPUT

      -- An example where 2 columns are returned from the zoom.  Normally used
      -- for composite keys
      INPUT BY NAME m_functionaltest_twocolumn.* ATTRIBUTES(WITHOUT DEFAULTS=TRUE, NAME="twocolumn")
         ON ACTION zoom 
            CALL base_init()
            CALL fgl_zoom.column_includeinresult_set(1,TRUE)
            CALL fgl_zoom.column_includeinresult_set(2,TRUE)
            
            CALL fgl_zoom.title_set("Return first 2 columns in the result")
            CALL fgl_zoom.execute()
            LET m_functionaltest_twocolumn.twocolumn1 = fgl_zoom.result_get(1,1)
            LET m_functionaltest_twocolumn.twocolumn2 = fgl_zoom.result_get(1,2)
      END INPUT

      -- An example where the user can select multiple rows in the zoom window.
      DISPLAY ARRAY m_functionaltest_single TO single.* 
         ON ACTION zoom
            CALL base_init()
            CALL fgl_zoom.multiplerow_set(TRUE)  
            CALL fgl_zoom.title_set("Return multiple rows")
            CALL fgl_zoom.execute()
            CALL m_functionaltest_single.clear()
            FOR i = 1 TO fgl_zoom.result_length_get()
               LET m_functionaltest_single[i].id = fgl_zoom.result_get(i,1)
            END FOR
      END DISPLAY

      -- An example where 2 columns are returned, and the user can select
      -- multiple rows in the same window
      DISPLAY ARRAY m_functionaltest_multiple TO multiple.* 
         ON ACTION zoom
            CALL base_init()
            CALL fgl_zoom.multiplerow_set(TRUE)  
            CALL fgl_zoom.column_includeinresult_set(1,TRUE)
            CALL fgl_zoom.column_includeinresult_set(2,TRUE)
            CALL fgl_zoom.title_set("Return multiple rows and columns" )
            CALL fgl_zoom.execute()
            CALL m_functionaltest_multiple.clear()
            FOR i = 1 TO fgl_zoom.result_length_get()
               LET m_functionaltest_multiple[i].id = fgl_zoom.result_get(i,1)
               LET m_functionaltest_multiple[i].desc = fgl_zoom.result_get(i,2)
            END FOR
            
      END DISPLAY

      ON ACTION custom
         LET l_mode = "custom"
         EXIT DIALOG

      ON ACTION example
         LET l_mode = "example"
         EXIT DIALOG
      
      ON ACTION close
         LET l_mode = "exit"
         EXIT DIALOG
      
   END DIALOG
   RETURN l_mode
END FUNCTION



#+ To save typing in the same methods each time, all tests start with this
PRIVATE FUNCTION base_init()
   CALL fgl_zoom.init()
   CALL fgl_zoom.sql_set("SELECT %2 FROM fgl_zoom_test WHERE %1")
   CALL fgl_zoom.cancelvalue_set(FGL_DIALOG_GETBUFFER())

   -- Example of an integer column
   CALL fgl_zoom.column_quick_set(1,"id","i",4,"ID")

   -- Example of a char column
   CALL fgl_zoom.column_quick_set(2,"desc","c",20,"Description")

   -- Example of a date column
   CALL fgl_zoom.column_quick_set(3,"date_created","d",10,"Date Created")
   CALL fgl_zoom.column_format_set(3,"dd/mm/yyyy")
   CALL fgl_zoom.column_justify_set(3,"center")

   -- Example of a datetime column
   CALL fgl_zoom.column_quick_set(4,"time_created","c",10,"Time Created")
   CALL fgl_zoom.column_justify_set(4,"center")

   -- Example of 2 decimal columns
   CALL fgl_zoom.column_quick_set(5,"quantity","f",11,"Quantity")
   CALL fgl_zoom.column_format_set(5,"----,--&.&&")
   
   CALL fgl_zoom.column_quick_set(6,"price","f",11,"Price")
   CALL fgl_zoom.column_format_set(6,"----,-$&.&&")
 
END FUNCTION