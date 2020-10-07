# syntax=docker/dockerfile:experimental
FROM haskell:8.0.2 AS builder

RUN apt-get update -qq && \
  apt-get install -qq -y libpcre3 libpcre3-dev build-essential --fix-missing --no-install-recommends && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir /log

WORKDIR /duckling

ADD duckling.cabal .
ADD stack.yaml .

RUN stack install --only-dependencies

ADD . .

# NOTE:`stack build` will use as many cores as are available to build
# in parallel. However, this can cause OOM issues as the linking step
# in GHC can be expensive. If the build fails, try specifying the
# '-j1' flag to force the build to run sequentially.
RUN --mount=type=cache,target=/duckling/.stack-work stack build
RUN --mount=type=cache,target=/duckling/.stack-work stack install

FROM builder AS tester
RUN --mount=type=cache,target=/duckling/.stack-work stack test

FROM debian:stretch

ENV LANG C.UTF-8

RUN apt-get update -qq && \
  apt-get install -qq -y libpcre3 libgmp10 --no-install-recommends && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=builder /root/.local/bin/duckling-example-exe /usr/local/bin/

EXPOSE 8000

CMD ["duckling-example-exe", "-p", "8000", "--no-access-log", "--no-error-log"]
