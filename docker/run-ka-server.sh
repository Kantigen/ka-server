exec docker run                                 \
  --rm -it --name=ka-server                     \
  -p 0.0.0.0:5000:5000                          \
  --net=ka-network                              \
  -v ${PWD}/../bin:/home/keno/ka-server/bin     \
  -v ${PWD}/../docs:/home/keno/ka-server/docs   \
  -v ${PWD}/../etc:/home/keno/ka-server/etc     \
  -v ${PWD}/../lib:/home/keno/ka-server/lib     \
  -v ${PWD}/../t:/home/keno/ka-server/t         \
  -v ${PWD}/../var:/home/keno/ka-server/var     \
  --volumes-from ka-captcha-data                \
  -v ${PWD}/../var/www/public/api/api.css:/home/keno/ka-server/var/www/public/api/api.css \
  -e KA_NO_MIDDLEWARE=1                         \
  kenoantigen/ka-server

