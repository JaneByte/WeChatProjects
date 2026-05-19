$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$envFile = Join-Path $projectRoot 'FreshTime\utils\config\env.js'

if (-not (Test-Path -LiteralPath $envFile)) {
  throw "未找到 env.js: $envFile"
}

$ipConfig = Get-NetIPConfiguration |
  Where-Object {
    $_.IPv4Address -and
    $_.IPv4DefaultGateway -and
    $_.NetAdapter.Status -eq 'Up'
  } |
  Select-Object -First 1

if (-not $ipConfig) {
  throw '未找到可用的局域网 IPv4 地址，请确认当前网络已连接。'
}

$currentIp = $ipConfig.IPv4Address.IPAddress
if (-not $currentIp) {
  throw '获取当前局域网 IP 失败。'
}

$targetUrl = "http://$currentIp`:8080/api"
$content = Get-Content -LiteralPath $envFile -Raw -Encoding UTF8

$updated = $content `
  -replace "(develop:\s*)'http://[^']*(:8080/api')", "`$1'$targetUrl'" `
  -replace "(trial:\s*)'http://[^']*(:8080/api')", "`$1'$targetUrl'"

if ($updated -eq $content) {
  throw '未匹配到 develop/trial 地址，请检查 env.js 格式是否已变更。'
}

Set-Content -LiteralPath $envFile -Value $updated -Encoding UTF8
Write-Output "已更新小程序接口地址为: $targetUrl"
