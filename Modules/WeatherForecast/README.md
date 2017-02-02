# WeatherForecast class
This is a PowerShell class which is used for getting weather forecasts from SMHI (www.smhi.se).
Why a class? Why not? :)

## Example
Create a new object based on the class.
```
PS C:\> $forecastseries = [WeatherForeCast]::new()
```
Use method DownloadForeCast to refresh the object with current data from the API.
```
PS C:\> $forecastseries.DownloadForeCast()
```
Check the object.
```
PS C:\> $forecastseries

Location  : Stockholm, Sweden
Longitude : 18.05
Latitude  : 59.3333
StartDate : 2017-02-02 16:00:00
EndDate   : 2017-02-12 01:00:00
ForeCast  : {ForeCast, ForeCast, ForeCast, ForeCast...}
```
It`s a ten day forecast. The first day is on an hourly basis and the later days have lower frequency. 
Check the first two results.
```
PS C:\> $forecastseries.ForeCast | select -First 2

ValidTime                     : 2017-02-02 16:00:00
Temperature                   : 0.9
RelativeHumidity              : 81
ThunderProbability            : 0
Visibility                    : 8.0
AirPressure                   : 1016
LowCloudCover                 : 8
MediumCloudCover              : 0
HighCloudCover                : 0
TotalCloudCover               : 8
PrecipitationCategory         : None
MinimumPrecipitationIntensity : 0.0
MaximumPrecipitationIntensity : 0.0
WindDirection                 : 197
WindGustVelocity              : 6.1
WindVelocity                  : 2.9
WeatherSymbol                 : Overcast

ValidTime                     : 2017-02-02 17:00:00
Temperature                   : 0.7
RelativeHumidity              : 83
ThunderProbability            : 0
Visibility                    : 9.0
AirPressure                   : 1015
LowCloudCover                 : 8
MediumCloudCover              : 0
HighCloudCover                : 2
TotalCloudCover               : 8
PrecipitationCategory         : None
MinimumPrecipitationIntensity : 0.0
MaximumPrecipitationIntensity : 0.0
WindDirection                 : 203
WindGustVelocity              : 6.4
WindVelocity                  : 2.9
WeatherSymbol                 : Overcast
```
## Inspect the object
The WeatherForeCast object has a property called ForeCast which is an array of ForeCast objects.
```
PS C:\> $forecastseries | gm

   TypeName: WeatherForeCast

Name             MemberType Definition                    
----             ---------- ----------                    
AddForeCast      Method     void AddForeCast(ForeCast x)  
DownloadForeCast Method     void DownloadForeCast()          <-- Use to refresh the object with new data
Equals           Method     bool Equals(System.Object obj)
GetHashCode      Method     int GetHashCode()             
GetType          Method     type GetType()                
SetGeoLocation   Method     void SetGeoLocation()            <-- Sets the geo location based on your IP number
ToString         Method     string ToString()             
EndDate          Property   datetime EndDate {get;set;}      <-- End date and time for the forecast
ForeCast         Property   ForeCast[] ForeCast {get;set;}   <-- Array with forecasts
Latitude         Property   decimal Latitude {get;set;}   
Location         Property   string Location {get;set;}    
Longitude        Property   decimal Longitude {get;set;}  
StartDate        Property   datetime StartDate {get;set;}    <-- Start date and time for the forecast
```
And the ForeCast object.
```
PS C:\> $forecastseries.ForeCast | gm

   TypeName: ForeCast

Name                          MemberType Definition                                      
----                          ---------- ----------                                      
Equals                        Method     bool Equals(System.Object obj)                  
GetHashCode                   Method     int GetHashCode()                               
GetType                       Method     type GetType()                                  
SetPrecipitationCategory      Method     void SetPrecipitationCategory(int i)            
SetWeatherSymbol              Method     void SetWeatherSymbol(int i)                    
ToString                      Method     string ToString()                               
AirPressure                   Property   decimal AirPressure {get;set;}                  
HighCloudCover                Property   int HighCloudCover {get;set;}                   
LowCloudCover                 Property   int LowCloudCover {get;set;}                    
MaximumPrecipitationIntensity Property   decimal MaximumPrecipitationIntensity {get;set;}
MediumCloudCover              Property   int MediumCloudCover {get;set;}                 
MinimumPrecipitationIntensity Property   decimal MinimumPrecipitationIntensity {get;set;}
PrecipitationCategory         Property   string PrecipitationCategory {get;set;}         
RelativeHumidity              Property   int RelativeHumidity {get;set;}                 
Temperature                   Property   decimal Temperature {get;set;}                  
ThunderProbability            Property   int ThunderProbability {get;set;}               
TotalCloudCover               Property   int TotalCloudCover {get;set;}                  
ValidTime                     Property   datetime ValidTime {get;set;}                   
Visibility                    Property   decimal Visibility {get;set;}                   
WeatherSymbol                 Property   string WeatherSymbol {get;set;}                 
WindDirection                 Property   int WindDirection {get;set;}                    
WindGustVelocity              Property   decimal WindGustVelocity {get;set;}             
WindVelocity                  Property   decimal WindVelocity {get;set;}
```
