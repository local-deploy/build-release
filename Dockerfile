FROM golang:1.18.1

LABEL name="Go Builder"
LABEL maintainer="dl@varme.pw"
LABEL version="1.0.2"

COPY entrypoint.sh /entrypoint.sh
COPY github-release /usr/local/bin/github-release
RUN ["chmod", "+x", "/entrypoint.sh"]
RUN ["chmod", "+x", "/usr/local/bin/github-release"]

ENTRYPOINT ["/entrypoint.sh"]
