start_postgres() {
  PGDATA="$PWD/db"
  initdb --no-locale --encoding=UTF-8
  pg_ctl -l "$PGDATA/server.log" start
  createuser postgres --createdb
}
stop_postgres() {
  mix ecto.drop
  MIX_ENV=test mix ecto.drop
  dropuser postgres
  pg_ctl stop
}
request() {
  if [ "$#" = 1 ]; then
    curl -s "localhost:4000/api/$1"
  else
    if [ ! -d "tokens" ]; then
      mkdir -p "tokens"
    fi
    if [ ! -f "tokens/$2" ]; then
      touch "tokens/$2"
    fi
  fi
  if [ "$#" = 2 ]; then
    curl -s                                      \
      "localhost:4000/api/$1"                    \
      -H "Authorization: Token $(cat tokens/$2)"
  elif [ "$#" = 3 ]; then
    curl -s                                      \
      "localhost:4000/api/$1"                    \
      -X "$3"                                    \
      -H "Authorization: Token $(cat tokens/$2)"
  elif [ "$#" = 4 ]; then
    curl -s                                      \
      "localhost:4000/api/$1"                    \
      -X $3                                      \
      -H "Authorization: Token $(cat tokens/$2)" \
      -H "Content-Type: application/json"        \
      -d "$4"
  elif [ "$#" = 5 ]; then
    curl -s                                      \
      "localhost:4000/api/$1"                    \
      -X "$3"                                    \
      -H "Authorization: Token $(cat tokens/$2)" \
      -H "Content-Type: application/json"        \
      -H "Accept: $5"                            \
      -d "$4"
  fi
}
login_token() {
  request login _ POST "{\"username\":\"$1\",\"password\":\"$2\"}"
}
