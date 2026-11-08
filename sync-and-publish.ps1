$ErrorActionPreference = "Continue"
$env:Path = "C:\Users\Dell\.gemini\antigravity\scratch\tools\git\cmd;C:\Users\Dell\.gemini\antigravity\scratch\tools\gh\bin;" + $env:Path

$blogDir = "C:\Users\Dell\.gemini\antigravity\scratch\nguyen-ba-thanh-blog"
$portalDir = "C:\Users\Dell\.gemini\antigravity\scratch\github-web-portal"

# 1. Sync built website into D:\Website
Copy-Item -Path "$blogDir\index.html", "$blogDir\gallery-data.js", "$blogDir\images" -Destination "D:\Website\" -Recurse -Force

# 2. Open the newly created personal blog in default browser immediately
Start-Process "$blogDir\index.html"

# 3. Check GitHub CLI login, or start browser login and auto-publish upon completion
$gh = "C:\Users\Dell\.gemini\antigravity\scratch\tools\gh\bin\gh.exe"
& $gh auth status 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Output "Starting GitHub web login..."
    "`n" | & $gh auth login --hostname github.com --git-protocol https --web -s repo,workflow,user
}

# 4. Once authenticated, automatically publish both repositories to GitHub Pages
$ghUser = (& $gh api user --jq .login 2>$null)
if ($ghUser) {
    $ghUser = $ghUser.Trim()
    Write-Output "Authenticated as GitHub user: $ghUser"
    & "$portalDir\publish-site.ps1" -SiteName "nguyen-ba-thanh-blog" -Description "Website va Blog Ca Nhan Nguyen Ba Thanh - Song Khoe Song Hanh Phuc Tuoi 58" -SourceDir $blogDir
    & "$portalDir\publish-site.ps1" -SiteName "github-web-portal" -Description "Trung Tam Quan Tri Website Nguyen Ba Thanh" -SourceDir $portalDir
}
