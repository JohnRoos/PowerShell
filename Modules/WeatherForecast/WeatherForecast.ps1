# Under construction
# Needs a lot of error handling and other things

class ForeCast {
    # Contains a forecast for a specific time and day
    
    # Date and time for the forecast
    [datetime]$ValidTime # date and time for the forecast
    # General
    [decimal]$Temperature # celsius
    [int]$RelativeHumidity # percent
    [int]$ThunderstormProbability # percent
    [decimal]$Visibility # kilometers
    [decimal]$MeanSeaLevel # hPa : Pressure reduced to medium sea level
    # Clouds
    [int]$LowCloudCover # 0-8 
    [int]$MediumCloudCover # 0-8
    [int]$HighCloudCover # 0-8 : 8 = total coverage
    [int]$TotalCloudCover # 0-8
    # Precipitation
    [string]$PrecipitationCategory # see method SetPrecipitationCategory
    [decimal]$SnowPrecipitationIntensity # millimeter
    [decimal]$TotalPrecipitationIntensity # millimeter
    # Wind
    [int]$WindDirection # degree
    [decimal]$WindGustVelocity # m/s
    [decimal]$WindVelocity # m/s

    [void] SetPrecipitationCategory ([int] $i)
    {
        [string]$cat = ""
        switch ($i)
        {
            0 { $cat = 'None' }
            1 { $cat = 'Snow' }
            2 { $cat = 'Snow mixed with rain' }
            3 { $cat = 'Rain' }
            4 { $cat = 'Drizzle' }
            5 { $cat = 'Freezing rain' }
            6 { $cat = 'Freezing drizzle' }
            Default { Write-Error 'Unknown Precipitation Category - Parameter must be between 0 and 6.' }
        }
        $this.PrecipitationCategory = $cat
    }
}

class WeatherForeCast {
    #Contains an array of forecasts and metadata about the location

    # General variables
    [string]$Location
    [decimal]$Longitude
    [decimal]$Latitude
    [datetime]$StartDate
    [datetime]$EndDate

    # The forecast array
    [ForeCast[]]$ForeCast

    # Remove the default methods just for the hell of it
    # hidden [void] GetType () {}
    # hidden [void] GetHashCode () {}
    # hidden [void] Equals () {}
    # hidden [void] ToString () {}

    # Add forecast and update max and min dates
    [void] AddForeCast ( [ForeCast]$x ) {
        $this.ForeCast += $x
        if ($x.ValidTime -lt $this.StartDate -or $this.StartDate -eq [datetime]::MinValue){
            $this.StartDate = $x.ValidTime
        }
        if ($x.ValidTime -gt $this.EndDate){
            $this.EndDate = $x.ValidTime
        }
    }

    # This might be used later. Under construction.
    [ForeCast] GetForeCast ([datetime]$x) {
        return $this.ForeCast
    }

    # Set the location from online rest api using the IP number
    [void] SetGeoLocation () {
        $raw = Invoke-RestMethod -Method Get -Uri 'http://ip-api.com/json'
        $this.Location  = "$($raw.city), $($raw.country)"
        $this.Latitude  = $raw.lat
        $this.Longitude = $raw.lon
    }

    # Downloads the forecast. Sets the location first if needed.
    [void] DownloadForeCast () {
        
        if (!$this.Latitude -or !$this.Longitude){
            $this.SetGeoLocation()
        }

        $lat = $this.Latitude
        $lon = $this.Longitude
        $uri = "http://opendata-download-metfcst.smhi.se/api/category/pmp1.5g/version/1/geopoint/lat/$lat/lon/$lon/data.json"
        $RAWforecast = Invoke-RestMethod -Method Get -Uri $uri

        foreach ($current in $RAWforecast.timeseries) {
            $props = @{
                HighCloudCover              = $current.hcc
                LowCloudCover               = $current.lcc
                MediumCloudCover            = $current.mcc
                MeanSeaLevel                = $current.msl
                SnowPrecipitationIntensity  = $current.pis
                TotalPrecipitationIntensity = $current.pit
                RelativeHumidity            = $current.r
                Temperature                 = $current.t
                TotalCloudCover             = $current.tcc
                ThunderstormProbability     = $current.tstm
                ValidTime                   = $current.ValidTime
                Visibility                  = $current.vis
                WindDirection               = $current.wd
                WindGustVelocity            = $current.gust
                WindVelocity                = $current.ws
            }

            $fc = New-Object -TypeName ForeCast -Property $props
            $fc.SetPrecipitationCategory($current.pcat)

            $this.AddForeCast($fc)
        }
    }
}

break

# Examples of how to use the class
$forecastseries = [WeatherForeCast]::new()
$forecastseries.DownloadForeCast()
$forecastseries
$forecastseries.ForeCast

# Inspect the object
$forecastseries | gm
$forecastseries.ForeCast | gm


# Just get the geo location
$forecastseries.SetGeoLocation()
$forecastseries

# Coordinates for Stockholm which can be used while debugging (or to get crappy weather forecasts)
# Latitud: 59.3420 Longitud: 18.0575
