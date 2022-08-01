# Labs Walk Thru

##### This is a accompanying file with the lab instructions and commands to help walk thru the labs. It's especially intended for use for those that have trouble copying and pasting from the slides, or prefer not to.


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

Note: Replace <id> below with the container id from the output of the above command (Tip: you usually only need the first few letters).
```
docker start <id>
```
```
docker ps 
```
```
docker attach <id>
```
