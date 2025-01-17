{
  description = "Building my rust project";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, flake-utils, nixpkgs, rust-overlay, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # pkgs = import nixpkgs {
          # system = "x86_64-linux";
          # overlays = [ (import rust-overlay) ];
        # };
        overlays = [(import rust-overlay)];
        pkgs = import nixpkgs {
          inherit overlays system;
        };
        nativeBuildInputs = with pkgs; [
          pkg-config
          gcc
          rust-bin.stable.latest.default
        ];
        buildInputs = with pkgs; [
          # openssl
          # xorg.libX11
          # alsa-lib
          # udev
          # libxkbcommon
          # wayland
          # vulkan-loader
          # vulkan-headers
          # vulkan-tools
          # xorg.libXcursor
          # xorg.libXi
          # xorg.libXrandr
          # mesa
          # xorg.libXinerama
          # xorg.libXext
          # xorg.libXfixes
          # xorg.libXtst
        ];
        projectName = "rofdo-rust-template";
        libraryPath = pkgs.lib.makeLibraryPath buildInputs;
      in
      {
        devShells.default = pkgs.mkShell {
          LD_LIBRARY_PATH = "${libraryPath}:$LD_LIBRARY_PATH";
          inherit buildInputs nativeBuildInputs;
        };
        packages.default = pkgs.rustPlatform.buildRustPackage {
          pname = projectName;
          version = "0.1.0";
          cargoLock.lockFile = ./Cargo.lock;
          src = ./.;
          inherit buildInputs nativeBuildInputs;
          
          postFixup = ''
            patchelf --set-rpath "${libraryPath}" $out/bin/"${projectName}"
          '';
        };
        packages.server = pkgs.rustPlatform.buildRustPackage {
          pname = "server";
          version = "0.1.0";
          cargoLock.lockFile = ./Cargo.lock;
          src = ./.;
          inherit buildInputs nativeBuildInputs;
          
          postFixup = ''
            patchelf --set-rpath "${libraryPath}" $out/bin/server
          '';
        };
        apps.default = {
          type = "app";
          program = "${self.packages.x86_64-linux.default}/bin/${projectName}";
        };
        apps.server = {
          type = "app";
          program = "${self.packages.x86_64-linux.default}/bin/server";
        };
      }
    );
}
