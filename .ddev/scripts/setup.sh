#!/bin/bash

# Set PLUGIN_PACKAGE to the package name (`vendor/name`) of your plugin.
PLUGIN_PACKAGE="REPLACE_WITH_PACKAGE_NAME"

# Set SITE_URL to the same value set for `REPLACE_WITH_SITE_URL.test` in ./.ddev/config.yaml
SITE_URL="REPLACE_WITH_SITE_URL"


# Check that setup is done before setting up project
if grep -Fxq "REPLACE_WITH_NAME" .ddev/config.yaml; then
  printf '%s\n' "Error: ./.ddev/setup.sh failed. Replace REPLACE_WITH_NAME in ./.ddev/config.yaml with a unique name." >&2
  exit 1
fi

if grep -Fxq "REPLACE_WITH_SITE_URL" .ddev/config.yaml; then
  printf '%s\n' "Error: ./.ddev/setup.sh failed. Replace REPLACE_WITH_SITE_URL in ./.ddev/config.yaml with a local testing domain. For example setting this to my-project.test lets you visit this Craft site at https://my-project.test/" >&2
  exit 1
fi

if [ $PLUGIN_PACKAGE == "REPLACE_WITH_PACKAGE_NAME" ]; then
  printf '%s\n' "Error: ./.ddev/setup.sh failed. Replace REPLACE_WITH_PACKAGE_NAME in ./.ddev/setup.sh with your plugin package name." >&2
  exit 1
fi

if [ $SITE_URL == "REPLACE_WITH_SITE_URL" ]; then
  printf '%s\n' "Error: ./.ddev/setup.sh failed. Replace REPLACE_WITH_SITE_URL in ./.ddev/setup.sh with the same value set for REPLACE_WITH_SITE_URL.test in ./.ddev/config.yaml." >&2
  exit 1
fi

if grep -Fxq "REPLACE_WITH_SITE_URL" _source/_craft/example.env; then
  printf '%s\n' "Error: ./.ddev/setup.sh failed. Replace REPLACE_WITH_SITE_URL in _source/_craft/example.env with a local testing domain. For example setting this to my-project.test lets you visit this Craft site at https://my-project.test/" >&2
  exit 1
fi

# cd to the right directory and setup environment
cd /var/www/html

# Check platform
if [ "$(uname)" == "Darwin" ]; then
  PLATFORM="UNIX"
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  PLATFORM="UNIX"
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
  PLATFORM="NT"
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
  PLATFORM="NT"
fi

if [ -f ".env" ]; then
  echo "Node environment file found."
else
  echo "Node environment file not found. Copying from example.env."
  if [ -f "example.env" ]; then
    cp example.env .env
  else
    echo "No example.env found"
  fi
fi

echo "Changing working directory to _source/_craft/"
cd /var/www/html/_source/_craft/

if [ -d "vendor/" ]; then
  echo "Composer packages already installed."
else
  echo "Installing composer packages."
  composer install --no-interaction --optimize-autoloader
fi

if [ -d "/var/www/html/_source/_craft/vendor/$PLUGIN_PACKAGE" ]; then
  echo "Removing installed version of plugin."
  rm -rf /var/www/html/_source/_craft/vendor/$PLUGIN_PACKAGE
  echo "Replacing installed version with development version."
else
  echo "Symlinking plugin into Craft vendor directory."
fi
ln -nfs ../../../../ /var/www/html/_source/_craft/vendor/$PLUGIN_PACKAGE

if [ -f ".env" ]; then
  echo "Craft environment file found."
else
  echo "Craft environment file not found. Copying from example.env."
  if [ -f "example.env" ]; then
    cp example.env .env
  else
    echo "No example.env found"
  fi
fi

echo "Installing Craft"
./craft install --interactive=0 --email="email@example.com" --username="admin" --password="password" --siteName="Craft Plugin" --siteUrl="\$SITE_URL" --language="en"
echo "Craft installed with"
echo "  User: admin"
echo "  Password: password"
