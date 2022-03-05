FROM node:lts@sha256:61b6cc81ecc3f94f614dca6bfdc5262d15a6618f7aabfbfc6f9f05c935ee753c

LABEL maintainer="Atomist <docker@atomist.com>"

RUN apt-get update && apt-get install -y --no-install-recommends \
     jq \
   && rm -rf /var/lib/apt/lists/*

RUN npm install -g dockerfilelint

COPY dockerfilelint.* /app/

WORKDIR /atm/home

ENTRYPOINT ["/bin/bash", "/app/dockerfilelint.sh"]
