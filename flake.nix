{
  description = "A simple maze game made in Godot.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      supportedSystems = [ "x86_64-linux" ];
      forEachSystem = nixpkgs.lib.genAttrs supportedSystems;
      pkgs = system: nixpkgs.legacyPackages.${system};
      godotPackages = pkgs: pkgs.godotPackages_4_4;
    in
    {
      formatter = forEachSystem (system: (pkgs system).nixfmt-tree);
      devShells = forEachSystem (system: {
        default = (pkgs system).mkShell {
          buildInputs = with (pkgs system); [
            godot_4_4
          ];
        };
      });
      packages = forEachSystem (system: rec {
        default = maze-game;
        godotExport = (pkgs system).stdenv.mkDerivation {
          pname = "${(godotPackages (pkgs system)).godot.pname}-sc";
          version = (godotPackages (pkgs system)).godot.version;
          src = (godotPackages (pkgs system)).godot;
          buildInputs = with (godotPackages (pkgs system)); [
            export-templates-bin
          ];
          installPhase = ''
            cp -r --no-preserve=mode,ownership "$src" "$out"
            chmod +rx "$out/libexec/godot.linuxbsd.editor.x86_64"
            mkdir -p "$out/libexec/editor_data"
            ln -s "${(godotPackages (pkgs system)).export-templates-bin}/share/godot/export_templates" "$out/libexec/editor_data/"
            touch "$out/libexec/_sc_"
          '';
        };
        maze-game = (pkgs system).stdenv.mkDerivation rec {
          pname = "maze-game";
          version = "0.2.0";
          src = ./.;
          nativeBuildInputs = [ godotExport ];
          buildInputs = [
            (pkgs system).steam-run-free
            (pkgs system).bash
          ];
          buildPhase = ''
            cp ${godotExport} builder/ --recursive
            chmod +rwx builder -R
            builder/bin/godot --headless --export-release Linux maze-game
          '';
          installPhase = ''
            install -Dm755 maze-game $out/libexec/maze-game
            mkdir $out/bin
            echo \#!${(pkgs system).bash}/bin/bash >> $out/bin/maze-game
            echo ${(pkgs system).steam-run-free}/bin/steam-run $out/libexec/maze-game >> $out/bin/maze-game
            chmod +rx $out/bin/maze-game
          '';
        };
      });
    };
}
