# Windows event log reader using legacy Win32 API): -i=EVTXP

## Description

Windows event log reader using legacy Win32 API). Command line switch to use this input format is -i=EVTXP.

## From-Entity Syntax

The <from-entity> specified in queries using the EVTXP input format can be:
- Comma-separated list of paths of log files, eventually including wildcards (glob pattern is supported).
- The URL of a file if located on HTTP, FTP or S3.
- Other (specific for the -i=EVTXP format.

## Parameters

- [Home](../README.MD)
- [List of parameters](evtxp_parameters_list.md)
- [Parameters table](evtxp_parameters_table.md)
- [Default parameter values](evtxp_parameters_defaults.md)
## Fields

- **TimeGenerated** *type timestamp*
- **TimeWritten** *type timestamp*
- **EventTypeName** *type string*
- **EventType** *type integer*
- **EventID** *type integer*
- **Source** *type string*
- **Category** *type string*
- **Message** *type string*
- **UserAccountName** *type string*
- **MachineName** *type string*
- **Log** *type string*
- **LogDisplayName** *type string*
- **EntryType** *type integer*
- **CategoryNumber** *type integer*
- **EventIndex** *type integer*
- **Strings** *type string*
- **Data** *type string*
- **RecordIndex** *type integer*

## Examples

------------------------------------------------------------

