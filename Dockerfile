## Dockerfile for a haskell environment
FROM ubuntu:18.04

ARG GHC_VERSION
ARG CABAL_VERSION
ARG STACK_VERSION
ARG HAPPY_VERSION
ARG ALEX_VERSION

## ensure locale is set during build
ENV LANG            C.UTF-8

## prepare installation
RUN apt-get update && \
    apt-get install -y gnupg curl

## add KVR ppa
RUN echo 'deb http://ppa.launchpad.net/hvr/ghc/ubuntu trusty main' > /etc/apt/sources.list.d/ghc.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F6F88286 && \
    apt-get update

## install needed packages
RUN apt-get install -y --no-install-recommends cabal-install-${CABAL_VERSION} ghc-${GHC_VERSION} happy-${HAPPY_VERSION} alex-${ALEX_VERSION} \
            zlib1g-dev libtinfo-dev libsqlite3-0 libsqlite3-dev ca-certificates g++ git

## install and check stack
RUN curl -fSL https://github.com/commercialhaskell/stack/releases/download/v${STACK_VERSION}/stack-${STACK_VERSION}-linux-x86_64.tar.gz -o stack.tar.gz && \
    curl -fSL https://github.com/commercialhaskell/stack/releases/download/v${STACK_VERSION}/stack-${STACK_VERSION}-linux-x86_64.tar.gz.asc -o stack.tar.gz.asc && \
    gpg --keyserver ipv4.pool.sks-keyservers.net --recv-keys C5705533DA4F78D8664B5DC0575159689BEFB442 && \
    gpg --batch --verify stack.tar.gz.asc stack.tar.gz && \
    tar -xf stack.tar.gz -C /usr/local/bin --strip-components=1 && \
    /usr/local/bin/stack config set system-ghc --global true

## clean some stuff
RUN apt-get purge -y --auto-remove curl gnupg && \
    rm -rf /root/.gnupg/ /var/lib/apt/lists/* /stack.tar.gz.asc /stack.tar.gz

ENV PATH /root/.cabal/bin:/root/.local/bin:/opt/cabal/bin:/opt/ghc/bin:$PATH

## run ghci by default unless a command is specified
CMD ["ghci"]
