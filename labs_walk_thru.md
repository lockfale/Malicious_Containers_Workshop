# Labs Walk Thru
##### This is a accompanying file with the lab instructions and commands to help walk thru the labs. It's especially intended for use for those that have trouble copying and pasting from the slides, or prefer not to.

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
  - Tip: you usually only need the first few letters.

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

