# Custom plugin built with Microsoft .Net: -i=CustomPlugin

[Home](../README.MD) | [Information](customplugin_info.md) | [List of parameters](customplugin_parameters_list.md) | [Parameters table](customplugin_parameters_table.md) |  [Default parameter values](customplugin_parameters_defaults.md)

## Parameters:
Parameters for configuring 'Custom plugin built with Microsoft .Net'. String values must be enclosed by double
quotes when they contain spaces and special characters can be escaped with the '\' (backslash). Boolean value
can be True|False or ON|OFF or 1|0. Date-time values are ISO formatted date or date time strings (Ex.
2021-05-16 or "2021-015-016 12:40:23"). Integer and decimal numbers are written without quotes. Arrays are
comma separated values enclosed by double quotes. When there is a list of available values, the parameter can
be one of the listed options. Some parameters are grouped in separate categories or prefixed with a name for
easier reading.


### Category: Plugin settings.

 - DebugMode

	* Default value: -DebugMode=True
	* Description: Compile the source code on each run and display compile and runtime error
	messages. Type: boolean value.

 - SourceCodeFile

	* Default value: -SourceCodeFile=""
	* Description: Plugin source code. Type: string value.

### Category: Advanced.

 - Assemblies

	* Default value: -Assemblies={ -Assemblies={ "system.dll", "System.Core.dll", "system.xml.dll", "system.data.dll", "System.ServiceModel.dll", "System.xml.Linq.dll", "System.Data.Linq.dll" }
	* Description: Type: array.

 - ClassName

	* Default value: -ClassName="CustomDotNetPluginClass"
	* Description: Type: string value.

 - Imports

	* Default value: -Imports={ -Imports={ "System", "System.Xml", "System.Data", "System.Collections", "System.Collections.Generic", "System.Linq", "System.Data.Linq", "Microsoft.VisualBasic", "LizardLabs", "LizardLabs.LogParserLizard", "LizardLabs.LogParser.InputFormats" }
	* Description: Type: array.

 - Namespace

	* Default value: -Namespace="LplDotNetDataSource"
	* Description: Type: string value.

 - SimpleMode

	* Default value: -SimpleMode=True
	* Description: If True the class is auto-generated around the code (just add
	ILogParserInputContext methods). If False, full code with namespace, class and
	called method should be build (useful for complex code with a lot of functions).
	Type: boolean value.

 - TreatWarningsAsErrors

	* Default value: -TreatWarningsAsErrors=False
	* Description: Type: boolean value.


------------------------------------------------------------

