# fgl_zoom
fgl_zoom is a Genero library you can use to code all your zoom windows.  What is a zoom window, alternative names include lookup window, query window, pick list is a window that appears when you click on a BUTTONEDIT button that allows you to select a value that will then be entered into the BUTTONEDIT field.

We typically see this pattern when entering what is a foreign key to another table.  The BUTTONEDIT requires entry of the key field and the zoom window allows you to list the key and data fields of the referenced table to select a value.  To narrow the list, a QBE option may also be available.

These screenshot illustrates a typical usage,

A BUTTONEDIT is used for the State code ...

<img alt="BUTTONEDIT Before" src="https://user-images.githubusercontent.com/13615993/32300328-e806e524-bfbd-11e7-8ac8-462e1e3f0cc3.png" width="20%" />

User clicks on the BUTTONEDIT button, a window appears with a list of values

<img alt="BUTTONEDIT Before" src="https://user-images.githubusercontent.com/13615993/32300325-e7c75026-bfbd-11e7-9919-cd03c6d34b28.png" width="50%" />


The user selects a state that is in turn passed back to the BUTTONEDIT field

<img alt="BUTTONEDIT After" src="https://user-images.githubusercontent.com/13615993/32300324-e7880a92-bfbd-11e7-9e13-6dbfee2e7c9d.png" width="20%" />

Sometimes you may even display a description as well

<img alt="BUTTONEDIT After with description" src="https://user-images.githubusercontent.com/13615993/32300323-e74bc6c2-bfbd-11e7-9ca9-52b2ca83df9d.png" width="20%" />

If the list of values is long, before you display the list, you may enter some QBE Criteria to reduce the number of values displayed in the list

<img alt="QBE Window" src="https://user-images.githubusercontent.com/13615993/32300545-db563e78-bfbe-11e7-875b-3cd4d47463da.png" width="50%" />

## Why Use fgl_zoom

For the pattern decribed previously, we would typically see for each these zoom windows, we would see a FUNCTION with a FOREACH to read the database, a DISPLAY ARRAY to list values, and an OPEN WINDOW, and .per for the UI.  We would see one of these for EACH zoom window and this code will typically be repetitive/duplicated making maintenance expensive.

So say you had 100 zoom windows, instead of 100 functions, 100 forms, 100 database cursors, 100 display arrays, with fgl_zoom there is a single library with one lot of database code, one lot of UI code etc.  This ensures a consistent user interface and makes code maintenance a lot cheaper.

## How to Use fgl_zoom

The fgl_zoom_test program consists of a form of three tabs

### Example

Illustrates potential uses.  Click on the BUTTONEDIT button and note the window that appears.  To view the 4gl source, the Junior Developer code would require click on the View Source.  In most cases, it is less than a screenfull of 4gl source.  The state code example in the previous screenshot has the following source.

<img alt="State Code Example" src="https://user-images.githubusercontent.com/13615993/32302337-01c13ad8-bfc7-11e7-82c9-b765a240dd83.png" width="50%" /><img alt="Source Example" src="https://user-images.githubusercontent.com/13615993/32302336-018d7202-bfc7-11e7-8407-eb89ac8c4520.png" width="50%" />

<img alt="More complex Customer Code Example" src="https://user-images.githubusercontent.com/13615993/32302335-0157e4a2-bfc7-11e7-99bd-52e742061c2b.png" width="50%" /><img alt="Source Example" src="https://user-images.githubusercontent.com/13615993/32302334-0122e004-bfc7-11e7-8e75-9138f509d66f.png" width="50%" />

<img alt="Auto Example" src="https://user-images.githubusercontent.com/13615993/32302333-00ebeb94-bfc7-11e7-90f5-34c592a48599.png" width="50%" /><img alt="Source Example" src="https://user-images.githubusercontent.com/13615993/32302332-00b4d4c4-bfc7-11e7-8225-0be7def2ec5c.png" width="50%" />

### Functional Test
fgl_zoom has a number of configuration parameters.  The functional test tab is used to test each of these parameters in isolation.  You can also look at the source to see the function name and expected parameters. 
<img alt="Functional Test Screenshot" src="https://user-images.githubusercontent.com/13615993/32301120-6c2c39f0-bfc1-11e7-981b-5ba19384dea7.png" width="50%" />

### Custom
The custom tab allows you to experiment and create some fgl_zoom code.  

Enter the appropriate parameter 

<img alt="Custom Initial Screen" src="https://user-images.githubusercontent.com/13615993/32301118-6bf1e016-bfc1-11e7-8fdb-a597c80244a6.png" width="50%" />

Click Execute to run the resultant zoom window(s)

<img alt="Custom QBE Screen" src="https://user-images.githubusercontent.com/13615993/32301116-6ba46304-bfc1-11e7-8e7c-531323da4362.png" width="50%" />

<img alt="Custom List Screen" src="https://user-images.githubusercontent.com/13615993/32301115-6b69af0c-bfc1-11e7-9852-47e80d49d881.png" width="50%" />

View Source to see the 4gl source required in your program.

<img alt="Custom View Source" src="https://user-images.githubusercontent.com/13615993/32301114-6b332676-bfc1-11e7-99c0-a0779e27f8a2.png" width="50%" />

## Options

For these refer to the Configuration Tab, or the Functional Test Tab to observe the difference in behaviour.

### SQL
The SQL to be used to access the database.  There are two placeholders.  Enter %1 to indicate where the where clause generated by the QBE Window is to be inserted into the SQL.  Use %2 to generate the column list from the column definitions below.   A typical value maybe something like SELECT %2 FROM tablename WHERE %1 ORDER BY id

### Derive Columns From SQL (Auto)
Check to derive the column data from the SQL parameter

### Window TITLE
Title to appear in the QBE and List Window

### Cancel Value
If the user selects cancel, what is the value returned.  Typically populated with FGL_DIALOG_GETBUFFER() so as not to remvoe the existing value.

### Disable QBE Window
Set to TRUE to disable the QBE Window.  This means that all the values that match the entered SQL will appear in the List Window.

### Disable List Window
Set to TRUE to disable the List Window.  This means that the where clause generated by the QBE is the value returned.

### Select First Window
Determine if the QBE or List Window is the first window shown.  Default is QBE Window.

### AutoSelect
If only one row is returned by the display, do not display the List Window and return immediately with that one value.

### Multiple Rows Returned
Set to TRUE if you want to allow the user to select multiple rows.  

### Maximum Rows Returned
Put a restriction on maximum number of rows returned.

### Freeze Columns
Allow a certian number of columns to be frozen so that they are always in view and not scrolled out

### Force QBE

Set to TRUE if you want to force the user to enter at least one value in a QBE field

### Column - Column

Name of the database column. 

### Column - Title

Title of the column, appears as the column header.

### Column - Width
The initial display width to be used for the column

### Column - Format
For numeric and date data, the format to be used.

### Column - Datatype
The datatype of the column.  We don't need exact datatype but need to differentitate Character, Date, Integer, Numeric for sorting and display purposes.

### Column - Justify
The justification left, right, center used for the column.

### Column - Exclude QBE
Set to TRUE if you do not want to see the column appear in the QBE Window.

### Column - Exclude List
Set to TRUE if you do not want to the see the column in the list of results.

### Column - Include
Set to TRUE to include the value in the result set.  Typically you would ensure that one column has this set to TRUE although you can set it in multiple columns for composite keys, or if you want to return code and matching description values.

### Column - QBE Default
Initial value to be used in the QBE field.

### Column - Force
Require the user to enter a value in the QBE for that column.

## Compatability

The use of Dynamic Dialogs will make it difficult to port this code to Genero versions prior to 3.00.  The module was originally written using Genero 2.30 so if you use GitHub to retrieve old versions of the code, you can probably put something together but I would suggest you upgrade to at least 3.00.

## Install

To incorporate fgl_zoom into your own application.

Compile and llace fgl_zoom.42m, fgl_zoom.42s where they will be
found by FGLLDPATH, FGLRESOURCEPATH, DBPATH etc. as used by your application.

Merge the contents of fgl_zoom_test.4st into your applications own style file.
You may wish to amend the styles used in fgl_zoom_test.4st so that it matches 
your own applications look and feel.

Merge the contents of fgl_zoom.str into your own string localization mechanism.
You could do as the test program does and simple add fgl_zoom.42s to the list of
specified files by the fglrun.localization.file settings in FGLPROFILE.

## Source

Add IMPORT FGL fgl_zoom

CALL fgl_zoom.init() to clear the paramters.

Add the required fgl_zoom.\* methods to set the individual parameter options.

Add LET value = fgl_zoom.call() to return the select value.
