# Script để update 150 bài tập tiếng Việt qua HTTP API
# Chạy script này sau khi backend đã start

$baseUrl = "https://smallbrushedsled50.conveyor.cloud/api"

# Login as admin để lấy token
$loginBody = @{
    email = "admin@smartgym.com"
    password = "Admin@123"
} | ConvertTo-Json -Depth 10

$loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $loginBody -ContentType "application/json; charset=utf-8"
$token = $loginResponse.token

Write-Host "Logged in successfully. Token: $($token.Substring(0,20))..."

# Tạo danh sách 150 bài tập tiếng Việt
$exercises = @(
    @{ Id=1; Name="Đi bộ nhẹ nhàng 15 phút"; Category="Cardio"; DurationSeconds=900; BaseMet=3.5; Intensity="Low"; Level="Beginner" },
    @{ Id=2; Name="Đi bộ nhanh 20 phút"; Category="Cardio"; DurationSeconds=1200; BaseMet=4.5; Intensity="Moderate"; Level="Beginner" },
    @{ Id=3; Name="Đi bộ leo dốc 25 phút"; Category="Cardio"; DurationSeconds=1500; BaseMet=5.5; Intensity="Moderate"; Level="Intermediate" },
    @{ Id=4; Name="Chạy bộ nhẹ 15 phút"; Category="Cardio"; DurationSeconds=900; BaseMet=6.0; Intensity="Moderate"; Level="Beginner" },
    @{ Id=5; Name="Chạy bộ 20 phút"; Category="Cardio"; DurationSeconds=1200; BaseMet=7.5; Intensity="Moderate"; Level="Intermediate" }
    # ... Add all 150 exercises here
)

# Convert to JSON with UTF-8
$jsonBody = $exercises | ConvertTo-Json -Depth 10
$utf8Bytes = [System.Text.Encoding]::UTF8.GetBytes($jsonBody)

# Call bulk-update API
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json; charset=utf-8"
}

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/ExerciseTemplate/bulk-update" -Method Post -Headers $headers -Body $utf8Bytes
    Write-Host "Successfully updated $($response.updated) exercises!" -ForegroundColor Green
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}
