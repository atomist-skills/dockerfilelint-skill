FROM node:lts

RUN apt-get update && apt-get install -y \
   jq \
   && rm -rf /var/lib/apt/lists/*

RUN npm install -g dockerfilelint

WORKDIR /app
COPY dockerfilelint.* /app/

WORKDIR /atm/home
ENTRYPOINT ["bash", "/app/dockerfilelint.sh"]
 
