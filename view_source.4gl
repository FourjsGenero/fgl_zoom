
FUNCTION show(src STRING)
    OPEN WINDOW src WITH FORM "view_source" ATTRIBUTES(STYLE="dialog")
    DISPLAY BY NAME src
    MENU ""
        ON ACTION accept
            EXIT MENU
         COMMAND "Copy to Clipboard"
           CALL ui.Interface.frontCall("standard", "cbset", src, [])
    END MENU
    CLOSE WINDOW src
END FUNCTION