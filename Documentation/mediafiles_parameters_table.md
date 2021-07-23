# Media files information: -i=MediaFiles

[Home](../README.MD) | [Information](mediafiles_info.md) | [List of parameters](mediafiles_parameters_list.md) | [Parameters table](mediafiles_parameters_table.md) |  [Default parameter values](mediafiles_parameters_defaults.md)

## Parameters:
Parameters for configuring 'Media files information'. String values must be enclosed by double quotes when
they contain spaces and special characters can be escaped with the '\' (backslash). Boolean value can be
True|False or ON|OFF or 1|0. Date-time values are ISO formatted date or date time strings (Ex. 2021-05-16 or
"2021-015-016 12:40:23"). Integer and decimal numbers are written without quotes. Arrays are comma separated
values enclosed by double quotes. When there is a list of available values, the parameter can be one of the
listed options. Some parameters are grouped in separate categories or prefixed with a name for easier reading.

 Parameter                    | Type           | Default Value | Description                                                                                                           | Category       
 ---------------------------- | -------------- | ------------- | --------------------------------------------------------------------------------------------------------------------- | --------------- 
 -**IgnoreErrors**            | boolean value  | True          |                                                                                                                       |                
 -**IncludeMediaProperties**  | boolean value  | True          |                                                                                                                       |                
 -**Recurse**                 | integer number | -1            | Max subdirectory recursion level for file streams. 0 disables subdirectory recursion; -1 enables unlimited recursion. |                
 -**ExtendedFileds**          | boolean value  | True          | Include extended fields like file path, line number, record number, etc.                                              | Record fields. 
 -**ErrorsToIgonre**          | integer number | 0             | Max number of errors allowed. 0 don't ignore errors; -1 to ignore all reading errors.                                 | Error handling.
 -**IgnoreConvertExceptions** | boolean value  | False         | Ignore the value exceptions and return null. Otherwise string fields will be set to error message for debugging.      | Error handling.

------------------------------------------------------------

