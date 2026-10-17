# syntax=docker/dockerfile:1.7

ARG NODE_IMAGE=node:24-bookworm-slim

FROM ${NODE_IMAGE} AS base
WORKDIR /app
RUN corepack enable

FROM base AS prod-deps
COPY package.json yarn.lock .yarnrc.yml ./
RUN yarn install --frozen-lockfile --non-interactive --production=true

FROM base AS build
COPY package.json yarn.lock .yarnrc.yml tsconfig.json ./
RUN yarn install --frozen-lockfile --non-interactive
COPY src ./src
RUN yarn build

FROM ${NODE_IMAGE} AS runner
WORKDIR /app
ENV NODE_ENV=production

COPY package.json ./
COPY --from=prod-deps /app/node_modules ./node_modules
COPY --from=build /app/build ./build

ENTRYPOINT ["node", "/app/build/index.js"]
