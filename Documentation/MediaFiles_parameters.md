# Delimiter-separated values: -i=MediaFiles

## Parameters:
Parameters for configuring 'Delimiter-separated values'. String values must be enclosed by double quotes when
they contain spaces and special characters can be escaped with the '\' (backslash). Boolean value can be
True|False or ON|OFF or 1|0. Date-time values are ISO formatted date or date time strings (Ex. 2021-05-16 or
"2021-015-016 12:40:23"). Integer and decimal numbers are written without quotes. Arrays are comma separated
values enclosed by double quotes. When there is a list of available values, the parameter can be one of the
listed options. Some parameters are grouped in separate categories or prefixed with a name for easier reading.

 - IgnoreErrors

	* Default value: -IgnoreErrors=True
	* Description: Type: boolean value.

 - IncludeMediaProperties

	* Default value: -IncludeMediaProperties=True
	* Description: Type: boolean value.

 - Recurse

	* Default value: -Recurse=-1
	* Description: Max subdirectory recursion level for file streams. 0 disables subdirectory
	recursion; -1 enables unlimited recursion. Type: integer number.

### Category: Record fields.

 - ExtendedFileds

	* Default value: -ExtendedFileds=True
	* Description: Include extended fields like file path, line number, record number, etc. Type:
	boolean value.

### Category: Error handling.

 - ErrorsToIgonre

	* Default value: -ErrorsToIgonre=0
	* Description: Max number of errors allowed. 0 don't ignore errors; -1 to ignore all reading
	errors. Type: integer number.

 - IgnoreConvertExceptions

	* Default value: -IgnoreConvertExceptions=False
	* Description: Ignore the value exceptions and return null. Otherwise string fields will be set
	to error message for debugging. Type: boolean value.


------------------------------------------------------------

