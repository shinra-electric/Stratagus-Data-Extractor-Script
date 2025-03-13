# Stratagus Data Extractor Script
Script for extracting Warcraft 1 and 2 game data on macOS for use with the [War1gus](https://github.com/Wargus/war1gus) and [Wargus](https://github.com/Wargus/wargus) projects

## How to use the script
Run the script from the same folder as:
- The latest War1gus or Wargus app
- Your game data

## Supported files
The script can extract data from these files:
- Warcraft
  -  `DATA` folder and `WAR1.BIN`
  -  `setup_warcraft_orcs__humans_1.2_(28330).exe` GoG installer
- Warcraft 2
  - `Support` folder and `Install.mpq`
  - `setup_warcraft_ii_2.02_v5_(78104).exe` with `setup_warcraft_ii_2.02_v5_(78104).bin` together

## Troubleshooting

When downloaded, you probably won't be able to run the script at first.<br>

- If you get a message saying that the script can't be opened, right-click on it and select `Open` from the context menu. You should now get a new option to `Open` anyway. If you are running macOS 15 Sequoia or later you may need to approve it from the `Privacy & Security` tab in the Settings app.<br>

- The default application that is used to open the script might be set to a text editor. Change the default application by selecting the script and using `Command+I` to open the `Get Info` window (or right-click and select from the context menu). Under the `Open With:` section, if Terminal is not selected choose `Other`, enable `All Applications` and navigate to `/Applications/Utilities/Terminal`. It should now open by double-clicking it.<br>

- The script was written for the `Zsh` shell environment. If run from the command line, use `zsh build_rpcs3.sh`. The script will not work properly using `sh build_rpcs3.sh`.

- If you have done the above steps and nothing happens when you run it, you may need to give it executable permissions. In Terminal, use the `cd` command to navigate to where the script is and enter `chmod +x build_rpcs3.sh`. <br>

Note that the script will perform all actions in the same folder you run it from (likely your `Downloads` folder), so you may need to give it permission for this, or move it somewhere else.
