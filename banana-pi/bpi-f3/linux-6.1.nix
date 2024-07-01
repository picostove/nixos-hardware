{ lib, callPackage, linuxPackagesFor, kernelPatches, fetchgit, fetchpatch, ... }:

let
  modDirVersion = "6.1.15";
  linuxPkg = { lib, fetchFromGitHub, buildLinux, ... }@args:
    buildLinux (args // {
      version = "${modDirVersion}-bananapi-bpif3";

      src = fetchgit {
        url = "https://gitee.com/bianbu-linux/linux-6.1.git";
        rev = "d6bae33cbc2532eff4f856399e2d3d37ecb10e51";
        hash = "sha256-W660mnl5RGcsGpCokRMJ1toB8LMH0kd3luipk65hO7w=";
      };

      kernelPatches = [
        {
          # riscv: signal: fix sigaltstack frame size checking
          patch = fetchpatch {
             url = "https://github.com/BPI-SINOVOIP/pi-linux/pull/4/commits/27a8b1ac27dc8db47f648f58c6b15964f9a93229.diff";
             hash = "sha256-Lp/oVSLjJvFjveQP1YfwzawFxqYHf9kQ7z4MjvEeUzs=";
           };
         }
         {
           # Remove git info in the kernel version. Nix builds will complain
           # about not being able to run git during the build otherwise.
           patch = ./linux-remove-gitver.patch;
         }
      ] ++ kernelPatches;

      inherit modDirVersion;
      defconfig = "k1_defconfig";

      autoModules = false;

      structuredExtraConfig = with lib.kernel; {
        IMAGE_LOAD_OFFSET = lib.mkForce (freeform "0x1400000");
        # This conflicts with the pxa_k1x driver.
        SERIAL_8250 = lib.mkForce no;

        # HACK: debug boot hang
        PWM_PXA = lib.mkForce no;

        # boot hangs while probing
        SND_SOC_SPACEMIT = lib.mkForce no;

        # required for initramfs
        RD_ZSTD = lib.mkForce yes;

        # these don't build - neither LITTLE_ENDIAN nor BIG_ENDIAN is getting set?
        RTL8852BE = no;
        RTL8852BS = no;
        # unnecessary for this board.
        DRM_KOMEDA = no;
        DRM_RADEON = no;
        DRM_AMDGPU = no;
        DRM_AMDGPU_SI = lib.mkForce no;
        DRM_AMDGPU_CIK = lib.mkForce no;
        DRM_AMDGPU_USERPTR = lib.mkForce no;
        DRM_AMD_DC = no;
        DRM_AMD_DC_HDCP = lib.mkForce no;
        DRM_AMD_DC_SI = lib.mkForce no;
        DRM_NOUVEAU = no;
        NOUVEAU_LEGACY_CTX_SUPPORT = no;
        DRM_NOUVEAU_BACKLIGHT = no;
        # fails to build for some reason.
        OCTEON_ETHERNET = no;
        # k1pro isn't in this tree.
        MMC_SDHCI_OF_K1PRO = no;
        SOC_SPACEMIT_K1PRO = no;
        K1PRO_MAILBOX = no;
        RESET_K1PRO_SPACEMIT = no;
        SPACEMIT_K1PRO_CCU = no;
        K1PRO_REMOTEPROC = no;
        PINCTRL_K1PRO = no;

        # ERROR: modpost: "dw_spi_ext_remove_host" [drivers/spi/spi-dw-mmio-ext.ko] undefined!
        # ERROR: modpost: "dw_spi_ext_add_host" [drivers/spi/spi-dw-mmio-ext.ko] undefined!
        SPI_DESIGNWARE_EXT = yes;

        MMC_SDHCI_PCI = yes;

        VSOCKETS = module;
        VIRTIO_VSOCKETS = module;
        VIRTIO_MENU = yes;
        VIRTIO_BALLOON = module;
        VIRTIO_BLK = module;
        VIRTIO_CONSOLE = module;
        VIRTIO_MMIO = module;
        VIRTIO_PCI = module;
        SCSI_VIRTIO = module;
      };

      extraMeta.branch = "bl-v1.0.y";
    } // (args.argsOverride or { }));

in lib.recurseIntoAttrs (linuxPackagesFor (callPackage linuxPkg { }))
