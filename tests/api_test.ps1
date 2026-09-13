# 1. Check computer in DB from previous registration
$pc = & mysql -u root -N -e "SELECT id, device_token, nama_pc, status FROM labcontrol_unimal.computers ORDER BY id DESC LIMIT 1;"
Write-Host "Latest Computer in DB: $pc"

$parts = $pc.Split("`t")
$computerId = $parts[0].Trim()
$token = $parts[1].Trim()

# 2. Test Heartbeat with token
$headers = @{ 
    "Authorization" = "Bearer $token"
    "Accept" = "application/json" 
}
$hbBody = @{
    status = "online"
    ip = "192.168.1.50"
    active_user = "lab_user"
    uptime_seconds = 7200
    agent_version = "1.0.0"
} | ConvertTo-Json

$hbRes = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/v1/agent/heartbeat" -Method Post -Headers $headers -Body $hbBody -ContentType "application/json"
Write-Host "Heartbeat Success: $($hbRes.success), Nama: $($hbRes.data.nama_pc)"

# 3. Create a test command
$sql = "INSERT INTO commands (computer_id, tipe, payload, status, created_at, updated_at) VALUES ($computerId, 'shutdown', '{\`"grace_seconds\`": 60, \`"message\`": \`"Uji coba shutdown dari ASLAB\`"}', 'pending', NOW(), NOW());"
& mysql -u root -D labcontrol_unimal -e "$sql"

# 4. Check that heartbeat returns pending command
$hbRes2 = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/v1/agent/heartbeat" -Method Post -Headers $headers -Body $hbBody -ContentType "application/json"
$pendingCmd = $hbRes2.data.pending_commands[0]
Write-Host "Received pending command: ID=$($pendingCmd.id), Type=$($pendingCmd.type), Grace=$($pendingCmd.payload.grace_seconds)"

# 5. Acknowledge command execution
$ackBody = @{
    status = "executed"
    result_message = "Shutdown dimulai dalam 60 detik"
} | ConvertTo-Json

$ackRes = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/v1/agent/commands/$($pendingCmd.id)/ack" -Method Post -Headers $headers -Body $ackBody -ContentType "application/json"
Write-Host "ACK Response: Success=$($ackRes.success), Status=$($ackRes.data.status)"

# 6. Verify in DB
$cmdDb = & mysql -u root -N -e "SELECT id, tipe, status, result_message FROM labcontrol_unimal.commands WHERE id = $($pendingCmd.id);"
Write-Host "DB Command Status: $cmdDb"
