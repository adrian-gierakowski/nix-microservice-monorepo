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

  stripExtension = str:
    let
      matched = (builtins.match "(.*)\\..*" str);
    in
      if matched == null
      # no . was found so return the whole thing
      then str
      # the first elem contains chars up to last .
      else builtins.elemAt matched 0
  ;

  # Compose an array of functions, for example, assuming that f, g and h
  # are functions:
  # z = compose [f g h];
  # z 1 == f(g(h 1)) == compose [f g h] 1
  compose = funcs: firstArg: lib.foldr (f: x: f x) firstArg funcs;

  listFilesFromDir = compose [
    (builtins.map (attrs: attrs.name))
    (builtins.filter ({ name, type }:
      # Only keep regular files and and symlinks (no directories)
      # TODO: resolve symlink and make sure it points to regular file.
      (type == "regular") ||
      (type == "symlink") &&
      # Ignore hidden files
      (builtins.substring 0 1 name) != "." )
    )
    (lib.mapAttrsToList (name: type: { inherit name type; }))
    builtins.readDir
  ];

  listDirEntries = path:
    map
      (name: path + "/${name}")
      (builtins.attrNames (builtins.readDir path));

  # Given a directory path, returns an attrset:
  # {
  #   "file-1-name-with-stripped-extension" = import file-1;
  #   "file-2-name-with-stripped-extension" = import file-2;
  #   ...
  # }
  importFilesFromDir = dirPath: compose
    [
      builtins.listToAttrs
      (builtins.map (name: {
        name = stripExtension name;
        value = import (dirPath + "/${name}");
      }))
      # keep only nix files
      (builtins.filter (fileName: builtins.match ".*\.nix$" fileName != null))
      listFilesFromDir
    ]
    dirPath
  ;

  # Given a directory path and pkgs, returns an attrset:
  # {
  #   "file-1-name-with-stripped-extension" = pkgs.callPackage (import file-1) {};
  #   "file-2-name-with-stripped-extension" = pkgs.callPackage (import file-2) {};
  #   ...
  # }
  importPackagesFromDir = pkgs: dirPath:
    let filesAsAttrs = importFilesFromDir dirPath;
    in builtins.mapAttrs
      (name: value: pkgs.callPackage value {})
      filesAsAttrs
  ;

  toJSONFile = name: config: builtins.toFile "${name}.json" (builtins.toJSON config);

  tracePrefix = prefix: x:
    builtins.trace ("${prefix} ${lib.generators.toPretty {} x}") x
  ;

  filterValue =
    let
      filterValueWithName = pred: name: x:
        if !(pred name x)
        then []
        else if builtins.isList x
        then [(filterList pred x)]
        else if builtins.isAttrs x
        then [(filterAttrs pred x)]
        else [x]
      ;
      filterList = pred: builtins.concatMap
        (filterValueWithName pred null)
      ;
      filterAttrs = pred: value:
        builtins.listToAttrs (
          builtins.concatMap
            (name:
              let
                result = filterValueWithName pred name value.${name};
              in
                map (lib.nameValuePair name) result
            )
            (builtins.attrNames value)
          )
      ;
    in pred: value: filterValueWithName pred null value
  ;

  isIn = v: list: builtins.any (e: v == e) list;

  cleanConfig = removeAttrNames: lib.filterAttrsRecursive (name: value:
    !(isIn name removeAttrNames || builtins.isFunction value)
  );

  prependPrefixToAttrNames = prefix: lib.mapAttrs'
    (name: value: lib.nameValuePair "${prefix}${name}" value)
  ;

  headOr = default: list:
    if list == []
    then default
    else builtins.head list
  ;

  assocPath = path: value: attrs:
    lib.recursiveUpdateUntil
      (currentPath: _: _: currentPath == path)
      attrs
      (lib.setAttrByPath path value)
  ;

  overPathIfExists = path: func: attrs:
    if lib.hasAttrByPath path attrs
    then
      let
        currentValue = lib.getAttrFromPath path attrs;
        newValue = func currentValue;
      in
        assocPath path newValue attrs
    else attrs
  ;
  allDefault = builtins.mapAttrs (name: value: lib.mkDefault value);
  allForce = builtins.mapAttrs (name: value: lib.mkForce value);
}