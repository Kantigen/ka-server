docker run -it -p ${KA_SERVER_LISTEN:-0.0.0.0}:${KA_SERVER_PORT:-8000}:80 	\
  --name=ka-nginx 					\
  --net=ka-network 					\
  -v ${PWD}/../etc:/etc/nginx 	\
  --volumes-from ka-captcha-data       		\
  -v ${PWD}/../etc:/home/keno/ka-server/etc 		\
  -v ${PWD}/../var:/home/keno/ka-server/var 		\
  -v ${PWD}/../captcha:/home/keno/ka-server/captcha     \
  -v ${PWD}/../../ka-assets:/home/keno/ka-server/var/www/public/assets       \
  -v ${PWD}/../var/www/public/api/api.css:/home/keno/ka-server/var/www/public/api/api.css \
  -d kenoantigen/ka-nginx

