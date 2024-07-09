# /etc/nixos/configuration.nix
{ config, pkgs, ... }:

{
  # Basic system settings
  imports = [ ./hardware-configuration.nix ];

  # Bootloader configuration
  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/nvme0n1"; # NVMe device
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking.hostName = "gamepc"; # Hostname

  time.timeZone = "Europe/Amsterdam"; # Timezone

  # Enable services
  services.xserver.enable = true;
  services.xserver.layout = "us"; # Keyboard layout
  services.xserver.libinput.enable = true;
  services.gnome3.gnomeOnScreenKeyboard = {
    enable = true;
    layout = "us"; # On-screen keyboard layout
  };
  services.xserver.displayManager.gdm = {
    enable = true; # GDM for GNOME
    autoLogin = {
      enable = true;
      user = "gamepc"; # Username for auto-login
    };
  };
  services.xserver.desktopManager.gnome.enable = true; # GNOME desktop

  # Enable networking
  networking.networkmanager.enable = true;

  # Install basic packages
  environment.systemPackages = with pkgs; [
    wget
    vim
    git
    firefox
    steam
    steamPackages.proton
    xboxdrv
  ];

  # NVIDIA drivers
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.modesetting.enable = true;
  hardware.opengl.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.package = pkgs.bluez;
  services.blueman.enable = true;

  # Enable GNOME Shell Extensions
  nixpkgs.config.allowUnfree = true;
  services.gnome.gnomeExtensions = {
    dash-to-dock = {
      enable = true;
      package = pkgs.gnomeExtensions.dash-to-dock;
    };
  };

  # Enable Steam
  programs.steam.enable = true;

  # User settings
  users.users.gamepc = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "bluetooth" ];
    hashedPassword = ""; # No password
  };

  # Enable sudo for wheel users
  security.sudo.wheelNeedsPassword = false;

  # Start Steam on GNOME startup
  environment.etc."xdg/autostart/steam.desktop".source = pkgs.writeText "steam-autostart" ''
    [Desktop Entry]
    Type=Application
    Exec=steam -tenfoot
    Hidden=false
    NoDisplay=false
    X-GNOME-Autostart-enabled=true
    Name[en_US]=Steam
    Name=Steam
    Comment[en_US]=Start Steam cli[Oent
    Comment=Start Steam client
  '';
}

