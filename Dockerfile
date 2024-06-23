# Use the rpy2 base image
FROM rpy2/base-ubuntu

# Set the working directory in the container
#WORKDIR /usr/src/app

RUN apt-get update && apt-get install -y \
    wget \
    git \
    tar

# Download and install pynoma v0.2.0
RUN wget https://github.com/bioinfo-hcpa/pynoma/archive/refs/tags/v0.2.0.tar.gz && \
    tar -xzf v0.2.0.tar.gz && \
    cd pynoma-0.2.0 && \
    pip install .

# Download and install pyABraOM v0.2.0
RUN wget https://github.com/bioinfo-hcpa/pyABraOM/archive/refs/tags/v0.2.0.tar.gz && \
    tar -xzf v0.2.0.tar.gz && \
    cd pyABraOM-0.2.0 && \
    pip install .

# Copy the current directory contents into the container at /usr/src/app
#COPY . .

# Install biovars from the latest GitHub repository
RUN git clone https://github.com/bioinfo-hcpa/biovars.git && \
    cd biovars && \
    pip install .[plots]

# Install R packages
# RUN R -e "install.packages(c('ggplot2', 'ggthemes', 'gridExtra', 'egg', 'png', 'grid', 'cowplot', 'patchwork', 'httr', 'jsonlite', 'xml2', 'dplyr', 'RColorBrewer', 'stringr', 'gggenes', 'rmarkdown'), dependencies=TRUE, repos='http://cran.rstudio.com/')"
# RUN biovars -R
