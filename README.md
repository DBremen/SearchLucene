# SearchLucene
Full text search using PowerShell, Everything, and Lucene. With the help of [Toxy](https://www.nuget.org/packages/Toxy/) and [EpubSharp](https://github.com/asido/EpubSharp) this also works with .pdf, .epub and other file formats.

## Prerequisites (pathes need to be updated accordingly):

| Name                             | Source                                                |
| -------------------------------- | ----------------------------------------------------- |
| Toxy                             | https://www.nuget.org/packages/Toxy                   |
| EpubSharp                        | https://github.com/asido/EpubSharp                    |
| es.exe (Everything command line) | https://voidtools.com/downloads/                      |
| rga (aka ripgrep-all)            | https://community.chocolatey.org/packages/ripgrep-all |

See [link to my blog post](https://powershellone.wordpress.com/2016/05/26/full-text-search-using-powershell-everything-and-lucene/) for more details.


| Function | Synopsis | Documentation |
| --- | --- | --- |
| Find-FileLucene | Search file using Lucene.Net | [Link](https://github.com/DBremen/SearchLucene/blob/master/docs/Find-FileLucene.md) |
| New-LuceneIndex | Creates the index on disk for the Lucene search engine | [Link](https://github.com/DBremen/SearchLucene/blob/master/docs/New-LuceneIndex.md) |
