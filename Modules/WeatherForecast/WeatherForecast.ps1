# Under construction
# Needs a lot of error handling and other things

class ForeCast {
    # Contains a forecast for a specific time and day
    
    # Date and time for the forecast
    [datetime]$ValidTime # date and time for the forecast
    # General
    [decimal]$Temperature # celsius
    [int]$RelativeHumidity # percent
    [int]$ThunderProbability # percent
    [decimal]$Visibility # kilometers
    [decimal]$AirPressure # hPa : Pressure reduced to medium sea level
    # Clouds
    [int]$LowCloudCover # 0-8 
    [int]$MediumCloudCover # 0-8
    [int]$HighCloudCover # 0-8 : 8 = total coverage
    [int]$TotalCloudCover # 0-8
    # Precipitation
    [string]$PrecipitationCategory # see method SetPrecipitationCategory
    #[decimal]$SnowPrecipitationIntensity # millimeter
    [decimal]$MinimumPrecipitationIntensity # millimeter per hour
    [decimal]$MaximumPrecipitationIntensity # millimeter per hour
    # Wind
    [int]$WindDirection # degree
    [decimal]$WindGustVelocity # m/s
    [decimal]$WindVelocity # m/s
    # Weather symbol
    [string]$WeatherSymbol  # see method SetWeatherSymbol

    

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

    [void] SetWeatherSymbol ([int] $i)
    {
        [string]$cat = ""
        switch ($i)
        {
            1  { $cat = 'Clear sky' }
            2  { $cat = 'Nearly clear sky' }
            3  { $cat = 'Variable cloudiness' }
            4  { $cat = 'Halfclear sky' }
            5  { $cat = 'Cloudy sky' }
            6  { $cat = 'Overcast' }
            7  { $cat = 'Fog' }
            8  { $cat = 'Rain showers' }
            9  { $cat = 'Thunderstorm' }
            10 { $cat = 'Light sleet' }
            11 { $cat = 'Snow showers' }
            12 { $cat = 'Rain' }
            13 { $cat = 'Thunder' }
            14 { $cat = 'Sleet' }
            15 { $cat = 'Snowfall' }
            Default { Write-Error 'Unknown Weather Symbol - Parameter must be between 1 and 15.' }
        }
        $this.WeatherSymbol = $cat
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
    hidden [ForeCast] GetForeCast ([datetime]$x) {
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

        $lat = $this.Latitude.ToString().Replace(',','.')
        $lon = $this.Longitude.ToString().Replace(',','.')
        
        #Old API
        #$uri = "http://opendata-download-metfcst.smhi.se/api/category/pmp1.5g/version/1/geopoint/lat/$lat/lon/$lon/data.json"

        #New API
        $uri = "http://opendata-download-metfcst.smhi.se/api/category/pmp2g/version/2/geotype/point/lon/$lon/lat/$lat/data.json"

        $RAWforecast = Invoke-RestMethod -Method Get -Uri $uri

        foreach ($current in $RAWforecast.timeseries) {
            $props = @{
                    ValidTime                     = $current.ValidTime
                    HighCloudCover                = ($current.parameters | Where-Object name -eq 'hcc_mean').values | Select-Object -First 1
                    LowCloudCover                 = ($current.parameters | Where-Object name -eq 'lcc_mean').values | Select-Object -First 1
                    MediumCloudCover              = ($current.parameters | Where-Object name -eq 'mcc_mean').values | Select-Object -First 1
                    AirPressure                   = ($current.parameters | Where-Object name -eq 'msl').values | Select-Object -First 1
                    MinimumPrecipitationIntensity = ($current.parameters | Where-Object name -eq 'pmin').values | Select-Object -First 1
                    MaximumPrecipitationIntensity = ($current.parameters | Where-Object name -eq 'pmax').values | Select-Object -First 1
                    RelativeHumidity              = ($current.parameters | Where-Object name -eq 'r').values | Select-Object -First 1
                    Temperature                   = ($current.parameters | Where-Object name -eq 't').values | Select-Object -First 1
                    TotalCloudCover               = ($current.parameters | Where-Object name -eq 'tcc_mean').values | Select-Object -First 1
                    ThunderProbability            = ($current.parameters | Where-Object name -eq 'tstm').values | Select-Object -First 1
                    Visibility                    = ($current.parameters | Where-Object name -eq 'vis').values | Select-Object -First 1
                    WindDirection                 = ($current.parameters | Where-Object name -eq 'wd').values | Select-Object -First 1
                    WindGustVelocity              = ($current.parameters | Where-Object name -eq 'gust').values | Select-Object -First 1
                    WindVelocity                  = ($current.parameters | Where-Object name -eq 'ws').values | Select-Object -First 1
            }
            $PrecipicationCategoryID = ($current.parameters | Where-Object name -eq 'pcat').values | Select-Object -First 1
            $WeatherSymbolID         = ($current.parameters | Where-Object name -eq 'Wsymb').values | Select-Object -First 1

            $fc = New-Object -TypeName ForeCast -Property $props
            $fc.SetPrecipitationCategory($PrecipicationCategoryID)
            $fc.SetWeatherSymbol($WeatherSymbolID)

            $this.AddForeCast($fc)
        }
    }
}


break

# Examples of how to use the class
$forecastseries = [WeatherForeCast]::new()
$forecastseries.DownloadForeCast()
$forecastseries
$forecastseries.ForeCast | select -First 10


# Inspect the object
$forecastseries | gm
$forecastseries.ForeCast | gm


# Just get the geo location
$forecastseries.SetGeoLocation()
$forecastseries

# Coordinates for Stockholm which can be used while debugging (or to get crappy weather forecasts)
# Latitud: 59.3420 Longitud: 18.0575
