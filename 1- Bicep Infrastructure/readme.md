# Bicep Infrastructure Demo

```powershell
New-AzDeployment -Name "techtalk-$((New-Guid).Guid)" -Location eastus -TemplateFile .\deploy.bicep -TemplateParameterFile .\environments\dev.parameters.json -WhatIf
```
