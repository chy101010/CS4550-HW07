#From Nat Tuck's CS4550 Lecture
#!/bin/bash
export MIX_ENV=prod
export PORT=4802
export SECRET_KEY_BASE=insecure
export DATABASE_URL=ecto://hw07:bad@localhost/hw07_prod

mix deps.get --only prod
mix compile

CFGD=$(readlink -f ~/.config/events)

if [ ! -d "$CFGD" ]; then
	mkdir -p $CFGD
fi

if [ ! -e "$CFGD/base" ]; then
	mix phx.gen.secret > "$CFGD/base"
fi

if [ ! -e "$CFGD/db_pass" ]; then
	pwgen 12 1 > "$CFGD/db_pass"
fi

SECRET_KEY_BASE=$(cat "$CFGD/base")
export SECRET_KEY_BASE

DB_PASS=$(cat "$CFGD/db_pass")
export DATABASE_URL=ecto://hw07:$DB_PASS@localhost/hw07_prod

mix ecto.create
mix ecto.migrate

npm install --prefix ./assets
npm run deploy --prefix ./assets
mix phx.digest

mix release
