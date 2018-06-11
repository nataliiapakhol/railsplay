FROM ruby:2.5.1
RUN apt-get update -qq \
  && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
  && apt-get clean autoclean \
  && apt-get autoremove -y \
  && rm -rf \
    /var/lib/apt \
    /var/lib/dpkg \
    /var/lib/cache \
    /var/lib/log
RUN mkdir -p /app
WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install
COPY . ./
EXPOSE 3000
CMD bundle exec rails server -p 3000 -b '0.0.0.0'
