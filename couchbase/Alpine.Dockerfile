FROM korczis/minimal-glibc

MAINTAINER Couchbase Docker Team <docker@couchbase.com>

ENV CB_VERSION=4.1.0 \
    CB_RELEASE_URL=http://packages.couchbase.com/releases \
    CB_PACKAGE=couchbase-server-enterprise_4.1.0-ubuntu14.04_amd64.deb \
    CB_SHA256=beb4ee31b5fea2bfa47c51132d3b29a12e6e2c537b7e5e8dca5d0d50558e4c53 \
    PATH=$PATH:/opt/couchbase/bin:/opt/couchbase/bin/tools:/opt/couchbase/bin/install \
    LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/couchbase/lib

RUN addgroup -g 1000 couchbase && adduser -u 1000 -G couchbase -H -S couchbase

# Install couchbase
RUN wget $CB_RELEASE_URL/$CB_VERSION/$CB_PACKAGE && \
    echo "$CB_SHA256  $CB_PACKAGE" | sha256sum -c - && \
    dpkg -i ./$CB_PACKAGE && rm -f ./$CB_PACKAGE

# Add runit script for couchbase-server
COPY scripts/run /etc/service/couchbase-server/run

# Add bootstrap script
COPY scripts/entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["couchbase-server"]

EXPOSE 8091 8092 8093 11207 11210 11211 18091 18092
VOLUME /opt/couchbase/var
