# Dockerfile for building docker container
FROM jupyter/minimal-notebook

LABEL maintainer="Markus Petters <mdpetter@ncsu.edu>"

USER root

# Install system packages dependencies
RUN apt-get update && \
    rm -rf /var/lib/apt/lists/*

# Environment Variables
ENV JULIA_DEPOT_PATH=/opt/julia
ENV JULIA_PKGDIR=/opt/julia
ENV JULIA_VERSION=1.4.0
ENV JULIA_SHA256=30d126dc3598f3cd0942de21cc38493658037ccc40eb0882b3b4c418770ca751
ENV JULIA_PROJECT=$HOME

# Download and install julia version
RUN mkdir /opt/julia-${JULIA_VERSION} && \
    cd /tmp && \
    wget -q https://julialang-s3.julialang.org/bin/linux/x64/`echo ${JULIA_VERSION} | cut -d. -f 1,2`/julia-${JULIA_VERSION}-linux-x86_64.tar.gz && \
    echo "${JULIA_SHA256} *julia-${JULIA_VERSION}-linux-x86_64.tar.gz" | sha256sum -c - && \
    tar xzf julia-${JULIA_VERSION}-linux-x86_64.tar.gz -C /opt/julia-${JULIA_VERSION} --strip-components=1 && \
    rm /tmp/julia-${JULIA_VERSION}-linux-x86_64.tar.gz
RUN ln -fs /opt/julia-*/bin/julia /usr/local/bin/julia

RUN mkdir /etc/julia && \
    echo "push!(Libdl.DL_LOAD_PATH, \"$CONDA_DIR/lib\")" >> /etc/julia/juliarc.jl && \
    mkdir $JULIA_PKGDIR && \
    chown $NB_USER $JULIA_PKGDIR && \
    fix-permissions $JULIA_PKGDIR

USER $NB_UID

ADD . .

# Activate julia environment and precompile
RUN julia -e 'using Pkg; Pkg.instantiate()' && \
    julia -e 'using Pkg; Pkg.status()' && \
    julia -e 'println(Base.active_project())' && \
    julia -e 'using Pkg; Pkg.precompile()' 


#USER root

USER root

RUN chmod a+w ${JULIA_DEPOT_PATH}-${JULIA_VERSION}/lib/julia/ && \
    chmod a+w ${JULIA_DEPOT_PATH}-${JULIA_VERSION}/etc/julia/startup.jl && \
    chmod a+rw *.* && \
    chmod a+rw Figures/ && \
    chmod a+rw Figures/*.* && \
    chmod a+rw Data/*.* && \ 
    chmod a+rw Data/

USER $NB_UID

RUN echo 'using Fezzik; Fezzik.trace();' >> ${JULIA_DEPOT_PATH}-${JULIA_VERSION}/etc/julia/startup.jl && \
    jupyter nbconvert --to notebook --execute --ExecutePreprocessor.timeout=600 "Supplement.ipynb" --stdout >/dev/null 
                                                                                
RUN julia -e 'using Fezzik; Fezzik.brute_build_julia(;clear_traces = true);'
