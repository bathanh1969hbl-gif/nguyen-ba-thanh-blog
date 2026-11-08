$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$srcDir = "D:\Website"
$galleryDir = "C:\Users\Dell\.gemini\antigravity\scratch\nguyen-ba-thanh-blog\images\gallery"
if (-not (Test-Path $galleryDir)) {
    New-Item -ItemType Directory -Path $galleryDir -Force | Out-Null
}

$jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
$encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
$encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, 78L)

$files = Get-ChildItem -Path $srcDir -Filter "*.jpg" | Where-Object { $_.Name -ne "Screenshot_20260426_153131_Gallery.jpg" } | Sort-Object Name

$galleryItems = @()
$idx = 1

foreach ($file in $files) {
    $outName = "photo-{0:D3}.jpg" -f $idx
    $outPath = Join-Path $galleryDir $outName

    $dateStr = "2026"
    $catKey = "journey"

    if ($file.Name -match "(\d{4})(\d{2})(\d{2})") {
        $y = $matches[1]
        $m = $matches[2]
        $d = $matches[3]
        $dateStr = "$d/$m/$y"
        switch ($m) {
            "03" { $catKey = "training" }
            "04" { $catKey = "training" }
            "05" { $catKey = "cangio" }
            "06" { $catKey = "daily" }
            "07" { $catKey = "camranh" }
            "08" { $catKey = "lifestyle" }
            "09" { $catKey = "lifestyle" }
        }
    } elseif ($file.Name -like "FB_IMG*") {
        $catKey = "cangio"
    }

    try {
        if (-not (Test-Path $outPath)) {
            $img = [System.Drawing.Image]::FromFile($file.FullName)
            try {
                if ($img.PropertyIdList -contains 274) {
                    $prop = $img.GetPropertyItem(274)
                    $orient = [BitConverter]::ToUInt16($prop.Value, 0)
                    switch ($orient) {
                        3 { $img.RotateFlip([System.Drawing.RotateFlipType]::Rotate180FlipNone) }
                        6 { $img.RotateFlip([System.Drawing.RotateFlipType]::Rotate90FlipNone) }
                        8 { $img.RotateFlip([System.Drawing.RotateFlipType]::Rotate270FlipNone) }
                    }
                    $img.RemovePropertyItem(274)
                }

                $maxDim = 1000
                $w = $img.Width
                $h = $img.Height
                if ($w -gt $maxDim -or $h -gt $maxDim) {
                    if ($w -gt $h) {
                        $newW = $maxDim
                        $newH = [int]($h * ($maxDim / $w))
                    } else {
                        $newH = $maxDim
                        $newW = [int]($w * ($maxDim / $h))
                    }
                } else {
                    $newW = $w
                    $newH = $h
                }

                $bmp = New-Object System.Drawing.Bitmap($newW, $newH)
                $g = [System.Drawing.Graphics]::FromImage($bmp)
                $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                $g.DrawImage($img, 0, 0, $newW, $newH)
                $g.Dispose()

                $bmp.Save($outPath, $jpegCodec, $encoderParams)
                $bmp.Dispose()
            } finally {
                $img.Dispose()
            }
        }

        $galleryItems += [PSCustomObject]@{
            id = $idx
            src = "images/gallery/$outName"
            original = $file.Name
            date = $dateStr
            catKey = $catKey
        }
        $idx++
    } catch {
        Write-Warning "Skipped $($file.Name): $_"
    }
}

$json = $galleryItems | ConvertTo-Json -Depth 3
"window.GALLERY_DATA = $json;" | Set-Content -Path "C:\Users\Dell\.gemini\antigravity\scratch\nguyen-ba-thanh-blog\gallery-data.js" -Encoding UTF8
Write-Output "Total processed gallery photos: $($galleryItems.Count)"
