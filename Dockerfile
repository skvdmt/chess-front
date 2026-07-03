FROM node:22.20-alpine AS build
WORKDIR /usr/src/chess-front
EXPOSE 8000
COPY package*.json .
COPY . .
RUN npm install
RUN npm run build

FROM skvdmt/serve:latest
WORKDIR /usr/local/bin
COPY --from=build /usr/src/chess-front/dist/. /var/www/html
EXPOSE 8000
ENTRYPOINT [ "serve" ]
