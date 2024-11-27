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

1. Start Git Loop:
```powershell
.\Git_Loop.ps1
```

2. Test the background sync:
   - Select one or more repositories in the list
   - Click "Start" to begin monitoring
   - Watch the status strip at the bottom - it shows when the next sync will occur
   - Wait for 30 seconds (default sync interval)
   - You should see new sync operations start automatically
   - The status indicators will update for each repository

3. Verify sync is working:
   - Make changes in one of the monitored repositories
   - Wait for the next sync interval
   - Git Loop should automatically detect and sync the changes
   - Check the status box for sync confirmation messages

4. Adjust sync interval (optional):
   - Open the `config` file
   - Modify the "SyncInterval" value (in seconds)
   - Restart Git Loop for changes to take effect

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

## ⚖️ License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤔 Support

For issues and feature requests, please use the GitHub issues tracker.
