Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Configuration
$config = @{
    Repositories = @(
        @{
            Name = "Masterlogs"
            Path = "D:\Projects\Masterlogs"
            Branch = "main"
            RemoteUrl = "https://github.com/ih8sirdavi/Masterlogs"
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
    SyncInterval = 30  # Increased to 30 seconds
    MaxRetries = 3     # Added retry count for failed operations
    LogRetention = 100 # Maximum number of log entries to keep
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

# Add verbose preference at the start
$VerbosePreference = "Continue"

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

# Function to log messages with verbose output
function Log-Message {
    param(
        [string]$message,
        [string]$repository = "",
        [string]$type = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp][$type]$(if($repository){" [$repository]"}) $message"
    
    Write-Verbose $logMessage
    
    if ($form.IsHandleCreated) {
        [void]$form.Invoke([Action]{
            [void]$statusBox.AppendText("$logMessage`r`n")
            $statusBox.ScrollToCaret()
            $statusLabel.Text = $message
        })
    }
}

# Update repository details with better formatting
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
        $detailsBox.Text = $details.ToString()
    }
    catch {
        $errorMessage = "Unable to fetch repository details: $_"
        Write-Verbose "Error in Update-RepositoryDetails: $errorMessage"
        $detailsBox.Text = $errorMessage
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
    
    $repoConfig = $config.Repositories | Where-Object { $_.Name -eq $repoName }
    if (-not $repoConfig) {
        Log-Message "Repository configuration not found" $repoName "ERROR"
        return
    }
    
    try {
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
    Write-Verbose "Timer tick - starting repository sync"
    Get-SelectedRepositories | ForEach-Object {
        Write-Verbose "Processing repository: $_"
        Sync-GitRepository $_
    }
    Write-Verbose "Timer tick complete"
})

# Start button click handler with verbose logging
$startButton.Add_Click({
    $selectedRepos = Get-SelectedRepositories
    if ($selectedRepos.Count -eq 0) {
        Write-Verbose "No repositories selected"
        [System.Windows.Forms.MessageBox]::Show("Please select at least one repository.", "No Repository Selected")
        return
    }
    
    Write-Verbose "Starting monitoring for selected repositories"
    $timer.Start()
    $startButton.Enabled = $false
    $stopButton.Enabled = $true
    Log-Message "Started monitoring selected repositories"
    
    Write-Verbose "Performing initial sync"
    $selectedRepos | ForEach-Object {
        Write-Verbose "Initial sync for repository: $_"
        Sync-GitRepository $_
    }
})

# Stop button click handler
$stopButton.Add_Click({
    $timer.Stop()
    $startButton.Enabled = $true
    $stopButton.Enabled = $false
    $repoListView.Enabled = $true
    $statusLabel.Text = "Monitoring stopped"
    Log-Message "Stopped monitoring" "" "INFO"
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

# Show form
$form.ShowDialog()
