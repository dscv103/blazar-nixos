# Communication profile - User-level communication applications
# Includes Discord, Slack, Telegram, email clients

{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.user.communication;
in
{
  options.profiles.user.communication = {
    enable = lib.mkEnableOption "communication profile with Discord, Slack, Telegram, etc.";
  };

  config = lib.mkIf cfg.enable {
    # ========================================================================
    # COMMUNICATION PACKAGES
    # ========================================================================
    
    home.packages = with pkgs; [
      # Chat and messaging
      discord # Voice, video, and text chat
      slack # Team communication
      telegram-desktop # Telegram messenger
      signal-desktop # Privacy-focused messenger
      element-desktop # Matrix client
      
      # Video conferencing
      zoom-us # Video conferencing
      # teams-for-linux # Microsoft Teams (unofficial)
      
      # Email clients
      thunderbird # Email, calendar, and contacts
      # mailspring # Modern email client
      
      # IRC clients
      # hexchat # IRC client
      # weechat # Terminal IRC client
      
      # VoIP
      # mumble # Low-latency voice chat
      
      # Social media
      # caprine # Facebook Messenger desktop app
      # whatsapp-for-linux # WhatsApp desktop (unofficial)
    ];

    # ========================================================================
    # PROGRAM CONFIGURATIONS
    # ========================================================================
    
    # Thunderbird configuration
    programs.thunderbird = {
      enable = true;
      
      # Profiles can be configured here
      # profiles = {
      #   default = {
      #     isDefault = true;
      #   };
      # };
    };

    # Discord configuration (Wayland support)
    # xdg.configFile."discord/settings.json".text = builtins.toJSON {
    #   SKIP_HOST_UPDATE = true;
    #   DANGEROUS_ENABLE_DEVTOOLS_ONLY_ENABLE_IF_YOU_KNOW_WHAT_YOURE_DOING = true;
    # };
  };
}

