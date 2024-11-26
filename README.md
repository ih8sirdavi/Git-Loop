# Git Loop

A PowerShell-based Git repository synchronization tool with a modern UI for automatically managing multiple repositories.

## Features

- **Multi-Repository Management**
  - Monitor multiple repositories simultaneously
  - Automatic synchronization with remote repositories
  - Configurable sync intervals
  - Support for both HTTPS and SSH repository URLs

- **Automatic Git Operations**
  - Auto-commit local changes
  - Auto-push to main branch
  - Auto-pull from remote
  - Conflict resolution (favoring remote changes)
  - Detailed status tracking

- **Modern UI**
  - Clean, minimalist design
  - Repository selection with checkboxes
  - Hover-based repository details
  - Real-time status updates
  - Detailed logging panel

## Configuration

The configuration is stored in a file named `config` in the same directory as the script. Here's an example configuration:

```json
{
    "Repositories": [
        {
            "Name": "RepoName",
            "Path": "D:\\Path\\To\\Repo",
            "Branch": "main",
            "RemoteUrl": "git@github.com:username/repo.git",
            "AutoSync": true
        }
    ],
    "SyncInterval": 30,    // Seconds between sync checks
    "MaxRetries": 3,       // Maximum retry attempts
    "LogRetention": 100,   // Maximum log entries
    "LogFile": "GitLoop.log",
    "MaxLogSize": "5MB"    // Maximum log file size before rotation
}
```

## Prerequisites

- Windows OS
- PowerShell 5.1 or later
- Git installed and configured
- .NET Framework 4.5 or later

## Installation

1. Clone or download this repository
2. Configure your repositories in the `config` file
3. Run `Git_Loop.ps1` with PowerShell

```powershell
powershell -ExecutionPolicy Bypass -File Git_Loop.ps1
```

## Usage

1. Launch the script
2. Select repositories to monitor using checkboxes
3. Click "Start" to begin monitoring
4. Hover over repository names to view detailed status
5. Use the log panel to track operations

The script will automatically:
- Commit any local changes
- Pull remote changes
- Push local changes to main
- Handle basic merge conflicts

## UI Elements

- **Repository List**: Checkbox-based selection with hover details
- **Details Panel**: Shows repository status and git information
- **Log Panel**: Real-time operation logging
- **Status Bar**: Current sync status and last operation time
- **Control Buttons**: Start/Stop monitoring

## Color Scheme

```powershell
Background: #F8F8F8
Button Background: #F0F0F0
Primary Text: #3C3C3C
Secondary Text: #787878
```

## Security Notes

- Uses local git configuration
- Supports both HTTPS and SSH authentication
- No credential storage in script
- Runs with user's git permissions

## Known Limitations

- Windows-only support
- Requires local git configuration
- Auto-resolves conflicts by taking remote changes
- Single branch (main) support
- No credential management

## Error Handling

- Detailed error logging
- Automatic retry on failed operations
- Safe state recovery
- Verbose operation logging

## Future Enhancements

- **Advanced Repository Management**
  - Branch-specific configurations and policies
  - Support for multiple branch monitoring
  - Custom pre-commit and post-commit hooks
  - Repository health checks and diagnostics

- **Enhanced Conflict Resolution**
  - Interactive conflict resolution interface
  - Configurable conflict resolution strategies
  - Backup creation before conflict resolution
  - Visual diff tool integration

- **Extended UI Features**
  - Dark mode support
  - Customizable UI themes
  - Repository grouping and tagging
  - Advanced filtering and search capabilities
  - Performance metrics and analytics dashboard

- **Security and Authentication**
  - Credential manager integration
  - Multi-factor authentication support
  - SSH key management interface
  - Repository access control lists

- **Automation and Integration**
  - CI/CD pipeline integration
  - Webhook support for custom events
  - Scheduled operations and maintenance
  - Email/Slack notifications for important events

- **Performance Optimizations**
  - Parallel repository processing
  - Incremental status updates
  - Resource usage monitoring
  - Network bandwidth optimization

## Cross-Platform Development Plans

The current PowerShell implementation, while powerful on Windows systems, has platform limitations. Future versions of Git Loop are planned to be reimplemented in cross-platform technologies:

### Python Implementation
- **Benefits**
  - Rich ecosystem of Git libraries (GitPython)
  - Cross-platform compatibility (Windows, macOS, Linux)
  - Easy package management with pip
  - Strong async support with asyncio
  - GUI options: tkinter, PyQt, or wxPython

### Node.js Implementation
- **Benefits**
  - Large ecosystem of Git packages (simple-git, nodegit)
  - Electron for native-like desktop applications
  - Cross-platform support
  - Modern UI frameworks (React, Vue.js)
  - Strong async capabilities
  - WebSocket support for real-time updates

### Implementation Priorities
1. Core Features
   - Maintain existing functionality
   - Platform-agnostic configuration
   - Cross-platform file path handling
   
2. UI/UX
   - Responsive design
   - Native OS integrations
   - Consistent experience across platforms
   
3. Platform-Specific Features
   - OS-native notifications
   - System tray integration
   - Platform-specific Git credential handling

4. Distribution
   - Platform-specific installers
   - Auto-updates
   - Container support

The cross-platform version will maintain the same core functionality while adding platform-specific optimizations and modern development practices.

## Contributing

Contributions are welcome! Please feel free to submit pull requests or create issues for bugs and feature requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

Created by ih8sirdavi

## Acknowledgments

- PowerShell Windows Forms
- Git command line interface
- Modern UI design principles
