# Harmless example post-action: display the execution context exported by ULP.
Write-Output "Rows: $env:ULP_ROWS"
Write-Output "Result sets: $env:ULP_RESULT_SETS"
Write-Output "First value: $env:ULP_FIRST_VALUE"
Write-Output "Output file: $env:ULP_OUTPUT_FILE"
Write-Output "Condition: $env:ULP_CONDITION"
