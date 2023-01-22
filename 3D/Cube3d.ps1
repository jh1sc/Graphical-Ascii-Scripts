Add-Type -AssemblyName  Microsoft.VisualBasic, PresentationCore, PresentationFramework, System.Drawing, System.Windows.Forms, WindowsBase, WindowsFormsIntegration, System
$ErrorActionPreference = 'SilentlyContinue'

#Console Setup
[int]$nScreenWidth = 240
[int]$nScreenHeight = 122
[string[]]$screen = @(" " * $nScreenWidth) * $nScreenHeight

#buffer and Window Size
$host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size(($nScreenWidth),($nScreenHeight))
$host.UI.RawUI.WindowSize = New-Object Management.Automation.Host.Size(($nScreenWidth), ($nScreenHeight))



function 3dPixelline
{
    param
    (
        # ProjMat
        [Parameter(Mandatory = $true)]
        [System.Numerics.Matrix4x4]$projectionMatrix,

        # The 3D coordinates
        [Parameter(Mandatory = $true)]
        [float]$X,

        [Parameter(Mandatory = $true)]
        [float]$Y,

        [Parameter(Mandatory = $true)]
        [float]$Z,

        [Parameter(Mandatory = $true)]
        [float]$X1,

        [Parameter(Mandatory = $true)]
        [float]$Y1,

        [Parameter(Mandatory = $true)]
        [float]$Z1
    )
    #$projectionMatrix = [System.Numerics.Matrix4x4]::CreatePerspectiveFieldOfView($Fov, $Aspr, $Near, $Far)
    $point3D = New-Object System.Numerics.Vector3($X, $Y, $Z)
    $point3D1 = New-Object System.Numerics.Vector3($X1, $Y1, $Z1)
    $point2D = [System.Numerics.Vector3]::Transform($point3D, $projectionMatrix)
    $point2D1 = [System.Numerics.Vector3]::Transform($point3D1, $projectionMatrix)

    $x1 = [System.Math]::Round($point2D.X + $nScreenWidth / 2)
    $y1 = [System.Math]::Round($point2D.Y + $nScreenHeight / 2)
    $x2 = [System.Math]::Round($point2D1.X + $nScreenWidth / 2)
    $y2 = [System.Math]::Round($point2D1.Y + $nScreenHeight / 2)


    #$char = "#"
    $char = GetSlopeChar $X $Y $X1 $Y1 

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
        $screen[$y1] = $screen[$y1].substring(0,$x1) + $char + $screen[$y1].substring($x1+1)
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



function ConvertToRadians([double]$degrees) {
    return ($degrees * (4.0 * [math]::atan(1.0))) / 180.0
}

function 3dPixel
{
    param
    (
         # ProjMat
        [Parameter(Mandatory = $true)]
        [System.Numerics.Matrix4x4]$projectionMatrix,

        # The 3D coordinates
        [Parameter(Mandatory = $true)]
        [float]$X,

        [Parameter(Mandatory = $true)]
        [float]$Y,

        [Parameter(Mandatory = $true)]
        [float]$Z,

        [Parameter(Mandatory = $true)]
        [char]$Char
    )
    #$projectionMatrix = [System.Numerics.Matrix4x4]::CreatePerspectiveFieldOfView($Fov, $Aspr, $Near, $Far)
    $point3D = New-Object System.Numerics.Vector3($X, $Y, $Z)
    $point2D = [System.Numerics.Vector3]::Transform($point3D, $projectionMatrix)
    $x1 = [System.Math]::Round($point2D.X + $nScreenWidth / 2)
    $y1 = [System.Math]::Round($point2D.Y + $nScreenHeight / 2)
    $screen[$y1] = $screen[$y1].substring(0,$x1) + $Char + $screen[$y1].substring($x1+1)

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

#3dPixelline $fov $aspectRatio $nearPlaneDistance $farPlaneDistance $x1 $y1 $z1 $x2 $y2 $z2


$Vertexs = @(
[pscustomobject]@{x=-0.5;y=-0.5;z=-0.5},
[pscustomobject]@{x=-0.5;y=-0.5;z=0.5},
[pscustomobject]@{x=-0.5;y=0.5;z=-0.5},
[pscustomobject]@{x=-0.5;y=0.5;z=0.5},
[pscustomobject]@{x=0.5;y=-0.5;z=-0.5},
[pscustomobject]@{x=0.5;y=-0.5;z=0.5},
[pscustomobject]@{x=0.5;y=0.5;z=-0.5},
[pscustomobject]@{x=0.5;y=0.5;z=0.5}
)
$Faces = @(
[pscustomobject]@{v1=0;v2=1;v3=3},
[pscustomobject]@{v1=0;v2=3;v3=2},
[pscustomobject]@{v1=4;v2=6;v3=7},
[pscustomobject]@{v1=4;v2=7;v3=5},
[pscustomobject]@{v1=0;v2=4;v3=5},
[pscustomobject]@{v1=0;v2=5;v3=1},
[pscustomobject]@{v1=2;v2=3;v3=7},
[pscustomobject]@{v1=2;v2=7;v3=6},
[pscustomobject]@{v1=0;v2=2;v3=6},
[pscustomobject]@{v1=0;v2=6;v3=4},
[pscustomobject]@{v1=1;v2=5;v3=7},
[pscustomobject]@{v1=1;v2=7;v3=3}
)


for ($j=0; $j -lt $Vertexs.length; $j++) {
		$Vertexs[$j].x *= 10
		$Vertexs[$j].y *= 10
		$Vertexs[$j].z *= 10
}

# Convert the 3D coordinates to 2D coordinates
    $fov = [System.Math]::PI / 4
    $aspectRatio = $nScreenWidth / $nScreenHeight
    $nearPlaneDistance = 0.1
    $farPlaneDistance = 100
    $projectionMatrix = [System.Numerics.Matrix4x4]::CreatePerspectiveFieldOfView($fov, $aspectRatio, $nearPlaneDistance, $farPlaneDistance)
    $fovniR = 60

while ($true) {
    $sw = [Diagnostics.Stopwatch]::StartNew()
    #clear screen
    $screen = @(" " * $nScreenWidth) * $nScreenHeight

    for($t=0;$t -lt $Faces.length;$t++){
    3dPixelline $projectionMatrix $Vertexs[$Faces[$t].v1].x $Vertexs[$Faces[$t].v1].y $Vertexs[$Faces[$t].v1].z $Vertexs[$Faces[$t].v2].x $Vertexs[$Faces[$t].v2].y $Vertexs[$Faces[$t].v2].z
    3dPixelline $projectionMatrix $Vertexs[$Faces[$t].v2].x $Vertexs[$Faces[$t].v2].y $Vertexs[$Faces[$t].v2].z $Vertexs[$Faces[$t].v3].x $Vertexs[$Faces[$t].v3].y $Vertexs[$Faces[$t].v3].z 
    3dPixelline $projectionMatrix $Vertexs[$Faces[$t].v3].x $Vertexs[$Faces[$t].v3].y $Vertexs[$Faces[$t].v3].z $Vertexs[$Faces[$t].v1].x $Vertexs[$Faces[$t].v1].y $Vertexs[$Faces[$t].v1].z 
}

    for ($i=0; $i -lt $Vertexs.length; $i++) {
        3dPixel $projectionMatrix $Vertexs[$i].x $Vertexs[$i].y $Vertexs[$i].z "@"
    }
    
    #rotation
    $theta = 0.05
    $cosTheta = [System.Math]::Cos($theta)
    $sinTheta = [System.Math]::Sin($theta)


    if (ASKS("W")) {
        #rotate around x axis
        for ($j=0; $j -lt $Vertexs.Length; $j++) {
            $y = $Vertexs[$j].y
            $z = $Vertexs[$j].z
            $Vertexs[$j].y = $y * $cosTheta - $z * $sinTheta
            $Vertexs[$j].z = $y * $sinTheta + $z * $cosTheta
        }
    }

    if (ASKS("S")) {
        #rotate around x axis
        for ($j=0; $j -lt $Vertexs.Length; $j++) {
            $y = $Vertexs[$j].y
            $z = $Vertexs[$j].z
            $Vertexs[$j].y = $y * $cosTheta + $z * $sinTheta
            $Vertexs[$j].z = $z * $cosTheta - $y * $sinTheta
        }
    }

    if (ASKS("A")) {
        #rotate around y axis
        for ($j=0; $j -lt $Vertexs.Length; $j++) {
            $x = $Vertexs[$j].x
            $z = $Vertexs[$j].z
            $Vertexs[$j].x = $x * $cosTheta + $z * $sinTheta
            $Vertexs[$j].z = $z * $cosTheta - $x * $sinTheta
        }
    }

    if (ASKS("D")) {
        #rotate around y axis
        for ($j=0; $j -lt $Vertexs.Length; $j++) {
            $x = $Vertexs[$j].x
            $z = $Vertexs[$j].z
            $Vertexs[$j].x = $x * $cosTheta - $z * $sinTheta
            $Vertexs[$j].z = $z * $cosTheta + $x * $sinTheta
        }
    }

    if (ASKS("Q")) {
        #rotate around z axis
        for ($j=0; $j -lt $Vertexs.Length; $j++) {
            $x = $Vertexs[$j].x
            $y = $Vertexs[$j].y
            $Vertexs[$j].x = $x * $cosTheta - $y * $sinTheta
            $Vertexs[$j].y = $x * $sinTheta + $y * $cosTheta
        }
    }

    if (ASKS("E")) {
        #rotate around z axis
        for ($j=0; $j -lt $Vertexs.Length; $j++) {
            $x = $Vertexs[$j].x
            $y = $Vertexs[$j].y
            $Vertexs[$j].x = $x * $cosTheta + $y * $sinTheta
            $Vertexs[$j].y = $y * $cosTheta - $x * $sinTheta
        }
    }

    #scale 

    if (ASKS("Up")) {
        for ($j=0; $j -lt $Vertexs.Length; $j++) {
            $Vertexs[$j].x *= 2
            $Vertexs[$j].y *= 2
            $Vertexs[$j].z *= 2
        }
    }

    if (ASKS("Down")) {
        for ($j=0; $j -lt $Vertexs.Length; $j++) {
            $Vertexs[$j].x *= 0.5
            $Vertexs[$j].y *= 0.5
            $Vertexs[$j].z *= 0.5
        }
    }





    $sw.Stop()
	$tks = $sw.ElapsedTicks
 	$fps = [math]::Round(10000000/$tks)
    [system.console]::title = "Made by: Jh1sc - FPS: $fps"
    [console]::setcursorposition(0,0)
    write-output ($screen -join "`n")
}










