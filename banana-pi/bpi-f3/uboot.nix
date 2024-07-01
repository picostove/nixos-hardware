{ buildUBoot
, opensbi
, fetchFromGitHub
, fetchpatch
, lib
}:

(buildUBoot {
  version = "2022.10-k1x";

  src = fetchFromGitHub {
    owner = "picostove";
    repo = "u-boot";
    rev = "bpi-f3";
    hash = "sha256-fqj+etdVgo+BjKAOo8T2r1EAZHeDmAylA2+E3sgGGs0=";
  };

  extraMakeFlags = [
    "OPENSBI=${opensbi}/share/opensbi/lp64/generic/firmware/fw_dynamic.bin"
  ];

  defconfig = "k1_defconfig";

  filesToInstall = [
    "FSBL.bin"
    "bootinfo_emmc.bin"
    "bootinfo_sd.bin"
    "bootinfo_spinand.bin"
    "bootinfo_spinor.bin"
    "u-boot.itb"
  ];
}).overrideAttrs (oldAttrs: {
  # The default uboot patches don't apply to this tree.
  patches = [
  ];
})
