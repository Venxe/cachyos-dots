function wall -d "Toggle linux-wallpaperengine on/off"
    if pgrep -x linux-wallpaper > /dev/null 2>&1
        killall linux-wallpaperengine > /dev/null 2>&1
        echo "Wallpaper Engine stopped."
    else
        set config_file "$HOME/.config/Linux Wallpaper Engine/active-wallpapers.json"

        if not test -f "$config_file"
            echo "Wallpaper Engine config not found."
            return 1
        end

        set screens (jq -r '.activeWallpapers | keys[]' "$config_file" 2>/dev/null)

        if test -z "$screens"
            echo "No active wallpaper found."
            return 1
        end

        set cmd_args

        for screen in $screens
            set bg_id (jq -r ".activeWallpapers[\"$screen\"].backgroundId" "$config_file")
            set scaling (jq -r ".activeWallpapers[\"$screen\"].scaling // \"fill\"" "$config_file")
            set fps (jq -r ".activeWallpapers[\"$screen\"].fps // 60" "$config_file")
            set silent (jq -r ".activeWallpapers[\"$screen\"].silent // true" "$config_file")
            set no_audio (jq -r ".activeWallpapers[\"$screen\"].noAudioProcessing // false" "$config_file")
            set disable_mouse (jq -r ".activeWallpapers[\"$screen\"].disableMouse // false" "$config_file")
            set disable_parallax (jq -r ".activeWallpapers[\"$screen\"].disableParallax // true" "$config_file")
            set disable_particles (jq -r ".activeWallpapers[\"$screen\"].disableParticles // false" "$config_file")

            set cmd_args $cmd_args --screen-root $screen --bg $bg_id --scaling $scaling --fps $fps

            test "$silent" = "true"; and set cmd_args $cmd_args --silent
            test "$no_audio" = "true"; and set cmd_args $cmd_args --no-audio-processing
            test "$disable_mouse" = "true"; and set cmd_args $cmd_args --disable-mouse
            test "$disable_parallax" = "true"; and set cmd_args $cmd_args --disable-parallax
            test "$disable_particles" = "true"; and set cmd_args $cmd_args --disable-particles
        end

        set first_bg (jq -r '.activeWallpapers[.activeWallpapers | keys[0]].backgroundId' "$config_file")
        set steam_root (echo $first_bg | sed 's|/steamapps/workshop/.*||')
        set assets_dir "$steam_root/steamapps/common/wallpaper_engine/assets"

        if test -d "$assets_dir"
            set cmd_args $cmd_args --assets-dir $assets_dir
        end

        systemd-run --user --quiet linux-wallpaperengine $cmd_args
        echo "Wallpaper Engine started."
    end
end
