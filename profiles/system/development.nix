# Development profile - System-level development tools and services
# Includes Docker, databases, and additional development utilities

{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.system.development;
in
{
  options.profiles.system.development = {
    enable = lib.mkEnableOption "development profile with Docker, databases, and dev tools";
  };

  config = lib.mkIf cfg.enable {
    # ============================================================================
    # DEVELOPMENT PACKAGES
    # ============================================================================
    environment.systemPackages = with pkgs; [
      # Container tools
      docker-compose
      lazydocker # Terminal UI for Docker
      dive # Explore Docker image layers

      # Database clients
      postgresql # PostgreSQL client
      redis # Redis client
      sqlite # SQLite client

      # API testing
      postman
      insomnia

      # Network tools
      wireshark
      tcpdump
      nmap

      # System monitoring
      sysstat
      iotop
      nethogs

      # Build tools
      gnumake
      cmake
      pkg-config

      # Version control
      git-lfs # Git Large File Storage
      gh # GitHub CLI

      # Documentation
      man-pages
      man-pages-posix
    ];

    # ============================================================================
    # DOCKER CONFIGURATION
    # ============================================================================
    virtualisation.docker = {
      enable = true;

      # Start Docker on-demand instead of at boot
      # Use: sudo systemctl start docker
      # Or add alias: alias docker-start='sudo systemctl start docker'
      enableOnBoot = false;

      # Use NVIDIA runtime for GPU access in containers
      enableNvidia = config.hardware.nvidia.modesetting.enable or false;

      # Auto-prune to save disk space
      autoPrune = {
        enable = true;
        dates = "weekly";
      };

      # Docker daemon configuration
      daemon.settings = {
        # Use systemd cgroup driver
        exec-opts = [ "native.cgroupdriver=systemd" ];

        # Enable experimental features
        experimental = true;

        # Set default logging driver
        log-driver = "json-file";
        log-opts = {
          max-size = "10m";
          max-file = "3";
        };
      };
    };

    # Add user to docker group (configured per-user in users.nix)
    # users.users.<username>.extraGroups = [ "docker" ];

    # ============================================================================
    # PODMAN CONFIGURATION (Alternative to Docker)
    # ============================================================================
    # Uncomment to use Podman instead of/alongside Docker
    # virtualisation.podman = {
    #   enable = true;
    #   dockerCompat = true; # Create docker alias for podman
    #   defaultNetwork.settings.dns_enabled = true;
    # };

    # ============================================================================
    # DATABASE SERVICES (Optional - enable as needed)
    # ============================================================================
    # PostgreSQL
    # services.postgresql = {
    #   enable = true;
    #   package = pkgs.postgresql_16;
    #   enableTCPIP = true;
    #   authentication = pkgs.lib.mkOverride 10 ''
    #     local all all trust
    #     host all all 127.0.0.1/32 trust
    #     host all all ::1/128 trust
    #   '';
    # };

    # Redis
    # services.redis.servers."" = {
    #   enable = true;
    #   port = 6379;
    # };

    # MySQL/MariaDB
    # services.mysql = {
    #   enable = true;
    #   package = pkgs.mariadb;
    # };

    # ============================================================================
    # DEVELOPMENT SERVICES
    # ============================================================================
    # Note: D-Bus is enabled globally in nixos/desktop.nix

    # ============================================================================
    # KERNEL PARAMETERS FOR DEVELOPMENT
    # ============================================================================
    boot.kernel.sysctl = {
      # Increase file watchers for development tools (IDEs, file watchers)
      # Default is 8192, which is often insufficient for large projects
      # 524288 = 512K watches, enough for most development scenarios
      "fs.inotify.max_user_watches" = 524288;

      # Maximum number of inotify instances per user
      # Default is 128, increased for multiple IDEs/tools running simultaneously
      "fs.inotify.max_user_instances" = 512;

      # Maximum number of file descriptors system-wide
      # Default is ~1M, increased for development servers and database connections
      "fs.file-max" = 2097152;
    };

    # ============================================================================
    # NETWORKING FOR DEVELOPMENT
    # ============================================================================
    networking.firewall = {
      # Allow common development ports
      allowedTCPPorts = [
        3000 # Node.js/React default
        4200 # Angular default
        5000 # Flask default
        8000 # Django/Python HTTP server
        8080 # Alternative HTTP
        9000 # PHP-FPM
      ];
    };

    # ============================================================================
    # DOCUMENTATION
    # ============================================================================
    # Enable man pages
    documentation = {
      enable = true;
      man.enable = true;
      dev.enable = true; # Development documentation
    };
  };
}

