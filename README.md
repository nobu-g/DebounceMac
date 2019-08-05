# DebounceMac

This program suppresses keyboard chattering on Mac, which occurs especially on the butterfly keyboard.  
This is Swift implementation of [debounce-mac](https://github.com/toothbrush/debounce-mac).

## Usage

```zsh
$ git clone git@github.com:nobu-g/DebounceMac.git
$ cd DebounceMac
$ swift build -c release
$ .build/release/DebounceMac
```

## Auto-start at login

```zsh
$ cp .build/release/DebounceMac /usr/local/bin/debounce
$ cp com.debounceMac.app.plist ~/Library/LaunchAgents/
$ launchctl load ~/Library/LaunchAgents/com.debounceMac.app.plist
$ launchctl start com.debounceMac.app
```

For details, see README of [debounce-mac](https://github.com/toothbrush/debounce-mac).

## Custermize

You can easily custermize debounce delay configuration by editting JSON file.  
Once you run this program, it creates config file `~/Library/DebounceMac/config.json`.  
By default, debounce delay(acceptable input interval) of all keys are set to 100ms and you can change this setting.

For example, `example.json` below means

- debounce delay of all keys except "R" are set to 100ms
- debounce delay of "R" is 120ms.
- debounce delay of "Space" is 200ms only when "Option" key is down and "Shift" key is up.

``` json
[
    {
        "key": "ALL",
        "delay": 100,
    },
    {
        "key": "R",
        "delay": 120,
    },
    {
        "key": "Space",
        "delay": 200,
        "condition": {
            "Option": true,
            "Shift": false,
        },
    },
]
```

For more about config file format, see `Config/config.schema.json` .

You can also specify the config file name by the command line argument.

```zsh
$ .build/release/DebounceMac myconfig.json
```

If you use launchctl, you have to edit `~/Library/LaunchAgents/com.debounceMac.app.plist` and reload it.
