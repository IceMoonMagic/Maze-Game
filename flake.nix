{
  description = "A simple maze game made in Godot.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs, ... }:
    let
      gameName = "maze-game";
      gameVersion = "0.2.0";
      godotPackages = pkgs: pkgs.godotPackages_4_4;
      exportPresets = [
        (mkExportPreset "Linux" "")
        (mkExportPreset "Linux 2D" "")
        (mkExportPreset "Web" ".html")
        (mkExportPreset "Web 2D" ".html")
        (mkExportPreset "Windows Desktop" ".exe")
        (mkExportPreset "Windows Desktop 2D" ".exe")
      ];

      renameToIndexHTML = true;
      builderDir = ".builder";
      supportedSystems = [ "x86_64-linux" ];

      forEachSystem = nixpkgs.lib.genAttrs supportedSystems;
      getPkgs = system: nixpkgs.legacyPackages.${system};
      mkExportPreset = name: ext: {
        presetName = name;
        outputExtension = ext;
      };

      allPacks = builtins.map (
        preset:
        preset
        // {
          exportMode = "pack";
          outputExtension = ".pck";
        }
      ) exportPresets;
      allDebugs = builtins.map (preset: preset // { exportMode = "debug"; }) exportPresets;
      allReleases = builtins.map (preset: preset // { exportMode = "release"; }) exportPresets;

      mkExports =
        presets: pkgs:
        builtins.map (p: {
          name = "${gameName}-${p.presetName}-${p.exportMode}";
          value = mkDerivation p pkgs;
        }) presets;

      mkDerivation =
        preset: pkgs:
        pkgs.stdenv.mkDerivation (
          let
            inherit (preset) presetName outputExtension exportMode;
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
              mkdir -p ${builderDir}/dist
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
              "./${builderDir}/godot" --headless --export-${exportMode} "${presetName}" "${builderDir}/dist/${gameName}${outputExtension}"
              runHook postBuild
            '';

            installPhase =
              let
                # needed because "cannot coerce a Boolean to a string"
                mvToIndex = if renameToIndexHTML then "true" else "false";
              in
              ''
                runHook preInstall
                cp "${builderDir}/dist/" -r -T "$out/"
                if [ -e "$out/${gameName}.html" -a $(${mvToIndex}) ]; then
                  mv "$out/${gameName}.html" "$out/index.html"
                fi
                runHook postInstall
              '';
          }
        );
      mkAggregation =
        name: mkExport: pkgs:
        let
          exports = mkExport pkgs;
        in
        pkgs.stdenv.mkDerivation {
          pname = "${gameName}-name";
          version = gameVersion;
          src = pkgs.emptyDirectory;
          buildInputs = builtins.map (e: e.value) exports;
          installPhase = builtins.concatStringsSep "\n" (
            [ "mkdir -p $out" ] ++ (builtins.map (e: "ln -s \"${e.value}\" -T \"$out/${e.name}\"") exports)
          );
        };
    in
    {
      formatter = forEachSystem (system: (getPkgs system).nixfmt-tree);
      devShells = forEachSystem (system: {
        default = (getPkgs system).mkShell {
          buildInputs = [ (godotPackages (getPkgs system)).godot ];
        };
      });
      packages = forEachSystem (
        system:
        let
          pkgs = getPkgs system;
        in
        {
          "${gameName}-pack" = mkAggregation "pack" (mkExports allPacks) pkgs;
          "${gameName}-debug" = mkAggregation "debug" (mkExports allDebugs) pkgs;
          "${gameName}-release" = mkAggregation "release" (mkExports allReleases) pkgs;
          default = self.packages.${system}."${gameName}-release";
        }
        // builtins.listToAttrs (mkExports (allPacks ++ allDebugs ++ allReleases) (getPkgs system))
      );
    };
}
