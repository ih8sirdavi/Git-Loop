Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Configuration
$config = @{
    Repositories = @(
        @{
            Name = "Masterlogs"
            Path = "D:\Projects\Masterlogs"
            Branch = "main"
            RemoteUrl = "git@github.com:ih8sirdavi/Masterlogs.git"
            AutoSync = $true
        },
        @{
            Name = "ANF"
            Path = "D:\Projects\ANF"
            Branch = "main"
            RemoteUrl = "git@github.com:ih8sirdavi/ANF.git"
            AutoSync = $true
        }
    )
    SyncInterval = 30     # Seconds between sync checks
    MaxRetries = 3        # Maximum retry attempts
    LogRetention = 100    # Maximum log entries to retain
    LogFile = "GitLoop.log"  # Log file name
    MaxLogSize = 5MB      # Maximum log file size before rotation
}

# Create logs directory if it doesn't exist
$logsDir = Join-Path $PSScriptRoot "logs"
if (-not (Test-Path $logsDir)) {
    New-Item -ItemType Directory -Path $logsDir | Out-Null
}

# Modern UI Colors
$colors = @{
    Background = [System.Drawing.Color]::FromArgb(248, 248, 248)
    ButtonBackground = [System.Drawing.Color]::FromArgb(240, 240, 240)
    ButtonHover = [System.Drawing.Color]::FromArgb(230, 230, 230)
    ButtonBorder = [System.Drawing.Color]::FromArgb(210, 210, 210)
    TextPrimary = [System.Drawing.Color]::FromArgb(60, 60, 60)
    TextSecondary = [System.Drawing.Color]::FromArgb(120, 120, 120)
    StatusBar = [System.Drawing.Color]::FromArgb(245, 245, 245)
    LogBackground = [System.Drawing.Color]::White
    SelectedItem = [System.Drawing.Color]::FromArgb(220, 220, 220)
}

# Create the form with modern styling
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Git Auto-Sync Manager'
$form.Size = New-Object System.Drawing.Size(1000,700)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'Sizable'
$form.MinimumSize = New-Object System.Drawing.Size(800,600)
$form.BackColor = $colors.Background
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
$repoListView.BackColor = $colors.LogBackground
$repoListView.ForeColor = $colors.TextPrimary
$repoListView.BorderStyle = [System.Windows.Forms.BorderStyle]::None
$repoListView.HoverSelection = $true

# Add columns
[void]$repoListView.Columns.Add("Name", 200)
$repoGroupBox.Controls.Add($repoListView)

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
$statusBox.BackColor = $colors.LogBackground
$statusBox.ForeColor = $colors.TextPrimary
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
$detailsBox.BackColor = $colors.LogBackground
$detailsBox.ForeColor = $colors.TextPrimary
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
$startButton.BackColor = $colors.ButtonBackground
$startButton.ForeColor = $colors.TextPrimary
$startButton.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$startButton.FlatAppearance.BorderColor = $colors.ButtonBorder
$startButton.FlatAppearance.MouseOverBackColor = $colors.ButtonHover
$startButton.Height = 30
$startButton.UseVisualStyleBackColor = $false
$startButton.Margin = New-Object System.Windows.Forms.Padding(5)
$startButton.Text = 'Start'
$buttonPanel.Controls.Add($startButton)

$stopButton = New-Object System.Windows.Forms.Button
$stopButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$stopButton.BackColor = [System.Drawing.Color]::FromArgb(200,0,0)
$stopButton.ForeColor = $colors.TextPrimary
$stopButton.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$stopButton.FlatAppearance.BorderColor = $colors.ButtonBorder
$stopButton.FlatAppearance.MouseOverBackColor = $colors.ButtonHover
$stopButton.Height = 30
$stopButton.UseVisualStyleBackColor = $false
$stopButton.Margin = New-Object System.Windows.Forms.Padding(5)
$stopButton.Text = 'Stop'
$stopButton.Enabled = $false
$buttonPanel.Controls.Add($stopButton)

$clearButton = New-Object System.Windows.Forms.Button
$clearButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$clearButton.BackColor = [System.Drawing.Color]::FromArgb(100,100,100)
$clearButton.ForeColor = $colors.TextPrimary
$clearButton.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$clearButton.FlatAppearance.BorderColor = $colors.ButtonBorder
$clearButton.FlatAppearance.MouseOverBackColor = $colors.ButtonHover
$clearButton.Height = 30
$clearButton.UseVisualStyleBackColor = $false
$clearButton.Margin = New-Object System.Windows.Forms.Padding(5)
$clearButton.Text = 'Clear Log'
$buttonPanel.Controls.Add($clearButton)

# Create status strip
$statusStrip = New-Object System.Windows.Forms.StatusStrip
$statusLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
$statusLabel.Text = "Ready"
$statusLabel.ForeColor = $colors.TextSecondary
$statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$statusStrip.Items.Add($statusLabel)
$statusStrip.BackColor = $colors.StatusBar
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
                [string]$repository = "",
                [string]$type = "INFO"
            )
            Write-Host "[$type][$repository] $message"
        }
        
        function Sync-GitRepository {
            param([string]$repoName)
            
            $repo = $config.Repositories | Where-Object { $_.Name -eq $repoName }
            if (-not $repo) {
                Log-Message "Repository $repoName not found in configuration" -type "ERROR"
                return
            }
            
            try {
                Set-Location $repo.Path
                
                # Fetch latest changes
                git fetch origin $repo.Branch
                if ($LASTEXITCODE -ne 0) {
                    throw "Failed to fetch from remote"
                }
                
                # Check for local changes
                $status = git status --porcelain
                if ($status) {
                    # Stage all changes
                    git add -A
                    if ($LASTEXITCODE -ne 0) {
                        throw "Failed to stage changes"
                    }
                    
                    # Commit changes
                    git commit -m "Auto-commit: Local changes"
                    if ($LASTEXITCODE -ne 0) {
                        throw "Failed to commit changes"
                    }
                }
                
                # Pull changes (with rebase to handle conflicts)
                git pull --rebase origin $repo.Branch
                if ($LASTEXITCODE -ne 0) {
                    throw "Failed to pull changes"
                }
                
                # Push our changes if any
                git push origin $repo.Branch
                if ($LASTEXITCODE -ne 0) {
                    throw "Failed to push changes"
                }
                
                Log-Message "Successfully synced repository" -repository $repoName
            }
            catch {
                Log-Message "Error syncing repository: $_" -repository $repoName -type "ERROR"
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
        
        if ($job.State -eq 'Completed') {
            $result = Receive-Job -Job $job
            Log-Message "Operation completed: $name" -type "INFO"
            $jobsToRemove += $entry.Key
            Remove-Job -Job $job
        }
        elseif ($job.State -eq 'Failed') {
            Log-Message "Operation failed: $name" -type "ERROR"
            $jobsToRemove += $entry.Key
            Remove-Job -Job $job
        }
        elseif (((Get-Date) - $startTime).TotalMinutes -gt 5) {
            Log-Message "Operation timed out: $name" -type "WARNING"
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
        Set-Location $repoConfig.Path

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
        Write-Verbose "Finished updating repository details for $repoName"
    }
}

# Function to perform Git sync for a repository
function Sync-GitRepository {
    param(
        [Parameter(Mandatory=$true)]
        [string]$repoName
    )
    
    Show-Progress $true
    
    try {
        $repoConfig = $config.Repositories | Where-Object { $_.Name -eq $repoName }
        if (-not $repoConfig) {
            Log-Message "Repository configuration not found" $repoName "ERROR"
            return
        }
        
        # Verify directory exists
        if (-not (Test-Path $repoConfig.Path)) {
            Log-Message "Repository directory not found: $($repoConfig.Path)" $repoName "ERROR"
            return
        }

        Set-Location $repoConfig.Path
        
        # Verify we're in a git repository
        $null = git rev-parse --git-dir 2>&1
        if ($LASTEXITCODE -ne 0) {
            Log-Message "Not a git repository" $repoName "ERROR"
            return
        }

        # Verify remote exists
        $remotes = git remote -v
        if (-not ($remotes -match "origin")) {
            Log-Message "Remote 'origin' not configured" $repoName "ERROR"
            return
        }
        
        # Verify branch exists
        $branches = git branch
        if (-not ($branches -match $repoConfig.Branch)) {
            Log-Message "Branch '$($repoConfig.Branch)' not found" $repoName "ERROR"
            return
        }

        # Check if we're on the correct branch
        $currentBranch = git rev-parse --abbrev-ref HEAD
        if ($currentBranch -ne $repoConfig.Branch) {
            git checkout $repoConfig.Branch
            Log-Message "Switched to branch '$($repoConfig.Branch)'" $repoName "INFO"
        }

        # Check for local changes
        $status = git status --porcelain
        if ($status) {
            # Add all changes
            git add -A
            $commitResult = git commit -m "Auto-commit: Changes from Git Loop sync $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" 2>&1
            if ($LASTEXITCODE -ne 0) {
                Log-Message "Failed to commit changes: $commitResult" $repoName "ERROR"
                return
            }
            Log-Message "Committed local changes" $repoName "INFO"
        }
        
        # Fetch latest changes
        $fetchResult = git fetch origin 2>&1
        if ($LASTEXITCODE -ne 0) {
            Log-Message "Failed to fetch: $fetchResult" $repoName "ERROR"
            return
        }
        Log-Message "Fetched changes from remote" $repoName "INFO"

        # Check if we need to pull
        $behindCount = git rev-list HEAD..origin/$($repoConfig.Branch) --count
        if ($behindCount -gt 0) {
            # Pull changes
            $pullResult = git pull origin $repoConfig.Branch 2>&1
            if ($LASTEXITCODE -ne 0) {
                if ($pullResult -match "conflict") {
                    Log-Message "Pull conflicts detected. Attempting auto-merge..." $repoName "WARNING"
                    # Try to auto-resolve conflicts by taking remote changes
                    git reset --hard origin/$($repoConfig.Branch)
                    Log-Message "Reset to remote state to resolve conflicts" $repoName "INFO"
                } else {
                    Log-Message "Pull failed: $pullResult" $repoName "ERROR"
                    return
                }
            } else {
                Log-Message "Pulled changes from remote" $repoName "INFO"
            }
        }

        # Push local changes
        $aheadCount = git rev-list origin/$($repoConfig.Branch)..HEAD --count
        if ($aheadCount -gt 0) {
            $pushResult = git push origin $repoConfig.Branch 2>&1
            if ($LASTEXITCODE -ne 0) {
                Log-Message "Failed to push: $pushResult" $repoName "ERROR"
                return
            }
            Log-Message "Pushed changes to remote" $repoName "INFO"
        }

        # Update repository details
        Update-RepositoryDetails $repoName
    }
    catch {
        Log-Message "Sync error: $_" $repoName "ERROR"
    }
    finally {
        Show-Progress $false
        Set-Location $PSScriptRoot
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
