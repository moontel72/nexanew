# NexaTrace Database Backup Script
# PowerShell script for automated database backups

param(
    [string]$DatabaseName = "nexasystem_db",
    [string]$HostName = "localhost",
    [int]$Port = 5444,
    [string]$Username = "postgres",
    [string]$Password = "awan1972",
    [string]$BackupDir = "C:\nexatrace_backups",
    [int]$RetentionDays = 7,
    [switch]$Compress = $true,
    [switch]$Verify = $true,
    [switch]$Silent = $false
)

# Error handling
$ErrorActionPreference = "Stop"

# Colors for output
$Green = "Green"
$Yellow = "Yellow"
$Red = "Red"
$Cyan = "Cyan"

# Function to write colored output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    if (-not $Silent) {
        Write-Host $Message -ForegroundColor $Color
    }
}

# Function to create timestamp
function Get-Timestamp {
    return Get-Date -Format "yyyyMMdd_HHmmss"
}

# Function to get backup file path
function Get-BackupFilePath {
    param([string]$Extension = "sql")

    $timestamp = Get-Timestamp
    $fileName = "${DatabaseName}_${timestamp}.${Extension}"
    return Join-Path $BackupDir $fileName
}

# Function to create backup directory
function Initialize-BackupDirectory {
    if (-not (Test-Path $BackupDir)) {
        Write-ColorOutput "📁 Creating backup directory: $BackupDir" -Color $Cyan
        New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
    }

    # Ensure directory is writable
    $testFile = Join-Path $BackupDir "test_write.tmp"
    try {
        "test" | Out-File -FilePath $testFile -Force
        Remove-Item $testFile -Force
    } catch {
        throw "Backup directory is not writable: $BackupDir"
    }
}

# Function to check PostgreSQL connection
function Test-PostgreSQLConnection {
    Write-ColorOutput "🔗 Testing PostgreSQL connection..." -Color $Cyan

    $env:PGPASSWORD = $Password
    try {
        $result = & "pg_isready" "-h" $HostName "-p" $Port "-U" $Username 2>&1
        $env:PGPASSWORD = $null

        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "  ✅ PostgreSQL is ready" -Color $Green
            return $true
        } else {
            Write-ColorOutput "  ❌ PostgreSQL is not ready: $result" -Color $Red
            return $false
        }
    } catch {
        $env:PGPASSWORD = $null
        Write-ColorOutput "  ❌ PostgreSQL check failed: $_" -Color $Red
        return $false
    }
}

# Function to create database backup
function Backup-Database {
    Write-ColorOutput "💾 Creating database backup..." -Color $Cyan

    $backupFile = Get-BackupFilePath "sql"

    # Set password for pg_dump
    $env:PGPASSWORD = $Password

    Write-ColorOutput "  📄 Backup file: $backupFile" -Color $Yellow

    try {
        # Create backup using pg_dump
        & "pg_dump" "-h" $HostName "-p" $Port "-U" $Username "-d" $DatabaseName "-F" "p" "-v" "-f" $backupFile 2>&1 | Out-Null

        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "  ✅ Backup created successfully" -Color $Green

            # Get backup size
            $backupSize = (Get-Item $backupFile).Length
            $sizeMB = [math]::Round($backupSize / 1MB, 2)
            Write-ColorOutput "  📊 Backup size: ${sizeMB} MB" -Color $Yellow

            return $backupFile
        } else {
            throw "pg_dump failed with exit code: $LASTEXITCODE"
        }
    } catch {
        throw "Backup failed: $_"
    } finally {
        $env:PGPASSWORD = $null
    }
}

# Function to compress backup
function Compress-Backup {
    param([string]$BackupFile)

    if (-not $Compress) {
        return $BackupFile
    }

    Write-ColorOutput "🗜️  Compressing backup..." -Color $Cyan

    $compressedFile = "$BackupFile.gz"

    try {
        # Use .NET GZipStream for compression
        $inputStream = New-Object System.IO.FileStream $BackupFile, ([IO.FileMode]::Open), ([IO.FileAccess]::Read), ([IO.FileShare]::Read)
        $outputStream = New-Object System.IO.FileStream $compressedFile, ([IO.FileMode]::Create), ([IO.FileAccess]::Write), ([IO.FileShare]::None)
        $gzipStream = New-Object System.IO.Compression.GZipStream $outputStream, ([IO.Compression.CompressionMode]::Compress)

        $buffer = New-Object byte[](4096)
        $bytesRead = 0

        do {
            $bytesRead = $inputStream.Read($buffer, 0, 4096)
            if ($bytesRead -gt 0) {
                $gzipStream.Write($buffer, 0, $bytesRead)
            }
        } while ($bytesRead -gt 0)

        $gzipStream.Close()
        $outputStream.Close()
        $inputStream.Close()

        # Remove original backup file
        Remove-Item $BackupFile -Force

        # Get compressed size
        $compressedSize = (Get-Item $compressedFile).Length
        $sizeMB = [math]::Round($compressedSize / 1MB, 2)

        Write-ColorOutput "  ✅ Backup compressed: ${sizeMB} MB" -Color $Green

        return $compressedFile
    } catch {
        Write-ColorOutput "  ⚠️  Compression failed: $_" -Color $Yellow
        return $BackupFile
    }
}

# Function to verify backup
function Verify-Backup {
    param([string]$BackupFile)

    if (-not $Verify) {
        return $true
    }

    Write-ColorOutput "🔍 Verifying backup integrity..." -Color $Cyan

    # Check if file exists and has content
    if (-not (Test-Path $BackupFile)) {
        Write-ColorOutput "  ❌ Backup file not found" -Color $Red
        return $false
    }

    $fileSize = (Get-Item $BackupFile).Length
    if ($fileSize -eq 0) {
        Write-ColorOutput "  ❌ Backup file is empty" -Color $Red
        return $false
    }

    # For SQL files, check if it contains valid SQL
    if ($BackupFile -match '\.sql$') {
        $content = Get-Content $BackupFile -First 10 -Raw
        if ($content -notmatch '^--.*PostgreSQL database dump') {
            Write-ColorOutput "  ⚠️  Backup file may not be valid SQL" -Color $Yellow
        }
    }

    # For compressed files, test decompression
    if ($BackupFile -match '\.gz$') {
        try {
            $inputStream = New-Object System.IO.FileStream $BackupFile, ([IO.FileMode]::Open), ([IO.FileAccess]::Read), ([IO.FileShare]::Read)
            $gzipStream = New-Object System.IO.Compression.GZipStream $inputStream, ([IO.Compression.CompressionMode]::Decompress)
            $buffer = New-Object byte[](1024)
            $bytesRead = $gzipStream.Read($buffer, 0, 1024)
            $gzipStream.Close()
            $inputStream.Close()

            if ($bytesRead -eq 0) {
                Write-ColorOutput "  ❌ Compressed file appears corrupt" -Color $Red
                return $false
            }
        } catch {
            Write-ColorOutput "  ❌ Compression verification failed: $_" -Color $Red
            return $false
        }
    }

    Write-ColorOutput "  ✅ Backup verification passed" -Color $Green
    return $true
}

# Function to clean up old backups
function Cleanup-OldBackups {
    Write-ColorOutput "🧹 Cleaning up old backups..." -Color $Cyan

    $cutoffDate = (Get-Date).AddDays(-$RetentionDays)
    $backupFiles = Get-ChildItem -Path $BackupDir -Filter "*${DatabaseName}_*" -File

    $deletedCount = 0
    $totalSizeFreed = 0

    foreach ($file in $backupFiles) {
        if ($file.LastWriteTime -lt $cutoffDate) {
            $fileSize = $file.Length
            try {
                Remove-Item $file.FullName -Force
                $deletedCount++
                $totalSizeFreed += $fileSize
                Write-ColorOutput "  🗑️  Deleted: $($file.Name)" -Color $Yellow
            } catch {
                Write-ColorOutput "  ⚠️  Failed to delete: $($file.Name)" -Color $Yellow
            }
        }
    }

    if ($deletedCount -gt 0) {
        $sizeMB = [math]::Round($totalSizeFreed / 1MB, 2)
        Write-ColorOutput "  ✅ Cleanup complete: ${deletedCount} files (${sizeMB} MB)" -Color $Green
    } else {
        Write-ColorOutput "  ℹ️  No old backups to clean up" -Color $Yellow
    }
}

# Function to generate backup report
function Generate-BackupReport {
    param([string]$BackupFile)

    $reportFile = Join-Path $BackupDir "backup_report_$(Get-Timestamp).txt"

    $report = @"
============================================
NEXATRACE DATABASE BACKUP REPORT
============================================
Backup Time: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Database: $DatabaseName
Host: $HostName:$Port
Backup File: $(Split-Path $BackupFile -Leaf)
Backup Size: $([math]::Round((Get-Item $BackupFile).Length / 1MB, 2)) MB
Compressed: $Compress
Verified: $Verify
Status: SUCCESS
============================================
BACKUP STATISTICS
============================================
Total Backups in Directory: $(@(Get-ChildItem -Path $BackupDir -Filter "*${DatabaseName}_*" -File).Count)
Oldest Backup: $(if ((Get-ChildItem -Path $BackupDir -Filter "*${DatabaseName}_*" -File).Count -gt 0) { (Get-ChildItem -Path $BackupDir -Filter "*${DatabaseName}_*" -File | Sort-Object LastWriteTime | Select-Object -First 1).LastWriteTime } else { "None" })
Newest Backup: $(if ((Get-ChildItem -Path $BackupDir -Filter "*${DatabaseName}_*" -File).Count -gt 0) { (Get-ChildItem -Path $BackupDir -Filter "*${DatabaseName}_*" -File | Sort-Object LastWriteTime | Select-Object -Last 1).LastWriteTime } else { "None" })
Total Backup Size: $([math]::Round((@(Get-ChildItem -Path $BackupDir -Filter "*${DatabaseName}_*" -File | Measure-Object Length -Sum).Sum / 1MB, 2)) MB
============================================
SYSTEM INFORMATION
============================================
Hostname: $env:COMPUTERNAME
Username: $env:USERNAME
OS: $([System.Environment]::OSVersion.VersionString)
Free Disk Space: $([math]::Round((Get-PSDrive -Name (Split-Path $BackupDir -Qualifier).TrimEnd(':')).Free / 1GB, 2)) GB
============================================
"@

    $report | Out-File -FilePath $reportFile -Encoding UTF8
    Write-ColorOutput "📋 Backup report generated: $(Split-Path $reportFile -Leaf)" -Color $Cyan

    return $reportFile
}

# Function to send notification (placeholder for email/SMS integration)
function Send-Notification {
    param(
        [string]$BackupFile,
        [bool]$Success
    )

    $status = if ($Success) { "SUCCESS" } else { "FAILED" }
    $message = "Database backup $status: $DatabaseName at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

    # Placeholder for notification integration
    # In production, integrate with email (Send-MailMessage), SMS (Twilio), or monitoring systems

    Write-ColorOutput "📧 Notification: $message" -Color $Cyan
}

# Main backup function
function Start-Backup {
    Write-ColorOutput "`n" -Color White
    Write-ColorOutput "╔══════════════════════════════════════════════════════════╗" -Color $Cyan
    Write-ColorOutput "║                 NEXATRACE DATABASE BACKUP                 ║" -Color $Cyan
    Write-ColorOutput "╚══════════════════════════════════════════════════════════╝" -Color $Cyan
    Write-ColorOutput "`n" -Color White

    $startTime = Get-Date
    $backupFile = $null
    $success = $false

    try {
        # Step 1: Initialize
        Initialize-BackupDirectory

        # Step 2: Test connection
        if (-not (Test-PostgreSQLConnection)) {
            throw "Cannot connect to PostgreSQL database"
        }

        # Step 3: Create backup
        $backupFile = Backup-Database

        # Step 4: Compress backup
        $backupFile = Compress-Backup -BackupFile $backupFile

        # Step 5: Verify backup
        if (-not (Verify-Backup -BackupFile $backupFile)) {
            throw "Backup verification failed"
        }

        # Step 6: Cleanup old backups
        Cleanup-OldBackups

        # Step 7: Generate report
        $reportFile = Generate-BackupReport -BackupFile $backupFile

        $success = $true

        # Calculate duration
        $duration = (Get-Date) - $startTime
        $durationStr = "{0:hh\:mm\:ss}" -f $duration

        Write-ColorOutput "`n" -Color White
        Write-ColorOutput "╔══════════════════════════════════════════════════════════╗" -Color $Green
        Write-ColorOutput "║                    BACKUP COMPLETE!                       ║" -Color $Green
        Write-ColorOutput "╚══════════════════════════════════════════════════════════╝" -Color $Green
        Write-ColorOutput "`n" -Color White

        Write-ColorOutput "📊 Summary:" -Color $Cyan
        Write-ColorOutput "  • Database: $DatabaseName" -Color White
        Write-ColorOutput "  • Backup File: $(Split-Path $backupFile -Leaf)" -Color White
        Write-ColorOutput "  • File Size: $([math]::Round((Get-Item $backupFile).Length / 1MB, 2)) MB" -Color White
        Write-ColorOutput "  • Duration: $durationStr" -Color White
        Write-ColorOutput "  • Status: ✅ SUCCESS" -Color $Green

    } catch {
        Write-ColorOutput "`n" -Color White
        Write-ColorOutput "╔══════════════════════════════════════════════════════════╗" -Color $Red
        Write-ColorOutput "║                    BACKUP FAILED!                        ║" -Color $Red
        Write-ColorOutput "╚══════════════════════════════════════════════════════════╝" -Color $Red
        Write-ColorOutput "`n" -Color White

        Write-ColorOutput "❌ Error: $_" -Color $Red
        Write-ColorOutput "🔄 Please check:" -Color $Yellow
        Write-ColorOutput "  1. PostgreSQL service is running" -Color White
        Write-ColorOutput "  2. Database credentials are correct" -Color White
        Write-ColorOutput "  3. Sufficient disk space is available" -Color White
        Write-ColorOutput "  4. Network connectivity to database host" -Color White

        $success = $false
    } finally {
        # Send notification
        Send-Notification -BackupFile $backupFile -Success $success
    }

    return $success
}

# Function to schedule backup (Windows Task Scheduler)
function Schedule-Backup {
    param(
        [string]$Schedule = "Daily",
        [string]$Time = "02:00"
    )

    Write-ColorOutput "📅 Scheduling automated backup..." -Color $Cyan

    $taskName = "NexaTrace Database Backup"
    $scriptPath = $MyInvocation.MyCommand.Path
    $arguments = "-ExecutionPolicy Bypass -File `"$scriptPath`" -Silent"

    $action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument $arguments
    $trigger = $null

    switch ($Schedule) {
        "Daily" {
            $trigger = New-ScheduledTaskTrigger -Daily -At $Time
        }
        "Weekly" {
            $trigger = New-ScheduledTaskTrigger -Weekly -At $Time -DaysOfWeek Monday
        }
        "Hourly" {
            $trigger = New-ScheduledTaskTrigger -Once -At (Get-D
