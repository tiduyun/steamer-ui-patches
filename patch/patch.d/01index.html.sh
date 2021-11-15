home_file="${WEB_ROOT}/index.html"
if [ ! -f "${home_file}.tmpl" ]; then
  cp "$home_file" "$home_file".tmpl
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
  var authConfig = {
    authType: '${APP_AUTH_TYPE:-default}',
    tokenName: '${APP_AUTH_TOKEN_NAME:-token}'
  }
  return { sys: sysConfig, authConfig: authConfig }
}
</script>
__CONFIG__
)";

awk -v input="${script_patch}" \
  'NR == 1, /<body>/ { sub(/<body>/, "<body>\n"input) } 1' \
  "$home_file".tmpl > "$home_file"

echo "patch \"${home_file}\" done."

