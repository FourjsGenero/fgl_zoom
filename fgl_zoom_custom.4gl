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
    auto BOOLEAN,
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
    LET m_custom_rec.auto = FALSE
    LET m_custom_rec.title2 = "fgl_zoom() Custom Test"
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
    LET m_custom_arr[2].includeinresult = FALSE
    LET m_custom_arr[2].qbeforce2 = FALSE

    LET m_custom_arr[3].columnname = "date_created"
    LET m_custom_arr[3].datatypec = "d"
    LET m_custom_arr[3].width = 10
    LET m_custom_arr[3].title3 = "Date Created"
    LET m_custom_arr[3].format = "dd/mm/yyyy"
    LET m_custom_arr[3].justify = "center"
    LET m_custom_arr[3].excludeqbe2 = FALSE
    LET m_custom_arr[3].excludelist2 = FALSE
    LET m_custom_arr[3].includeinresult = FALSE
    LET m_custom_arr[3].qbeforce2 = FALSE

    LET m_custom_arr[4].columnname = "time_created"
    LET m_custom_arr[4].datatypec = "c"
    LET m_custom_arr[4].width = 8
    LET m_custom_arr[4].title3 = "Time Created"
    LET m_custom_arr[4].format = ""
    LET m_custom_arr[4].justify = "center"
    LET m_custom_arr[4].excludeqbe2 = FALSE
    LET m_custom_arr[4].excludelist2 = FALSE
    LET m_custom_arr[4].includeinresult = FALSE
    LET m_custom_arr[4].qbeforce2 = FALSE

    LET m_custom_arr[5].columnname = "quantity"
    LET m_custom_arr[5].datatypec = "f"
    LET m_custom_arr[5].width = 11
    LET m_custom_arr[5].title3 = "Quantity"
    LET m_custom_arr[5].format = "----,--&.&&"
    LET m_custom_arr[5].justify = "right"
    LET m_custom_arr[5].excludeqbe2 = FALSE
    LET m_custom_arr[5].excludelist2 = FALSE
    LET m_custom_arr[5].includeinresult = FALSE
    LET m_custom_arr[5].qbeforce2 = FALSE

    LET m_custom_arr[6].columnname = "price"
    LET m_custom_arr[6].datatypec = "f"
    LET m_custom_arr[6].width = 11
    LET m_custom_arr[6].title3 = "Price"
    LET m_custom_arr[6].format = "----,-$&.&&"
    LET m_custom_arr[6].justify = "right"
    LET m_custom_arr[6].excludeqbe2 = FALSE
    LET m_custom_arr[6].excludelist2 = FALSE
    LET m_custom_arr[6].includeinresult = FALSE
    LET m_custom_arr[6].qbeforce2 = FALSE

    INITIALIZE m_custom_result.* TO NULL
    LET m_custom_result.selected_column = 1
    LET m_custom_result.selected_row = 1
END FUNCTION

FUNCTION test()
    DEFINE l_mode STRING
    DEFINE i INTEGER
    DEFINE l_new_row_idx INTEGER
    DEFINE l_zoom fgl_zoom.zoomType

    DIALOG ATTRIBUTES(UNBUFFERED)
        INPUT BY NAME m_custom_rec.* ATTRIBUTES(WITHOUT DEFAULTS = TRUE)
            ON CHANGE auto
                IF m_custom_rec.auto AND m_custom_arr.getLength() > 0 THEN
                    IF FGL_WINQUESTION("Question", "Do you want to clear column array values?", "yes", "yes|no", "fa-quest", 0)
                            = "yes"
                        THEN
                        CALL m_custom_arr.clear()
                    END IF
                END IF
        END INPUT

        INPUT ARRAY m_custom_arr FROM custom_scr.* ATTRIBUTES(WITHOUT DEFAULTS = TRUE)
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
                LET m_custom_result.value = l_zoom.result[m_custom_result.selected_row, m_custom_result.selected_column]

            ON CHANGE selected_column
                LET m_custom_result.value = l_zoom.result[m_custom_result.selected_row, m_custom_result.selected_column]
        END INPUT

        ON ACTION execute
            CALL l_zoom.init()
            LET l_zoom.sql = m_custom_rec.sql
            IF m_custom_rec.auto THEN
                CALL l_zoom.column_auto_set()
            END IF
            LET l_zoom.title = m_custom_rec.title2
            LET l_zoom.cancelvalue = m_custom_rec.cancelvalue
            LET l_zoom.noqbe = m_custom_rec.noqbe2
            LET l_zoom.nolist = m_custom_rec.nolist2
            LET l_zoom.gotolist = m_custom_rec.gotolist
            LET l_zoom.autoselect = m_custom_rec.autoselect
            LET l_zoom.multiplerow = m_custom_rec.multiplerow
            LET l_zoom.maxrow = m_custom_rec.maxrow
            LET l_zoom.freezeleft = m_custom_rec.freezeleft
            LET l_zoom.freezeright = m_custom_rec.freezeright
            LET l_zoom.qbeforce = m_custom_rec.qbeforce

            FOR i = 1 TO m_custom_arr.getLength()
                LET l_zoom.column[i].columnname = m_custom_arr[i].columnname
                LET l_zoom.column[i].title = m_custom_arr[i].title3
                LET l_zoom.column[i].width = m_custom_arr[i].width
                LET l_zoom.column[i].format = m_custom_arr[i].format
                LET l_zoom.column[i].datatypec = m_custom_arr[i].datatypec
                LET l_zoom.column[i].justify = m_custom_arr[i].justify
                LET l_zoom.column[i].excludeqbe = m_custom_arr[i].excludeqbe2
                LET l_zoom.column[i].excludelist = m_custom_arr[i].excludelist2
                LET l_zoom.column[i].includeinresult = m_custom_arr[i].includeinresult
                LET l_zoom.column[i].qbedefault = m_custom_arr[i].qbedefault
                LET l_zoom.column[i].qbeforce = m_custom_arr[i].qbeforce2
            END FOR
            CALL l_zoom.execute()
            -- populate selected_row, selected_get combobox
            LET m_custom_result.selected_row = 1
            LET m_custom_result.selected_column = 1
            LET m_custom_result.value = l_zoom.result[m_custom_result.selected_row, m_custom_result.selected_column]
            LET m_custom_result.where_clause = l_zoom.where
            CALL comboinit_selected_row(l_zoom.result.getLength())
            IF l_zoom.result.getLength() > 0 THEN
                CALL comboinit_selected_column(l_zoom.result[1].getLength())
            ELSE
                CALL comboinit_selected_column(0)
            END IF
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
    CALL sb.append("IMPORT FGL fgl_zoom")
    CALL sb.append("\n\nDEFINE l_zoom fgl_zoom.zoomType")
    CALL sb.append("\n\n--Initializer")
    CALL sb.append("\nCALL l_zoom.init()")

    CALL sb.append("\n\n--Setter")
    IF m_custom_rec.sql.getLength() > 0 THEN
        CALL sb.append(SFMT("\nLET l_zoom.sql = \"%1\"", m_custom_rec.sql))
    END IF
    IF m_custom_rec.auto THEN
        CALL sb.append("\nLET l_zoom.column_auto = true")
    END IF
    IF m_custom_rec.title2.getLength() > 0 THEN
        CALL sb.append(SFMT("\nLET l_zoom.title_set(\"%1\")", m_custom_rec.title2))
    END IF
    IF m_custom_rec.cancelvalue.getLength() > 0 THEN
        CALL sb.append(SFMT("\nLET l_zoom.cancelvalue_set(\"%1\")", m_custom_rec.cancelvalue))
    END IF
    IF m_custom_rec.noqbe2 THEN
        CALL sb.append("\nLET l_zoom.noqbe = TRUE")
    END IF
    IF m_custom_rec.nolist2 THEN
        CALL sb.append("\nLET l_zoom.nolist = TRUE")
    END IF
    IF m_custom_rec.gotolist THEN
        CALL sb.append("\nLET l_zoom.gotolist = TRUE")
    END IF
    IF m_custom_rec.autoselect THEN
        CALL sb.append("\nLET l_zoom.autoselect = TRUE")
    END IF
    IF m_custom_rec.multiplerow THEN
        CALL sb.append("\nLET l_zoom.multiplerow = true")
    END IF
    IF m_custom_rec.maxrow > 0 THEN
        CALL sb.append(SFMT("\nLET l_zoom.maxrow = %1", m_custom_rec.maxrow))
    END IF
    IF m_custom_rec.freezeleft > 0 THEN
        CALL sb.append(SFMT("\nLET l_zoom.freezeleft = %1", m_custom_rec.freezeleft))
    END IF
    IF m_custom_rec.freezeright > 0 THEN
        CALL sb.append(SFMT("\nLET l_zoom.freezeright = %1", m_custom_rec.freezeright))
    END IF
    IF m_custom_rec.qbeforce THEN
        CALL sb.append(SFMT("\nLET l_zoom.qbeforce = true", m_custom_rec.qbeforce))
    END IF

    FOR i = 1 TO m_custom_arr.getLength()
        CALL sb.append("\n")
        CALL sb.append(
            SFMT("\nCALL l_zoom.column[%1].quick_set(\"%2\",%6,\"%3\",%4,\"%5\")",
                i USING "<<",
                m_custom_arr[i].columnname,
                m_custom_arr[i].datatypec,
                m_custom_arr[i].width USING "<<",
                m_custom_arr[i].title3,
                IIF(m_custom_arr[i].includeinresult, "true", "false")))

        IF m_custom_arr[i].format.getLength() THEN
            CALL sb.append(SFMT("\nLET l_zoom.column[%1].format = \"%2\"", i USING "<<", m_custom_arr[i].format))
        END IF
        IF m_custom_arr[i].justify.getLength() > 0 THEN
            IF m_custom_arr[i].datatypec MATCHES "[fi]" THEN
                IF m_custom_arr[i].justify != "right" THEN
                    CALL sb.append(SFMT("\LET l_zoom.column[%1].justify = \"%2\"", i USING "<<", m_custom_arr[i].justify))
                END IF
            END IF
            IF m_custom_arr[i].datatypec MATCHES "[cd]" THEN
                IF m_custom_arr[i].justify != "left" THEN
                    CALL sb.append(SFMT("\nLET l_zoom.column[%1].justify = \"%2\"", i USING "<<", m_custom_arr[i].justify))
                END IF
            END IF
        END IF

        IF m_custom_arr[i].excludeqbe2 THEN
            CALL sb.append(SFMT("\nLET l_zoom.column[%1].excludeqbe = TRUE", i USING "<<"))
        END IF
        IF m_custom_arr[i].excludelist2 THEN
            CALL sb.append(SFMT("\nLET l_zoom.column[%1].excludelist = TRUE", i USING "<<"))
        END IF
        IF m_custom_arr[i].qbedefault.getLength() THEN
            CALL sb.append(SFMT("\nLET l_zoom.column[%1].qbedefault = \"%2\"", i USING "<<", m_custom_arr[i].qbedefault))
        END IF
        IF m_custom_arr[i].qbeforce2 THEN
            CALL sb.append(SFMT("\nLET l_zoom.column[%1].qbeforce = TRUE", i USING "<<"))
        END IF

        IF m_custom_arr[i].includeinresult THEN
            LET l_columns_returned = l_columns_returned + 1
        END IF

    END FOR

    CALL sb.append("\n\n--Execute")
    IF l_columns_returned = 1 AND NOT m_custom_rec.multiplerow THEN
        CALL sb.append("\nLET l_result = l_zoom.call()")
    ELSE
        CALL sb.append("\nCALL l_zoom.execute()")
    END IF

    CALL sb.append("\n\n--Getter")
    IF NOT m_custom_rec.noqbe2 THEN
        CALL sb.append("\nLET l_where_clause = l_zoom.where")
    END IF
    IF l_columns_returned = 1 AND m_custom_rec.multiplerow THEN
        CALL sb.append("\nLET l_qbe_clause = l_zoom.qbe")
    END IF
    CASE
        WHEN l_columns_returned = 1 AND NOT m_custom_rec.multiplerow
            # do nothing, use fgl_zoom.call instead
        WHEN l_columns_returned = 1 AND m_custom_rec.multiplerow
            CALL sb.append("\nFOR l_row = 1 TO l_zoom.result.getLength()")
            CALL sb.append("\n   LET l_value[l_row] = l_zoom.result[l_row, 1]")
            CALL sb.append("\nEND FOR")
        OTHERWISE
            CALL sb.append("\nFOR l_row = 1 TO l_zoom.result.getLength()")
            CALL sb.append("\n   FOR l_col = 1 TO l_zoom.result[1].getLength()")
            CALL sb.append("\n      LET l_value[l_row,l_col] = l_zoom.result[l_row, l_col]")
            CALL sb.append("\n   END FOR")
            CALL sb.append("\nEND FOR")
    END CASE

    LET l_continue = TRUE
    WHILE l_continue
        MENU "" ATTRIBUTES(STYLE = "dialog", COMMENT = sb.toString())
            COMMAND "Copy to Clipboard"
                CALL ui.Interface.frontCall("standard", "cbset", sb.toString(), [])
            COMMAND "Exit"
                LET l_continue = FALSE
            ON ACTION CLOSE
                LET l_continue = FALSE
        END MENU
    END WHILE

END FUNCTION

PRIVATE FUNCTION comboinit_selected_column(l_col_count INTEGER)
    DEFINE cb ui.ComboBox
    DEFINE i INTEGER

    LET cb = ui.ComboBox.forName("selected_column")
    CALL cb.clear()
    FOR i = 1 TO l_col_count
        CALL cb.addItem(i, i)
    END FOR
END FUNCTION

PRIVATE FUNCTION comboinit_selected_row(l_row_count INTEGER)
    DEFINE cb ui.ComboBox
    DEFINE i INTEGER

    LET cb = ui.ComboBox.forName("selected_row")
    CALL cb.clear()
    FOR i = 1 TO l_row_count
        CALL cb.addItem(i, i)
    END FOR
END FUNCTION
