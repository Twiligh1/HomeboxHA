FROM ghcr.io/sysadminsmedia/homebox:latest

RUN apk add --no-cache jq bash

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
