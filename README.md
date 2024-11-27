# Git Loop

An automated Git repository synchronization tool that keeps multiple repositories in sync with minimal user intervention.

## Features

- 🔄 Automatic multi-repository synchronization
- ⚙️ Configurable sync intervals
- 🔐 Secure SSH authentication
- 📁 Multiple repository support
- 📝 Comprehensive logging
- 🔧 Easy configuration management

## Installation

1. Clone this repository:
```powershell
git clone git@github.com:ih8sirdavi/Git-Loop.git
```

2. Ensure you have the required dependencies:
   - Git installed and configured
   - PowerShell 5.1 or later
   - .NET Framework 4.5+

3. Run the script:
```powershell
.\Git_Loop.ps1
```

On first run, the script will:
- Detect your Git username
- Create initial configuration
- Set up logging directory
- Initialize Git ignore rules

## Configuration

The tool uses a JSON configuration file (`config`) with the following structure:

```json
{
    "Repositories": [
        {
            "Name": "Repository Name",
            "Path": "D:\\Path\\To\\Repository",
            "Branch": "main",
            "RemoteUrl": "git@github.com:username/repo.git",
            "AutoSync": true
        }
    ],
    "SyncInterval": 30,
    "MaxRetries": 3,
    "LogRetention": 100,
    "LogFile": "GitLoop.log",
    "MaxLogSize": "5MB"
}
```

### Configuration Files
- `config`: Main configuration file (not tracked in Git)
- `config.example`: Template configuration (tracked in Git)
- `logs/config.backup`: Automatic backup of your configuration

### Configuration Options
- `SyncInterval`: Time between syncs in seconds
- `MaxRetries`: Number of retry attempts for failed operations
- `LogRetention`: Number of log files to keep
- `MaxLogSize`: Maximum size for log files

## Directory Structure

```
Git Loop/
├── Git_Loop.ps1      # Main script
├── config            # Your configuration (ignored by Git)
├── config.example    # Configuration template
├── logs/            # Log directory
│   ├── GitLoop.log   # Operation logs
│   └── config.backup # Configuration backup
└── .gitignore       # Git ignore rules
```

## Git Ignore Rules

The following paths are automatically ignored:
- `/logs/` - All log files and configuration backups
- `/config` - Your personal configuration
- `/.git/` - Git directory

The `config.example` file is tracked to serve as a template for new users.

## Usage

1. Fork the repository
2. Configure your repositories in the config file
3. Run the script:
   ```powershell
   .\Git_Loop.ps1 -Verbose  # For detailed logging
   ```

The script will:
- Load your configuration
- Create a backup in logs/config.backup
- Start monitoring your repositories
- Automatically sync changes

## Security

- Uses SSH for authentication
- No credentials stored in script
- Runs with your Git permissions
- Configuration files not tracked in Git

## Troubleshooting

If you encounter issues:
1. Run with `-Verbose` flag for detailed logging
2. Check `logs/GitLoop.log` for operation logs
3. Verify SSH key configuration
4. Ensure Git is properly configured

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

Created by ih8sirdavi

## Acknowledgments

- PowerShell Windows Forms
- Git command line interface
- Modern UI design principles

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
