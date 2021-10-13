FROM scratch
ADD ./patch /var/patch

FROM scratch
ENV APP_NAME=梯度智能云
ENV PATCH_FILE=/var/patch/.apply.sh
COPY --from=0 / /
