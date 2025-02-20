<# :
@echo off
powershell /nologo /noprofile /command "&{[ScriptBlock]::Create((cat """%~f0""") -join [Char[]]10).Invoke(@(&{$args}%*))}"
exit /b
#>
<#
MIT License

Copyright(c) 2021 James Edward Anhalt III - https://github.com/jeaiii

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
#>

$global:ProgressPreference = 'SilentlyContinue'

$cache = ".cache"
$packages = @{}

function default
{
    param($Value, $Default)
    if ($Value) { $Value } else { $Default }
}

function Cache
{
    param ([string]$Uri, [string]$Path)
    if (-not (Test-Path -Path "$cache/$Path"))
    {
        if (-not (Test-Path -Path "$cache/$Path.zip"))
        {
            Write-Host GET: $Uri -> "$cache/$Path.zip" -Fo Blue
            Invoke-WebRequest -Uri $Uri -OutFile "$cache/$Path.zip"
        }
        Write-Host UNZIP: "$cache/$Path.zip" -> "$cache/$Path" -Fo Blue
        Expand-Archive -Path "$cache/$Path.zip" -DestinationPath "$cache/$Path" -Force
        Get-ChildItem -Path "$cache/$Path" -File -Recurse | foreach {$_.IsReadOnly = $true}
    }
}

$premake = Get-Content -Raw -Path "premake5.json" | ConvertFrom-Json

if (-not (Test-Path -Path $cache))
{
    $_ = New-Item -Path $cache -ItemType "directory"
}

if ($premake.packages)
{
    foreach($package in $premake.packages.PsObject.Properties)
    {
        $name = $package.Name
        $org = $package.Value.org
        $repo = default $package.Value.repo $name
        $version = default $package.Value.version "main"
        $path = "$org-$repo-$version"
        $uri = default $package.Value.uri "https://api.github.com/repos/$org/$repo/zipball/$version"
        Cache -Uri $uri -Path $path
        $find = (Get-ChildItem -Path "$cache/$path" -Name -Directory)
        if ($find -ne $repo)
        {
            Write-Host RENAME: "$cache/$path/$find" -> "$cache/$path/$repo" -fo Blue
            Rename-Item "$cache/$path/$find" $name
        }

        $src = default $package.Value.src "."
        $h = default $package.Value.h $src

        $packages | Add-Member $package.Name @{
            "root" = "$cache/$path/$repo/"; "src" = "$cache/$path/$repo/$src/"; "h" = "$cache/$path/$repo/$h/";
        }
    }
}

$version = default $premake.version "5.0.0-alpha16"
$os = default $premake.os "windows"
$action = default $premake.action "vs2019"

$path = "premake-$version-$os"
Write-Host PREMAKE: $path -fo green
	
Cache -Uri "https://github.com/premake/premake-core/releases/download/v$version/$path.zip" -Path $path

$packages | ConvertTo-Json | Set-Content -Path "$cache/packages.json"

Start-Process -FilePath "$cache/$path/premake5" -NoNewWindow -Wait -ArgumentList $action
