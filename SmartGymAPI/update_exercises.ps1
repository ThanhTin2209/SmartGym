# Script update 150 bai tap tieng Viet qua HTTP API
$baseUrl = "http://localhost:5200/api"

Write-Host "=== SMART GYM - UPDATE 150 BAI TAP ===" -ForegroundColor Cyan

# Buoc 1: Login
Write-Host "[1/3] Dang login..." -ForegroundColor Yellow
$loginBody = '{"email":"admin@smartgym.com","password":"Admin@123"}'

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $loginBody -ContentType "application/json; charset=utf-8"
    $token = $loginResponse.token
    Write-Host "[OK] Login thanh cong!" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Loi login: $_" -ForegroundColor Red
    exit
}

# Buoc 2: Doc file JSON
Write-Host "[2/3] Dang doc file JSON..." -ForegroundColor Yellow
$jsonContent = Get-Content -Path "exercises_vietnamese.json" -Raw -Encoding UTF8
Write-Host "[OK] Da doc 150 bai tap!" -ForegroundColor Green

# Buoc 3: Goi API bulk-update
Write-Host "[3/3] Dang update vao database..." -ForegroundColor Yellow
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json; charset=utf-8"
}

try {
    $utf8Bytes = [System.Text.Encoding]::UTF8.GetBytes($jsonContent)
    $response = Invoke-RestMethod -Uri "$baseUrl/ExerciseTemplate/bulk-update" -Method Post -Headers $headers -Body $utf8Bytes
    Write-Host "[OK] Da update thanh cong $($response.updated) bai tap!" -ForegroundColor Green
    Write-Host "`nHOAN THANH! Bay gio Hot Restart Flutter App!" -ForegroundColor Cyan
} catch {
    Write-Host "[ERROR] Loi update: $_" -ForegroundColor Red
}
