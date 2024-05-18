FROM python:latest

WORKDIR /root/mail_server

ARG PORT
ENV PORT=${PORT}

COPY --link requirements.txt .
RUN pip install -r requirements.txt

COPY --link . .

CMD ["make", "dev"]
# CMD ["/bin/bash"]