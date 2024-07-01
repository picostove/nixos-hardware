{ opensbi, fetchgit, ubootTools, dtc }:

opensbi.overrideAttrs (attrs: {
  src = fetchgit {
    url = "https://gitee.com/bianbu-linux/opensbi.git";
    rev = "6f1344573d4ce0638d24d960e9a7d5ff1b0426b6";
    hash = "sha256-Zk8utf0DFxWJ4rhD+8SAxyVWdTXgkRnZp7BURXtyTZQ=";
  };
  patches = [
    ./opensbi-install-itb.patch
    ./opensbi-enable-logging.patch
  ];
  nativeBuildInputs = (attrs.nativeBuildInputs or [] ) ++ [
    dtc
    ubootTools
  ];
  makeFlags = attrs.makeFlags ++ [
    "PLATFORM_DEFCONFIG=k1_defconfig"
  ];
})
