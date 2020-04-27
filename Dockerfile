FROM perl:5.30-threaded

ENV LANG C.UTF-8

WORKDIR /app

RUN cpanm -nq Carton
COPY cpanfile cpanfile.snapshot ./
RUN carton install --deployment
COPY . .

CMD ["carton", "exec", "perl", "main.pl"]