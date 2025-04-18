# Generate KDE Plasma ServiceMenus

{ pkgs, lib, config, name, ... }:

with lib;

let
  cfg = config.serviceMenus;

  actionType = with types; {
    options = {
      exec = mkOption { type = str; };
      icon = mkOption { type = nullOr str; default = null; };
    };
  };

  menuType = with types; {
    options = {
      mimetypes = mkOption { type = listOf str; };
      terminal = mkOption {
        type = bool;
        default = false;
      };
      protocols = mkOption {
        type = nullOr (listOf str);
        default = null;
      };
      minNumberOfUrls = mkOption {
        type = nullOr int;
        default = null;
      };
      maxNumberOfUrls = mkOption {
        type = nullOr int;
        default = null;
      };
      requiredNumberOfUrls = mkOption {
        type = nullOr (listOf int);
        default = null;
      };
      actions = mkOption {
        type = attrsOf (submodule actionType);
      };
    };
  };
  
  mkPath = entry:
    "${config.xdg.dataHome}/kio/servicemenus/hm-${toKebabCase entry.name}.desktop";

  toKebabCase = string:
    toLower (replaceStrings [" "] ["-"] string);

  # TODO: Allow multiple actions in one desktop entry
  mkEntryText = entry: with entry;
  let
    reqUrls = if (entry.requiredNumberOfUrls != null) then
      concatStringsSep "," (
        forEach entry.requiredNumberOfUrls (x: toString x )
      ) else null;

    numberOfActions =
      length (attrValues entry.actions);
  in
    ''
      # Auto-generated by home-manager

      [Desktop Entry]
      Version=1.0
      Type=Service
      Actions=${concatStringsSep ";" (mapAttrsToList (name: value: (toKebabCase name) ) entry.actions)}
      MimeType=${concatStringsSep ";" entry.mimetypes}
    ''
    + optionalString (terminal) "Terminal=true\n"
    + optionalString (numberOfActions > 1) "X-KDE-Submenu=${entry.name}\n"
    + optionalString (protocols != null) "X-KDE-Protocols=${concatStringsSep "," protocols}\n"
    + optionalString (minNumberOfUrls != null) "X-KDE-MinNumberOfUrls=${toString minNumberOfUrls}\n"
    + optionalString (maxNumberOfUrls != null) "X-KDE-MaxNumberOfUrls=${toString maxNumberOfUrls}\n"
    + optionalString (reqUrls != null) "X-KDE-requiredNumberOfUrls=${toString reqUrls}\n"
    + (foldl' (a: b: a + b) "" (forEach ( addNameToAttrs entry.actions) (x: mkActionText x )));

    mkActionText = action:
    ''

      [Desktop Action ${toKebabCase action.name}]
      Name=${action.name}
      Exec=${action.exec}
    ''
    + optionalString (action.icon != null) "Icon=${action.icon}\n"
    ;

    addNameToAttrs = attrs:
      mapAttrsToList (name: value: value // { inherit name; } ) attrs;

in {
  options.serviceMenus = with types; mkOption {
    type = attrsOf (submodule menuType);
  };

  config = {
    home.file = foldl' (a: b: a // b) {} (
      forEach (addNameToAttrs cfg) (x: { ${mkPath x}.text = mkEntryText x; } )
    );
  };
}
