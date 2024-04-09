# set the seed
$message = Get-Content -Path "./secret.json" | ConvertFrom-Json | Select-Object -ExpandProperty message

$secret = Get-Content -Path "./secret.json" | ConvertFrom-Json

$splatting = @{
    Method = 'Get'
    Uri    = "https://geocode.maps.co/search?q=$($secret.city), $($secret.state)&api_key=6614b4a39e8a7130440609sfb3174ff"
}

$location = Invoke-RestMethod @splatting

$splatting = @{
    Uri    = "https://api.weather.gov/points/$($location.lat),$($location.lon)"
    Method = 'Get'
}

$weather = Invoke-RestMethod @splatting 

$splatting = @{
    Uri    = $weather.properties.forecast
    Method = 'Get'
}

Invoke-RestMethod @splatting | Foreach-Object {
    $PSItem.properties.periods | Select-Object -First 1 | ForEach-Object {
        
        # Weather seed
        $seed = ($PSItem.temperature) + ($PSItem.windSpeed | ForEach-Object { $PSItem.split(' ')[0] }) + ($PSItem.probabilityOfPrecipitation.value)
    
        # Get a seed based on weather
        $1 = Get-Random -Minimum 1000000000 -Maximum 9999999999 -SetSeed $seed
        $2 = Get-Random -Minimum 1000000000 -Maximum 9999999999 -SetSeed ([datetime]::Now.TimeOfDay.TotalSeconds + 5)
    }
}
$message
$1 + $2


