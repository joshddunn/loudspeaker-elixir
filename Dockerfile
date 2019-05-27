FROM elixir:1.8

RUN apt-get update
RUN apt-get install -y build-essential

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix archive.install --force hex phx_new 1.4.6

RUN mkdir /myapp
WORKDIR /myapp
ADD . /myapp
