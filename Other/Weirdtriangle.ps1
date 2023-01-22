#Powershell 3d Engine
$ErrorActionPreference = 'SilentlyContinue'

#Importing Asseblies
Add-Type -AssemblyName  Microsoft.VisualBasic, PresentationCore, PresentationFramework, System.Drawing, System.Windows.Forms, WindowsBase, WindowsFormsIntegration, System
#lib
[string]$fLib = $MyInvocation.MyCommand.Path;$fLib = Split-Path $fLib;$fLib = $fLib + "\src\lib\";cd $fLib
.\cmdwiz setfont 1
#Console Setup
[int]$nScreenWidth = 120
[int]$nScreenHeight = 40
#buffer and Window Size
$host.UI.RawUI.WindowSize = New-Object Management.Automation.Host.Size(($nScreenWidth), ($nScreenHeight))
$host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size(($nScreenWidth),($nScreenHeight))




#create console screen buffer
[string[]]$screen = @(" " * $nScreenWidth) * $nScreenHeight


#functions 
function SetPixel([int]$x, [int]$y, [char]$c)
{
    $screen[$y] = $screen[$y].Remove($x, 1).Insert($x, $c)
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

function 2dline {
	param ([int]$x1, [int]$y1, [int]$x2, [int]$y2)
	$dx = $x2 - $x1
	$dy = $y2 - $y1
	$steps = [math]::Max([math]::Abs($dx),[math]::Abs($dy))
	$xinc = $dx / $steps
	$yinc = $dy / $steps
	$x = $x1
	$y = $y1
	for ($i=0; $i -le $steps; $i++) {
		SetPixel $x $y "$"
		$x += $xinc
		$y += $yinc
	}
}

function DrawTriangle {
	param ([int]$x1, [int]$y1, [int]$x2, [int]$y2, [int]$x3, [int]$y3)
	2dline $x1 $y1 $x2 $y2
	2dline $x2 $y2 $x3 $y3
	2dline $x3 $y3 $x1 $y1
}




$i =0
#Main Loop
while ($true) {
    #clear screen
    $screen = @(" " * $nScreenWidth) * $nScreenHeight
    #draw triangle
		$i += 1
		
		$x1 = [math]::sin($i * 0.0174533) * 10 + 40
		$y1 = [math]::cos($i * 0.0174533) * 10 + 12
		$x2 = [math]::sin(($i + 120) * 0.0174533) * 10 + 40
		$y2 = [math]::Sin(($i + 120) * 0.0174533) * 10 + 12
		$x3 = [math]::Cos(($i + 240) * 0.0174533) * 10 + 40
		$y3 = [math]::Sin(($i + 240) * 0.0174533) * 10 + 12
		DrawTriangle $x1 $y1 $x2 $y2 $x3 $y3



    #draw screen
    [console]::setcursorposition(0,0)
    $Bytes = $screen.ToCharArray() -as [byte[]]
    $OutStream = [console]::OpenStandardOutput()
    $OutStream.Write($Bytes,0,$Bytes.Length)
}