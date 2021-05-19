# W3C format reader (IIS, FTP, Apache, ISA, Exchange, SMTP, MediaSvc, etc.): -i=W3C

[Home](../Readme.md) | [Information](w3c_info.md) | [List of parameters](w3c_parameters.md) | [Parameters table](w3c_parameters_table.md) |  [Default parameter values](w3c_parameters_defaults.md)

## Parameters:
Parameters for configuring 'W3C format reader (IIS, FTP, Apache, ISA, Exchange, SMTP, MediaSvc, etc.)'. String
values must be enclosed by double quotes when they contain spaces and special characters can be escaped with
the '\' (backslash). Boolean value can be True|False or ON|OFF or 1|0. Date-time values are ISO formatted date
or date time strings (Ex. 2021-05-16 or "2021-015-016 12:40:23"). Integer and decimal numbers are written
without quotes. Arrays are comma separated values enclosed by double quotes. When there is a list of available
values, the parameter can be one of the listed options. Some parameters are grouped in separate categories or
prefixed with a name for easier reading.

### Category: Parsing options.

 - CommentIndicator

	* Default value: -CommentIndicator="#"
	* Description: Lines starting with this string are comments. By default W3C comment char is #.
	Type: string value.


#### Prefix: DelimiterOptions
Delimiter settings. Record lines are parsed using these settings. *Parameters:*

 - DelimiterOptions.DelimiterCharacter

	* Default value: -DelimiterOptions.DelimiterCharacter="space"
	* Description: Field delimiter character. You can use 'tab','space' or any C# string syntax to
	escape special characters (ex. \t for tabs, \\ for \, \" for ", etc..). Leave
	empty to read entire line. Type: string value.

 - DelimiterOptions.EscapeCharacter

	* Default value: -DelimiterOptions.EscapeCharacter="\\\\"
	* Description: Escape the quotation characters with this char. Usual escape char is \. You can
	use 'tab','space' or any C# string syntax to escape special characters (ex. \t
	for tabs, \\ for \, \" for ", etc..). Type: string value.

 - DelimiterOptions.HasHeaderRow

	* Default value: -DelimiterOptions.HasHeaderRow=True
	* Description: First record is header that contains field names. Type: boolean value.

 - DelimiterOptions.QuoteCharacter

	* Default value: -DelimiterOptions.QuoteCharacter="\\\""
	* Description: If value is wrapped in quotes set the quotation char (usually double quotes). If
	there is delimiter between the quotes the delimiter will be part of the field.
	Quotes in the field can be escaped with escape character (ex. \" in the field
	will be translated to ").  You can use 'tab','space' or any C# string syntax to
	escape special characters (ex. \t for tabs, \\ for \, \" for ", etc..). Type:
	string value.


 - HeaderFields

	* Default value: -HeaderFields="auto"
	* Description: Set to auto to automatically try to detect headers if there is no #Fields line
	in log files Otherwise set the field names separated by custom delimiter or
	space. Type: string value.

### Category: Record fields.

 - Culture

	* Default value: -Culture=""
	* Description: Converts the string representation of a numbers and date and time by using
	culture-specific format information (ex. en-US). If empty, current UI culture is
	used. Type: string value.

 - ExtendedFileds

	* Default value: -ExtendedFileds=True
	* Description: Include extended fields like file path, line number, record number, etc. Type:
	boolean value.

 - IncludeFullRecord

	* Default value: -IncludeFullRecord=False
	* Description: Adds text field to the output with the full text of the record. Type: boolean
	value.

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

### Category: Additional fields.

 - DetailedUserAgentInfo

	* Default value: -DetailedUserAgentInfo=False
	* Description: If true, more detailed information will be extracted from user-agent field, but
	it may be much slower for large datasets so use this carefully. Type: boolean
	value.

 - FieldNameClientIP

	* Default value: -FieldNameClientIP="User-Client-IP"
	* Description: WARNING: use this carefully on large datasets (some calculated fields may
	significantly affects performance). Use this field value as client-IP address
	string to separate address and port number if combined. Leave it blank to
	ignore. Type: string value.

 - FieldNameUserAgent

	* Default value: -FieldNameUserAgent="cs(User-Agent)"
	* Description: Use this field value as user-agent string to parse and extract information about
	device, name, bot, OS, etc... Leave it blank to ignore. Type: string value.

 - IncludeAdditionalFields

	* Default value: -IncludeAdditionalFields=False
	* Description: Expand fields in list of calculated fields. If you want to exclude some field,
	leave it blank. Type: boolean value.


------------------------------------------------------------

