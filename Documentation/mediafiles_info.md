# Delimiter-separated values: -i=MediaFiles

## Description

Delimiter-separated values. Command line switch to use this input format is -i=MediaFiles.

## From-Entity Syntax

The <from-entity> specified in queries using the MediaFiles input format can be:
- Comma-separated list of paths of log files, eventually including wildcards (glob pattern is supported).
- The URL of a file if located on HTTP, FTP or S3.
- Other (specific for the -i=MediaFiles format.

## Parameters

- [Home](../README.MD)
- [List of parameters](mediafiles_parameters_list.md)
- [Parameters table](mediafiles_parameters_table.md)
- [Default parameter values](mediafiles_parameters_defaults.md)
## Fields

- **Name** *type string*
- **FullName** *type string*
- **Directory** *type string*
- **Extension** *type string*
- **LengthInBytes** *type integer*
- **IsReadOnly** *type string*
- **Attributes** *type string*
- **CreationTime** *type timestamp*
- **LastAccessTime** *type timestamp*
- **LastWriteTime** *type timestamp*
- **MimeType** *type string*
- **Writeable** *type string*
- **PossiblyCorrupt** *type string*
- **CorruptionReasons** *type string*
- **TagTypesOnDisk** *type string*
- **TagTypes** *type string*
- **PhotoWidth** *type integer*
- **PhotoHeight** *type integer*
- **PhotoQuality** *type integer*
- **VideoWidth** *type integer*
- **VideoHeight** *type integer*
- **MediaTypes** *type string*
- **Codecs** *type string*
- **Description** *type string*
- **AudioBitrate** *type integer*
- **AudioSampleRate** *type integer*
- **BitsPerSample** *type integer*
- **AudioChannels** *type integer*
- **Duration** *type timestamp*
- **DurationTimeSpan** *type timestamp*
- **DurationInDays** *type real*
- **DurationInHours** *type real*
- **DurationInMinutes** *type real*
- **DurationInSeconds** *type real*
- **DurationInMilliseconds** *type integer*
- **MediaProperties** *type string*
- **RecordIndex** *type integer*

## Examples

------------------------------------------------------------

