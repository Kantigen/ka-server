FROM centos:7

# best practice?
RUN yum -y upgrade

RUN yum install -y make \
    wget \
    gcc gcc-c++ \
    zlib-devel \
    openssl openssl-devel \
    expat expat-devel \
    ncurses-devel \
    glibc-devel \
    git \
    mysql mysql-devel \
    libxml2 libxml2-devel \
    gd gd-devel \
    cronie \
    bzip2 \
    && systemctl enable crond.service \
    && rm -fr /var/lib/apt/lists/*

RUN mkdir /usr/src/perl
WORKDIR   /usr/src/perl

# I know I should, but don't want to figure out why it fails in this
# environment.
#    && TEST_JOBS=$(nproc) make test_harness \
#

RUN curl -SL https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.24.0.tar.bz2 -o perl-5.24.0.tar.bz2 \
    && echo '298fa605138c1a00dab95643130ae0edab369b4d *perl-5.24.0.tar.bz2' | sha1sum -c - \
    && tar --strip-components=1 -xjf perl-5.24.0.tar.bz2 -C /usr/src/perl \
    && rm perl-5.24.0.tar.bz2 \
    && ./Configure -Duse64bitall -Duseshrplib  -des \
    && make -j$(nproc) \
    && make install \
    && cd /usr/src \
    && curl -LO https://raw.githubusercontent.com/miyagawa/cpanminus/master/cpanm \
    && chmod +x cpanm \
    && ./cpanm App::cpanminus \
    && rm -fr ./cpanm /usr/src/perl /tmp/*

WORKDIR /root
ENV ANYEVENT_WEBSOCKET_TEST_SKIP_SSL=1

RUN groupadd nogroup

#
# This is likely not best practice, however the build runs very slowly without `--notest`
# Note: We're calling cpanm individually for each module due to some
# unreliability I haven't figured out the cause of
#
RUN cpanm --notest AnyEvent::Beanstalk
RUN cpanm --notest AnyEvent::Beanstalk
RUN cpanm --notest AnyEvent::Redis
RUN cpanm --notest AnyEvent::WebSocket::Client
RUN cpanm --notest AnyEvent::WebSocket::Server
RUN cpanm --notest App::Daemon
RUN cpanm --notest App::DH
RUN cpanm --notest Bad::Words
RUN cpanm --notest Beanstalk::Client
RUN cpanm --notest Business::PayPal::API
RUN cpanm --notest Clone
RUN cpanm --notest Config::JSON
RUN cpanm --notest Config::YAML
RUN cpanm --notest Crypt::SaltedHash
RUN cpanm --notest Data::Validate::Email
RUN cpanm --notest DateTime
RUN cpanm --notest DateTime::Format::Duration
RUN cpanm --notest DateTime::Format::MySQL
RUN cpanm --notest DateTime::Format::Strptime
RUN cpanm --notest DBD::mysql
RUN cpanm --notest DBI
RUN cpanm --notest DBIx::Class
RUN cpanm --notest DBIx::Class::DeploymentHandler
RUN cpanm --notest DBIx::Class::DynamicSubclass
RUN cpanm --notest DBIx::Class::EasyFixture
RUN cpanm --notest DBIx::Class::InflateColumn::Serializer
RUN cpanm --notest DBIx::Class::Schema
RUN cpanm --notest DBIx::Class::TimeStamp
RUN cpanm --notest Digest::HMAC_SHA1
RUN cpanm --notest Digest::MD5
RUN cpanm --notest Email::Send
RUN cpanm --notest Email::Send::Test
RUN cpanm --notest Email::Stuff
RUN cpanm --notest Email::Valid
RUN cpanm --notest Encode Module::Build
RUN cpanm --notest EV AnyEvent
RUN cpanm --notest Exception::Class
RUN cpanm --notest Facebook::Graph
RUN cpanm --notest File::Copy
RUN cpanm --notest File::Path
RUN cpanm --notest File::Pid Log::Log4perl
RUN cpanm --notest Firebase::Auth
RUN cpanm --notest GD
RUN cpanm --notest GD::SecurityImage
RUN cpanm --notest Gravatar::URL Digest::MD4
RUN cpanm --notest Guard
RUN cpanm --notest IO::Socket::IP
RUN cpanm --notest IO::Socket::SSL
RUN cpanm --notest JSON JSON::Any
RUN cpanm --notest JSON::RPC::Dispatcher
RUN cpanm --notest JSON::RPC::Dispatcher::App
RUN cpanm --notest JSON::WebToken
RUN cpanm --notest JSON::XS
RUN cpanm --notest List::MoreUtils
RUN cpanm --notest List::Util
RUN cpanm --notest List::Util::WeightedChoice
RUN cpanm --notest Log::Any::Adapter
RUN cpanm --notest Log::Any::Adapter::Log4perl
RUN cpanm --notest Log::Log4perl
RUN cpanm --notest LWP::Protocol::https
RUN cpanm --notest LWP::UserAgent
RUN cpanm --notest MARKOV/MailTools-2.21.tar.gz
RUN cpanm --notest --verbose Memcached::libmemcached
RUN cpanm --notest Module::Find
RUN cpanm --notest Moose
RUN cpanm --notest MooseX::NonMoose
RUN cpanm --notest MooseX::Singleton
RUN cpanm --notest namespace::autoclean
RUN cpanm --notest Net::Amazon::S3
RUN cpanm --notest Net::Server::SS::PreFork
RUN cpanm --notest Path::Class
RUN cpanm --notest PerlX::Maybe
RUN cpanm --notest Plack::App::WebSocket::Connection
RUN cpanm --notest Plack::Handler::Twiggy
RUN cpanm --notest Plack::Middleware::CrossOrigin
RUN cpanm --notest Plack::Middleware::Headers
RUN cpanm --notest Pod::Simple::HTML
RUN cpanm --notest Redis
RUN cpanm --notest Regexp::Common
RUN cpanm --notest rlib MooseX::App
RUN cpanm --notest Server::Starter SOAP::Lite
RUN cpanm --notest String::Random
RUN cpanm --notest Sysadm::Install
RUN cpanm --notest Term::ProgressBar
RUN cpanm --notest Term::ProgressBar::Quiet
RUN cpanm --notest Term::ProgressBar::Simple
RUN cpanm --notest Term::ReadKey
RUN cpanm --notest Test::Class::Moose
RUN cpanm --notest Test::Compile
RUN cpanm --notest Test::Deep
RUN cpanm --notest Test::Differences
RUN cpanm --notest Test::Exception
RUN cpanm --notest Test::Harness
RUN cpanm --notest Test::Mock::Class
RUN cpanm --notest Test::Most
RUN cpanm --notest Test::Number::Delta
RUN cpanm --notest Test::Pod::Coverage
RUN cpanm --notest Test::Trap
RUN cpanm --notest Test::Warn
RUN cpanm --notest Text::CSV_XS
RUN cpanm --notest Text::Trim
RUN cpanm --notest Text::WagnerFischer
RUN cpanm --notest Text::Xslate
RUN cpanm --notest Tie::IxHash
RUN cpanm --notest Time::HiRes
RUN cpanm --notest Time::Warp
RUN cpanm --notest URI::Encode
RUN cpanm --notest UUID::Tiny
RUN cpanm --notest XML::FeedPP
RUN cpanm --notest XML::Hash::LX
RUN cpanm --notest XML::Parser
RUN cpanm --notest YANICK/Parallel-ForkManager-1.16.tar.gz

WORKDIR /home/keno/ka-server/bin

# just a couple settings that help us with debugging and such.
# TERM being set gets us less working, PERLLIB gets us
# "perl -ML -e..." working
ENV TERM=xterm PERLLIB=/home/keno/ka-server/lib
