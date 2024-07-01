{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, nixos-hardware, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      rec {
        packages.default = packages.sd-image;
        packages.sd-image = (import "${nixpkgs}/nixos" {
          configuration =
            { config, ... }: {
              imports = [
                ./sd-image-installer.nix
              ];

              # If you want to use ssh set a password
              # users.users.nixos.password = "super secure password";
              # OR add your public ssh key
              # users.users.nixos.openssh.authorizedKeys.keys = [ "ssh-rsa ..." ];

              # AND configure networking
              # networking.interfaces.end0.useDHCP = true;
              # networking.interfaces.end1.useDHCP = true;

              # Additional configuration goes here

              sdImage.compressImage = false;

              nixpkgs.crossSystem = {
                config = "riscv64-unknown-linux-gnu";
                system = "riscv64-linux";
              };

              system.stateVersion = "24.11";
            };
          inherit system;
        }).config.system.build.sdImage;
      });
}
