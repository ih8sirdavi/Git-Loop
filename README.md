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

## 🛠️ Configuration

The configuration file (`config`) is automatically created on first run:

```json
{
    "Repositories": [
        {
            "Name": "Git Loop",
            "Path": "D:\\Projects\\Git Loop",
            "Branch": "main",
            "RemoteUrl": "git@github.com:username/repo.git",
            "AutoSync": true
        }
    ],
    "SyncInterval": 30,
    "MaxRetries": 3,
    "LogRetention": 100,
    "LogFile": "GitLoop.log",
    "MaxLogSize": "5MB",
    "Theme": "Light"
}
```

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

3. **Logs**
   - View operation logs in the status window
   - Detailed logs saved in `logs/GitLoop.log`
   - Configuration backups maintained automatically

## 🔄 Version History

- **0.1.0-alpha** (Current)
  - Initial release
  - Basic sync functionality
  - Repository monitoring
  - Status tracking

## 📋 Planned Features

1. **Core Enhancements**
   - 🔲 System Tray Integration
     - Minimize to system tray
     - Background operation
     - Tray notifications for sync status
     - Quick access menu
   - 🔲 Windows Notifications
     - Native Windows notification system integration
     - Configurable alerts for sync, errors, and conflicts
     - New commit notifications
   - 🔲 Silent Operation
     - Command-line parameter for silent startup
     - Auto-start with Windows
     - Start minimized to tray option

2. **Advanced Features**
   - 🔲 Enhanced UI
     - Conflict resolution interface
     - Diff viewer for changes
     - Remote repository health monitoring
   - 🔲 Performance Optimization
     - Parallel repository scanning
     - Incremental status updates
     - Memory usage optimization
   - 🔲 Network Features
     - Bandwidth throttling
     - Network-aware sync
     - Scheduled sync windows
   - 🔲 Security Enhancements
     - Credential management
     - SSH key rotation
     - Access token management
     - Audit logging

3. **Future Phases**
   - 🔲 Cross-platform support (Python/Node.js)
   - 🔲 Team collaboration features
   - 🔲 Cloud integration
   - 🔲 Web interface

## 🐞 Recent Bug Fixes & Improvements

### v1.1.0 (Latest)
1. Background Sync Enhancements:
   - Added job monitor timer to check job status every second
   - Fixed disconnected timer issue with sync function
   - Improved job tracking and completion detection
   - Added real-time countdown display

2. Error Handling Improvements:
   - Fixed false positive errors from git fetch output
   - Better distinction between informational git messages and actual errors
   - More detailed error logging for troubleshooting
   - Improved error messages in status display

3. Timer Management:
   - Synchronized all timers (sync, countdown, job monitor)
   - Proper cleanup of timers on application close
   - Better handling of timer state during start/stop

4. UI Improvements:
   - Added real-time sync countdown display
   - Better status indicators for sync operations
   - Clearer error messages in status box

### Known Issues
- Git fetch output may appear in error logs from previous versions
- Multiple rapid start/stop actions may need a restart to reset timers
- Status updates might lag slightly during heavy sync operations

### Upcoming Features
- Configurable job timeout settings
- More detailed job progress reporting
- Enhanced error recovery mechanisms
- UI improvements for sync status display

## ⚖️ License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤔 Support

For issues and feature requests, please use the GitHub issues tracker.
