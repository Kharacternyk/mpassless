---
description: mpassless is an experimental password manager without a master password.
sidebar_label: Introduction & contacts
---

import Logo from '../static/logo.svg';

# <Logo alt="" height="100%" width="2em" style={{verticalAlign: "middle"}} /> mpassless

<head>
    <title>mpassless</title>
</head>

is an experimental password manager without a master password.
Its operation can be described as **content-decryptable storage**:
if you remember enough of your passwords,
for example half of them,
you can unlock the vault and get the rest of them.

mpassless consists of [a theoretical description of the cryptographic scheme](./scheme.md)
and [an open source reference implementation](https://github.com/Kharacternyk/mpassless).
The reference implementation in turn consists of a Dart library and a Flutter application
that can run [in a browser](https://app.mpassless.org) and [on Android](https://play.google.com/store/apps/details).

mpassless is a crazy idea of [Nazar (me)](https://vinnich.uk),
and there is no warranty of any kind.
If you have questions or suggestions,
I'd love to hear from you at nazar@vinnich.uk.
