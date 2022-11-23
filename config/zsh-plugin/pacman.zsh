icanhas (){
  # TODO: Search for package before attempting to install
  # TODO: Try next repo if not found (core, AUR, snap)
  pacman -Syy "$1"
}
