FROM scratch

ADD ./default.conf /etc/nginx/conf.d/
ADD ./apply-patches.sh /var/www/.apply_patches.sh
ADD ./login-bg.jpeg /var/www/.cache/

FROM scratch
COPY --from=0 / /
