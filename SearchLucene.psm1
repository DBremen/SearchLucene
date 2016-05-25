#requires -version 3.0
#http://lucene.apache.org/core/3_6_1/queryparsersyntax.html
Add-Type -Path $PSSCriptRoot\Lucene.Net.dll
$INDEX_DIRECTORY = "$env:temp\luceneIndex"
if (!(Test-Path 'C:\Program Files (x86)\es\es.exe')){
    Write-Warning 'Everything commandline (es.exe) not found please download and install to use this script'
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
            #Create the index for the whole c:\ drive for ps1, psm1, and txt files (default extensions)
            #no output but will take quite a while for a whole drive
            Create-LuceneIndex -DirectoryToBeIndex c:\
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
        [string[]]$Include = @('*.ps1','*.psm1','*.txt*'),
        #Directory that will hold the index files
        [Parameter(Position = 2)]
        [string]$IndexDirectory = $INDEX_DIRECTORY
    )
    if (-not (Test-Path $IndexDirectory)){
        Remove-Item $IndexDirectory -Recurse -Force -ErrorAction SilentlyContinue
    }
    $directory = [Lucene.Net.Store.FSDirectory]::Open($IndexDirectory)
    $analyzer  = New-Object Lucene.Net.Analysis.Standard.StandardAnalyzer("LUCENE_CURRENT")
    #index in ram
    #$directory = [RAMDirectory]::new()
    $indexWriter= New-Object Lucene.Net.Index.IndexWriter($directory,$analyzer,$true,(New-Object Lucene.Net.Index.IndexWriter+MaxFieldLength(25000)))
    if ($Include){
        $includeArg = 'ext:'
        $IncludeArg += $Include -replace '(\*|\.)' -join ';'
    }

    $files = & "C:\Program Files (x86)\es\es.exe" $DirectoryToBeIndexed $IncludeArg
    foreach ($file in $files) {
        try{ 
            $text=[IO.File]::ReadAllText($file) 
            $doc = New-Object Lucene.Net.Documents.Document
            #default name = fulltext (doesn't need to be specified in query)
            $doc.Add((New-Object Lucene.Net.Documents.Field("fulltext",$text,"YES","ANALYZED")))
            $doc.Add((New-Object Lucene.Net.Documents.Field]("path",$file,"YES","ANALYZED")))
            $doc.Add((New-Object Lucene.Net.Documents.Field("extension",[IO.Path]::GetExtension($file),"YES","ANALYZED")))
            $indexWriter.AddDocument($doc)
        }
        catch{
        }
    } 
    $indexWriter.close()
}

function Find-FileLucene{
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
            New-LuceneIndex
    #>
    [CmdletBinding()]
    [Alias('ffl')]
    param (
        #The text to search for supports wildcard pattern
        [Parameter(Mandatory, Position = 0)]
        [string]$searchText,
        [string]$Path = 'c:\',
        #The file extension(s) to include in the search
        [string[]]$Include = '*.ps1',
        #The directory that contains the index defaults to variable specified at the top of the module
        [string]$IndexDirectory = $INDEX_DIRECTORY,
        #Include detailed results with matching line
        [switch]$Detailed

    )
    $queryTxt = $searchText
    foreach ($entry in $PSBoundParameters.GetEnumerator()) {
        switch ($entry.Key){
            {$_ -eq 'Include'} {   $queryTxt += " AND (extension:$($entry.Value[0]))"
                                   if ($entry.Value.Count -gt 1){
                                        $queryTxt = $queryTxt.Substring(0,$queryTxt.Length -1)
                                        $entry.Value | select -Skip 1 | foreach {
                                            $queryTxt += " OR extension:$($_)"
                                        }
                                        $queryTxt += ')'
                                    } 
                                }
            {$_ -eq 'Path'}  {    $queryTxt += " AND path:$($entry.Value)" }
        }
    }
    $directory = [Lucene.Net.Store.FSDirectory]::Open($IndexDirectory)
    $analyzer  = New-Object Lucene.Net.Analysis.Standard.StandardAnalyzer]("LUCENE_CURRENT")
    $indexSearcher = New-Object Lucene.Net.Search.IndexSearcher($directory, $true) # read-only-true
    $parser = New-Object Lucene.Net.QueryParsers.QueryParser("LUCENE_CURRENT", "fulltext", $analyzer)    
    $query = $parser.Parse($queryTxt)    
    $totalDocs = $indexSearcher.Search($query,$null,1000).ScoreDocs
    $result = for ($i = 0; $i -lt $totalDocs.count; $i++) { 
        $hitDoc = $indexSearcher.Doc($totalDocs[$i].Doc)
        $fullPath = $hitDoc.Get("path")
        if ($Detailed){
            Select-String -Path $fullPath -Pattern $SearchText -SimpleMatch 
        }
        else{
            $fullPath 
        }
    } 
    if ($Detailed){
        $result | select Path, LineNumber, Line 
    }
    else{
        $result
    }
    $indexSearcher.Close()
    $directory.Close() 
}

Export-ModuleMember -Function Find-FileLucene, New-LuceneIndex -Alias ffl