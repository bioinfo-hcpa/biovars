# Use the rpy2 base image
FROM rpy2/base-ubuntu

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    git \
    tar \
    libssl-dev

# Install pandoc
RUN wget -O pandoc.deb https://github.com/jgm/pandoc/releases/download/3.2/pandoc-3.2-1-amd64.deb && \
    dpkg -i pandoc.deb

# Download and install pynoma v0.2.1
RUN wget -O pynoma-0.2.1.tar.gz https://github.com/bioinfo-hcpa/pynoma/archive/refs/tags/v0.2.1.tar.gz && \
    tar -xzf pynoma-0.2.1.tar.gz && \
    pip install ./pynoma-0.2.1/

# Download and install pyABraOM v0.2.0
RUN wget -O pyABraOM-0.2.0.tar.gz https://github.com/bioinfo-hcpa/pyABraOM/archive/refs/tags/v0.2.0.tar.gz && \
    tar -xzf pyABraOM-0.2.0.tar.gz && \
    pip install ./pyABraOM-0.2.0/

# Install biovars from the latest GitHub repository
RUN git clone https://github.com/bioinfo-hcpa/biovars.git && \
    pip install ./biovars/[plots]

# Install R packages
RUN biovars -R
