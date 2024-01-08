FROM crystallang/crystal:latest

WORKDIR /usr/src/app

COPY . .

RUN shards install
RUN crystal build --release cwizard.cr

CMD ["./cwizard"]

ENV TERM xterm
