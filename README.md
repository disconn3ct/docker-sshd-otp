SSH Host with Fail2ban, Google Authenticator
===
This docker container bundles up sshd, fail2ban and google-authenticator TOTP into a secure ssh gateway box.

The 'Dockerfile-alt' can be used to prepopulate your authorized keys and google-authenticator config. You will need to put the keys into 'ssh/authorized_keys' and put the .google_authenticator file into 'google_authenticator'.

Alternately, you can run it with the shipped Dockerfile and use 'exec' to put those files in place in the final image:

```
cat google_authenticator | docker exec -i jovial_nobel sh -c 'cat >> /root/.google_authenticator'
cat ~/.ssh/id_rsa.pub | docker exec -i jovial_nobel sh -c 'cat >> /root/.ssh/authorized_keys'
```

