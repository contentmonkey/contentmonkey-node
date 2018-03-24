# ContentMonkey
[![Travis](https://img.shields.io/travis/contentmonkey/contentmonkey.svg?style=flat-square)](https://travis-ci.org/contentmonkey/contentmonkey)
[![GitHub top language](https://img.shields.io/github/languages/top/contentmonkey/contentmonkey.svg?style=flat-square&colorB=green)](#)
[![Gemnasium](https://img.shields.io/gemnasium/contentmonkey/contentmonkey.svg?style=flat-square)](https://beta.gemnasium.com/projects/github.com/contentmonkey/contentmonkey)
[![Unicorns](https://img.shields.io/badge/unicorn-approved-ff69b4.svg?style=flat-square)](https://www.youtube.com/watch?v=9auOCbH5Ns4?autoplay=true)
## Description
**ContentMonkey** is a _simple_ but _powerful_ CMS written in _CoffeeScript_ with _NodeJS_.
## Getting Started
### Step 1:
Install **NodeJS** and **yarn**.
**Mac:**

```
brew install node yarn
```
**Windows:**

Install **NodeJS** from [https://nodejs.org/en/download/](https://nodejs.org/en/download/).

Install **yarn** with the [official installer](https://yarnpkg.com/latest.msi).

**Linux:**

Install **NodeJS** and **yarn** using _apt-get_:
```
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
```
### Step 2:
Install the app's **node dependencies** using _yarn_:
```
yarn install
```
### Step 3:
Run the application using **yarn**:
```
yarn start
```
