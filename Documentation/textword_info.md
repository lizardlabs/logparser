# Text word input format: -i=TextWord

## Description

Text word input format. Command line switch to use this input format is -i=TextWord.

## From-Entity Syntax

The <from-entity> specified in queries using the TextWord input format can be:
- Comma-separated list of paths of log files, eventually including wildcards (glob pattern is supported).
- The URL of a file if located on HTTP, FTP or S3.
- Other (specific for the -i=TextWord format.

## Parameters

- [Home](../README.MD)
- [List of parameters](textword_parameters_list.md)
- [Parameters table](textword_parameters_table.md)
- [Default parameter values](textword_parameters_defaults.md)
## Fields

- **Word** *type string*
- **RecordIndex** *type integer*
- **StreamRecordIndex** *type integer*
- **StreamLineNumber** *type integer*
- **StreamName** *type string*
- **FullRecord** *type string*

## Examples

------------------------------------------------------------

