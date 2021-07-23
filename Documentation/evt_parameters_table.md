# Windows event log reader: -i=EVT

[Home](../README.MD) | [Information](evt_info.md) | [List of parameters](evt_parameters_list.md) | [Parameters table](evt_parameters_table.md) |  [Default parameter values](evt_parameters_defaults.md)

## Parameters:
Parameters for configuring 'Windows event log reader'. String values must be enclosed by double quotes when
they contain spaces and special characters can be escaped with the '\' (backslash). Boolean value can be
True|False or ON|OFF or 1|0. Date-time values are ISO formatted date or date time strings (Ex. 2021-05-16 or
"2021-015-016 12:40:23"). Integer and decimal numbers are written without quotes. Arrays are comma separated
values enclosed by double quotes. When there is a list of available values, the parameter can be one of the
listed options. Some parameters are grouped in separate categories or prefixed with a name for easier reading.

 Parameter                        | Type           | Default Value | Description                                                                                                                   | Category       
 -------------------------------- | -------------- | ------------- | ----------------------------------------------------------------------------------------------------------------------------- | --------------- 
 -**AdvancedEventLogQuery**       | string value   | ""            | Advanced XML query for querying Windows Events (see Microsoft documentation). Used only in special cases.                     |                
 -**FormatMsg**                   | boolean value  | False         | Remove spaces from message for better readability.                                                                            |                
 -**IgnoreErrors**                | boolean value  | False         | If true, ignores some errors while reading the event records. Otherwise throws exception and stop reading data.               |                
 -**ReverseDirection**            | boolean value  | True          | If true, read records in reverse order (latest events first).                                                                 |                
 -**StringsSeparator**            | string value   | "|"           |                                                                                                                               |                
 -**ExtendedFileds**              | boolean value  | True          | Include extended fields like file path, line number, record number, etc.                                                      | Record fields. 
 -**ErrorsToIgonre**              | integer number | 0             | Max number of errors allowed. 0 don't ignore errors; -1 to ignore all reading errors.                                         | Error handling.
 -**IgnoreConvertExceptions**     | boolean value  | False         | Ignore the value exceptions and return null. Otherwise string fields will be set to error message for debugging.              | Error handling.
 -**IncludeKeywordsDisplayNames** | boolean value  | True          | If true, Keywords field is extracted from event record. Warning: will affect performance when used on a huge data set.        | Performance.   
 -**IncludeStrings**              | boolean value  | True          | If true, Strings field is extracted from event record. Warning: will affect performance when used on a huge data set.         | Performance.   
 -**ResolveUserSIDs**             | boolean value  | True          | Try to resolve user SID to actual account name in a new field. Warning: will affect performance when used on a huge data set. | Performance.   

------------------------------------------------------------

