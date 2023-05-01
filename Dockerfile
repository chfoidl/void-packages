FROM ghcr.io/void-linux/xbps-src-masterdir:20230425RC01-x86_64

# Prepare
# Sync and upgrade once, assume error comes from xbps update
RUN xbps-install -Syu || xbps-install -yu xbps \
  # Upgrade again (in case there was a xbps update)
  && xbps-install -yu

# Install dependencies
RUN xbps-install -Sy git \
  && git clone --depth 1 https://github.com/void-linux/void-packages.git /src-void-packages

ADD . /hostrepo
ADD ./scripts/build.sh /build.sh
ADD ./keys/14:95:38:fa:c3:67:b8:52:e7:0e:96:df:e9:5e:c8:24.plist /var/db/xbps/keys/14:95:38:fa:c3:67:b8:52:e7:0e:96:df:e9:5e:c8:24.plist

# Copy base-files from the source void-packages.
# This is required for xbps-src.
RUN cp -R /src-void-packages/srcpkgs/base-files /hostrepo/srcpkgs/base-files

# Add custom repo
RUN echo "repository=https://void-repo.ush.one/current" > /usr/share/xbps.d/12-repository-custom.conf

WORKDIR /hostrepo

# Prepare environment.
RUN ./common/travis/prepare.sh \
	&& ./xbps-src binary-bootstrap \
	&& xbps-install -Sy

ENTRYPOINT ["/build.sh"]
