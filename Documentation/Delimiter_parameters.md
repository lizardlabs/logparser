# Dates table: -i=Delimiter

[Home](../Readme.md) | [Information](delimiter_info.md) | [List of parameters](delimiter_parameters.md) | [Parameters table](delimiter_parameters_table.md) |  [Default parameter values](delimiter_parameters_defaults.md)

## Parameters:
Parameters for configuring 'Dates table'. String values must be enclosed by double quotes when they contain
spaces and special characters can be escaped with the '\' (backslash). Boolean value can be True|False or
ON|OFF or 1|0. Date-time values are ISO formatted date or date time strings (Ex. 2021-05-16 or "2021-015-016
12:40:23"). Integer and decimal numbers are written without quotes. Arrays are comma separated values enclosed
by double quotes. When there is a list of available values, the parameter can be one of the listed options.
Some parameters are grouped in separate categories or prefixed with a name for easier reading.

### Category: Parsing options.


#### Prefix: DelimiterOptions
Delimiter settings. Record lines are parsed using these settings. *Parameters:*

 - DelimiterOptions.DelimiterCharacter

	* Default value: -DelimiterOptions.DelimiterCharacter=","
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

	* Default value: -HeaderFields=""
	* Description: Set to empty to automatically try to detect headers from the file. Otherwise set
	the field names separated by custom delimiter or comma. Type: string value.

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

 - EnableAdvancedRecordConfiguration

	* Default value: -EnableAdvancedRecordConfiguration=False
	* Description: If not enabled, advanced record reader configuration will be ignored. Text files
	will be read in multi-line record mode. Each record will be separated by the
	lines that match the fields RegEx. Type: boolean value.

 - Recurse

	* Default value: -Recurse=0
	* Description: Maximum number of subdirectory recursion level for file streams. 0 disables
	subdirectory recursion; -1 enables unlimited recursion. Type: integer number.


#### Prefix: TextReaderOptions
Advanced text reader configuration. In most cases you won't need this. Some of
these settings can decrease performance on huge files. *Parameters:*

 - TextReaderOptions.CodePage

	* Default value: -TextReaderOptions.CodePage=65001
	* Description: Code page of the log files. Default is UTF-8 (65001). Type: integer number.

 - TextReaderOptions.EndOfLineComment

	* Default value: -TextReaderOptions.EndOfLineComment=""
	* Description: Ignore text after this string till the end of line (like // in C++ or -- in
	SQL). Type: string value.


#### Prefix: TextReaderOptions.Filters
Advanced line filters (in case you need additional filters to ignore text
lines). Most users won't need this. *Parameters:*

 - TextReaderOptions.Filters.Capacity

	* Default value: -TextReaderOptions.Filters.Capacity=0
	* Description: Type: integer number.

 - TextReaderOptions.Filters.Count

	* Default value: -TextReaderOptions.Filters.Count=0
	* Description: Type: integer number.


 - TextReaderOptions.IgnoreEmptyLines

	* Default value: -TextReaderOptions.IgnoreEmptyLines=False
	* Description: Empty lines will be  ignored when reading the text stream line by line. Type:
	boolean value.

 - TextReaderOptions.IgnoreLastLines

	* Default value: -TextReaderOptions.IgnoreLastLines=0
	* Description: Ignore last N lines of each file when reading text stream. Type: integer number.

 - TextReaderOptions.LineSeparator

	* Default value: -TextReaderOptions.LineSeparator=""
	* Description: By default s line is defined as a sequence of characters followed by a carriage
	return ('\r'), a line feed ('\n'), or a carriage return immediately followed by
	a line feed. The resulting string does not contain the terminating carriage
	return and/or line feed. Type: string value.

 - TextReaderOptions.MultilineCommentEnd

	* Default value: -TextReaderOptions.MultilineCommentEnd=""
	* Description: Ignore all text (including new lines) between MultilineCommentStart and
	MultilineCommentEnd (like /* ... */ in C++). Type: string value.

 - TextReaderOptions.MultilineCommentStart

	* Default value: -TextReaderOptions.MultilineCommentStart=""
	* Description: Ignore all text (including new lines) between MultilineCommentStart and
	MultilineCommentEnd (like /* ... */ in C++). Type: string value.

 - TextReaderOptions.SkipFirstLines

	* Default value: -TextReaderOptions.SkipFirstLines=0
	* Description: Skip first N lines of each file when reading text stream. Type: integer number.

 - TextReaderOptions.StartOfLineComment

	* Default value: -TextReaderOptions.StartOfLineComment=""
	* Description: Ignore each line that starts with this string (ex. REM in Basic or # in W3C
	logs). Type: string value.

 - TextReaderOptions.StartOfLineCommentCanStartWithSpaces

	* Default value: -TextReaderOptions.StartOfLineCommentCanStartWithSpaces=True
	* Description: Should the reader ignore spaces at the beginning of line when looking for a
	start of line comment. Type: boolean value.

 - TextReaderOptions.StringComparisonType

	* Default value: -TextReaderOptions.StringComparisonType=OrdinalIgnoreCase
	* Description: How to compare strings for comment settings (ex. case sensitive or not). Type:
	list of values.

	* Available values: 
		- CurrentCulture
		- CurrentCultureIgnoreCase
		- InvariantCulture
		- InvariantCultureIgnoreCase
		- Ordinal
		- OrdinalIgnoreCase



#### Prefix: TextRecordConfiguration
Advanced record reader configuration to combine multiple lines in one record and
then parse the record. In most cases you won't need this but for complex file
formats it can be very powerful. *Parameters:*


#### Prefix: TextRecordConfiguration.Filters
Advanced record filters in case you need toe ignore some records after
transformation. Most users won't need this. *Parameters:*

 - TextRecordConfiguration.Filters.Capacity

	* Default value: -TextRecordConfiguration.Filters.Capacity=0
	* Description: Type: integer number.

 - TextRecordConfiguration.Filters.Count

	* Default value: -TextRecordConfiguration.Filters.Count=0
	* Description: Type: integer number.


 - TextRecordConfiguration.IncludeRecordFooterLine

	* Default value: -TextRecordConfiguration.IncludeRecordFooterLine=True
	* Description: Type: boolean value.

 - TextRecordConfiguration.IncludeRecordHeaderLine

	* Default value: -TextRecordConfiguration.IncludeRecordHeaderLine=True
	* Description: Type: boolean value.

 - TextRecordConfiguration.LineSeparator

	* Default value: -TextRecordConfiguration.LineSeparator=""
	* Description: Set the character sequence how to be used to append record lines. By default
	lines are appended and separated with carriage return and line feed ('\r\n').
	Type: string value.


#### Prefix: TextRecordConfiguration.RecordFooter
*Parameters:*

 - TextRecordConfiguration.RecordFooter.MatchingString

	* Default value: -TextRecordConfiguration.RecordFooter.MatchingString=""
	* Description: Matching string for the selected matching type. If regular expression is used to
	match, then this should be the regex pattern, but only if advanced regex
	configuration is not provided. Otherwise it will be ignored. Type: string value.

 - TextRecordConfiguration.RecordFooter.MatchingType

	* Default value: -TextRecordConfiguration.RecordFooter.MatchingType=None
	* Description: The condition used to match the input string: no Condition (match it always
	,match the record if it contains the selector string, match the record if it
	begins with selector string match the record if it ends with selector string,
	match if it begins and ends with selector string (enclosed),match the record if
	it matches the regular expression passed as selector, etc. Type: list of values.

	* Available values: 
		- None
		- MatchIfContains
		- MatchIfBeginsWith
		- MatchIfEndsWith
		- MatchIfEnclosed
		- MatchRegularExpression
		- MatchIfDoesNotContain
		- MatchIfDoesNotBeginsWith
		- MatchIfDoesNotEndsWith
		- MatchIfNotEnclosedWith
		- DoesNotMatchRegex


#### Prefix: TextRecordConfiguration.RecordFooter.RegExConfiguration
If this regular expression configuration is set, this regular expression
configuration is used for matching match the line. Otherwise if MatchRegex if
set as filter type, an regular expression will be created from FilterString
property. *Parameters:*

 - TextRecordConfiguration.RecordFooter.RegExConfiguration.CultureInvariant

	* Default value: -TextRecordConfiguration.RecordFooter.RegExConfiguration.CultureInvariant=True
	* Description: Type: boolean value.

 - TextRecordConfiguration.RecordFooter.RegExConfiguration.ECMAScript

	* Default value: -TextRecordConfiguration.RecordFooter.RegExConfiguration.ECMAScript=False
	* Description: Type: boolean value.

 - TextRecordConfiguration.RecordFooter.RegExConfiguration.ExplicitCapture

	* Default value: -TextRecordConfiguration.RecordFooter.RegExConfiguration.ExplicitCapture=True
	* Description: Type: boolean value.

 - TextRecordConfiguration.RecordFooter.RegExConfiguration.IgnoreCase

	* Default value: -TextRecordConfiguration.RecordFooter.RegExConfiguration.IgnoreCase=True
	* Description: Type: boolean value.

 - TextRecordConfiguration.RecordFooter.RegExConfiguration.IgnorePatternWhitespace

	* Default value: -TextRecordConfiguration.RecordFooter.RegExConfiguration.IgnorePatternWhitespace=True
	* Description: Type: boolean value.

 - TextRecordConfiguration.RecordFooter.RegExConfiguration.Multiline

	* Default value: -TextRecordConfiguration.RecordFooter.RegExConfiguration.Multiline=True
	* Description: Type: boolean value.

 - TextRecordConfiguration.RecordFooter.RegExConfiguration.RegExPattern

	* Default value: -TextRecordConfiguration.RecordFooter.RegExConfiguration.RegExPattern=""
	* Description: Type: string value.

 - TextRecordConfiguration.RecordFooter.RegExConfiguration.RightToLeft

	* Default value: -TextRecordConfiguration.RecordFooter.RegExConfiguration.RightToLeft=False
	* Description: Type: boolean value.

 - TextRecordConfiguration.RecordFooter.RegExConfiguration.Singleline

	* Default value: -TextRecordConfiguration.RecordFooter.RegExConfiguration.Singleline=True
	* Description: Type: boolean value.

 - TextRecordConfiguration.RecordFooter.RegExConfiguration.UseGrokAliases

	* Default value: -TextRecordConfiguration.RecordFooter.RegExConfiguration.UseGrokAliases=True
	* Description: Type: boolean value.


 - TextRecordConfiguration.RecordFooter.StringComparisonType

	* Default value: -TextRecordConfiguration.RecordFooter.StringComparisonType=OrdinalIgnoreCase
	* Description: Specifies the culture and case rules to be used when comparing strings with
	String.Compare() method. Type: list of values.

	* Available values: 
		- CurrentCulture
		- CurrentCultureIgnoreCase
		- InvariantCulture
		- InvariantCultureIgnoreCase
		- Ordinal
		- OrdinalIgnoreCase



#### Prefix: TextRecordConfiguration.RecordHeader
*Parameters:*

 - TextRecordConfiguration.RecordHeader.MatchingString

	* Default value: -TextRecordConfiguration.RecordHeader.MatchingString=""
	* Description: Matching string for the selected matching type. If regular expression is used to
	match, then this should be the regex pattern, but only if advanced regex
	configuration is not provided. Otherwise it will be ignored. Type: string value.

 - TextRecordConfiguration.RecordHeader.MatchingType

	* Default value: -TextRecordConfiguration.RecordHeader.MatchingType=None
	* Description: The condition used to match the input string: no Condition (match it always
	,match the record if it contains the selector string, match the record if it
	begins with selector string match the record if it ends with selector string,
	match if it begins and ends with selector string (enclosed),match the record if
	it matches the regular expression passed as selector, etc. Type: list of values.

	* Available values: 
		- None
		- MatchIfContains
		- MatchIfBeginsWith
		- MatchIfEndsWith
		- MatchIfEnclosed
		- MatchRegularExpression
		- MatchIfDoesNotContain
		- MatchIfDoesNotBeginsWith
		- MatchIfDoesNotEndsWith
		- MatchIfNotEnclosedWith
		- DoesNotMatchRegex


#### Prefix: TextRecordConfiguration.RecordHeader.RegExConfiguration
If this regular expression configuration is set, this regular expression
configuration is used for matching match the line. Otherwise if MatchRegex if
set as filter type, an regular expression will be created from FilterString
property. *Parameters:*

 - TextRecordConfiguration.RecordHeader.RegExConfiguration.CultureInvariant

	* Default value: -TextRecordConfiguration.RecordHeader.RegExConfiguration.CultureInvariant=True
	* Description: Type: boolean value.

 - TextRecordConfiguration.RecordHeader.RegExConfiguration.ECMAScript

	* Default value: -TextRecordConfiguration.RecordHeader.RegExConfiguration.ECMAScript=False
	* Description: Type: boolean value.

 - TextRecordConfiguration.RecordHeader.RegExConfiguration.ExplicitCapture

	* Default value: -TextRecordConfiguration.RecordHeader.RegExConfiguration.ExplicitCapture=True
	* Description: Type: boolean value.

 - TextRecordConfiguration.RecordHeader.RegExConfiguration.IgnoreCase

	* Default value: -TextRecordConfiguration.RecordHeader.RegExConfiguration.IgnoreCase=True
	* Description: Type: boolean value.

 - TextRecordConfiguration.RecordHeader.RegExConfiguration.IgnorePatternWhitespace

	* Default value: -TextRecordConfiguration.RecordHeader.RegExConfiguration.IgnorePatternWhitespace=True
	* Description: Type: boolean value.

 - TextRecordConfiguration.RecordHeader.RegExConfiguration.Multiline

	* Default value: -TextRecordConfiguration.RecordHeader.RegExConfiguration.Multiline=True
	* Description: Type: boolean value.

 - TextRecordConfiguration.RecordHeader.RegExConfiguration.RegExPattern

	* Default value: -TextRecordConfiguration.RecordHeader.RegExConfiguration.RegExPattern=""
	* Description: Type: string value.

 - TextRecordConfiguration.RecordHeader.RegExConfiguration.RightToLeft

	* Default value: -TextRecordConfiguration.RecordHeader.RegExConfiguration.RightToLeft=False
	* Description: Type: boolean value.

 - TextRecordConfiguration.RecordHeader.RegExConfiguration.Singleline

	* Default value: -TextRecordConfiguration.RecordHeader.RegExConfiguration.Singleline=True
	* Description: Type: boolean value.

 - TextRecordConfiguration.RecordHeader.RegExConfiguration.UseGrokAliases

	* Default value: -TextRecordConfiguration.RecordHeader.RegExConfiguration.UseGrokAliases=True
	* Description: Type: boolean value.


 - TextRecordConfiguration.RecordHeader.StringComparisonType

	* Default value: -TextRecordConfiguration.RecordHeader.StringComparisonType=OrdinalIgnoreCase
	* Description: Specifies the culture and case rules to be used when comparing strings with
	String.Compare() method. Type: list of values.

	* Available values: 
		- CurrentCulture
		- CurrentCultureIgnoreCase
		- InvariantCulture
		- InvariantCultureIgnoreCase
		- Ordinal
		- OrdinalIgnoreCase


 - TextRecordConfiguration.RecordType

	* Default value: -TextRecordConfiguration.RecordType=SingleLineRecord
	* Description: Type: list of values.

	* Available values: 
		- SingleLineRecord
		- MultiLineRecord
		- EntireFileIsOneRecord


#### Prefix: TextRecordConfiguration.TransformationRegExConfiguration
If this regular expression is set, after the record is read,
RegEx.Replace(TrasformationReplacementString) method will be used to transform
the result. *Parameters:*

 - TextRecordConfiguration.TransformationRegExConfiguration.CultureInvariant

	* Default value: -TextRecordConfiguration.TransformationRegExConfiguration.CultureInvariant=True
	* Description: Type: boolean value.

 - TextRecordConfiguration.TransformationRegExConfiguration.ECMAScript

	* Default value: -TextRecordConfiguration.TransformationRegExConfiguration.ECMAScript=False
	* Description: Type: boolean value.

 - TextRecordConfiguration.TransformationRegExConfiguration.ExplicitCapture

	* Default value: -TextRecordConfiguration.TransformationRegExConfiguration.ExplicitCapture=True
	* Description: Type: boolean value.

 - TextRecordConfiguration.TransformationRegExConfiguration.IgnoreCase

	* Default value: -TextRecordConfiguration.TransformationRegExConfiguration.IgnoreCase=True
	* Description: Type: boolean value.

 - TextRecordConfiguration.TransformationRegExConfiguration.IgnorePatternWhitespace

	* Default value: -TextRecordConfiguration.TransformationRegExConfiguration.IgnorePatternWhitespace=True
	* Description: Type: boolean value.

 - TextRecordConfiguration.TransformationRegExConfiguration.Multiline

	* Default value: -TextRecordConfiguration.TransformationRegExConfiguration.Multiline=True
	* Description: Type: boolean value.

 - TextRecordConfiguration.TransformationRegExConfiguration.RegExPattern

	* Default value: -TextRecordConfiguration.TransformationRegExConfiguration.RegExPattern=""
	* Description: Type: string value.

 - TextRecordConfiguration.TransformationRegExConfiguration.RightToLeft

	* Default value: -TextRecordConfiguration.TransformationRegExConfiguration.RightToLeft=False
	* Description: Type: boolean value.

 - TextRecordConfiguration.TransformationRegExConfiguration.Singleline

	* Default value: -TextRecordConfiguration.TransformationRegExConfiguration.Singleline=True
	* Description: Type: boolean value.

 - TextRecordConfiguration.TransformationRegExConfiguration.UseGrokAliases

	* Default value: -TextRecordConfiguration.TransformationRegExConfiguration.UseGrokAliases=True
	* Description: Type: boolean value.


 - TextRecordConfiguration.TrasformationReplacementString

	* Default value: -TextRecordConfiguration.TrasformationReplacementString=""
	* Description: Type: string value.


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

