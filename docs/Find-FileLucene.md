# Find-FileLucene

## SYNOPSIS
Search file using Lucene.Net

## SYNTAX

### Normal (Default)
```
Find-FileLucene [-searchText] <String> [-Path <String>] [-Include <String[]>] [-IndexDirectory <String>]
```

### Detailed
```
Find-FileLucene [-searchText] <String> [-Path <String>] [-Include <String[]>] [-IndexDirectory <String>]
 [-Detailed] [-MatchColor <ConsoleColor>]
```

## DESCRIPTION
Using Lucene.Net to do a full text search on indexed files by path, and extension.
Output can include detailed results including matching Line and LineNumber (Detailed switch)

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
#Search all indexed files for the word 'test'
```

Find-FileLucene 'test' -Detailed
#outputs detailed results including matching LineNumber and Line

### -------------------------- EXAMPLE 2 --------------------------
```
#Search all indexed .ps1 and .txt files for the word 'test'
```

Find-FileLucene 'test' -Include @('.txt','.ps1')

## PARAMETERS

### -searchText
The text to search for supports wildcard pattern

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
{{Fill Path Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
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
Position: Named
Default value: *.ps1
Accept pipeline input: False
Accept wildcard characters: False
```

### -IndexDirectory
The directory that contains the index defaults to variable specified at the top of the module

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: $__INDEX_DIRECTORY
Accept pipeline input: False
Accept wildcard characters: False
```

### -Detailed
Include detailed results with matching line

```yaml
Type: SwitchParameter
Parameter Sets: Detailed
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -MatchColor
{{Fill MatchColor Description}}

```yaml
Type: ConsoleColor
Parameter Sets: Detailed
Aliases: 
Accepted values: Black, DarkBlue, DarkGreen, DarkCyan, DarkRed, DarkMagenta, DarkYellow, Gray, DarkGray, Blue, Green, Cyan, Red, Magenta, Yellow, White

Required: False
Position: Named
Default value: DarkYellow
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://powershellone.wordpress.com/2016/05/26/full-text-search-using-powershell-everything-and-lucene/](https://powershellone.wordpress.com/2016/05/26/full-text-search-using-powershell-everything-and-lucene/)

[New-LuceneIndex]()

[http://lucene.apache.org/core/3_6_1/queryparsersyntax.html](http://lucene.apache.org/core/3_6_1/queryparsersyntax.html)

