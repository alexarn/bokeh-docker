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
docker build -t afi-nginx
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
Note: this build a PHP 7.1 development environment. To use another PHP version, edit the *Dockerfile* and change the *FROM* image to the one you need.

```
cd bokeh-docker/bokeh-php-dev
docker build -t bokeh-php-7.1-dev .
```

### Memcached
```
docker pull memcached
```

# Run containers

## Bokeh

This will clone the Bokeh project in *www* subdirectory ( *install_dir* param ). In order to set files ownership to the you account, use the *uid* param as follow. 
```
cd your/work/space/
docker run -d -p 9000:9000 --name bokeh-php-userid -h bokeh-php-lla -e install_dir=www -e uid=$(id -u) -v $(pwd)/:/home/webmaster/ bokeh-php-7.1-dev
```

### Check the logs
```
docker logs bokeh-php-lla --follow
```


