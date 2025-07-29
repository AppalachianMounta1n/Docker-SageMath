#Multi-stage build for SageMath with Jupyter
#Build stage
FROM archlinux:latest as builder

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
RUN yay -S --noconfirm sage || (echo "AUR installation failed, installing SageMath from source..." && \
    cd /tmp && \
    git clone https://github.com/sagemath/sage.git && \
    cd sage && \
    make -j$(nproc) && \
    make install)

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
        && \
    /home/builduser/sage-env/bin/jupyter lab build

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
COPY --from=builder /usr/share/sage* /usr/share/
COPY --from=builder /usr/lib/sage* /usr/lib/
COPY --from=builder /home/builduser/.local /home/sageuser/.local
COPY --from=builder /home/builduser/.jupyter /home/sageuser/.jupyter
COPY --from=builder /home/builduser/sage-env /home/sageuser/sage-env

#Fix permissions and shebang paths
RUN chown -R sageuser:sageuser /home/sageuser/sage-env && \
    chmod +x /home/sageuser/sage-env/bin/* && \
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
    echo 'echo "Activating Python virtual environment..."' >> /home/sageuser/startup.sh && \
    echo 'source /home/sageuser/sage-env/bin/activate' >> /home/sageuser/startup.sh && \
    echo 'echo "Python virtual environment activated. You can now use pip install in notebooks."' >> /home/sageuser/startup.sh && \
    echo 'echo "Starting Jupyter Lab..."' >> /home/sageuser/startup.sh && \
    echo 'exec /home/sageuser/sage-env/bin/jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root' >> /home/sageuser/startup.sh && \
    chmod +x /home/sageuser/startup.sh

#Expose port for Jupyter
EXPOSE 8888

#Set entrypoint to auto-start Jupyter
ENTRYPOINT ["/home/sageuser/startup.sh"]