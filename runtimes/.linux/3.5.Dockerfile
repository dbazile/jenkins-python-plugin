FROM buildpack-deps:jessie

RUN apt-get update && apt-get install -y --no-install-recommends \
		dpkg-dev \
		tcl \
		tcl-dev \
		tk \
		tk-dev \
	&& rm -rf /var/lib/apt/lists/*

ENV GPG_KEY 97FC712E4C024BBEA48A61ED3A5CA953F73C700D
ENV PYTHON_VERSION 3.5.4

RUN set -ex \
	&& wget -q -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-$PYTHON_VERSION.tar.xz" \
	&& wget -q -O python.tar.xz.asc "https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-$PYTHON_VERSION.tar.xz.asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEY" \
	&& gpg --batch --verify python.tar.xz.asc python.tar.xz \
	&& rm -rf "$GNUPGHOME" python.tar.xz.asc \
	&& mkdir -p /usr/src/python \
	&& tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz \
	&& rm python.tar.xz

WORKDIR /usr/src/python

ENV RUNTIME_NAME "python-${PYTHON_VERSION}-linux"

RUN set -ex \
	&& mkdir -p "/staging" \
	&& ./configure \
		--prefix="/staging/$RUNTIME_NAME" \
		--with-ensurepip=install \
	&& make \
	&& make install

WORKDIR /staging

RUN set -ex \
	&& find /staging -depth \
		\( \
			\( -type d -a \( -name test -o -name tests \) \) \
			-o \
			\( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
		\) -exec rm -rf '{}' +

VOLUME /output

ADD _postinstall.sh ./$RUNTIME_NAME/postinstall.sh
RUN set -ex \
	&& tar zcvf "$RUNTIME_NAME.tar.gz" "$RUNTIME_NAME" \
	&& sha256sum "$RUNTIME_NAME.tar.gz" > "$RUNTIME_NAME.tar.gz.shasum"

CMD cp "$RUNTIME_NAME.tar.gz" "$RUNTIME_NAME.tar.gz.shasum" /output
