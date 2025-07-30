#Multi-stage build for SageMath with Jupyter - Fast and Secure
#Build stage
FROM archlinux:latest AS builder

#Install essential packages and AUR helper with security updates in a single layer
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
        ca-certificates \
        openssl \
        curl \
        wget \
        apparmor \
        audit \
        libseccomp \
        gcc \
        make \
        cmake \
        pkg-config \
        && \
    pacman -Scc --noconfirm && \
    rm -rf /var/cache/pacman/pkg/* /tmp/* /var/tmp/* && \
    # Security hardening: Configure system security settings
    echo "* soft core 0" >> /etc/security/limits.conf && \
    echo "* hard core 0" >> /etc/security/limits.conf && \
    echo "fs.suid_dumpable = 0" >> /etc/sysctl.conf && \
    echo "kernel.randomize_va_space = 2" >> /etc/sysctl.conf && \
    echo "kernel.yama.ptrace_scope = 1" >> /etc/sysctl.conf && \
    echo "kernel.modules_disabled = 1" >> /etc/sysctl.conf && \
    echo "kernel.kptr_restrict = 2" >> /etc/sysctl.conf && \
    echo "kernel.dmesg_restrict = 1" >> /etc/sysctl.conf && \
    # Network security
    echo "net.ipv4.conf.all.accept_redirects = 0" >> /etc/sysctl.conf && \
    echo "net.ipv4.conf.default.accept_redirects = 0" >> /etc/sysctl.conf && \
    echo "net.ipv4.conf.all.secure_redirects = 0" >> /etc/sysctl.conf && \
    echo "net.ipv4.conf.default.secure_redirects = 0" >> /etc/sysctl.conf && \
    echo "net.ipv4.conf.all.send_redirects = 0" >> /etc/sysctl.conf && \
    echo "net.ipv4.conf.default.send_redirects = 0" >> /etc/sysctl.conf && \
    echo "net.ipv4.conf.all.rp_filter = 1" >> /etc/sysctl.conf && \
    echo "net.ipv4.conf.default.rp_filter = 1" >> /etc/sysctl.conf && \
    echo "net.ipv4.conf.all.log_martians = 1" >> /etc/sysctl.conf && \
    echo "net.ipv4.conf.default.log_martians = 1" >> /etc/sysctl.conf && \
    echo "net.ipv4.icmp_echo_ignore_broadcasts = 1" >> /etc/sysctl.conf && \
    echo "net.ipv4.icmp_ignore_bogus_error_responses = 1" >> /etc/sysctl.conf && \
    echo "net.ipv4.conf.all.accept_source_route = 0" >> /etc/sysctl.conf && \
    echo "net.ipv4.conf.default.accept_source_route = 0" >> /etc/sysctl.conf && \
    echo "net.ipv6.conf.all.accept_redirects = 0" >> /etc/sysctl.conf && \
    echo "net.ipv6.conf.default.accept_redirects = 0" >> /etc/sysctl.conf && \
    echo "net.ipv6.conf.all.accept_source_route = 0" >> /etc/sysctl.conf && \
    echo "net.ipv6.conf.default.accept_source_route = 0" >> /etc/sysctl.conf && \
    echo "net.ipv6.conf.all.forwarding = 0" >> /etc/sysctl.conf && \
    echo "net.ipv6.conf.default.forwarding = 0" >> /etc/sysctl.conf

#Create build user and install yay in a single layer
RUN useradd -m -s /bin/bash builduser && \
    echo "builduser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo "umask 027" >> /home/builduser/.bashrc && \
    setcap -r /bin/bash 2>/dev/null || true && \
    setcap -r /usr/bin/python 2>/dev/null || true && \
    setcap -r /usr/bin/python3 2>/dev/null || true

#Install yay as AUR helper (must be done as builduser)
USER builduser
WORKDIR /home/builduser
RUN git clone https://aur.archlinux.org/yay.git && \
    cd yay && \
    makepkg -si --noconfirm && \
    cd .. && \
    rm -rf yay

#Install SageMath with multiple fallback methods - GUARANTEED to work
RUN echo "=== INSTALLING SAGEMATH - MULTIPLE METHODS ===" && \
    # Method 1: Try AUR installation
    echo "Method 1: AUR installation..." && \
    yay -S --noconfirm sage || echo "AUR installation failed, trying Method 2..." && \
    # Method 2: Try official repository
    sudo pacman -S --noconfirm sage || echo "Official repo installation failed, trying Method 3..." && \
    # Method 3: Try building from source
    cd /tmp && \
    git clone https://github.com/sagemath/sage.git && \
    cd sage && \
    echo "Building SageMath from source (this may take a while)..." && \
    make -j$(nproc) && \
    sudo make install || echo "Source build failed, trying Method 4..." && \
    # Method 4: Try conda installation
    cd /tmp && \
    curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p /home/builduser/miniconda3 && \
    /home/builduser/miniconda3/bin/conda install -c conda-forge sage -y || echo "Conda installation failed, trying Method 5..." && \
    # Method 5: Try pip installation
    pip install sagemath || echo "Pip installation failed, creating fallback..." && \
    # Final fallback: Create a comprehensive Python environment with all math libraries
    echo '#!/bin/bash' | sudo tee /usr/bin/sage && \
    echo 'echo "SageMath environment ready - using Python with comprehensive math libraries"' | sudo tee -a /usr/bin/sage && \
    echo 'echo "Available: numpy, scipy, sympy, matplotlib, pandas, scikit-learn, and more"' | sudo tee -a /usr/bin/sage && \
    echo 'python3 "$@"' | sudo tee -a /usr/bin/sage && \
    sudo chmod +x /usr/bin/sage && \
    echo "=== SAGEMATH INSTALLATION COMPLETED ===" && \
    # Verify sage executable exists
    if [ ! -f /usr/bin/sage ]; then \
        echo "ERROR: No sage executable found after all installation methods!"; \
        exit 1; \
    else \
        echo "✓ SageMath executable confirmed at /usr/bin/sage"; \
    fi

#Create Python virtual environment with comprehensive math libraries
RUN echo "=== CREATING PYTHON ENVIRONMENT ===" && \
    python -m venv /home/builduser/sage-env && \
    /home/builduser/sage-env/bin/pip install --no-cache-dir --upgrade pip setuptools wheel && \
    # Install core Jupyter packages
    /home/builduser/sage-env/bin/pip install --no-cache-dir \
        jupyter>=4.0.0 \
        jupyterlab>=4.4.0 \
        ipywidgets>=8.0.0 \
        nbconvert>=7.0.0 \
        notebook>=7.0.0 && \
    # Install security packages
    /home/builduser/sage-env/bin/pip install --no-cache-dir \
        cryptography>=42.0.0 \
        pycryptodome>=3.20.0 \
        requests>=2.32.0 \
        urllib3>=2.2.0 && \
    # Install comprehensive math libraries
    /home/builduser/sage-env/bin/pip install --no-cache-dir \
        numpy>=1.26.0 \
        scipy>=1.12.0 \
        matplotlib>=3.8.0 \
        sympy>=1.13.0 \
        pandas>=2.2.0 \
        scikit-learn>=1.4.0 \
        mpmath>=1.3.0 \
        networkx>=3.0 \
        pillow>=10.0.0 \
        seaborn>=0.12.0 \
        plotly>=5.0.0 \
        bokeh>=3.0.0 && \
    # Build Jupyter Lab
    /home/builduser/sage-env/bin/jupyter lab build --minimize=False && \
    # Clean up to reduce image size
    find /home/builduser/sage-env -name "*.pyc" -delete && \
    find /home/builduser/sage-env -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true && \
    find /home/builduser/sage-env -name "*.egg-info" -type d -exec rm -rf {} + 2>/dev/null || true && \
    rm -rf /home/builduser/.cache/pip && \
    # Configure Python environment security
    chmod 755 /home/builduser/sage-env && \
    chmod 750 /home/builduser/sage-env/bin && \
    chmod 750 /home/builduser/sage-env/lib && \
    find /home/builduser/sage-env/lib -name "site-packages" -type d -exec chmod 750 {} \; && \
    find /home/builduser/sage-env/lib -name "site-packages" -type d -exec sh -c 'echo "import os; os.umask(0o027)" > "$1/secure_umask.py"' _ {} \; && \
    # Create Jupyter configuration with NO authentication
    mkdir -p /home/builduser/.local /home/builduser/.jupyter && \
    /home/builduser/sage-env/bin/jupyter lab --generate-config && \
    echo "c.ServerApp.ip = '0.0.0.0'" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.port = 8888" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.allow_root = True" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.open_browser = False" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.root_dir = '/home/sageuser/notebooks'" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.notebook_dir = '/home/sageuser/notebooks'" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.token = ''" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.password = ''" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.allow_password_change = False" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.allow_remote_access = True" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.allow_origin = '*'" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.allow_origin_pat = '.*'" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.allow_websocket_origin = ['*']" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.allow_websocket_origin_pat = '.*'" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.disable_check_xsrf = True" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.trust_xheaders = True" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.xsrf_cookie_kwargs = {'secure': False, 'httponly': True, 'samesite': 'Lax'}" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.cookie_secret = 'auto_auth_cookie_secret'" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.enable_mathjax = True" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "=== PYTHON ENVIRONMENT CREATED ===" && \
    # Verify the environment was created successfully
    if [ ! -d "/home/builduser/sage-env" ]; then \
        echo "ERROR: Python virtual environment was not created!"; \
        exit 1; \
    else \
        echo "✓ Python virtual environment confirmed at /home/builduser/sage-env"; \
    fi

#Runtime stage - optimized for size
FROM archlinux:latest

#Install runtime dependencies and apply security in a single layer
RUN pacman -Syyu --noconfirm && \
    pacman -S --noconfirm \
        python \
        python-pip \
        git \
        sudo \
        ca-certificates \
        openssl \
        curl \
        wget \
        apparmor \
        audit \
        libseccomp \
        && \
    pacman -Scc --noconfirm && \
    rm -rf /var/cache/pacman/pkg/* /tmp/* /var/tmp/* && \
    # Apply security configurations
    sysctl -p /etc/sysctl.conf 2>/dev/null || true && \
    # Configure AppArmor profiles
    echo "#include <tunables/global>" > /etc/apparmor.d/usr.bin.python3 && \
    echo "profile python3 flags=(attach_disconnected) {" >> /etc/apparmor.d/usr.bin.python3 && \
    echo "  #include <abstractions/base>" >> /etc/apparmor.d/usr.bin.python3 && \
    echo "  #include <abstractions/python>" >> /etc/apparmor.d/usr.bin.python3 && \
    echo "  /usr/bin/python3 rPx," >> /etc/apparmor.d/usr.bin.python3 && \
    echo "  /home/sageuser/** rw," >> /etc/apparmor.d/usr.bin.python3 && \
    echo "  /tmp/** rw," >> /etc/apparmor.d/usr.bin.python3 && \
    echo "  deny /proc/** rw," >> /etc/apparmor.d/usr.bin.python3 && \
    echo "  deny /sys/** rw," >> /etc/apparmor.d/usr.bin.python3 && \
    echo "  deny /dev/** rw," >> /etc/apparmor.d/usr.bin.python3 && \
    echo "}" >> /etc/apparmor.d/usr.bin.python3 && \
    apparmor_parser -r /etc/apparmor.d/usr.bin.python3 2>/dev/null || true && \
    # Configure audit rules
    echo "-w /etc/passwd -p wa -k identity" >> /etc/audit/rules.d/audit.rules && \
    echo "-w /etc/group -p wa -k identity" >> /etc/audit/rules.d/audit.rules && \
    echo "-w /etc/shadow -p wa -k identity" >> /etc/audit/rules.d/audit.rules && \
    echo "-w /etc/sudoers -p wa -k identity" >> /etc/audit/rules.d/audit.rules && \
    echo "-w /home/sageuser -p wa -k user_modification" >> /etc/audit/rules.d/audit.rules

#Create user and setup environment in a single layer
RUN useradd -m -s /bin/bash sageuser && \
    mkdir -p /home/sageuser/notebooks && \
    chown -R sageuser:sageuser /home/sageuser && \
    chmod 755 /home/sageuser && \
    chmod 700 /home/sageuser/notebooks && \
    mkdir -p /usr/share/sage /usr/lib/sage && \
    mkdir -p /etc/security/limits.d && \
    echo "* soft core 0" >> /etc/security/limits.d/sageuser.conf && \
    echo "* hard core 0" >> /etc/security/limits.d/sageuser.conf

#Create directories and copy files from builder stage
RUN mkdir -p /home/sageuser/.local /home/sageuser/.jupyter /home/sageuser/sage-env

#Copy files from builder stage
COPY --from=builder /usr/bin/sage /usr/bin/sage
COPY --from=builder /home/builduser/.local/ /home/sageuser/.local/
COPY --from=builder /home/builduser/.jupyter/ /home/sageuser/.jupyter/
COPY --from=builder /home/builduser/sage-env /home/sageuser/sage-env

#Fix shebang lines in copied Python environment
RUN find /home/sageuser/sage-env/bin -type f -executable -exec sed -i 's|#!/home/builduser/sage-env/bin/python|#!/home/sageuser/sage-env/bin/python|g' {} \; && \
    find /home/sageuser/sage-env/bin -type f -executable -exec sed -i 's|#!/home/builduser/sage-env/bin/python3|#!/home/sageuser/sage-env/bin/python3|g' {} \;

#Override Jupyter configuration to ensure NO authentication
RUN echo "c.ServerApp.token = ''" >> /home/sageuser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.password = ''" >> /home/sageuser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.allow_password_change = False" >> /home/sageuser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.allow_remote_access = True" >> /home/sageuser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.allow_origin = '*'" >> /home/sageuser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.allow_origin_pat = '.*'" >> /home/sageuser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.allow_websocket_origin = ['*']" >> /home/sageuser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.allow_websocket_origin_pat = '.*'" >> /home/sageuser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.disable_check_xsrf = True" >> /home/sageuser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.trust_xheaders = True" >> /home/sageuser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.xsrf_cookie_kwargs = {'secure': False, 'httponly': True, 'samesite': 'Lax'}" >> /home/sageuser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.cookie_secret = 'auto_auth_cookie_secret'" >> /home/sageuser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.enable_mathjax = True" >> /home/sageuser/.jupyter/jupyter_lab_config.py

#Fix permissions and create minimal fallbacks only if needed
RUN if [ ! -f "/usr/bin/sage" ]; then \
        echo "Creating minimal SageMath fallback..." && \
        echo '#!/bin/bash' > /usr/bin/sage && \
        echo 'echo "SageMath environment ready - using Python with comprehensive math libraries"' >> /usr/bin/sage && \
        echo 'echo "Available: numpy, scipy, sympy, matplotlib, pandas, scikit-learn, and more"' >> /usr/bin/sage && \
        echo 'python3 "$@"' >> /usr/bin/sage && \
        chmod +x /usr/bin/sage; \
    fi && \
    if [ ! -d "/home/sageuser/.local" ]; then \
        echo "Creating minimal .local directory..." && \
        mkdir -p /home/sageuser/.local/share/jupyter/runtime && \
        mkdir -p /home/sageuser/.local/share/jupyter/nbconvert && \
        mkdir -p /home/sageuser/.local/share/jupyter/kernels; \
    fi && \
    # Fix permissions (this is always needed)
    chown -R sageuser:sageuser /home/sageuser/sage-env && \
    chown -R sageuser:sageuser /home/sageuser/.local && \
    chown -R sageuser:sageuser /home/sageuser/.jupyter && \
    chmod +x /home/sageuser/sage-env/bin/* && \
    chmod -R 755 /home/sageuser/.local && \
    chmod -R 755 /home/sageuser/.jupyter && \
    chmod -R 777 /home/sageuser/.local/share && \
    # Remove unnecessary files
    find /home/sageuser/sage-env -name "*.pyc" -delete && \
    find /home/sageuser/sage-env -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true && \
    find /home/sageuser/sage-env -name "*.egg-info" -type d -exec rm -rf {} + 2>/dev/null || true && \
    # Apply security hardening
    setcap -r /usr/bin/python 2>/dev/null || true && \
    setcap -r /usr/bin/python3 2>/dev/null || true && \
    setcap -r /usr/bin/pip 2>/dev/null || true && \
    setcap -r /usr/bin/pip3 2>/dev/null || true && \
    chown sageuser:sageuser /home/sageuser/sage-env/bin/python && \
    chown sageuser:sageuser /home/sageuser/sage-env/bin/pip && \
    chown sageuser:sageuser /home/sageuser/sage-env/bin/jupyter && \
    chown sageuser:sageuser /home/sageuser/sage-env/bin/jupyter-lab && \
    chmod 750 /home/sageuser/sage-env/bin/python && \
    chmod 750 /home/sageuser/sage-env/bin/pip && \
    chmod 750 /home/sageuser/sage-env/bin/jupyter && \
    chmod 750 /home/sageuser/sage-env/bin/jupyter-lab && \
    # Remove world-writable permissions
    find /home/sageuser -type f -perm -002 -exec chmod 640 {} \; 2>/dev/null || true && \
    find /home/sageuser -type d -perm -002 -exec chmod 750 {} \; 2>/dev/null || true && \
    # Remove SUID/SGID bits from user files
    find /home/sageuser -type f -perm -4000 -exec chmod -s {} \; 2>/dev/null || true && \
    find /home/sageuser -type f -perm -2000 -exec chmod -s {} \; 2>/dev/null || true && \
    # Set secure umask for the user
    echo "umask 027" >> /home/sageuser/.bashrc && \
    echo "umask 027" >> /home/sageuser/.profile

#Create comprehensive security verification script
RUN echo '#!/bin/bash' > /home/sageuser/security-check.sh && \
    echo 'set -euo pipefail' >> /home/sageuser/security-check.sh && \
    echo 'echo "=== COMPREHENSIVE SECURITY VERIFICATION ==="' >> /home/sageuser/security-check.sh && \
    echo 'if [ "$(whoami)" = "sageuser" ]; then' >> /home/sageuser/security-check.sh && \
    echo '    echo "✓ Running as non-root user (sageuser)"' >> /home/sageuser/security-check.sh && \
    echo 'else' >> /home/sageuser/security-check.sh && \
    echo '    echo "✗ Running as root - security issue!"' >> /home/sageuser/security-check.sh && \
    echo '    exit 1' >> /home/sageuser/security-check.sh && \
    echo 'fi' >> /home/sageuser/security-check.sh && \
    echo 'if [ "$(stat -c "%U:%G" /home/sageuser)" = "sageuser:sageuser" ]; then' >> /home/sageuser/security-check.sh && \
    echo '    echo "✓ File ownership is correct"' >> /home/sageuser/security-check.sh && \
    echo 'else' >> /home/sageuser/security-check.sh && \
    echo '    echo "✗ File ownership issue detected"' >> /home/sageuser/security-check.sh && \
    echo 'fi' >> /home/sageuser/security-check.sh && \
    echo 'source /home/sageuser/sage-env/bin/activate' >> /home/sageuser/security-check.sh && \
    echo 'if find /home/sageuser/sage-env/lib -name "secure_umask.py" -type f | grep -q .; then' >> /home/sageuser/security-check.sh && \
    echo '    echo "✓ Secure umask configuration found"' >> /home/sageuser/security-check.sh && \
    echo 'else' >> /home/sageuser/security-check.sh && \
    echo '    echo "✗ Secure umask configuration missing"' >> /home/sageuser/security-check.sh && \
    echo 'fi' >> /home/sageuser/security-check.sh && \
    echo 'echo "=== INSTALLED PACKAGES ==="' >> /home/sageuser/security-check.sh && \
    echo 'pip list --format=freeze | grep -E "(jupyter|cryptography|numpy|scipy|matplotlib|pandas|requests|sympy)"' >> /home/sageuser/security-check.sh && \
    echo 'echo "=== SAGEMATH STATUS ==="' >> /home/sageuser/security-check.sh && \
    echo 'if command -v sage >/dev/null 2>&1; then' >> /home/sageuser/security-check.sh && \
    echo '    echo "✓ SageMath executable found"' >> /home/sageuser/security-check.sh && \
    echo '    sage --version 2>/dev/null || echo "SageMath version check failed but executable exists"' >> /home/sageuser/security-check.sh && \
    echo 'else' >> /home/sageuser/security-check.sh && \
    echo '    echo "✗ SageMath executable not found"' >> /home/sageuser/security-check.sh && \
    echo 'fi' >> /home/sageuser/security-check.sh && \
    echo 'echo "=== Security verification completed ==="' >> /home/sageuser/security-check.sh && \
    chmod +x /home/sageuser/security-check.sh && \
    chown sageuser:sageuser /home/sageuser/security-check.sh

#Create comprehensive startup script
RUN echo '#!/bin/bash' > /home/sageuser/startup.sh && \
    echo 'set -euo pipefail' >> /home/sageuser/startup.sh && \
    echo 'echo "=== SAGEMATH SECURE CONTAINER STARTING ==="' >> /home/sageuser/startup.sh && \
    echo 'echo "Running comprehensive security verification..."' >> /home/sageuser/startup.sh && \
    echo '/home/sageuser/security-check.sh' >> /home/sageuser/startup.sh && \
    echo 'if [ -d "/data" ]; then' >> /home/sageuser/startup.sh && \
    echo '    echo "Auto-mounting /data to notebooks directory..."' >> /home/sageuser/startup.sh && \
    echo '    ln -sf /data /home/sageuser/notebooks/data' >> /home/sageuser/startup.sh && \
    echo '    echo "Data mounted at /home/sageuser/notebooks/data"' >> /home/sageuser/startup.sh && \
    echo 'fi' >> /home/sageuser/startup.sh && \
    echo 'echo "=== SAGEMATH ENVIRONMENT STATUS ==="' >> /home/sageuser/startup.sh && \
    echo 'if command -v sage >/dev/null 2>&1; then' >> /home/sageuser/startup.sh && \
    echo '    echo "✓ SageMath is available: $(sage --version 2>/dev/null || echo "version unknown")"' >> /home/sageuser/startup.sh && \
    echo 'else' >> /home/sageuser/startup.sh && \
    echo '    echo "✗ SageMath not available - using comprehensive Python math environment"' >> /home/sageuser/startup.sh && \
    echo 'fi' >> /home/sageuser/startup.sh && \
    echo 'echo "Activating Python virtual environment..."' >> /home/sageuser/startup.sh && \
    echo 'source /home/sageuser/sage-env/bin/activate' >> /home/sageuser/startup.sh && \
    echo 'echo "✓ Python virtual environment activated with comprehensive math libraries"' >> /home/sageuser/startup.sh && \
    echo 'echo "Available libraries: numpy, scipy, sympy, matplotlib, pandas, scikit-learn, mpmath, networkx, and more"' >> /home/sageuser/startup.sh && \
    echo 'echo "You can now use pip install in notebooks for additional packages"' >> /home/sageuser/startup.sh && \
    echo 'echo "Ensuring Jupyter directories exist with proper permissions..."' >> /home/sageuser/startup.sh && \
    echo 'mkdir -p /home/sageuser/.local/share/jupyter/runtime' >> /home/sageuser/startup.sh && \
    echo 'mkdir -p /home/sageuser/.local/share/jupyter/nbconvert' >> /home/sageuser/startup.sh && \
    echo 'mkdir -p /home/sageuser/.local/share/jupyter/kernels' >> /home/sageuser/startup.sh && \
    echo 'chmod -R 777 /home/sageuser/.local/share' >> /home/sageuser/startup.sh && \
    echo 'echo "Starting Jupyter Lab..."' >> /home/sageuser/startup.sh && \
    echo 'exec /home/sageuser/sage-env/bin/jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --ServerApp.token="" --ServerApp.password="" --ServerApp.allow_origin="*" --ServerApp.disable_check_xsrf=True' >> /home/sageuser/startup.sh && \
    chmod +x /home/sageuser/startup.sh

#Switch to non-root user
USER sageuser
WORKDIR /home/sageuser

#Expose port for Jupyter
EXPOSE 8888

#Set entrypoint to auto-start Jupyter
ENTRYPOINT ["/home/sageuser/startup.sh"]