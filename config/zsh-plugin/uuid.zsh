hextouuid (){
  sed 's/./&-/8;s/./&-/13;s/./&-/18;s/./&-/23;s/\(.*\)/\L\1/' <<< "$1"
}

uuidtohex (){
  sed 's/[-]//g;s/\(.*\)/\U\1/' <<< "$1"
}

uuidtoclipboard (){
  echo -n "$(uuidgen -r)" | xclip -sel clip && xclip -out -sel clip
}

hexuuidtoclipboard (){
  echo -n "$(uuidgen -r)" | sed 's/-//g' | tr '[:lower:]' '[:upper:]' | xxd -r -p | xclip -sel clip && xclip -out -sel clip
}
