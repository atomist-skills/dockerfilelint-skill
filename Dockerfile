FROM node:lts@sha256:ab6c8cd32006f8a4c1c795e55ddfbc7f54f5a3fb7318506ecb355cab8f5e7182

LABEL maintainer="Atomist <docker@atomist.com>"

RUN apt-get update && apt-get install -y --no-install-recommends \
     jq \
   && rm -rf /var/lib/apt/lists/*

RUN npm install -g dockerfilelint

COPY dockerfilelint.* /app/

WORKDIR /atm/home

ENTRYPOINT ["/bin/bash", "/app/dockerfilelint.sh"]
