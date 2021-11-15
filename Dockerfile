FROM scratch
ADD ./patch /var/patch

FROM scratch
ENV APP_NAME=大数据综合应用集成框架系统
ENV APP_INITIAL_SCRIPT="<style>.m-login-form .form .hd .logo{height:22px;}.m-login-form .form .hd .title{font-size:19px;}</style>"
ENV APP_AUTH_TYPE=token/bigdata APP_AUTH_TOKEN_NAME=admin_token
ENV PATCH_FILE=/var/patch/.apply.sh
COPY --from=0 / /
