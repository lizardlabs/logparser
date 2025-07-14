# Windows event log reader using legacy Win32 API): -i=EVTXP

[Home](../README.MD) | [Information](evtxp_info.md) | [List of parameters](evtxp_parameters_list.md) | [Parameters table](evtxp_parameters_table.md) |  [Default parameter values](evtxp_parameters_defaults.md)

## Parameters:
Parameters for configuring 'Windows event log reader using legacy Win32 API)'. String values must be enclosed
by double quotes when they contain spaces and special characters can be escaped with the '\' (backslash).
Boolean value can be True|False or ON|OFF or 1|0. Date-time values are ISO formatted date or date time strings
(Ex. 2021-05-16 or "2021-015-016 12:40:23"). Integer and decimal numbers are written without quotes. Arrays
are comma separated values enclosed by double quotes. When there is a list of available values, the parameter
can be one of the listed options. Some parameters are grouped in separate categories or prefixed with a name
for easier reading.

 - Computers

	* Default value: -Computers=""
	* Description: Comma separated list of network computers (user access permission required).
	Empty string for local PC. Type: string value.

 - FormatMsg

	* Default value: -FormatMsg=False
	* Description: Remove spaces from message for better readability. Type: boolean value.

 - IgnoreErrors

	* Default value: -IgnoreErrors=False
	* Description: If true, ignores some errors while reading the event records. Otherwise throws
	exception and stop reading data. Type: boolean value.

 - ReverseDirection

	* Default value: -ReverseDirection=True
	* Description: If true, read records in reverse order (latest events first). Type: boolean
	value.

 - StringsSeparator

	* Default value: -StringsSeparator="|"
	* Description: Type: string value.

### Category: Performance.

 - IncludeMessage

	* Default value: -IncludeMessage=Always
	* Description: If set to Always, a message is always included in the record but it reduces
	overall reading performance since the message is loaded from external resource.
	Removing messages from the record can increase performance (especially when
	reading from remote PC). Type: list of values.

	* Available values: 
		- Always
		- OnlyOnErrors
		- OnlyOnErrorsAndWarnings
		- Never

 - IncludeStrings

	* Default value: -IncludeStrings=True
	* Description: If true, Strings field is extracted from event record. Warning: will affect
	performance when used on a huge data set. Type: boolean value.

### Category: Record fields.

 - ExtendedFileds

	* Default value: -ExtendedFileds=True
	* Description: Include extended fields like file path, line number, record number, etc. Type:
	boolean value.

### Category: Stream reader configuration.

 - Recurse

	* Default value: -Recurse=0
	* Description: Maximum number of subdirectory recursion level for file streams (if events are
	loaded from a file ex. 'c:\logs\*.evtx'). 0 disables subdirectory recursion; -1
	enables unlimited recursion. Type: integer number.

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

