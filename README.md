# Docker-SageMath

A Docker container providing a Jupyter Lab environment with mathematical computing capabilities, built on Arch Linux. This container offers a ready-to-use environment for mathematical analysis, data science, and computational research.

## Overview

This Docker image creates an isolated environment with:
- **Python 3.13.5** with virtual environment
- **Jupyter Lab** for interactive computing
- **Mathematical libraries**: numpy, scipy, matplotlib, sympy, pandas, scikit-learn
- **Cryptography tools**: cryptography, pycryptodome
- **Jupyter extensions**: jupyterlab, ipywidgets, jupyterthemes, nbconvert, voila

The container attempts to install SageMath from the Arch User Repository (AUR) but gracefully falls back to a Python environment with mathematical libraries if SageMath installation fails.

## Quick Start

### Using Docker Hub (Recommended)

```bash
# Pull and run the container
docker run -d -p 8888:8888 \
  -v $(pwd)/notebooks:/home/sageuser/notebooks \
  --name sage-container \
  appalachianmounta1n/sage-math

# Access Jupyter Lab at http://localhost:8888
```

### Building from Source

```bash
# Clone the repository
git clone https://github.com/AppalachianMounta1n/Docker-SageMath.git
cd Docker-SageMath

# Build the image
sudo docker build -t sage-math .

# Run the container
sudo docker run -d -p 8888:8888 \
  -v $(pwd)/notebooks:/home/sageuser/notebooks \
  --name sage-container \
  sage-math
```

## Usage Guide

### Starting the Container

```bash
# Basic run command
sudo docker run -d -p 8888:8888 \
  -v $(pwd)/notebooks:/home/sageuser/notebooks \
  --name sage-container \
  appalachianmounta1n/sage-math
```

### Accessing Jupyter Lab

1. **Open your web browser**
2. **Navigate to**: `http://localhost:8888`
3. **No authentication required** - access is immediate

### Container Management

```bash
# Stop the container
sudo docker stop sage-container

# Start the container
sudo docker start sage-container

# View logs
sudo docker logs sage-container

# Remove the container
sudo docker rm sage-container

# Access container shell (for debugging)
sudo docker exec -it sage-container /bin/bash
```

### Data Persistence

The container mounts a local `notebooks` directory to persist your work:

```bash
# Create notebooks directory
mkdir notebooks

# Run with volume mounting
sudo docker run -d -p 8888:8888 \
  -v $(pwd)/notebooks:/home/sageuser/notebooks \
  --name sage-container \
  appalachianmounta1n/sage-math
```

Your notebooks and data will be saved in the local `notebooks` directory and persist between container restarts.

## Available Libraries and Tools

### Core Python Environment
- **Python 3.13.5** with virtual environment
- **pip** for package management

### Mathematical Computing
- **NumPy**: Numerical computing and array operations
- **SciPy**: Scientific computing and optimization
- **Matplotlib**: Plotting and visualization
- **SymPy**: Symbolic mathematics
- **Pandas**: Data manipulation and analysis
- **Scikit-learn**: Machine learning algorithms

### Cryptography
- **cryptography**: Cryptographic recipes and primitives
- **pycryptodome**: Cryptographic library for Python

### Jupyter Ecosystem
- **Jupyter Lab**: Modern web-based interface
- **Jupyter Notebook**: Classic notebook interface
- **ipywidgets**: Interactive widgets
- **jupyterthemes**: Custom themes
- **nbconvert**: Notebook conversion tools
- **voila**: Dashboard creation

## What Works

### Mathematical Computing
- **Linear algebra operations** with NumPy and SciPy
- **Symbolic mathematics** with SymPy
- **Data analysis** with Pandas
- **Machine learning** with Scikit-learn
- **Plotting and visualization** with Matplotlib
- **Cryptographic operations** with cryptography and pycryptodome

### Jupyter Features
- **Interactive notebooks** with Python kernels
- **Real-time plotting** and visualization
- **Widget-based interfaces** with ipywidgets
- **Theme customization** with jupyterthemes
- **Notebook export** to various formats
- **Dashboard creation** with Voila

### Development Features
- **Package installation** via pip within notebooks
- **Persistent storage** through volume mounting
- **No authentication required** for easy access
- **Multi-user support** (though not recommended for production)

## What Doesn't Work

### SageMath Limitations
- **SageMath may not be available** - the container attempts to install SageMath from AUR but may fail due to build dependencies or network issues
- **SageMath-specific features** are not guaranteed to work
- **SageMath notebooks** (.sage files) may not execute properly

### System Limitations
- **No GPU acceleration** - the container doesn't include CUDA or GPU drivers
- **Limited system packages** - only essential packages are installed
- **No persistent system changes** - modifications to the base system are lost on container restart

### Security Considerations
- **No authentication** - anyone with network access can use the container
- **Not suitable for production** - designed for development and research
- **Root access** - the container runs with elevated privileges

### Performance Limitations
- **Memory constraints** - limited by Docker container memory limits
- **CPU constraints** - limited by Docker container CPU limits
- **Storage constraints** - limited by Docker container storage limits

## Troubleshooting

### Container Won't Start
```bash
# Check container logs
sudo docker logs sage-container

# Check if port 8888 is already in use
sudo netstat -tlnp | grep 8888

# Remove conflicting container
sudo docker rm sage-container
```

### Jupyter Not Accessible
```bash
# Check if container is running
sudo docker ps

# Check container logs for errors
sudo docker logs sage-container

# Restart the container
sudo docker restart sage-container
```

### Permission Issues
```bash
# Ensure notebooks directory has correct permissions
chmod 755 notebooks

# Run container with proper volume mounting
sudo docker run -d -p 8888:8888 \
  -v $(pwd)/notebooks:/home/sageuser/notebooks \
  --name sage-container \
  appalachianmounta1n/sage-math
```

### Package Installation Issues
If you need additional packages, install them within Jupyter notebooks:

```python
# Install packages in a notebook cell
!pip install package_name

# Or use conda if available
!conda install package_name
```

## Development

### Building Custom Images
```bash
# Clone the repository
git clone https://github.com/AppalachianMounta1n/Docker-SageMath.git
cd Docker-SageMath

# Modify the Dockerfile as needed
# Build the image
sudo docker build -t my-sage-math .

# Run your custom image
sudo docker run -d -p 8888:8888 \
  -v $(pwd)/notebooks:/home/sageuser/notebooks \
  --name my-container \
  my-sage-math
```

### Contributing
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the build process
5. Submit a pull request

## License

This project is open source. Please check the repository for specific licensing information.

## Support

For issues, questions, or contributions:
- **GitHub Issues**: [https://github.com/AppalachianMounta1n/Docker-SageMath/issues](https://github.com/AppalachianMounta1n/Docker-SageMath/issues)
- **Docker Hub**: [https://hub.docker.com/r/appalachianmounta1n/sage-math](https://hub.docker.com/r/appalachianmounta1n/sage-math)

## Acknowledgments

- Built on Arch Linux for package availability
- Uses Jupyter ecosystem for interactive computing
- Leverages Python scientific computing stack
- Inspired by the need for portable mathematical computing environments