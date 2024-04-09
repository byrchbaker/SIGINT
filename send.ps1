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
    
        $splatting = @{
            Minimum = 1000000000000000
            Maximum = 9999999999999999
            SetSeed = $seed
        }

        # Get a seed based on weather
        $weatherKey = Get-Random @splatting
        $weatherKeyBytes = [System.Text.Encoding]::UTF8.GetBytes($weatherKey.ToString())

        $splatting = @{
            Minimum = 1000000000000000
            Maximum = 9999999999999999
            SetSeed = ([datetime]::Now.TimeOfDay.TotalMinutes)
        }

        $timeKey = Get-Random @splatting 
        $timeKeyBytes = [System.Text.Encoding]::UTF8.GetBytes($timeKey.ToString())
        
        $splatting = @{
            SecureString = (ConvertTo-SecureString -String $message -AsPlainText -Force)
            Key = ($timeKeyBytes + $weatherKeyBytes)
        }

        # AES-256
        $encrypted = ConvertFrom-SecureString @splatting


        $binary = [System.Text.Encoding]::Default.GetBytes($encrypted) | ForEach-Object {[System.Convert]::ToString($_,2).PadLeft(8,'0') }

        $freqOne = 1000  
        $freqZero = 500  
        $duration = 50  

        foreach ($bit in $binary) {
            foreach ($char in $bit.ToCharArray()) {
                if ($char -eq '1') {
                    [Console]::Beep($freqOne, $duration)
                } elseif ($char -eq '0') {
                    [Console]::Beep($freqZero, $duration)
                } else {
                    # Handle invalid characters if any
                }
            }
        }
    }
}





