#!/bin/sh
# vim: set ft=sh fdm=manual ts=2 sw=2 sts=2 tw=85 et:

# ================================================
# Description: Apply localized patches
# Last Modified: Tue Oct 26, 2021 19:40
# Author: Allex Wang (allex.wxn@gmail.com)
# ================================================

set -eu

sh_dir=$(cd -P -- "$(dirname -- "$(readlink -f "$0")")" && pwd -P)

PATCH_HOME=/var/patch
PATCH_ASSETS_HOME=${PATCH_HOME}/assets
LOCK_FILE=${PATCH_HOME}/.patched

# prevent duplicate patch
[ -f "$LOCK_FILE" ] && exit

BASE_DIR=/var/www
WEB_ROOT=${BASE_DIR}/steamer-ui

find_file () {
  find "${PATCH_ASSETS_HOME}" -maxdepth 5 -name "$1" | head -n 1
}

echo "Apply patches ..."

home_file="${WEB_ROOT}/index.html"
if [ ! -f "${home_file}.tmpl" ]; then
  cp ${home_file} ${home_file}.tmpl
fi

# -> logo image
logo_file=$(find_file logo.*)
if [ "$logo_file" ]; then
  LOGO_PATH=/${logo_file##*/}
  cp "$logo_file" "${WEB_ROOT}${LOGO_PATH}"
fi

# -> app customize configs
script_patch="$(cat <<__CONFIG__
${APP_INITIAL_SCRIPT:-}
<script>
function getSteamerUiConfig () {
  var sysConfig = {
    appBrandImage: null,
    appName: '${APP_NAME:-\$\{APP_NAME\}}',
    copyright: ''
  }
  var appLogo = '${LOGO_PATH:-}'
  if (appLogo) sysConfig.appLogo = appLogo
  return { sys: sysConfig }
}
</script>
__CONFIG__
)";

awk -v input="${script_patch}" \
  'NR == 1, /<body>/ { sub(/<body>/, "<body>\n"input) } 1' \
  "${home_file}.tmpl" > ${home_file}

echo "patch \"${home_file}\" done."

# -> login_bg image
cust_login_bg=$(find_file login-bg.*)
if [ -f "$cust_login_bg" ]; then
  filename="${cust_login_bg##*/}"
  origin_filename=login-bg.png
  cp -f "${cust_login_bg}" "${WEB_ROOT}/img/$filename"
  if [ "$filename" != "$origin_filename" ]; then
    grep "${origin_filename}" ${WEB_ROOT}/css -rl |xargs -r sed -i"" "s#${origin_filename}#${filename}#g"
  fi
fi

for i in "${PATCH_HOME}"/patch.d/*.sh ; do
  if [ -r "$i" ]; then
    if [ "${-#*i}" != "$-" ]; then
      . "$i"
    else
      . "$i" >/dev/null
    fi
  fi
done

touch "$LOCK_FILE"
echo "apply localize done."
