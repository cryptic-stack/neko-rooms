#!/bin/sh
set -eu

sed -i \
  -e 's|<title>n\.eko</title>|<title>HackLab</title>|g' \
  -e "s|We're sorry but n\.eko doesn't work properly|We're sorry but HackLab doesn't work properly|g" \
  -e 's|A self hosted virtual browser (<a href="https://github.com/m1k1o/neko">m1k1o/neko</a>) that runs in docker\.|Guided hacking lab powered by HackLab.|g' \
  -e 's|#19bd9c|#2f7d95|g' \
  /var/www/index.html

if [ -f /var/www/site.webmanifest ]; then
  sed -i \
    -e 's|"name": "n\.eko"|"name": "HackLab"|g' \
    -e 's|"short_name": "n\.eko"|"short_name": "HackLab"|g' \
    -e 's|#19bd9c|#2f7d95|g' \
    /var/www/site.webmanifest
fi

for f in /var/www/js/*.js; do
  sed -i \
    -e 's|alt:"n\.eko"|alt:"HackLab"|g' \
    -e 's|Github repository|HackLab workspace|g' \
    -e 's|https://github.com/m1k1o/neko|#|g' \
    -e 's|_v("n")|_v("Hack")|g' \
    -e 's|_v("N")|_v("Hack")|g' \
    -e 's|_v(".eko")|_v("Lab")|g' \
    -e 's|_v(".EKO")|_v("Lab")|g' \
    -e 's|raw.githubusercontent.com/m1k1o/neko/master/README.md|raw.githubusercontent.com/m1k1o/neko-rooms/master/README.md|g' \
    "$f"
done
