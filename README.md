# Prepare

## Clone project

```
git clone git@git.afi-sa.fr:afi/bokeh-docker.git
```

## Build base images

### MySQL / MariaDB
```
cd bokeh-docker/afi-mysql
docker build -t afi-mysql .
```

### NGINX
```
cd bokeh-docker/afi-nginx
docker build -t afi-nginx .
```

### PHP 7.1 (also exists for 7.2, 7.3)
```
cd bokeh-docker/afi-php7.1-dev
docker build -t afi-php-7.1-dev .
```


### List built docker images
```
docker image ls                                                                       
REPOSITORY                    TAG                 IMAGE ID            CREATED              SIZE                     
afi-mysql                     latest              750e516451bb        About a minute ago   530MB      
```


## Build final images

These images contain configuration instructions needed to deploy / run Bokeh for a development environment

### MySQL / MariaDB
```
cd bokeh-docker/bokeh-mysql
docker build -t bokeh-mysql .
```

### NGINX
```
cd bokeh-docker/bokeh-nginx
docker build -t bokeh-nginx .
```

### Bokeh
Note: this build a PHP 7.1 development environment. To use another PHP version, edit the *Dockerfile* and change the *FROM* image to the one you need.

```
cd bokeh-docker/bokeh-php-dev
docker build -t bokeh-php-7.1-dev .
```

### Memcached
```
docker pull memcached
```

# Create internal network for containers

In order for dockers containers to communicate (for example, php container have to connect to memcache on the network), you can create a private docker network named **bokeh0** (this name will be used later to run all containers):

```
docker network create --driver=bridge --subnet=10.90.0.0/24 --ip-range=10.90.0.0/24 --gateway=10.90.0.254 bokeh0
```


# Run containers

## Memcached

```
docker run -d --network=bokeh0 -p 11211:11211 --name bokeh-memcache -h bokeh-memcache memcached -m 64
```

### Check the logs
```
docker logs bokeh-memcache --follow
```


## MySQL

```
docker run -d --network=bokeh0 -p 3306:3306 --name bokeh-mysql -h bokeh-mysql -e uid=$(id -u) -e MYSQL_ROOT_PASSWORD=$(cat /opt/AFI/etc/root_pwd) -e install_dir=www -v $(pwd):/home/webmaster/ bokeh-mysql
```

## Bokeh

This will clone the Bokeh project in *www* subdirectory ( *install_dir* param ). In order to set files ownership to the you account, use the *uid* param as follow. 
```
cd your/work/space/
docker run -d -p 9000:9000 --name my-bokeh-dev -h bokeh-php-7.1-dev -e install_dir=www -e uid=$(id -u) -v $(pwd)/:/home/webmaster/ bokeh-php-7.1-dev
```

## NGINX

```
docker run -d --network=bokeh0 -p 8080:80 -p 4430:443 --name bokeh-nginx -h bokeh-nginx -e uid=$(id -u) -e install_dir=www -e MYSQL_ROOT_PASSWORD=$(cat /opt/AFI/etc/root_pwd) -e url=bokeh.afi-sa.net -e php_host=bokeh-php -e db_host=bokeh-mysql -e db_name=bokeh -e db_user=bokeh -e db_pwd=bokeh1234 -v $(pwd):/home/webmaster/ bokeh-nginx
```
