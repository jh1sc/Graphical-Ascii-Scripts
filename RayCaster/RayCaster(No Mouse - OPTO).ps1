
$ErrorActionPreference = 'SilentlyContinue'
#RayCasting Game in powershell using DDA algorithm


#Importing Asseblies
Add-Type -AssemblyName  Microsoft.VisualBasic, PresentationCore, PresentationFramework, System.Drawing, System.Windows.Forms, WindowsBase, WindowsFormsIntegration, System

#lib
[string]$fLib = $MyInvocation.MyCommand.Path;$fLib = Split-Path $fLib;$fLib = $fLib + "\src\lib\";cd $fLib
.\cmdwiz setfont 1

#Console Setup
[int]$nScreenWidth = 60
[int]$nScreenHeight = 40
#buffer and Window Size
$host.UI.RawUI.WindowSize = New-Object Management.Automation.Host.Size(($nScreenWidth), ($nScreenHeight))
$host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size(($nScreenWidth),($nScreenHeight))

[cosnole]::CursorVisible = $false
[System.Console]::SetWindowPosition(0,0)
[System.Console]::Title = "LOADING..."
[System.Console]::BackgroundColor = [System.ConsoleColor]::Black
[System.Console]::ForegroundColor = [System.ConsoleColor]::White
[System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8

#create console screen buffer
[string[]]$screen = @(" " * $nScreenWidth) * $nScreenHeight

[string[]]$map = @(
    "3444444444444441",
    "3..............1",
    "3..............1",
    "3..44444444....1",
    "3..............1",
    "3......3.......1",
    "3......3.......1",
    "3......3.......1",
    "3......3111....1",
    "3......3.......1",
    "3......3.......1",
    "3......3.......1",
    "3......3.......1",
    "3..............1",
    "3..............1",
    "2222222222222221"
)

#Variables
[float]$fPlayerX = 2
[float]$fPlayerY = 2
[float]$fPlayerA = 0.0

[float]$fFOV = 3.14159 / 4.0
[float]$fDepth = 32
[int]$nRenderDist = 4


[int]$nMapWidth = $map[0].length
[int]$nMapHeight = $map.length
[int]$iter = 1
[float]$fSpeed = 0.5

#FUNCTIONS

#Gets Key State
function ASKS {
	param ([string]$Char)
	Add-Type -AssemblyName System.Windows.Forms
	#A-sync Key State
	$signature = 
@"
	[DllImport("user32.dll", CharSet=CharSet.Auto, ExactSpelling=true)]
	public static extern short GetAsyncKeyState(int virtualKeyCode);
"@
$GetAsyncKeyState = Add-Type -MemberDefinition $signature -Name "Win32GetAsyncKeyState" -Namespace Win32Functions -PassThru
return $GetAsyncKeyState::GetAsyncKeyState([System.Windows.Forms.Keys]::$Char)
}
#Draw Pixel on screen (Not Used as a ffor optimization)
function Draw-Pixel ([int]$x,[int]$y,[string]$o) {$screen[$y] = $screen[$y].substring(0,$x) + $o + $screen[$y].substring($x+1)}
#Draws to Console quickly (Not Used as a function for optimization)
function Write-Console {
param ([string]$String)
[console]::setcursorposition(0,0);$Bytes = $String.ToCharArray() -as [byte[]]
$OutStream = [console]::OpenStandardOutput();$OutStream.Write($Bytes,0,$Bytes.Length)
}



#GameLoop
while($true)
{   
    #Clear Screen
    $sw = [Diagnostics.Stopwatch]::StartNew()
    [string[]]$screen = @(" " * $nScreenWidth) * $nScreenHeight
    $iter++
    #For each column

	#controlss..
	if ((ASKS W) -ne "0")
    {
        $fPlayerX += [math]::Sin($fPlayerA) * $fSpeed * ($fps / 110)
        $fPlayerY += [math]::Cos($fPlayerA) * $fSpeed * ($fps / 110)
        if ($map[$fPlayerY][$fPlayerX] -ne ".")
        {
            $fPlayerX -= [math]::Sin($fPlayerA) * $fSpeed * ($fps / 110)
            $fPlayerY -= [math]::Cos($fPlayerA) * $fSpeed * ($fps / 110)
        }
        $CK= "W" 
    }
	if ((ASKS S) -ne "0")
    {
        $fPlayerX -= [math]::Sin($fPlayerA) * $fSpeed * ($fps / 110)
        $fPlayerY -= [math]::Cos($fPlayerA) * $fSpeed * ($fps / 110)
        if ($map[$fPlayerY][$fPlayerX] -ne ".")
        {
            $fPlayerX += [math]::Sin($fPlayerA) * $fSpeed * ($fps / 110)
            $fPlayerY += [math]::Cos($fPlayerA) * $fSpeed * ($fps / 110)
        }
        $CK= "S"
    }
	if ((ASKS D) -ne "0"){$fPlayerA += 0.2 * ($fps / 110) * $fSpeed;$CK= "D"}
	if ((ASKS A) -ne "0"){$fPlayerA -= 0.2 * ($fps / 110) * $fSpeed;$CK= "A"}
    if ((ASKS Q) -ne "0"){$fFOV += 0.1;$CK= "Q"}
    if ((ASKS E) -ne "0"){$fFOV -= 0.1;$CK= "E"}
    if ((ASKS Up) -ne "0"){$fSpeed += 0.1;$CK= "Up"}
    if ((ASKS Down) -ne "0"){$fSpeed -= 0.1;$CK= "Down"}
    if ((ASKS Left) -ne "0"){$fDepth += 1;$CK= "Left"}
    if ((ASKS Right) -ne "0"){$fDepth -= 1;$CK= "Right"}


    for ([int]$x = 0; $x -lt $nScreenWidth; $x++)
    {
        #For each ray
        [float]$fRayAngle = ($fPlayerA - $fFOV / 2.0) + ($x / $nScreenWidth) * $fFOV
        #Find distance to wall
        [float]$fStepSize = 0.1 #Increment size for ray casting, decrease to increase resolution
        [float]$fDistanceToWall = 0.0
        [bool]$bHitWall = $false #Set when ray hits wall block
        #Unit vector for ray in player space
        [float]$fEyeX = [Math]::Sin($fRayAngle)
        [float]$fEyeY = [Math]::Cos($fRayAngle)

        while (!$bHitWall -and $fDistanceToWall -lt $fDepth)
        {
            $fDistanceToWall += $fStepSize
            [int]$nTestX = [int]($fPlayerX + $fEyeX * $fDistanceToWall)
            [int]$nTestY = [int]($fPlayerY + $fEyeY * $fDistanceToWall)
            #Test if ray is out of bounds
            if ($nTestX -lt 0 -or $nTestX -ge $nMapWidth -or $nTestY -lt 0 -or $nTestY -ge $nMapHeight)
            {
                $bHitWall = $true #Just set distance to maximum depth
                $fDistanceToWall = $fDepth
            }
            else
            {
                #Ray is inbounds so test to see if the ray cell is a wall block
                if ($map[$nTestY][$nTestX] -ne "." )
                {
                    $bHitWall = $true
                    #texture wall depedning on the side of the wall
                    $texture = $map[$nTestY][$nTestX]
                    #draw sides of wall to make it look 3D
                    if ($texture -eq "1"){$texture = "@"}
                    if ($texture -eq "2"){$texture = "%"}
                    if ($texture -eq "3"){$texture = "#"}
                    if ($texture -eq "4"){$texture = "&"}


                }
            }
        }

        #Calculate distance to ceiling and floor
        [int]$nCeiling = [int](($nScreenHeight / 2.0) - $nScreenHeight / $fDistanceToWall)
        [int]$nFloor = $nScreenHeight - $nCeiling
        #$ShadeIndex = "M@&#?!=;:~-,. "
	    $ShadeIndex = "MQW#BNqpHERmKdgAGbX8@SDOPUkwZyF69heT0a&xV%Cs4fY52Lonz3ucJjvItr}{li?1][7<>=)(+*|!/\;:-,_~^.'"


        for([int]$y=0;$y -lt $nScreenHeight; $y++)
        {
            if ($y -lt $nCeiling)
            {
                        $screen[$y] = $screen[$y].substring(0,$i) + "|" + $screen[$y].substring($i+1)
            }
            elseif ($y -gt $nCeiling -and $y -le $nFloor)
            {
                #wall
                


                $screen[$y] = $screen[$y].substring(0,$x) + $texture + $screen[$y].substring($x+1)
            }
            else
            {
                #floor
                $screen[$y] = $screen[$y].substring(0,$x) + "-" + $screen[$y].substring($x+1)
            }
        }
    }
    #display Map at y10 x0
    for([int]$nx=0;$nx -lt $nMapWidth; $nx++)
    {
        for([int]$ny=0;$ny -lt $nMapHeight; $ny++)
        {
            $screen[$ny+1] = $screen[$ny+1].substring(0,$nx) + $map[$ny][$nx] + $screen[$ny+1].substring($nx+1)
            $screen[[int]$fPlayerY+1] = $screen[[int]$fPlayerY+1].substring(0,[int]$fPlayerX) + "P" + $screen[[int]$fPlayerY+1].substring([int]$fPlayerX+1)
        }
    }
    #draw debug info at y x0
    $debug = "X:" + [int]$fPlayerX + " Y:" + [int]$fPlayerY + " Angle:" + [int]$fPlayerAn + " FPS:" + [int]$fps + " Current Key:" + $CK + " FOV:" + [int]$fFOV + " Speed:" + [int]$fSpeed + " Depth:" + [int]$fDepth
    $screen[0] = $debug
    
    $String = ($screen -join "`n")
    [console]::setcursorposition(0,0);$Bytes = $String.ToCharArray() -as [byte[]]
    $OutStream = [console]::OpenStandardOutput();$OutStream.Write($Bytes,0,$Bytes.Length)
    $sw.Stop()
	$tks = $sw.ElapsedTicks
 	$fps = [math]::Round(10000000/$tks)
    $fPlayerAn = $fPlayerA * 180 / [math]::PI
    [system.console]::title = "Made by: Jh1sc"
}
