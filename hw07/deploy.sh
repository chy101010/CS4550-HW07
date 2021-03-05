#From Nat Tuck's CS4550 Lecture
#!/bin/bash
export MIX_ENV=prod
export PORT=4802
export SECRET_KEY_BASE=insecure
export DATABASE_URL=ecto://hw07:Joi7Yo3A@localhost/hw07_app

mix deps.get --only prod
MIX_ENV=prod mix compile

CFGD=$(readlink -f ~/.config/bulls)

if [ ! -d "$CFGD" ]; then
	mkdir -p $CFGD
	echo "Hello One"
fi

echo "Hello Two"

if [ ! -e "$CFGD/base" ]; then
	mix phx.gen.secret > "$CFGD/base"
	echo "Hello Three"
fi

SECRET_KEY_BASE=$(cat "$CFGD/base")
export SECRET_KEY_BASE

npm install --prefix ./assets
npm run deploy --prefix ./assets
mix phx.digest

mix release
