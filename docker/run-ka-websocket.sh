docker run                                          \
  --rm -it --name=ka-websocket                        \
  -p 0.0.0.0:6000:80                              \
  --net=ka-network                                 \
  -v ${PWD}/../bin:/home/keno/ka-server/bin     \
  -v ${PWD}/../docs:/home/keno/ka-server/docs   \
  -v ${PWD}/../etc:/home/keno/ka-server/etc     \
  -v ${PWD}/../lib:/home/keno/ka-server/lib     \
  -v ${PWD}/../t:/home/keno/ka-server/t         \
  -v ${PWD}/../var:/home/keno/ka-server/var     \
  --volumes-from ka-captcha-data                   \
  -e KA_NO_MIDDLEWARE=1                            \
  kenoantigen/ka-server

