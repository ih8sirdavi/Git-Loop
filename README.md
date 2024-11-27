# Git Loop (PowerShell)

> A PowerShell-based Git repository synchronization tool that automatically monitors and syncs changes across multiple repositories.

## 🚀 Features

- 🔄 Real-time repository monitoring
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

## 🎯 Planned Features

### System Integration
- [ ] 🔔 Windows notification system integration
  - Repository sync status notifications
  - Error alerts
  - Custom notification settings
- [ ] 🏃‍♂️ Silent startup mode
  - Start with Windows option
  - Minimize to system tray on startup
  - Quick access through tray icon
- [ ] 💻 System tray integration
  - Repository status overview
  - Quick sync actions
  - Tray icon status indicators

### Enhanced UI/UX
- [ ] 📊 Repository statistics dashboard
  - Commit frequency graphs
  - Sync history visualization
  - Branch comparison views
- [ ] ⚡ Quick actions menu
  - Right-click context menus
  - Keyboard shortcuts
  - Custom action scripts
- [ ] 🎨 Advanced theme customization
  - Custom theme creation
  - Theme import/export
  - Per-repository color coding

### Performance & Security
- [ ] 🔒 Enhanced security features
  - Credential manager integration
  - SSH key management
  - Repository access controls
- [ ] 💪 Performance optimizations
  - Parallel fetch operations
  - Smart sync scheduling
  - Resource usage controls
- [ ] 📦 Compact mode
  - Reduced memory footprint
  - Optimized for background operation
  - Lightweight UI mode

### Collaboration Features
- [ ] 👥 Team synchronization
  - Shared repository configurations
  - Team activity monitoring
  - Sync status broadcasting
- [ ] 📝 Enhanced logging
  - Detailed sync reports
  - Team activity logs
  - Export capabilities
- [ ] 🤝 Integration capabilities
  - CI/CD pipeline hooks
  - Issue tracker integration
  - Chat platform notifications

### Advanced Git Features
- [ ] 🌳 Branch management
  - Visual branch navigator
  - Branch sync rules
  - Auto-merge configurations
- [ ] 🏷️ Tag management
  - Automated tag syncing
  - Version tracking
  - Release management
- [ ] 🔄 Custom sync strategies
  - Per-repository sync rules
  - Conditional sync triggers
  - Branch-specific settings

### Configuration Management
- [ ] ⚙️ Profile system
  - Multiple configuration profiles
  - Quick profile switching
  - Profile sharing
- [ ] 📱 Remote configuration
  - Cloud-based settings sync
  - Remote repository management
  - Mobile app companion
- [ ] 🎮 Command-line interface
  - Headless operation mode
  - Script integration
  - Remote control capabilities

## 🔄 Development Status

Current Version: 0.1.0-alpha

### Short-term Goals (v0.2.0)
1. Windows notification system
2. System tray integration
3. Silent startup mode
4. Basic keyboard shortcuts
5. Repository quick actions

### Mid-term Goals (v0.3.0)
1. Enhanced security features
2. Performance optimizations
3. Advanced theme system
4. Team collaboration features
5. Branch management tools

### Long-term Goals (v1.0.0)
1. Complete CI/CD integration
2. Mobile companion app
3. Cloud configuration sync
4. Advanced analytics
5. Enterprise features

## 🔄 Version History

- **0.1.0-alpha** (Current)
  - Initial release
  - Basic sync functionality
  - Repository monitoring
  - Status tracking

## 📋 Planned Features

1. **Phase 2**
   - 🔲 Cross-platform support (Python/Node.js)
   - 🔲 Team collaboration features
   - 🔲 Cloud integration
   - 🔲 Web interface

2. **Phase 3**
   - 🔲 Enterprise features
   - 🔲 Team permissions
   - 🔲 Advanced workflows
   - 🔲 CI/CD integration

## ⚖️ License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤔 Support

For issues and feature requests, please use the GitHub issues tracker.
