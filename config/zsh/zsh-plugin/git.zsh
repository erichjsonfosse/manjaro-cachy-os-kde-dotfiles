getlatesttag() {
  git -c 'versionsort.suffix=-' \
    ls-remote --exit-code --refs --sort='version:refname' --tags "$1" '*.*.*' |
    tail --lines=1 |
    cut --delimiter='/' --fields=3
}
