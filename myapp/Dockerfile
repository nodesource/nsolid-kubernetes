FROM nodesource/nsolid:latest

RUN mkdir -p /usr/src/app

WORKDIR /usr/src/app

ADD server.js /usr/src/app/server.js

ENTRYPOINT ["nsolid", "server.js"]
