# EvtxECmd parser for Windows event logs: -i=EVTXECMD

[Home](../README.MD) | [Information](evtxecmd_info.md) | [List of parameters](evtxecmd_parameters_list.md) | [Parameters table](evtxecmd_parameters_table.md) |  [Default parameter values](evtxecmd_parameters_defaults.md)

## Parameters:
Parameters for configuring 'EvtxECmd parser for Windows event logs'. String values must be enclosed by double
quotes when they contain spaces and special characters can be escaped with the '\' (backslash). Boolean value
can be True|False or ON|OFF or 1|0. Date-time values are ISO formatted date or date time strings (Ex.
2021-05-16 or "2021-015-016 12:40:23"). Integer and decimal numbers are written without quotes. Arrays are
comma separated values enclosed by double quotes. When there is a list of available values, the parameter can
be one of the listed options. Some parameters are grouped in separate categories or prefixed with a name for
easier reading.

### Category: EvtxECmd configuration.

 - MapsDirectory

	* Default value: -MapsDirectory="EvtxECmd\\Maps"
	* Description: EvtxECmd Maps directory. Located in Documents folder by default. Has to be
	updated manually (ex. by using GIT). The application does not update the maps
	automatically from the EvtxECmd repository
	(https://github.com/EricZimmerman/evtx). Type: string value.

### Category: Record fields.

 - ExtendedFileds

	* Default value: -ExtendedFileds=True
	* Description: Include extended fields like file path, line number, record number, etc. Type:
	boolean value.

### Category: Stream reader configuration.

 - Recurse

	* Default value: -Recurse=0
	* Description: Maximum number of subdirectory recursion level for file streams. 0 disables
	subdirectory recursion; -1 enables unlimited recursion. Type: integer number.

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

