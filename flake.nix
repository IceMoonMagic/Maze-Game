{
  description = "A simple maze game made in Godot.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs, ... }:
    let
      gameName = "maze-game";
      gameVersion = "0.2.0";
      godotPackages = pkgs: pkgs.godotPackages_4_4;
      builderDir = ".builder";
      supportedSystems = [ "x86_64-linux" ];
      forEachSystem = nixpkgs.lib.genAttrs supportedSystems;
      getPkgs = system: nixpkgs.legacyPackages.${system};
    in
    {
      formatter = forEachSystem (system: (getPkgs system).nixfmt-tree);
      devShells = forEachSystem (system: {
        default = (getPkgs system).mkShell {
          buildInputs = [ (godotPackages (getPkgs system)).godot ];
        };
      });
      packages = {
        x86_64-linux.default = self.packages.x86_64-linux.${gameName};
        x86_64-linux.${gameName} =
          let
            pkgs = getPkgs "x86_64-linux";
            godot = (godotPackages pkgs).godot;
            export-templates-bin = (godotPackages pkgs).export-templates-bin;
            outputExtention = ".x86_64";
          in
          pkgs.stdenv.mkDerivation (
            (self.builder {
              presetName = "Linux";
              inherit outputExtention;
              exportMode = "release";
            } pkgs)
            // {
              buildInputs = with pkgs; [
                bash
                steam-run-free
              ];
              installPhase = ''
                # The export templates still assume some dynamic linking, so need to make a wrapper with steam-run
                # the shell wrappers don't seem to support this use case (passing the executable through another program)
                # May also try just adding all dependancies. Best lead is for compiling the engine itself.
                # https://docs.godotengine.org/en/latest/engine_details/development/compiling/compiling_for_linuxbsd.html
                install -Dm755 "${gameName}${outputExtention}" "$out/libexec/${gameName}${outputExtention}"
                mkdir $out/bin
                echo \#!${pkgs.bash}/bin/bash >> "$out/bin/${gameName}"
                echo ${pkgs.steam-run-free}/bin/steam-run "$out/libexec/${gameName}${outputExtention}" >> "$out/bin/${gameName}"
                chmod +rx "$out/bin/${gameName}"
              '';
            }
          );
      };
      builder =
        {
          presetName,
          outputExtention,
          exportMode,
        }:
        pkgs:
        let
          godot = (godotPackages pkgs).godot;
          export-templates-bin = (godotPackages pkgs).export-templates-bin;
        in
        {
          pname = gameName;
          version = gameVersion;
          src = ./.;
          nativeBuildInputs = [
            godot
            export-templates-bin
          ];

          # Kind of a hack becuase Godot doesn't have a way to configure an export template directory
          # See https://github.com/godotengine/godot-proposals/issues/2565
          configurePhase = ''
            runHook preConfigure

            mkdir -p "${builderDir}/editor_data"
            # Enable Godot's Self Contained Mode
            touch "${builderDir}/_sc_"
            # Self Contained won't work if the binary is just symlinked, so it needs to be copied
            install -Dm755 ${godot}/libexec/godot.linuxbsd.editor.x86_64 -T ${builderDir}/godot
            # Can and will link templates because they're almost 2 GiBs
            # To my knowledge, symlinking like this should be fine.
            ln -s "${export-templates-bin}/share/godot/export_templates" "${builderDir}/editor_data/"

            runHook postConfigure
          '';

          buildPhase = ''
            runHook preBuild
            "./${builderDir}/godot" --headless --export-${exportMode} "${presetName}" "${gameName}${outputExtention}"
            runHook postBuild
          '';
        };
    };
}
