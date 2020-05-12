FROM python:3-alpine

RUN apk add curl \
    && pip install requests ObjectPath
COPY elasticcheck.py /elasticcheck.py

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
