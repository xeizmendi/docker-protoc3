FROM golang:1.8

RUN apt-get update\
	&& apt-get install -y --no-install-recommends unzip\
	&& curl -s -L https://github.com/google/protobuf/releases/download/v3.3.0/protoc-3.3.0-linux-x86_64.zip -o /tmp/protoc.zip\
	&& unzip /tmp/protoc.zip -d /usr/local\
	&& rm -f /tmp/protoc.zip\
	&& rm -fr /var/lib/apt/lists/*\
	&& go get -u github.com/golang/protobuf/proto github.com/golang/protobuf/protoc-gen-go

ENTRYPOINT ["/usr/local/bin/protoc"]
