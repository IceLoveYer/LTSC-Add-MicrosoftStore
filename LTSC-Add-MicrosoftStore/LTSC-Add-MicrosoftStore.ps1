# --------------------------------------
# LTSC-Add-MicrosoftStore IceYer
# 先输出匹配到的文件名单，再按任意键继续安装
# --------------------------------------

# 设置 PowerShell 窗口标题
$host.UI.RawUI.WindowTitle = "LTSC-Add-MicrosoftStore IceYer"

# 获取当前脚本所在目录
$scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

# 获取系统架构
$architecture = if ([Environment]::Is64BitOperatingSystem) { "x64" } else { "x86" }

# 定义需匹配的正则表达式列表
$regexPatterns = @(
    "Microsoft.NET.Native.Framework[0-9\._]+${architecture}__8wekyb3d8bbwe.Appx",
    "Microsoft.NET.Native.Runtime[0-9\._]+${architecture}__8wekyb3d8bbwe.Appx",
    "Microsoft.UI.Xaml[0-9\._]+${architecture}__8wekyb3d8bbwe.Appx",
    "Microsoft.VCLibs[0-9\._]+UWPDesktop[0-9\._]+${architecture}__8wekyb3d8bbwe.Appx",
    "Microsoft.VCLibs[0-9\._]+${architecture}__8wekyb3d8bbwe.Appx",
    "Microsoft.Services.Store.Engagement[0-9\._]+${architecture}__8wekyb3d8bbwe.Appx",
    "Microsoft.WindowsStore[0-9\._]+neutral_~_8wekyb3d8bbwe.Msixbundle"
)

# ------------------------
# 1) 显示所有匹配文件
# ------------------------
Write-Host "开始匹配文件（系统类型：$architecture）...`n"
# 用来保存所有匹配到的文件信息
$matchedFiles = New-Object System.Collections.Generic.List[System.IO.FileInfo]
foreach ($pattern in $regexPatterns) {
    Write-Host "正则：$pattern"
    # 在当前目录下查找所有文件，并用 -match 判断是否符合正则
    $files = Get-ChildItem -Path $scriptPath -File | Where-Object { $_.Name -match $pattern }
    foreach ($file in $files) {
        Write-Host "匹配：$($file.Name)"
        $matchedFiles.Add($file) | Out-Null
    }
    Write-Host
}

# 如果一个都没匹配到，直接提示退出
if ($matchedFiles.Count -eq 0) {
    Write-Host "未匹配到任何文件。按任意键退出..."
    [void][Console]::ReadKey($true)
    exit
}

Write-Host "`n以上是匹配到的文件列表，请确认后按任意键开始安装..."
Write-Host ""
[void][Console]::ReadKey($true)

# ------------------------
# 2) 等待按键后，再执行安装
# ------------------------
foreach ($file in $matchedFiles) {
    Write-Host "`n正在安装：$($file.Name)"
    try {
        # 如需安装到当前用户，可改为： Add-AppxPackage -Path $file.FullName
        Add-AppxProvisionedPackage -Online -PackagePath $file.FullName -SkipLicense | Out-Null
        Write-Host "    状态：成功"
    }
    catch {
        Write-Host "    状态：失败：$($_.Exception.Message)"
    }
}

# ------------------------
# 3) 安装结束，等待退出
# ------------------------
Write-Host "`n脚本执行结束。按任意键退出..."
[void][Console]::ReadKey($true)
