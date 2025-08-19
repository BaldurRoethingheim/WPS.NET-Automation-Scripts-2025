<# Let this program be called from other programs to perform the Mouse Move & Click.
Just one part of task automation PowerShell-Script. #>
param(
[CmdletBinding()]
[int]
$X_pos = [int]50,
[int]
$Y_pos = [int]80,
[int]
$dXX = 0,
[int]
$dYY = 0,
[switch]
$MoveTo = $false,
[switch]
$MoveRel = $false,
[switch]
$LeftClick = $false,
[switch]
$RightClick = $false,
[switch]
$CheckDug = $false,
[switch]
$askPosition = $false
 
)
 
Add-Type -AssemblyName System.Windows.Forms
 
 
<# add read current position -> click at moved to position (task seperation) #>
if (-not ([System.Management.Automation.PSTypeName]'MouseSimulator').Type) {
    <# queries wether type already defined #>
 
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
 
public struct POINT {
    public int X;
    public int Y;
}
 
public class MouseSimulator {
   
    [DllImport("user32.dll")]
    public static extern bool GetCursorPos(out POINT lpPoint);
 
    [DllImport("user32.dll")]
    public static extern bool SetCursorPos(int X, int Y);
 
    [DllImport("user32.dll")]
    public static extern void mouse_event(int dwFlags, int dx, int dy, int dwData, int dwExtraInfo);
 
    public const int MOUSEEVENTF_LEFTDOWN = 0x0002;
    public const int MOUSEEVENTF_LEFTUP = 0x0004;
    public const int MOUSEEVENTF_RIGHTDOWN = 0x0008;
    public const int MOUSEEVENTF_RIGHTUP = 0x0010;
   
    public static void LeftClick(int x, int y) {
        SetCursorPos(x, y);
        mouse_event(MOUSEEVENTF_LEFTDOWN, x, y, 0, 0);
        mouse_event(MOUSEEVENTF_LEFTUP, x, y, 0, 0);
    }
 
    public static void RightClick(int x, int y) {
        SetCursorPos(x, y);
        mouse_event(MOUSEEVENTF_RIGHTDOWN, x, y, 0, 0);
        mouse_event(MOUSEEVENTF_RIGHTUP, x, y, 0, 0);
    }
 
    public static void Move(int x, int y){
        SetCursorPos(x, y);
    }
}
"@
} else {
    if ($CheckDug -eq $true) {
        Write-Output "[MouseSimlator] existiert bereits.`r`n";        
    }
}
 
 
# Aktuelle Cursorposition holen
$point = New-Object POINT
[MouseSimulator]::GetCursorPos([ref]$point) | Out-Null
 
# Bildschirmgröße holen
$screenWidth = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width
$screenHeight = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height
[int]$doubleScreenWidth_int = [int]$screenWidth * 2;
 
# Relative Bewegung (z. B. 50 Pixel nach rechts und 30 nach unten)
$dx = $dXX
$dy = $dYY
 
# Neue Position berechnen
$newX = [Math]::Min([Math]::Max($point.X + $dx, 0), $doubleScreenWidth_int - 1)
$newY = [Math]::Min([Math]::Max($point.Y + $dy, 0), $screenHeight - 1)
 
 
 
function idleLoop {
param (
        <#OptionalParameters#>
    )
    $j = 0;
    for ($i = 0; $i -lt 100; $i++) {
        if ($j -gt 10) {$j=0;}
        if (($i%10) -eq 0) {$j++}
        [MouseSimulator]::Move($X + 5*($i%10), $Y+5*($j))
        Start-Sleep -Seconds 5
    }
}
 
 
function MoveToPosition {
    param (
        [CmdletBinding()]
        [Parameter(Mandatory=$true)]
        $X,
        [CmdletBinding()]
        [Parameter(Mandatory=$true)]
        $Y
    )
    [MouseSimulator]::Move($X, $Y);    
}
function MoveRelative {
    [MouseSimulator]::Move($newX, $newY);    
}
 
 
function askPosition {
    [MouseSimulator]::GetCursorPos([ref]$point) | Out-Null;
    $x = $point.X;
    $y = $point.Y;
   
    Clear-Host
    Write-Output ("Track mouse position`n`n" + "X: " + $x + "`nY: " + $y);
}
 
<# alternative: let the useage of dXX & dYY and X_pos & Y_pos decide. mixture allowed, but too much -> one redundant variable will be ignored #>
<# TODO: Tell what action was performed #>
 
 
if ($MoveTo -eq $true) {
    MoveToPosition -X $X_pos -Y $Y_pos;
} elseif ($MoveRel -eq $true) {
    MoveRelative;
} elseif ($LeftClick -eq $true) {
    <# Action when this condition is true #>
} elseif ($RightClick -eq $true) {
    <# Action when this condition is true #>
}
 
if ($askPosition -eq $true){
    askPosition;
}
 
## a) to position
## b) delta X & delta Y
## 1. Option: just Move
## 2. Option: LeftClick
## 3. Option: RightClick