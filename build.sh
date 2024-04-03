#!/usr/bin/env bash

zmk_path="$HOME/code/zmk"
zmk_config_path="$HOME/code/zmk-config"
output="$zmk_config_path/out"

[[ -z $BOARDS ]] && BOARDS="$(grep '^[[:space:]]*-[[:space:]]*board:' $zmk_config_path/build.yaml | sed 's/^.*: *//')"

function build() {
  cd $zmk_path/app
  for board in $(echo $BOARDS | sed 's/,/ /g')
  do
    west build -b $board -d build/$board -- -DZMK_CONFIG="$zmk_config_path/config" -Wno-dev > "/tmp/zmk_$board.log"
    if [[ $? -ne 0 ]]; then
      echo "Build failed for $board"
      echo "Last 20 lines of /tmp/zmk_$board.log:"
      tail -n 20 "/tmp/zmk_$board.log"
      exit 1
    fi

    cp "$zmk_path/app/build/$board/zephyr/zmk.uf2" "$output/$board.uf2"
  done
}

if [[ $1 == "watch" ]]; then
	fd | entr -c -r $0 "build"
	exit 0
fi

if [[ $1 == "flash" ]]; then
  cd $zmk_path/app
    west flash

  # log stream --predicate '(composedMessage contains "Volumes/GLV80") && (sender == "mscamerad-xpc")' | while read line; do
  #   west flash
  # done

	exit 0
fi


if [[ $1 == "build" ]]; then
  build

	echo
	echo "UF2 files built"

	ls -l $output

	exit 0
fi

echo "Usage: $0 [watch|build]"

