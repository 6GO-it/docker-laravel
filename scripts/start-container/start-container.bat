docker stop database
docker rm -f database
docker run ^
     -d ^
     -it ^
     --name database ^
     -p 3306:3306 ^
     -e MYSQL_ROOT_PASSWORD=root ^
     -e MYSQL_DATABASE=%1 ^
     -e MYSQL_USER=root ^
     mariadb:latest
docker stop %1
docker rm -f %1
docker run ^
	--name %1 ^
	--link database ^
	-d ^
	-e WEB_DOCUMENT_ROOT=/app/public ^
	-v "%cd%:/app" ^
	-p 80:80 ^
	laravel
