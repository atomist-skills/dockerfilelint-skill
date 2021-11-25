FROM node:lts@sha256:88ee7d2a5e18d359b4b5750ecb50a9b238ab467397c306aeb9955f4f11be44ce

LABEL maintainer="Atomist <docker@atomist.com>"

RUN apt-get update && apt-get install -y --no-install-recommends \
     jq \
   && rm -rf /var/lib/apt/lists/*

RUN npm install -g dockerfilelint

COPY dockerfilelint.* /app/

WORKDIR /atm/home

ENTRYPOINT ["/bin/bash", "/app/dockerfilelint.sh"]
