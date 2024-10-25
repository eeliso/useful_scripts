# Define the path to the .fsk file
$filePath = "C:\Users\Example\Desktop\file.fsk"

# Read JSON data from the .fsk file
$jsonContent = Get-Content $filePath -Raw

# Convert the JSON string into a PowerShell object
$jsonData = $jsonContent | ConvertFrom-Json

# Array to hold extracted data
$extractedData = @()

# Iterate through each item in the 'data' object
foreach ($key in $jsonData.data.PSObject.Properties.Name) {
    $entry = $jsonData.data.$key

    # Extract the URL and check if it starts with "http://" or "https://"
    $url = $entry.url

    if (-not ($url -match '^https?://')) {
        # If it doesn't start with "http://" or "https://", prepend "https://"
        $url = "https://$url"
    }

    # Extract the required fields (username, URL, and password)
    $extractedData += [PSCustomObject]@{
        Username = $entry.username
        URL      = $url
        Password = $entry.password
    }
}

# Path to the output CSV file
$outputCsv = "C:\Users\Example\Desktop\output.csv"

# Export the extracted data to CSV
$extractedData | Export-Csv -Path $outputCsv -NoTypeInformation

# Provide feedback
Write-Host "Extraction complete. Data saved to $outputCsv"