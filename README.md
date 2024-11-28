# Git Loop (PowerShell)

> A PowerShell-based Git repository synchronization tool that automatically monitors and syncs changes across multiple repositories.

## 🚀 Features

- 🔄 Real-time repository monitoring
- 🕒 Automatic background sync every 30 seconds (configurable)
- ✅ Dynamic repository selection (check/uncheck during runtime)
- 📊 Detailed repository status and sync information
- 🔍 Visual status indicators for each repository
- 📝 Comprehensive logging system
- ⚡ Asynchronous operations with progress tracking
- 🛡️ Error handling with automatic retries
- 🎨 Modern UI with light/dark theme support

## ⚙️ Requirements

- Windows 10/11
- PowerShell 5.1 or later
- Git for Windows
- .NET Framework 4.5+
- SSH key configured for GitHub

## 📥 Installation

1. Clone the repository:
```powershell
git clone git@github.com:ih8sirdavi/Git-Loop.git
cd "Git Loop"
```

2. Run the PowerShell script:
```powershell
.\Git_Loop.ps1
```

## 🧪 Testing Background Sync

1. Preparation:
   - Close any running instances of Git Loop
   - Open PowerShell as Administrator
   - Navigate to Git Loop directory

2. Start Git Loop with verbose logging:
```powershell
.\Git_Loop.ps1 -Verbose
```

3. Initial setup:
   - Wait for the application to fully load
   - The repository list should populate
   - Status strip should show "Ready"

4. Test repository selection:
   - Select 2-3 repositories to test with
   - Each selection should show in the log
   - Repository details should update
   - Status icons should show "Pending"

5. Start background sync:
   - Click the "Start" button
   - Verify in the log: "Started monitoring selected repositories"
   - Initial sync should begin immediately
   - Watch for these indicators:
     * Status strip shows countdown timer (30 seconds)
     * Repository icons change to "Syncing"
     * Job monitor starts checking job status (every second)
     * Verbose log shows "Timer tick" and job status updates

6. Monitor sync process:
   - Status strip shows "Next sync in: XX seconds"
   - Counter decrements every second
   - When counter reaches 0:
     * New sync jobs start
     * Job monitor tracks completion
     * Repository status updates to "Success" when done
     * Push operations complete automatically
   - Counter resets to 30 (or configured interval)

7. Test sync detection:
   - Open one of the monitored repositories
   - Make a small change (e.g., edit a text file)
   - Save and commit the change
   - Wait for countdown to reach 0
   - Watch the job monitoring in verbose log:
     * Job starts for modified repository
     * Changes are detected and pushed
     * Status updates to "Success" when complete
   - Verify changes appear in remote repository

8. Test stop/restart:
   - Click "Stop" button
   - Verify:
     * "Monitoring stopped" in log
     * Countdown timer stops
     * Job monitor stops
     * All running jobs clean up
     * Start button becomes enabled
   - Click "Start" to resume
   - Verify all timers restart:
     * Sync timer (30s intervals)
     * Countdown timer (1s updates)
     * Job monitor (1s checks)

9. Common issues:
   - Changes not pushing:
     * Check verbose log for job completion
     * Verify job monitor shows "Operation completed"
     * Look for any error messages in status box
   - Sync status not updating:
     * Ensure job monitor is running (verbose log)
     * Check for "Timer tick" messages
     * Verify repository selection
   - Jobs hanging:
     * Jobs timeout after 5 minutes
     * Check verbose log for timeout messages
     * Try stopping and restarting monitoring

10. Adjust sync interval (optional):
    - Open `config` file
    - Locate "SyncInterval" setting
    - Change to desired seconds (e.g., 10 for testing)
    - Save config file
    - Restart Git Loop completely
    - Verify all timers use new interval

## ⚙️ Configuration

The application can be configured through the `config` file. Here are the key settings:

```json
{
    "Repositories": [
        {
            "Name": "Git Loop",
            "Path": ".",
            "Branch": "main",
            "RemoteUrl": "git@github.com:USERNAME/Git-Loop.git",
            "AutoSync": true
        }
    ],
    "SyncInterval": 30,
    "MaxRetries": 3,
    "JobTimeoutSeconds": 300,
    "LogRetention": 100,
    "LogFile": "GitLoop.log",
    "MaxLogSize": "5MB",
    "Theme": "Light"
}
```

### Configuration Options

- **SyncInterval**: Time between sync operations (seconds)
- **MaxRetries**: Number of retry attempts for failed operations
- **JobTimeoutSeconds**: Maximum duration for sync operations (default: 300s)
- **LogRetention**: Number of log files to keep
- **MaxLogSize**: Maximum size for log files
- **Theme**: UI theme ("Light" or "Dark")

### Job Timeout Behavior

The `JobTimeoutSeconds` setting controls how long Git Loop will wait for sync operations to complete:

1. **Default Duration**: 5 minutes (300 seconds)
2. **Timeout Actions**:
   - Operation is forcefully stopped
   - Error is logged with timeout duration
   - Repository status updates to "Error"
   - Job is cleaned up and removed

3. **Common Timeout Scenarios**:
   - Slow network connections
   - Large repository syncs
   - Git server unresponsiveness
   - SSH authentication delays

4. **Handling Timeouts**:
   - Failed operations will retry on next sync cycle
   - Check logs for detailed error messages
   - Adjust timeout duration if needed
   - Consider network and repository size

## 📁 Directory Structure

```
Git Loop/
├── Git_Loop.ps1      # Main script
├── config            # User configuration
├── config.example    # Configuration template
├── .gitignore       # Git ignore rules
├── logs/            # Log directory
│   ├── GitLoop.log  # Operation logs
│   └── config.backup # Configuration backup
├── dev/             # Development workspace (git-ignored)
└── docs/            # Documentation
    └── planning/    # Future planning (git-ignored)
```

## 🔧 Development

### Development Workspace
- Use `/dev` directory for new feature development
- Place planning documents in `/docs/planning`
- Use appropriate file extensions for different types of files:
  - `*.dev.*` - Development files
  - `*.test.*` - Test files
  - `*.local.*` - Local configuration
  - `*_wip.*` - Work in progress
  - `*_draft.*` - Draft files

### Git Ignore Rules
The `.gitignore` is configured to maintain a clean repository while developing:
- Ignores development and planning directories
- Excludes temporary and backup files
- Ignores IDE/editor specific files
- Preserves core functionality files

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Make your changes
4. Submit a pull request

## 📝 Usage Tips

1. **Repository Selection**
   - Check/uncheck repositories at any time
   - Status updates appear in real-time
   - Visual indicators show sync status

2. **Monitoring**
   - Start/Stop monitoring with dedicated buttons
   - View detailed repository information
   - Check sync status and last commit details
   - Jobs automatically timeout after configured duration (default 5 minutes)

3. **Configuration**
   - Edit `config` file for customization
   - Set sync interval (default 30 seconds)
   - Configure job timeout (JobTimeoutSeconds, default 300 seconds)
   - Adjust log retention and max size

4. **Logs**
   - View operation logs in the status window
   - Detailed logs saved in `logs/GitLoop.log`
   - Configuration backups maintained automatically
   - Timeout events logged with duration details

## 🔄 Version History

- **v1.1.1** (Current)
  - **Repository Management**
    * Added operation throttling (500ms minimum interval)
    * Implemented repository-specific locks
    * Improved rapid change handling
    * Better cleanup of repository resources
    * Enhanced operation tracking
    * Smarter resource allocation
    * Improved state management

  - **Process Management**
    * Improved application cleanup on exit
    * Proper termination of background jobs
    * Better handling of Git processes
    * Enhanced resource management
    * Optimized cleanup sequence

  - **Git Operation Handling**
    * Improved Git operation output filtering
    * Properly handle CRLF/LF warnings
    * Better distinction between warnings and errors
    * Cleaner log output
    * Smarter warning detection
    * Enhanced sync reliability
    * Optimized Git process handling

  - **Error Handling**
    * Smarter error detection
    * Reduced false positive errors
    * More accurate sync status reporting
    * Enhanced warning filtering
    * Improved log clarity
    * Better error categorization

- **v1.1.0**
  - **Job Management**
    * Added configurable job timeouts
    * Enhanced error handling and logging
    * Improved background sync reliability
    * Fixed job monitoring issues

  - **UI Improvements**
    * Added real-time countdown display
    * Enhanced status indicators
    * Better error visibility
    * Improved log clarity

- **v1.0.0**
  - Initial release with basic functionality

## 🔍 Troubleshooting

### Common Git Messages

Git Loop intelligently handles common Git messages to avoid false error reports:

1. **Line Ending Warnings**
   ```
   warning: CRLF will be replaced by LF...
   warning: LF will be replaced by CRLF...
   ```
   These are normal Git line ending conversions and not errors.

2. **Repository Information**
   ```
   From github.com:user/repo
   * branch main -> FETCH_HEAD
   ```
   These are informational messages about fetch operations.

3. **Branch Updates**
   ```
   * [new branch]  main -> main
   ```
   Normal branch tracking information.

### Real Error Examples

These are examples of actual errors that require attention:

1. **Authentication Issues**
   ```
   fatal: Authentication failed for 'https://github.com/...'
   ```

2. **Network Problems**
   ```
   fatal: unable to access 'https://github.com/...': Could not resolve host
   ```

3. **Merge Conflicts**
   ```
   error: could not apply... conflict
   ```

### Error Resolution

1. **Authentication Errors**
   - Verify Git credentials
   - Check SSH keys if using SSH
   - Update stored credentials

2. **Network Issues**
   - Check internet connection
   - Verify proxy settings
   - Test repository access

3. **Merge Conflicts**
   - Manually resolve conflicts
   - Reset local changes if needed
   - Contact repository owner

## ⚖️ License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤔 Support

For issues and feature requests, please use the GitHub issues tracker.

## 🌟 Features

- **Automatic Repository Sync**
  * Monitor multiple Git repositories
  * Configurable sync intervals
  * Smart conflict resolution
  * Automatic retry on failures

- **Background Processing**
  * Non-blocking sync operations
  * Configurable job timeouts
  * Graceful error handling
  * Real-time status updates

- **Modern UI**
  * Clean, intuitive interface
  * Dark/Light theme support
  * Real-time progress indicators
  * Detailed repository information

- **Robust Error Handling**
  * Automatic retry with backoff
  * Detailed error logging
  * Timeout protection
  * Status preservation

## ⚙️ Configuration

The application uses a JSON configuration file (`config`) with these key settings:

```json
{
    "Repositories": [
        {
            "Name": "Git Loop",
            "Path": ".",
            "Branch": "main",
            "RemoteUrl": "git@github.com:USERNAME/Git-Loop.git",
            "AutoSync": true
        }
    ],
    "SyncInterval": 30,
    "MaxRetries": 3,
    "JobTimeoutSeconds": 300,
    "LogRetention": 100,
    "LogFile": "GitLoop.log",
    "MaxLogSize": "5MB",
    "Theme": "Light"
}
```

### Configuration Options

- **SyncInterval**: Time between sync operations (seconds)
- **MaxRetries**: Number of retry attempts for failed operations
- **JobTimeoutSeconds**: Maximum duration for sync operations (default: 300s)
- **LogRetention**: Number of log files to keep
- **MaxLogSize**: Maximum size for log files
- **Theme**: UI theme ("Light" or "Dark")

### Job Timeout Behavior

The `JobTimeoutSeconds` setting controls how long Git Loop will wait for sync operations to complete:

1. **Default Duration**: 5 minutes (300 seconds)
2. **Timeout Actions**:
   - Operation is forcefully stopped
   - Error is logged with timeout duration
   - Repository status updates to "Error"
   - Job is cleaned up and removed

3. **Common Timeout Scenarios**:
   - Slow network connections
   - Large repository syncs
   - Git server unresponsiveness
   - SSH authentication delays

4. **Handling Timeouts**:
   - Failed operations will retry on next sync cycle
   - Check logs for detailed error messages
   - Adjust timeout duration if needed
   - Consider network and repository size

## 📁 Directory Structure

```
Git Loop/
├── Git_Loop.ps1      # Main script
├── config            # Configuration file
├── config.example    # Example configuration
├── README.md         # Documentation
└── logs/            # Log directory
    ├── GitLoop.log  # Main log file
    └── errors.log   # Error log file
```

## 📝 Usage Tips

1. **Repository Selection**
   - Check/uncheck repositories to monitor
   - Status updates in real-time
   - Visual indicators show sync status
   - Hover for repository details

2. **Monitoring**
   - Start/Stop monitoring with buttons
   - View repository details and status
   - Monitor sync progress
   - Auto-timeout prevents stuck operations

3. **Logs**
   - Real-time operation logs in status window
   - Detailed logs in `logs/GitLoop.log`
   - Error logs in `logs/errors.log`
   - Configuration backups in `logs/config.backup`

4. **Performance**
   - Adjust sync interval for your needs
   - Configure timeouts based on repo size
   - Use auto-sync selectively
   - Monitor resource usage
