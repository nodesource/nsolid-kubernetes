FROM nodesource/nsolid:carbon-latest

RUN mkdir -p /usr/src/app

WORKDIR /usr/src/app

ADD package.json /usr/src/app/package.json
RUN npm install --production
ADD server.js /usr/src/app/server.js

ENTRYPOINT ["nsolid", "server.js"]
