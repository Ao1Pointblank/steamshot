# steamshot.sh
A simple background script to organize locally stored Steam game screenshots

Basic dependencies:  
``util-linux (getopt), curl, inotify-tools (for daemon mode only)``  

```
Usage: ./steamshot-sort.sh [-h|--help] [-i|--interactive] [-u|--undo] [-d|--daemon]
  -h, --help        Show this help message
  -i, --interactive  Show changes before applying
  -u, --undo         Move all screenshots back to main folder
  -d, --daemon       Start an inotifywait event watcher to run the sorter automatically
```

The script is optimized to only download 100B per API call to Steam, in order to identify game titles.  

> The automatic daemon mode is best used as a startup script, and uses minimal resources:  
<img width="700" height="100" alt="image" src="https://github.com/user-attachments/assets/5eec3eb1-9292-421b-b3c8-602917ddb8d1" />


> You will need to change your Steam settings to allow for saving external (local) copies of your screenshots, and set the output folder to match the one used in the script:
``"/home/$USER/Pictures/Steam Screenshots"``

<img width="500" height="400" alt="Capture_2026-09-26_16-54-21" src="https://github.com/user-attachments/assets/d4cc38eb-da4e-4869-8986-df0f2539ed0d" />  

> Resulting organized output folder will look something like this:  

<img width="450" height="350" alt="image" src="https://github.com/user-attachments/assets/7b007f0b-c9c3-4886-a6c8-c5b81863f594" />  

