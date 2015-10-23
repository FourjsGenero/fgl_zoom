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
#       fgl_zoom_custom.4gl
#
#       January 2011 Reuben Barclay reuben@4js.com.au

#+ Allow testing of the generic zoom window by allowing user to create a custom test
#+
#+ Test the generic zoom window by providing a GUI whereby the user can select
#+ the value of all the input parameters, and then interrogate the possible 
#+ output values

IMPORT FGL fgl_zoom

DEFINE m_custom_rec RECORD
   sql STRING,
   title2 STRING,
   cancelvalue STRING,
   noqbe2 BOOLEAN,
   nolist2 BOOLEAN, 
   gotolist BOOLEAN, 
   autoselect BOOLEAN, 
   multiplerow BOOLEAN,
   maxrow INTEGER,
   freezeleft INTEGER,
   freezeright INTEGER,
   qbeforce BOOLEAN
END RECORD
DEFINE m_custom_arr DYNAMIC ARRAY OF RECORD
   columnname STRING,
   title3 STRING,
   width INTEGER,
   format STRING,
   datatypec CHAR(1),
   justify STRING,
   excludeqbe2 BOOLEAN,
   excludelist2 BOOLEAN,
   includeinresult BOOLEAN,
   qbedefault STRING,
   qbeforce2 BOOLEAN
END RECORD
DEFINE m_custom_result RECORD
   selected_row, selected_column INTEGER,
   value STRING,
   where_clause STRING
END RECORD



#+ Set the exception handling
PRIVATE FUNCTION exception()
    WHENEVER ANY ERROR RAISE
END FUNCTION



FUNCTION init()

   INITIALIZE m_custom_rec.* TO NULL
   LET m_custom_rec.sql = "SELECT %2 FROM fgl_zoom_test WHERE %1"
   LET m_custom_rec.title2= "fgl_zoom() Custom Test"
   LET m_custom_rec.noqbe2 = FALSE
   LET m_custom_rec.nolist2 = FALSE
   LET m_custom_rec.gotolist = FALSE
   LET m_custom_rec.autoselect = FALSE
   LET m_custom_rec.multiplerow = FALSE
   LET m_custom_rec.maxrow = 0
   LET m_custom_rec.qbeforce = FALSE
   
   LET m_custom_arr[1].columnname = "id"
   LET m_custom_arr[1].datatypec = "i"
   LET m_custom_arr[1].width = 4
   LET m_custom_arr[1].title3 = "ID"
   LET m_custom_arr[1].justify = "right"
   LET m_custom_arr[1].excludeqbe2 = FALSE
   LET m_custom_arr[1].excludelist2 = FALSE
   LET m_custom_arr[1].includeinresult = TRUE
   LET m_custom_arr[1].qbeforce2 = TRUE
   
   LET m_custom_arr[2].columnname = "desc"
   LET m_custom_arr[2].datatypec = "c"
   LET m_custom_arr[2].width = 20
   LET m_custom_arr[2].title3 = "Description"
   LET m_custom_arr[2].justify = "left"
   LET m_custom_arr[2].excludeqbe2 = FALSE
   LET m_custom_arr[2].excludelist2 = FALSE
   LET m_custom_arr[2].includeinresult = TRUE
   LET m_custom_arr[2].qbeforce2 = FALSE
   
   LET m_custom_arr[3].columnname = "date_created"
   LET m_custom_arr[3].datatypec = "d"
   LET m_custom_arr[3].width = 10
   LET m_custom_arr[3].title3 = "Date Created"
   LET m_custom_arr[3].format = "dd/mm/yyyy"
   LET m_custom_arr[3].justify = "center"
   LET m_custom_arr[3].excludeqbe2 = FALSE
   LET m_custom_arr[3].excludelist2 = FALSE
   LET m_custom_arr[3].includeinresult = TRUE
   LET m_custom_arr[3].qbeforce2 = FALSE

   LET m_custom_arr[4].columnname = "time_created"
   LET m_custom_arr[4].datatypec = "c"
   LET m_custom_arr[4].width = 8
   LET m_custom_arr[4].title3 = "Time Created"
   LET m_custom_arr[4].format = ""
   LET m_custom_arr[4].justify = "center"
   LET m_custom_arr[4].excludeqbe2 = FALSE
   LET m_custom_arr[4].excludelist2 = FALSE
   LET m_custom_arr[4].includeinresult = TRUE
   LET m_custom_arr[4].qbeforce2 = FALSE

   LET m_custom_arr[5].columnname = "quantity"
   LET m_custom_arr[5].datatypec = "f"
   LET m_custom_arr[5].width = 11
   LET m_custom_arr[5].title3 = "Quantity"
   LET m_custom_arr[5].format = "----,--&.&&"
   LET m_custom_arr[5].justify = "right"
   LET m_custom_arr[5].excludeqbe2 = FALSE
   LET m_custom_arr[5].excludelist2 = FALSE
   LET m_custom_arr[5].includeinresult = TRUE
   LET m_custom_arr[5].qbeforce2 = FALSE

   LET m_custom_arr[6].columnname = "price"
   LET m_custom_arr[6].datatypec = "f"
   LET m_custom_arr[6].width = 11
   LET m_custom_arr[6].title3 = "Price"
   LET m_custom_arr[6].format = "----,-$&.&&"
   LET m_custom_arr[6].justify = "right"
   LET m_custom_arr[6].excludeqbe2 = FALSE
   LET m_custom_arr[6].excludelist2 = FALSE
   LET m_custom_arr[6].includeinresult = TRUE
   LET m_custom_arr[6].qbeforce2 = FALSE

   INITIALIZE m_custom_result.* TO NULL
   LET m_custom_result.selected_column = 1
   LET m_custom_result.selected_row = 1
END FUNCTION



FUNCTION test()
DEFINE l_mode STRING
DEFINE i INTEGER
DEFINE l_new_row_idx INTEGER

   DIALOG ATTRIBUTES(UNBUFFERED)
      INPUT BY NAME m_custom_rec.* ATTRIBUTES(WITHOUT DEFAULTS=TRUE)
      END INPUT
      
      INPUT ARRAY m_custom_arr FROM custom_scr.* ATTRIBUTES(WITHOUT DEFAULTS=TRUE)
         BEFORE INSERT
            LET l_new_row_idx = DIALOG.getCurrentRow("custom_scr")
            LET m_custom_arr[l_new_row_idx].datatypec = "c"
            LET m_custom_arr[l_new_row_idx].justify = "left"
            LET m_custom_arr[l_new_row_idx].excludeqbe2 = FALSE
            LET m_custom_arr[l_new_row_idx].excludelist2 = FALSE
            LET m_custom_arr[l_new_row_idx].includeinresult = TRUE
            LET m_custom_arr[l_new_row_idx].qbeforce2 = FALSE
      END INPUT

      INPUT BY NAME m_custom_result.*
         ON CHANGE selected_row
            LET m_custom_result.value = fgl_zoom.result_get(m_custom_result.selected_row, m_custom_result.selected_column)
            
         ON CHANGE selected_column
            LET m_custom_result.value = fgl_zoom.result_get(m_custom_result.selected_row, m_custom_result.selected_column)
      END INPUT

      ON ACTION execute
         CALL fgl_zoom.init()
         CALL fgl_zoom.sql_set(m_custom_rec.sql)
         CALL fgl_zoom.title_set(m_custom_rec.title2)
         CALL fgl_zoom.cancelvalue_set(m_custom_rec.cancelvalue)
         CALL fgl_zoom.noqbe_set(m_custom_rec.noqbe2)
         CALL fgl_zoom.nolist_set(m_custom_rec.nolist2)
         CALL fgl_zoom.gotolist_set(m_custom_rec.gotolist)
         CALL fgl_zoom.autoselect_set(m_custom_rec.autoselect)
         CALL fgl_zoom.multiplerow_set(m_custom_rec.multiplerow)
         CALL fgl_zoom.maxrow_set(m_custom_rec.maxrow)
         CALL fgl_zoom.freezeleft_set(m_custom_rec.freezeleft)
         CALL fgl_zoom.freezeright_set(m_custom_rec.freezeright)
         CALL fgl_zoom.qbeforce_set(m_custom_rec.qbeforce)
         
         FOR i = 1 TO m_custom_arr.getLength()
            CALL fgl_zoom.column_columnname_set(i,m_custom_arr[i].columnname)
            CALL fgl_zoom.column_title_set(i,m_custom_arr[i].title3)
            CALL fgl_zoom.column_width_set(i,m_custom_arr[i].width)
            CALL fgl_zoom.column_format_set(i,m_custom_arr[i].format)
            CALL fgl_zoom.column_datatypec_set(i,m_custom_arr[i].datatypec)
            CALL fgl_zoom.column_justify_set(i, m_custom_arr[i].justify)
            CALL fgl_zoom.column_excludeqbe_set(i, m_custom_arr[i].excludeqbe2)
            CALL fgl_zoom.column_excludelist_set(i, m_custom_arr[i].excludelist2)
            CALL fgl_zoom.column_includeinresult_set(i, m_custom_arr[i].includeinresult)
            CALL fgl_zoom.column_qbedefault_set(i, m_custom_arr[i].qbedefault)
            CALL fgl_zoom.column_qbeforce_set(i, m_custom_arr[i].qbeforce2)
         END FOR
         CALL fgl_zoom.execute()
         -- populate selected_row, selected_get combobox
         LET m_custom_result.selected_row = 1
         LET m_custom_result.selected_column =1
         LET m_custom_result.value = fgl_zoom.result_get(m_custom_result.selected_row, m_custom_result.selected_column)
         LET m_custom_result.where_clause = fgl_zoom.where_get()
         CALL populate_selected_row()
         CALL populate_selected_column()
         CONTINUE DIALOG

      ON ACTION functionaltest
         LET l_mode = "functionaltest"
         EXIT DIALOG

      ON ACTION example
         LET l_mode = "example"
         EXIT DIALOG

      ON ACTION viewsource
         CALL viewsource()

      ON ACTION clear
         INITIALIZE m_custom_rec.* TO NULL
         CALL m_custom_arr.clear()
         INITIALIZE m_custom_result.* TO NULL
         LET m_custom_result.selected_column = 1
         LET m_custom_result.selected_row = 1
         
      ON ACTION restore
         CALL init()

      ON ACTION CLOSE
         LET l_mode = "exit"
         EXIT DIALOG
   END DIALOG

   RETURN l_mode
END FUNCTION


PRIVATE FUNCTION viewsource()
DEFINE sb base.StringBuffer
DEFINE i INTEGER
DEFINE l_columns_returned SMALLINT
DEFINE l_continue SMALLINT

   LET l_columns_returned = 0

   LET sb = base.StringBuffer.create()
   CALL sb.append("--Initializer")
   CALL sb.append("\nCALL fgl_zoom.init()")

   CALL sb.append("\n\n--Setter")
   IF m_custom_rec.sql.getLength() > 0 THEN
      CALL sb.append(SFMT("\nCALL fgl_zoom.sql_set(\"%1\")", m_custom_rec.sql))
   END IF
   IF m_custom_rec.title2.getLength() > 0 THEN
      CALL sb.append(SFMT("\nCALL fgl_zoom.title_set(\"%1\")", m_custom_rec.title2))
   END IF
   IF m_custom_rec.cancelvalue.getLength() > 0 THEN
      CALL sb.append(SFMT("\nCALL fgl_zoom.cancelvalue_set(\"%1\")", m_custom_rec.cancelvalue))
   END IF
   IF m_custom_rec.noqbe2 THEN
      CALL sb.append("\nCALL fgl_zoom.noqbe_set(TRUE)")
   END IF
   IF m_custom_rec.nolist2 THEN
      CALL sb.append("\nCALL fgl_zoom.nolist_set(TRUE)")
   END IF
   IF m_custom_rec.gotolist THEN
      CALL sb.append("\nCALL fgl_zoom.gotolist_set(TRUE)")
   END IF
   IF m_custom_rec.autoselect THEN
      CALL sb.append("\nCALL fgl_zoom.autoselect_set(TRUE)")
   END IF
   IF m_custom_rec.multiplerow THEN
      CALL sb.append("\nCALL fgl_zoom.multiplerow_set(TRUE)")
   END IF
   IF m_custom_rec.maxrow > 0 THEN
      CALL sb.append(SFMT("\nCALL fgl_zoom.maxrow_set(%1)", m_custom_rec.maxrow))
   END IF
   IF m_custom_rec.freezeleft > 0 THEN
      CALL sb.append(SFMT("\nCALL fgl_zoom.freezeleft(%1)", m_custom_rec.freezeleft))
   END IF
   IF m_custom_rec.freezeright > 0 THEN
      CALL sb.append(SFMT("\nCALL fgl_zoom.freezeright(%1)", m_custom_rec.freezeright))
   END IF
   IF m_custom_rec.qbeforce THEN
      CALL sb.append(SFMT("\nCALL fgl_zoom.qbeforce(TRUE)", m_custom_rec.qbeforce))
   END IF

   FOR i = 1 TO m_custom_arr.getLength()
      CALL sb.append("\n")
      CALL sb.append(SFMT("\nCALL fgl_zoom.column_quick_set(%1,\"%2\",\"%3\",%4,\"%5\")", i USING "<<",m_custom_arr[i].columnname,m_custom_arr[i].datatypec, m_custom_arr[i].width USING "<<", m_custom_arr[i].title3))   

      IF m_custom_arr[i].format.getLength() THEN
         CALL sb.append(SFMT("\nCALL fgl_zoom.column_format_set(%1,\"%2\")", i USING "<<", m_custom_arr[i].format))
      END IF
      IF m_custom_arr[i].justify.getLength() > 0 THEN
         IF m_custom_arr[i].datatypec MATCHES "[fi]" THEN
            IF m_custom_arr[i].justify != "right" THEN
               CALL sb.append(SFMT("\nCALL fgl_zoom.column_justify_set(%1,\"%2\")", i USING "<<", m_custom_arr[i].justify))
            END IF
         END IF
         IF m_custom_arr[i].datatypec MATCHES "[cd]" THEN
            IF m_custom_arr[i].justify != "left" THEN
               CALL sb.append(SFMT("\nCALL fgl_zoom.column_justify_set(%1,\"%2\")", i USING "<<", m_custom_arr[i].justify))
            END IF
         END IF
      END IF

      IF m_custom_arr[i].excludeqbe2 THEN
         CALL sb.append(SFMT("\nCALL fgl_zoom.excludeqbe_set(%1,TRUE)", i USING "<<"))
      END IF
      IF m_custom_arr[i].excludelist2 THEN
         CALL sb.append(SFMT("\nCALL fgl_zoom.excludelist_set(%1,TRUE)", i USING "<<"))
      END IF
      IF m_custom_arr[i].qbedefault.getLength() THEN
         CALL sb.append(SFMT("\nCALL fgl_zoom.column_qbedefault_set(%1,\"%2\")", i USING "<<", m_custom_arr[i].qbedefault))
      END IF
      IF m_custom_arr[i].qbeforce2 THEN
         CALL sb.append(SFMT("\nCALL fgl_zoom.column_qbeforce_set(%1,TRUE)", i USING "<<"))
      END IF
      IF i = 1 AND NOT m_custom_arr[i].includeinresult THEN
         CALL sb.append(SFMT("\nCALL fgl_zoom.includeinresult_set(%1,FALSE)", i USING "<<"))
      END IF
      IF i > 1 AND m_custom_arr[i].includeinresult THEN
         CALL sb.append(SFMT("\nCALL fgl_zoom.includeinresult_set(%1,TRUE)", i USING "<<"))
      END IF
      IF m_custom_arr[i].includeinresult THEN
         LET l_columns_returned = l_columns_returned + 1
      END IF
     
      
   END FOR
            
   CALL sb.append("\n\n--Execute")
   IF l_columns_returned = 1 AND NOT m_custom_rec.multiplerow THEN
      CALL sb.append("\nLET l_result = fgl_zoom.call()")
   ELSE
      CALL sb.append("\nCALL fgl_zoom.execute()")
   END IF

   CALL sb.append("\n\n--Getter")
   IF NOT m_custom_rec.noqbe2 THEN
      CALL sb.append("\nLET l_where_clause = fgl_zoom.where_get()")
   END IF
   IF l_columns_returned = 1 AND m_custom_rec.multiplerow THEN
      CALL sb.append("\nLET l_qbe_clause = fgl_zoom.qbe_get()")
   END IF
   CASE
      WHEN l_columns_returned = 1 AND NOT m_custom_rec.multiplerow 
         # do nothing, use fgl_zoom.call instead
      WHEN l_columns_returned = 1 AND m_custom_rec.multiplerow 
         CALL sb.append("\nFOR l_row = 1 TO fgl_zoom.result_length_get()")
         CALL sb.append("\n   LET l_value[l_row] = fgl_zoom.result_get(l_row, 1)")
         CALL sb.append("\nEND FOR")
      OTHERWISE
         CALL sb.append("\nFOR l_row = 1 TO fgl_zoom.result_length_get()")
         CALL sb.append("\n   FOR l_col = 1 TO fgl_zoom.result_rowlength_get(l_row)")
         CALL sb.append("\n      LET l_value[l_row,l_col] = fgl_zoom.result_get(l_row, l_col)")
         CALL sb.append("\n   END FOR")
         CALL sb.append("\nEND FOR")
   END CASE

   LET l_continue = TRUE
   WHILE l_continue
      MENU "" ATTRIBUTES(STYLE="dialog", COMMENT=sb.toString())
         COMMAND "Copy to Clipboard"
            CALL ui.Interface.frontCall("standard","cbset",sb.toString(),[])
         COMMAND "Exit" 
            LET l_continue = FALSE
         ON ACTION CLOSE
            LET l_continue = FALSE
      END MENU
   END WHILE
   
END FUNCTION



PRIVATE FUNCTION populate_selected_column()
DEFINE cb ui.ComboBox
DEFINE i, l_length INTEGER

   LET cb = ui.ComboBox.forName("selected_column")
   CALL cb.clear()
   IF fgl_zoom.result_length_get() > 0 THEN
      LET l_length = fgl_zoom.result_rowlength_get(1)
   ELSE
      LET l_length = 0
   END IF
   FOR i = 1 TO l_length
      CALL cb.addItem(i,i)
   END FOR
END FUNCTION



PRIVATE FUNCTION populate_selected_row()
DEFINE cb ui.ComboBox
DEFINE i, l_length INTEGER

   LET cb = ui.ComboBox.forName("selected_row")
   CALL cb.clear()
   LET l_length = fgl_zoom.result_length_get()
   FOR i = 1 TO l_length
      CALL cb.addItem(i,i)
   END FOR
END FUNCTION