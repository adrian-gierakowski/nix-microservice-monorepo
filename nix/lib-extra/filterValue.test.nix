let
  pkgs = import ../pkgs.nix {};
  inherit (pkgs) lib;
  inherit (lib.extra) filterValue;
  testNotModified = input: {
    expr = filterValue (_: _: true) input;
    expected = [input];
  };
in lib.extra.prependPrefixToAttrNames "test" {
  "not modified {}" = testNotModified {};
  "not modified { a = 1; }" = testNotModified { a = 1; };
  "not modified []" = testNotModified [];
  "not modified [1 []]" = testNotModified [1 []];
  "not modified [[]]" = testNotModified [[]];
  "not modified [{ a = 1; }]" = testNotModified [{ a = 1; }];
  "not modified complex" = testNotModified {
    a = 1;
    b = "B";
    c = null;
    # d = x: x;
    e = [];
    f = [{ g = 1; } { h = []; }];
  };
  "filter by value in list" = {
    expr = filterValue (_: value: value != 1) [1 2 3 1];
    expected = [[2 3]];
  };
  "filter by value in attrs" = {
    expr = filterValue (_: value: value != 1) { a = 1; b = 2; c = 1; };
    expected = [{ b = 2; }];
  };
  "filters by type in list" = {
    expr = filterValue (_: value: !builtins.isFunction value) [1 lib.id 2];
    expected = [[1 2]];
  };
  "filter by type value in attrs" = {
    expr = filterValue (_: value: !builtins.isFunction value) { a = 1; b = lib.id; c = 2; };
    expected = [{ a = 1; c = 2; }];
  };
  "filter by name value in attrs" = {
    expr = filterValue (name: _: !(name == "a")) { a = 1; b = 2; null = 3; c = []; };
    expected = [{ b = 2; null = 3; c = []; }];
  };
}