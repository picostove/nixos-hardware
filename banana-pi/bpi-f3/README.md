# BananaPi BPI-F3

## Building an SD image

```sh
nix build 'github:picostove/nixos-hardware?ref=add-bananapi-bpi-f3&dir=banana-pi/bpi-f3#sd-image'
```

## What works

1. Booting to a serial prompt
2. Ethernet networking

## Untested

1. HDMI
2. SPI flash
3. Bluetooth (needs firmware blob)
4. USB peripherals

## Known issues

1.  `clk_ignore_unused` must be passed on the kernel command line, otherwise
    boot will hang forever once unused clocks are disabled.
2.  Both `CONFIG_PWM_PXA` and `CONFIG_SND_SOC_SPACEMIT` are disabled since they
    may cause hangs during boot. This means PWM fan control and backlight
    control won't work.
3.  The RTL8852BS WiFi driver is disabled since it complains about not having
    the right configs for big/little endian set.
