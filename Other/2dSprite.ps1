$ErrorActionPreference = 'SilentlyContinue'


#Importing Asseblies
Add-Type -AssemblyName  Microsoft.VisualBasic, PresentationCore, PresentationFramework, System.Drawing, System.Windows.Forms, WindowsBase, WindowsFormsIntegration, System




#Console Setup
[int]$nScreenWidth = 100
[int]$nScreenHeight = 100
$host.UI.RawUI.WindowSize = New-Object Management.Automation.Host.Size(($nScreenWidth), ($nScreenHeight))
$host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size(($nScreenWidth),($nScreenHeight))
[string[]]$screen = @(" " * $nScreenWidth) * $nScreenHeight



#functions

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

#draw function
function draw{
    param ([int]$x, [int]$y, [array[]]$spr, [bool]$SPRORNOT)
    if ($SPRORNOT) {
		if ($x -lt 0) {$x = 0}
		if ($y -lt 0) {$y = 0}
		if ($x -gt $nScreenWidth) {$x = $nScreenWidth}
		if ($y -gt $nScreenHeight) {$y = $nScreenHeight}
        for ($i=0; $i -lt $spr.length; $i++) {
            for ($j=0; $j -lt $spr[$i].length; $j++) {
                $screen[$y+$i] = $screen[$y+$i].Remove($x+$j,1)
                $screen[$y+$i] = $screen[$y+$i].Insert($x+$j,$spr[$i][$j])
            }
        }
    
    }
    else {
        #display char on screen
        $screen[$y] = $screen[$y].Remove($x,1)
        $screen[$y] = $screen[$y].Insert($x,$char)
    }
}
function velocity {
	param ([int]$x, [int]$y, [int]$friction, [int]$speed, [int]$angle)
	#acceleration
	$ax = [math]::cos($angle) * $speed
	$ay = [math]::sin($angle) * $speed
	#velocity
	$vx = $ax - $friction
	$vy = $ay - $friction
	#position
	$px = $x + $vx
	$py = $y + $vy
	return $px, $py
}
function display {
    param ([string]$String)
	[console]::setcursorposition(0,0)
	$Bytes = $String.ToCharArray() -as [byte[]]
	$OutStream = [console]::OpenStandardOutput()
	$OutStream.Write($Bytes,0,$Bytes.Length)
}
function 2dline {
	param ([int]$x1, [int]$y1, [int]$x2, [int]$y2, [string]$char)
	$dx = $x2 - $x1
	$dy = $y2 - $y1
	$steps = [math]::Max([math]::Abs($dx),[math]::Abs($dy))
	$xinc = $dx / $steps
	$yinc = $dy / $steps
	$x = $x1
	$y = $y1
	for ($i=0; $i -le $steps; $i++) {
		draw $x $y $char
		$x += $xinc
		$y += $yinc
	}
}
function title{param([string]$title);$host.ui.rawui.windowtitle = $title}
function DrawTriangle {
	param ([int]$x1, [int]$y1, [int]$x2, [int]$y2, [int]$x3, [int]$y3)
	2dline $x1 $y1 $x2 $y2
	2dline $x2 $y2 $x3 $y3
	2dline $x3 $y3 $x1 $y1
}

#Sprites
#player
$p_idle = 
@(
("/---\")
("|0>0|")
("\---/")
(" |||")
("/|||\")
(" |||")
(" / \")
)

#enviroment
$e_grass = @("_" * $nScreenWidth) 

#gameloop
$wspeed = 1
while ($true) {
    #clear screen
    $screen = @(" " * $nScreenWidth) * $nScreenHeight
    if ((ASKS W) -ne "0") {$py -= $wspeed}
    if ((ASKS S) -ne "0") {$py += $wspeed}
    if ((ASKS A) -ne "0") {$px -= $wspeed}
    if ((ASKS D) -ne "0") {$px += $wspeed}


	#enviroment stuff
	Draw 0 99 $e_grass $true
	






	#player stuff
    Draw $px $py $p_idle $true

	#collision stuff
	if ($px -lt 0) {$px = 0}
	if ($py -lt 0) {$py = 0}
	if ($px -gt $nScreenWidth) {$px = $nScreenWidth}
	if ($py -gt $nScreenHeight) {$py = $nScreenHeight}

	#collison with enviroment
	if ($screen[$py] -eq "_") {$py = $py - 1}


	





	
    title "PX: $px PY: $py ANGLE: $angle"
    display ($screen -join "`n")
}



