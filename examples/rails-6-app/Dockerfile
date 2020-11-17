FROM ruby:2.7.2-slim

RUN apt-get update -qq && apt-get install -y build-essential curl

WORKDIR /usr/src/app/

# Install node version that will enable installation of yarn
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -

RUN apt-get install -y --no-install-recommends \
    nodejs \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY Gemfile* ./
RUN bundle install
RUN npm install -g yarn
# RUN yarn -v
# RUN which yarn
# RUN yarn config current
COPY package.json yarn.lock ./
RUN yarn install

COPY . .

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000

CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]
