FROM python:3.6

RUN apt-get update\
	&& apt-get install -y --no-install-recommends unzip \
	&& rm -fr /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.10.1

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='72d820dec546752e5a8303b33b009079c15c2390ce76d67cf514991646c6127b' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='feca4e920d5ca25001dc0823390df79bc7ea5b5b8c03483e5a2c54f164654936' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='1e07a159414b5090d31166d1a06ee501762076ef21140dcd54cdcbe4e68a9c9b' ;; \
		i386) goRelArch='linux-386'; goRelSha256='acbe19d56123549faf747b4f61b730008b185a0e2145d220527d2383627dfe69' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='91d0026bbed601c4aad332473ed02f9a460b31437cbc6f2a37a88c0376fc3a65' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='e211a5abdacf843e16ac33a309d554403beb63959f96f9db70051f303035434b' ;; \
		*) goRelArch='src'; goRelSha256='589449ff6c3ccbff1d391d4e7ab5bb5d5643a5a41a04c99315e55c16bbf73ddc'; \
			echo >&2; echo >&2 "warning: current architecture ($dpkgArch) does not have a corresponding Go binary release; will be building from source"; echo >&2 ;; \
	esac; \
	\
	url="https://golang.org/dl/go${GOLANG_VERSION}.${goRelArch}.tar.gz"; \
	curl -L -s -o go.tgz "$url"; \
	echo "${goRelSha256} *go.tgz" | sha256sum -c -; \
	tar -C /usr/local -xzf go.tgz; \
	rm go.tgz; \
	\
	if [ "$goRelArch" = 'src' ]; then \
		echo >&2; \
		echo >&2 'error: UNIMPLEMENTED'; \
		echo >&2 'TODO install golang-any from jessie-backports for GOROOT_BOOTSTRAP (and uninstall after build)'; \
		echo >&2; \
		exit 1; \
	fi; \
	\
	export PATH="/usr/local/go/bin:$PATH"; \
	go version

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

ENV PROTOBUF_VERSION=3.5.1

RUN curl -L -s https://github.com/google/protobuf/releases/download/v${PROTOBUF_VERSION}/protobuf-cpp-${PROTOBUF_VERSION}.tar.gz -o /tmp/protobuf.tar.gz \
	&& tar -xzf /tmp/protobuf.tar.gz -C /tmp \
	&& rm -f /tmp/protobuf.tar.gz \
	&& cd /tmp/protobuf-${PROTOBUF_VERSION} \
    && ./configure \
	&& make \
	&& make install \
	&& ldconfig \
	&& rm -rf /tmp/protobuf-${PROTOBUF_VERSION}

RUN go get -u github.com/golang/protobuf/proto github.com/golang/protobuf/protoc-gen-go github.com/gogo/protobuf/protoc-gen-gofast

RUN go get -u github.com/gogo/protobuf/gogoproto github.com/gogo/protobuf/protoc-gen-gogofast github.com/gogo/protobuf/protoc-gen-gogofaster github.com/gogo/protobuf/protoc-gen-gogoslick

ENV GRPC_VERSION=1.11.0

RUN pip3 install grpcio==${GRPC_VERSION} \
	&& pip3 install grpcio-tools==${GRPC_VERSION} \
	&& git clone -b v${GRPC_VERSION} https://github.com/grpc/grpc /tmp/grpc \
	&& cd /tmp/grpc \
	&& git submodule update --init \
	&& make \
	&& make install

ENTRYPOINT ["/usr/local/bin/protoc"]
