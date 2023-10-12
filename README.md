This is a tool which implements the TOTP-style Google Authenticator protocol, which is like the TOTP standard except it's noncompliant as it doesn't implement a large enough shared key, but that's what GitHub wants. This will be the last piece of software I release on GitHub - all my newer stuff will be on codeberg once I can be bothered releasing more stuff.

As the author of this software, I release this into the public domain. Of course, the Zig standard module is MIT-licensed, but if you somehow managed to grab some public domain replacements for all the stuff this uses then you'd have a fully public-domain implementation for this garbage.

Yes, my actual key is hardcoded into this program. I would rather be using email 2FA instead. No, I'm not giving you my password or my recovery keys.

Usage:

1. Get Zig 0.11.0.
2. Put your own key into `src/main.zig` .
3. `zig build -p ~/.local install` .
4. Run `fuckyougithub` .
