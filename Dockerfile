FROM golang:1.17.2

LABEL name="Go Builder"
LABEL maintainer="dl@varme.pw"
LABEL version="1.0.0"

COPY entrypoint.sh /entrypoint.sh
COPY github-release /usr/bin/github-release
RUN ["chmod", "+x", "/entrypoint.sh"]
RUN ["chmod", "+x", "/usr/bin/github-release"]

ENTRYPOINT ["/entrypoint.sh"]
