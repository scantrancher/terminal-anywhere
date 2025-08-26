# 🚀 Terminal Anywhere

**Secure, high-performance terminal streaming with sub-20ms latency**

Access and share terminal sessions from anywhere with enterprise-grade security and real-time collaboration features.

---

## ⚡ Quick Install

### Install Server
```bash
curl -L https://raw.githubusercontent.com/scantrancher/terminal-anywhere/main/install-server.sh | bash
```

### Install Client
```bash
curl -L https://raw.githubusercontent.com/scantrancher/terminal-anywhere/main/install-client.sh | bash
```

### Install Both (Interactive)
```bash
curl -L https://raw.githubusercontent.com/scantrancher/terminal-anywhere/main/install.sh | bash
```

---

## 🎯 Quick Start

### 1. Start the Server
```bash
# Start server (network accessible)
terminal_anywhere_server --bind-all

# 🔐 Server will display a secure access token like:
# Token: abc123def456...
# Connect from network: ws://your-ip:7860/ws
```

### 2. Connect a Client
```bash
# From another machine (use the token from step 1)
terminal_anywhere_client ws://server-ip:7860/ws --token abc123def456...

# From localhost (no token needed)
terminal_anywhere_client ws://127.0.0.1:7860/ws
```

### 3. Use Web Terminal
Open in browser: `http://server-ip:7860/terminal?token=abc123def456...`

---

## 🌟 Features

### 🔒 **Enterprise Security**
- **Token-based authentication** with auto-generated secure tokens
- **Localhost bypass** - no token needed for local connections
- **Rate limiting** and IP blocking protection
- **Input validation** prevents command injection attacks

### ⚡ **High Performance**
- **Sub-10ms input response** time
- **< 20ms round-trip latency** for complete interactions
- **Optimized WebSocket protocol** with MessagePack serialization
- **Async I/O** for minimal overhead

### 🎛️ **Session Management**
- **Persistent sessions** - survive network disconnections
- **Session resumption** across devices with state synchronization
- **Multi-client sharing** for real-time collaboration
- **Partial session IDs** for user-friendly commands

### 🖥️ **Multiple Interfaces**
- **Native CLI client** with rich terminal rendering
- **Full-screen web terminal** with theme support
- **Admin dashboard** for session management
- **Cross-platform** support (Linux, macOS, Windows via WSL)

### 🤝 **Collaboration**
- **Real-time session sharing** between multiple users
- **Live terminal collaboration** with synchronized input/output
- **Session monitoring** and management tools
- **Copy resume commands** for easy sharing

---

## 📚 Usage Examples

### Basic Connection
```bash
# Start server
terminal_anywhere_server --bind-all

# Connect client
terminal_anywhere_client ws://192.168.1.100:7860/ws --token YOUR_TOKEN
```

### Session Management
```bash
# List all sessions
terminal_anywhere_client list ws://server:7860/ws --token TOKEN

# Resume specific session
terminal_anywhere_client resume ws://server:7860/ws session-id --token TOKEN

# Resume with flag
terminal_anywhere_client ws://server:7860/ws --resume session-id --token TOKEN
```

### Web Access
```bash
# Access web terminal
http://server-ip:7860/terminal?token=YOUR_TOKEN

# Resume session in web browser
http://server-ip:7860/terminal?token=YOUR_TOKEN&resume=session-id

# Admin dashboard
http://server-ip:7860/admin?token=YOUR_TOKEN
```

---

## 🔧 Advanced Configuration

### Server Options
```bash
terminal_anywhere_server --help

# Common options:
--bind-all              # Accept network connections
--port 7860             # Custom port (default: 7860)
--host 0.0.0.0          # Bind to specific interface
--tunnel                # Enable Gradio tunnel for public access
```

### Client Options
```bash
terminal_anywhere_client --help

# Connection options:
--token TOKEN           # Authentication token
--resume SESSION_ID     # Resume specific session
--list-sessions         # List available sessions

# You can also use environment variable:
export TERMINAL_STREAMING_TOKEN=your-token-here
terminal_anywhere_client ws://server:7860/ws
```

### Environment Variables
```bash
# Client authentication
export TERMINAL_STREAMING_TOKEN="your-secure-token"

# Server configuration  
export TERMINAL_STREAMING_HOST="0.0.0.0"
export TERMINAL_STREAMING_PORT="7860"
```

---

## 🎨 Web Terminal Features

### Themes
- **Dark Mode** (default)
- **Light Mode** 
- **Monokai**
- **Solarized**

### Interface
- **Full-screen terminal** with optimized font rendering
- **Responsive design** for desktop and mobile
- **Copy resume commands** with one-click clipboard
- **Real-time connection status** indicators
- **Clean, minimal UI** with essential controls only

---

## 🔐 Security Model

### Authentication
- **Host-based security**: Localhost trusted, network requires tokens
- **Auto-generated tokens**: Cryptographically secure with HMAC-SHA256
- **Token validation**: All network connections authenticated
- **Session ownership**: Token-based session access control

### Network Security
- **Rate limiting**: Prevent brute force attacks
- **IP blocking**: Automatic blocking after failed attempts
- **Input sanitization**: Filter malicious commands
- **Connection throttling**: Prevent resource exhaustion

### Best Practices
- **Use secure tokens**: Never share tokens in public channels
- **Rotate tokens**: Regenerate tokens periodically
- **Network security**: Use VPN or secure networks when possible
- **Monitor access**: Check admin dashboard for active sessions

---

## 🚀 Platform Support

### Supported Platforms
| Platform | Architecture | Status |
|----------|-------------|--------|
| **Linux** | x64 (Intel/AMD) | ✅ Full Support |
| **Linux** | ARM64 (Raspberry Pi) | ✅ Full Support |
| **macOS** | x64 (Intel) | ✅ Full Support |
| **macOS** | ARM64 (Apple Silicon) | ✅ Full Support |
| **Windows** | WSL2 | ⚠️ Via WSL2 |

### System Requirements
- **Memory**: 50MB RAM for server, 20MB RAM for client
- **Network**: Any TCP/IP connection (local or internet)
- **Terminal**: ANSI-compatible terminal for CLI client
- **Browser**: Modern browser for web interface

---

## 🛠️ Troubleshooting

### Common Issues

**Connection Refused**
```bash
# Check if server is running
ps aux | grep terminal_anywhere_server

# Check port availability
netstat -tlnp | grep :7860

# Try localhost connection first
terminal_anywhere_client ws://127.0.0.1:7860/ws
```

**Authentication Failed**
```bash
# Verify token from server logs
terminal_anywhere_server --bind-all | grep "Token:"

# Use correct token format
terminal_anywhere_client ws://server:7860/ws --token "full-token-here"

# Check token environment variable
echo $TERMINAL_STREAMING_TOKEN
```

**Session Not Found**
```bash
# List available sessions
terminal_anywhere_client list ws://server:7860/ws --token TOKEN

# Use partial session ID matching
terminal_anywhere_client resume ws://server:7860/ws fb763864 --token TOKEN
```

**Performance Issues**
```bash
# Check network latency
ping server-ip

# Use localhost for testing
terminal_anywhere_client ws://127.0.0.1:7860/ws

# Monitor server resources
top -p $(pidof terminal_anywhere_server)
```

---

## 📊 Performance Benchmarks

### Latency Measurements
- **Local connection**: < 5ms round-trip
- **LAN connection**: < 15ms round-trip  
- **Internet connection**: < 50ms round-trip (depends on network)
- **Input response**: < 10ms keystroke to server processing

### Resource Usage
- **Server memory**: ~50MB with 10 active sessions
- **Client memory**: ~20MB per client instance
- **CPU usage**: < 5% during normal terminal use
- **Network bandwidth**: ~1KB/s per idle session, ~10KB/s active typing

---

## 🤝 Support & Community

### Getting Help
- **Documentation**: Full guides in the distribution package
- **Issues**: Report bugs and feature requests
- **Performance**: Optimization guides included
- **Security**: Security best practices documented

### Use Cases
- **Remote Development**: Access development environments from anywhere
- **Server Administration**: Manage multiple servers efficiently  
- **Team Collaboration**: Share terminal sessions for debugging
- **Education**: Remote terminal access for students
- **DevOps**: Persistent terminal sessions for long-running tasks

---

## 📈 What's Next

### Current Version: 1.0.0
- ✅ Complete terminal streaming system
- ✅ Enterprise-grade security
- ✅ Multi-platform binaries
- ✅ Session management and persistence
- ✅ Web terminal interface
- ✅ Real-time collaboration

### Future Enhancements
- 🔮 Plugin API for custom interfaces
- 🔮 Desktop GUI applications
- 🔮 Mobile app support
- 🔮 Enhanced collaboration features
- 🔮 Integration APIs

---

<div align="center">

**🎉 Ready to get started?**

Choose your installation method above and connect your first terminal in under 60 seconds!

---

*Terminal Anywhere - Secure terminal streaming for the modern world*

</div>