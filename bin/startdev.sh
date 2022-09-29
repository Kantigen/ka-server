echo "Starting development server"
plackup --env development --server Plack::Handler::Standalone --app keno.psgi --reload -R /home/keno/ka-server/lib,/home/keno/ka-server/var
