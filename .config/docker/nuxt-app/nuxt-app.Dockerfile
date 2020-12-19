FROM node:lts-alpine

COPY package*.json ./

RUN yarn install

ENV HOST 0.0.0.0
ENV NUXT_PORT 3000 

COPY . .

EXPOSE $NUXT_PORT
CMD [ "yarn" , "dev" ]
