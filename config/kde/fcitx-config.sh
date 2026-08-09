#!/usr/bin/env bash

# Configure Fcitx 5 Wayland Virtual Keyboard, /etc/environment variables, and layout profile
KWIN_CONFIG_FILE="$HOMEDIR/.config/kwinrc"

logInfo "Setting active Input Method to Fcitx 5..."
writeKdeConfig "$KWIN_CONFIG_FILE" "Wayland" "InputMethod" "/usr/share/applications/org.fcitx.Fcitx5.desktop"

if [ -w "/etc/environment" ]; then
  logInfo "Configuring Fcitx 5 environment variables in /etc/environment..."
  for env_var in "GTK_IM_MODULE=fcitx" "QT_IM_MODULE=fcitx" "XMODIFIERS=@im=fcitx"; do
    if ! grep -q "^$env_var" /etc/environment 2>/dev/null; then
      echo "$env_var" >> /etc/environment
    fi
  done
fi

FCITX5_PROFILE_DIR="$HOMEDIR/.config/fcitx5"
FCITX5_PROFILE_FILE="$FCITX5_PROFILE_DIR/profile"
FCITX5_CONFIG_FILE="$FCITX5_PROFILE_DIR/config"

if [ -d "$HOMEDIR/.config" ]; then
  mkdir -p "$FCITX5_PROFILE_DIR"
  cat << 'EOF' > "$FCITX5_PROFILE_FILE"
[Groups/0]
Name=Default
Default Layout=us
DefaultIM=keyboard-us

[Groups/0/Items/0]
Name=keyboard-us
Layout=

[Groups/0/Items/1]
Name=keyboard-no
Layout=

[GroupOrder]
0=Default
EOF

  writeKdeConfig "$FCITX5_CONFIG_FILE" "Hotkey/TriggerKeys" "0" "Super+space"
  chown -R "$LOGNAME:$LOGNAME" "$FCITX5_PROFILE_DIR" 2>/dev/null || true
fi
