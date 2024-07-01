{ config, pkgs, modulesPath, ... }:

let firmware = pkgs.callPackage ./firmware.nix { };
in {
  imports = [
    "${modulesPath}/profiles/base.nix"
    "${modulesPath}/installer/sd-card/sd-image.nix"
    ./default.nix
  ];

  sdImage = {
    imageName =
      "${config.sdImage.imageBaseName}-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}-bananapi-bpif3.img";

    # Overridden by postBuildCommands
    populateFirmwareCommands = "";

    # This is basically a hack to move the rootfs partition to a +16MiB offset,
    # giving us some room to stash firmware.
    firmwarePartitionOffset = 4;
    firmwareSize = 4;

    postBuildCommands = ''
      # preserve root partition
      eval $(partx $img -o START,SECTORS --nr 2 --pairs)

      # increase image size for gpt backup header
      truncate -s '+2M' $img

      set -x

      # destroy everything except the root partition.
      dd conv=notrunc if=/dev/zero of=$img bs=4096 count=2048

      sfdisk $img <<EOF
          label: gpt
          unit: sectors
          sector-size: 512
          grain: 512
          first-lba: 256

          start=256,    size=512,      type=5B193300-FC78-40CD-8002-E86C45580B47, name=fsbl
          start=1024,   size=2048,     type=2E54B353-1271-4842-806F-E436D6AF6985, name=opensbi
          start=4096,   size=4096,     type=2E54B353-1271-4842-806F-E436D6AF6985, name=uboot
          start=$START, size=$SECTORS, type=0FC63DAF-8483-4772-8E79-3D69D8477DE4, name=bootfs, attrs="LegacyBIOSBootable"
      EOF

      dd conv=notrunc if=${firmware.uboot}/bootinfo_sd.bin of=$img seek=0 count=80

      eval $(partx $img -o START,SECTORS --nr 1 --pairs)
      dd conv=notrunc if=${firmware.uboot}/FSBL.bin of=$img seek=$START count=$SECTORS

      eval $(partx $img -o START,SECTORS --nr 2 --pairs)
      dd conv=notrunc if=${firmware.opensbi}/share/opensbi/lp64/generic/firmware/fw_dynamic.itb of=$img seek=$START count=$SECTORS

      eval $(partx $img -o START,SECTORS --nr 3 --pairs)
      dd conv=notrunc if=${firmware.uboot}/u-boot.itb of=$img seek=$START count=$SECTORS

    '';

    populateRootCommands = ''
      mkdir -p ./files/boot
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
    '';
  };
}
