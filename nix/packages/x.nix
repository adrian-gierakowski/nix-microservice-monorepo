{
  lib,
  jq,
  coreutils,
  gnused,
  fzf,
  jq-repl,
  writers-extra,
  name ? "x"
}:
let
  rm = "${coreutils}/bin/rm";
  head = "${coreutils}/bin/head";
  sed = lib.getExe gnused;
  jqExe = lib.getExe jq;
in writers-extra.writeBashBin
  name
  ''
  env=''${1:-prd}

  prefix="platform.$env.config"

  json=$(nix eval --json -f nix/pkgs.nix "$prefix")

  declare RESULT=($(echo "$json" | ${lib.getExe jq-repl}))

  selected_path=$(echo ''${RESULT[0]} | ${sed} -e 's/\[//' -e 's/\]//')
  value_at_path=''${RESULT[1]}

  full_path=$prefix$selected_path

  if [[ $(echo "$value_at_path" | sed -n '1{/^\/nix\/store/p};q1') ]];
  then
    read -p "enter arguments for: $value_at_path" MY_PARAMS
    eval "exec nix run -f nix/pkgs.nix $full_path -- $MY_PARAMS"
  else
    echo "$value_at_path"
  fi
  ''
