{ config, ... }:
{
  services.mpd = {
    enable = true;
    musicDirectory = config.xdg.userDirs.music;
    network.startWhenNeeded = true;
    extraConfig = ''
      auto_update "yes"
      restore_paused "yes"
      follow_outside_symlinks "yes"
      follow_inside_symlinks "yes"

      audio_output {
        type "pulse"
        name "PulseAudio / PipeWire"
      }
    '';
  };
}
