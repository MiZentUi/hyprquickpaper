# HyprQuickPaper

Wallpaper selector made using quickshell. Inspired by [ilyamiro's dots](https://github.com/ilyamiro/nixos-configuration)
PRs and contributions are appreciated.

> [!IMPORTANT]
> Make sure to read the entire config and usage sections before using.

## Demo

https://github.com/user-attachments/assets/375e3696-e62d-48bf-8af6-18d2be86b224

## Key features

- Wallpaper selection with thumbnails
- Saves the position of the currently selected wallpaper
- Customizable colors using generation tools like Matugen

## Dependencies

- [quickshell](https://git.outfoxxed.me/quickshell/quickshell)
- jq
- file
- ImageMagick (magick, with convert fallback)

## Installation

### Arch

Install dependencies

```bash
sudo pacman -S quickshell jq file imagemagick
```

Now just clone this repo into Quickshell's config folder

```bash
git clone https://github.com/iamsurjog/hyprquickpaper ~/.config/quickshell/hyprquickpaper
```

## Config

Go to the `config.json` file and change the `"wallpaper_path"` and the `"cache_path"` variables

Example `config.json`

```json
{
    "wallpaper_path": "$HOME/dotfiles/images/wallpapers/",
    "cache_path": "$HOME/.cache/quickshell/hyprquickpaper/",
    "number_of_pictures": 6,
    "cache_batch_size": 20,
    "height": 500,
    "x_factor": -0.25
}
```

Example `colors.json`

```json
{
    "border_color": "#ffa500"
}
```

Also add your wallpaper changing commands to the `commands.sh` file. Selecting a wallpaper runs the command with the path to the wallpaper passed as the first argument. An example on how to use it with swww or wpaperd is given.

```bash
swww img $1 -t grow --transition-duration 1
```

```bash
wpaperctl set $1
```

You can change the number of pictures cached async at the same time by changing `cache_batch_size`. Making it zero or less will try to cache all the images at the same time

> [!WARNING]
> Trying to cache all the images at the same time could severly affect your performance. Do it only when the number of wallpapers is a managable amount

### Other attributes

- `number_of_pictures` - the number of pictures that are shown on the screen at a time.
- `height` - height of the thumbnails.
- `x_factor` - a digital shift that tilts a shape sideways.

## Usage

Now you're ready to launch HyprQuickPaper from your terminal, or add it to your Hyprland config.

```bash
quickshell -c hyprquickpaper
```

Add one of the above lines to your `hyprland.conf` or `hyprland.lua` to bind HyprQuickPaper to Super + W.

```hypr
bind = $mainMod, W, exec, quickshell -c hyprquickpaper
```

```lua
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("quickshell -c hyprquickpaper"))
```

On using it for the first time it will not load anything. Press escape and then restart it and it should load the wallpapers.

### Keybinds

- H/L, K/J, or the arrow keys to scroll one wallpaper left/right
- U/D to scroll one screen worth left/right respectively
- Tab or Backtab to scroll cyclically
- Esc to quit out
- Space/Enter(or return) to select wallpaper
- Scrolling/click and dragging also works for scrolling
- Clicking also allows selection of a wallpaper

## Common fixes

- Remove everything from the cache folder
