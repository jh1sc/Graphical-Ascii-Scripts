#Fluid simulation in Powershell
$ErrorActionPreference = 'SilentlyContinue'
#Importing Asseblies
Add-Type -AssemblyName  Microsoft.VisualBasic, PresentationCore, PresentationFramework, System.Drawing, System.Windows.Forms, WindowsBase, WindowsFormsIntegration, System
#Console Setup
[int]$nScreenWidth = 40
[int]$nScreenHeight = 40
[string[]]$screen = @(" " * $nScreenWidth) * $nScreenHeight
#buffer and Window Size
$host.UI.RawUI.WindowSize = New-Object Management.Automation.Host.Size(($nScreenWidth), ($nScreenHeight))
$host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size(($nScreenWidth),($nScreenHeight))

function Write-Console {
    param ([string]$String)
	[console]::setcursorposition(0,0)
	$Bytes = $String.ToCharArray() -as [byte[]]
	$OutStream = [console]::OpenStandardOutput()
	$OutStream.Write($Bytes,0,$Bytes.Length)
}

function Pixel {
    param(
        [double]$x,
        [double]$y,
        [string]$o
    )
    #cartesian to screen coordinates
    $screen[$y] = $screen[$y].substring(0,$x) + $o + $screen[$y].substring($x+1)
}

#defining vars such its like a water
$gravity = 1
$pressure = 4
$viscosity = 7
$friction = 1
$density = 2
$dt = 0.1

$particle = @()
$square = 10
for ($i = 0; $i -lt $square; $i++) {
    for ($j = 0; $j -lt $square; $j++) {
        $particle += [pscustomobject]@{
            x = $i * 2
            y = $j * 2
            vx = 4
            vy = 4
            density = $density
            pressure = $pressure 
            fx = 3
            fy = 3
        }
    }
}

[array]$aLTfps = @()

#Fluid Simulation
while($true) {
    $sw = [Diagnostics.Stopwatch]::StartNew()
    $screen = @(" " * $nScreenWidth) * $nScreenHeight


    #update particles
    foreach ($p in $particle) {
        #calculate density
        $p.density = 0
        foreach ($p2 in $particle) {
            $dx = $p.x - $p2.x
            $dy = $p.y - $p2.y
            $dist = [Math]::Sqrt($dx*$dx + $dy*$dy)
            if ($dist -lt 2) {
                $p.density += (2 - $dist) * (2 - $dist)
            }
        }
        #calculate pressure
        $p.pressure = $pressure * ($p.density - 1)
    }

    #update forces
    foreach ($p in $particle) {
        $p.fx = 0
        $p.fy = 0
        foreach ($p2 in $particle) {
            $dx = $p.x - $p2.x
            $dy = $p.y - $p2.y
            $dist = [Math]::Sqrt($dx*$dx + $dy*$dy)
            if ($dist -lt 2) {
                #pressure force
                $p.fx += $dx * ($p.pressure + $p2.pressure) / (2 * $p2.density) * (2 - $dist)
                $p.fy += $dy * ($p.pressure + $p2.pressure) / (2 * $p2.density) * (2 - $dist)
                #viscosity force
                $p.fx += $viscosity * ($p2.vx - $p.vx) / $p2.density * (2 - $dist)
                $p.fy += $viscosity * ($p2.vy - $p.vy) / $p2.density * (2 - $dist)
                #hooks law
                $p.fx += $dx * 0.1 * (2 - $dist)
                $p.fy += $dy * 0.1 * (2 - $dist)
            }
        }
        #gravity force
        $p.fy += $gravity * $p.density
        #friction force
        $p.fx += $friction * $p.vx
        $p.fy += $friction * $p.vy
    }


    #update velocities
    foreach ($p in $particle) {
        $p.vx += $p.fx * $dt
        $p.vy += $p.fy * $dt
    }

    #update positions
    foreach ($p in $particle) { 
        #collision detection and bouce off walls with angular velocity and friction
        if ($p.x -lt 1) {
            $p.x = 1
            $p.vx = -$p.vx * 0.1
            $p.fy = 0
        }
        if ($p.x -gt $nScreenWidth - 2) {
            $p.x = $nScreenWidth - 6
            $p.vx = -$p.vx * 0.1
            $p.fy = 0
        }
        if ($p.y -lt 1) {
            $p.y = 1
            $p.vy = -$p.vy * 0.1 
            $p.fy = 0
        }
        if ($p.y -gt $nScreenHeight - 2) {
            $p.y = $nScreenHeight - 1
            $p.vy = -$p.vy * 0.1
            $p.fy = 0
        }

        

        


        #collison of particles
        foreach ($p2 in $particle) {
            $dx = $p.x - $p2.x
            $dy = $p.y - $p2.y
            $dist = [Math]::Sqrt($dx*$dx + $dy*$dy)
            if ($dist -lt 1) {
                $p.fx = -$p.vx * 0.1 
                $p.fy = -$p.vy * 0.1
            }
        }


        #update position
        $p.x += $p.vx
        $p.y += $p.vy
    }

    
    #display particles
    foreach ($p in $particle) {
        Pixel $p.x $p.y "#"
    }
    


    [console]::setcursorposition(0,0)
    Write-output ($screen -join "`n")
    sleep -Milliseconds 10
    $sw.Stop()
	$ms = $sw.ElapsedTicks
	$fps = (10000000/$ms)
    $aLTfps += $fps
	$LifeTimeFPS = [math]::round(($aLTfps | Measure-Object -Average).Average )
	$host.UI.RawUI.WindowTitle = "3d Projection - FPS: $fps - LifetimeFPS: $LifeTimeFPS"
}