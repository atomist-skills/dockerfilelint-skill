FROM node:lts@sha256:1844333e5a9df490d932161570ae61357af0d1788b0f3ec0ee2a437a3f0d4f8e

LABEL maintainer="Atomist <docker@atomist.com>"

RUN apt-get update && apt-get install -y --no-install-recommends \
     jq \
   && rm -rf /var/lib/apt/lists/*

RUN npm install -g dockerfilelint

COPY dockerfilelint.* /app/

WORKDIR /atm/home

ENTRYPOINT ["/bin/bash", "/app/dockerfilelint.sh"]
