# From Nat Tuck's CS4550 Lecture Note
#!/bin/bash

export MIX_ENV=prod
export PORT=4802

CFGD=$(readlink -f ~/.config/events)

if [ ! -e "$CFGD/base" ]; then
	echo "Deploy First"
	exit 1
fi

DB_PASS=$(cat "$CFGD/db_pass")
export DATABASE_URL=ecto://hw07:$DB_PASS@localhost/hw07_prod
echo $DATABASE_URL

SECRET_KEY_BASE=$(cat "$CFGD/base")
export SECRET_KEY_BASE

_build/prod/rel/hw07/bin/hw07 start
