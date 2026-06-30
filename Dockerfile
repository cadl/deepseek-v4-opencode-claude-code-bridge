# DeepSeek V4 OpenCode <-> Claude Code bridge
# Pure Node.js server with no third-party dependencies, so the image is tiny.
FROM node:22-alpine

# Default runtime configuration. Every value can be overridden at `docker run`
# time with -e, in docker-compose, or in the Dokploy environment settings.
ENV NODE_ENV=production \
    CLAUDE_OPENCODE_PROXY_HOST=0.0.0.0 \
    CLAUDE_OPENCODE_PROXY_PORT=8787 \
    CLAUDE_OPENCODE_REASONING_CACHE=/app/data/reasoning-cache.json

WORKDIR /app

# Only the files the server actually needs at runtime.
COPY package.json server.js config.json ./

# Writable location for the reasoning cache (required for thinking-mode
# tool-call history replay). Mount a volume here to persist it across restarts.
RUN mkdir -p /app/data && chown -R node:node /app

USER node

EXPOSE 8787

# Uses the built-in /health endpoint; no curl/wget needed on Alpine.
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD node -e "require('http').get('http://127.0.0.1:'+(process.env.CLAUDE_OPENCODE_PROXY_PORT||8787)+'/health',r=>process.exit(r.statusCode===200?0:1)).on('error',()=>process.exit(1))"

CMD ["node", "server.js", "--config", "./config.json"]
