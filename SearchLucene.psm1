﻿#requires -version 3.0
#New-MarkdownHelp -Module SearchLucene -OutputFolder "$env:USERPROFILE\Dropbox\WindowsPowerShell_ProgramFiles\Modules\SearchLucene\" -Force
Add-Type -Path $PSSCriptRoot\Lucene.Net.dll
$global:__INDEX_DIRECTORY = "$env:USERPROFILE\i\luceneIndex"
if (!(Test-Path 'C:\Program Files (x86)\es\es.exe')) {
    Write-Warning 'Everything commandline (es.exe) not found please download and install to use this script'
    exit
}
if (!(Get-Command "rga.exe" -ErrorAction SilentlyContinue)) {
    Write-Warning 'rga.exe aka ripgrep-all not found please download and instal via chocolatey'
    exit
}


function New-LuceneIndex {
    <#
        .SYNOPSIS
            Creates the index on disk for the Lucene search engine
        .DESCRIPTION
            Using Lucene.Net builds an index within the specified directory recursively.
            Properties index are fulltext, path, and extension of the files in the specified folder.
        .EXAMPLE
            #Create the index for the whole c:\ drive for '*.ps1', '*.psm1', '*.txt', '*.epub', '*.pdf', '*.doc', '*.docx', '*.pptx', '*.js', '*.php', '*.ejs' files (default extensions)
            #no output but will take quite a while for a whole drive
            Create-LuceneIndex -DirectoryToBeIndex c:\
        .LINK
            https://powershellone.wordpress.com/2016/05/26/full-text-search-using-powershell-everything-and-lucene/
        .LINK
            Find-FileLucene
    #>
    [CmdletBinding()]
    param (
        #The directory that contains the files to be indexed
        [Parameter(Position = 0)]
        [string]$DirectoryToBeIndexed = 'c:\',
        #The file extension(s) to include in the search
        [Parameter(Position = 1)]
        [string[]]$Include = @('*.ps1', '*.psm1', '*.txt', '*.epub', '*.pdf', '*.doc', '*.docx', '*.pptx', '*.js', '*.php', '*.ejs'),
        #Directory that will hold the index files
        [Parameter(Position = 2)]
        [string]$IndexDirectory = $__INDEX_DIRECTORY
    )
    Add-Type -Path  'C:\Scripts\ps1\EpubSharp\EpubSharp.dll'
    Add-Type -Path "C:\Scripts\ps1\toxy\Toxy.dll"
    if (Test-Path $IndexDirectory) {
        Remove-Item $IndexDirectory -Recurse -Force -ErrorAction SilentlyContinue
    }
    $null = mkdir $IndexDirectory -Force
    $directory = [Lucene.Net.Store.FSDirectory]::Open($IndexDirectory)
    $analyzer = New-Object Lucene.Net.Analysis.Standard.StandardAnalyzer("LUCENE_CURRENT")
    #index in ram
    #$directory = [RAMDirectory]::new()
    $indexWriter = New-Object Lucene.Net.Index.IndexWriter($directory, $analyzer, $true, (New-Object Lucene.Net.Index.IndexWriter+MaxFieldLength(25000)))
    if ($Include) {
        $includeArg = 'ext:'
        $IncludeArg += $Include -replace '(\*|\.)' -join ';'
    }

    $files = & "C:\Program Files (x86)\es\es.exe" $DirectoryToBeIndexed $IncludeArg
    foreach ($file in $files) {
        try {
            $ext = [IO.Path]::GetExtension($file)
            if ($ext -eq '.epub') {
                $book = [EpubSharp.EpubReader]::Read($file)
                $text = $book.ToPlainText()
            }
            elseif ($ext -in ('.pdf', '.doc', '.docx', '.pptx')) {
                $context = new-object toxy.ParserContext($file);
                $parser = [toxy.parserfactory]::CreateText($context)
                $text = $parser.Parse()
            }
            else {
                $text = [IO.File]::ReadAllText($file)
            }
            $doc = New-Object Lucene.Net.Documents.Document
            #default name = fulltext (doesn't need to be specified in query)
            $doc.Add((New-Object Lucene.Net.Documents.Field("fulltext", $text, "YES", "ANALYZED")))
            $doc.Add((New-Object Lucene.Net.Documents.Field]("path", $file, "YES", "ANALYZED")))
            $doc.Add((New-Object Lucene.Net.Documents.Field("extension", $ext, "YES", "ANALYZED")))
            $indexWriter.AddDocument($doc)
        }
        catch {
        }
    }
    $indexWriter.close()
}
filter ColorPattern( [string]$Pattern, [ConsoleColor]$Color, [switch]$SimpleMatch ) {
    if( $SimpleMatch ) { $Pattern = [regex]::Escape( $Pattern ) }

    $split = $_ -split $Pattern
    $found = [regex]::Matches( $_, $Pattern, 'IgnoreCase' )
    for( $i = 0; $i -lt $split.Count; ++$i ) {
    Write-Host $split[$i] -NoNewline
    Write-Host $found[$i] -NoNewline -ForegroundColor $Color -BackgroundColor White
    }

    Write-Host
}
function Find-FileLucene {
    <#
        .SYNOPSIS
            Search file using Lucene.Net
        .DESCRIPTION
            Using Lucene.Net to do a full text search on indexed files by path, and extension.
            Output can include detailed results including matching Line and LineNumber (Detailed switch)
        .EXAMPLE
            #Search all indexed files for the word 'test'
            Find-FileLucene 'test' -Detailed
            #outputs detailed results including matching LineNumber and Line
        .EXAMPLE
            #Search all indexed .ps1 and .txt files for the word 'test'
            Find-FileLucene 'test' -Include @('.txt','.ps1')
        .LINK
            https://powershellone.wordpress.com/2016/05/26/full-text-search-using-powershell-everything-and-lucene/
        .LINK
            New-LuceneIndex
        .LINK
            http://lucene.apache.org/core/3_6_1/queryparsersyntax.html
    #>
    [CmdletBinding(DefaultParameterSetName='Normal')]
    [Alias('ffl')]
    param (
        #The text to search for supports wildcard pattern
        [Parameter(Mandatory, Position = 0,ParameterSetName = 'Normal')]
        [Parameter(Mandatory, Position = 0,ParameterSetName = 'Detailed')]
        [string]$searchText,
        [Parameter(ParameterSetName = 'Normal')]
        [Parameter(ParameterSetName = 'Detailed')]
        [string]$Path = 'c:\',
        #The file extension(s) to include in the search
        [Parameter(ParameterSetName = 'Normal')]
        [Parameter(ParameterSetName = 'Detailed')]
        [string[]]$Include = '*.ps1',
        #The directory that contains the index defaults to variable specified at the top of the module
        [Parameter(ParameterSetName = 'Normal')]
        [Parameter(ParameterSetName = 'Detailed')]
        [string]$IndexDirectory = $__INDEX_DIRECTORY,
        #Include detailed results with matching line
        [Parameter(ParameterSetName = 'Detailed')]
        [switch]$Detailed,
        [Parameter(ParameterSetName = 'Detailed')]
        [ConsoleColor]$MatchColor = 'DarkYellow'

    )
    $queryTxt = $searchText
    foreach ($entry in $PSBoundParameters.GetEnumerator()) {
        switch ($entry.Key) {
            { $_ -eq 'Include' } {
                $queryTxt += " AND (extension:$($entry.Value[0]))"
                if ($entry.Value.Count -gt 1) {
                    $queryTxt = $queryTxt.Substring(0, $queryTxt.Length - 1)
                    $entry.Value | select -Skip 1 | foreach {
                        $queryTxt += " OR extension:$($_)"
                    }
                    $queryTxt += ')'
                }
            }
            { $_ -eq 'Path' } { $queryTxt += " AND path:$($entry.Value)" }
        }
    }
    $directory = [Lucene.Net.Store.FSDirectory]::Open($IndexDirectory)
    $analyzer = New-Object Lucene.Net.Analysis.Standard.StandardAnalyzer]("LUCENE_CURRENT")
    $indexSearcher = New-Object Lucene.Net.Search.IndexSearcher($directory, $true) # read-only-true
    $parser = New-Object Lucene.Net.QueryParsers.QueryParser("LUCENE_CURRENT", "fulltext", $analyzer)
    $query = $parser.Parse($queryTxt)
    $totalDocs = $indexSearcher.Search($query, $null, 1000).ScoreDocs
    $result = for ($i = 0; $i -lt $totalDocs.count; $i++) {
        $hitDoc = $indexSearcher.Doc($totalDocs[$i].Doc)
        $fullPath = $hitDoc.Get("path")
        if ($Detailed) {
            (rga $SearchText $fullPath -n).foreach{
                if ($_ -match '^\d+:.*\d+:'){
                    $null,$location,$line = $_.Split(':')
                    $location = $location.Replace('Page ','')
                    $location = "p. $location"
                }
                elseif ($_ -match '^\d+:.*'){
                    $location, $line = $_.Split(':')
                }
                else { 
                    $line = $_
                    $location = 'x'
                }
                $line = $line.Trim()
                [PSCustomObject][ordered]@{
                    Location  = $location
                    Line        = $line
                    Path        = $fullPath
                }
            }
        }
        else {
            $fullPath
        }
    }
    if ($Detailed) {
        $result | ColorPattern -Pattern $searchText -Color $MatchColor -SimpleMatch
    }
    else {
        $result | Invoke-Fzf -Multi -previewwindow 'right:60%' -preview 'bat --color=always --style=full --line-range :300 {}'
    }
    $indexSearcher.Close()
    $directory.Close()
}

Export-ModuleMember -Function Find-FileLucene, New-LuceneIndex -Alias ffl