# Portable Log Parser

Portable log parser  is a command line tool for Microsoft Windows that will parse various system logs and use SQLite 
engine to query them. Output the results to the console, file, database, web service, etc. This repository is for documentation, plugins and samples. Developed by [Lizard Labs Software](http://www.lizard-labs.com){:target="_blank"}

*Note: this project is still in test and development phase. Portable log parser is not available yet for general public. 
The final version will be released soon. The documentation here may be changed with the final release*

## Main features

- Command line tool for querying various log files and text based data using SQL.
- Read data with some of the many supported input formats: 
  - W3C - Apache and IIS logs, 
  - log4net/log4j - in XML or multi-line text files, 
  - Windows System Events, 
  - Text files, 
  - CSV/TSV formated files, 
  - extract fields with regular expression (RegEx/GROK), 
  - multi-line records, 
  - key-value pairs, 
  - custom plugins, etc.
- Output to different formats and destination streams
- Reading files from local file system or stored on FTP, HTTP, Amazon AWS S3, etc.
- Reading data directly from compressed or encrypted files (.gz, .zip).
- Results can be delivered to various (ex. console, file, , SQL Server database, Text Based UI (TUI) in  (ex. Markdown, TSV, CSV, JSON, XML, Excel, etc.) 
- Extensible trough pluggin programming interface
- Versatile - not only for log files but for many other data files.
- Portable (no installation required).
- Free for personal and professional use 

## Queries

SQLite engine is used to query logs data with SQL. 

### General Syntax of a PLP query

This is a general syntax of PLP query used to query some data from log files:

  > CREATE VIRTUAL TABLE temp.***vtablename*** USING ParsingModule('***from***',***input format and parameters***); -- define data input  
  > SELECT * FROM ***vtablename***; -- actual query;

- **vtablename** is a unique name of the virtual table
- **from**  is a comma separated list of files or event sources. Accepts wildcards and glob characters (ex. 'c:\logs\*.log, c:\logs\somelog.txt')
- **input format and parameters** sets the parsing format and properties that will be used to parse the input

Logs are imported trough the [virtual table mechanism of SQLite](https://sqlite.org/vtab.html){:target="_blank"}. ParsingModule, which is 
built in Portable Log Parser, receives parameters for logs source (ex. path to the log file or files using GLOB syntax) and input format properties that tells the 
engine how to process records, columns, etc. Multiple virtual tables for same or different input formats can be created in a single query. More details about input format 
parameters can be found in the PLP documentation.


After configuring the virtual table, SQLLite query language is used to query data. This includes a number of powerful 
features including filtering, grouping, joins, grouping, set operations (union, except, intersect), window-functions, etc. 
SQLite querying engine is really powerful and capable to execute very complex queries. Find out more about writing 
SQLite SELECT queries reading the [official SQLite documentation](https://sqlite.org/windowfunctions.html){:target="_blank"} or 
various [tutorials](https://www.sqlitetutorial.net/sqlite-select/){:target="_blank"} that can be found all around the Internet.


### Sample queries

Here are some sample PLP queries that configure virtual tables and execute queries against them.

- Read last 100 events from system event log:   

  > CREATE VIRTUAL TABLE temp.evt  USING ParsingModule('System',-EVT);  
  > SELECT * FROM evt limit 100;

- Count event type from entiresystem event log:   

  > CREATE VIRTUAL TABLE temp.evt  USING ParsingModule('System',-EVT);  
  > SELECT EventType, EventTypeName, count(*)  
  > FROM evt  
  > GROUP BY EventType, EventTypeName;

![Portable Log Parser console output in markdown text format](documentation\images\PortableLogParser_Console_MarkDown.png "Portable Log Parser console output in markdown text format")    

- Counting the GET requests in IIS W3C log:

   > CREATE VIRTUAL TABLE temp.w3c USING ParsingModule('c:\logfiles\u_ex2105*_x.log', -i=W3C);
   > SELECT count(*) as NoOfRequests  
   > FROM w3c  
   > WHERE [cs-method] = 'GET'

- Different input types in a single query:

  > CREATE VIRTUAL TABLE temp.textlineHuge USING ParsingModule('c:\txtfiles\*.txt', '-i=TextLine');  
  > CREATE VIRTUAL TABLE temp.w3c USING ParsingModule('c:\logfiles\u_ex2105*_x.log', -i=W3C);
  > 
  >SELECT * FROM w3c  
  > ORDER BY [time] DESC  
  > LIMIT 1000; -- last 1000 requests from w3c log  
  >  
  > SELECT * FROM textlineHuge  
  > WHERE Text like '%results%'  
  > ORDER BY Text; -- filter and sort lines with word 'results' from a text file(s)  

### SQLite engine

We have chosen to use SQLite because it has a powerful and extensible querying engine that is proven and widely popular.
Out of the box PLP includes these SQLite extensions: json1, eval, crypt, compress, completion, 
extension-functions (math functions),  fts5,  percentile, regexp,  series,  totype. We will probably include more in future releases.
Read more about these in the SQLite documentation. If you need some extension that could be useful send us an email 
so we can consider including it in the package.


## Portable Log Parser Lizard command line

Portable log parser is command line tool. Command-line executable is a binary file "plogparser.exe" that can be used from the 
Windows command-line shell to execute queries and perform other tasks. The binaries included in the package does 
not require any installation; once copied to a computer, PLP is ready to use.


Help Mode, activated with the "-h" or "-?" switch, offers users the possibility to access quick reference help topics displayed to 
the console output. The help topics can be selectable through additional command-line arguments for each input format.

Example command lines:

- The following command run the query and output to console in vertical list (default output)
  > plogparser.exe "create table temp.evt1 ParsingModule('System',-EVT); select * from evt1 limit 100;"

- Shortcuts to write queries. The above query can be executed this way too:
  > plogparser.exe -i=EVT -from="System" -limit=100

- Read query from a file, write results to a file in markdown format:
  > plogparser.exe "c:\queries\query1.sql" -o="c:\reports\logoutput.md" -fmt=md 

- Use shortcuts to build query that reads last 100 error messages from Windows system log and display them in Text-based User Interface (TUI):
  > plogparser.exe -i=EVT -from="System" -select="TimeCreated, Message" -where="EventTypeName='Error'" -orderby="TimeCreated DESC" -limit=100 -o=tui 


![Portable Log Parser Text-based user interface - TUI](documentation\images\PortableLogParser_TUI.png "Portable Log Parser Text-based user interface - TUI")

## Available Input Formats
This is a list of available input format. Input format is set with ***-i=format*** switch. Each format can be configured with additional parameters. More information about configuration parameters can be found in the documentation.

- [Windows event log reader: -i=EVT](documentation/EVT_parameters.md)
- [Multiline text parser using regular expressions (also supports Grok syntax): -i=RegEx](documentation/RegEx_parameters.md)
- [Comma-separated values: -i=CSV](documentation/CSV_parameters.md)
- [Tab-separated values: -i=TSV](documentation/TSV_parameters.md)
- [W3C format reader (IIS, FTP, Apache, ISA, Exchange, SMTP, MediaSvc, etc.): -i=W3C](documentation/W3C_parameters.md)
- [Text line input format: -i=TextLine](documentation/TextLine_parameters.md)
- [Text word input format: -i=TextWord](documentation/TextWord_parameters.md)
- [Dates table: -i=Delimiter](documentation/Delimiter_parameters.md)
- [Log4j/log4net XML Format: -i=log4jXML](documentation/log4jXML_parameters.md)
- [JSON formated log: -i=JsonLog](documentation/JsonLog_parameters.md)
- [Numbers table: -i=Numbers](documentation/Numbers_parameters.md)
- [Media files information: -i=Dates](documentation/Dates_parameters.md)
- [Delimiter-separated values: -i=MediaFiles](documentation/MediaFiles_parameters.md)
- [Custom plugin built with Microsoft .Net: -i=CustomPlugin](documentation/CustomPlugin_parameters.md)

## Available Output types and formats

- Text based output to the console, file or network stream in any of these formats:
  - Vertical list
  - Tab separated fields (TSV)
  - Delimiter separated fields (ex. comma with or without quote)
  - Markdown formatted table(s)
  - JSON
  - XML
  - plugins for custom formatting
- Excel file
- TUI - text based user interface
- Microsoft SQL Server database
- GUI - graphical user interface (planned for future releases)
- Web UI - WebAPI and Web based application (planned for future releases)


## Extensibility (plugins)

PLP plugins C# or VB.NET can be written for these components:

- Custom input formats,
- Custom text output formats (ex. customized XML or JSON),
- Custom output (ex. to HTTP stream),
- Extension functions for use in SQL queries.

## Performance

On average laptop (Intel i7, 16 GB RAM) PLP parsed and sorted large file (200 MB) in about 20 seconds, and read trough lines of a 10 GB text file in about 1:17 minutes:

> CREATE VIRTUAL TABLE temp.w3cLarge USING ParsingModule('c:\logs\large.log', -i:W3C); -- large file, ~200 MB, 471,651 log lined parsed as W3C file  
>
> CREATE VIRTUAL TABLE temp.textlineHuge USING ParsingModule({fnameHuge}, '-i=TextLine'); -- huge file, ~10 GB, 20,752,820 log lines  
>
> SELECT * FROM w3cLarge ORDER BY [time] DESC; -- parsing and sorting of large file finished in about 20 seconds  
>
> SELECT count(*) as CntHuge FROM textlineHuge; -- parsing and counting the log lines of a huge file finished in 1:17 minutes 


## Installation

If you don't want to use installer, you can use portable version. Download the zip archive from this link PortableLogParser.zip.

Extract and copy the ZIP archive content to any folder.

Read End User License Agreement (EULA) located in documentation folder.
 
If you accept EULA, then launch Portable Log Parser. Otherwise delete all files of "Portable Log Parser" installation package.

## Microsoft Log Parser replacement?

Microsoft Logparser 2.2 is a popular and versatile tool that provides universal query access to text-based data such as log files, 
XML files and CSV files, as well as key data sources on the Windows operating system such as the Event Log and the Registry. 
Logparser is loved by the community for its flexibility and performance and still used by many professionals. We even made a 
GUI for MS Logparser, [Log Parser Lizard](https://lizard-labs.com/log_parser_lizard.aspx){:target="_blank"}, that is downloaded by a hundred of 
thousands of users worldwide. You can find more about log parser here () and here()

Unfortunately Microsoft stopped its development a while ago. There are no new features added for years. MS Logparser is a 32 bit application
that also brings some limitations for modern platforms.

Therefore we decided to build Portable Log Parser. PLP is not 100% compatible with MS logparser but our plan is to add as 
many features as possible. Also in many ways, PLP could be better than MS Logparser. Hopefully, with the help of the 
community PLP,  will be accepted as a decent Microsoft Logparser 2.2 replacement. 

## Contributing

At this moment, the "Portable Log Parser" is free to use and not open sourced (yet).  We will continue to work on the project. 
Hopefully there will be enough interest, so please star or share this repository. All contributions are welcome.

### How can I contribute?

You can contribute in the following ways:

- Show interest in using this tool.
- Report an issue.
- Suggest a feature.
- Promoting PLP and the site to others.
- Create samples that we can put here. This will help others to learn.
- Send us a sample log files so we can build a parsers for them.
- Tell us your user story - why you need a good log parser and how you want to use it.
- Which features you are missing in other log parsing tools so we can develop them in PLP and LPL.
- Creating tutorials and guides.
- Tweet or blog about how you used PLP in certain situation.
- Check our software offering at [Lizard Labs Software](http://www.lizard-labs.com){:target="_blank"}. There are pretty good tools there, you might find something useful.
- For complete log parsing GUI experience take a look at [Log Parser Lizard](https://lizard-labs.com/log_parser_lizard.aspx){:target="_blank"}

We're glad to know you're interested in this project.


## Log parsing with desktop GUI
To get the best log parsing experience using SQL queries, you can try our [Log Parser Lizard](https://lizard-labs.com/log_parser_lizard.aspx){:target="_blank"} which can also manage and run SQL Server queries against various log formats. To support "Portable Log Parser", you can buy a LPL license.

![Log Parser Lizard - GUI](https://lizard-labs.com/images/lpl/Log%20Parser%20Lizard%20screenshot%20animation.gif "Log Parser Lizard")

### Future plans

We have plans to continue our work on log parsing tools in the near future. We will build a new desktop and Web GUI tools that will use PLP engine for reading log files.

We will include more input and output formats, functions, plugins, samples, etc. 

We will make LPL extensible so anyone can write plugins for input formats, functions, output formats or output streams (ex. to call custom Web API).

Currently PLP is developed on Microsoft .NET Framework 4.x for Microsoft Windows. Our plans is to port it to .NET 5 and make it available for other platforms too.

Send us your feedback at office@lizard-labs.com so we can make better software tools for you.

***Your contributions are welcome!***

 


