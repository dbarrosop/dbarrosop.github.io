FROM jekyll/jekyll:3.7.3

COPY Gemfile /tmp

RUN cd /tmp && bundle
