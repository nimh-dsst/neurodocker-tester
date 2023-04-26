# Started by Neurodocker and Reproenv.
# Revised by Eric Earl.

FROM ubuntu:20.04
ENTRYPOINT ["/bin/bash"]
ENV PATH="/opt/afni-latest:$PATH" \
    AFNI_PLUGINPATH="/opt/afni-latest"
RUN apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
           ca-certificates \
           cmake \
           curl \
           ed \
           gsl-bin \
           libcurl4-openssl-dev \
           libgl1-mesa-dri \
           libglib2.0-0 \
           libglu1-mesa-dev \
           libglw1-mesa \
           libgomp1 \
           libjpeg-turbo8-dev \
           libjpeg62 \
           libssl-dev \
           libudunits2-dev \
           libxm4 \
           netpbm \
           python-is-python3 \
           python3-pip \
           tcsh \
           xfonts-base \
           xvfb \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get update -qq \
    && apt-get install --yes --quiet --fix-missing \
    && rm -rf /var/lib/apt/lists/* \
    && gsl_path="$(find / -name 'libgsl.so.??' || printf '')" \
    && if [ -n "$gsl_path" ]; then \
         ln -sfv "$gsl_path" "$(dirname $gsl_path)/libgsl.so.0"; \
    fi \
    && ldconfig \
    && mkdir -p /opt/afni-latest \
    && echo "Downloading AFNI ..." \
    && curl -fL https://afni.nimh.nih.gov/pub/dist/tgz/linux_openmp_64.tgz \
    | tar -xz -C /opt/afni-latest --strip-components 1
ENV FSLDIR="/usr/share/fsl/5.0" \
    PATH="/usr/share/fsl/5.0/bin:$PATH" \
    FSLOUTPUTTYPE="NIFTI_GZ" \
    FSLMULTIFILEQUIT="TRUE" \
    FSLTCLSH="/usr/share/fsl/5.0/bin/fsltclsh" \
    FSLWISH="/usr/share/fsl/5.0/bin/fslwish" \
    FSLLOCKDIR="" \
    FSLMACHINELIST="" \
    FSLREMOTECALL="" \
    FSLGECUDAQ="cuda.q"
RUN echo "Installing FSL ..." \
    && apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
           gnupg2 \
           wget \
    && wget -O- http://neuro.debian.net/lists/jammy.us-nh.full | tee /etc/apt/sources.list.d/neurodebian.sources.list \
    && apt-key adv --recv-keys --keyserver hkps://keyserver.ubuntu.com 0xA5D32F012649A5A9 \
    && apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
           bc \
           ca-certificates \
           curl \
           dc \
           file \
           fsl-core \
           libfontconfig1 \
           libfreetype6 \
           libgl1-mesa-dev \
           libgl1-mesa-dri \
           libglu1-mesa-dev \
           libgomp1 \
           libice6 \
           libopenblas-base \
           libxcursor1 \
           libxft2 \
           libxinerama1 \
           libxrandr2 \
           libxrender1 \
           libxt6 \
           nano \
    && rm -rf /var/lib/apt/lists/* \
ENV CONDA_DIR="/opt/miniconda-latest" \
    PATH="/opt/miniconda-latest/bin:$PATH"
RUN apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
           bzip2 \
           ca-certificates \
           curl \
    && rm -rf /var/lib/apt/lists/* \
    # Install dependencies.
    && export PATH="/opt/miniconda-latest/bin:$PATH" \
    && echo "Downloading Miniconda installer ..." \
    && conda_installer="/tmp/miniconda.sh" \
    && curl -fsSL -o "$conda_installer" https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && bash "$conda_installer" -b -p /opt/miniconda-latest \
    && rm -f "$conda_installer" \
    && conda update -yq -nbase conda \
    # Prefer packages in conda-forge
    && conda config --system --prepend channels conda-forge \
    # Packages in lower-priority channels not considered if a package with the same
    # name exists in a higher priority channel. Can dramatically speed up installations.
    # Conda recommends this as a default
    # https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-channels.html
    && conda config --set channel_priority strict \
    && conda config --system --set auto_update_conda false \
    && conda config --system --set show_channel_urls true \
    # Enable `conda activate`
    && conda init bash \
    && conda install -c conda-forge fsleyes --yes \
    && bash -c "source activate base \
    &&   python -m pip install --no-cache-dir  \
             "visualqc"" \
    # Clean up
    && sync && conda clean --all --yes && sync \
    && rm -rf ~/.cache/pip/*
