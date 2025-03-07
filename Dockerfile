FROM node:22-alpine AS build
WORKDIR /app

RUN npm install -g pnpm@10
RUN apk add --no-cache git
COPY package.json pnpm-lock.yaml ./
COPY patches ./patches
RUN pnpm install --frozen-lockfile

COPY . .
RUN pnpm run build
RUN pnpm prune --prod

FROM node:22-alpine
WORKDIR /app
COPY --from=build /app/build /app/build
COPY --from=build /app/node_modules /app/node_modules
RUN echo '{"type":"module"}' > /app/package.json

EXPOSE 3000
ENV NODE_ENV=production
ENV HOST=0.0.0.0
CMD [ "node", "./build/headplane/server.js" ]
