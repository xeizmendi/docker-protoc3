FROM debian:jessie

RUN apt-get update\
	&& apt-get install -y curl ca-certificates unzip\
	&& curl -s -L https://github.com/google/protobuf/releases/download/v3.3.0/protoc-3.3.0-linux-x86_64.zip -o /tmp/protoc.zip\
	&& unzip /tmp/protoc.zip -d /proto\
	&& rm -f /tmp/protoc.zip\
	&& apt-get remove --purge -y curl ca-certificates unzip\
	&& rm -fr /var/lib/apt/lists/*

ENTRYPOINT ["/proto/bin/protoc"]
