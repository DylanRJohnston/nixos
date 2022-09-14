FROM nixos/nix

RUN echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf
RUN echo "max-jobs = auto" >> /etc/nix/nix.conf
# Doesn't work through Docker for Mac
RUN echo "filter-syscalls = false" >> /etc/nix/nix.conf

RUN nix-env -i openssh gnused

RUN mkdir -p /etc/ssh \
  && mkdir /var/empty \
  && mkdir /run \
  && echo "sshd:x:498:65534::/var/empty:/run/current-system/sw/bin/nologin" >> /etc/passwd \
  && sed -i 's/root:!/root:\*/' /etc/shadow \
  && sed -i 's#/bin/bash#/root/.nix-profile/bin/bash#' /etc/passwd \
  && cp /root/.nix-profile/etc/ssh/sshd_config /etc/ssh/ \
  && echo "export NIX_PATH=$NIX_PATH" >> /etc/bashrc \
  && echo "export NIX_SSL_CERT_FILE=$NIX_SSL_CERT_FILE" >> /etc/bashrc \
  && echo "export PATH=$PATH" >> /etc/bashrc \
  && echo "source /etc/bashrc" >> /etc/profile

RUN ssh-keygen -A
ADD nix-build-slave.key.pub /root/.ssh/authorized_keys

EXPOSE 22
# sshd cant be invoked behind a symlink
CMD ["/bin/sh", "-c", "$(readlink -f $(which sshd)) -D -e"]