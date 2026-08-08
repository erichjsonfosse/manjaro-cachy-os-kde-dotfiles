#!/usr/bin/env bash

logHeader "Configuring Onefetch Greeter"

# Remove existing onefetch block if present
sed -i '/^# BEGIN ONEFETCH GREETER/,/^# END ONEFETCH GREETER/d' "$ZSHRC_FILE"

{
  printf "\n# BEGIN ONEFETCH GREETER\n"
  printf "##### Onefetch Git repository greeter #####\n"
  printf "last_repository=\n"
  printf "check_directory_for_new_repository() {\n"
  printf "  current_repository=\$(git rev-parse --show-toplevel 2>/dev/null)\n\n"
  printf "  if [ \"\$current_repository\" ] &&\n"
  printf "    [ \"\$current_repository\" != \"\$last_repository\" ]; then\n"
  printf "    onefetch\n"
  printf "  fi\n"
  printf "  last_repository=\"\$current_repository\"\n"
  printf "}\n"
  printf "chpwd_functions+=(check_directory_for_new_repository)\n"
  printf "##### Onefetch Git repository greeter #####\n"
  printf "# END ONEFETCH GREETER\n"
} >> "$ZSHRC_FILE"

logSuccess "Onefetch configuration applied!"
