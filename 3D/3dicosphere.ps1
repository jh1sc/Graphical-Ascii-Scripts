Add-Type -AssemblyName  Microsoft.VisualBasic, PresentationCore, PresentationFramework, System.Drawing, System.Windows.Forms, WindowsBase, WindowsFormsIntegration, System
$ErrorActionPreference = 'SilentlyContinue'

#Console Setup
[int]$nScreenWidth = 200
[int]$nScreenHeight = 100
[string[]]$screen = @(" " * $nScreenWidth) * $nScreenHeight

#buffer and Window Size
$host.UI.RawUI.WindowSize = New-Object Management.Automation.Host.Size(($nScreenWidth), ($nScreenHeight))
$host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size(($nScreenWidth),($nScreenHeight))


function 3dPixelline
{
    param
    (
        # The field of view, in radians
        [Parameter(Mandatory = $true)]
        [float]$Fov,

        # The aspect ratio
        [Parameter(Mandatory = $true)]
        [float]$Aspr,

        # The distance to the near clipping plane
        [Parameter(Mandatory = $true)]
        [float]$Near,

        # The distance to the far clipping plane
        [Parameter(Mandatory = $true)]
        [float]$Far,

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
    $projectionMatrix = [System.Numerics.Matrix4x4]::CreatePerspectiveFieldOfView($Fov, $Aspr, $Near, $Far)
    $point3D = New-Object System.Numerics.Vector3($X, $Y, $Z)
    $point3D1 = New-Object System.Numerics.Vector3($X1, $Y1, $Z1)
    $point2D = [System.Numerics.Vector3]::Transform($point3D, $projectionMatrix)
    $point2D1 = [System.Numerics.Vector3]::Transform($point3D1, $projectionMatrix)

    $x1 = [System.Math]::Round($point2D.X + $nScreenWidth / 2)
    $y1 = [System.Math]::Round($point2D.Y + $nScreenHeight / 2)
    $x2 = [System.Math]::Round($point2D1.X + $nScreenWidth / 2)
    $y2 = [System.Math]::Round($point2D1.Y + $nScreenHeight / 2)

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
        $screen[$y1] = $screen[$y1].substring(0,$x1) + "O" + $screen[$y1].substring($x1+1)
		if (($x1 -eq $x2) -and ($y1 -eq $y2)) {break}
		$e2 = 2 * $err
		if ($e2 -gt -$dy) {$err = $err - $dy; $x1 = $x1 + $sx}
		if ($e2 -lt $dx) {$err = $err + $dx; $y1 = $y1 + $sy}
	}
    
}


function 3dPixel
{
    param
    (
        # The field of view, in radians
        [Parameter(Mandatory = $true)]
        [float]$Fov,

        # The aspect ratio
        [Parameter(Mandatory = $true)]
        [float]$Aspr,

        # The distance to the near clipping plane
        [Parameter(Mandatory = $true)]
        [float]$Near,

        # The distance to the far clipping plane
        [Parameter(Mandatory = $true)]
        [float]$Far,

        # The 3D coordinates
        [Parameter(Mandatory = $true)]
        [float]$X,

        [Parameter(Mandatory = $true)]
        [float]$Y,

        [Parameter(Mandatory = $true)]
        [float]$Z,

        [Parameter(Mandatory = $true)]
        [float]$c
    )
    $projectionMatrix = [System.Numerics.Matrix4x4]::CreatePerspectiveFieldOfView($Fov, $Aspr, $Near, $Far)
    $point3D = New-Object System.Numerics.Vector3($X, $Y, $Z)
    $point2D = [System.Numerics.Vector3]::Transform($point3D, $projectionMatrix)
    $x1 = [System.Math]::Round($point2D.X + $nScreenWidth / 2)
    $y1 = [System.Math]::Round($point2D.Y + $nScreenHeight / 2)
    $screen[$y1] = $screen[$y1].substring(0,$x1) + $c + $screen[$y1].substring($x1+1)

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

#vertexs of a icosaedron
[array[]]$Vertexs = @(
    @(-0.525731, 0.000000, 0.850651),
    @(0.525731, 0.000000, 0.850651),
    @(-0.525731, 0.000000, -0.850651),
    @(0.525731, 0.000000, -0.850651),
    @(0.000000, 0.850651, 0.525731),
    @(0.000000, 0.850651, -0.525731),
    @(0.000000, -0.850651, 0.525731),
    @(0.000000, -0.850651, -0.525731),
    @(0.850651, 0.525731, 0.000000),
    @(-0.850651, 0.525731, 0.000000),
    @(0.850651, -0.525731, 0.000000),
    @(-0.850651, -0.525731, 0.000000)
)
#faces of a icosaedron
[array[]]$Faces = @(
    @(0, 4, 1),
    @(0, 9, 4),
    @(9, 5, 4),
    @(4, 5, 8),
    @(4, 8, 1),
    @(8, 10, 1),
    @(8, 3, 10),
    @(5, 3, 8),
    @(5, 2, 3),
    @(2, 7, 3),
    @(7, 10, 3),
    @(7, 6, 10),
    @(7, 11, 6),
    @(11, 0, 6),
    @(0, 1, 6),
    @(6, 1, 10),
    @(9, 0, 11),
    @(9, 11, 2),
    @(9, 2, 5),
    @(7, 2, 11)
)



    for ($j=0; $j -lt $Vertexs.length; $j++) {
		$Vertexs[$j][0] *= 10
		$Vertexs[$j][1] *= 10
		$Vertexs[$j][2] *= 10
	}
#camera
$Cam3d = New-Object System.Numerics.Vector3(0, 0, 0)

while ($true) {
    $sw = [Diagnostics.Stopwatch]::StartNew()
    #clear screen
    $screen = @(" " * $nScreenWidth) * $nScreenHeight

    # Convert the 3D coordinates to 2D coordinates
    $fov = [System.Math]::PI / 4
    $aspectRatio = $nScreenWidth / $nScreenHeight
    $nearPlaneDistance = 0.1
    $farPlaneDistance = 100
    
    
    #draw faces
    for ($i=0; $i -lt $Faces.length; $i++) {
        $x1 = $Vertexs[$Faces[$i][0]][0] - $Cam3d.X
        $y1 = $Vertexs[$Faces[$i][0]][1] - $Cam3d.Y
        $z1 = $Vertexs[$Faces[$i][0]][2] - $Cam3d.Z
        $x2 = $Vertexs[$Faces[$i][1]][0] - $Cam3d.X
        $y2 = $Vertexs[$Faces[$i][1]][1] - $Cam3d.Y
        $z2 = $Vertexs[$Faces[$i][1]][2] - $Cam3d.Z
        $x3 = $Vertexs[$Faces[$i][2]][0] - $Cam3d.X
        $y3 = $Vertexs[$Faces[$i][2]][1] - $Cam3d.Y
        $z3 = $Vertexs[$Faces[$i][2]][2] - $Cam3d.Z
        3dPixelline $fov $aspectRatio $nearPlaneDistance $farPlaneDistance $x1 $y1 $z1 $x2 $y2 $z2
        3dPixelline $fov $aspectRatio $nearPlaneDistance $farPlaneDistance $x2 $y2 $z2 $x3 $y3 $z3
        3dPixelline $fov $aspectRatio $nearPlaneDistance $farPlaneDistance $x3 $y3 $z3 $x1 $y1 $z1
    }
    #draw vertex points
    for ($i=0; $i -lt $Vertexs.length; $i++) {
        3dPixel $fov $aspectRatio $nearPlaneDistance $farPlaneDistance $Vertexs[0] $Vertexs[1] $Vertexs[2] "@"
    }


    $screen[0] = $screen[0].Substring(0,0) + "CONTROLS:" + $screen[0].Substring(0+1)
    $screen[1] = $screen[1].Substring(0,0) + "W - rotate around x axis(+)" + $screen[1].Substring(0+1)
    $screen[2] = $screen[2].Substring(0,0) + "S - rotate around x axis(-)" + $screen[2].Substring(0+1)

    $screen[3] = $screen[3].Substring(0,0) + "A - rotate around y axis(+)" + $screen[3].Substring(0+1)
    $screen[4] = $screen[4].Substring(0,0) + "D - rotate around y axis(-)" + $screen[4].Substring(0+1)

    $screen[5] = $screen[5].Substring(0,0) + "Q - rotate around z axis(+)" + $screen[5].Substring(0+1)
    $screen[6] = $screen[6].Substring(0,0) + "E - rotate around z axis(-)" + $screen[6].Substring(0+1)

    $screen[7] = $screen[7].Substring(0,0) + "UP arrow - scale(+)" + $screen[7].Substring(0+1)
    $screen[8] = $screen[8].Substring(0,0) + "DOWN arrow - scale(-)" + $screen[8].Substring(0+1)



    #rotation
    $theta = 0.05
    $cosTheta = [System.Math]::Cos($theta)
    $sinTheta = [System.Math]::Sin($theta)

    if (ASKS("W")) {
        #rotate around x axis
        for ($j=0; $j -lt $Vertexs.Length; $j++) {
            $y = $Vertexs[$j][1]
            $z = $Vertexs[$j][2]
            $Vertexs[$j][1] = $y * $cosTheta - $z * $sinTheta
            $Vertexs[$j][2] = $y * $sinTheta + $z * $cosTheta
        }
    }

    if (ASKS("S")) {
        #rotate around x axis
        for ($j=0; $j -lt $Vertexs.Length; $j++) {
            $y = $Vertexs[$j][1]
            $z = $Vertexs[$j][2]
            $Vertexs[$j][1] = $y * $cosTheta + $z * $sinTheta
            $Vertexs[$j][2] = $z * $cosTheta - $y * $sinTheta
        }
    }

    if (ASKS("A")) {
        #rotate around y axis
        for ($j=0; $j -lt $Vertexs.Length; $j++) {
            $x = $Vertexs[$j][0]
            $z = $Vertexs[$j][2]
            $Vertexs[$j][0] = $x * $cosTheta + $z * $sinTheta
            $Vertexs[$j][2] = $z * $cosTheta - $x * $sinTheta
        }
    }

    if (ASKS("D")) {
        #rotate around y axis
        for ($j=0; $j -lt $Vertexs.Length; $j++) {
            $x = $Vertexs[$j][0]
            $z = $Vertexs[$j][2]
            $Vertexs[$j][0] = $x * $cosTheta - $z * $sinTheta
            $Vertexs[$j][2] = $z * $cosTheta + $x * $sinTheta
        }
    }

    if (ASKS("Q")) {
        #rotate around z axis
        for ($j=0; $j -lt $Vertexs.Length; $j++) {
            $x = $Vertexs[$j][0]
            $y = $Vertexs[$j][1]
            $Vertexs[$j][0] = $x * $cosTheta - $y * $sinTheta
            $Vertexs[$j][1] = $x * $sinTheta + $y * $cosTheta
        }
    }

    if (ASKS("E")) {
        #rotate around z axis
        for ($j=0; $j -lt $Vertexs.Length; $j++) {
            $x = $Vertexs[$j][0]
            $y = $Vertexs[$j][1]
            $Vertexs[$j][0] = $x * $cosTheta + $y * $sinTheta
            $Vertexs[$j][1] = $y * $cosTheta - $x * $sinTheta
        }
    }

    #scale 
    if (ASKS("Up")) {
        for ($j=0; $j -lt $Vertexs.Length; $j++) {
            $Vertexs[$j][0] *= 1.01
            $Vertexs[$j][1] *= 1.01
            $Vertexs[$j][2] *= 1.01
        }
    }

    if (ASKS("Down")) {
        for ($j=0; $j -lt $Vertexs.Length; $j++) {
            $Vertexs[$j][0] *= 0.99
            $Vertexs[$j][1] *= 0.99
            $Vertexs[$j][2] *= 0.99
        }
    }




    $sw.Stop()
	$tks = $sw.ElapsedTicks
 	$fps = [math]::Round(10000000/$tks)
    [system.console]::title = "Made by: Jh1sc - FPS: $fps"
    [console]::setcursorposition(0,0)
    write-output ($screen -join "`n")
}










