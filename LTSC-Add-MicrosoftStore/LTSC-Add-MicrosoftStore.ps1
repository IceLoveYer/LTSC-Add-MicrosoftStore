$host.UI.RawUI.WindowTitle = "LTSC-Add-MicrosoftStore IceYer"

# ����Ƿ�Ϊ Windows 10 ����߰汾
if (([System.Environment]::OSVersion.Version).Major -lt 10) {
    Write-Host "�˽ű���֧�� Windows 10 �����ϰ汾��"
    exit
}

# ����Ƿ��Թ���ԱȨ������
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    Break
}

# ��ȡϵͳ�ܹ�
$architecture = if ([Environment]::Is64BitOperatingSystem) { "x64" } else { "x86" }

# ��ȡ��ǰ�ű�����Ŀ¼
$scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

# ����������ʽ����
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

# ����������ʽ��װ��
function Install-PackageByRegex {
    param (
        [string]$Path,
        [string[]]$RegexPatterns
    )

    # ����������ʽ
    foreach ($pattern in $RegexPatterns) {
        # ������ǰĿ¼���ļ�
        Write-Host "ƥ�䣺$pattern"
        Get-ChildItem -Path $Path | ForEach-Object {
            $file = $_
            # ����ļ����Ƿ�ƥ�䵱ǰ������ʽ
            if ($file.Name -match $pattern) {
                $packagePath = $file.FullName
                Write-Host "Ԥ�䣺$($file.Name)"

                # ʹ�� Add-AppxProvisionedPackage Ԥ��Ӧ��
                try {
                    Add-AppxProvisionedPackage -Online -PackagePath $packagePath -SkipLicense > $null
                    
                    Write-Host "״̬���ɹ���"
                }
                catch {
                    Write-Host "״̬��ʧ�ܣ�"
                    Write-Host $_.Exception.Message
                }
            }
        }
        Write-Host
        Write-Host
    }
}
Install-PackageByRegex -Path $scriptPath -RegexPatterns $regexPatterns

# ��������ʾ��������˳�
Write-Host "�ű�ִ�н�������������˳�..."
[void][Console]::ReadKey($true)