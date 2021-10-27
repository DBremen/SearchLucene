# New-LuceneIndex

## SYNOPSIS
Creates the index on disk for the Lucene search engine

## SYNTAX

```
New-LuceneIndex [[-DirectoryToBeIndexed] <String>] [[-Include] <String[]>] [[-IndexDirectory] <String>]
```

## DESCRIPTION
Using Lucene.Net builds an index within the specified directory recursively.
Properties index are fulltext, path, and extension of the files in the specified folder.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
#Create the index for the whole c:\ drive for '*.ps1', '*.psm1', '*.txt', '*.epub', '*.pdf', '*.doc', '*.docx', '*.pptx', '*.js', '*.php', '*.ejs' files (default extensions)
```

#no output but will take quite a while for a whole drive
Create-LuceneIndex -DirectoryToBeIndex c:\

## PARAMETERS

### -DirectoryToBeIndexed
The directory that contains the files to be indexed

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 1
Default value: C:\
Accept pipeline input: False
Accept wildcard characters: False
```

### -Include
The file extension(s) to include in the search

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: False
Position: 2
Default value: @('*.ps1', '*.psm1', '*.txt', '*.epub', '*.pdf', '*.doc', '*.docx', '*.pptx', '*.js', '*.php', '*.ejs')
Accept pipeline input: False
Accept wildcard characters: False
```

### -IndexDirectory
Directory that will hold the index files

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 3
Default value: $__INDEX_DIRECTORY
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://powershellone.wordpress.com/2016/05/26/full-text-search-using-powershell-everything-and-lucene/](https://powershellone.wordpress.com/2016/05/26/full-text-search-using-powershell-everything-and-lucene/)

[Find-FileLucene]()

