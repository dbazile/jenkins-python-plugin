FROM buildpack-deps:jessie

RUN apt-get update && apt-get install -y --no-install-recommends \
		dpkg-dev \
		tcl \
		tcl-dev \
		tk \
		tk-dev \
	&& rm -rf /var/lib/apt/lists/*

ENV GPG_KEY C01E1CAD5EA2C4F0B8E3571504C367C218ADD4FF
ENV PYTHON_VERSION 2.7.13

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

RUN set -ex \
	&& "/staging/$RUNTIME_NAME/bin/pip" install virtualenv

WORKDIR /staging

RUN set -ex \
	&& find /staging -depth \
		\( \
			\( -type d -a \( -name test -o -name tests \) \) \
			-o \
			\( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
		\) -exec rm -rf '{}' +

VOLUME /output

ADD _postinstall.bash ./$RUNTIME_NAME/postinstall.bash
RUN set -ex \
	&& chmod +x ./$RUNTIME_NAME/postinstall.bash \
	&& tar zcvf "$RUNTIME_NAME.tar.gz" "$RUNTIME_NAME" \
	&& sha256sum "$RUNTIME_NAME.tar.gz" > "$RUNTIME_NAME.tar.gz.shasum"

CMD cp "$RUNTIME_NAME.tar.gz" "$RUNTIME_NAME.tar.gz.shasum" /output
