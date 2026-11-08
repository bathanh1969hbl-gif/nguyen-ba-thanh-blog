$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$destDir = "C:\Users\Dell\.gemini\antigravity\scratch\nguyen-ba-thanh-blog\images"
if (-not (Test-Path $destDir)) {
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
}

# Curated list of photos from D:\Website (excluding any denied file)
$photos = @(
    @{ Src = "D:\Website\20260501_083009.jpg"; Out = "hero-finish.jpg" },
    @{ Src = "D:\Website\FB_IMG_1780023394093.jpg"; Out = "marathon-team.jpg" },
    @{ Src = "D:\Website\IMG_UPLOAD_20260501_034426.jpg"; Out = "early-morning-start.jpg" },
    @{ Src = "D:\Website\Screenshot_20260711_151957_Facebook.jpg"; Out = "morning-run-friends.jpg" },
    @{ Src = "D:\Website\20260719_051954.jpg"; Out = "cam-ranh-sunrise.jpg" },
    @{ Src = "D:\Website\IMG_UPLOAD_20260713_102930.jpg"; Out = "coastal-journey.jpg" },
    @{ Src = "D:\Website\20260713_100932.jpg"; Out = "sea-horizon.jpg" },
    @{ Src = "D:\Website\20260709_085748.jpg"; Out = "rocky-coast.jpg" },
    @{ Src = "D:\Website\20260501_115608.jpg"; Out = "family-gathering.jpg" },
    @{ Src = "D:\Website\Screenshot_20260808_112211_Gallery.jpg"; Out = "active-lifestyle.jpg" },
    @{ Src = "D:\Website\20260330_162215.jpg"; Out = "nature-stream.jpg" },
    @{ Src = "D:\Website\Screenshot_20260710_165258_Maps.jpg"; Out = "landscape-trang-an.jpg" },
    @{ Src = "D:\Website\20260712_084219.jpg"; Out = "hai-van-quan.jpg" },
    @{ Src = "D:\Website\IMG_UPLOAD_20260627_153902.jpg"; Out = "community-friends.jpg" }
)

foreach ($item in $photos) {
    if (Test-Path $item.Src) {
        $img = [System.Drawing.Image]::FromFile($item.Src)
        try {
            # Check EXIF orientation (0x0112 = 274)
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

            $maxDim = 1400
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

            $outPath = Join-Path $destDir $item.Out
            $bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Jpeg)
            $bmp.Dispose()
            Write-Output "Processed: $($item.Out) ($newW x $newH)"
        } finally {
            $img.Dispose()
        }
    }
}
