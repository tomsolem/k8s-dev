FROM alpine:latest
# https://git-scm.com/book/en/v2/Git-on-the-Server-Setting-Up-the-Server

RUN apk update && apk add --update --no-cache openssh git git-daemon apache2 apache2-utils openrc coreutils
#    User git
#    PreferredAuthentications publickey
#    IdentityFile ~/.ssh/authorized_keys
RUN adduser -h /home/git -s /bin/sh -D git
RUN echo -n 'git:secret' | chpasswd
RUN mkdir -p /srv
RUN mkdir -p /mnt/shared
RUN chown git /srv
RUN chown git /mnt/shared
USER git

#Set fake user details for initial git commit
RUN git config --global user.email "you@example.com"
#Init repositories with an initial commit
RUN mkdir -p "/srv/git/org/flux-gitops"
WORKDIR  "/srv/git/org/flux-gitops"
RUN git init -b main
RUN touch .gitignore
RUN git add .
RUN git commit -m "First commit"
RUN git config --bool core.bare true

RUN mkdir -p "/home/git/.ssh"
RUN touch /home/git/.ssh/authorized_keys && chmod 600 /home/git/.ssh/authorized_keys

RUN mkdir -p "/home/git/tmp/ssh"
RUN ssh-keygen -t rsa -f "/home/git/tmp/ssh/git-server_id" -N ''
RUN cat "/home/git/tmp/ssh/git-server_id.pub" > "/home/git/.ssh/authorized_keys"


USER git

ENTRYPOINT ["/entrypoint.sh"]
EXPOSE 22
COPY entrypoint.sh /