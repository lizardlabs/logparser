# Log4j/log4net XML Format: -i=log4jXML

## Description

Log4j/log4net XML Format. Command line switch to use this input format is -i=log4jXML.

## From-Entity Syntax

The <from-entity> specified in queries using the log4jXML input format can be:
- Comma-separated list of paths of log files, eventually including wildcards (glob pattern is supported).
- The URL of a file if located on HTTP, FTP or S3.
- Other (specific for the -i=log4jXML format.

## Parameters

- [Home](../Readme.md)
- [List of parameters](log4jxml_parameters.md)
- [Parameters table](log4jxml_parameters_table.md)
- [Default parameter values](log4jxml_parameters_defaults.md)
## Fields

- **LocalTimeStamp** *type timestamp*
- **Logger** *type string*
- **Thread** *type string*
- **LevelIndex** *type integer*
- **Level** *type string*
- **Message** *type string*
- **MachineName** *type string*
- **UserName** *type string*
- **HostName** *type string*
- **App** *type string*
- **Throwable** *type string*
- **Class** *type string*
- **Method** *type string*
- **File** *type string*
- **Line** *type string*
- **Uncategorized** *type string*
- **TimeStampUTC** *type timestamp*
- **Delta** *type real*
- **LocalDate** *type timestamp*
- **LocalTime** *type timestamp*
- **RecordIndex** *type integer*
- **StreamRecordIndex** *type integer*
- **StreamLineNumber** *type integer*
- **StreamName** *type string*

## Examples

------------------------------------------------------------

