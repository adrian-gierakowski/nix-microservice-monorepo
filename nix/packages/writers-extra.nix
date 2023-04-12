{
  bash,
  coreutils,
  lib,
  makeWrapper,
  ripgrep,
  runCommandNoCC,
  writers,
  writeText,
}:
rec {
  writeScriptChecked = interpreter:
    let
      rg = lib.getExe ripgrep;
    in writers.makeScriptWriter {
      inherit interpreter;
      check = ''
        do_check() {
          # This should work with most shell interpreters.
          local check_error=$(${interpreter} -n $1 2>&1)

          if [[ -n $check_error ]]; then
            echo
            echo "$check_error"
            echo
            local file=$(echo "$check_error" | ${rg} -m 1 '(.*): line ([\d]+): ' -o -r '$1')
            local line=$(echo "$check_error" | ${rg} -m 1 '(.*): line ([\d]+): ' -o -r '$2')

            if [[ -n $file && -n $line ]]; then
              # pipe through rg to highlight in red
              echo "$file:$line" | ${rg} ".*"
              echo

              # Print with line numbers and highlight the line with error.
              ${coreutils}/bin/cat -n $1 | ${rg} "^\s+$line\s.*" -C 3
            fi
            exit 1
          fi
        }

        do_check''
      ;
    }
  ;

  writeBashChecked = writeScriptChecked "${bash}/bin/bash";

  writeBashBin = name: writeBashChecked "/bin/${name}";

  writeBashBinStrict = name: content: writeBashBin name ''
    set -ueo pipefail

    ${content}
  '';

  mkScriptBinWithDeps = interpreter: deps: name: content:
    let
      script-no-deps = writeBashChecked
        "${name}-no-deps"
        content
      ;
    in runCommandNoCC name { buildInputs = [ makeWrapper ]; } ''
      mkdir -p $out/bin
      binPath=$out/bin/${name}
      makeWrapper ${script-no-deps} $out/bin/${name} --prefix PATH : ${lib.makeBinPath deps}
    ''
  ;

  mkBashScriptBinWithDeps = mkScriptBinWithDeps "${bash}/bin/bash";

  writeJSON = { name, ext ? "json" }: value:
    let
      fullName = "${name}${if ext == "" then "" else ".${ext}"}";
    in
      writeText fullName (builtins.toJSON value);
}