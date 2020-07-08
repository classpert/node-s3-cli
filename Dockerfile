FROM node:10.16.3
LABEL AUTHOR="Classpert"

ENV PATH="/app/.bin/:${PATH}"
RUN mkdir /app
WORKDIR /app

RUN npm install npm@latest -g

USER node
ENTRYPOINT ["npm"]
