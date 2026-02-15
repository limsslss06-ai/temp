
# step:
# 1. git checkout --orphan temp_branch
# 2. git add -A
# 3. git commit -m "message"
# 4. git branch -D main
# 5. git branch -m main
# 6. git push -f origin main

function Reset-Git {
    [CmdletBinding()]  # 添加高级函数支持
    param(
        [Parameter(Position = 0)]
        [string]$Message = "Reset Git repository to a clean state"
    )

    # 检查是否是 git 仓库
    if (-not (Test-Path ".git")) {
        Write-Error "Not a Git repository"
        return
    }

    # Var:
    # 安全时间戳（冒号在 Windows 下可能有问题）
    $timestamp = Get-Date -Format "yyyy-MM-dd HH-mm-ss"
    $commitMessage = "[$timestamp] $Message"
    $tempBranchName = "Reset_Git_temp_branch"

     # 3️⃣ 删除临时分支 temp_branch（如果存在）
    if (git show-ref --verify --quiet refs/heads/temp_branch) {
        # 获取当前分支
        $currentBranch = git rev-parse --abbrev-ref HEAD
        if ($currentBranch -eq $tempBranchName) {
            # 当前在 temp_branch，脱离 HEAD 以便删除分支
            git checkout --detach
        }
        git branch -D $tempBranchName 2>$null | Out-Null
    }

    # 创建临时分支
    git checkout --orphan $tempBranchName
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to create orphan branch"
        return
    }

    # 添加所有更改并提交
    git add -A
    git commit -m $commitMessage
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Commit failed"
        return
    }

    # 删除 main 分支（如果存在）并重命名 temp_branch -> main
    git branch -D main 2>$null | Out-Null
    git branch -m main
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to rename branch"
        return
    }

    # 强制推送到远程仓库
    git push -f origin main
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Git repository reset successfully" -ForegroundColor Green
        Write-Host "Commit message: $commitMessage" -ForegroundColor Green
    }
    else {
        Write-Error "Push failed" -ForegroundColor Red
    }

}