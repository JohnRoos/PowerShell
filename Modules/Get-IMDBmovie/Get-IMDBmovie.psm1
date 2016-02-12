<#
.Synopsis
   This scripts will get some basic information from IMDB about a movie by parcing the html code on the website.
.DESCRIPTION
   This scripts will get some basic information from IMDB about a movie by parcing the html code on the website.

   Created by John Roos 
   Email: john@roostech.se
   Web: http://blog.roostech.se
.EXAMPLE
   Get-ImdbMovie -Title 'star trek'
.EXAMPLE
   Get-ImdbMovie -Title 'star trek' -verbose
#>
function Get-IMDBMovie
{
    [CmdletBinding()]
    Param
    (
        # Enter the title of the movie you want to get information about
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateNotNullorEmpty()]
        [string]$Title
    )
 
    Process
    {
        $searchTitle = $Title.Replace(' ','%20')
 
        Write-Verbose "Fetching search results"
        $moviesearch = Invoke-WebRequest "http://www.imdb.com/search/title?title=$searchTitle&title_type=feature"
         
        Write-Verbose "Moving html elements into variable"
        $titleclassarray = $moviesearch.AllElements | where Class -eq 'title' | select -First 1
         
        Write-Verbose "Checking if result contains movies"
        try {
            $titleclass = $titleclassarray[0]
        }
        catch {
            Write-Warning "No movie found matching that title http://www.imdb.com/search/title?title=$searchTitle&title_type=feature"
            break
        }
         
        if (!($titleclass)){
            Write-Warning "No movie found matching that title http://www.imdb.com/search/title?title=$searchTitle&title_type=feature"
            break
        }
         
        Write-Verbose "Result contains movies."
         
        Write-Verbose "Parcing HTML for movie link."
        $regex = "<\s*a\s*[^>]*?href\s*=\s*[`"']*([^`"'>]+)[^>]*?>"
        $linksFound = [Regex]::Matches($titleclass.innerHTML, $regex, "IgnoreCase")
         
        $titlelink = New-Object System.Collections.ArrayList
        foreach($link in $linksFound)
        {
            $trimmedlink = $link.Groups[1].Value.Trim()
            if ($trimmedlink.Contains('/title/')) {
                [void] $titlelink.Add($trimmedlink)
            }
        }
        Write-Verbose "Movie link found."
 
        $movieURL = "http://www.imdb.com$($titlelink[0])"
        Write-Verbose "Fetching movie page."
        $moviehtml = Invoke-WebRequest $movieURL -Headers @{"Accept-Language"="en-US,en;"}
        Write-Verbose "Movie page fetched."
 
        $movie = New-Object -TypeName psobject
 
        Write-Verbose "Parcing for title."
        Add-Member -InputObject $movie -MemberType 'NoteProperty' -Name "Title" -Value ($moviehtml.AllElements | where Class -eq 'itemprop' | select -First 1).innerText
 
        Write-Verbose "Parcing for directors."
        foreach ($line in ($moviehtml.AllElements | where Class -eq 'txt-block').InnerHTML -split "`n"){
            if ($line -like '*Director:*'){
                $line = $line.Replace('</SPAN></A>','')
                Add-Member -InputObject $movie -MemberType 'NoteProperty' -Name "Directors" -Value $line.Remove(0,$line.LastIndexOf('>')+1)
            }
        }
 
        Write-Verbose "Parcing for year."
        Add-Member -InputObject $movie -MemberType 'NoteProperty' -Name "Year" -Value (($moviehtml.AllElements | where Class -eq 'nobr' | select -First 1).innerText).Replace('(','').Replace(')','')
 
        Write-Verbose "Parcing for rating."
        Add-Member -InputObject $movie -MemberType 'NoteProperty' -Name "Rating" -Value ($moviehtml.AllElements | where Class -eq 'titlePageSprite star-box-giga-star' | select -First 1).innerText
 
        Write-Verbose "Parcing for description."
        Add-Member -InputObject $movie -MemberType 'NoteProperty' -Name "Description" -Value ($moviehtml.AllElements | where itemprop -eq 'description' | select -first 1).InnerText
 
        Write-Verbose "Parcing for writers."
        Add-Member -InputObject $movie -MemberType 'NoteProperty' -Name "Writers" -Value ($moviehtml.AllElements | where itemprop -eq 'creator' | select -first 1).InnerText.Replace('Writers:','').Replace(' »','')
 
        Write-Verbose "Parcing for stars."
        Add-Member -InputObject $movie -MemberType 'NoteProperty' -Name "Stars" -Value ($moviehtml.AllElements | where itemprop -eq 'actors').InnerText.Replace('Stars:','').Replace(' | See full cast and crew »','')
 
        Write-Verbose "Adding the link."
        Add-Member -InputObject $movie -MemberType 'NoteProperty' -Name "Link" -Value $movieURL
 
        Write-Verbose "Returning object."
        $movie
    }
}