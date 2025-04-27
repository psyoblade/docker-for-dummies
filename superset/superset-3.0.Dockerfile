FROM apache/superset:3.0.2

ENV SUPERSET_SECRET_KEY=thisISaSECRET_123456
ENV DATABASE_URL=sqlite:////app/superset.db

RUN superset db upgrade && \
    superset fab create-admin \
      --username admin \
      --firstname Superset \
      --lastname Admin \
      --email admin@superset.com \
      --password admin && \
    superset init

CMD ["superset", "run", "-h", "0.0.0.0", "-p", "8088", "--with-threads", "--reload", "--debugger"]
