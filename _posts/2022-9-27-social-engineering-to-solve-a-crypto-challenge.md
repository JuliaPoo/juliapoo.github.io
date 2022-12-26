---
layout: post
author: JuliaPoo
category: Security

display-title: "Social Engineering to Solve A Crypto Challenge"
tags:
    - social-engineering
    - ctf
    - crypto

nav: |
    * [Metadata](#metadata)
    * [Aside: How PGP Works](#aside-how-pgp-works)
    * [Social Engineering Time](#social-engineering-time)
    * [Intended Solution](#intended-solution)
    
excerpt: "Using ProtonMail's user interface to trick organisers into giving the flag"
---

# Metadata

I recently participated in [LakeCTF](https://ctf.polygl0ts.ch/) by [polygl0ts](https://polygl0ts.ch/) with [NUS Greyhats](https://nusgreyhats.org/) and we got 5th place in the Quals.

<center>
<img style="width:calc(min(100%, 900px))" src="/assets/posts/2022-9-27-social-engineering-to-solve-a-crypto-challenge/owo.JPG">
</center>

Among the challenges I solved, there was this cryptography challenge `NeutronMail` with `14` solves. In this challenge we are given an intercepted email [flag.eml](/assets/posts/2022-9-27-social-engineering-to-solve-a-crypto-challenge/flag.eml), which is encrypted with PGP (Pretty Good Privacy) and addressed to `epfl-ctf-admin2@protonmail.com` which we are tasked to decrypt. 

{% capture code %}
```eml
X-Pm-Content-Encryption: end-to-end
X-Pm-Origin: internal
Subject: flag
From: redacted <redacted@example.com>
Date: Sat, 17 Sep 2022 11:37:00 +0000
Mime-Version: 1.0
Content-Type: text/plain
To: epfl-ctf-admin2@protonmail.com <epfl-ctf-admin2@protonmail.com>
X-Pm-Spamscore: 0
Received: from mail.protonmail.ch by mail.protonmail.ch; Sat, 17 Sep 2022 11:37:00 +0000
X-Original-To: epfl-ctf-admin2@protonmail.com
Return-Path: <redacted@example.com>
Delivered-To: epfl-ctf-admin2@protonmail.com


-----BEGIN PGP MESSAGE-----
Version: ProtonMail

wcFMAyRhQ5xV+GJ6ARAAmyuolHbZFMloxZvOw88N6wqjnhSwx8NJyVDScuUp
5M4g7ZskUoxbfcjt9pk+AWeZmhLaI/XSv+ULS3FYuPqJWL+eq/zHpuMw6Nw2
CkDAzMaGKqutnpv385k3Fsq3Y1+VEAgzQAi6iarpQml+FSwG/5we4PAvu5Kj
IWMe/RwY2F7yNmMDwPBmk09L9Yu+tn8CV6XJ8ZH9kwW8OW6anp557m3zmyF8
Gx/7BIoFnxgLtj5NL7ejZWJAleMrDyTks5gPZkYwcHCfdjr6Q54z+qpgDTKX
aFh3sIzOtDzOPv/xJ/gP4lwvrcFrk61A7JgwcO4y+1wRWPKS2WCikbJnfP3V
mLU+tPFLHgxfltwTh1OrbnNsJx631JotWZfLLyWcXel0wrgjSguvcLqXk8cH
caTCAXAEu4+YKBc0hazoAYvt3b6GhOuS6ktwaTAnlM9NqoC4ioiMb45yRxno
yR7DGxqtTM+Qzr2Z7SiUnFalSGfu6T+N6u4rV4+Hoa80sC2LkMxNTSeYE5Ft
xTtGsuzpQbF0GrgacrAql2yBze/syfLsWppaHNBWKYokGctg8JZkdx0Yo7ca
/kUM5EA/saderyePWRJ6xGtF74x/avzJ0+hrQIQkcINPZ1YWAe1lCCm7HYsY
uZdrJZVBNYRIweJpliI/9g6PWWApT1rOC6HIbWxh/fHSwO8BTBAesTx6q7iA
dTQuZmFOJCxIHSDbHnfpHHNkwbGRt9kbTvwYzkwDIbJjuD+uxXo/pAWrNaR6
aYNul29MzvQRDYdnB37dfUOPM7YaRT5/hA3sbAgxAbJDusqMe6iQqhM6M8Lq
zpu7gvDvVxCRwsTVx2owt8UzLlTd1vJnoAJp7pS6J+Y4Wgdn4eB3Oc4QntCo
9zUfHe+RptH4G1vHzpHN+r0WHPij7EZSmJHHOIdvE1PMwCcpDVufktFXKh8Y
EAhgFAQ9ynYehhx2io7F8aO31fMr/Yl81md0H3DpNAGJcGcMRl3uFRIq8I0d
cl4WTW/DCUop88z09gPIbiCZfrCZk2fbJotBNxr7Cu/nscJpKOw/QuEARZix
hPvNCqoQlJ9wmmc+2ehbbjGeVkklIpMi4DckzI3dvszm9cAKTf2FVszECv5/
Fv5zc4UUWn7taUVCPeZcnP/IyOt4m6Stl4SaC4uI3bF6PSgzOsTQu+KDvQKA
POKfoiDUx+8yY8DY+z72ZB0BHdWQTJsPHB49M2i/S4hu2tADlAIoYTs/BzLd
dfUEmzBa/9U6YAdMye0tIQ==
=AyK0
-----END PGP MESSAGE-----
```
{% endcapture %}

<details>
<summary>See `flag.eml`:</summary>
{{ code | markdownify }}
</details>

We are also given the following description:

```
After getting hacked, the organizers of the CTF created a new and 
more secure account. You were able to intercept this PGP encrypted
e-mail. Can you decrypt it?
```

## Aside: How PGP Works

[PGP (Pretty Good Privacy)](https://en.wikipedia.org/wiki/Pretty_Good_Privacy) is an ancient (don't kill me) encryption program that provides cryptographic privacy and authentication. There isn't authentication in this challenge so I won't be covering that.

In this challenge, the message is encrypted with [RSA](https://en.wikipedia.org/wiki/RSA_(cryptosystem)), one of the encryption schemes PGP supports, which is an asymmetric public-private key cryptosystem. In order to send somebody a message encrypted with RSA, the receiver has to expose a _public key_ to everybody, but keep a _private key_ secret. The sender would then _encrypt_ the message with the receiver's _public key_ and send it over. The receiver will then use their _private key_, which nobody else but them knows, to decrypt the message. And so lies the theoretical security of RSA: You **need** the _private key_ in order to decrypt the message, it is theoretically computationally infeasible to do so without. Since only the receiver has their own private key, nobody can decrypt and read the message even if one were to intercept the encrypted message.

In the context of this challenge, [ProtonMail](https://proton.me/) exposes each accounts's _public key_ via their API `https://api.protonmail.ch/pks/lookup?op=get&search=username@protonmail.com`, and so we can get the _public key_ of the intended recipient of the email in this challenge like so:

```py
import requests
username = "epfl-ctf-admin2"
open("pub", "wb").write(requests.get(f"https://api.protonmail.ch/pks/lookup?op=get&search={username}@protonmail.com").content)
!cat pub | gpg --list-packets --verbose

# The relevant public key used for the challenge:

# :public sub key packet:
#     version 4, algo 1, created 1654083420, expires 0
#     pkey[0]: 
#         B1CF59A37A81DA7854EFFDB8C9FE9F2AABEC72FEC3D62324B24D9DB7DE01A3099F79E01219EC35DB4C58C
#         4C6A1B09865349E37B218F48CA9EC161AF84ED32AD5E7B096079DF567991C1B9E03A419B00D3FF6350849
#         C1E8C0753E2BCD54BDD33D81D5D564EE721A6BE80921B4CF220AA9F05F53D98106E59DE9ED327899FB633
#         86AB95F106E5CD60F4F578096B0E0C217928BE5CF6BBE10C6633F2DC320D224AEBF51FE34352738AD0B6E
#         0873C6C3DF5E49EF218F02688F1478D50A55A44D875BFC4799754C2F6135FF168C9C8E225EBF84850A01C
#         A7AE789D425824663FD2479ECC7AD71E1BE674FA59A42ACBAFA48EB43B181957145ED996739FFACE0A2F8
#         3432C0E9D64BCC5A68033AD8E7DF8191B1C0C157007544C8D1AE3A4B662D4B8FAE3549B2A63A076D62E34
#         847DD1AE307B3741A5CE1B5727A2586448FFFA1BB5FF019EA7230CC61DDDA1663B2E165322A02A13EF02B
#         9183704B083C3C7E9A9919C37693BE62A8B4F592041605AD046AC32D0DBFC0D312709D881DD164E2DD130
#         791BA70282FDBBA4391D78CD856AD237F73115DD1A0DD12EFE336E580C0B19C9A4B61F5119A0C1BAEC7C0
#         E313EB65C7405DE5B9BC4C6464A08547887F1C255C1E5ABE8989BF57D94C20E1B50151F4FA796EE46E69B
#         A77C289641EE560B80F2665BD8292C5DD25304BE9246E0FA38133DDD543FB26582DE80A8A0077A7ED636A
#         2DC3
#     pkey[1]: 010001
#     keyid: 2461439C55F8627A
```

Unfortunately for the entire world, [RSA sucks ass](https://blog.trailofbits.com/2019/07/08/fuck-rsa/). It is an incredibly brittle encryption scheme and just overall outdated and shitty. The intended solution for this challenge would involve exploiting a flaw in the _public key_ to compute the _private key_ (which should be computationally intractable!). More about that later. 

For now I'll be going through the **Social Engineering Approach** I took to solve this challenge.

## Social Engineering Time

So I couldn't find a flaw in the public key. The modulus is big (4096 bit) and can't be factored as far as I tried. The exponent is the usual `0x10001`. I also tried to look for the private key online, because sometimes private keys are compromised and floating somewhere in _**The World Wide Web**_, or for any flaws in the PGP configuration; are there any vulnerabilities in the versions used? All of these queries came up null.

Three hours in, we were starting to get desperate, and so I tried this wild idea: Since the only person capable of decrypting the message is the one holding the private key (the intended recipient), what if we tricked the recipient to send us the decrypted message? Now look I totally didn't expect this to work, but on the off chance it is actually somewhat the intended solution I gave it a go. Here's how it works:

I send the intended recipient the encrypted email. ProtonMail would recieve the email, and since it's not exactly good user interface to make the recipient _manually decrypt_ each email they recieve, ProtonMail would decrypt the message and display the decrypted message to the recipient:

<center>
<img style="width:calc(min(100%, 900px))" src="/assets/posts/2022-9-27-social-engineering-to-solve-a-crypto-challenge/whatisent.png">
</center>

What this looks like to the intended recipient (the organisers), is that _some random player_ has solved the challenge. This prompts the organisers to maybe reply with a word of congratulations? 

Now anybody who has used emails will know that typically the email client will append the entire conversation history to the reply email. ProtonMail, when sending the reply back to my email, will try to look for my PGP _public key_ in order to re-encrypt the reply and the conversation history (which includes the decrypted message I want) to send it my way. Unfortunately, my email has no PGP public key for ProtonMail to use, so ProtonMail will just send the reply in plaintext, essentially tricking the organisers to decrypt the message for me:

<center>
<img style="width:calc(min(100%, 900px))" src="/assets/posts/2022-9-27-social-engineering-to-solve-a-crypto-challenge/whattheysent.png">
</center>

**Solved.**

## Intended Solution

The intended recipient being `epfl-ctf-admin2@protonmail.com` implies the existence of `epfl-ctf-admin@protonmail.com`. If you were to take the public keys of both accounts, you'd realise that the modulus (part of the public key) has a common factor. Taking `gcd` of both modulus, which is incredible fast, would allow you to recover the common factor and hence fully factor the intended recipient's modulus. This allows one to compute the intended recipient's private key and decrypt the message.
