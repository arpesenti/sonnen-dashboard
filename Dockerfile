FROM ruby:2.7-alpine

RUN apk update && apk add --no-cache build-base nodejs

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

EXPOSE 3030

CMD ["smashing", "start"]
