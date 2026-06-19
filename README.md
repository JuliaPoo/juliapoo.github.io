# Running

```bat
:: Clone repository
git clone --recursive https://github.com/JuliaPoo/juliapoo.github.io

:: Build docker image
cd pages-gem
make image
cd ..

:: Run locally
docker-compose up
```

## Using the Typst backend

- Requires VSCode
- Install `Tinymist Typst` and `Tinymist Typst HTML`. Requires `typst 0.14`, or at least, until typst allows you to customise html output (in particular, disable MathML).
- You need python installed.
    - Need `beautifulsoup4` and `pyyaml`.
- Write your posts in `typst-posts` folder.
- `ctrl+shift+B` to run VSCode task to build current post.