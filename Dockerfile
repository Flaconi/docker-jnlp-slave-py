ARG JENKINS_AGENT
FROM jenkins/inbound-agent:${JENKINS_AGENT}
USER root

ARG PYTHON_MAJOR
ARG PYTHON_PATCH
RUN export PYTHON_SEMVER="${PYTHON_MAJOR}.${PYTHON_PATCH}" \
  && apt-get update \
  && apt-get install --no-install-recommends --no-install-suggests -y \
    wget \
    build-essential \
    libc6-dev \
    libbz2-dev \
    libffi-dev \
    libgdbm-dev \
    libreadline-dev \
    libncursesw5-dev \
    libssl-dev \
    libsqlite3-dev \
    tk-dev \
    zlib1g-dev \
  && cd /usr/src \
  && wget https://www.python.org/ftp/python/${PYTHON_SEMVER}/Python-${PYTHON_SEMVER}.tgz \
  && tar xzf Python-${PYTHON_SEMVER}.tgz \
  && rm Python-${PYTHON_SEMVER}.tgz \
  && cd Python-${PYTHON_SEMVER} \
  && ./configure --enable-optimizations --with-ensurepip \
  && make altinstall \
  && ln -s /usr/local/bin/python${PYTHON_MAJOR} /usr/local/bin/python3 \
  && ln -s /usr/local/bin/pip${PYTHON_MAJOR} /usr/local/bin/pip \
  && pip install --upgrade pip \
  && pip install six \
  # Clean up
	&& apt-get remove -f -y --purge --auto-remove build-essential \
	&& apt-get clean \
	&& apt-get autoremove -y \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /root/.cache /usr/src/Python*

USER jenkins
