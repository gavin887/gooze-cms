FROM golang:1.24-alpine AS builder

WORKDIR /app

RUN apk add --no-cache git tzdata

ENV CGO_ENABLED=0
ENV GOOS=linux
ENV GOARCH=amd64
ENV GOPROXY=https://goproxy.cn,direct

COPY gooze-vben-api/go.mod gooze-vben-api/go.sum ./
RUN go mod download

COPY gooze-vben-api/ .

RUN go build -ldflags="-s -w" -o /app/admin ./cmd/admin/main.go

FROM alpine:latest

RUN apk add --no-cache ca-certificates tzdata yq
ENV TZ=Asia/Shanghai

WORKDIR /app

COPY --from=builder /app/admin /app/admin
COPY gooze-vben-api/configs/ /app/configs/
COPY docker/backend/entrypoint.sh /app/entrypoint.sh

RUN chmod +x /app/admin /app/entrypoint.sh

EXPOSE 18002

ENTRYPOINT ["/app/entrypoint.sh"]
