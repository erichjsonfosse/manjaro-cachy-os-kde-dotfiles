gitcanhas() {
  # TODO: Receive project folder as input to install script
  project_folder="$HOME/projects"
  folder="$project_folder/$(basename "$1")"
  folder=${folder%.*}
  echo "Cloning $1 into $folder"
  git clone "$1" "$folder"
  cd "$folder" || exit
}

getlatesttag() {
  git -c 'versionsort.suffix=-' \
    ls-remote --exit-code --refs --sort='version:refname' --tags "$1" '*.*.*' |
    tail --lines=1 |
    cut --delimiter='/' --fields=3
}
