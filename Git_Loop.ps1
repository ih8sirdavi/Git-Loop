Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Configuration paths
$configPath = Join-Path $PSScriptRoot "config"
$configExamplePath = Join-Path $PSScriptRoot "config.example"
$logsPath = Join-Path $PSScriptRoot "logs"
$configBackupPath = Join-Path $logsPath "config.backup"
Write-Verbose "Looking for configuration at: $configPath"

function Backup-Configuration {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ConfigPath
    )
    
    if (Test-Path $ConfigPath) {
        Write-Verbose "Creating backup of existing configuration..."
        try {
            # Ensure logs directory exists
            if (-not (Test-Path $logsPath)) {
                Write-Verbose "Creating logs directory..."
                New-Item -ItemType Directory -Path $logsPath -Force | Out-Null
            }
            
            Copy-Item -Path $ConfigPath -Destination $configBackupPath -Force
            Write-Verbose "Configuration backup created at: $configBackupPath"
        } catch {
            Write-Warning "Failed to create configuration backup: $_"
        }
    }
}

function Initialize-GitIgnore {
    $gitIgnorePath = Join-Path $PSScriptRoot ".gitignore"
    if (-not (Test-Path $gitIgnorePath)) {
        Write-Verbose "Creating .gitignore file..."
        @"
# Ignore logs directory (includes config.backup)
/logs/

# Ignore main config but not example
/config

# Keep config example
!/config.example

# Ignore Git directory
/.git/
"@ | Set-Content $gitIgnorePath
        Write-Verbose ".gitignore file created"
    }
}

function Initialize-Configuration {
    Write-Verbose "Starting configuration initialization..."
    if (-not (Test-Path $configExamplePath)) {
        Write-Verbose "Configuration example not found at: $configExamplePath"
        throw "Configuration example file not found at: $configExamplePath. Please reinstall Git Loop."
    }
    Write-Verbose "Found configuration example at: $configExamplePath"

    Write-Host "`nWelcome to Git Loop!`n" -ForegroundColor Cyan
    Write-Host "No configuration file found. Let's set up your initial configuration." -ForegroundColor Yellow
    
    # Check SSH key configuration
    Write-Verbose "Checking SSH key configuration..."
    $sshConfigured = Test-GitSshKey
    if (-not $sshConfigured) {
        Write-Host "`nGitHub SSH key not configured!" -ForegroundColor Yellow
        Write-Host "Please follow these steps to set up SSH authentication:" -ForegroundColor White
        Write-Host "1. Generate an SSH key: ssh-keygen -t ed25519 -C 'your_email@example.com'" -ForegroundColor White
        Write-Host "2. Add the key to ssh-agent: ssh-add ~/.ssh/id_ed25519" -ForegroundColor White
        Write-Host "3. Add the public key to GitHub: https://github.com/settings/keys" -ForegroundColor White
        Write-Host "4. Test the connection: ssh -T git@github.com" -ForegroundColor White
        Write-Host "`nPress any key after setting up SSH (or Esc to skip)..." -ForegroundColor Yellow
        
        $key = $Host.UI.RawUI.ReadKey("IncludeKeyDown")
        if ($key.VirtualKeyCode -eq 27) { # Esc key
            Write-Host "`nSkipping SSH setup..." -ForegroundColor Yellow
        } else {
            # Test again after setup
            $sshConfigured = Test-GitSshKey
            if (-not $sshConfigured) {
                Write-Host "`nSSH key still not configured correctly. Please verify your setup." -ForegroundColor Red
                Write-Host "You can continue, but Git operations may fail." -ForegroundColor Yellow
            } else {
                Write-Host "`nSSH key configured successfully!" -ForegroundColor Green
            }
        }
    } else {
        Write-Verbose "SSH key already configured"
    }
    
    # Get GitHub username
    Write-Verbose "Checking for global Git username..."
    $defaultUsername = git config --global user.name
    $username = $null
    $maxRetries = 3
    $retryCount = 0
    
    # First check if we have a default username
    if ($defaultUsername) {
        Write-Verbose "Found global Git username: $defaultUsername"
        Write-Host "`nFound Git username: $defaultUsername" -ForegroundColor Green
        Write-Verbose "Using global Git username"
        $username = $defaultUsername
    } else {
        Write-Verbose "No global Git username found"
        Write-Host "`nNo global Git username found." -ForegroundColor Yellow
    }
    
    # Only enter the retry loop if we don't have a username yet
    if (-not $username) {
        Write-Host "`nUsing default username: $defaultUsername" -ForegroundColor Green
        $username = $defaultUsername
    }
    
    Write-Verbose "Using GitHub username: $username"

    # Load example config
    Write-Verbose "Loading example configuration..."
    $exampleConfig = Get-Content $configExamplePath -Raw | ConvertFrom-Json
    Write-Verbose "Successfully loaded example configuration"
    
    # Update the configuration with user's details
    Write-Verbose "Updating configuration with user details..."
    $currentPath = (Get-Location).Path
    $repoUrl = "git@github.com:$username/Git-Loop.git"
    Write-Verbose "Using repository URL: $repoUrl"
    
    # Check if Git is initialized
    Write-Verbose "Checking Git repository status..."
    $gitDir = Join-Path $currentPath ".git"
    if (-not (Test-Path $gitDir)) {
        Write-Verbose "Git repository not found, initializing..."
        Write-Host "`nInitializing Git repository..." -ForegroundColor Yellow
        
        # Initialize Git repository
        $gitInit = git init 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to initialize Git repository: $gitInit"
            throw "Git initialization failed"
        }
        
        Write-Verbose "Adding remote origin..."
        $gitRemote = git remote add origin $repoUrl 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to add remote: $gitRemote"
            throw "Failed to add Git remote"
        }
    } else {
        Write-Verbose "Git repository already initialized"
        
        # Update remote if it exists
        $remoteExists = git remote get-url origin 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Verbose "Updating existing remote..."
            git remote set-url origin $repoUrl
        } else {
            Write-Verbose "Adding new remote..."
            git remote add origin $repoUrl
        }
    }
    
    # Update example config with actual values
    Write-Verbose "Updating configuration paths and URLs..."
    $exampleConfig.Repositories[0].Path = $currentPath
    $exampleConfig.Repositories[0].RemoteUrl = $repoUrl
    
    # Create the config file
    Write-Verbose "Writing new configuration to: $configPath"
    $exampleConfig | ConvertTo-Json -Depth 10 | Set-Content $configPath
    Write-Verbose "Configuration file created successfully"
    
    Backup-Configuration -ConfigPath $configPath
    
    Initialize-GitIgnore
    
    Write-Host "`nConfiguration created successfully!" -ForegroundColor Green
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Fork the Git Loop repository at: https://github.com/ih8sirdavi/Git-Loop" -ForegroundColor White
    Write-Host "2. After forking, your repository will be available at: https://github.com/$username/Git-Loop" -ForegroundColor White
    Write-Host "3. The script will automatically use SSH for authentication." -ForegroundColor White
    Write-Host "4. You can edit the config file manually to add more repositories." -ForegroundColor White
    Write-Host "`nPress any key to continue..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
    Write-Verbose "Initialization complete"
    return $true
}

function Test-GitSshKey {
    Write-Verbose "Testing SSH key configuration..."
    $testResult = ssh -T git@github.com 2>&1
    return $testResult -like "*successfully authenticated*"
}

if (-not (Test-Path $configPath)) {
    try {
        if (-not (Initialize-Configuration)) {
            exit 1
        }
    } catch {
        Write-Error "Failed to initialize configuration: $_"
        exit 1
    }
} else {
    # Backup existing configuration before loading
    Backup-Configuration -ConfigPath $configPath
    Initialize-GitIgnore
}

try {
    Write-Verbose "Reading configuration file..."
    $config = Get-Content $configPath -Raw | ConvertFrom-Json
    Write-Verbose "Successfully parsed JSON configuration"
    
    # Validate required configuration fields
    Write-Verbose "Validating configuration..."
    $requiredFields = @('Repositories', 'SyncInterval', 'MaxRetries', 'LogRetention', 'LogFile', 'MaxLogSize')
    $missingFields = $requiredFields | Where-Object { -not $config.PSObject.Properties.Name.Contains($_) }
    if ($missingFields) {
        throw "Missing required configuration fields: $($missingFields -join ', ')"
    }

    # Validate repository configurations
    if ($config.Repositories.Count -eq 0) {
        Write-Warning "No repositories configured in config.json"
    }
    
    $config.Repositories | ForEach-Object {
        $repo = $_
        $repoFields = @('Name', 'Path', 'Branch', 'RemoteUrl', 'AutoSync')
        $missingRepoFields = $repoFields | Where-Object { -not $repo.PSObject.Properties.Name.Contains($_) }
        if ($missingRepoFields) {
            throw "Repository '$($repo.Name)' is missing required fields: $($missingRepoFields -join ', ')"
        }
    }
    
    # Convert the JSON object to a PowerShell hashtable for compatibility
    Write-Verbose "Converting configuration to PowerShell hashtable..."
    $config = @{
        Repositories = $config.Repositories | ForEach-Object {
            Write-Verbose "Processing repository: $($_.Name)"
            @{
                Name = $_.Name
                Path = $_.Path
                Branch = $_.Branch
                RemoteUrl = $_.RemoteUrl
                AutoSync = $_.AutoSync
            }
        }
        SyncInterval = $config.SyncInterval
        MaxRetries = $config.MaxRetries
        LogRetention = $config.LogRetention
        LogFile = $config.LogFile
        MaxLogSize = $config.MaxLogSize
    }
    Write-Verbose "Configuration loaded successfully"
    Write-Verbose "Loaded $(($config.Repositories | Measure-Object).Count) repositories"
    Write-Verbose "Sync interval: $($config.SyncInterval) seconds"
} catch {
    Write-Error "Failed to load configuration: $_"
    exit 1
}

# Create logs directory if it doesn't exist
$logsDir = Join-Path $PSScriptRoot "logs"
if (-not (Test-Path $logsDir)) {
    New-Item -ItemType Directory -Path $logsDir | Out-Null
}

# Initialize error logging
$errorLogPath = Join-Path $logsDir "errors.log"
$repoStatusImages = @{
    "Syncing" = [System.Drawing.SystemIcons]::Information
    "Error" = [System.Drawing.SystemIcons]::Error
    "Success" = [System.Drawing.SystemIcons]::Shield
    "Pending" = [System.Drawing.SystemIcons]::Warning
}

# Create image list for repository status
$imageList = New-Object System.Windows.Forms.ImageList
$imageList.ColorDepth = [System.Windows.Forms.ColorDepth]::Depth32Bit
foreach ($status in $repoStatusImages.Keys) {
    $imageList.Images.Add($status, $repoStatusImages[$status])
}

# Theme definitions
$script:themes = @{
    Light = @{
        Background = [System.Drawing.Color]::FromArgb(248, 248, 248)
        TextPrimary = [System.Drawing.Color]::FromArgb(60, 60, 60)
        TextSecondary = [System.Drawing.Color]::FromArgb(120, 120, 120)
        ButtonBackground = [System.Drawing.Color]::FromArgb(240, 240, 240)
        ButtonHover = [System.Drawing.Color]::FromArgb(230, 230, 230)
        ButtonBorder = [System.Drawing.Color]::FromArgb(200, 200, 200)
        Success = [System.Drawing.Color]::FromArgb(40, 167, 69)
        Error = [System.Drawing.Color]::FromArgb(220, 53, 69)
        Warning = [System.Drawing.Color]::FromArgb(255, 193, 7)
    }
    Dark = @{
        Background = [System.Drawing.Color]::FromArgb(30, 30, 30)
        TextPrimary = [System.Drawing.Color]::FromArgb(240, 240, 240)
        TextSecondary = [System.Drawing.Color]::FromArgb(180, 180, 180)
        ButtonBackground = [System.Drawing.Color]::FromArgb(45, 45, 45)
        ButtonHover = [System.Drawing.Color]::FromArgb(60, 60, 60)
        ButtonBorder = [System.Drawing.Color]::FromArgb(70, 70, 70)
        Success = [System.Drawing.Color]::FromArgb(40, 167, 69)
        Error = [System.Drawing.Color]::FromArgb(220, 53, 69)
        Warning = [System.Drawing.Color]::FromArgb(255, 193, 7)
    }
}

# Current theme (default to Light)
$script:currentTheme = "Light"

# Load theme from config if exists
if ($config.Theme) {
    $script:currentTheme = $config.Theme
    Write-Verbose "Loaded theme preference from config: $script:currentTheme"
}

# Create the form with modern styling
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Git Auto-Sync Manager'
$form.Size = New-Object System.Drawing.Size(1000,700)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'Sizable'
$form.MinimumSize = New-Object System.Drawing.Size(800,600)
$form.Font = New-Object System.Drawing.Font("Segoe UI", 9)

# Create main TableLayoutPanel for layout
$mainLayout = New-Object System.Windows.Forms.TableLayoutPanel
$mainLayout.Dock = [System.Windows.Forms.DockStyle]::Fill
$mainLayout.ColumnCount = 2
$mainLayout.RowCount = 2
[void]$mainLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 30)))
[void]$mainLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 70)))
[void]$mainLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 60)))
[void]$mainLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 40)))
$mainLayout.Padding = New-Object System.Windows.Forms.Padding(10)
$form.Controls.Add($mainLayout)

# Create left panel for repository selection
$leftPanel = New-Object System.Windows.Forms.Panel
$leftPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$leftPanel.Padding = New-Object System.Windows.Forms.Padding(5)
[void]$mainLayout.Controls.Add($leftPanel, 0, 0)
[void]$mainLayout.SetRowSpan($leftPanel, 2)

# Create repository GroupBox
$repoGroupBox = New-Object System.Windows.Forms.GroupBox
$repoGroupBox.Text = "Repositories"
$repoGroupBox.Dock = [System.Windows.Forms.DockStyle]::Fill
$repoGroupBox.Font = New-Object System.Drawing.Font("Segoe UI Semibold", 9)
$leftPanel.Controls.Add($repoGroupBox)

# Create repository ListView instead of ListBox
$repoListView = New-Object System.Windows.Forms.ListView
$repoListView.View = [System.Windows.Forms.View]::Details
$repoListView.CheckBoxes = $true
$repoListView.FullRowSelect = $true
$repoListView.GridLines = $false
$repoListView.HeaderStyle = [System.Windows.Forms.ColumnHeaderStyle]::None
$repoListView.Dock = [System.Windows.Forms.DockStyle]::Fill
$repoListView.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$repoListView.SmallImageList = $imageList
$repoGroupBox.Controls.Add($repoListView)

# Add columns
[void]$repoListView.Columns.Add("Name", 200)

# Populate repository ListView
$config.Repositories | ForEach-Object {
    $item = New-Object System.Windows.Forms.ListViewItem($_.Name)
    [void]$repoListView.Items.Add($item)
}

# Handle mouse move for hover effect
$repoListView.Add_MouseMove({
    param($sender, $e)
    $item = $repoListView.GetItemAt($e.X, $e.Y)
    if ($item) {
        Write-Verbose "Hovering over repository: $($item.Text)"
        Update-RepositoryDetails $item.Text
    }
})

# Update sync function to use checked items
function Get-SelectedRepositories {
    $repoListView.Items | Where-Object { $_.Checked } | ForEach-Object { $_.Text }
}

# Enhanced logging function with better error handling
function Log-Message {
    param(
        [string]$message,
        [string]$repository = "",
        [string]$type = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp][$type]"
    if ($repository) {
        $logMessage += "[$repository] "
    }
    $logMessage += " $message"
    
    # Write to log file first
    try {
        $logFile = Join-Path $logsDir $config.LogFile
        Add-Content -Path $logFile -Value $logMessage
    }
    catch {
        Write-Warning "Failed to write to log file: $_"
    }
    
    # Update UI if possible
    Update-UI {
        $statusBox.AppendText("$logMessage`r`n")
        $statusBox.ScrollToCaret()
        $statusLabel.Text = $message
    }
    
    # Always write to verbose stream
    Write-Verbose $logMessage
}

# Enhanced logging function with error handling
function Log-Error {
    param(
        [string]$message,
        [string]$repository = "",
        [System.Management.Automation.ErrorRecord]$errorRecord = $null
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $errorMessage = "[$timestamp][ERROR]"
    if ($repository) {
        $errorMessage += "[$repository] "
    }
    $errorMessage += $message
    
    if ($errorRecord) {
        $errorMessage += "`nException: $($errorRecord.Exception.Message)"
        $errorMessage += "`nStack Trace: $($errorRecord.ScriptStackTrace)"
    }
    
    # Write to error log file
    Add-Content -Path $errorLogPath -Value $errorMessage
    
    # Also log to main log
    Log-Message $message -repository $repository -type "ERROR"
    
    # Update repository status in UI
    if ($repository) {
        Update-RepositoryStatus -repoName $repository -status "Error"
    }
}

# Function to safely update UI
function Update-UI {
    param(
        [Parameter(Mandatory=$true)]
        [scriptblock]$Action
    )
    
    if ($form.IsHandleCreated) {
        try {
            $form.Invoke([Action]{
                & $Action
            })
        }
        catch {
            Write-Warning "Failed to update UI: $_"
        }
    }
}

# Function to show/hide progress
function Show-Progress {
    param([bool]$show)
    Update-UI {
        $progressBar.Visible = $show
    }
}

# Function to update repository status in UI
function Update-RepositoryStatus {
    param(
        [string]$repoName,
        [string]$status  # "Syncing", "Error", "Success", "Pending"
    )
    
    Update-UI {
        $item = $repoListView.Items | Where-Object { $_.Text -eq $repoName }
        if ($item) {
            $item.ImageKey = $status
            
            # Update tooltip with status and last sync time
            $item.ToolTipText = "Status: $status`nLast Sync: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
            
            # Ensure the item is visible
            $item.EnsureVisible()
        }
    }
}

# Retry operation with exponential backoff
function Retry-Operation {
    param(
        [Parameter(Mandatory=$true)]
        [scriptblock]$Operation,
        [string]$OperationName = "Operation",
        [int]$MaxRetries = 3,
        [int]$InitialDelay = 2,
        [string]$Repository = ""
    )
    
    $delay = $InitialDelay
    $retryCount = 0
    $success = $false
    
    do {
        try {
            & $Operation
            $success = $true
            break
        }
        catch {
            $retryCount++
            if ($retryCount -ge $MaxRetries) {
                Log-Error "Failed after $MaxRetries retries: $OperationName" -repository $Repository -errorRecord $_
                throw
            }
            
            Log-Message "Retry $retryCount/$MaxRetries for $OperationName (waiting ${delay}s)" -repository $Repository -type "WARNING"
            Start-Sleep -Seconds $delay
            $delay *= 2  # Exponential backoff
        }
    } while (-not $success -and $retryCount -lt $MaxRetries)
    
    return $success
}

# Create status panel
$statusPanel = New-Object System.Windows.Forms.Panel
$statusPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$statusPanel.Padding = New-Object System.Windows.Forms.Padding(5)
[void]$mainLayout.Controls.Add($statusPanel, 1, 0)

# Create status GroupBox
$statusGroupBox = New-Object System.Windows.Forms.GroupBox
$statusGroupBox.Text = "Sync Status"
$statusGroupBox.Dock = [System.Windows.Forms.DockStyle]::Fill
$statusGroupBox.Font = New-Object System.Drawing.Font("Segoe UI Semibold", 9)
$statusPanel.Controls.Add($statusGroupBox)

# Create status TextBox with modern styling
$statusBox = New-Object System.Windows.Forms.TextBox
$statusBox.Multiline = $true
$statusBox.ScrollBars = 'Vertical'
$statusBox.ReadOnly = $true
$statusBox.Dock = [System.Windows.Forms.DockStyle]::Fill
$statusBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$statusBox.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$statusGroupBox.Controls.Add($statusBox)

# Create details panel
$detailsPanel = New-Object System.Windows.Forms.Panel
$detailsPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$detailsPanel.Padding = New-Object System.Windows.Forms.Padding(5)
[void]$mainLayout.Controls.Add($detailsPanel, 1, 1)

# Create details GroupBox
$detailsGroupBox = New-Object System.Windows.Forms.GroupBox
$detailsGroupBox.Text = "Repository Details"
$detailsGroupBox.Dock = [System.Windows.Forms.DockStyle]::Fill
$detailsGroupBox.Font = New-Object System.Drawing.Font("Segoe UI Semibold", 9)
$detailsPanel.Controls.Add($detailsGroupBox)

# Create details TextBox with modern styling
$detailsBox = New-Object System.Windows.Forms.TextBox
$detailsBox.Multiline = $true
$detailsBox.ScrollBars = 'Vertical'
$detailsBox.ReadOnly = $true
$detailsBox.Dock = [System.Windows.Forms.DockStyle]::Fill
$detailsBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$detailsBox.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$detailsGroupBox.Controls.Add($detailsBox)

# Create button panel
$buttonPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$buttonPanel.Dock = [System.Windows.Forms.DockStyle]::Bottom
$buttonPanel.Height = 40
$buttonPanel.Padding = New-Object System.Windows.Forms.Padding(5)
$buttonPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::LeftToRight
$leftPanel.Controls.Add($buttonPanel)

# Create modern styled buttons
$startButton = New-Object System.Windows.Forms.Button
$startButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$startButton.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$startButton.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(200, 200, 200)
$startButton.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(230, 230, 230)
$startButton.Height = 30
$startButton.UseVisualStyleBackColor = $false
$startButton.Margin = New-Object System.Windows.Forms.Padding(5)
$startButton.Text = 'Start'
$buttonPanel.Controls.Add($startButton)

$stopButton = New-Object System.Windows.Forms.Button
$stopButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$stopButton.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$stopButton.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(200, 200, 200)
$stopButton.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(230, 230, 230)
$stopButton.Height = 30
$stopButton.UseVisualStyleBackColor = $false
$stopButton.Margin = New-Object System.Windows.Forms.Padding(5)
$stopButton.Text = 'Stop'
$stopButton.Enabled = $false
$buttonPanel.Controls.Add($stopButton)

$clearButton = New-Object System.Windows.Forms.Button
$clearButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$clearButton.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$clearButton.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(200, 200, 200)
$clearButton.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(230, 230, 230)
$clearButton.Height = 30
$clearButton.UseVisualStyleBackColor = $false
$clearButton.Margin = New-Object System.Windows.Forms.Padding(5)
$clearButton.Text = 'Clear Log'
$buttonPanel.Controls.Add($clearButton)

# Create status strip
$statusStrip = New-Object System.Windows.Forms.StatusStrip
$statusLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
$statusLabel.Text = "Ready"
$statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$statusStrip.Items.Add($statusLabel)
$form.Controls.Add($statusStrip)

# Create progress bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Height = 2
$progressBar.Dock = [System.Windows.Forms.DockStyle]::Bottom
$progressBar.Style = [System.Windows.Forms.ProgressBarStyle]::Marquee
$progressBar.MarqueeAnimationSpeed = 30
$progressBar.Visible = $false
$form.Controls.Add($progressBar)

# Hashtable to track running jobs
$script:runningJobs = @{}

# Function to start an async operation
function Start-AsyncOperation {
    param(
        [Parameter(Mandatory=$true)]
        [string]$OperationName,
        [Parameter(Mandatory=$true)]
        [string]$RepoName
    )
    
    # Create and start the job with all necessary functions
    $job = Start-Job -ScriptBlock {
        param($repoName, $config, $PSScriptRoot)
        
        # Define all required functions
        function Log-Message {
            param(
                [string]$message,
                [string]$type = "INFO",
                [string]$repository = ""
            )
            
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $logEntry = "[$timestamp][$type]"
            if ($repository) { $logEntry += "[$repository]" }
            $logEntry += " $message"
            
            $logPath = Join-Path $PSScriptRoot "logs\GitLoop.log"
            Add-Content -Path $logPath -Value $logEntry
        }

        function Update-RepositoryStatus {
            param(
                [string]$repoName,
                [string]$status  # "Syncing", "Error", "Success", "Pending"
            )
            Log-Message "Updated status for $repoName to: $status" -type "INFO" -repository $repoName
        }
        
        function Retry-Operation {
            param(
                [Parameter(Mandatory=$true)]
                [scriptblock]$Operation,
                [string]$OperationName = "Operation",
                [int]$MaxRetries = 3,
                [int]$InitialDelay = 2,
                [string]$Repository = ""
            )
            
            $delay = $InitialDelay
            $retryCount = 0
            $success = $false
            
            do {
                try {
                    & $Operation
                    $success = $true
                    break
                }
                catch {
                    $retryCount++
                    if ($retryCount -ge $MaxRetries) {
                        Log-Error "Failed after $MaxRetries retries: $OperationName" -repository $Repository -errorRecord $_
                        throw
                    }
                    
                    Log-Message "Retry $retryCount/$MaxRetries for $OperationName (waiting ${delay}s)" -repository $Repository -type "WARNING"
                    Start-Sleep -Seconds $delay
                    $delay *= 2
                }
            } while (-not $success -and $retryCount -lt $MaxRetries)
            
            return $success
        }
        
        function Sync-GitRepository {
            param([string]$repoName)
            
            $repo = $config.Repositories | Where-Object { $_.Name -eq $repoName }
            if (-not $repo) {
                Log-Error "Repository not found in configuration" -repository $repoName
                return
            }
            
            try {
                Set-Location $repo.Path
                
                # Fetch latest changes
                Retry-Operation -Operation {
                    git fetch origin $repo.Branch
                    if ($LASTEXITCODE -ne 0) {
                        throw "Failed to fetch from remote"
                    }
                } -OperationName "git fetch" -Repository $repoName
                
                # Check for local changes
                $status = git status --porcelain
                if ($status) {
                    # Stage all changes
                    Retry-Operation -Operation {
                        git add -A
                        if ($LASTEXITCODE -ne 0) {
                            throw "Failed to stage changes"
                        }
                    } -OperationName "git add" -Repository $repoName
                    
                    # Commit changes
                    Retry-Operation -Operation {
                        git commit -m "Auto-commit: Local changes"
                        if ($LASTEXITCODE -ne 0) {
                            throw "Failed to commit changes"
                        }
                    } -OperationName "git commit" -Repository $repoName
                }
                
                # Pull changes (with rebase to handle conflicts)
                Retry-Operation -Operation {
                    git pull --rebase origin $repo.Branch
                    if ($LASTEXITCODE -ne 0) {
                        throw "Failed to pull changes"
                    }
                } -OperationName "git pull" -Repository $repoName
                
                # Push our changes if any
                Retry-Operation -Operation {
                    git push origin $repo.Branch
                    if ($LASTEXITCODE -ne 0) {
                        throw "Failed to push changes"
                    }
                } -OperationName "git push" -Repository $repoName
                
                Log-Message "Successfully synced repository" -repository $repoName
            }
            catch {
                Log-Error "Error syncing repository: $_" -repository $repoName -errorRecord $_
                throw
            }
            finally {
                Set-Location $PSScriptRoot
            }
        }
        
        # Run the sync operation
        Sync-GitRepository $repoName
    } -ArgumentList $RepoName, $config, $PSScriptRoot
    
    # Track the job
    $script:runningJobs[$OperationName] = @{
        Job = $job
        StartTime = Get-Date
        Name = $OperationName
    }
    
    Log-Message "Started async operation: $OperationName" -type "INFO"
    Show-Progress $true
    Update-RepositoryStatus -repoName $RepoName -status "Syncing"
    
    # Start monitoring the job
    Start-JobMonitor
}

# Function to show/hide progress
function Show-Progress {
    param([bool]$show)
    Update-UI {
        $progressBar.Visible = $show
    }
}

# Function to monitor jobs
function Start-JobMonitor {
    if ($script:runningJobs.Count -eq 0) {
        Show-Progress $false
        return
    }
    
    $jobsToRemove = @()
    
    foreach ($entry in $script:runningJobs.GetEnumerator()) {
        $job = $entry.Value.Job
        $name = $entry.Value.Name
        $startTime = $entry.Value.StartTime
        $repoName = $name -replace '^(?:Initial )?Sync (.+)$','$1'
        
        if ($job.State -eq 'Completed') {
            try {
                $result = Receive-Job -Job $job -ErrorAction Stop
                Log-Message "Operation completed: $name" -type "INFO"
                Update-RepositoryStatus -repoName $repoName -status "Success"
                Update-RepositoryDetails $repoName
            }
            catch {
                Log-Error "Operation failed: $_" -repository $repoName -errorRecord $_
                Update-RepositoryStatus -repoName $repoName -status "Error"
            }
            finally {
                $jobsToRemove += $entry.Key
                Remove-Job -Job $job
            }
        }
        elseif ($job.State -eq 'Failed') {
            Log-Error "Operation failed" -repository $repoName
            Update-RepositoryStatus -repoName $repoName -status "Error"
            $jobsToRemove += $entry.Key
            Remove-Job -Job $job
        }
        elseif (((Get-Date) - $startTime).TotalMinutes -gt 5) {
            Log-Error "Operation timed out" -repository $repoName
            Update-RepositoryStatus -repoName $repoName -status "Error"
            Stop-Job -Job $job
            Remove-Job -Job $job
            $jobsToRemove += $entry.Key
        }
    }
    
    # Remove completed/failed/timed out jobs
    foreach ($key in $jobsToRemove) {
        $script:runningJobs.Remove($key)
    }
    
    # Hide progress if no jobs are running
    if ($script:runningJobs.Count -eq 0) {
        Show-Progress $false
    }
}

# Timer for periodic sync
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = $config.SyncInterval * 1000  # Convert to milliseconds

# Update status strip with next sync time
function Update-StatusStrip {
    $nextSync = (Get-Date).AddSeconds($config.SyncInterval)
    $statusLabel.Text = "Next sync at: $($nextSync.ToString('HH:mm:ss'))"
}

# Timer tick handler with verbose logging
$timer.Add_Tick({
    $selectedRepos = Get-SelectedRepositories
    foreach ($repo in $selectedRepos) {
        Start-AsyncOperation -OperationName "Sync $repo" -RepoName $repo
    }
})

# Start button click handler with verbose logging
$startButton.Add_Click({
    $selectedRepos = Get-SelectedRepositories
    if ($selectedRepos.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Please select at least one repository to monitor.", "No Repositories Selected", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }
    
    $timer.Start()
    $startButton.Enabled = $false
    $stopButton.Enabled = $true
    Log-Message "Started monitoring selected repositories"
    
    Write-Verbose "Performing initial sync"
    $selectedRepos | ForEach-Object {
        Start-AsyncOperation -OperationName "Initial Sync $_" -RepoName $_
    }
})

# Stop button click handler
$stopButton.Add_Click({
    $timer.Stop()
    $startButton.Enabled = $true
    $stopButton.Enabled = $false
    Log-Message "Stopped monitoring repositories"
})

# Clear button click handler
$clearButton.Add_Click({
    $statusBox.Clear()
    $statusLabel.Text = "Log cleared"
})

# Form closing handler
$form.Add_FormClosing({
    if ($timer) {
        $timer.Stop()
        $timer.Dispose()
    }
})

# Create tooltips
$tooltips = New-Object System.Windows.Forms.ToolTip
$tooltips.InitialDelay = 200
$tooltips.ReshowDelay = 100
$tooltips.AutoPopDelay = 5000
$tooltips.ShowAlways = $true

# Add tooltips to controls
$tooltips.SetToolTip($startButton, "Start monitoring selected repositories")
$tooltips.SetToolTip($stopButton, "Stop monitoring repositories")
$tooltips.SetToolTip($repoListView, "Select repositories to monitor. Hover over names to see details.")
$tooltips.SetToolTip($statusBox, "Operation log and status messages")
$tooltips.SetToolTip($detailsBox, "Detailed repository information")

# Add tooltips to repository items
$config.Repositories | ForEach-Object {
    $tooltipText = @"
Repository: $($_.Name)
Path: $($_.Path)
Branch: $($_.Branch)
Remote: $($_.RemoteUrl)
"@
    $tooltips.SetToolTip($repoListView, $tooltipText)
}

# Theme button
$themeButton = New-Object System.Windows.Forms.Button
$themeButton.Text = " Toggle Theme"
$themeButton.Width = 120
$themeButton.Height = 30
$themeButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$themeButton.Add_Click({ Switch-Theme })
$buttonPanel.Controls.Add($themeButton)

# Function to toggle theme
function Switch-Theme {
    $script:currentTheme = if ($script:currentTheme -eq "Light") { "Dark" } else { "Light" }
    $theme = $script:themes[$script:currentTheme]
    
    Write-Verbose "Switching to $script:currentTheme theme"
    
    # Update form
    $form.BackColor = $theme.Background
    $form.ForeColor = $theme.TextPrimary
    
    # Update repository list
    $repoListView.BackColor = $theme.Background
    $repoListView.ForeColor = $theme.TextPrimary
    
    # Update details box
    $detailsBox.BackColor = $theme.Background
    $detailsBox.ForeColor = $theme.TextPrimary
    
    # Update status box
    $statusBox.BackColor = $theme.Background
    $statusBox.ForeColor = $theme.TextPrimary
    
    # Update buttons
    $startButton.BackColor = $theme.ButtonBackground
    $startButton.ForeColor = $theme.TextPrimary
    $startButton.FlatAppearance.BorderColor = $theme.ButtonBorder
    $startButton.FlatAppearance.MouseOverBackColor = $theme.ButtonHover
    
    $stopButton.BackColor = $theme.ButtonBackground
    $stopButton.ForeColor = $theme.TextPrimary
    $stopButton.FlatAppearance.BorderColor = $theme.ButtonBorder
    $stopButton.FlatAppearance.MouseOverBackColor = $theme.ButtonHover
    
    $clearButton.BackColor = $theme.ButtonBackground
    $clearButton.ForeColor = $theme.TextPrimary
    $clearButton.FlatAppearance.BorderColor = $theme.ButtonBorder
    $clearButton.FlatAppearance.MouseOverBackColor = $theme.ButtonHover
    
    $themeButton.BackColor = $theme.ButtonBackground
    $themeButton.ForeColor = $theme.TextPrimary
    $themeButton.FlatAppearance.BorderColor = $theme.ButtonBorder
    $themeButton.FlatAppearance.MouseOverBackColor = $theme.ButtonHover
    
    # Update status strip
    $statusStrip.BackColor = $theme.Background
    $statusLabel.ForeColor = $theme.TextSecondary
    
    # Save theme preference
    $config | Add-Member -NotePropertyName "Theme" -NotePropertyValue $script:currentTheme -Force
    $config | ConvertTo-Json -Depth 10 | Set-Content $configPath
    Write-Verbose "Theme preference saved to config"
}

# Apply initial theme
$theme = $script:themes[$script:currentTheme]
Write-Verbose "Applying initial theme: $script:currentTheme"

# Apply theme to form
$form.BackColor = $theme.Background
$form.ForeColor = $theme.TextPrimary

# Apply theme to repository list
$repoListView.BackColor = $theme.Background
$repoListView.ForeColor = $theme.TextPrimary

# Apply theme to details box
$detailsBox.BackColor = $theme.Background
$detailsBox.ForeColor = $theme.TextPrimary

# Apply theme to status box
$statusBox.BackColor = $theme.Background
$statusBox.ForeColor = $theme.TextPrimary

# Apply theme to buttons
$startButton.BackColor = $theme.ButtonBackground
$startButton.ForeColor = $theme.TextPrimary
$startButton.FlatAppearance.BorderColor = $theme.ButtonBorder
$startButton.FlatAppearance.MouseOverBackColor = $theme.ButtonHover

$stopButton.BackColor = $theme.ButtonBackground
$stopButton.ForeColor = $theme.TextPrimary
$stopButton.FlatAppearance.BorderColor = $theme.ButtonBorder
$stopButton.FlatAppearance.MouseOverBackColor = $theme.ButtonHover

$clearButton.BackColor = $theme.ButtonBackground
$clearButton.ForeColor = $theme.TextPrimary
$clearButton.FlatAppearance.BorderColor = $theme.ButtonBorder
$clearButton.FlatAppearance.MouseOverBackColor = $theme.ButtonHover

$themeButton.BackColor = $theme.ButtonBackground
$themeButton.ForeColor = $theme.TextPrimary
$themeButton.FlatAppearance.BorderColor = $theme.ButtonBorder
$themeButton.FlatAppearance.MouseOverBackColor = $theme.ButtonHover

# Apply theme to status strip
$statusStrip.BackColor = $theme.Background
$statusLabel.ForeColor = $theme.TextSecondary

# Function to update repository details with better formatting
function Update-RepositoryDetails {
    param(
        [Parameter(Mandatory=$true)]
        [string]$repoName
    )
    
    Write-Verbose "Starting repository details update for $repoName"
    
    try {
        $repoConfig = $config.Repositories | Where-Object { $_.Name -eq $repoName }
        if (-not $repoConfig) { 
            Write-Verbose "Repository configuration not found for $repoName"
            return 
        }

        Write-Verbose "Changing directory to $($repoConfig.Path)"
        Push-Location $repoConfig.Path

        # Get repository status with verbose logging
        Write-Verbose "Fetching git status for $repoName"
        $status = git status --porcelain
        
        Write-Verbose "Getting branch information"
        $branch = git rev-parse --abbrev-ref HEAD 2>$null
        if ($LASTEXITCODE -ne 0) { Write-Verbose "Failed to get branch name" }
        
        Write-Verbose "Calculating ahead/behind commits"
        $ahead = git rev-list origin/$branch..HEAD --count 2>$null
        if ($LASTEXITCODE -ne 0) { Write-Verbose "Failed to calculate ahead commits" }
        
        $behind = git rev-list HEAD..origin/$branch --count 2>$null
        if ($LASTEXITCODE -ne 0) { Write-Verbose "Failed to calculate behind commits" }
        
        Write-Verbose "Getting last commit"
        $lastCommit = git log -1 --format="%h - %s [%ar]" 2>$null
        if ($LASTEXITCODE -ne 0) { Write-Verbose "Failed to get last commit" }
        
        Write-Verbose "Getting remote URL"
        $remoteUrl = git config --get remote.origin.url 2>$null
        if ($LASTEXITCODE -ne 0) { Write-Verbose "Failed to get remote URL" }

        # Build details string with safe characters
        Write-Verbose "Building details string"
        $details = [System.Text.StringBuilder]::new()
        [void]$details.AppendLine("[Repository] $repoName")
        [void]$details.AppendLine("[Remote] $remoteUrl")
        [void]$details.AppendLine("[Branch] $branch")
        [void]$details.AppendLine("")
        [void]$details.AppendLine("Status:")
        [void]$details.AppendLine("  * Ahead by: $ahead commit(s)")
        [void]$details.AppendLine("  * Behind by: $behind commit(s)")
        [void]$details.AppendLine("")
        [void]$details.AppendLine("Last Commit:")
        [void]$details.AppendLine("  $lastCommit")
        
        if ($status) {
            Write-Verbose "Adding working tree changes"
            [void]$details.AppendLine("")
            [void]$details.AppendLine("Working Tree Changes:")
            $status -split "`n" | Where-Object { $_ } | ForEach-Object {
                [void]$details.AppendLine("  $($_)")
            }
        }

        Write-Verbose "Updating details box text"
        Update-UI {
            $detailsBox.Text = $details.ToString()
        }
    }
    catch {
        $errorMessage = "Unable to fetch repository details: $_"
        Write-Verbose "Error in Update-RepositoryDetails: $errorMessage"
        Update-UI {
            $detailsBox.Text = $errorMessage
        }
    }
    finally {
        Pop-Location
        Write-Verbose "Finished updating repository details for $repoName"
    }
}

# Check dependencies before starting
function Test-Dependencies {
    Write-Verbose "Checking dependencies..."
    
    # Check Git installation
    try {
        $gitVersion = git --version
        Write-Verbose "Git version: $gitVersion"
    }
    catch {
        $errorMessage = "Git is not installed or not in PATH. Please install Git and try again."
        [System.Windows.Forms.MessageBox]::Show($errorMessage, "Missing Dependency", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return $false
    }
    
    # Check .NET Framework version
    $netVersion = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").Release
    if ($netVersion -lt 378389) {  # .NET 4.5 minimum
        $errorMessage = ".NET Framework 4.5 or later is required. Please update .NET Framework and try again."
        [System.Windows.Forms.MessageBox]::Show($errorMessage, "Missing Dependency", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return $false
    }
    
    # Validate repository configurations
    $invalidRepos = @()
    foreach ($repo in $config.Repositories) {
        if (-not (Test-Path $repo.Path)) {
            $invalidRepos += "$($repo.Name) (Invalid Path: $($repo.Path))"
            continue
        }
        
        Push-Location $repo.Path
        try {
            # Check if it's a git repository
            $null = git rev-parse --git-dir 2>&1
            if ($LASTEXITCODE -ne 0) {
                $invalidRepos += "$($repo.Name) (Not a Git repository)"
                continue
            }
            
            # Check if remote exists
            $remotes = git remote -v
            if (-not ($remotes -match "origin")) {
                $invalidRepos += "$($repo.Name) (No 'origin' remote)"
                continue
            }
            
            # Check if branch exists
            $branches = git branch
            if (-not ($branches -match $repo.Branch)) {
                $invalidRepos += "$($repo.Name) (Branch '$($repo.Branch)' not found)"
            }
        }
        finally {
            Pop-Location
        }
    }
    
    if ($invalidRepos.Count -gt 0) {
        $errorMessage = "The following repositories have configuration issues:`n`n" + ($invalidRepos -join "`n")
        [System.Windows.Forms.MessageBox]::Show($errorMessage, "Repository Configuration Issues", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    }
    
    Write-Verbose "Dependency check complete"
    return $true
}

# Add dependency check before showing form
if (-not (Test-Dependencies)) {
    exit 1
}

# Show form
$form.ShowDialog()
