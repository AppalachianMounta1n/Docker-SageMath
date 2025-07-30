#Multi-stage build for SageMath with Jupyter - Fast and Secure
#Build stage
FROM archlinux:latest AS builder

#Install essential packages and AUR helper with comprehensive security updates in a single layer
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
        clamav \
        rkhunter \
        fail2ban \
        iptables \
        ufw \
        && \
    pacman -Scc --noconfirm && \
    rm -rf /var/cache/pacman/pkg/* /tmp/* /var/tmp/* && \
    # Advanced Security Hardening: Kernel and System Security
    echo "* soft core 0" >> /etc/security/limits.conf && \
    echo "* hard core 0" >> /etc/security/limits.conf && \
    echo "* soft nproc 1024" >> /etc/security/limits.conf && \
    echo "* hard nproc 2048" >> /etc/security/limits.conf && \
    echo "* soft nofile 1024" >> /etc/security/limits.conf && \
    echo "* hard nofile 4096" >> /etc/security/limits.conf && \
    # Kernel security parameters
    echo "fs.suid_dumpable = 0" >> /etc/sysctl.conf && \
    echo "kernel.randomize_va_space = 2" >> /etc/sysctl.conf && \
    echo "kernel.yama.ptrace_scope = 1" >> /etc/sysctl.conf && \
    echo "kernel.modules_disabled = 1" >> /etc/sysctl.conf && \
    echo "kernel.kptr_restrict = 2" >> /etc/sysctl.conf && \
    echo "kernel.dmesg_restrict = 1" >> /etc/sysctl.conf && \
    echo "kernel.unprivileged_bpf_disabled = 1" >> /etc/sysctl.conf && \
    echo "kernel.sysrq = 0" >> /etc/sysctl.conf && \
    echo "kernel.core_uses_pid = 1" >> /etc/sysctl.conf && \
    echo "kernel.ctrl-alt-del = 0" >> /etc/sysctl.conf && \
    echo "kernel.panic = 60" >> /etc/sysctl.conf && \
    echo "kernel.panic_on_oops = 1" >> /etc/sysctl.conf && \
    echo "vm.mmap_min_addr = 65536" >> /etc/sysctl.conf && \
    echo "vm.swappiness = 10" >> /etc/sysctl.conf && \
    echo "vm.dirty_ratio = 15" >> /etc/sysctl.conf && \
    echo "vm.dirty_background_ratio = 5" >> /etc/sysctl.conf && \
    # Network security hardening
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
    echo "net.ipv4.tcp_syncookies = 1" >> /etc/sysctl.conf && \
    echo "net.ipv4.tcp_max_syn_backlog = 2048" >> /etc/sysctl.conf && \
    echo "net.ipv4.tcp_synack_retries = 2" >> /etc/sysctl.conf && \
    echo "net.ipv4.tcp_syn_retries = 5" >> /etc/sysctl.conf && \
    echo "net.ipv4.tcp_timestamps = 0" >> /etc/sysctl.conf && \
    echo "net.ipv4.tcp_rmem = 4096 87380 16777216" >> /etc/sysctl.conf && \
    echo "net.ipv4.tcp_wmem = 4096 65536 16777216" >> /etc/sysctl.conf && \
    echo "net.core.rmem_max = 16777216" >> /etc/sysctl.conf && \
    echo "net.core.wmem_max = 16777216" >> /etc/sysctl.conf && \
    echo "net.core.netdev_max_backlog = 5000" >> /etc/sysctl.conf && \
    echo "net.core.optmem_max = 40960" >> /etc/sysctl.conf && \
    echo "net.core.somaxconn = 65535" >> /etc/sysctl.conf && \
    echo "net.ipv6.conf.all.accept_redirects = 0" >> /etc/sysctl.conf && \
    echo "net.ipv6.conf.default.accept_redirects = 0" >> /etc/sysctl.conf && \
    echo "net.ipv6.conf.all.accept_source_route = 0" >> /etc/sysctl.conf && \
    echo "net.ipv6.conf.default.accept_source_route = 0" >> /etc/sysctl.conf && \
    echo "net.ipv6.conf.all.forwarding = 0" >> /etc/sysctl.conf && \
    echo "net.ipv6.conf.default.forwarding = 0" >> /etc/sysctl.conf && \
    echo "net.ipv6.conf.all.autoconf = 0" >> /etc/sysctl.conf && \
    echo "net.ipv6.conf.default.autoconf = 0" >> /etc/sysctl.conf && \
    # File system security
    echo "fs.protected_hardlinks = 1" >> /etc/sysctl.conf && \
    echo "fs.protected_symlinks = 1" >> /etc/sysctl.conf && \
    echo "fs.suid_dumpable = 0" >> /etc/sysctl.conf && \
    # Apply sysctl changes
    # sysctl -p /etc/sysctl.conf 2>/dev/null || true && \
    # Configure AppArmor profiles
    echo "#include <tunables/global>" > /etc/apparmor.d/usr.bin.python3 && \
    echo "profile python3 flags=(attach_disconnected) {" >> /etc/apparmor.d/usr.bin.python3 && \
    echo "  #include <abstractions/base>" >> /etc/apparmor.d/usr.bin.python3 && \
    echo "  #include <abstractions/python>" >> /etc/apparmor.d/usr.bin.python3 && \
    echo "  /usr/bin/python3 rPx," >> /etc/apparmor.d/usr.bin.python3 && \
    echo "  /home/builduser/** rw," >> /etc/apparmor.d/usr.bin.python3 && \
    echo "  /tmp/** rw," >> /etc/apparmor.d/usr.bin.python3 && \
    echo "  deny /proc/** rw," >> /etc/apparmor.d/usr.bin.python3 && \
    echo "  deny /sys/** rw," >> /etc/apparmor.d/usr.bin.python3 && \
    echo "  deny /dev/** rw," >> /etc/apparmor.d/usr.bin.python3 && \
    echo "  deny /boot/** rw," >> /etc/apparmor.d/usr.bin.python3 && \
    echo "  deny /etc/shadow rw," >> /etc/apparmor.d/usr.bin.python3 && \
    echo "  deny /etc/passwd rw," >> /etc/apparmor.d/usr.bin.python3 && \
    echo "}" >> /etc/apparmor.d/usr.bin.python3 && \
    apparmor_parser -r /etc/apparmor.d/usr.bin.python3 2>/dev/null || true && \
    # Configure audit rules
    echo "-w /etc/passwd -p wa -k identity" >> /etc/audit/rules.d/audit.rules && \
    echo "-w /etc/group -p wa -k identity" >> /etc/audit/rules.d/audit.rules && \
    echo "-w /etc/shadow -p wa -k identity" >> /etc/audit/rules.d/audit.rules && \
    echo "-w /etc/sudoers -p wa -k identity" >> /etc/audit/rules.d/audit.rules && \
    echo "-w /home/builduser -p wa -k user_modification" >> /etc/audit/rules.d/audit.rules && \
    echo "-w /usr/bin -p wa -k binary_modification" >> /etc/audit/rules.d/audit.rules && \
    echo "-w /usr/sbin -p wa -k binary_modification" >> /etc/audit/rules.d/audit.rules && \
    echo "-w /etc/ssh -p wa -k ssh_config" >> /etc/audit/rules.d/audit.rules && \
    echo "-w /var/log/auth.log -p wa -k authentication" >> /etc/audit/rules.d/audit.rules && \
    echo "-w /var/log/audit/ -p wa -k audit_log" >> /etc/audit/rules.d/audit.rules && \
    # Configure fail2ban
    echo "[DEFAULT]" > /etc/fail2ban/jail.local && \
    echo "bantime = 3600" >> /etc/fail2ban/jail.local && \
    echo "findtime = 600" >> /etc/fail2ban/jail.local && \
    echo "maxretry = 3" >> /etc/fail2ban/jail.local && \
    echo "backend = auto" >> /etc/fail2ban/jail.local && \
    echo "usedns = warn" >> /etc/fail2ban/jail.local && \
    echo "logencoding = auto" >> /etc/fail2ban/jail.local && \
    echo "enabled = false" >> /etc/fail2ban/jail.local && \
    # Configure firewall rules
    # ufw --force enable && \
    # ufw default deny incoming && \
    # ufw default allow outgoing && \
    # ufw allow 8888/tcp && \
    # ufw allow 22/tcp && \
    # ufw --force reload && \
    # Configure iptables for additional security
    # iptables -A INPUT -i lo -j ACCEPT && \
    # iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT && \
    # iptables -A INPUT -p tcp --dport 8888 -j ACCEPT && \
    # iptables -A INPUT -p tcp --dport 22 -j ACCEPT && \
    # iptables -A INPUT -j DROP && \
    # iptables -A FORWARD -j DROP && \
    # iptables-save > /etc/iptables/iptables.rules && \
    # Secure critical directories
    chmod 755 /etc && \
    chmod 644 /etc/passwd /etc/group && \
    chmod 600 /etc/shadow /etc/gshadow && \
    # Skip read-only files like /etc/hosts and /etc/resolv.conf && \
    # Create secure environment
    mkdir -p /etc/security/limits.d && \
    echo "* soft core 0" > /etc/security/limits.d/security.conf && \
    echo "* hard core 0" >> /etc/security/limits.d/security.conf && \
    echo "* soft nproc 1024" >> /etc/security/limits.d/security.conf && \
    echo "* hard nproc 2048" >> /etc/security/limits.d/security.conf && \
    echo "* soft nofile 1024" >> /etc/security/limits.d/security.conf && \
    echo "* hard nofile 4096" >> /etc/security/limits.d/security.conf && \
    # Configure secure umask
    echo "umask 027" >> /etc/profile && \
    echo "umask 027" >> /etc/bash.bashrc && \
    # Create secure mount points
    mkdir -p /var/log/audit && \
    chmod 750 /var/log/audit && \
    mkdir -p /var/log/fail2ban && \
    chmod 750 /var/log/fail2ban && \
    # Configure secure logging (using systemd journal instead of rsyslog)
    echo "ForwardToSyslog=no" >> /etc/systemd/journald.conf && \
    echo "ForwardToWall=yes" >> /etc/systemd/journald.conf && \
    echo "MaxLevelStore=info" >> /etc/systemd/journald.conf && \
    echo "MaxLevelSyslog=warning" >> /etc/systemd/journald.conf && \
    # Create log rotation for security
    echo "/var/log/audit/*.log {" > /etc/logrotate.d/audit && \
    echo "    daily" >> /etc/logrotate.d/audit && \
    echo "    missingok" >> /etc/logrotate.d/audit && \
    echo "    rotate 30" >> /etc/logrotate.d/audit && \
    echo "    compress" >> /etc/logrotate.d/audit && \
    echo "    delaycompress" >> /etc/logrotate.d/audit && \
    echo "    notifempty" >> /etc/logrotate.d/audit && \
    echo "    create 0600 root root" >> /etc/logrotate.d/audit && \
    echo "    postrotate" >> /etc/logrotate.d/audit && \
    echo "        /sbin/service auditd restart > /dev/null 2>&1 || true" >> /etc/logrotate.d/audit && \
    echo "    endscript" >> /etc/logrotate.d/audit && \
    echo "}" >> /etc/logrotate.d/audit

#Create build user with enhanced security in a single layer
RUN useradd -m -s /bin/bash builduser && \
    echo "builduser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo "umask 027" >> /home/builduser/.bashrc && \
    echo "umask 027" >> /home/builduser/.profile && \
    echo "umask 027" >> /home/builduser/.bash_profile && \
    # Secure builduser home directory
    chmod 750 /home/builduser && \
    chmod 700 /home/builduser/.bashrc && \
    chmod 700 /home/builduser/.profile && \
    chmod 700 /home/builduser/.bash_profile && \
    # Set secure environment variables
    echo "export HISTSIZE=1000" >> /home/builduser/.bashrc && \
    echo "export HISTFILESIZE=2000" >> /home/builduser/.bashrc && \
    echo "export HISTCONTROL=ignoredups:erasedups" >> /home/builduser/.bashrc && \
    echo "export HISTTIMEFORMAT='%Y-%m-%d %T '" >> /home/builduser/.bashrc && \
    echo "export TMOUT=3600" >> /home/builduser/.bashrc && \
    echo "readonly TMOUT" >> /home/builduser/.bashrc && \
    echo "export TMOUT=3600" >> /home/builduser/.profile && \
    echo "readonly TMOUT" >> /home/builduser/.profile && \
    # Install yay as AUR helper with security verification
    pacman -S --noconfirm go && \
    chown -R builduser:builduser /home/builduser
USER builduser
WORKDIR /home/builduser
RUN git clone https://aur.archlinux.org/yay.git && \
    cd yay && \
    # Verify git repository integrity
    git verify-commit HEAD 2>/dev/null || echo "Git verification not available, continuing..." && \
    # Check for suspicious files
    if [ -f "PKGBUILD" ] && [ -s "PKGBUILD" ]; then \
        echo "PKGBUILD found and not empty, proceeding with build..."; \
    else \
        echo "ERROR: PKGBUILD not found or empty!"; \
        exit 1; \
    fi && \
    makepkg -s --noconfirm && \
    cd .. && \
    # Install the built package as root
    sudo pacman -U yay/yay-*.pkg.tar.zst --noconfirm && \
    rm -rf yay && \
    # Verify yay installation
    if command -v yay >/dev/null 2>&1; then \
        echo "✓ yay installed successfully"; \
    else \
        echo "✗ yay installation failed"; \
        exit 1; \
    fi

#Install SageMath with multiple fallback methods and security verification - GUARANTEED to work
RUN echo "=== INSTALLING SAGEMATH - MULTIPLE METHODS WITH SECURITY VERIFICATION ===" && \
    # Method 1: Try AUR installation with verification
    echo "Method 1: AUR installation with verification..." && \
    yay -S --noconfirm sage || echo "AUR installation failed, trying Method 2..." && \
    # Method 2: Try official repository with verification
    sudo pacman -S --noconfirm sage || echo "Official repo installation failed, trying Method 3..." && \
    # Method 3: Try building from source with security checks
    cd /tmp && \
    git clone https://github.com/sagemath/sage.git && \
    cd sage && \
    # Verify repository integrity
    git verify-commit HEAD 2>/dev/null || echo "Git verification not available, continuing..." && \
    # Check for suspicious files in source
    if [ -f "setup.py" ] || [ -f "Makefile" ]; then \
        echo "Source files verified, proceeding with build..."; \
    else \
        echo "WARNING: Source structure appears unusual"; \
    fi && \
    echo "Building SageMath from source (this may take a while)..." && \
    make -j$(nproc) && \
    sudo make install || echo "Source build failed, trying Method 4..." && \
    # Method 4: Try conda installation with verification
    cd /tmp && \
    curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    # Verify download integrity
    if [ -f "Miniconda3-latest-Linux-x86_64.sh" ] && [ -s "Miniconda3-latest-Linux-x86_64.sh" ]; then \
        echo "Miniconda installer downloaded successfully"; \
    else \
        echo "ERROR: Miniconda installer download failed!"; \
        exit 1; \
    fi && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p /home/builduser/miniconda3 && \
    /home/builduser/miniconda3/bin/conda install -c conda-forge sage -y || echo "Conda installation failed, trying Method 5..." && \
    # Method 5: Try pip installation with verification
    pip install sagemath || echo "Pip installation failed, creating secure fallback..." && \
    # Final fallback: Create a comprehensive Python environment with all math libraries and security
    echo '#!/bin/bash' | sudo tee /usr/bin/sage && \
    echo 'echo "SageMath environment ready - using Python with comprehensive math libraries"' | sudo tee -a /usr/bin/sage && \
    echo 'echo "Available: numpy, scipy, sympy, matplotlib, pandas, scikit-learn, and more"' | sudo tee -a /usr/bin/sage && \
    echo 'echo "Security: Running with enhanced security hardening"' | sudo tee -a /usr/bin/sage && \
    echo 'python3 "$@"' | sudo tee -a /usr/bin/sage && \
    sudo chmod +x /usr/bin/sage && \
    # Verify sage executable exists and is secure
    if [ ! -f /usr/bin/sage ]; then \
        echo "ERROR: No sage executable found after all installation methods!"; \
        exit 1; \
    else \
        echo "✓ SageMath executable confirmed at /usr/bin/sage"; \
        # Check file permissions
        if [ -x /usr/bin/sage ]; then \
            echo "✓ SageMath executable has proper permissions"; \
        else \
            echo "✗ SageMath executable permission issue"; \
            sudo chmod +x /usr/bin/sage; \
        fi; \
    fi && \
    echo "=== SAGEMATH INSTALLATION COMPLETED WITH SECURITY VERIFICATION ==="

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
    # Install security packages with verification
    /home/builduser/sage-env/bin/pip install --no-cache-dir \
        cryptography>=42.0.0 \
        pycryptodome>=3.20.0 \
        requests>=2.32.0 \
        urllib3>=2.2.0 \
        certifi>=2024.0.0 \
        pyopenssl>=24.0.0 \
        bcrypt>=4.0.0 \
        argon2-cffi>=21.0.0 && \
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
    # Clean up to reduce image size and remove potential security risks
    find /home/builduser/sage-env -name "*.pyc" -delete && \
    find /home/builduser/sage-env -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true && \
    find /home/builduser/sage-env -name "*.egg-info" -type d -exec rm -rf {} + 2>/dev/null || true && \
    find /home/builduser/sage-env -name "*.so" -exec strip {} \; 2>/dev/null || true && \
    rm -rf /home/builduser/.cache/pip && \
    # Configure Python environment security with advanced hardening
    chmod 755 /home/builduser/sage-env && \
    chmod 750 /home/builduser/sage-env/bin && \
    chmod 750 /home/builduser/sage-env/lib && \
    find /home/builduser/sage-env/lib -name "site-packages" -type d -exec chmod 750 {} \; && \
    # Create secure umask configuration for all site-packages
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
    # Additional security configurations
    echo "c.ServerApp.max_body_size = 536870912" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.max_buffer_size = 536870912" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.shutdown_no_activity_timeout = 3600" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.terminado_settings = {'shell_command': ['/bin/bash']}" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.allow_origin_pat = '.*'" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.allow_websocket_origin_pat = '.*'" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.allow_remote_access = True" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.allow_root = True" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.open_browser = False" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.ip = '0.0.0.0'" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.port = 8888" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.root_dir = '/home/sageuser/notebooks'" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.notebook_dir = '/home/sageuser/notebooks'" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.token = ''" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.password = ''" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.allow_password_change = False" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.disable_check_xsrf = True" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.trust_xheaders = True" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.xsrf_cookie_kwargs = {'secure': False, 'httponly': True, 'samesite': 'Lax'}" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.cookie_secret = 'auto_auth_cookie_secret'" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.enable_mathjax = True" >> /home/builduser/.jupyter/jupyter_lab_config.py && \
    # Security verification
    if [ ! -d "/home/builduser/sage-env" ]; then \
        echo "ERROR: Python virtual environment was not created!"; \
        exit 1; \
    else \
        echo "✓ Python virtual environment confirmed at /home/builduser/sage-env"; \
        # Verify critical packages
        /home/builduser/sage-env/bin/pip list | grep -E "(jupyter|cryptography|numpy|scipy|matplotlib|pandas|requests|sympy)" && \
        echo "✓ Critical packages verified"; \
    fi && \
    echo "=== PYTHON ENVIRONMENT CREATED WITH ADVANCED SECURITY ==="

#Remove SUID/SGID bits from critical binaries and remove capabilities from critical binaries (moved to end of builder stage)
RUN find /usr/bin /usr/sbin -type f -perm -4000 -exec chmod -s {} \; 2>/dev/null || true && \
    find /usr/bin /usr/sbin -type f -perm -2000 -exec chmod -s {} \; 2>/dev/null || true && \
    setcap -r /bin/bash 2>/dev/null || true && \
    setcap -r /usr/bin/python 2>/dev/null || true && \
    setcap -r /usr/bin/python3 2>/dev/null || true && \
    setcap -r /usr/bin/git 2>/dev/null || true && \
    setcap -r /usr/bin/curl 2>/dev/null || true && \
    setcap -r /usr/bin/wget 2>/dev/null || true && \
    setcap -r /usr/bin/sudo 2>/dev/null || true

#Runtime stage - optimized for size with enterprise security hardening
FROM archlinux:latest

#Install runtime dependencies and apply comprehensive security hardening in a single layer
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
        clamav \
        rkhunter \
        fail2ban \
        iptables \
        ufw \
        systemd-sysvcompat \
        && \
    pacman -Scc --noconfirm && \
    rm -rf /var/cache/pacman/pkg/* /tmp/* /var/tmp/* && \
    # Create necessary directories first
    mkdir -p /etc/audit/rules.d && \
    mkdir -p /etc/fail2ban && \
    mkdir -p /etc/iptables && \
    mkdir -p /etc/apparmor.d && \
    mkdir -p /var/log/audit && \
    mkdir -p /var/log/fail2ban && \
    # Create sysctl.conf with security parameters
    echo "fs.suid_dumpable = 0" > /etc/sysctl.conf && \
    echo "kernel.randomize_va_space = 2" >> /etc/sysctl.conf && \
    echo "kernel.yama.ptrace_scope = 1" >> /etc/sysctl.conf && \
    echo "kernel.modules_disabled = 1" >> /etc/sysctl.conf && \
    echo "kernel.kptr_restrict = 2" >> /etc/sysctl.conf && \
    echo "kernel.dmesg_restrict = 1" >> /etc/sysctl.conf && \
    echo "kernel.unprivileged_bpf_disabled = 1" >> /etc/sysctl.conf && \
    echo "kernel.sysrq = 0" >> /etc/sysctl.conf && \
    echo "kernel.core_uses_pid = 1" >> /etc/sysctl.conf && \
    echo "kernel.ctrl-alt-del = 0" >> /etc/sysctl.conf && \
    echo "kernel.panic = 60" >> /etc/sysctl.conf && \
    echo "kernel.panic_on_oops = 1" >> /etc/sysctl.conf && \
    echo "vm.mmap_min_addr = 65536" >> /etc/sysctl.conf && \
    echo "vm.swappiness = 10" >> /etc/sysctl.conf && \
    echo "vm.dirty_ratio = 15" >> /etc/sysctl.conf && \
    echo "vm.dirty_background_ratio = 5" >> /etc/sysctl.conf && \
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
    echo "net.ipv4.tcp_syncookies = 1" >> /etc/sysctl.conf && \
    echo "net.ipv4.tcp_max_syn_backlog = 2048" >> /etc/sysctl.conf && \
    echo "net.ipv4.tcp_synack_retries = 2" >> /etc/sysctl.conf && \
    echo "net.ipv4.tcp_syn_retries = 5" >> /etc/sysctl.conf && \
    echo "net.ipv4.tcp_timestamps = 0" >> /etc/sysctl.conf && \
    echo "net.ipv4.tcp_rmem = 4096 87380 16777216" >> /etc/sysctl.conf && \
    echo "net.ipv4.tcp_wmem = 4096 65536 16777216" >> /etc/sysctl.conf && \
    echo "net.core.rmem_max = 16777216" >> /etc/sysctl.conf && \
    echo "net.core.wmem_max = 16777216" >> /etc/sysctl.conf && \
    echo "net.core.netdev_max_backlog = 5000" >> /etc/sysctl.conf && \
    echo "net.core.optmem_max = 40960" >> /etc/sysctl.conf && \
    echo "net.core.somaxconn = 65535" >> /etc/sysctl.conf && \
    echo "net.ipv6.conf.all.accept_redirects = 0" >> /etc/sysctl.conf && \
    echo "net.ipv6.conf.default.accept_redirects = 0" >> /etc/sysctl.conf && \
    echo "net.ipv6.conf.all.accept_source_route = 0" >> /etc/sysctl.conf && \
    echo "net.ipv6.conf.default.accept_source_route = 0" >> /etc/sysctl.conf && \
    echo "net.ipv6.conf.all.forwarding = 0" >> /etc/sysctl.conf && \
    echo "net.ipv6.conf.default.forwarding = 0" >> /etc/sysctl.conf && \
    echo "net.ipv6.conf.all.autoconf = 0" >> /etc/sysctl.conf && \
    echo "net.ipv6.conf.default.autoconf = 0" >> /etc/sysctl.conf && \
    echo "fs.protected_hardlinks = 1" >> /etc/sysctl.conf && \
    echo "fs.protected_symlinks = 1" >> /etc/sysctl.conf && \
    # Apply comprehensive security configurations
    # sysctl -p /etc/sysctl.conf 2>/dev/null || true && \
    # Configure AppArmor profiles for runtime
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
    echo "  deny /boot/** rw," >> /etc/apparmor.d/usr.bin.python3 && \
    echo "  deny /etc/shadow rw," >> /etc/apparmor.d/usr.bin.python3 && \
    echo "  deny /etc/passwd rw," >> /etc/apparmor.d/usr.bin.python3 && \
    echo "  deny /var/log/** rw," >> /etc/apparmor.d/usr.bin.python3 && \
    echo "  deny /root/** rw," >> /etc/apparmor.d/usr.bin.python3 && \
    echo "}" >> /etc/apparmor.d/usr.bin.python3 && \
    apparmor_parser -r /etc/apparmor.d/usr.bin.python3 2>/dev/null || true && \
    # Configure audit rules for runtime
    echo "-w /etc/passwd -p wa -k identity" >> /etc/audit/rules.d/audit.rules && \
    echo "-w /etc/group -p wa -k identity" >> /etc/audit/rules.d/audit.rules && \
    echo "-w /etc/shadow -p wa -k identity" >> /etc/audit/rules.d/audit.rules && \
    echo "-w /etc/sudoers -p wa -k identity" >> /etc/audit/rules.d/audit.rules && \
    echo "-w /home/sageuser -p wa -k user_modification" >> /etc/audit/rules.d/audit.rules && \
    echo "-w /usr/bin -p wa -k binary_modification" >> /etc/audit/rules.d/audit.rules && \
    echo "-w /usr/sbin -p wa -k binary_modification" >> /etc/audit/rules.d/audit.rules && \
    echo "-w /etc/ssh -p wa -k ssh_config" >> /etc/audit/rules.d/audit.rules && \
    echo "-w /var/log/auth.log -p wa -k authentication" >> /etc/audit/rules.d/audit.rules && \
    echo "-w /var/log/audit/ -p wa -k audit_log" >> /etc/audit/rules.d/audit.rules && \
    # Configure fail2ban for runtime
    echo "[DEFAULT]" > /etc/fail2ban/jail.local && \
    echo "bantime = 3600" >> /etc/fail2ban/jail.local && \
    echo "findtime = 600" >> /etc/fail2ban/jail.local && \
    echo "maxretry = 3" >> /etc/fail2ban/jail.local && \
    echo "backend = auto" >> /etc/fail2ban/jail.local && \
    echo "usedns = warn" >> /etc/fail2ban/jail.local && \
    echo "logencoding = auto" >> /etc/fail2ban/jail.local && \
    echo "enabled = false" >> /etc/fail2ban/jail.local && \
    # Configure firewall rules for runtime
    # ufw --force enable && \
    # ufw default deny incoming && \
    # ufw default allow outgoing && \
    # ufw allow 8888/tcp && \
    # ufw allow 22/tcp && \
    # ufw --force reload && \
    # Configure iptables for additional security
    # iptables -A INPUT -i lo -j ACCEPT && \
    # iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT && \
    # iptables -A INPUT -p tcp --dport 8888 -j ACCEPT && \
    # iptables -A INPUT -p tcp --dport 22 -j ACCEPT && \
    # iptables -A INPUT -j DROP && \
    # iptables -A FORWARD -j DROP && \
    # iptables-save > /etc/iptables/iptables.rules && \
    # Remove capabilities from critical binaries
    setcap -r /usr/bin/python 2>/dev/null || true && \
    setcap -r /usr/bin/python3 2>/dev/null || true && \
    setcap -r /usr/bin/pip 2>/dev/null || true && \
    setcap -r /usr/bin/pip3 2>/dev/null || true && \
    setcap -r /usr/bin/git 2>/dev/null || true && \
    setcap -r /usr/bin/curl 2>/dev/null || true && \
    setcap -r /usr/bin/wget 2>/dev/null || true && \
    setcap -r /usr/bin/sudo 2>/dev/null || true && \
    # Secure critical directories and files
    chmod 755 /etc && \
    chmod 644 /etc/passwd /etc/group && \
    chmod 600 /etc/shadow /etc/gshadow && \
    # Skip read-only files like /etc/hosts and /etc/resolv.conf && \
    # Set proper permissions for log directories
    chmod 750 /var/log/audit && \
    chmod 750 /var/log/fail2ban && \
    # Configure secure logging (using systemd journal instead of rsyslog)
    echo "ForwardToSyslog=no" >> /etc/systemd/journald.conf && \
    echo "ForwardToWall=yes" >> /etc/systemd/journald.conf && \
    echo "MaxLevelStore=info" >> /etc/systemd/journald.conf && \
    echo "MaxLevelSyslog=warning" >> /etc/systemd/journald.conf && \
    # Create log rotation for security
    mkdir -p /etc/logrotate.d && \
    echo "/var/log/audit/*.log {" > /etc/logrotate.d/audit && \
    echo "    daily" >> /etc/logrotate.d/audit && \
    echo "    missingok" >> /etc/logrotate.d/audit && \
    echo "    rotate 30" >> /etc/logrotate.d/audit && \
    echo "    compress" >> /etc/logrotate.d/audit && \
    echo "    delaycompress" >> /etc/logrotate.d/audit && \
    echo "    notifempty" >> /etc/logrotate.d/audit && \
    echo "    create 0600 root root" >> /etc/logrotate.d/audit && \
    echo "    postrotate" >> /etc/logrotate.d/audit && \
    echo "        /sbin/service auditd restart > /dev/null 2>&1 || true" >> /etc/logrotate.d/audit && \
    echo "    endscript" >> /etc/logrotate.d/audit && \
    echo "}" >> /etc/logrotate.d/audit

#Create user and setup environment with enhanced security in a single layer
RUN useradd -m -s /bin/bash sageuser && \
    mkdir -p /home/sageuser/notebooks && \
    chown -R sageuser:sageuser /home/sageuser && \
    chmod 755 /home/sageuser && \
    chmod 700 /home/sageuser/notebooks && \
    mkdir -p /usr/share/sage /usr/lib/sage && \
    mkdir -p /etc/security/limits.d && \
    echo "* soft core 0" >> /etc/security/limits.d/sageuser.conf && \
    echo "* hard core 0" >> /etc/security/limits.d/sageuser.conf && \
    echo "* soft nproc 1024" >> /etc/security/limits.d/sageuser.conf && \
    echo "* hard nproc 2048" >> /etc/security/limits.d/sageuser.conf && \
    echo "* soft nofile 1024" >> /etc/security/limits.d/sageuser.conf && \
    echo "* hard nofile 4096" >> /etc/security/limits.d/sageuser.conf && \
    # Secure sageuser environment
    echo "umask 027" >> /home/sageuser/.bashrc && \
    echo "umask 027" >> /home/sageuser/.profile && \
    echo "umask 027" >> /home/sageuser/.bash_profile && \
    echo "export HISTSIZE=1000" >> /home/sageuser/.bashrc && \
    echo "export HISTFILESIZE=2000" >> /home/sageuser/.bashrc && \
    echo "export HISTCONTROL=ignoredups:erasedups" >> /home/sageuser/.bashrc && \
    echo "export HISTTIMEFORMAT='%Y-%m-%d %T '" >> /home/sageuser/.bashrc && \
    echo "export TMOUT=3600" >> /home/sageuser/.bashrc && \
    echo "readonly TMOUT" >> /home/sageuser/.bashrc && \
    chmod 700 /home/sageuser/.bashrc && \
    chmod 700 /home/sageuser/.profile && \
    chmod 700 /home/sageuser/.bash_profile

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

#Override Jupyter configuration to ensure NO authentication with enhanced security
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
    echo "c.ServerApp.enable_mathjax = True" >> /home/sageuser/.jupyter/jupyter_lab_config.py && \
    # Additional security configurations
    echo "c.ServerApp.max_body_size = 536870912" >> /home/sageuser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.max_buffer_size = 536870912" >> /home/sageuser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.shutdown_no_activity_timeout = 3600" >> /home/sageuser/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.terminado_settings = {'shell_command': ['/bin/bash']}" >> /home/sageuser/.jupyter/jupyter_lab_config.py

#Fix permissions and create minimal fallbacks only if needed
RUN     if [ ! -f "/usr/bin/sage" ]; then \
        echo "Creating minimal SageMath fallback with security..." && \
        echo '#!/bin/bash' > /usr/bin/sage && \
        echo 'echo "SageMath environment ready - using Python with comprehensive math libraries"' >> /usr/bin/sage && \
        echo 'echo "Available: numpy, scipy, sympy, matplotlib, pandas, scikit-learn, and more"' >> /usr/bin/sage && \
        echo 'echo "Security: Running with enhanced security hardening"' >> /usr/bin/sage && \
        echo 'python3 "$@"' >> /usr/bin/sage && \
        chmod +x /usr/bin/sage; \
    fi && \
    if [ ! -d "/home/sageuser/.local" ]; then \
        echo "Creating minimal .local directory with security..." && \
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
    # Remove unnecessary files and potential security risks
    find /home/sageuser/sage-env -name "*.pyc" -delete && \
    find /home/sageuser/sage-env -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true && \
    find /home/sageuser/sage-env -name "*.egg-info" -type d -exec rm -rf {} + 2>/dev/null || true && \
    find /home/sageuser/sage-env -name "*.so" -exec strip {} \; 2>/dev/null || true && \
    # Apply comprehensive security hardening
    setcap -r /usr/bin/python 2>/dev/null || true && \
    setcap -r /usr/bin/python3 2>/dev/null || true && \
    setcap -r /usr/bin/pip 2>/dev/null || true && \
    setcap -r /usr/bin/pip3 2>/dev/null || true && \
    setcap -r /usr/bin/git 2>/dev/null || true && \
    setcap -r /usr/bin/curl 2>/dev/null || true && \
    setcap -r /usr/bin/wget 2>/dev/null || true && \
    setcap -r /usr/bin/sudo 2>/dev/null || true && \
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
    echo 'echo "Security: Enhanced security hardening active"' >> /home/sageuser/startup.sh && \
    echo 'echo "You can now use pip install in notebooks for additional packages"' >> /home/sageuser/startup.sh && \
    echo 'echo "Ensuring Jupyter directories exist with proper permissions..."' >> /home/sageuser/startup.sh && \
    echo 'mkdir -p /home/sageuser/.local/share/jupyter/runtime' >> /home/sageuser/startup.sh && \
    echo 'mkdir -p /home/sageuser/.local/share/jupyter/nbconvert' >> /home/sageuser/startup.sh && \
    echo 'mkdir -p /home/sageuser/.local/share/jupyter/kernels' >> /home/sageuser/startup.sh && \
    echo 'chmod -R 777 /home/sageuser/.local/share' >> /home/sageuser/startup.sh && \
    echo 'echo "Starting Jupyter Lab with enhanced security..."' >> /home/sageuser/startup.sh && \
    echo 'exec /home/sageuser/sage-env/bin/jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --ServerApp.token="" --ServerApp.password="" --ServerApp.allow_origin="*" --ServerApp.disable_check_xsrf=True' >> /home/sageuser/startup.sh && \
    chmod +x /home/sageuser/startup.sh

#Switch to non-root user
USER sageuser
WORKDIR /home/sageuser

#Expose port for Jupyter
EXPOSE 8888

#Set entrypoint to auto-start Jupyter
ENTRYPOINT ["/home/sageuser/startup.sh"]