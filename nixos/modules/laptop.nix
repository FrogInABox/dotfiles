{ options, config, lib, pkgs, ... }:

with lib;
let cfg = config.modules.laptop;
in {
  options.modules.laptop = {
    enable = mkEnableOption "laptop module";
    swapAltWin = mkEnableOption "swapping LAlt & LWin keys";
    networkmanager.enable = mkEnableOption "networkmanager";
    autorandr.enable = mkEnableOption "autorandr";
    hibernate.enable = mkEnableOption "hibernate";
  };

  config = mkIf cfg.enable {
    # use network-manager for handling wifi and ethernet
    networking.networkmanager.enable = cfg.networkmanager.enable;

    services.xserver = {
      libinput.enable = true; # enable touchpad
      xkbOptions = mkIf cfg.swapAltWin "altwin:swap_lalt_lwin";
    };

    # autorandr for auto switching display config
    services.autorandr = mkIf cfg.autorandr.enable {
      enable = true;
      defaultTarget = "horizontal";
    };

    services.logind.lidSwitch =
      mkIf cfg.hibernate.enable "suspend-then-hibernate";
    systemd.sleep.extraConfig =
      mkIf cfg.hibernate.enable "HibernateDelaySec=1200";

    environment.systemPackages = with pkgs;
      [
        brightnessctl # for changing brightness
      ];
  };
}
