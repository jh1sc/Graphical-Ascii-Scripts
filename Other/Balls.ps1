Add-Type -AssemblyName  Microsoft.VisualBasic, PresentationCore, PresentationFramework, System.Drawing, System.Windows.Forms, WindowsBase, WindowsFormsIntegration, System
#$ErrorActionPreference = 'SilentlyContinue'
[int]$nScreenWidth = 240
[int]$nScreenHeight = 124
[string[]]$screen = @(" " * $nScreenWidth) * $nScreenHeight
$host.UI.RawUI.WindowSize = New-Object Management.Automation.Host.Size(($nScreenWidth), ($nScreenHeight))
$host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size(($nScreenWidth),($nScreenHeight))
[console]::OutputEncoding = [Text.Encoding]::Unicode

Function Pixel 
{
    param
    (
        [Parameter(Mandatory = $true)]
        [int]$x,
        [Parameter(Mandatory = $true)]
        [int]$y,
        [Parameter(Mandatory = $true)]
        [char]$c
    )
   #$x = [math]::round($x + $nScreenWidth/2)
    #$y = [math]::round($y + $nScreenHeight/2)
    if($x -gt $nScreenWidth -or $y -gt $nScreenHeight -or $x -lt 0 -or $y -lt 0){return}
    $screen[$y] = $screen[$y].Substring(0,$x) + $c + $screen[$y].Substring($x+1)
}

function 2dLine 
{
    param 
    (
        [float]$x1,
        [float]$y1,
        [float]$x2,
        [float]$y2,
        [char]$c
    )
    if( $c -eq $null){$c = GetSlopeChar $x1 $y1 $x2 $y2}
    $x1 = [math]::round($x1)
    $x2 = [math]::round($x2)
    $y1 = [math]::round($y1)
    $y2 = [math]::round($y2)

    #2d line drawer
    $dx = $x2 - $x1
	$dy = $y2 - $y1
	$dx = [math]::abs($dx)
	$dy = [math]::abs($dy)
	$sx = $x1 - $x2
	$sy = $y1 - $y2
	if ($x1 -lt $x2) {$sx = 1} else {$sx = -1}
	if ($y1 -lt $y2) {$sy = 1} else {$sy = -1}
	$err = $dx - $dy
	while ($true) {
        Pixel $x1 $y1 $c
		if (($x1 -eq $x2) -and ($y1 -eq $y2)) {break}
		$e2 = 2 * $err
		if ($e2 -gt -$dy) {$err = $err - $dy; $x1 = $x1 + $sx}
		if ($e2 -lt $dx) {$err = $err + $dx; $y1 = $y1 + $sy}
	}
}
function GetSlopeChar([double] $x1, [double] $y1, [double] $x2, [double] $y2) {
  # Calculate the angle in degrees
  $angle = [Math]::Atan2(($y2 - $y1), ($x2 - $x1)) * 180 / [Math]::PI

  # Output the appropriate ASCII character based on the angle
  if ($angle -ge 67.5) {
    return "\"
  }
  elseif ($angle -ge 22.5) {
    return "/"
  }
  elseif ($angle -ge -22.5) {
    return "-"
  }
  elseif ($angle -ge -67.5) {
    return "\"
  }
  else {
    return "|"
  }
}


function ASKS {
    param ([string]$Char)
    $signature = 
@"
	[DllImport("user32.dll", CharSet=CharSet.Auto, ExactSpelling=true)]
	public static extern short GetAsyncKeyState(int virtualKeyCode);
"@
$GetAsyncKeyState = Add-Type -MemberDefinition $signature -Name "Win32GetAsyncKeyState" -Namespace Win32Functions -PassThru
return $GetAsyncKeyState::GetAsyncKeyState([System.Windows.Forms.Keys]::$Char)
}

function Draw-Circle {
    param (
        [double]$Radius,
        [float]$CenterPositionx,
        [float]$CenterPositiony,
        [int]$Resolution,
        [char]$c
    )
    for ($i = 0; $i -le $Resolution; $i++) {
        $angle = ($i / $Resolution) * (2 * [Math]::PI)
        $x = $CenterPositionx + ($Radius * [Math]::Cos($angle))
        $y = $CenterPositiony + ($Radius * [Math]::Sin($angle))
        Pixel $x $y $c
    }
}



function Get-CursorPosition
{
        $mousepos = [System.Windows.Forms.Cursor]::Position
        $mx = [int]($mousepos.x * ($host.UI.RawUI.BufferSize.Width / [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width))
        $my = [int]($mousepos.y * ($host.UI.RawUI.BufferSize.Height / [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height))
        return $mx, $my
}

while ($true)
{
    $sw = [Diagnostics.Stopwatch]::StartNew()
    $screen = @(" " * $nScreenWidth) * $nScreenHeight

    
$x, $y = Get-CursorPosition
Draw-Circle 10 $x $y 36 "█"




    $sw.Stop()
	$tks = $sw.ElapsedTicks
 	$fps = [math]::Round(10000000/$tks)
    [system.console]::title = "Made by: Jh1sc - FPS: $fps"
    [console]::setcursorposition(0,0)
    write-output ($screen -join "`n")
}
