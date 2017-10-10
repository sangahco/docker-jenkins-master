FROM jenkins/jenkins:lts

COPY . /usr/local/src

USER root
RUN apt-get update && apt-get install -y \
    python3 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN set -x \
    && cp /usr/local/src/docker-entrypoint.sh /entrypoint.sh \
    && curl https://bootstrap.pypa.io/get-pip.py -o /usr/local/src/get-pip.py \
    && python3 /usr/local/src/get-pip.py --user \
    && ~/.local/bin/pip install awscli --upgrade --user \
    && rm -rf /usr/local/src

RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]