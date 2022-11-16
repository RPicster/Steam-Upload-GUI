<h1><img src="https://github.com/RPicster/Steam-Upload-GUI/blob/main/other/icon_high_res.svg?raw=true" width="25" height="25" /> Steam Upload GUI</h1>

This is a simple **Windows** GUI to help you uploading multiple Steam apps through **Steams Content Builder** tool.

It is made for **Game Developers** that regularly need to upload **multiple apps** (with different app IDs) to **Steam**.

If you have multiple games and/or games with demos you know why this tool exists 🤐!

Spend less time ⏱ uploading things, have more time for game development! 🎮

<img src="https://raw.githubusercontent.com/RPicster/Steam-Upload-GUI/main/other/screenshot.jpg?raw=true" width="500" height="333" />

## How to use this tool
### Preparation
- Of course you need to be a Steam partner and have your game(s) setup inside the Steam partner web interface.
- If you haven't already, follow the steps in **[this official manual](https://partner.steamgames.com/doc/sdk/uploading?l=finnish&language=english#1)**.
- Setup your `vdf` files as needed - I personally use the **SteamPipe GUI Tool**. A guide is **[available here](https://partner.steamgames.com/doc/sdk/uploading?l=finnish&language=english#3)**.
- Make sure the `vdf` file are in `tools\ContentBuilder\scripts` in your steamworks sdk folder.
- Download the latest **Steam Upload GUI** from the **[releases](https://github.com/RPicster/Steam-Upload-GUI/releases)** or export it yourself using Godot.
- Unzip the executable and place it in some nice place (There will be two files created... so not on Desktop 😜).
### Using the GUI ✨
- Start `SteamUploadGUI.exe` and first, enter your path to the `\ContentBuilder` directory e.g. `"C:\steam_sdk\tools\ContentBuilder`.
- After pressing `Enter` to confirm, it automatically detects your Steam apps `vdf` files.
- Select the Apps that you want to Upload.
- Enter your Steam credentials for the upload (Steam suggests to create a special user for that, I would recommend following that guideline! 🧙‍♂️)
- If it is your first time uploading Apps via the Content Builder, you probably need to **authenticate via Steam Guard** first. Use the button on the bottom to do so.
- When the tool is interacting with `steamcmd.exe` a new comnmand prompt will open to show you the progress.

## Troubleshooting
**❓ Problem:** I can not find any Apps!</br>
**❗ Solution:** Make sure you followed the above steps! Check if there are `*.vdf` files for your projects in the `ContentBuilder\scripts` folder.

**❓ Problem:** The uploaded version is not live on Steam!</br>
**❗ Solution:** If an app is uploaded via the Content Builder, you always have to set it to the `default` branch manually in the web interface, there is no way to upload something and set if life on `default` automatically.

If you need further support or have questions, join my [**Community Discord Server**](https://discord.com/invite/JU3y5WkQ4g). If you encounter bugs, please **open an Issue here on GitHub**.

# License
The project is MIT licensed. You can find the complete license in the [LICENSE](https://github.com/RPicster/Steam-Upload-GUI/blob/main/LICENSE) file.

Steam Upload GUI was made using the **[Godot Engine](https://www.godotengine.org)** - [License Details](https://godotengine.org/license)

The default font is **[Noto Sans](https://fonts.google.com/noto/specimen/Noto+Sans/about)**

# Contributing

**🤩 Contributions are welcome! Especially expanding the tool to work on Linux/Mac! 🤩**




# Giving back

I use Twitter as my main account for game development related stuff, so I would be thankful for anyone following me 🎉

[**Raffa on Twitter**](https://www.twitter.com/MV_Raffa)

I would also love to welcome you on my games Discord server where we can have a friendly chat about my games, or about Godot 💬

[**Community Discord Server**](https://discord.com/invite/JU3y5WkQ4g)

And if you like, I will praise the dark lord ☕ every day and gladly accept your offerings to the shrine!

[**Buy Raffa a Coffee**](https://www.buymeacoffee.com/raffa)
