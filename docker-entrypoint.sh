#!/bin/bash
set -e

if [[ "$UPDATE_ON_START" == "true" ]]; then
    steamcmd +force_install_dir "$APP_DIR" +@sSteamCmdForcePlatformType windows \
        +login "$STEAM_USERNAME" "$STEAM_PASSWORD" "$STEAM_GUARD" \
        +app_update "$APP_ID" validate +quit
fi

if [[ "$RESET_SEED" == "true" ]]; then
    rm -rf "$APP_DIR/Moria/Saved/Config/InviteSeed.cfg"
fi

SETTINGS_FILE="$APP_DIR/MoriaServerConfig.ini"
if [[ ! -f $SETTINGS_FILE ]]; then
    echo "No configuration file found, linking default"
    ln -s "$CONFIG_DIR/MoriaServerConfig.ini" $SETTINGS_FILE

    echo "Setting ports in configuration file"
    sed -i "s/ListenPort=7777/ListenPort=$GAME_PORT/" $SETTINGS_FILE
fi

SAVE_DIR="$APP_DIR/Moria/Saved"
if [[ ! -d $SAVE_DIR ]]; then
    echo "No save file found, linking directory"
    mkdir -p "$APP_DIR/Moria"
    ln -s "$DATA_DIR" $SAVE_DIR
fi

echo "Starting fake screen"
rm -f /tmp/.X0-lock 2>&1
Xvfb :0 -screen 0 1024x768x24 &

echo "Starting Moria"
DISPLAY=:0.0 wine "$APP_DIR/MoriaServer.exe"
