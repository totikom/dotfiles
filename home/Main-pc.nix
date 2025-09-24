{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs = {
    beets = {
      enable = true;
      settings = {
        directory = "~/Music";
        library = "~/Documents/musiclibrary.db";
        import = {
          move = true;
          incremental = true;
          language = [
            "en"
            "ru"
          ];
        };
        clutter = [
          "*.log"
          "*.cue"
          "*.jpg"
          "*.png"
          "*.pdf"
          "*.txt"
          "Scans"
          "scans"
          "Artwork"
        ];
        plugins = [ "unimported" ];
        unimported = {
          ignore_subdirectories = [ "UNIMPORTED" ];
          ignore_extensions = [ "db" ];
        };
      };
    };
  };
  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    digikam
    doublecmd
    rustmission
    transmission-remote-gtk
  ];
}
