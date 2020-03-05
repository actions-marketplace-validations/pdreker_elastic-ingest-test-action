FROM docker:stable

RUN apk add python3 py3-requests
COPY elasticcheck.py /elasticcheck.py

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
