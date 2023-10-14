FROM golang:1.21.3-alpine as builder

COPY . /go/src/github.com/vieux/docker-volume-sshfs

WORKDIR /go/src/github.com/vieux/docker-volume-sshfs

RUN set -ex \
    && apk update && apk upgrade && apk add --no-cache --virtual .build-deps \
    gcc libc-dev \
    && go mod init \
    && go install -mod=mod --ldflags '-extldflags "-static"' \
    && apk del .build-deps

CMD ["/go/bin/docker-volume-sshfs"]

FROM alpine

RUN apk update && \
    apk add sshfs && \
    apk add --no-cache tini && \
    mkdir -p /run/docker/plugins /mnt/state /mnt/volumes

COPY --from=builder /go/bin/docker-volume-sshfs .

CMD ["docker-volume-sshfs"]