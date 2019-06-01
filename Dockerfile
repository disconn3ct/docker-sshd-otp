FROM ubuntu:bionic

# These shouldn't have to change often
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord","-c","/etc/supervisor/supervisord.conf"]

EXPOSE 22
VOLUME /home

# fail2ban requires ed
# templates require envsubst from gettext-base
RUN apt update && \
    apt install -y \
      ed \
      fail2ban \
      gettext-base \
      libpam-google-authenticator \
      openssh-client \
      openssh-server \
      python-pyinotify \
      rsyslog \
      ssh \
      supervisor
ENV DEBIAN_FRONTEND=noninteractive

# Enable google-auth
ADD common-auth.conf /etc/pam.d/common-auth
# Same for SSH
RUN sed -i 's/^ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/' /etc/ssh/sshd_config
RUN sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
RUN echo 'AuthenticationMethods "publickey,keyboard-interactive"' >> /etc/ssh/sshd_config

# Set up directories
RUN mkdir -p /var/run/sshd /var/log/supervisor /var/run/fail2ban /etc/template/fail2ban

# Configurations:
ADD rsyslog.conf /etc/rsyslog.d/10-stdout.conf
ADD fail2ban-supervisor.sh /usr/local/bin/
ADD supervisor.d/* /etc/supervisor/conf.d/
ADD fail2ban/* /etc/template/fail2ban/
ADD entrypoint.sh /

RUN apt update && apt upgrade -y && apt clean && rm -rf /var/lib/apt/lists/*
