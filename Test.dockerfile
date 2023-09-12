FROM ruby:3.2-slim

RUN apt update -y && \
  apt install -y \
    build-essential \
    libcurl4-openssl-dev \
    git

COPY . /app
WORKDIR /app

RUN rm -f Gemfile.lock && bundle install

CMD ["rake", "spec"]
