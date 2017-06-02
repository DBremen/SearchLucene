function Generate-ScriptMarkdownHelp{
    <#    
    .SYNOPSIS
        The function that generated the Markdown help in this repository. (see Example for usage). 
        Generates markdown help for each function containing comment based help in the module (Description not empty) within a folder recursively and a summary table for the main README.md
    .DESCRIPTION
        platyPS is used to generate the function level help + the README.md is generated "manually".
	.PARAMETER Module
		Name of the Module to generate help for.
    .PARAMETER RepoUrl
        Url for the Git repository homepage
	.EXAMPLE
       Generate-ScriptMarkdownHelp -Module SearchLucene  -RepoUrl https://github.com/DBremen/SearchLucene
#>
    [CmdletBinding()]
    Param($Module)
    $summaryTable = @'
# SearchLucene
Full text search using PowerShell, Everything, and Lucene.
See [Link to my blog post](https://powershellone.wordpress.com/2016/05/26/full-text-search-using-powershell-everything-and-lucene/) for more details

| Function | Synopsis | Documentation |
| --- | --- | --- |
'@
    Import-Module platyps
    $htCheck = @{}
    Import-Module $Module
    $functions = Get-Command -Module $Module
    foreach ($function in $functions){
        try{
            $help =Get-Help $function.Name | Where-Object {$_.Name -eq $function.Name} -ErrorAction Stop
        }catch{
            continue
        }
        if ($help.description -ne $null){
            $htCheck[$function.Name] += 1
            $link = $help.relatedLinks 
            if ($link){
                $link = $link.navigationLink.uri | Where-Object {$_ -like '*powershellone*'}
            }
            $mdFile = $function.Name + '.md'
            $summaryTable += "`n| $($function.Name) | $($help.Synopsis) | $("[Link]($($RepoUrl)/blob/master/docs/$mdFile)") |"
        }
    }
    $docFolder = "$(Split-Path (Get-Module $Module)[0].Path)\docs"
    $summaryTable | Set-Content "$(Split-Path $docFolder -Parent)/README.md" -Force
    $documenation = New-MarkdownHelp -Module $Module -OutputFolder $docFolder -Force
    foreach ($file in (dir $docFolder)){
        $text = (Get-Content -Path $file.FullName | Select-Object -Skip 6) | Set-Content $file.FullName -Force
    }
    #sanity check if help file were generated for each script
    [PSCustomObject]$htCheck
}
Generate-ScriptMarkdownHelp SearchLucene -RepoUrl https://github.com/DBremen/SearchLucene