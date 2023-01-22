
$ErrorActionPreference = 'SilentlyContinue'
Function DrawColor{
	param([string]$text,[decimal]$r, [decimal]$g, [decimal]$b, [int]$x, [int]$y)
    $ansi_escape = [char]27
	$ansi_command = "$ansi_escape[48;2;{0};{1};{2}m" -f $r, $g, $b
	$ansi_terminate = "$ansi_escape[0m"
	$out = $ansi_command + $text + $ansi_terminate
    [console]::setcursorposition($x,$y)
	write-host -nonewline $out
}
[int]$nScreenWidth = 9000
[int]$nScreenHeight = 122

$host.UI.RawUI.WindowSize = New-Object Management.Automation.Host.Size(($nScreenWidth), 50)
$host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size(($nScreenWidth),($nScreenHeight))

cls
while(1){
for ($i = 0; $i -lt 360; $i++) {
    $r = [math]::round([Math]::Sin($i * [Math]::PI / 180) * 127)+ 128
    $g = [math]::round([Math]::Sin(($i + 120) * [Math]::PI / 180) * 127)+ 128
    $b = [math]::round([Math]::Sin(($i + 240) * [Math]::PI / 180) * 127 )+ 128
    $x += 1
    $y = [math]::round([Math]::Sin(($i)* [Math]::PI / 180) * 10) + 10
    DrawColor " " $r $g $b $x $y
};}









