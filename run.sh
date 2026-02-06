#!/usr/bin/env bash
set -euo pipefail

OPTIONS_FILE="/data/options.json"

# Defaults
log_level="info"
log_format="text"
allow_analytics="false"
web_max_upload_size="10"
label_maker_font_size="24"
label_maker_height="96"
label_maker_margin="5"
label_maker_padding="5"
label_maker_width="320"
label_maker_print_command="cp {{.FileName}} /data/labels/label.png"

if [ -f "${OPTIONS_FILE}" ]; then
  log_level="$(jq -r '.log_level // "info"' "${OPTIONS_FILE}")"
  log_format="$(jq -r '.log_format // "text"' "${OPTIONS_FILE}")"
  allow_analytics="$(jq -r '.allow_analytics // false' "${OPTIONS_FILE}")"
  web_max_upload_size="$(jq -r '.web_max_upload_size // 10' "${OPTIONS_FILE}")"
  label_maker_font_size="$(jq -r '.label_maker_font_size // 24' "${OPTIONS_FILE}")"
  label_maker_height="$(jq -r '.label_maker_height // 96' "${OPTIONS_FILE}")"
  label_maker_margin="$(jq -r '.label_maker_margin // 5' "${OPTIONS_FILE}")"
  label_maker_padding="$(jq -r '.label_maker_padding // 5' "${OPTIONS_FILE}")"
  label_maker_width="$(jq -r '.label_maker_width // 320' "${OPTIONS_FILE}")"
  label_maker_print_command="$(jq -r '.label_maker_print_command // "cp {{.FileName}} /data/labels/label.png"' "${OPTIONS_FILE}")"
fi

mkdir -p /data /data/labels

export HBOX_LOG_LEVEL="${log_level}"
export HBOX_LOG_FORMAT="${log_format}"
export HBOX_OPTIONS_ALLOW_ANALYTICS="${allow_analytics}"
export HBOX_WEB_MAX_UPLOAD_SIZE="${web_max_upload_size}"
export HBOX_LABEL_MAKER_FONT_SIZE="${label_maker_font_size}"
export HBOX_LABEL_MAKER_HEIGHT="${label_maker_height}"
export HBOX_LABEL_MAKER_MARGIN="${label_maker_margin}"
export HBOX_LABEL_MAKER_PADDING="${label_maker_padding}"
export HBOX_LABEL_MAKER_WIDTH="${label_maker_width}"
export HBOX_LABEL_MAKER_PRINT_COMMAND="${label_maker_print_command}"

echo "[homebox-addon] Options loaded:"
echo "  HBOX_LOG_LEVEL=${HBOX_LOG_LEVEL}"
echo "  HBOX_LOG_FORMAT=${HBOX_LOG_FORMAT}"
echo "  HBOX_OPTIONS_ALLOW_ANALYTICS=${HBOX_OPTIONS_ALLOW_ANALYTICS}"
echo "  HBOX_WEB_MAX_UPLOAD_SIZE=${HBOX_WEB_MAX_UPLOAD_SIZE}"
echo "  HBOX_LABEL_MAKER_PRINT_COMMAND=${HBOX_LABEL_MAKER_PRINT_COMMAND}"

# Homebox binary im Image (bei dir ist es /app/api)
if [ -x /app/api ]; then
  echo "[homebox-addon] Starting: /app/api"
  exec /app/api
fi

# Fallbacks (falls Image sich ändert)
for c in homebox /app/homebox /usr/local/bin/homebox /usr/bin/homebox; do
  if command -v "$c" >/dev/null 2>&1; then
    echo "[homebox-addon] Starting via: $c"
    exec "$c"
  fi
  if [ -x "$c" ]; then
    echo "[homebox-addon] Starting via: $c"
    exec "$c"
  fi
done

echo "[homebox-addon] ERROR: No executable found. /app listing:"
ls -la /app || true
exit 1
