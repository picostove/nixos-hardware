{
  config,
  lib,
  pkgs,
  ...
}: {
  boot = {
    # Explicitly disable ZFS on vendor-supplied kernels.
    supportedFilesystems =
      lib.mkForce ["btrfs" "vfat" "f2fs" "xfs" "ntfs" "cifs"];
    consoleLogLevel = lib.mkDefault 7;
    kernelPackages = lib.mkDefault (pkgs.callPackage ./linux-6.1.nix {
      inherit (config.boot) kernelPatches;
    });

    kernelParams = lib.mkForce [
      "console=ttyS0,115200n8"
      "earlycon=sbi"
      "clk_ignore_unused" # will hang without this :\
    ];

    # Slim down the initrd. The default modules include a lot of x86 cruft.
    initrd.includeDefaultModules = false;
    initrd.availableKernelModules = lib.mkForce [];

    # Use extlinux in u-boot instead of the vendor boot flow.
    loader = {
      grub.enable = lib.mkDefault false;
      generic-extlinux-compatible.enable = lib.mkDefault true;
    };
  };
}
