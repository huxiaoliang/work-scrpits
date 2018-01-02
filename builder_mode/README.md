# try docker builder mode

This example copy from:

http://tonybai.com/2017/12/21/the-concise-history-of-docker-image-building/

1.stage1: all dependencies in one image(583MB)

  docker build -t repodemo/httpd:latest .

  docker run repodemo/httpd

2.stage2: docker image build mode (228MB)

  use images to build httpd binary and use other images to build
  httpd runtime  

  docker build -t repodemo/httpd-builder:latest -f Dockerfile.build .

  docker create --name extract-httpserver repodemo/httpd-builder

  docker cp extract-httpserver:/go/src/httpd ./httpd

  docker rm -f extract-httpserver

  docker rmi repodemo/httpd-builder

3.stage3:
  use minimal docker image based on Alpine Linux(10.3MB)

   docker build -t repodemo/httpd-alpine-builder:latest -f Dockerfile.build.alpine .

   docker create --name extract-httpserver repodemo/httpd-alpine-builder

   docker cp extract-httpserver:/go/src/httpd ./httpd

   docker rm -f extract-httpserver

   docker rmi repodemo/httpd-alpine-builder

   dockebuild -t repodemo/httpd-alpine -f Dockerfile.target.alpine .

   docker run repodemo/httpd-alpine


4.stage4: 
  use docker image multi-stage build feature(10.3MB)

  docker build -t repodemo/httpd-multi-stage .

  docker run repodemo/httpd-multi-stage
