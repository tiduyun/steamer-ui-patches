#!/bin/sh
# vim: set ft=sh fdm=manual ts=2 sw=2 sts=2 tw=85 et:

# ================================================
# Description: Apply localized patches
# Last Modified: Mon Jun 21, 2021 20:27
# Author: Allex Wang (allex.wxn@gmail.com)
# ================================================

set -eu

sh_dir=`cd -P -- "$(dirname -- "$(readlink -f $0)")" && pwd -P`

echo "Apply patches ..."

home_page="$sh_dir/steamer-ui/index.html"

if [ ! -f "${home_page}.tmpl" ]; then
  cp ${home_page} ${home_page}.tmpl
fi

script_patch="$(cat <<CONFIG
${APP_INITIAL_SCRIPT:-}
<script>
function getSteamerUiConfig () {
  return {
    'sys': {
      appBrandImage: null,
      appName: '${APP_NAME:-梯度智能云}',
      copyright: ''
    }
  }
}
</script>
CONFIG
)";

awk -v input="${script_patch}" \
  'NR == 1, /<body>/ { sub(/<body>/, "<body>\n"input) } 1' \
  "${home_page}.tmpl" > ${home_page}

echo "patch "${home_page}" done."

login_bg=/var/www/.cache/login-bg.jpeg
if [ -f $login_bg ]; then
  cp -f $login_bg /var/www/steamer-ui/img/login-bg.jpeg
  grep "login-bg.png" $sh_dir/steamer-ui/css -rl |xargs sed -i"" "s#login-bg.png#${login_bg##*/}#g"
fi

if [ -z "${ARGO_ENDPOINT}" ]; then
  echo >&2 "env 'ARGO_ENDPOINT' not defined"
  exit 1
fi
echo '${ARGO_ENDPOINT}' >> /etc/nginx/.vars

echo "apply localize done."
