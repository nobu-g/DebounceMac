# DebounceMac

This program suppresses keyboard chattering on Mac, which occurs especially on butterfly keyboards.
This is a Swift implementation of [debounce-mac](https://github.com/toothbrush/debounce-mac).

## Usage

```shell
git clone git@github.com:nobu-g/DebounceMac.git
cd DebounceMac
swift build -c release
.build/release/DebounceMac
```

Note: to build this program, you need Xcode installed.

## Auto-start at login

```shell
cp .build/release/DebounceMac /usr/local/bin/debounce
cp com.user.DebounceMac.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.user.DebounceMac.plist
```

For details, see README of [debounce-mac](https://github.com/toothbrush/debounce-mac).

## Customize

You can easily customize debounce delay configuration by editing a JSON file.
Once you run this program, it creates a config file at `~/Library/Application Support/DebounceMac/config.json`.
By default, debounce delay (i.e., acceptable input interval) of all keys is set to 100ms, and you can change this setting.

For example, `example.json` below means

- debounce delay of all keys except "R" is set to 100ms
- debounce delay of "R" is 120ms.
- debounce delay of "Space" is 200ms only when the "Option" key is down and the "Shift" key is up.

``` json
[
    {
        "key": "ALL",
        "delay": 100
    },
    {
        "key": "R",
        "delay": 120
    },
    {
        "key": "Space",
        "delay": 200,
        "condition": {
            "Option": true,
            "Shift": false
        }
    }
]
```

For more about the config file format, see `Config/config.schema.json`.

You can also specify the config file name by the command line argument.

```shell
.build/release/DebounceMac myconfig.json
```

If you use `launchctl`, you need to edit `~/Library/LaunchAgents/com.user.DebounceMac.plist` and reload it.
