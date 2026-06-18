FROM node:20-slim AS builder

WORKDIR /app

RUN npm install -g pnpm@9 && pnpm config set registry https://registry.npmmirror.com

COPY gooze-vben-admin/ ./

RUN pnpm install

RUN pnpm build --filter=@gooze/admin

FROM nginx:alpine

ENV TZ=Asia/Shanghai
ENV API_URL=/api/v1
ENV API_BASE_URL=http://backend:18002

COPY docker/frontend/nginx.conf.template /etc/nginx/conf.d/default.conf.template
COPY docker/frontend/entrypoint.sh /entrypoint.sh

COPY --from=builder /app/apps/admin/dist /usr/share/nginx/html

RUN chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
