FROM golang as builder

RUN go get -u github.com/rakyll/hey
RUN which hey

FROM ubuntu:18.04
COPY --from=builder /go/bin/hey /usr/local/bin
