#!/bin/bash
set -eu -o pipefail
echo "Creating group: ${USERNAME}"
groupadd -g 65000 "${USERNAME}"
echo "Creating user: ${USERNAME}"
useradd -u 65000 -g 65000 -m -p '' -s /bin/bash "${USERNAME}"

umask '077'
echo "Configuring secrets"
mkdir "/home/${USERNAME}/.ssh"
cp /run/secrets/ssh-authorized-keys "/home/${USERNAME}/.ssh/authorized_keys"
cp /run/secrets/google-authenticator "/home/${USERNAME}/.google_authenticator"
chown -R "${USERNAME}:" "/home/${USERNAME}"
umask '0022'

echo "Templating fail2ban configuration. IGNORE_IP: ${IGNORE_IP:-none}"
export T_IGNORE_IP=${IGNORE_IP:-}
export T_DESTEMAIL=${DESTEMAIL:-}
for prg_path in /etc/template/*; do
  prg=$(basename $prg_path)
  if [[ -d "/etc/template/${prg}" ]]; then
    for tem_path in /etc/template/${prg}/*; do
      tem=$(basename $tem_path)
      if [[ -f "/etc/template/${prg}/${tem}" ]]; then
        echo "Templating ${prg}: ${tem}"
        envsubst < "/etc/template/${prg}/${tem}" > "/etc/${prg}/${tem}"
      fi
    done
  fi
done
echo "Starting: $@"
exec "$@"
