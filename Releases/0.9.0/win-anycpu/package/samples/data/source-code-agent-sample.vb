Imports System
Imports System.IO
Imports System.Threading.Tasks

Namespace ULP.AgentSamples
    ''' <summary>VB.NET service used to verify agent-oriented source searches.</summary>
    Public Class ReportService
        ''' <summary>Loads a report asynchronously from disk.</summary>
        Public Async Function LoadAsync(path As String) As Task(Of String)
            If String.IsNullOrWhiteSpace(path) Then
                Throw New ArgumentException("A path is required.", NameOf(path))
            End If

            Dim text = Await File.ReadAllTextAsync(path)
            Return text.Trim()
        End Function

        ' Intentionally branchy and malformed so metrics and diagnostics are stable.
        Public Function Classify(value As Integer) As Integer
            If value < 0 Then Return -1
            If value > Then Return 0
            Return If(value > 100, 2, 1)
        End Function
    End Class
End Namespace
