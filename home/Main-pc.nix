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
          move = "yes";
          incremental = "yes";
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
}
