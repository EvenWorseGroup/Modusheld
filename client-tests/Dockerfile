FROM python:3.12-alpine

WORKDIR /app

COPY client-tests/ /app/client-tests/

RUN adduser -D -u 10003 modushield-client \
    && chmod +x /app/client-tests/e2e.sh \
    && chown -R modushield-client:modushield-client /app

USER 10003

CMD ["sh", "-c", "while :; do sleep 3600; done"]
