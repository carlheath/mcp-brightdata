FROM node:22-alpine AS builder

COPY . /app
WORKDIR /app

RUN npm ci --ignore-scripts

FROM node:22-alpine AS release

WORKDIR /app

COPY --from=builder /app/server.js /app/
COPY --from=builder /app/browser_tools.js /app/
COPY --from=builder /app/browser_session.js /app/
COPY --from=builder /app/aria_snapshot_filter.js /app/
COPY --from=builder /app/tool_groups.js /app/
COPY --from=builder /app/package.json /app/
COPY --from=builder /app/package-lock.json /app/
COPY --from=builder /app/node_modules /app/node_modules

ENV NODE_ENV=production
ENV MCP_HTTP_PORT=3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:${MCP_HTTP_PORT}/sse || exit 1

EXPOSE 3000

ENTRYPOINT ["node", "server.js"]
