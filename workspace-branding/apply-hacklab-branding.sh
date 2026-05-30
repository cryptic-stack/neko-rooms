#!/bin/sh
set -eu

if getent passwd neko >/dev/null 2>&1; then
  usermod -l student -d /home/student -m neko
fi

if getent group neko >/dev/null 2>&1; then
  groupmod -n student neko
fi

if getent passwd student >/dev/null 2>&1; then
  usermod -c "HackLab Student" student
  chown -R student:student /home/student
fi

mkdir -p /tmp/runtime-hacklab
chown student:student /tmp/runtime-hacklab 2>/dev/null || true
chmod 700 /tmp/runtime-hacklab

if [ -x /usr/bin/neko ] && [ ! -e /usr/bin/hacklab-session ]; then
  cp /usr/bin/neko /usr/bin/hacklab-session
  chmod 0755 /usr/bin/hacklab-session
fi

find /etc/neko -type f -print 2>/dev/null | while read -r f; do
  sed -i \
    -e 's|/home/neko|/home/student|g' \
    -e 's|root:neko|root:student|g' \
    -e 's|runtime-neko|runtime-hacklab|g' \
    -e 's|/var/log/neko|/var/log/hacklab|g' \
    -e 's|/etc/neko|/etc/hacklab|g' \
    -e 's|/usr/bin/neko serve|/usr/bin/hacklab-session serve|g' \
    -e 's|program:neko|program:hacklab-session|g' \
    "$f"
done

for f in /etc/supervisord.conf /etc/supervisor/supervisord.conf; do
  [ -f "$f" ] || continue
  sed -i \
    -e 's|/home/neko|/home/student|g' \
    -e 's|root:neko|root:student|g' \
    -e 's|runtime-neko|runtime-hacklab|g' \
    -e 's|/var/log/neko|/var/log/hacklab|g' \
    -e 's|/etc/neko|/etc/hacklab|g' \
    -e 's|/usr/bin/neko serve|/usr/bin/hacklab-session serve|g' \
    -e 's|program:neko|program:hacklab-session|g' \
    "$f"
done

if [ -d /var/log/neko ]; then
  mv /var/log/neko /var/log/hacklab
fi

if [ -d /etc/neko ]; then
  mv /etc/neko /etc/hacklab
fi

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

if [ -f /var/www/browserconfig.xml ]; then
  sed -i -e 's|#19bd9c|#2f7d95|g' /var/www/browserconfig.xml
fi

for f in /var/www/js/*.js /var/www/css/*.css; do
  [ -f "$f" ] || continue
  sed -i \
    -e 's|raw.githubusercontent.com/m1k1o/neko/master/README.md|raw.githubusercontent.com/m1k1o/neko-rooms/master/README.md|g' \
    -e 's|https://github.com/m1k1o/neko|#|g' \
    -e 's|n\.eko|HackLab|g' \
    -e 's|alt:"n\.eko"|alt:"HackLab"|g' \
    -e 's|Github repository|HackLab workspace|g' \
    -e 's|_v("n")|_v("Hack")|g' \
    -e 's|_v("N")|_v("Hack")|g' \
    -e 's|_v(".eko")|_v("Lab")|g' \
    -e 's|_v(".EKO")|_v("Lab")|g' \
    -e 's|t("img",{attrs:{src:n(2835),alt:"HackLab"}}),||g' \
    -e 's|2835:function(e,t,n){e.exports=n.p+"img/logo.800bec71.svg"}|2835:function(e,t,n){e.exports=""}|g' \
    "$f"
done

rm -f /var/www/img/logo.800bec71.svg

cat >/etc/profile.d/hacklab-prompt.sh <<'EOF'
export HACKLAB_SHELL_USER="${HACKLAB_SHELL_USER:-student}"
export HACKLAB_SHELL_HOST="${HACKLAB_SHELL_HOST:-hacklab}"

if [ -n "${PS1-}" ]; then
  PS1='\[\033[01;32m\]'"${HACKLAB_SHELL_USER}@${HACKLAB_SHELL_HOST}"'\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
  PROMPT_COMMAND='printf "\033]0;%s@%s: %s\007" "$HACKLAB_SHELL_USER" "$HACKLAB_SHELL_HOST" "$PWD"'
fi
EOF

for shellrc in /home/student/.bashrc /root/.bashrc /etc/skel/.bashrc; do
  [ -f "$shellrc" ] || continue
  sed -i \
    -e 's|\\u@\\h|${HACKLAB_SHELL_USER:-student}@${HACKLAB_SHELL_HOST:-hacklab}|g' \
    -e 's|${USER}@${HOSTNAME}|${HACKLAB_SHELL_USER:-student}@${HACKLAB_SHELL_HOST:-hacklab}|g' \
    "$shellrc"
  if ! grep -q 'hacklab-prompt.sh' "$shellrc"; then
    printf '\n[ -f /etc/profile.d/hacklab-prompt.sh ] && . /etc/profile.d/hacklab-prompt.sh\n' >>"$shellrc"
  fi
done
