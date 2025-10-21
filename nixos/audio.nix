# PipeWire audio configuration
# Modern audio server with PulseAudio and JACK compatibility

_:

{
  # Enable RealtimeKit for low-latency audio
  security.rtkit.enable = true;

  # PipeWire configuration
  services.pipewire = {
    enable = true;

    # Use PipeWire as the primary sound server (modern method)
    audio.enable = true;

    # ALSA support
    alsa = {
      enable = true;
      support32Bit = true; # Required for 32-bit applications
    };

    # PulseAudio compatibility layer
    pulse.enable = true;

    # JACK compatibility (for professional audio interfaces like Focusrite Scarlett)
    jack.enable = true;
  };

  # Disable PulseAudio in favor of PipeWire
  services.pulseaudio.enable = false;
}

