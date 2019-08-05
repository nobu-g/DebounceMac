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

