{ lib }:
rec {
  attrsToAttsOfJsonStrings = builtins.mapAttrs (name: value:
    (
      if builtins.isAttrs value || builtins.isList value then builtins.toJSON
      else toString
    ) value
  );
  mkSubmoduleOpts = attrs: lib.types.submodule ({
  	options = mkOptions attrs;
  });
  mkOptions = attrs: builtins.mapAttrs
		(_: value: if value._type == "option" then value else lib.mkOption { type = value; })
		attrs
  ;
}