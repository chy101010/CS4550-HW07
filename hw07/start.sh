# From Nat Tuck's CS4550 Lecture Note
#!/bin/bash

export MIX_ENV=prod
export PORT=4802

CFGD=$(readlink -f ~/.config/bulls)

if [ ! -e "$CFGD/base" ]; then
	echo "Deploy First"
	exit 1
fi

SECRET_KEY_BASE=$(cat "$CFGD/base")
export SECRET_KEY_BASE

_build/prod/rel/bulls/bin/bulls start