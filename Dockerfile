FROM node:lts@sha256:4164d987bfceb62b17db4938d535dd31fc50d6ee0b4e00ac7a774f82af408d48

LABEL maintainer="Atomist <docker@atomist.com>"

RUN apt-get update && apt-get install -y --no-install-recommends \
     jq \
   && rm -rf /var/lib/apt/lists/*

RUN npm install -g dockerfilelint

COPY dockerfilelint.* /app/

WORKDIR /atm/home

ENTRYPOINT ["/bin/bash", "/app/dockerfilelint.sh"]
