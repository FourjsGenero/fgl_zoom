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
#       l_zoom_functionaltest.4gl
#
#       January 2011 Reuben Barclay reuben@4js.com.au

#+ Allow testing of specific generic zoom window options
#+
#+ Test the generic zoom by allowing the effect of individual options to be
#+ observed.  The user can select from a number of different zoom options, all
#+ of which highlight an individual configurations setting

IMPORT FGL fgl_zoom

DEFINE m_functionaltest RECORD
    default, qbedefault, straight2list, noqbe, excludeqbe, excludelist, union,
            subquery, autoselect1, autoselect2, maxrow20, qbeforce3, qbeforce4,
            auto2, gotop, goton, nocolumnheader, ascombobox
        INTEGER,
    nolist, qbe, choosecolumn STRING
END RECORD
DEFINE m_functionaltest_twocolumn RECORD
    twocolumn1 INTEGER,
    twocolumn2 STRING
END RECORD
DEFINE m_functionaltest_single DYNAMIC ARRAY OF RECORD
    id INTEGER
END RECORD
DEFINE m_functionaltest_multiple DYNAMIC ARRAY OF RECORD
    id INTEGER,
    desc STRING
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
#+ a basic test, as defined by base_init(l_zoom) and then add extra calls to test
#+ the effect of various parameters.
FUNCTION test()
    DEFINE i INTEGER
    DEFINE l_mode STRING
    DEFINE l_zoom zoomType

    DIALOG ATTRIBUTES(UNBUFFERED)
        INPUT BY NAME m_functionaltest.*
            ATTRIBUTES(WITHOUT DEFAULTS = TRUE, NAME = "main")

            -- A zoom using the default options
            ON ACTION zoom INFIELD default
                CALL base_init(l_zoom)
                LET l_zoom.title = "Default Values"
                LET m_functionaltest.default = l_zoom.call()

                -- A zoom where some QBE defaults are specified.
                -- Use these where the data table has a large number of rows
                -- and you don't want all rows searched if the user simply presses ENTER
            ON ACTION zoom INFIELD qbedefault
                CALL base_init(l_zoom)
                LET l_zoom.title = "Default QBE Values"

                LET l_zoom.column[1].qbedefault = "<100"
                LET l_zoom.column[2].qbedefault = "A:MZ"
                LET l_zoom.column[3].qbedefault = SFMT(">='%1'", (TODAY - 365))
                LET l_zoom.column[4].qbedefault = "<12:00:00"
                LET l_zoom.column[5].qbedefault = ">100"
                LET l_zoom.column[6].qbedefault = ">100"
                LET m_functionaltest.qbedefault = l_zoom.call()

                -- A zoom that goes straight to list
                -- Use this when you know the number of rows is not too large
            ON ACTION zoom INFIELD straight2list
                CALL base_init(l_zoom)
                LET l_zoom.title = "Straight to List"
                LET l_zoom.gotolist = TRUE
                LET m_functionaltest.straight2list = l_zoom.call()

                -- Disable the QBE button
            ON ACTION zoom INFIELD noqbe
                CALL base_init(l_zoom)
                LET l_zoom.title = "No QBE"
                LET l_zoom.noqbe = TRUE
                LET m_functionaltest.noqbe = l_zoom.call()

                -- If the QBE results in one row being selected, return straight away
                -- Don't force the user to select the only row
            ON ACTION zoom INFIELD autoselect1
                CALL base_init(l_zoom)
                LET l_zoom.title = "AutoSelect"
                LET l_zoom.autoselect = TRUE
                LET l_zoom.column[1].qbedefault = "1"
                LET m_functionaltest.autoselect1 = l_zoom.call()

                -- Similar to above, but there is no QBE so it looks like it the zoom
                -- populates the value straight away
            ON ACTION zoom INFIELD autoselect2
                CALL base_init(l_zoom)
                LET l_zoom.title = "AutoSelect"
                LET l_zoom.autoselect = TRUE
                LET l_zoom.noqbe = TRUE
                LET l_zoom.sql =
                    "SELECT %2 FROM fgl_zoom_test WHERE %1 AND id=1"
                LET m_functionaltest.autoselect2 = l_zoom.call()

                -- Limit the maximum number of rows that are returned.  Normally this also
                -- forces the user to enter some appropriate QBE parameters
            ON ACTION zoom INFIELD maxrow20
                CALL base_init(l_zoom)
                LET l_zoom.title = "Max 20 rows returned"
                LET l_zoom.maxrow = 20
                LET m_functionaltest.maxrow20 = l_zoom.call()

                -- A zoom that forces the user to enter some QBE criteria
                -- Use this
            ON ACTION zoom INFIELD qbeforce3
                CALL base_init(l_zoom)
                LET l_zoom.title = "Force QBE"
                LET l_zoom.qbeforce = TRUE
                LET m_functionaltest.qbeforce3 = l_zoom.call()

                -- A zoom that forces the user to enter some QBE criteria
                -- Use this
            ON ACTION zoom INFIELD qbeforce4
                CALL base_init(l_zoom)
                LET l_zoom.title = "Force QBE in first column"
                LET l_zoom.column[1].qbeforce = TRUE
                LET m_functionaltest.qbeforce4 = l_zoom.call()

                -- A zoom that derives the columns from the SQL string
            ON ACTION zoom INFIELD auto2
                CALL l_zoom.init() -- Note calling this and not base_init()
                LET l_zoom.title = "Derive columns from SQL"
                LET l_zoom.cancelvalue = FGL_DIALOG_GETBUFFER()
                LET l_zoom.sql =
                    "SELECT id, desc, date_created, time_created, quantity, price FROM fgl_zoom_test WHERE %1 ORDER BY id"
                CALL l_zoom.column_auto_set()
                LET m_functionaltest.auto2 = l_zoom.call()

                -- A zoom that puts focus on second row
            ON ACTION zoom INFIELD gotop
                CALL base_init(l_zoom)
                LET l_zoom.title = "Goto second row"
                LET l_zoom.cancelvalue = FGL_DIALOG_GETBUFFER()
                LET l_zoom.gotorow = 2
                LET m_functionaltest.gotop = l_zoom.call()

                -- A zoom that puts focus on last row
            ON ACTION zoom INFIELD goton
                CALL base_init(l_zoom)
                LET l_zoom.title = "Goto last row"
                LET l_zoom.cancelvalue = FGL_DIALOG_GETBUFFER()
                LET l_zoom.gotorow = -1
                LET m_functionaltest.gotop = l_zoom.call()

                -- A zoom that has no column headings
            ON ACTION zoom INFIELD nocolumnheader
                CALL base_init(l_zoom)
                LET l_zoom.title = "No Column Headers"
                LET l_zoom.cancelvalue = FGL_DIALOG_GETBUFFER()
                LET l_zoom.header = FALSE 
                LET m_functionaltest.nocolumnheader = l_zoom.call()

            -- A zoom that looks like a ComboBox
            ON ACTION zoom INFIELD ascombobox
                CALL l_zoom.init()
                LET l_zoom.sql = "SELECT %2 FROM fgl_zoom_test WHERE %1"
                LET l_zoom.cancelvalue = FGL_DIALOG_GETBUFFER()
                LET l_zoom.combobox = TRUE 
                CALL l_zoom.column[1].quick_set("id", TRUE, "i", 4, "ID")
                LET l_zoom.column[1].excludelist = TRUE
                CALL l_zoom.column[2].quick_set("desc", FALSE, "c", 20, "Description")
                
                LET m_functionaltest.ascombobox = l_zoom.call()
                
                -- Control what column is returned
            ON ACTION zoom INFIELD choosecolumn
                CALL base_init(l_zoom)
                LET l_zoom.title = "Return the second column in the result"

                LET l_zoom.column[1].includeinresult = FALSE
                LET l_zoom.column[2].includeinresult = TRUE
                LET m_functionaltest.choosecolumn = l_zoom.call()

                -- Exclude a column from the QBE, but display it in the list
            ON ACTION zoom INFIELD excludeqbe
                CALL base_init(l_zoom)
                LET l_zoom.title = "Exclude a column from the QBE"
                LET l_zoom.column[1].excludeqbe = TRUE
                LET m_functionaltest.excludeqbe = l_zoom.call()

                -- Exclude a column from the list, but display it in the QBE
            ON ACTION zoom INFIELD excludelist
                CALL base_init(l_zoom)
                LET l_zoom.title = "Exclude a column from the list"
                LET l_zoom.column[1].excludelist = TRUE
                LET m_functionaltest.excludelist = l_zoom.call()

                -- Only show the QBE.  Use as a generic way to enter a where clause
            ON ACTION zoom INFIELD nolist
                CALL base_init(l_zoom)
                LET l_zoom.title = "Return a Where Clause"
                LET l_zoom.nolist = TRUE
                CALL l_zoom.execute()
                LET m_functionaltest.nolist = l_zoom.where

                -- For use with a CONSTRUCT statement, return the QBE construct clause
                -- that could be used to select the selected values i.e pipe delimited
            ON ACTION zoom INFIELD qbe
                CALL base_init(l_zoom)
                LET l_zoom.title = "Return equivalent of a QBE Construct Clause"
                LET l_zoom.multiplerow = TRUE
                CALL l_zoom.execute()
                LET m_functionaltest.qbe = l_zoom.qbe_get()

                -- An example with a UNION clause in the SQL
                -- The important thing to consider is should the WHERE clause be added
                -- to both sides of the UNION?
            ON ACTION zoom INFIELD union
                CALL base_init(l_zoom)
                LET l_zoom.title = "A UNION SQL"
                LET l_zoom.sql =
                    "SELECT id, desc, date_created, time_created, quantity, price, '******' FROM fgl_zoom_test WHERE %1 AND quantity < 100 UNION SELECT id, desc, date_created, time_created, quantity, price, '' FROM fgl_zoom_test WHERE %1 AND quantity >= 100 ORDER BY 1"
                CALL l_zoom.column[7]
                    .quick_set("(constant)", FALSE, "c", 6, "Low Stock")
                LET l_zoom.column[7].excludeqbe = TRUE
                LET m_functionaltest.union = l_zoom.call()

                -- An example with a subquery in the SQL
                -- The important thing to consider is where should the where clause be
                -- added
            ON ACTION zoom INFIELD subquery
                CALL base_init(l_zoom)
                LET l_zoom.title = "A SQL with a sub-query"
                LET l_zoom.sql =
                    "SELECT id, desc, date_created, time_created, quantity, price, 1+(SELECT COUNT(*) FROM fgl_zoom_test b WHERE %1 AND a.quantity < b.quantity) FROM fgl_zoom_test a WHERE %1 "
                CALL l_zoom.column[7]
                    .quick_set("rank", FALSE, "i", 4, "Qty Rank")
                LET l_zoom.column[7].excludeqbe = TRUE
                LET m_functionaltest.subquery = l_zoom.call()

        END INPUT

        -- An example where 2 columns are returned from the zoom.  Normally used
        -- for composite keys
        INPUT BY NAME m_functionaltest_twocolumn.*
            ATTRIBUTES(WITHOUT DEFAULTS = TRUE, NAME = "twocolumn")
            ON ACTION zoom
                CALL base_init(l_zoom)
                LET l_zoom.title = "Return first 2 columns in the result"
                LET l_zoom.column[1].includeinresult = TRUE
                LET l_zoom.column[2].includeinresult = TRUE
                CALL l_zoom.execute()
                IF l_zoom.ok() THEN
                    LET m_functionaltest_twocolumn.twocolumn1 =
                        l_zoom.result[1, 1]
                    LET m_functionaltest_twocolumn.twocolumn2 =
                        l_zoom.result[1, 2]
                END IF
        END INPUT

        -- An example where the user can select multiple rows in the zoom window.
        DISPLAY ARRAY m_functionaltest_single TO single.*
            ON ACTION zoom
                CALL base_init(l_zoom)
                LET l_zoom.title = "Return multiple rows"
                LET l_zoom.multiplerow = TRUE
                CALL l_zoom.execute()
                IF l_zoom.ok() THEN
                    CALL m_functionaltest_single.clear()
                    FOR i = 1 TO l_zoom.result.getLength()
                        LET m_functionaltest_single[i].id = l_zoom.result[i, 1]
                    END FOR
                END IF
        END DISPLAY

        -- An example where 2 columns are returned, and the user can select
        -- multiple rows in the same window
        DISPLAY ARRAY m_functionaltest_multiple TO multiple.*
            ON ACTION zoom
                CALL base_init(l_zoom)
                LET l_zoom.title = "Return multiple rows and columns"

                LET l_zoom.multiplerow = TRUE
                LET l_zoom.column[1].includeinresult = TRUE
                LET l_zoom.column[2].includeinresult = TRUE
                CALL l_zoom.execute()
                IF l_zoom.ok() THEN
                    CALL m_functionaltest_multiple.clear()
                    FOR i = 1 TO l_zoom.result.getLength()
                        LET m_functionaltest_multiple[i].id =
                            l_zoom.result[i, 1]
                        LET m_functionaltest_multiple[i].desc =
                            l_zoom.result[i, 2]
                    END FOR
                END IF

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
PRIVATE FUNCTION base_init(z zoomType INOUT)

    CALL z.init()
    LET z.sql = "SELECT %2 FROM fgl_zoom_test WHERE %1"
    LET z.cancelvalue = FGL_DIALOG_GETBUFFER()

    -- Example of an integer column
    CALL z.column[1].quick_set("id", TRUE, "i", 4, "ID")

    -- Example of a char column
    CALL z.column[2].quick_set("desc", FALSE, "c", 20, "Description")

    -- Example of a date column
    CALL z.column[3].quick_set("date_created", FALSE, "d", 10, "Date Created")
    LET z.column[3].format = "dd/mm/yyyy"
    LET z.column[3].justify = "center"

    -- Example of a datetime column
    CALL z.column[4].quick_set("time_created", FALSE, "c", 10, "Time Created")
    LET z.column[4].justify = "center"

    -- Example of 2 decimal columns
    CALL z.column[5].quick_set("quantity", FALSE, "f", 11, "Quantity")
    LET z.column[5].format = "----,--&.&&"

    CALL z.column[6].quick_set("price", FALSE, "f", 11, "Price")
    LET z.column[6].format = "----,-$&.&&"
END FUNCTION
