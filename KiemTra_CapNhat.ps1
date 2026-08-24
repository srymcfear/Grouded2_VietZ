[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$repoUrl = 'https://raw.githubusercontent.com/srymcfear/Grounded2_VietZ/main/version.json'
$localDir = $PSScriptRoot
if ([string]::IsNullOrEmpty($localDir)) {
    $localDir = (Get-Location).Path
}
$localVersionFile = Join-Path $localDir 'version.json'
$zipTemp = Join-Path $localDir '_update_temp.zip'

Write-Host '==================================================' -ForegroundColor Cyan
Write-Host '     KIỂM TRA CẬP NHẬT VIỆT HÓA GROUNDED 2        ' -ForegroundColor White
Write-Host '                  FEΔR TEAM                       ' -ForegroundColor Magenta
Write-Host '==================================================' -ForegroundColor Cyan
Write-Host ''

Write-Host '[*] Đang kết nối máy chủ kiểm tra phiên bản...' -ForegroundColor Yellow

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

try {
    $onlineInfo = Invoke-RestMethod -Uri $repoUrl -UseBasicParsing -Headers @{'Cache-Control'='no-cache'}
} catch {
    Write-Host '[X] Không thể kết nối tới GitHub!' -ForegroundColor Red
    Write-Host "    Chi tiết: $($_.Exception.Message)" -ForegroundColor Gray
    Write-Host ''
    Read-Host 'Nhấn Enter để thoát...'
    exit
}

$localVer = '0.0.0'
if (Test-Path $localVersionFile) {
    try {
        $localInfo = Get-Content -Raw -LiteralPath $localVersionFile -Encoding UTF8 | ConvertFrom-Json
        $localVer = $localInfo.version
    } catch { 
        $localVer = '0.0.0' 
    }
}

$onlineVer = $onlineInfo.version
$buildDate = $onlineInfo.build_date
$author = $onlineInfo.author
$downloadUrl = $onlineInfo.download_url

Write-Host '  - Phiên bản hiện tại : ' -NoNewline; Write-Host $localVer -ForegroundColor Yellow
Write-Host '  - Phiên bản mới nhất : ' -NoNewline; Write-Host $onlineVer -ForegroundColor Green
Write-Host '  - Ngày phát hành     : ' -NoNewline; Write-Host $buildDate -ForegroundColor Cyan
Write-Host '  - Tác giả            : ' -NoNewline; Write-Host $author -ForegroundColor Magenta
Write-Host ''

$needUpdate = ($onlineVer -ne $localVer)

if ($needUpdate) {
    Write-Host '=== ĐÃ CÓ BẢN CẬP NHẬT MỚI! ===' -ForegroundColor Green
    Write-Host 'Nội dung cập nhật (Changelog):' -ForegroundColor White
    foreach ($item in $onlineInfo.changelog) {
        Write-Host "  • $item" -ForegroundColor Gray
    }
    Write-Host ''
    $opt = Read-Host 'Bạn có muốn tải và cài đặt cập nhật ngay? (Y/N)'
    if ($opt -ne 'Y' -and $opt -ne 'y') {
        Write-Host 'Đã hủy cập nhật.' -ForegroundColor Yellow
        Start-Sleep -Seconds 2
        exit
    }
} else {
    Write-Host '[✓] Bạn đang sử dụng phiên bản mới nhất!' -ForegroundColor Green
    Write-Host ''
    $opt = Read-Host 'Bạn có muốn tải và cài đè lại bản Việt Hóa không? (Y/N)'
    if ($opt -ne 'Y' -and $opt -ne 'y') {
        Write-Host 'Tạm biệt! Chúc bạn chơi game vui vẻ.' -ForegroundColor Cyan
        Start-Sleep -Seconds 2
        exit
    }
}

# Kiểm tra nếu game đang chạy
$runningGames = Get-Process | Where-Object { $_.ProcessName -like '*Grounded2*' -or $_.ProcessName -like '*Augusta*' }
if ($runningGames) {
    Write-Host ''
    Write-Host '[!] CẢNH BÁO: Game Grounded 2 đang chạy!' -ForegroundColor Red
    Write-Host '    Vui lòng đóng game trước khi cập nhật để tránh lỗi khóa file.' -ForegroundColor Yellow
    Read-Host 'Nhấn Enter sau khi đã đóng game để tiếp tục...'
}

Write-Host ''
Write-Host '[*] Đang tải bản Việt Hóa mới nhất...' -ForegroundColor Yellow

$downloadOk = $false
try {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipTemp -UseBasicParsing
    Write-Host '[✓] Tải dữ liệu thành công!' -ForegroundColor Green
    $downloadOk = $true
} catch {
    Write-Host '[X] Tải file thất bại! Vui lòng kiểm tra lại kết nối mạng.' -ForegroundColor Red
    Write-Host "    Chi tiết: $($_.Exception.Message)" -ForegroundColor Gray
    if (Test-Path $zipTemp) { Remove-Item -Force $zipTemp -ErrorAction SilentlyContinue }
    Read-Host 'Nhấn Enter để thoát...'
    exit
}

if ($downloadOk) {
    Write-Host '[*] Đang giải nén và cập nhật vào game...' -ForegroundColor Yellow
    try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $zip = [System.IO.Compression.ZipFile]::OpenRead($zipTemp)
        foreach ($entry in $zip.Entries) {
            if ([string]::IsNullOrEmpty($entry.Name)) { continue }
            $destPath = Join-Path $localDir $entry.FullName
            $destParent = [System.IO.Path]::GetDirectoryName($destPath)
            if (-not (Test-Path $destParent)) { 
                [System.IO.Directory]::CreateDirectory($destParent) | Out-Null 
            }
            [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $destPath, $true)
        }
        $zip.Dispose()

        # Lưu version.json local
        $onlineInfo | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $localVersionFile -Encoding UTF8

        Write-Host ''
        Write-Host '==================================================' -ForegroundColor Green
        Write-Host '   [✓] CẬP NHẬT BẢN VIỆT HÓA THÀNH CÔNG!          ' -ForegroundColor White
        Write-Host "   Phiên bản: v$onlineVer                         " -ForegroundColor Cyan
        Write-Host '   Chúc bạn có những giờ phút chơi game vui vẻ!   ' -ForegroundColor Yellow
        Write-Host '==================================================' -ForegroundColor Green
    } catch {
        Write-Host '[X] Lỗi trong quá trình giải nén / ghi đè file!' -ForegroundColor Red
        Write-Host "    Chi tiết: $($_.Exception.Message)" -ForegroundColor Gray
    }
    if (Test-Path $zipTemp) { 
        Remove-Item -Force $zipTemp -ErrorAction SilentlyContinue 
    }
}

Write-Host ''
Read-Host 'Nhấn Enter để kết thúc...'
