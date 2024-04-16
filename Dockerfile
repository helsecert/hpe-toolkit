FROM docker.io/rockylinux/rockylinux:9.3

# SPP repo, contains ssacli and hponcfg
COPY hpe-spp.repo /etc/yum.repos.d/
# SUM repo, contains smartupdate
COPY hpe-sum.repo /etc/yum.repos.d/

# install smartupdate, hponcfg and ssacli
# openssl is required for hponcfg
# find is required for smartupdate
RUN dnf install -y \
            sum \
            hponcfg \
            ssacli \
            ssaducli \
            openssl \
            findutils \
 && rm -rf /var/cache/yum \
           /etc/yum.repos.d/hpe-spp.repo \
           /etc/yum.repos.d/hpe-sum.repo \
 && dnf clean all

# FWPP repo, contains firmware packages
COPY hpe-fwpp.repo /etc/yum.repos.d/

# upgrade script
COPY --chmod=0755 upgrade-firmware.sh /

# copy entrypoint and make it executable
COPY --chmod=0755 entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
