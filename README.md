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