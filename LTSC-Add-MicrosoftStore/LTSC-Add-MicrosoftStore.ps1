$host.UI.RawUI.WindowTitle = "LTSC-Add-MicrosoftStore IceYer"

# 检查是否为 Windows 10 或更高版本
if (([System.Environment]::OSVersion.Version).Major -lt 10) {
    Write-Host "此脚本仅支持 Windows 10 及以上版本。"
    exit
}

# 检查是否以管理员权限运行
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    Break
}

# 获取系统架构
$architecture = if ([Environment]::Is64BitOperatingSystem) { "x64" } else { "x86" }

# 获取当前脚本所在目录
$scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

# 定义正则表达式数组
# Microsoft.NET.Native.Framework.2.2_2.2.29512.0_x86__8wekyb3d8bbwe.Appx
# Microsoft.NET.Native.Framework.2.2_2.2.29512.0_x64__8wekyb3d8bbwe.Appx
# Microsoft.NET.Native.Runtime.2.2_2.2.28604.0_x86__8wekyb3d8bbwe.Appx
# Microsoft.NET.Native.Runtime.2.2_2.2.28604.0_x64__8wekyb3d8bbwe.Appx
# Microsoft.UI.Xaml.2.8_8.2310.30001.0_x86__8wekyb3d8bbwe.Appx
# Microsoft.UI.Xaml.2.8_8.2310.30001.0_x64__8wekyb3d8bbwe.Appx
# Microsoft.VCLibs.140.00.UWPDesktop_14.0.33519.0_x86__8wekyb3d8bbwe.Appx
# Microsoft.VCLibs.140.00.UWPDesktop_14.0.33519.0_x64__8wekyb3d8bbwe.Appx
# Microsoft.VCLibs.140.00_14.0.33519.0_x64__8wekyb3d8bbwe.Appx
# Microsoft.VCLibs.140.00_14.0.33519.0_x86__8wekyb3d8bbwe.Appx
# Microsoft.WindowsStore_22402.1401.4.0_neutral_~_8wekyb3d8bbwe.Msixbundle
$regexPatterns = @(
    "Microsoft\.NET\.Native\.Framework[0-9\._]+$architecture[_]+8wekyb3d8bbwe\.Appx",
    "Microsoft\.NET\.Native\.Runtime[0-9\._]+$architecture[_]+8wekyb3d8bbwe\.Appx",
    "Microsoft\.UI\.Xaml[0-9\._]+$architecture[_]+8wekyb3d8bbwe\.Appx",
    "Microsoft\.VCLibs[0-9\._]+UWPDesktop[0-9\._]+$architecture[_]+8wekyb3d8bbwe\.Appx",
    "Microsoft\.VCLibs[0-9\._]+$architecture[_]+8wekyb3d8bbwe\.Appx",
    "Microsoft.WindowsStore[0-9\._]+neutral_~_8wekyb3d8bbwe.Msixbundle"
)

# 定义正则表达式安装包
function Install-PackageByRegex {
    param (
        [string]$Path,
        [string[]]$RegexPatterns
    )

    # 遍历正则表达式
    foreach ($pattern in $RegexPatterns) {
        # 遍历当前目录的文件
        Write-Host "匹配：$pattern"
        Get-ChildItem -Path $Path | ForEach-Object {
            $file = $_
            # 检查文件名是否匹配当前正则表达式
            if ($file.Name -match $pattern) {
                $packagePath = $file.FullName
                Write-Host "预配：$($file.Name)"

                # 使用 Add-AppxProvisionedPackage 预配应用
                try {
                    Add-AppxProvisionedPackage -Online -PackagePath $packagePath -SkipLicense > $null
                    
                    Write-Host "状态：成功！"
                }
                catch {
                    Write-Host "状态：失败！"
                    Write-Host $_.Exception.Message
                }
            }
        }
        Write-Host
        Write-Host
    }
}
Install-PackageByRegex -Path $scriptPath -RegexPatterns $regexPatterns

# 结束后提示按任意键退出
Write-Host "脚本执行结束。按任意键退出..."
[void][Console]::ReadKey($true)