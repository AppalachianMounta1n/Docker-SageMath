# Alpine Sage - Lightweight Mathematical Computing Environment

A lightweight Docker container providing a Python-based mathematical computing environment built on Alpine Linux. This is the Alpine Linux variant of the main SageMath Docker project, offering a smaller, more secure alternative for mathematical computing.

## 🏔️ Overview

Alpine Sage provides a minimal, secure mathematical computing environment using Alpine Linux as the base. While it doesn't include the full SageMath system (which isn't available on Alpine), it offers a comprehensive Python environment with mathematical libraries and Jupyter Lab for interactive computing.

### Key Features

- **Lightweight**: Based on Alpine Linux (~5MB base image)
- **Secure**: Minimal attack surface with Alpine's security-focused design
- **Fast**: Quick startup times without complex SageMath compilation
- **Comprehensive**: Full Python mathematical computing stack
- **Interactive**: Jupyter Lab with no authentication required
- **Production Ready**: Optimized for containerized deployments

## 🚀 Quick Start

### From Docker Hub

```bash
# Pull and run the latest version
docker run -d -p 8889:8888 --name alpine-sage appalachianmounta1n/alpine-sage-math

# Access Jupyter Lab at http://localhost:8889
```

### Build from Source

```bash
# Clone the repository
git clone https://github.com/AppalachianMounta1n/Docker-SageMath.git
cd Docker-SageMath/AlpineSage

# Build the image
docker build -t alpine-sage .

# Run the container
docker run -d -p 8889:8888 --name alpine-sage-container alpine-sage
```

## 📖 Usage Guide

### Starting the Container

```bash
# Basic run
docker run -d -p 8889:8888 --name alpine-sage-container appalachianmounta1n/alpine-sage-math

# With volume mounting for data persistence
docker run -d -p 8889:8888 \
  -v $(pwd)/notebooks:/home/sageuser/notebooks \
  --name alpine-sage-container \
  appalachianmounta1n/alpine-sage-math

# With custom port mapping
docker run -d -p 9999:8888 --name alpine-sage-container appalachianmounta1n/alpine-sage-math
```

### Accessing Jupyter Lab

1. **No Authentication Required**: The container is configured for development use without authentication
2. **Access URL**: `http://localhost:8889` (or your custom port)
3. **Immediate Access**: Jupyter Lab starts automatically and is ready for use

### Container Management

```bash
# View logs
docker logs alpine-sage-container

# Stop the container
docker stop alpine-sage-container

# Remove the container
docker rm alpine-sage-container

# Restart the container
docker restart alpine-sage-container
```

### Data Persistence

```bash
# Mount a local directory for notebooks
docker run -d -p 8889:8888 \
  -v $(pwd)/my-notebooks:/home/sageuser/notebooks \
  --name alpine-sage-container \
  appalachianmounta1n/alpine-sage-math

# Copy files from container
docker cp alpine-sage-container:/home/sageuser/notebooks ./local-notebooks
```

## 🔧 Available Libraries and Tools

### Core Python Environment
- **Python 3.12.11** with virtual environment
- **pip** for package management
- **venv** for environment isolation

### Mathematical Libraries
- **NumPy**: Numerical computing and array operations
- **SciPy**: Scientific computing and optimization
- **Matplotlib**: Plotting and visualization
- **SymPy**: Symbolic mathematics
- **Pandas**: Data manipulation and analysis
- **Scikit-learn**: Machine learning algorithms

### Cryptography and Security
- **cryptography**: Cryptographic recipes and primitives
- **pycryptodome**: Cryptographic library for Python

### Jupyter Ecosystem
- **Jupyter Lab**: Next-generation web-based user interface
- **Jupyter Notebook**: Classic notebook interface
- **ipywidgets**: Interactive widgets for Jupyter
- **jupyterthemes**: Custom themes for Jupyter
- **nbconvert**: Convert notebooks to other formats
- **voila**: Deploy Jupyter notebooks as standalone applications

### System Libraries
- **GMP**: GNU Multiple Precision Arithmetic Library
- **MPFR**: Multiple Precision Floating-Point Reliable Library
- **FFTW**: Fastest Fourier Transform in the West
- **LAPACK**: Linear Algebra Package
- **OpenBLAS**: Optimized BLAS library
- **SuiteSparse**: Sparse matrix algorithms
- **Boost**: C++ libraries
- **GSL**: GNU Scientific Library
- **PARI**: Computer algebra system
- **ECL**: Embeddable Common Lisp

## 🔄 Differences from Main SageMath Version

| Feature | Alpine Sage | Main SageMath |
|---------|-------------|---------------|
| **Base OS** | Alpine Linux | Arch Linux |
| **Image Size** | ~500MB | ~2GB+ |
| **SageMath** | Python fallback | Full SageMath system |
| **Startup Time** | ~30 seconds | ~2-5 minutes |
| **Security** | Minimal attack surface | Standard Linux |
| **Memory Usage** | Lower | Higher |
| **Package Manager** | `apk` | `pacman` |
| **Use Case** | Lightweight computing | Full mathematical research |

## ✅ What Works

- **Python Mathematical Computing**: Full NumPy, SciPy, Matplotlib, SymPy stack
- **Jupyter Lab**: Interactive notebooks with all extensions
- **Data Analysis**: Pandas, scikit-learn for ML/AI
- **Cryptography**: Complete crypto library support
- **Visualization**: Matplotlib, plotly, seaborn
- **File I/O**: Read/write various data formats
- **Network Access**: HTTP requests, API calls
- **System Integration**: Docker volumes, port mapping

## ❌ What Doesn't Work

- **SageMath Commands**: No `sage` mathematical functions
- **SageMath Notebooks**: Cannot run `.sage` files
- **SageMath Libraries**: No access to SageMath-specific packages
- **Complex Mathematical Operations**: Limited to Python libraries
- **SageMath Integration**: No integration with SageMath ecosystem

## 🛠️ Development

### Building for Development

```bash
# Build with no cache for fresh start
docker build --no-cache -t alpine-sage-dev .

# Build with specific tag
docker build -t alpine-sage:v1.0.0 .
```

### Customizing the Environment

1. **Add Python Packages**: Modify the pip install section in the Dockerfile
2. **Change Base Image**: Update the `FROM` instruction
3. **Add System Packages**: Modify the `apk add` commands
4. **Custom Jupyter Config**: Edit the Jupyter configuration section

### Testing

```bash
# Run with interactive shell for testing
docker run -it --rm appalachianmounta1n/alpine-sage-math /bin/bash

# Test Python environment
python3 -c "import numpy, scipy, matplotlib; print('All libraries available')"

# Test Jupyter
jupyter lab --version
```

## 🔍 Troubleshooting

### Common Issues

**Container won't start**
```bash
# Check logs
docker logs alpine-sage-container

# Verify port availability
netstat -tulpn | grep 8889
```

**Jupyter not accessible**
```bash
# Check if container is running
docker ps

# Verify port mapping
docker port alpine-sage-container

# Check Jupyter logs
docker exec alpine-sage-container jupyter lab list
```

**Permission issues**
```bash
# Fix volume permissions
docker run -d -p 8889:8888 \
  -v $(pwd)/notebooks:/home/sageuser/notebooks:rw \
  --name alpine-sage-container \
  appalachianmounta1n/alpine-sage-math
```

### Performance Optimization

```bash
# Run with resource limits
docker run -d -p 8889:8888 \
  --memory=2g --cpus=2 \
  --name alpine-sage-container \
  appalachianmounta1n/alpine-sage-math

# Use tmpfs for temporary files
docker run -d -p 8889:8888 \
  --tmpfs /tmp \
  --name alpine-sage-container \
  appalachianmounta1n/alpine-sage-math
```

## 📦 Docker Hub

The Alpine Sage image is available on Docker Hub:

```bash
# Pull the image
docker pull appalachianmounta1n/alpine-sage-math

# View image details
docker inspect appalachianmounta1n/alpine-sage-math
```

**Image**: `appalachianmounta1n/alpine-sage-math:latest`

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### Development Guidelines

- Follow Alpine Linux best practices
- Keep the image size minimal
- Document all changes
- Test on multiple architectures
- Maintain backward compatibility

## 📄 License

This project is licensed under the MIT License - see the main repository for details.

## 🆘 Support

- **Issues**: Report bugs and feature requests on GitHub
- **Documentation**: Check the main README for additional information
- **Community**: Join discussions in the repository

## 🔗 Related Projects

- **[Main SageMath Docker](https://github.com/AppalachianMounta1n/Docker-SageMath)**: Full SageMath environment on Arch Linux
- **[SageMath Official](https://www.sagemath.org/)**: The official SageMath project
- **[Alpine Linux](https://alpinelinux.org/)**: Lightweight Linux distribution

---

**Note**: This Alpine version is designed for users who need a lightweight mathematical computing environment without the full SageMath system. For complete SageMath functionality, use the main Arch Linux version. 