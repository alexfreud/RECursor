# RECursor

**macOS 10.13+ ONLY!**

Support Windows animated cursor in macOS applications, using in [reAMP].

[![Screenshot from reAMP with animated cursor](http://re-amp.ru/media/images/git/animatedCursor.gif)](https://re-amp.ru)

## Install

Swift package only, add this repo URL to your project, setup delegate and enjoy!

```swift
import RECursor
...
// Init cursor
let cursor = try RECursor(cursor: "cur1164.ani")

// Set
cursor.set()

// Reset to default cursor
Cursor.unSet()
```

## About Me

- Twitter: [@alexfreud](https://twitter.com/alexfreud)
- reAMP music player with Winamp skins support: [reAMP]
- PayPal: [Buy me a cup of coffee if you find it's useful for you](https://www.paypal.me/reamp)

## License

MIT

[reAMP]: https://re-amp.ru


