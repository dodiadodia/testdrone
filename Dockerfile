# Build step
FROM golang:latest

ENV https_proxy=http://172.16.0.4:8118
ENV http_proxy=http://172.16.0.4:8118
RUN mkdir -p $GOPATH/src/github.com/Depado/dummy
ADD . $GOPATH/src/github.com/Depado/dummy
WORKDIR $GOPATH/src/github.com/Depado/dummy
RUN go get -u github.com/golang/dep/cmd/dep
RUN dep ensure -vendor-only
RUN CGO_ENABLED=0 go build -o /dummy

# Final step
FROM alpine

RUN apk update
RUN apk upgrade
RUN apk add ca-certificates && update-ca-certificates
RUN apk add --update tzdata
RUN rm -rf /var/cache/apk/*

COPY --from=0 /dummy /home/
#ADD ./testdrone /home/dummy
ENV TZ=Europe/Paris
WORKDIR /home
ENTRYPOINT ./dummy
EXPOSE 8080
