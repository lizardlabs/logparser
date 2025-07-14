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

 Parameter                    | Type           | Default Value      | Description                                                                                                                                                                                                                                  | Category                    
 ---------------------------- | -------------- | ------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------- 
 -**MapsDirectory**           | string value   | "EvtxECmd\\\\Maps" | EvtxECmd Maps directory. Located in Documents folder by default. Has to be updated manually (ex. by using GIT). The application does not update the maps automatically from the EvtxECmd repository (https://github.com/EricZimmerman/evtx). | EvtxECmd configuration.     
 -**ExtendedFileds**          | boolean value  | True               | Include extended fields like file path, line number, record number, etc.                                                                                                                                                                     | Record fields.              
 -**Recurse**                 | integer number | 0                  | Maximum number of subdirectory recursion level for file streams. 0 disables subdirectory recursion; -1 enables unlimited recursion.                                                                                                          | Stream reader configuration.
 -**ErrorsToIgonre**          | integer number | 0                  | Max number of errors allowed. 0 don't ignore errors; -1 to ignore all reading errors.                                                                                                                                                        | Error handling.             
 -**IgnoreConvertExceptions** | boolean value  | False              | Ignore the value exceptions and return null. Otherwise string fields will be set to error message for debugging.                                                                                                                             | Error handling.             

------------------------------------------------------------

