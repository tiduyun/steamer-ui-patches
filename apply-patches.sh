#!/bin/sh
# vim: set ft=sh fdm=manual ts=2 sw=2 sts=2 tw=85 et:

# ================================================
# Description: Apply localized patches
# Last Modified: Mon Apr 26, 2021 11:29
# Author: Allex Wang (allex.wxn@gmail.com)
# ================================================

set -eu

sh_dir=`cd -P -- "$(dirname -- "$(readlink -f $0)")" && pwd -P`

echo "Apply patches ..."

home_page="$sh_dir/steamer-ui/index.html"

if [ ! -f "${home_page}.tmpl" ]; then
  cp ${home_page} ${home_page}.tmpl
fi

script_patch="$(cat <<'CONFIG'
<script>
function getSteamerUiConfig () {
  return {
    'sys': {
      appBrandImage: null,
      appName: '梯度大数据集成平台',
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

cp -f /var/www/.cache/login-bg.jpeg /var/www/steamer-ui/img/login-bg.jpeg
grep "login-bg.png" $sh_dir/steamer-ui/css -rl |xargs sed -i"" "s#login-bg.png#login-bg.jpeg#g"

echo "apply localize done."
