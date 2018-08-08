function New-WordBlock {
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName, ValueFromPipeline, Mandatory = $true)][Xceed.Words.NET.Container]$WordDocument,
        ### TOC
        [bool] $TocEnable,
        [string] $TocText,
        [int] $TocListLevel,
        [ListItemType] $TocListItemType,
        [HeadingType] $TocHeadingType,
        ### Paragraphs/PageBreaks
        [int] $EmptyParagraphsBefore,
        [int] $EmptyParagraphsAfter,
        [int] $PageBreaksBefore,
        [int] $PageBreaksAfter,
        ### Text Data
        [string] $Text,
        [nullable[Alignment]] $TextAlignment = [Alignment]::Both,

        ### Table Data
        [Object] $TableData,
        [nullable[TableDesign]] $TableDesign,
        [int] $TableMaximumColumns = 5,
        [nullable[bool]] $TableTitleMerge,
        [string] $TableTitleText,
        [nullable[Alignment]] $TableTitleAlignment = 'center',
        [nullable[System.Drawing.Color]] $TableTitleColor = 'Black',
        [switch] $TableTranspose,

        ### List Data
        [Object] $ListData,
        [ListItemType] $ListType,


        ### Chart Data
        [nullable[bool]] $ChartEnable,
        [string] $ChartTitle,
        $ChartKeys,
        $ChartValues,
        [ChartLegendPosition] $ChartLegendPosition = [ChartLegendPosition]::Bottom,
        [bool] $ChartLegendOverlay
    )
    ### PAGE BREAKS BEFORE
    $WordDocument | New-WordBlockPageBreak -PageBreaks $PageBreaksBefore

    ### TOC PROCESSING
    if ($TocEnable) {
        $TOC = $WordDocument | Add-WordTocItem -Text $TocText -ListLevel $TocListLevel -ListItemType $TocListItemType -HeadingType $TocHeadingType
    }

    ### EMPTY PARAGRAPHS BEFORE
    $WordDocument | New-WordBlockParagraph -EmptyParagraphs $EmptyParagraphsBefore

    ### TEXT PROCESSING
    $Paragraph = Add-WordText -WordDocument $WordDocument -Paragraph $Paragraph -Text $Text -Alignment $TextAlignment
    ### TABLE PROCESSING
    if ($TableData) {
        $Table = Add-WordTable -WordDocument $WordDocument -Paragraph $Paragraph -DataTable $TableData -AutoFit Window -Design $TableDesign -DoNotAddTitle:$TableTitleMerge -MaximumColumns $TableMaximumColumns -Transpose:$TableTranspose
        if ($TableTitleMerge) {
            $Table = Set-WordTableRowMergeCells -Table $Table -RowNr 0 -MergeAll  # -ColumnNrStart 0 -ColumnNrEnd 1
            if ($TableTitleText -ne $null) {
                $TableParagraph = Get-WordTableRow -Table $Table -RowNr 0 -ColumnNr 0
                $TableParagraph = Set-WordText -Paragraph $TableParagraph -Text $TableTitleText -Alignment $TableTitleAlignment -Color $TableTitleColor
            }
        }
    }
    ### LIST PROCESSING
    if ((Get-ObjectCount $ListData) -gt 0) {
        $List = Add-WordList -WordDocument $WordDocument -ListType $ListType -Paragraph $Paragraph -ListData $ListData #-Verbose
    } else {
        $Paragraph = Add-WordText -WordDocument $WordDocument -Paragraph $Paragraph -Text $TextListEmpty
    }
    ### CHART PROCESSING
    if ($ChartEnable) {
        $WordDocument | New-WordBlockParagraph -EmptyParagraphs 1
        Add-WordPieChart -WordDocument $WordDocument -ChartName $ChartTitle -Names $ChartKeys -Values $ChartValues -ChartLegendPosition $ChartLegendPosition -ChartLegendOverlay $ChartLegendOverlay
    }
    ### EMPTY PARAGRAPHS AFTER
    $WordDocument | New-WordBlockParagraph -EmptyParagraphs $EmptyParagraphsAfter

    ### PAGE BREAKS AFTER
    $WordDocument | New-WordBlockPageBreak -PageBreaks $PageBreaks
}
function New-WordBlockTable {
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName, ValueFromPipeline, Mandatory = $true)][Xceed.Words.NET.Container]$WordDocument,
        # [parameter(ValueFromPipelineByPropertyName, ValueFromPipeline)]$Paragraph,
        [bool] $TocEnable,
        [string] $TocText,
        [int] $TocListLevel,
        [ListItemType] $TocListItemType,
        [HeadingType] $TocHeadingType,

        [int] $EmptyParagraphsBefore,
        [int] $EmptyParagraphsAfter,
        [int] $PageBreaksBefore,
        [int] $PageBreaksAfter,
        [string] $Text,

        [Object] $TableData,
        [nullable[TableDesign]] $TableDesign,
        [int] $TableMaximumColumns = 5,
        [nullable[bool]] $TableTitleMerge,
        [string] $TableTitleText,
        [nullable[Alignment]] $TableTitleAlignment = 'center',
        [nullable[System.Drawing.Color]] $TableTitleColor = 'Black',
        [switch] $TableTranspose,
        [nullable[bool]] $ChartEnable,
        [string] $ChartTitle,
        $ChartKeys,
        $ChartValues,
        [ChartLegendPosition] $ChartLegendPosition = [ChartLegendPosition]::Bottom,
        [bool] $ChartLegendOverlay
        # [bool] $Supress

    )
    $WordDocument | New-WordBlockPageBreak -PageBreaks $PageBreaksBefore
    if ($TocEnable) {
        $TOC = $WordDocument | Add-WordTocItem -Text $TocText -ListLevel $TocListLevel -ListItemType $TocListItemType -HeadingType $TocHeadingType
    }
    $WordDocument | New-WordBlockParagraph -EmptyParagraphs $EmptyParagraphsBefore
    $Paragraph = Add-WordText -WordDocument $WordDocument -Paragraph $Paragraph -Text $Text

    if ($TableData) {
        $Table = Add-WordTable -WordDocument $WordDocument -Paragraph $Paragraph -DataTable $TableData -AutoFit Window -Design $TableDesign -DoNotAddTitle:$TableTitleMerge -MaximumColumns $TableMaximumColumns -Transpose:$TableTranspose
        if ($TableTitleMerge) {
            $Table = Set-WordTableRowMergeCells -Table $Table -RowNr 0 -MergeAll  # -ColumnNrStart 0 -ColumnNrEnd 1
            if ($TableTitleText -ne $null) {
                $TableParagraph = Get-WordTableRow -Table $Table -RowNr 0 -ColumnNr 0
                $TableParagraph = Set-WordText -Paragraph $TableParagraph -Text $TableTitleText -Alignment $TableTitleAlignment -Color $TableTitleColor
            }
        }
    }
    if ($ChartEnable) {
        $WordDocument | New-WordBlockParagraph -EmptyParagraphs 1
        Add-WordPieChart -WordDocument $WordDocument -ChartName $ChartTitle -Names $ChartKeys -Values $ChartValues -ChartLegendPosition $ChartLegendPosition -ChartLegendOverlay $ChartLegendOverlay
    }
    $WordDocument | New-WordBlockParagraph -EmptyParagraphs $EmptyParagraphsAfter
    $WordDocument | New-WordBlockPageBreak -PageBreaks $PageBreaksAfter
    #if ($Supress) { return } else { return $WordDocument }
}
function New-WordBlockList {
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName, ValueFromPipeline, Mandatory = $true)][Xceed.Words.NET.Container]$WordDocument,
        # [parameter(ValueFromPipelineByPropertyName, ValueFromPipeline)]$Paragraph,
        [bool] $TocEnable,
        [string] $TocText,
        [int] $TocListLevel,
        [ListItemType] $TocListItemType,
        [HeadingType] $TocHeadingType,
        [int] $EmptyParagraphsBefore,
        [int] $EmptyParagraphsAfter,
        [string] $Text,
        [string] $TextListEmpty,

        [Object] $ListData,
        [ListItemType] $ListType
        # [bool] $Supress
    )
    if ($TocEnable) {
        $TOC = $WordDocument | Add-WordTocItem -Text $TocText -ListLevel $TocListLevel -ListItemType $TocListItemType -HeadingType $TocHeadingType
    }
    $WordDocument | New-WordBlockParagraph -EmptyParagraphs $EmptyParagraphsBefore
    $Paragraph = Add-WordText -WordDocument $WordDocument -Paragraph $Paragraph -Text $Text
    if ((Get-ObjectCount $ListData) -gt 0) {
        $List = Add-WordList -WordDocument $WordDocument -ListType $ListType -Paragraph $Paragraph -ListData $ListData #-Verbose
    } else {
        $Paragraph = Add-WordText -WordDocument $WordDocument -Paragraph $Paragraph -Text $TextListEmpty
    }
    $WordDocument |New-WordBlockParagraph -EmptyParagraphs $EmptyParagraphsAfter
    #if ($Supress) { return } else { return $WordDocument }
}
function New-WordBlockParagraph {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipelineByPropertyName, ValueFromPipeline, Mandatory = $true)][Xceed.Words.NET.Container]$WordDocument,
        [int] $EmptyParagraphs
        # [bool] $Supress
    )
    $i = 0
    While ($i -lt $EmptyParagraphs) {
        Write-Verbose "New-WordBlockList - EmptyParagraphs $i"
        $Paragraph = Add-WordParagraph -WordDocument $WordDocument
        $i++
    }
    #if ($Supress) { return } else { return $WordDocument }
}
function New-WordBlockPageBreak {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipelineByPropertyName, ValueFromPipeline, Mandatory = $true)][Xceed.Words.NET.Container]$WordDocument,
        [int] $PageBreaks,
        [bool] $Supress
    )
    $i = 0
    While ($i -lt $PageBreaks) {
        Write-Verbose "New-WordBlockPageBreak - PageBreak $i"
        $WordDocument | Add-WordPageBreak -Supress $True
        $i++
    }
}