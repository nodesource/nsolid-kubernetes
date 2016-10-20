FROM nodesource/nsolid-boron:2.0

RUN mkdir -p /usr/src/app

WORKDIR /usr/src/app

ADD package.json /usr/src/app/package.json
RUN npm install --production
ADD server.js /usr/src/app/server.js

ENTRYPOINT ["nsolid", "server.js"]
