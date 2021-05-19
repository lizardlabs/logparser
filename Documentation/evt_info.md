# Windows event log reader: -i=EVT

## Description

Windows event log reader. Command line switch to use this input format is -i=EVT.

## From-Entity Syntax

The <from-entity> specified in queries using the EVT input format can be:
- Comma-separated list of paths of log files, eventually including wildcards (glob pattern is supported).
- The URL of a file if located on HTTP, FTP or S3.
- Other (specific for the -i=EVT format.

## Parameters

- [Home](../README.MD)
- [List of parameters](evt_parameters_list.md)
- [Parameters table](evt_parameters_table.md)
- [Default parameter values](evt_parameters_defaults.md)
## Fields

- **LogName** *type string*
- **RecordId** *type integer*
- **TimeCreated** *type timestamp*
- **EventId** *type integer*
- **EventTypeName** *type string*
- **Message** *type string*
- **TaskDisplayName** *type string*
- **ProviderName** *type string*
- **ProviderId** *type string*
- **OpcodeName** *type string*
- **UserId** *type string*
- **MachineName** *type string*
- **ProcessId** *type integer*
- **ThreadId** *type integer*
- **EventType** *type string*
- **KeywordsFlag** *type integer*
- **Opcode** *type string*
- **Task** *type integer*
- **Version** *type string*
- **Qualifiers** *type integer*
- **RelatedActivityId** *type string*
- **ActivityId** *type string*
- **UserAccountName** *type string*
- **KeywordsDisplayNames** *type string*
- **Strings** *type string*
- **RecordIndex** *type integer*

## Examples

------------------------------------------------------------

