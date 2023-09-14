---
layout: post
author: JuliaPoo
category: CTF

display-title: "DUCTF 2023: Encrypted Mail Writeup [Crypto, 3 solves]"
tags:
    - ctf
    - crypto
    - zero-knowledge-proof
    - linear-algebra


nav: |
    * [Challenge](#challenge)
        * [Objective](#objective)
    * [Attack](#attack)
        * [Logging into admin](#logging-into-admin)
            * [b isn't random enough](#isnt-random-enough)
        * [Sending flag_haver a message from the admin account](#sending-flag_haver-a-message-from-the-admin-account)
            * [Attacking the Cipher](#attacking-the-cipher)
        * [Summary of Attack](#summary-of-attack)
    
excerpt: "The most fun I've had solving a challenge in a while ^-^. It's rare to have a challenge that involves attacking both the cryptographic primitive and the protocol at the same time."
---

## Metadata

This challenge is from [DownUnderCTF 2023](https://github.com/DownUnderCTF/Challenges_2023_Public). I played under [NUS Greyhats](https://nusgreyhats.org/) instead of the usual [SEE](https://seetf.sg/) and we won 1st. However I didn't really contribute much, I joined halfway through the CTF and had other commitments and accumulated a total of only ~1000/12000 of the eventual points the whole team made.

Regardless, I'm happy that we blooded Encrypted Mail 31 hours into the CTF (beating SEE which I betrayed, sorryyyy Neobeo and Warri). Encrypted Mail was the 2nd hardest crypto challenge, and the hardest was, unfortunately for the author Joseph, unsolved.

## Challenge

- Points: 449
- Solves: 3
- Files: [encrypted-mail.tar.gz](/assets/posts/2023-05-09-encrypted-mail-writeup/encrypted-mail.tar.gz)
- Author: [joseph](https://github.com/josephsurin)

> Zero-knowledge authentication, end-to-end encryption, this new mail app has it all. For a limited time, admins may be sending flags to users. Sign up today to get yours!
>
> `nc 2023.ductf.dev 30000`

### Objective

Players are given a minimal mail-server implementation to interact with. There are 4 options to choose from:

1. Register
2. Login
3. Send Message
4. View Inbox

When you register, the server asks for your username and your public key $y$ that will be used during Login. The intended usage of this mail server would require you to generate a private key $x$ and generate $y$ from it.

During Login, the server prompts you with a series of _challenges_, which should require that you know the secret private key $x$ for that account to answer the challenges correctly. This is the "zero-knowledge" part of this mail server.

Once you log in, you can send messages and view your inbox. To send s message, you would need to input the recipient's username. The server then replies with the recipient's public key. You are then required to encrypt your message with the recipient's public key, sign the message with your private key and tell the server the resulting encrypted message and signature.

When you view your inbox, the server replies with all the messages you have. However, the server replies with the encrypted messages (encrypted with your public key) and the signatures (for you to verify the sender with the sender's public key).

In addition to these functionalities, there are two bot accounts. 
1. `admin`
2. `flag_haver`

The `admin` bot checks for any new accounts and sends them an (encrypted) sweet welcome message `Welcome {username}!`. The `flag_haver` bot iterates all the messages they have, and if the message is from `admin` (`flag_haver` checks the signature) and has the following format: `Send flag to {username}`, `flag_haver` obliges and sends the flag as an (encrypted) message to the user. 

`flag_haver` is the only account that has access to the flag, so we must get `admin` to send them `Send flag to {username}`. However, there's nothing that prompts `admin` to do such a thing, so we probably have to log into `admin`.

Once we log into `admin`, it appears that we still need the `admin`'s private key in order to sign the message, so that `flag_haver` will happily read the message.

## Attack

### Logging into admin

We start with first logging into `admin`. The code for this is implemented in `Authenticator`

```py
g = 3
p = 1467036926602756933667493250084962071646332827366282684436836892199877831990586034135575089582195051935063743076951101438328248410785708278030691147763296367303874712247063207281890660681715036187155115101762255732327814001244715367


class Authenticator:
    def __init__(self, pubkey):
        self.y = pubkey

    def generate_challenges(self, n=128):
        challenges = []
        answers = []
        for _ in range(n):
            b = round(random.random())
            r = random.getrandbits(p.bit_length())
            c = random.getrandbits(p.bit_length())
            c1 = pow(g, r, p)
            if b == 0:
                c2 = pow(g, c, p)
            elif b == 1:
                c2 = pow(self.y, r, p)
            answers.append(b)
            challenges.append((int(c1), int(c2)))
        self.answers = answers
        return challenges

    def verify_answers(self, answers):
        return len(answers) == len(self.answers) and all(a == b for a, b in zip(answers, self.answers))
```

The authentication scheme is a zero-knowledge variant of [Diffie-Hellman](https://en.wikipedia.org/wiki/Diffie%E2%80%93Hellman_key_exchange) (I don't know the actual name of this variant). 

The user is expected to randomly generate a private key $x$ and compute their public key as $g^x = y \; \mathrm{mod} \; p$ where $p$ is a prime and $g = 3$. $p$ is a strong prime so the [Discrete Logarithm Problem (DLP)](https://en.wikipedia.org/wiki/Discrete_logarithm#Cryptography) is hard on $\mathbb{Z}/p\mathbb{Z}$ is computationally hard.

The server knows a user's public key $y$ and wants the user to prove that they know their private key (without actually transmitting the private key). The server generates $128$ challenges, for each challenge, it generates a boolean $b$, and random numbers $r, c \in [0, p)$, and computes:

$$
\begin{aligned}
c_1 &= g^r \; \mathrm{mod} \; p \\
c_2 &= \begin{cases}
y^r = g^{x r} \; \mathrm{mod} \; p & \text{if b}\\
g^c \; \mathrm{mod} \; p & \text{otherwise}
\end{cases}
\end{aligned}
$$

The server then returns $c_1$ and $c_2$ for each challenge, and the user is required to recover the value of $b$ for each challenge.

Suppose the user doesn't know the private key $x$. Then $g^c$ and $y ^r = g^{xr}$ are utterly indistinguishable as, due to the difficulty of DLP, a user won't be able to recover $x$ from $y$, and hence $x r$ might as well be a random number just like $c$. The user is forced to guess the value of $b$ for each challenge, and since there are $128$ challenges, the probability of passing them all is $2^{-128}$, which is unreasonably small.

However, if the user does know the private key $x$, the user can simply test if $c_1^x = c_2$ to get $b$.

We don't know the admin's private key, so we're doomed right?

#### $b$ isn't random enough

Let's look at how the challenges are generated:
```py
import random
# ...
def generate_challenges(self, n=128):
    challenges = []
    answers = []
    for _ in range(n):
        b = round(random.random())
        r = random.getrandbits(p.bit_length())
        c = random.getrandbits(p.bit_length())
        c1 = pow(g, r, p)
        if b == 0:
            c2 = pow(g, c, p)
        elif b == 1:
            c2 = pow(self.y, r, p)
        answers.append(b)
        challenges.append((int(c1), int(c2)))
    self.answers = answers
    return challenges
```

Recall that the user is to recover $b$ which should only be possible if they know their private key. However, $b$ is generated via Python's `random` module, which uses a Pseudo-random number generator (PRNG) known as [MT19937](https://en.wikipedia.org/wiki/Mersenne_Twister).

MT19937 initialises an internal state $u$ of $624$ 32-bit integers, and at each step, it generates a "random" 32-bit integer. Note that `b = round(random.random())` is just a fancy way of selecting a bit from one of the 32-bit outputs. Taking the $624$ 32-bit integer as a vector of $624 * 32 = 19938$ bits, i.e., $u \in F_2^{19938}$ where $F_2 = \mathbb{Z} / 2\mathbb{Z}$ is the field of boolean, each 32-bit output $x_m \in F_2^{32}$ is a linear transform of $u$. I.e., for each bit of output (say bit $b_n$ for the $n$-th challenge), we can associate a known vector $v_n$ such that $v_n^T u = b_n$.

This means that for $N$ challenges generated by the server, we can represent the vector $\textbf{b} = (b_1 \; b_2 \; \cdots \; b_N)$ with a known linear transformation $V u = \textbf{b}$, where $V = (v_1 \; v_2 \; \cdots \; v_N)$. 

This is huge! If we know the value of vector $\textbf{b}$ for a large enough $N$, we can recover $u$, and compute all subsequent $b_i = v_i^T u$. I.e., we can answer all subsequent challenges and log into any user without knowing their private key!

I found this before the hint came up btw, but as I didn't join the discord, I didn't see the announcement calling for feedback :(.

How do we get $\textbf{b}$? Since we can answer the challenges if we log into an account we created (since we know the private key), we can simply log in as many times as needed and save the answers for the challenges.

Furthermore, $V$ is a transform $F_2^{19938} \rightarrow F_2^{N}$. So, to solve for $u$ given the equation $V u = \textbf{b}$, we need $N \ge 19938$. Since we obtain $128$ values of $b_i$ each time we log in, we would need to log in $\lceil 19938/128 \rceil = 156$ times.

{% capture code %}
> Turns out, for large enough $N$, $V$ will always have a 32-bit (or 31? I forgot) kernel, which makes recovering the exact $u$ impossible. However, since for large enough $N$ the kernel remains the same, whichever $u$ that satisfies $V u = \textbf{b}$ for $N \ge 19938$ allows us to compute subsequent $b_i$. This was found experimentally and if anybody knows why (I suspect it's the twisting) do let me know.
{% endcapture %}
<details>
<summary>Mini caveat:</summary>
{{ code | markdownify }}
</details>

We can compute $V$ in a black-box manner. We go through each of the $19938$ basis vectors of $F_2^{19938}$ by setting only one bit (say the $i$-th) of $u$ and computing $\textbf{b}$ given such $u$. $\textbf{b}$ will be the $i$-th column vector of $V$.

```py
s = random.getstate()
def login_sym(bidx, n=128):
    new_s = (s[0], (*[int(0) if i != bidx//32 else int(1)<<int(bidx%32) for i in range(624)], s[1][-1]), s[2])
    random.setstate(new_s)
    ret = []
    for _ in range(156):
        for _ in range(n):
            b = round(random.random())
            r = random.getrandbits(p.bit_length())
            c = random.getrandbits(p.bit_length())
            ret.append(b)
    return ret

# prng is our transform V that transforms the internal state u
# into the challenge answers
prng = np.zeros((624*32, 624*32), dtype=bool)
for bidx in range(624*32):
    print(bidx, end="\r")
    prng[:,bidx] = login_sym(bidx)
np.save(open("prng_transform.npy", "wb"), prng)
```

Once we have $\textbf{b}$, we can recover $u$ and generate the answers for the next challenge to log into any account:

```py
prng = np.load(open("prng_transform.npy", "rb"))
prng_sage = matrix(GF(2), prng.astype(int))

# bits is our b we've gotten from logging in 156 times
sol = prng_sage.solve_right(vector(GF(2), bits), check=False)
bvrec = list(map(int, sol))
rec_s = (s[0], (*[reduce(lambda x,y: (x<<1)+y, bvrec[i*32:i*32+32][::-1]) for i in range(624)], s[1][-1]), s[2])

# Assert that we recovered u correctly
random.setstate(rec_s)
rec_bits = [b for _ in range(156) for b in login_local()]
assert all(x == y for x,y in zip(bits, rec_bits))

# Locally generate the answers for the 128 challenges during the next login
bb = login_local()
myans = " ".join(map(str, map(int, bb))).encode()
```

{% capture code %}
> This step was for me the most frustrating step. I recovered $V$ very quickly but spent at least 2 hours trying to coax `numpy` to do $F_2$ arithmetic. And then I gave up and loaded the matrix into sagemath. However, due to my potato computer, it takes over 20 minutes to load the matrix and after that sagemath becomes extremely unstable and crashes all the time. I ended up re-loading the matrix into sagemath at least 7 times.
{% endcapture %}
<details>
<summary>Not so fun fact:</summary>
{{ code | markdownify }}
</details>

### Sending flag_haver a message from the admin account

Now that we can log into `admin`, we have to send `flag_haver` a message. Unfortunately, we would have to sign the message with `admin`'s private key, which we still do not have.

```py
def send(self, recipient_public_key, message):
    key = secrets.randbelow(2**128)
    key_enc = Encryptor(recipient_public_key).encrypt(key)
    key_enc = key_enc[0].to_bytes(96, 'big') + key_enc[1].to_bytes(96, 'big')
    ct = Cipher(key).encrypt(message)
    sig = Signer(self.private_key).sign(ct)
    return (key_enc + ct, sig)

def receive(self, sender_public_key, ciphertext, sig):
    if len(ciphertext) < 192:
        return False
    key_enc, ct = ciphertext[:192], ciphertext[192:]
    if not Verifier(sender_public_key).verify(ct, sig):
        return False
    key_enc0, key_enc1 = int.from_bytes(key_enc[:96], 'big'), int.from_bytes(key_enc[96:192], 'big')
    key = Decryptor(self.private_key).decrypt((key_enc0, key_enc1))
    message = Cipher(key).decrypt(ct)
    return message
```

In order to send a message, we randomly generate a `key` that gets encrypted with the recipient's public key (we have this) into `key_enc`. The `message` gets encrypted with `ct` and the `ct` is signed with the sender's private key (we don't have this) to get `sig`. `key_enc`, `ct` and `sig` get sent.

Note that the recipient will require their private key to decrypt `key_enc` in order to decrypt `ct` into the message, and they will also verify that `ct` is signed with the recipient's private key. This should ensure that
1. Only the recipient can read the message
2. The recipient can verify that the message is indeed from the sender.

A key "weird" thing to note here is that the signature only verifies that `ct` is _committed_ to the sender's private key. `key_enc` isn't. This means that while the recipient can verify that `ct` came from the sender, they can't guarantee that `key_enc` is.

This means that we can:
1. Take an existing encrypted and signed message sent by the `admin` to a user whose private key we know. In this case, it is the welcome message to the user `MeowMeowMeow`.
2. Use the known private key to recover `key`.
3. Modify `key` which in turn will change the result of the `ct`'s decryption.
4. Re-encrypt `key` with our new recipient's public key to get `key_enc`.
5. Re-use the `ct` and `sig` from the message we got from `admin` and only change the `key_enc`.
6. Send the modified message to the new recipient.

The new recipient will successfully decrypt `key_enc` into our modified key due to step 4, the new recipient will think the message is indeed from `admin` since we did not change `ct`, and finally, the decrypted message will look different from what the `admin` has sent to `MeowMeowMeow` because we've modified `key`.

Now the question is whether we can change `key` such that the decrypted message changes from `Welcome MeowMeowMeow!` to `Send flag to {username}` to be sent to `flag_haver`, where `username` can be anything matching `[a-zA-Z0-9]{8,16}` as we can simply create an account with that username and receive the flag from `flag_haver`. Note that the modified message has to be the same length, so `username` should have length $8$. To do that we need to see how `Cipher(key).encrypt(message)` works.

#### Attacking the Cipher

```py
class Cipher:
    def __init__(self, key):
        self.n = 4
        self.idx = self.n
        self.state = [(key >> (32 * i)) & 0xffffffff for i in range(self.n)]

    def next(self):
        if self.idx == self.n:
            for i in range(self.n):
                x = self.state[i]
                v = x >> 1
                if x >> 31:
                    v ^= 0xa9b91cc3
                if x & 1:
                    v ^= 0x38ab48ef
                self.state[i] = v ^ self.state[(i + 3) % self.n]
            self.idx = 0

        v = self.state[self.idx]
        x0, x1, x2, x3, x4 = (v >> 31) & 1, (v >> 24) & 1, (v >> 18) & 1, (v >> 14) & 1, v & 1
        y = x0 + x1 + x2 + x3 + x4

        self.idx += 1
        return y & 1

    def next_byte(self):
        return int(''.join([str(self.next()) for _ in range(8)]), 2)

    def xor(self, A, B):
        return bytes([a ^ b for a, b in zip(A, B)])

    def encrypt(self, message):
        return self.xor(message, [self.next_byte() for _ in message])

    def decrypt(self, ciphertext):
        return self.xor(ciphertext, [self.next_byte() for _ in ciphertext])
```

We can see that `Cipher` generates a stream by bytes according to the `key` and XORs it with the message. An interesting thing to note is that the `.next` method, and hence the `.next_byte` method, computes their output by taking a linear combination of the bits of `key`. This is easily seen by noting that the only operations used to update `self.state` and return the next byte only involve XOR and bitshifts. 

This is extremely similar to how MT19937 works, in that for a given message of $l$ bytes, we have an associated XOR stream $x \in F_2^{8 l}$ such that $c = m + x$ where $c$ is the ciphertext and $m$ is the message. We also have a 128-bit key $k \in F_2^{8 \times 128}$, and we can derive a fixed transform $V: F_2^{8 \times 128}\rightarrow F_2^{8 l}$ mapping $V k = x$.

For our use-case, we want to keep $c = m + x$ constant and compute a new key $k'$ such that $V k = x'$ and $c = m' + x'$, where $x'$ is the new byte stream and $m'$ is our target ciphertext. Note that

1. We know $k$ as this $k$ is from the welcome message and we can get $k$ by decrypting `key_enc` with our private key.
2. We know $m$ as `Welcome MeowMeowMeow!`.
3. We can control $m'$ and hence know $\delta_m$ as well.

Then since:

$$
\begin{aligned}
c &= m + x = m' + x' = (m + \delta_m) + x' \\
x' &= x - \delta_m \\
V k' &= x' = x - \delta_m
\end{aligned}
$$

Then since we can compute $x - \delta_m$, we can easily compute $k'$... provided $k'$ actually exists.

It turns out that while our desired $k'$ has $128$ dimensions, $V$ only has rank $121$. Practically, this means we can always find a $k'$ such that $x'$ matches $x - \delta_m$ for the first $121$ bits, or ~$15$ bytes. I.e., a $k'$ such that $m$ matches $m'$ by ~$15$-bytes.

Unfortunately, our target message `Send flag to {username}` has a minimum length of $21$ bytes since `username` has the constraints `[a-zA-Z0-9]{8,16}`, so we are $6$ bytes short. Put it another way, if we determine the first $2$ bytes of `username`, say `username=XX??????`, we are guaranteed to find $k'$ such that $m'$ will be `Send flag to XX------`, where `-` are just random bytes, and so `XX------` isn't guaranteed to satisfy the `[a-zA-Z0-9]{8,16}` constraint.

However, we can bruteforce `XX` such that `XX------` does indeed satisfy the constraint!

{% capture code %}
> We bruteforce $2$ characters in `[a-zA-Z0-9]` which amounts to $62^2 = 3844$ possibilities. Now, the probability that the remaining $6$ characters does appear in `[a-zA-Z0-9]` is $(62/256)^{6}$ which is roughly one in $4955$, which is fairly close to $3844$. In the event that no such `XX` exists, we can try again with a different initial username (in the welcome message, which currently is `MeowMeowMeow`).
{% endcapture %}
<details>
<summary>Why we can expect bruteforce to work:</summary>
{{ code | markdownify }}
</details>

It turns out the username `elSvxrjZ` does work. In fact, it works regardless of what $k$ is, since if $\exists k'$ such that $V k' = x' = x - \delta_m = V k - \delta_m$, then for a new encountered key $j$, we have 

$$
V j - \delta_m = V k - \delta_m - V (j - k) = V k' - V (j - k) = V (\delta_k + j)
$$

So, we can set $j' = \delta_k + j$ as our new key.

```py
from itertools import product
import re
import numpy as np
import random

# Compute V
V = []
for bidx in range(128):
    c = Cipher(1<<bidx)
    V.append([c.next() for _ in range(8*21)])
V = matrix(GF(2), np.array(V).T)

msg = b'Welcome MeowMeowMeow!'
allowed = "1234567890qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM"
for x,y in product(allowed, repeat=2):
    target = f'Send flag to {x+y}aaaaaa'.encode()
    ct = Cipher(key).encrypt(msg)

    bs = vector(GF(2), [*map(int, ''.join([format(m^^c, "08b") for m,c in zip(target, ct)]))])
    kbits = V.solve_right(bs, check=False)
    key_rec = int("".join(map(str, kbits))[::-1], 2)

    ctt = Cipher(key_rec).encrypt(target)
    tar = [x^^y for x,y in zip(ctt[15:], target[15:])]
    nt = [x^^y for x,y in zip(tar, ct[15:])]
    new_target = target[:15] + bytes(nt)
    
    assert Cipher(key_rec).encrypt(new_target) == ct
    try:
        if re.fullmatch(r'[a-zA-Z0-9]{8,16}', new_target.decode()[13:]):
            break
    except: pass

print(new_target)
# b'Send flag to elSvxrjZ'
```

So, before we log into `admin`, we just have to create the user `elSvxrjZ`, log into `admin` and send the spoofed message (`Send flag to elSvxrjZ`) to `flag_haver`. `flag_haver` will send the flag to `elSvxrjZ` and we can log into `elSvxrjZ` and decrypt the flag with `elSvxrjZ`'s private key.

## Summary of attack

1. Create an account with the username `elSvxrjZ` and save the private key.
2. Create an account with the username `MeowMeowMeow` and save the private key.
3. Log into `MeowMeowMeow` 156 times to get enough challenge answers to recover the random generator's internal state.
5. Save the welcome message the admin sent `MeowMeowMeow`.
6. Locally generate the answers for the next login challenge to log into the `admin` without knowing the `admin`'s private key.
7. Use the saved welcome message for `MeowMeowMeow` to fake a signed message from `admin` that tells `flag_haver` to send the flag to `elSvxrjZ`.
    - `flag_haver` is prompted to send the flag to username `elSvcrjZ`.
8. Log into `elSvxrjZ` and use `elSvxrjZ`'s private key to decrypt the message from `flag_haver`, which contains the flag.

**Flag**: `DUCTF{wait_its_all_linear_algebra?...always_has_been}`