#!/bin/bash


echo "Installing App Images..."

mkdir -p "$APP_IMAGE_DIR"

# Atom Editor
wget -O "$APP_IMAGE_DIR/atom-editor.AppImage" "https://bintray.com/probono/AppImages/download_file?file_path=Atom-v1.18.0.glibc2.17-x86_64.AppImage"
# Insomnia Designer
wget -O "$APP_IMAGE_DIR/insomnia-designer.AppImage" "https://updates.insomnia.rest/downloads/linux/latest?app=com.insomnia.designer"
# Insomnia REST Client
wget -O "$APP_IMAGE_DIR/insomnia-rest-client.AppImage" "https://updates.insomnia.rest/downloads/linux/latest"
# Rambox
# wget -O "$APP_IMAGE_DIR/rambox.AppImage" "https://rambox.pro/api/downloadCE?os=linux&filetype=AppImage&arch=x86_64"

echo "App images downloaded"
