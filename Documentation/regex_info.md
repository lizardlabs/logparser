# Multiline text parser using regular expressions (also supports Grok syntax): -i=RegEx

## Description

Multiline text parser using regular expressions (also supports Grok syntax). Command line switch to use this input format is -i=RegEx.

## From-Entity Syntax

The <from-entity> specified in queries using the RegEx input format can be:
- Comma-separated list of paths of log files, eventually including wildcards (glob pattern is supported).
- The URL of a file if located on HTTP, FTP or S3.
- Other (specific for the -i=RegEx format.

## Parameters

- [Home](../Readme.md)
- [List of parameters](regex_parameters.md)
- [Parameters table](regex_parameters_table.md)
- [Default parameter values](regex_parameters_defaults.md)
## Fields

- **level** *type string*
- **logger** *type string*
- **ndc** *type string*
- **Message** *type string*
- **Data** *type string*
- **RecordIndex** *type integer*
- **StreamRecordIndex** *type integer*
- **StreamLineNumber** *type integer*
- **StreamName** *type string*

## Examples

------------------------------------------------------------

