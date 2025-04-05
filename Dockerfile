# syntax=docker/dockerfile:1.4
FROM python:3.11-slim

# Add contrib/non-free repos FIRST
RUN echo "deb http://deb.debian.org/debian bookworm contrib non-free non-free-firmware" > /etc/apt/sources.list.d/contrib.list


# System dependencies
RUN apt-get update && \
    echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections && \
    apt-get install -y --no-install-recommends \
    bash build-essential python3-dev libblas-dev liblapack-dev gfortran \
    libfreetype6-dev libpng-dev texlive-latex-extra texlive-fonts-recommended \
    dvipng cm-super ghostscript ttf-mscorefonts-installer fontconfig \
    texlive texlive-latex-extra texlive-fonts-extra \
    texlive-latex-recommended texlive-science \
    tipa libpango1.0-dev libcairo2-dev ffmpeg \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && fc-cache -f -v


# Create non-root user
RUN useradd -m -u 1000 -s /bin/bash jupyter && \
    mkdir -p /home/jupyter/.jupyter && \
    mkdir -p /home/jupyter/notebooks && \
    chown -R jupyter:jupyter /home/jupyter

# Install Python packages
RUN pip install --no-cache-dir \
    terminado numpy scipy pandas matplotlib jupyterlab scienceplots \
    manim IPython


# Final setup
USER jupyter
WORKDIR /home/jupyter/notebooks
EXPOSE 8888

# Configure default URL for JupyterLab
RUN jupyter server --generate-config && \
    echo "c.ServerApp.default_url = '/lab'" >> /home/jupyter/.jupyter/jupyter_server_config.py

ENV JUPYTER_TOKEN=""
RUN echo "c.ServerApp.token = os.environ.get('JUPYTER_TOKEN', '')" >> /home/jupyter/.jupyter/jupyter_server_config.py

CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser"]
