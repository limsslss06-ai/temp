
# steps:
# git add -A
# git commit -m "message"
# git push


function Push-Git {
    [CmdletBinding()]  # 添加高级函数支持
    param(
        [Parameter(Position = 0)]
        [string]$Message = "",
        
        [switch]$Force,  # 添加强制推送选项
        [switch]$NoVerify  # 跳过钩子检查
    )

    # 检查是否是 git 仓库
    if (-not (Test-Path ".git")) {
        Write-Error "Not a Git repository"
        return
    }

    # 添加所有更改
    git add -A
    
    # 检查是否有更改
    $changes = git diff --cached --name-only
    if (-not $changes) {
        Write-Host "No changes to commit" -ForegroundColor Yellow
        return
    }

    # 显示将要提交的文件
    Write-Host "Files to commit:" -ForegroundColor Cyan
    $changes | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }

    # 构建提交信息
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $commitMessage = if ($Message) { "[$timestamp] $Message" } else { "[$timestamp]" }
    
    # 执行提交
    git commit -m $commitMessage
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Commit failed"
        return
    }

    # 执行推送
    $pushParams = @()
    if ($Force) { $pushParams += "--force" }
    if ($NoVerify) { $pushParams += "--no-verify" }
    
    git push @pushParams
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Changes pushed successfully" -ForegroundColor Green
        Write-Host "Commit message: $commitMessage" -ForegroundColor Green
    } else {
        Write-Error "Push failed"
    }
}