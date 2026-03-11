# === CONFIGURAZIONE ===
$inputFolder  = "C:\"
$outputFolder = "C:\"
$maxWidth     = 1200
$maxSizeKB    = 200       # peso massimo in KB
$quality      = 82        # qualità iniziale (1-100)

# ======================

# Crea cartella output se non esiste
New-Item -ItemType Directory -Force -Path $outputFolder | Out-Null

$extensions = @("*.jpg", "*.jpeg", "*.png", "*.gif", "*.bmp", "*.tiff")
$files = $extensions | ForEach-Object { Get-ChildItem -Path $inputFolder -Filter $_ }

foreach ($file in $files) {
    $outputFile = Join-Path $outputFolder "$($file.BaseName).webp"

    Write-Host "Converto: $($file.Name)" -ForegroundColor Cyan

    # Converti con ridimensionamento e qualità
    magick $file.FullName `
        -resize "$($maxWidth)x>" `
        -quality $quality `
        $outputFile

    # Controlla il peso e abbassa la qualità finché non rientra
    $currentQuality = $quality
    while ((Get-Item $outputFile).Length / 1KB -gt $maxSizeKB -and $currentQuality -gt 10) {
        $currentQuality -= 5
        Write-Host "  -> Troppo grande, riprovo con qualità $currentQuality..." -ForegroundColor Yellow
        magick $file.FullName `
            -resize "$($maxWidth)x>" `
            -quality $currentQuality `
            $outputFile
    }

    $finalSize = [math]::Round((Get-Item $outputFile).Length / 1KB, 1)
    Write-Host "  -> OK: $finalSize KB (qualità finale: $currentQuality)" -ForegroundColor Green
}

Write-Host "`nConversione completata!" -ForegroundColor Green