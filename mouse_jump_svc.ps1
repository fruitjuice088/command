$ErrorActionPreference = "Stop"

Add-Type @"
    using System;
    using System.Runtime.InteropServices;

    public class User32 {
        [DllImport("user32.dll")]
        public static extern IntPtr GetForegroundWindow();

        [DllImport("user32.dll")]
        public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

        [DllImport("user32.dll")]
        public static extern void SetCursorPos(int X, int Y);

        [DllImport("user32.dll")]
        public static extern short GetAsyncKeyState(int vKey);
    }

    public struct RECT {
        public int Left;
        public int Top;
        public int Right;
        public int Bottom;
    }
"@

Add-Type -AssemblyName System.Windows.Forms

$TIMER_INTERVAL = 100
$MUTEX_NAME = "Global/mutex"  # Avoid multiple instances

$KEY_F24 = 0x87

function timer_function($notify) {
    if ([User32]::GetAsyncKeyState($KEY_F24) -ne 0) {
        $handle = [User32]::GetForegroundWindow()
        $rect = New-Object RECT
        if ([User32]::GetWindowRect($handle, [ref]$rect)) {
            [User32]::SetCursorPos(($rect.Left + $rect.Right) / 2, $rect.Top + 15)
        }
    }
}

function cleanUp() {
    param(
        [System.Windows.Forms.Timer] $timer,
        [System.Windows.Forms.NotifyIcon] $notifyIcon,
        [System.Threading.Mutex] $mutex
    )
    $timer.Stop()
    $notifyIcon.Visible = $false
    $mutex.ReleaseMutex()
    $mutex.Close()
    [System.Windows.Forms.Application]::Exit()
}

function main() {
    $mutex = New-Object System.Threading.Mutex($false, $MUTEX_NAME)
    if (-not $mutex.WaitOne(0, $false)) {
        Write-Host "An instance of this app is already running."
        $mutex.Close()
        return
    }
    $windowCode = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
    $asyncWindow = Add-Type -MemberDefinition $windowCode -Name Win32ShowWindowAsync -Namespace Win32Functions -PassThru
    $null = $asyncWindow::ShowWindowAsync((Get-Process -PID $pid).MainWindowHandle, 0)

    $appContext = New-Object System.Windows.Forms.ApplicationContext
    $timer = New-Object Windows.Forms.Timer
    $path = Get-Process -id $pid | Select-Object -ExpandProperty Path  # for Icon
    $icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)

    # Task tray icon
    $notifyIcon = New-Object System.Windows.Forms.NotifyIcon
    $notifyIcon.Icon = $icon
    $notifyIcon.Visible = $true
    $notifyIcon.Text = "Press F24 to let mouse to jump to active window!"

    # Icon click event
    $notifyIcon.add_click({
        if ($_.Button -eq [Windows.Forms.MouseButtons]::Left) {
            # Execute event defined in timer
            $timer.Stop()
            $timer.Interval = 1
            $timer.Start()
        }
    })

    # Menu
    $menuItemExit = New-Object System.Windows.Forms.ToolStripMenuItem
    $menuItemExit.Text = "Exit"
    $notifyIcon.ContextMenuStrip = New-Object System.Windows.Forms.ContextMenuStrip
    $notifyIcon.ContextMenuStrip.Items.AddRange($menuItemExit)

    # Exit buton click event
    $menuItemExit.add_Click({
        $appContext.ExitThread()
    })

    # Timer event
    $timer.Enabled = $true
    $timer.Add_Tick({
        $timer.Stop()
        timer_function($notifyIcon)

        # Restart with setting interval
        $timer.Interval = $TIMER_INTERVAL
        $timer.Start()
    })

    $timer.Interval = 1
    $timer.Start()

    [void][System.Windows.Forms.Application]::Run($appContext)

    cleanUp -timer $timer -notifyIcon $notifyIcon -mutex $mutex
    $mutex.Close()
}

main
