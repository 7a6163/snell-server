# Snell Server Docker

A lightweight Docker container for running [Snell Server](https://manual.nssurge.com/others/snell.html), a high-performance proxy server developed by Surge Networks.

## Features

- 🚀 **Multi-architecture support**: linux/amd64, linux/arm64
- 🐳 **Ultra-minimal Docker image**: Based on Google's distroless static image
- 🔒 **Maximum security**: No shell, package manager, or unnecessary binaries
- ⚡ **Latest version**: Snell Server v5.0.0b3
- 📦 **Tiny footprint**: Extremely small final image size

## Quick Start

### 🚀 Easy Setup (Recommended)

Use the automated setup script:

```bash
# Quick start with defaults
./setup.sh

# Custom architecture and port
./setup.sh --arch arm64 --port 8080

# With custom configuration
./setup.sh --config ./my-snell.conf --name my-snell-server
```

### 🐳 Using Pre-built Images

#### Docker Hub
```bash
# Pull from Docker Hub
docker pull <your-dockerhub-username>/snell-server:latest

# Run with configuration
docker run -d --name snell-server \
  -p 6160:6160 \
  -v ./snell-server.conf:/etc/snell-server.conf:ro \
  <your-dockerhub-username>/snell-server:latest \
  snell-server -c /etc/snell-server.conf
```

#### GitHub Container Registry
```bash
# Pull from GitHub Container Registry
docker pull ghcr.io/<your-github-username>/snell-server:latest

# Run with configuration
docker run -d --name snell-server \
  -p 6160:6160 \
  -v ./snell-server.conf:/etc/snell-server.conf:ro \
  ghcr.io/<your-github-username>/snell-server:latest \
  snell-server -c /etc/snell-server.conf
```

### 🔨 Manual Build

```bash
# For AMD64 (default)
docker build --platform linux/amd64 -t snell-server .

# For ARM64
docker build --platform linux/arm64 -t snell-server .
```

## Configuration

Create a `snell-server.conf` file (or copy from `snell-server.conf.example`):

```ini
[snell-server]
listen = 0.0.0.0:6160
psk = your-pre-shared-key
obfs = http
```

### Generate a secure PSK

```bash
# Generate a random 32-character base64 key
openssl rand -base64 32
```

### Configuration Options

- `listen`: The address and port to listen on
- `psk`: Pre-shared key for authentication
- `obfs`: Obfuscation method (http, tls, or off)

## Docker Compose

```yaml
version: '3.8'

services:
  snell-server:
    build:
      context: .
      args:
        ARCH: amd64
    container_name: snell-server
    ports:
      - "6160:6160"
    volumes:
      - ./snell-server.conf:/etc/snell-server.conf
    command: snell-server -c /etc/snell-server.conf
    restart: unless-stopped
```

## Supported Architectures

| Architecture | Platform | Status |
|--------------|----------|--------|
| x86_64 | `linux/amd64` | ✅ Supported |
| arm64 | `linux/arm64` | ✅ Supported |

## CI/CD & Automation

### 🤖 GitHub Actions

This repository includes comprehensive CI/CD workflows:

- **🔄 Automated Builds**: Multi-architecture Docker images on every release
- **🔍 Security Scanning**: Trivy vulnerability scanning
- **✅ Testing**: Dockerfile linting and build testing on PRs
- **📦 Publishing**: Automatic publishing to Docker Hub and GitHub Container Registry
- **🔄 Dependency Updates**: Dependabot for keeping dependencies current

### 📋 Workflow Triggers

- **Release**: Push tags starting with `v*` (e.g., `v5.0.0b3`)
- **Development**: Push to `main` branch
- **Testing**: Pull requests to `main`
- **Manual**: Workflow dispatch with custom tags

### 🔧 Setup for Your Repository

1. **Fork this repository**
2. **Set up secrets** in your GitHub repository settings:

   **For Docker Hub:**
   - `DOCKERHUB_USERNAME`: Your Docker Hub username
   - `DOCKERHUB_TOKEN`: Your Docker Hub access token

   **For GitHub Container Registry:**
   - No additional setup needed! Uses `GITHUB_TOKEN` automatically

3. **Enable GitHub Container Registry** (if not already enabled):
   - Go to your GitHub profile → Settings → Developer settings → Personal access tokens
   - Ensure your token has `write:packages` permission

4. **Create a release** by pushing a tag:
   ```bash
   git tag v5.0.0b3
   git push origin v5.0.0b3
   ```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `ARCH` | `amd64` | Target architecture for the build |
| `SNELL_VERSION` | `v5.0.0b3` | Snell server version to download |

## Security Considerations

- Always use a strong, unique pre-shared key (PSK)
- Consider using TLS obfuscation for better security
- Run the container with appropriate network restrictions
- Regularly update to the latest version
- **Distroless advantage**: No shell or package manager reduces attack surface
- **Minimal dependencies**: Only contains the snell-server binary and essential libraries

## Troubleshooting

### Common Issues

1. **Architecture mismatch**: Ensure you're building for the correct architecture
2. **Port conflicts**: Make sure port 6160 is available
3. **Configuration errors**: Validate your `snell-server.conf` syntax

### Logs

View container logs:
```bash
docker logs snell-server
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Links

- [Snell Protocol Documentation](https://manual.nssurge.com/others/snell.html)
- [Surge Networks](https://nssurge.com/)
- [Docker Hub](https://hub.docker.com/)
- [Google Distroless](https://github.com/GoogleContainerTools/distroless)

## Changelog

## 📁 Repository Structure

```
├── Dockerfile                    # Ultra-optimized multi-stage build
├── docker-compose.yml           # Easy local development setup
├── setup.sh                     # Automated setup script
├── snell-server.conf.example    # Sample configuration file
├── README.md                    # This documentation
├── LICENSE                      # MIT License
└── .github/
    ├── workflows/
    │   ├── docker-release.yml    # Multi-arch build & release
    │   └── docker-test.yml       # PR testing & validation
    └── dependabot.yml           # Dependency update automation
```

## Changelog

### v5.0.0b3
- Updated to Snell Server v5.0.0b3
- **Fixed GHCR upload issues**: Enabled GitHub Container Registry publishing
- **Architecture consistency**: Standardized multi-architecture support to linux/amd64 and linux/arm64
- **Enhanced CI/CD**: Improved workflow reliability and error handling
- **Documentation updates**: Corrected architecture references across all files

### v4.1.1
- Updated to Snell Server v4.1.1
- **Ultra-optimized Dockerfile**: Reduced from 30 to 15 lines
- **Distroless final image**: Maximum security with minimal attack surface
- Added multi-architecture support (linux/amd64, linux/arm64)
- **Dual-registry publishing**: Automated builds to Docker Hub and GitHub Container Registry
- **GitHub Actions CI/CD**: Comprehensive testing, security scanning, and releases
- **Setup automation**: Easy deployment script with configuration generation
- Eliminated unnecessary dependencies and layers
