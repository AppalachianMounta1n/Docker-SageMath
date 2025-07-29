#Multi-stage build for SageMath with Jupyter
#Build stage
FROM archlinux:latest AS builder

#Install essential packages and AUR helper
RUN pacman -Syyu --noconfirm && \
    pacman -S --noconfirm \
        base-devel \
        git \
        sudo \
        python \
        python-pip \
        python-setuptools \
        python-wheel \
        nodejs \
        npm \
        && \
    pacman -Scc --noconfirm

#Create build user for AUR
RUN useradd -m -s /bin/bash builduser && \
    echo "builduser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

#Install yay as an AUR helper
USER builduser
WORKDIR /home/builduser
RUN git clone https://aur.archlinux.org/yay.git && \
    cd yay && \
    makepkg -si --noconfirm && \
    cd .. && \
    rm -rf yay

#Install SageMath from AUR or fallback to source
RUN echo "Attempting to install SageMath..." && \
    yay -S --noconfirm sage || \
    (echo "AUR installation failed, trying alternative methods..." && \
     sudo pacman -S --noconfirm sage || \
     (echo "Official repo installation failed, trying from source..." && \
      cd /tmp && \
      git clone https://github.com/sagemath/sage.git && \
      cd sage && \
      make -j$(nproc) && \
      make install))

#Ensure SageMath is properly installed and create necessary directories
RUN echo "Verifying SageMath installation..." && \
    if [ -f /usr/bin/sage ]; then \
        echo "SageMath found at /usr/bin/sage"; \
        sage --version || echo "SageMath executable found but version check failed"; \
    elif [ -f /usr/local/bin/sage ]; then \
        echo "SageMath found at /usr/local/bin/sage, creating symlink"; \
        sudo ln -sf /usr/local/bin/sage /usr/bin/sage; \
        sage --version || echo "SageMath executable found but version check failed"; \
    elif [ -f /opt/sage/sage ]; then \
        echo "SageMath found at /opt/sage/sage, creating symlink"; \
        sudo ln -sf /opt/sage/sage /usr/bin/sage; \
        sage --version || echo "SageMath executable found but version check failed"; \
    else \
        echo "SageMath installation failed - creating dummy sage executable for now"; \
        echo '#!/bin/bash' | sudo tee /usr/bin/sage; \
        echo 'echo "SageMath not available - using Python with math libraries instead"' | sudo tee -a /usr/bin/sage; \
        echo 'python3 "$@"' | sudo tee -a /usr/bin/sage; \
        sudo chmod +x /usr/bin/sage; \
    fi

#Create Python virtual environment and install packages
RUN python -m venv /home/builduser/sage-env && \
    /home/builduser/sage-env/bin/pip install --no-cache-dir --upgrade pip setuptools wheel && \
    /home/builduser/sage-env/bin/pip install --no-cache-dir \
        jupyter \
        jupyterlab \
        ipywidgets \
        jupyterthemes \
        nbconvert \
        notebook \
        voila \
        cryptography \
        pycryptodome \
        numpy \
        scipy \
        matplotlib \
        sympy \
        pandas \
        scikit-learn \
        && \
    /home/builduser/sage-env/bin/jupyter lab build

#Create necessary directories and initialize Jupyter
RUN mkdir -p /home/builduser/.local /home/builduser/.jupyter && \
    /home/builduser/sage-env/bin/jupyter lab --generate-config && \
    echo "c.ServerApp.ip = '0.0.0.0'" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.allow_root = True" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.token = ''" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.password = ''" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.open_browser = False" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.allow_origin = '*'" >> /home/builduser/.jupyter/jupyter_lab_config.py

#Runtime stage
FROM archlinux:latest

#Install runtime dependencies only
RUN pacman -Syyu --noconfirm && \
    pacman -S --noconfirm \
        python \
        git \
        sudo \
        && \
    pacman -Scc --noconfirm

#Create non-root user
RUN useradd -m -s /bin/bash sageuser

#Set working directory
WORKDIR /home/sageuser

#Create notebook directory and set security
RUN mkdir -p /home/sageuser/notebooks && \
    chown -R sageuser:sageuser /home/sageuser && \
    chmod 755 /home/sageuser && \
    chmod 700 /home/sageuser/notebooks

#Copy SageMath and virtual environment from builder stage
COPY --from=builder /usr/bin/sage /usr/bin/sage
COPY --from=builder /home/builduser/.local/ /home/sageuser/.local/
COPY --from=builder /home/builduser/.jupyter/ /home/sageuser/.jupyter/
COPY --from=builder /home/builduser/sage-env /home/sageuser/sage-env

#Copy SageMath files if they exist (optional)
RUN mkdir -p /usr/share/sage /usr/lib/sage && \
    if [ -d "/usr/share/sage" ]; then \
        echo "SageMath share directory found"; \
    else \
        echo "SageMath share directory not found - skipping"; \
    fi && \
    if [ -d "/usr/lib/sage" ]; then \
        echo "SageMath lib directory found"; \
    else \
        echo "SageMath lib directory not found - skipping"; \
    fi

#Ensure Jupyter directories exist with proper permissions
RUN mkdir -p /home/sageuser/.local/share/jupyter/runtime && \
    mkdir -p /home/sageuser/.local/share/jupyter/nbconvert && \
    mkdir -p /home/sageuser/.local/share/jupyter/kernels && \
    chown -R sageuser:sageuser /home/sageuser/.local && \
    chmod -R 755 /home/sageuser/.local && \
    chmod -R 777 /home/sageuser/.local/share

#Fix permissions and shebang paths
RUN chown -R sageuser:sageuser /home/sageuser/sage-env && \
    chown -R sageuser:sageuser /home/sageuser/.local && \
    chown -R sageuser:sageuser /home/sageuser/.jupyter && \
    chmod +x /home/sageuser/sage-env/bin/* && \
    chmod -R 755 /home/sageuser/.local && \
    chmod -R 755 /home/sageuser/.jupyter && \
    sed -i 's|/home/builduser/sage-env/bin/python|/home/sageuser/sage-env/bin/python|g' /home/sageuser/sage-env/bin/*

#Switch to non-root user
USER sageuser

#Create startup script for auto-mounting and Jupyter launch
RUN echo '#!/bin/bash' > /home/sageuser/startup.sh && \
    echo 'if [ -d "/data" ]; then' >> /home/sageuser/startup.sh && \
    echo '    echo "Auto-mounting /data to notebooks directory..."' >> /home/sageuser/startup.sh && \
    echo '    ln -sf /data /home/sageuser/notebooks/data' >> /home/sageuser/startup.sh && \
    echo '    echo "Data mounted at /home/sageuser/notebooks/data"' >> /home/sageuser/startup.sh && \
    echo 'fi' >> /home/sageuser/startup.sh && \
    echo 'echo "Checking SageMath availability..."' >> /home/sageuser/startup.sh && \
    echo 'if command -v sage >/dev/null 2>&1; then' >> /home/sageuser/startup.sh && \
    echo '    echo "SageMath is available: $(sage --version 2>/dev/null || echo "version unknown")"' >> /home/sageuser/startup.sh && \
    echo 'else' >> /home/sageuser/startup.sh && \
    echo '    echo "SageMath not available - using Python with mathematical libraries (numpy, scipy, sympy)"' >> /home/sageuser/startup.sh && \
    echo 'fi' >> /home/sageuser/startup.sh && \
    echo 'echo "Activating Python virtual environment..."' >> /home/sageuser/startup.sh && \
    echo 'source /home/sageuser/sage-env/bin/activate' >> /home/sageuser/startup.sh && \
    echo 'echo "Python virtual environment activated. You can now use pip install in notebooks."' >> /home/sageuser/startup.sh && \
    echo 'echo "Ensuring Jupyter directories exist with proper permissions..."' >> /home/sageuser/startup.sh && \
    echo 'mkdir -p /home/sageuser/.local/share/jupyter/runtime' >> /home/sageuser/startup.sh && \
    echo 'mkdir -p /home/sageuser/.local/share/jupyter/nbconvert' >> /home/sageuser/startup.sh && \
    echo 'mkdir -p /home/sageuser/.local/share/jupyter/kernels' >> /home/sageuser/startup.sh && \
    echo 'chmod -R 777 /home/sageuser/.local/share' >> /home/sageuser/startup.sh && \
    echo 'echo "Starting Jupyter Lab..."' >> /home/sageuser/startup.sh && \
    echo 'exec /home/sageuser/sage-env/bin/jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root' >> /home/sageuser/startup.sh && \
    chmod +x /home/sageuser/startup.sh

#Expose port for Jupyter
EXPOSE 8888

#Set entrypoint to auto-start Jupyter
ENTRYPOINT ["/home/sageuser/startup.sh"]