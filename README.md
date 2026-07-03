[![sayimburak's Dotfiles](https://raw.githubusercontent.com/Venxe/Dotfiles/refs/heads/main/banner.jpg)

This repository contains a quick-install setup of my custom configuration and the packages I use, built on top of the [caelestia-dots](https://github.com/caelestia-dots/caelestia) project.

The installation process is fully automated and specifically tailored to my personal workflow.

🐧 **Operating System:** CachyOS

🖼️ **Window Manager:** Hyprland

🖥️ **Display Manager:** SDDM

> [!WARNING]
> Running this setup may install software and configurations that could conflict with your preferences. You may want to review the [packages](https://github.com/Venxe/Dotfiles/tree/main/installers) before proceeding.


## ⚙️ Installation

Run the following command in the terminal to download and install the dotfiles:
```bash
git clone --depth 1 https://github.com/Venxe/cachyos-dots.git ~/cachyos-dots && cd ~/cachyos-dots && chmod +x installer/install.sh && ./installer/install.sh
```

### Recomandations:

- [**Wallpapers**](https://github.com/sayimburak/wallpapers) – A curated collection of high-resolution wallpapers


## ⚡ Notes
<details>
<summary>After installation, you may need to adjust the configuration for your specific monitor(s).</summary>

You can view your connected monitors and their properties by running the `hyprctl monitors` command in the terminal.
</details>

<details>
<summary>After signing in to Spotify, you must configure a few settings for applying Spicetify.</summary>

```
spicetify config current_theme marketplace
spicetify config custom_apps marketplace
spicetify backup apply
```

My Marketplace Items:
- **Extensions:** Full Screen, Scanabbles
- **Snippets:** Hover Panels, Rounded Images, Auto-hide Friends, Pretty Lyrics, Smooth Progress/Volume Bar, Modern ScrollBar, Remove the Artist and Credits sections from the Sidebar
</details>
