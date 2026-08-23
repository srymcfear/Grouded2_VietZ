@echo off
chcp 65001 >nul
echo ==================================================
echo       GỠ CÀI ĐẶT BẢN VIỆT HÓA GROUNDED 2
echo                  FEΔR TEAM
echo ==================================================
echo.
echo Đang xóa các file Việt Hóa...
echo.

if exist "Augusta\Content\Paks\FEΔRVietHoa_P.pak" (
    del /f /q "Augusta\Content\Paks\FEΔRVietHoa_P.pak"
    echo  - Da xoa: FEΔRVietHoa_P.pak
) else (
    echo  - Khong tim thay: FEΔRVietHoa_P.pak
)

if exist "Augusta\Content\Paks\FEΔRVietHoa_P.ucas" (
    del /f /q "Augusta\Content\Paks\FEΔRVietHoa_P.ucas"
    echo  - Da xoa: FEΔRVietHoa_P.ucas
) else (
    echo  - Khong tim thay: FEΔRVietHoa_P.ucas
)

if exist "Augusta\Content\Paks\FEΔRVietHoa_P.utoc" (
    del /f /q "Augusta\Content\Paks\FEΔRVietHoa_P.utoc"
    echo  - Da xoa: FEΔRVietHoa_P.utoc
) else (
    echo  - Khong tim thay: FEΔRVietHoa_P.utoc
)

echo.
echo ==================================================
echo Đã gỡ cài đặt bản Việt Hóa thành công!
echo Chúc bạn chơi game vui vẻ!
echo ==================================================
pause
