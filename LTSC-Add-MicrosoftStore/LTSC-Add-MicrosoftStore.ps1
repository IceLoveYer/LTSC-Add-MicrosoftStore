# --------------------------------------
# LTSC-Add-MicrosoftStore IceYer
# �����ƥ�䵽���ļ��������ٰ������������װ
# --------------------------------------

# ���� PowerShell ���ڱ���
$host.UI.RawUI.WindowTitle = "LTSC-Add-MicrosoftStore IceYer"

# ��ȡ��ǰ�ű�����Ŀ¼
$scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

# ��ȡϵͳ�ܹ�
$architecture = if ([Environment]::Is64BitOperatingSystem) { "x64" } else { "x86" }

# ������ƥ���������ʽ�б�
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
# 1) ��ʾ����ƥ���ļ�
# ------------------------
Write-Host "��ʼƥ���ļ���ϵͳ���ͣ�$architecture��...`n"
# ������������ƥ�䵽���ļ���Ϣ
$matchedFiles = New-Object System.Collections.Generic.List[System.IO.FileInfo]
foreach ($pattern in $regexPatterns) {
    Write-Host "����$pattern"
    # �ڵ�ǰĿ¼�²��������ļ������� -match �ж��Ƿ��������
    $files = Get-ChildItem -Path $scriptPath -File | Where-Object { $_.Name -match $pattern }
    foreach ($file in $files) {
        Write-Host "ƥ�䣺$($file.Name)"
        $matchedFiles.Add($file) | Out-Null
    }
    Write-Host
}

# ���һ����ûƥ�䵽��ֱ����ʾ�˳�
if ($matchedFiles.Count -eq 0) {
    Write-Host "δƥ�䵽�κ��ļ�����������˳�..."
    [void][Console]::ReadKey($true)
    exit
}

Write-Host "`n������ƥ�䵽���ļ��б���ȷ�Ϻ��������ʼ��װ..."
Write-Host ""
[void][Console]::ReadKey($true)

# ------------------------
# 2) �ȴ���������ִ�а�װ
# ------------------------
foreach ($file in $matchedFiles) {
    Write-Host "`n���ڰ�װ��$($file.Name)"
    try {
        # ���谲װ����ǰ�û����ɸ�Ϊ�� Add-AppxPackage -Path $file.FullName
        Add-AppxProvisionedPackage -Online -PackagePath $file.FullName -SkipLicense | Out-Null
        Write-Host "    ״̬���ɹ�"
    }
    catch {
        Write-Host "    ״̬��ʧ�ܣ�$($_.Exception.Message)"
    }
}

# ------------------------
# 3) ��װ�������ȴ��˳�
# ------------------------
Write-Host "`n�ű�ִ�н�������������˳�..."
[void][Console]::ReadKey($true)
