FROM alpine:3.12

LABEL maintainer="Avi Deitcher <https://github.com/deitch>"

LABEL maintainer2="Simone M. Zucchi <simone.zucchi@gmail.com>"

ARG USER_NAME=appuser
ARG USER_UID=1005
ARG USER_GID=1005

ARG AWSCLI_VER=1.18.211
ARG BASH_VER=5.0.17-r0
ARG MARIADB_CLIENT_VER=10.4.15-r0
ARG MARIADB_CONNECTOR_C_VER=3.1.8-r1
ARG PYTHON3_VER=3.8.5-r0
ARG SAMBA_CLIENT_VER=4.12.9-r0
ARG SHADOW_VER=4.8.1-r0
ARG OPENSSL_VER=1.1.1i-r0

# install the necessary client
# the mysql-client must be 10.3.15 or later
RUN apk add --no-cache \
      bash=${BASH_VER} \
      mariadb-client=${MARIADB_CLIENT_VER} \
      mariadb-connector-c=${MARIADB_CONNECTOR_C_VER} \
      python3=${PYTHON3_VER} \
      samba-client=${SAMBA_CLIENT_VER} \
      shadow=${SHADOW_VER} \
      openssl=${OPENSSL_VER} && \
    touch /etc/samba/smb.conf && \
    # set us up to run as non-root user
    groupadd -g ${USER_GID} ${USER_NAME} && \
    useradd -r -u ${USER_UID} -g ${USER_GID} ${USER_NAME} && \
    # ensure smb stuff works correctly
    mkdir -p /var/cache/samba && \
    chmod 0755 /var/cache/samba && \
    chown ${USER_NAME} /var/cache/samba

USER ${USER_NAME}

RUN pip3 install --user awscli==${AWSCLI_VER}

# install the entrypoint
COPY functions.sh /
COPY entrypoint /entrypoint

# start
ENTRYPOINT [ "/entrypoint" ]
