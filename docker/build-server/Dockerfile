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

# Install App::Daemon dependencies (with tests)

# Memcached / PreFork can timeout due to long compilation without --verbose
RUN cpanm Encode Module::Build \
 && cpanm --notest Term::ReadKey GD App::Daemon GD::SecurityImage \
    IO::Socket::IP \
 && cpanm Sysadm::Install File::Pid Log::Log4perl \
   Exception::Class \
   Test::Harness Test::Differences Test::Exception \
   Test::Warn Test::Deep Test::Most Test::Trap \
   Time::HiRes \
   Log::Any::Adapter Log::Any::Adapter::Log4perl \
   Log::Log4perl \
 && cpanm EV AnyEvent \
 && rm -fr /root/.cpanm

RUN cpanm Beanstalk::Client Clone Config::JSON Config::YAML \
   && cpanm DateTime DateTime::Format::Duration DateTime::Format::MySQL DateTime::Format::Strptime \
   && cpanm DBI DBD::mysql \
 && rm -fr /root/.cpanm

RUN cpanm DBIx::Class \
   DBIx::Class::DynamicSubclass DBIx::Class::InflateColumn::Serializer DBIx::Class::Schema DBIx::Class::TimeStamp \
 && rm -fr /root/.cpanm

RUN cpanm MARKOV/MailTools-2.21.tar.gz Email::Send Email::Send::Test Digest::HMAC_SHA1 Digest::MD5 Email::Stuff Email::Valid \
   Facebook::Graph File::Copy File::Path Guard IO::Socket::SSL \
   JSON JSON::Any JSON::WebToken JSON::XS List::MoreUtils List::Util \
   List::Util::WeightedChoice \
   LWP::Protocol::https LWP::UserAgent \
   JSON::RPC::Dispatcher JSON::RPC::Dispatcher::App \
 && rm -fr /root/.cpanm

RUN cpanm --verbose Memcached::libmemcached Net::Server::SS::PreFork \
 && rm -fr /root/.cpanm

RUN cpanm Test::Pod::Coverage Moose Module::Find namespace::autoclean \
 && cpanm Term::ProgressBar::Simple Net::Amazon::S3 \
    Path::Class Plack::Middleware::CrossOrigin Pod::Simple::HTML \
    Regexp::Common Server::Starter SOAP::Lite String::Random \
    Text::CSV_XS Tie::IxHash URI::Encode UUID::Tiny XML::FeedPP \
    XML::Hash::LX XML::Parser Text::Xslate \
    Term::ProgressBar Term::ProgressBar::Quiet PerlX::Maybe \
    Gravatar::URL Digest::MD4 Bad::Words \
    Business::PayPal::API  \
 && rm -fr /root/.cpanm

RUN cpanm YANICK/Parallel-ForkManager-1.16.tar.gz \
 && cpanm AnyEvent::WebSocket::Client Test::Compile Test::Class::Moose DBIx::Class::EasyFixture Test::Number::Delta \
 && cpanm Redis MooseX::Singleton Crypt::SaltedHash Data::Validate::Email Text::Trim MooseX::NonMoose AnyEvent::WebSocket::Server \
 && cpanm Plack::App::WebSocket::Connection Test::Mock::Class Plack::Middleware::Headers Plack::Handler::Twiggy \
 && cpanm rlib MooseX::App Text::WagnerFischer AnyEvent::Beanstalk AnyEvent::Beanstalk AnyEvent::Redis \
 && rm -fr /root/.cpanm

RUN cpanm Firebase::Auth \
 && rm -fr /root/.cpanm

RUN groupadd nogroup
WORKDIR /home/keno/ka-server/bin

RUN cpanm DBIx::Class::DeploymentHandler App::DH \
 && rm -fr /root/.cpanm \
 && rm -fr /tmp/*

# just a couple settings that help us with debugging and such.
# TERM being set gets us less working, PERLLIB gets us
# "perl -ML -e..." working
ENV TERM=xterm PERLLIB=/home/keno/ka-server/lib
