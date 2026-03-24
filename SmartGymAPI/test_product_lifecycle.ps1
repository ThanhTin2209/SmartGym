# 1. Login
$loginUrl = "https://foundyellowboard88.conveyor.cloud/api/Auth/login"
$body = @{
    email = "admin@smartgym.com"
    password = "Admin@123"
} | ConvertTo-Json

try {
    $loginRes = Invoke-RestMethod -Uri $loginUrl -Method Post -Body $body -ContentType "application/json"
    $token = $loginRes.token
    Write-Host "Login Success. Token length: $($token.Length)"
} catch {
    Write-Error "Login Failed: $_"
    exit
}

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

# 2. Create Product
$createUrl = "https://foundyellowboard88.conveyor.cloud/api/Product"
$newProduct = @{
    categoryId = 1
    name = "Test Product PowerShell"
    description = "Created via CLI"
    price = 100000
    stock = 10
    imageUrl = "http://example.com/img.png"
    isActive = $true
} | ConvertTo-Json

try {
    $createRes = Invoke-RestMethod -Uri $createUrl -Method Post -Headers $headers -Body $newProduct
    $productId = $createRes.id
    Write-Host "Created Product ID: $productId"
} catch {
    Write-Error "Create Failed: $_"
    exit
}

# 3. Update Product
$updateUrl = "https://foundyellowboard88.conveyor.cloud/api/Product/$productId"
$updatedProduct = @{
    id = $productId
    categoryId = 1
    name = "Test Product PowerShell Updated"
    description = "Updated via CLI"
    price = 200000
    stock = 20
    imageUrl = "http://example.com/img-updated.png"
    isActive = $true
} | ConvertTo-Json

try {
    $updateRes = Invoke-RestMethod -Uri $updateUrl -Method Put -Headers $headers -Body $updatedProduct
    Write-Host "Update Success: $($updateRes.name)"
} catch {
    Write-Error "Update Failed: $_"
}

# 4. Delete Product
$deleteUrl = "https://foundyellowboard88.conveyor.cloud/api/Product/$productId"

try {
    Invoke-RestMethod -Uri $deleteUrl -Method Delete -Headers $headers
    Write-Host "Delete Success"
} catch {
    Write-Error "Delete Failed: $_"
}
