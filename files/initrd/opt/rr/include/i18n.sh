if [ -f ${BOOTLOADER_PATH}/.locale ]; then
  export LANG="$(cat ${BOOTLOADER_PATH}/.locale)"
fi

alias TEXT='gettext "rr"'
shopt -s expand_aliases
