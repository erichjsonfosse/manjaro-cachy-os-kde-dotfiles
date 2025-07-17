# Return if keychain is not found
if (( ! $+commands[keychain] )); then
  return
fi

SHORT_HOST=${SHORT_HOST:-${(%):-%m}}

loadIdentitiesFromSshFolder()
{
  files=$(find ~/.ssh -type f -name "id_*" -not -name "*.pub")
  declare -a filenames=()

  for f in "${files[@]}"
  do
    filenames+=("${f##*/}") # Extracts everything after last /
  done

  printf "%s\n" "${filenames[@]}"
}

runKeychain()
{
	local -a identities
	identities=$(loadIdentitiesFromSshFolder)
	local _keychain_env_sh
	local _keychain_env_sh_gpg

	# Start keychain
	for i in $identities
	do
	  keychain --quiet "$i" --host "$SHORT_HOST"
	done

	# Get the filenames to store/lookup the environment from
	_keychain_env_sh="$HOME/.keychain/$SHORT_HOST-sh"
	_keychain_env_sh_gpg="$HOME/.keychain/$SHORT_HOST-sh-gpg"

	# Source environment settings.
	[ -f "$_keychain_env_sh" ]     && . "$_keychain_env_sh"
	[ -f "$_keychain_env_sh_gpg" ] && . "$_keychain_env_sh_gpg"
}

runKeychain
