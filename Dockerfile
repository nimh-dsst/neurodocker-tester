# Started by Neurodocker and Reproenv.
# Revised by Eric Earl.

FROM ubuntu:22.04
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
ENV FSLDIR="/opt/fsl-6.0.5.1" \
    PATH="/opt/fsl-6.0.5.1/bin:$PATH" \
    FSLOUTPUTTYPE="NIFTI_GZ" \
    FSLMULTIFILEQUIT="TRUE" \
    FSLTCLSH="/opt/fsl-6.0.5.1/bin/fsltclsh" \
    FSLWISH="/opt/fsl-6.0.5.1/bin/fslwish" \
    FSLLOCKDIR="" \
    FSLMACHINELIST="" \
    FSLREMOTECALL="" \
    FSLGECUDAQ="cuda.q"
RUN apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
           bc \
           ca-certificates \
           curl \
           dc \
           file \
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
           sudo \
           wget \
    && rm -rf /var/lib/apt/lists/* \
    && echo "Downloading FSL ..." \
    && mkdir -p /opt/fsl-6.0.5.1 \
    && curl -fL https://fsl.fmrib.ox.ac.uk/fsldownloads/fsl-6.0.5.1-centos7_64.tar.gz \
    | tar -xz -C /opt/fsl-6.0.5.1 --strip-components 1 \
    && echo "Installing FSL conda environment ..." \
    && bash /opt/fsl-6.0.5.1/etc/fslconf/fslpython_install.sh -f /opt/fsl-6.0.5.1
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
    && bash -c "source activate base \
    &&   python -m pip install --no-cache-dir  \
             "visualqc"" \
    # Clean up
    && sync && conda clean --all --yes && sync \
    && rm -rf ~/.cache/pip/*

# Save specification to JSON.
RUN printf '{ \
  "pkg_manager": "apt", \
  "existing_users": [ \
    "root" \
  ], \
  "instructions": [ \
    { \
      "name": "from_", \
      "kwds": { \
        "base_image": "ubuntu:22.04" \
      } \
    }, \
    { \
      "name": "entrypoint", \
      "kwds": { \
        "args": [ \
          "/bin/bash" \
        ] \
      } \
    }, \
    { \
      "name": "env", \
      "kwds": { \
        "PATH": "/opt/afni-latest:$PATH", \
        "AFNI_PLUGINPATH": "/opt/afni-latest" \
      } \
    }, \
    { \
      "name": "run", \
      "kwds": { \
        "command": "apt-get update -qq\\napt-get install -y -q --no-install-recommends \\\\\\n    ca-certificates \\\\\\n    cmake \\\\\\n    curl \\\\\\n    ed \\\\\\n    gsl-bin \\\\\\n    libcurl4-openssl-dev \\\\\\n    libgl1-mesa-dri \\\\\\n    libglib2.0-0 \\\\\\n    libglu1-mesa-dev \\\\\\n    libglw1-mesa \\\\\\n    libgomp1 \\\\\\n    libjpeg-turbo8-dev \\\\\\n    libjpeg62 \\\\\\n    libssl-dev \\\\\\n    libudunits2-dev \\\\\\n    libxm4 \\\\\\n    multiarch-support \\\\\\n    netpbm \\\\\\n    python-is-python3 \\\\\\n    python3-pip \\\\\\n    tcsh \\\\\\n    xfonts-base \\\\\\n    xvfb\\nrm -rf /var/lib/apt/lists/*\\n_reproenv_tmppath=\\"$\(mktemp -t tmp.XXXXXXXXXX.deb\)\\"\\ncurl -fsSL --retry 5 -o \\"${_reproenv_tmppath}\\" http://mirrors.kernel.org/debian/pool/main/libx/libxp/libxp6_1.0.2-2_amd64.deb\\napt-get install --yes -q \\"${_reproenv_tmppath}\\"\\nrm \\"${_reproenv_tmppath}\\"\\n_reproenv_tmppath=\\"$\(mktemp -t tmp.XXXXXXXXXX.deb\)\\"\\ncurl -fsSL --retry 5 -o \\"${_reproenv_tmppath}\\" http://snapshot.debian.org/archive/debian-security/20160113T213056Z/pool/updates/main/libp/libpng/libpng12-0_1.2.49-1%%2Bdeb7u2_amd64.deb\\napt-get install --yes -q \\"${_reproenv_tmppath}\\"\\nrm \\"${_reproenv_tmppath}\\"\\napt-get update -qq\\napt-get install --yes --quiet --fix-missing\\nrm -rf /var/lib/apt/lists/*\\n\\ngsl_path=\\"$\(find / -name '"'"'libgsl.so.??'"'"' || printf '"'"''"'"'\)\\"\\nif [ -n \\"$gsl_path\\" ]; then \\\\\\n  ln -sfv \\"$gsl_path\\" \\"$\(dirname $gsl_path\)/libgsl.so.0\\"; \\\\\\nfi\\nldconfig\\nmkdir -p /opt/afni-latest\\necho \\"Downloading AFNI ...\\"\\ncurl -fL https://afni.nimh.nih.gov/pub/dist/tgz/linux_openmp_64.tgz \\\\\\n| tar -xz -C /opt/afni-latest --strip-components 1" \
      } \
    }, \
    { \
      "name": "env", \
      "kwds": { \
        "FSLDIR": "/opt/fsl-6.0.5.1", \
        "PATH": "/opt/fsl-6.0.5.1/bin:$PATH", \
        "FSLOUTPUTTYPE": "NIFTI_GZ", \
        "FSLMULTIFILEQUIT": "TRUE", \
        "FSLTCLSH": "/opt/fsl-6.0.5.1/bin/fsltclsh", \
        "FSLWISH": "/opt/fsl-6.0.5.1/bin/fslwish", \
        "FSLLOCKDIR": "", \
        "FSLMACHINELIST": "", \
        "FSLREMOTECALL": "", \
        "FSLGECUDAQ": "cuda.q" \
      } \
    }, \
    { \
      "name": "run", \
      "kwds": { \
        "command": "apt-get update -qq\\napt-get install -y -q --no-install-recommends \\\\\\n    bc \\\\\\n    ca-certificates \\\\\\n    curl \\\\\\n    dc \\\\\\n    file \\\\\\n    libfontconfig1 \\\\\\n    libfreetype6 \\\\\\n    libgl1-mesa-dev \\\\\\n    libgl1-mesa-dri \\\\\\n    libglu1-mesa-dev \\\\\\n    libgomp1 \\\\\\n    libice6 \\\\\\n    libopenblas-base \\\\\\n    libxcursor1 \\\\\\n    libxft2 \\\\\\n    libxinerama1 \\\\\\n    libxrandr2 \\\\\\n    libxrender1 \\\\\\n    libxt6 \\\\\\n    nano \\\\\\n    sudo \\\\\\n    wget\\nrm -rf /var/lib/apt/lists/*\\necho \\"Downloading FSL ...\\"\\nmkdir -p /opt/fsl-6.0.5.1\\ncurl -fL https://fsl.fmrib.ox.ac.uk/fsldownloads/fsl-6.0.5.1-centos7_64.tar.gz \\\\\\n| tar -xz -C /opt/fsl-6.0.5.1 --strip-components 1 \\necho \\"Installing FSL conda environment ...\\"\\nbash /opt/fsl-6.0.5.1/etc/fslconf/fslpython_install.sh -f /opt/fsl-6.0.5.1" \
      } \
    }, \
    { \
      "name": "env", \
      "kwds": { \
        "CONDA_DIR": "/opt/miniconda-latest", \
        "PATH": "/opt/miniconda-latest/bin:$PATH" \
      } \
    }, \
    { \
      "name": "run", \
      "kwds": { \
        "command": "apt-get update -qq\\napt-get install -y -q --no-install-recommends \\\\\\n    bzip2 \\\\\\n    ca-certificates \\\\\\n    curl\\nrm -rf /var/lib/apt/lists/*\\n# Install dependencies.\\nexport PATH=\\"/opt/miniconda-latest/bin:$PATH\\"\\necho \\"Downloading Miniconda installer ...\\"\\nconda_installer=\\"/tmp/miniconda.sh\\"\\ncurl -fsSL -o \\"$conda_installer\\" https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh\\nbash \\"$conda_installer\\" -b -p /opt/miniconda-latest\\nrm -f \\"$conda_installer\\"\\nconda update -yq -nbase conda\\n# Prefer packages in conda-forge\\nconda config --system --prepend channels conda-forge\\n# Packages in lower-priority channels not considered if a package with the same\\n# name exists in a higher priority channel. Can dramatically speed up installations.\\n# Conda recommends this as a default\\n# https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-channels.html\\nconda config --set channel_priority strict\\nconda config --system --set auto_update_conda false\\nconda config --system --set show_channel_urls true\\n# Enable `conda activate`\\nconda init bash\\nbash -c \\"source activate base\\n  python -m pip install --no-cache-dir  \\\\\\n      \\"visualqc\\"\\"\\n# Clean up\\nsync && conda clean --all --yes && sync\\nrm -rf ~/.cache/pip/*" \
      } \
    } \
  ] \
}' > /.reproenv.json
# End saving to specification to JSON.
