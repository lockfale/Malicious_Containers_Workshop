# BSides_Charleston_2022_Malicious_Containers_Workshop


Welcome to the docker/kubernetes training, the following destructions will help you set up a lab for the Defcon Workshop. The K8s lab component is predominantly built w/ the assistance of `kind` - a tool for rapid prototyping in k8s, and `ansible` for orcestration. It’s not suitable for production usage,but it builds fast and reliably given our time constraints. It’ll give us an environment that will teach us the fundamental components. 


**Time:** 5-10 mins including spinning dials


**1. Create a new VM instance.** Select a medium for this session, so that you can run a large number of nodes and pods. 
This should come out to around the following cost per month: $26.46, or $0.03 cents an hour from your free credits you get by registering a new email address. 
        Goto: https://cloud.google.com/free 
        Create an account, or log in. 
![compute_engine](https://user-images.githubusercontent.com/32903188/182159860-24dde591-f87f-4e70-8df1-be6e27455108.png)

**1a. Enable the compute API:** 

![compute_api](https://user-images.githubusercontent.com/32903188/182159962-e40dd9f9-d7d1-4410-957a-e03ca309e653.png)

![image](https://user-images.githubusercontent.com/32903188/182160064-ae2c5d3e-baaf-48a5-85ba-8f01c88b511f.png)

**1b. Configure the machine: ** 

![machine_config](https://user-images.githubusercontent.com/32903188/182160209-e7609477-f3e6-4c77-b2de-ad1a17b886c4.png)

**1c. Configure the boot disk and image size.** 
![boot_disk](https://user-images.githubusercontent.com/32903188/182160383-ebeb8930-ab12-4a36-8595-ba71622ce26c.png)


**2. Connect to the instance over SSH.** Gcloud has a nice web browser based SSH that will work fine for the lab: 

![ssh_connect](https://user-images.githubusercontent.com/32903188/182160599-ac61a507-3f02-4a3f-865f-39416aed9e31.png)

**3. Run the following setup commands: ** 

`sudo apt update && sudo apt install ansible python3-pip docker.io etcd-client unzip jq`

`sudo usermod -aG docker $USER`


**4. Install the Kubectl binary:**

 `curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"` 

 `curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"`

 `echo "$(<kubectl.sha256) kubectl" | sha256sum --check`

* Should see a "kubectl:OK" message. *
 
 `chmod +x kubectl` 
 
 `sudo mv ./kubectl /usr/local/bin/kubectl` 
 
 `rm kubectl.sha256` 
 
 **5. Install Kind** (Kubernetes in Docker) 
 
 `curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64` 
 
 `chmod +x ./kind`
 
 `sudo mv ./kind /usr/local/bin/kind ` 
   
  
  **6. Start a new terminal** - then `exit` the existing one. 
  
  `kind version` 
  
  `kind create cluster --image=kindest/node:v1.23.0` 
  
  
**Note:** by default it’ll pull an old version of Kubernetes so image argument is added to specify newer version of 
kubernetes

**Note:** kubectl will be one major version ahead of our Kubernetes install but that shouldn't effect our labs
`kubectl version`

`docker ps`

`kind get clusters` 


`kind delete cluster` 


**7. Build Lab Cluster ** 
Note that the YAML file is annotated, so you can understand how it works. 
 Create a file: 
 `nano kind-lab-config.yaml` 
 Open the following link, and paste the contents into the file: [https://github.com/lockfale/DC30_Malicious_Containers_Workshop/blob/main/kind-lab-config.yaml ](https://raw.githubusercontent.com/lockfale/Malicious_Containers_Workshop/main/Bsides_Charleston_22/kind-lab-config.yaml)
 
 Save the file. 
 
 `kind create cluster --config=kind-lab-config.yaml` 
 
 This may take a couple of minutes, go get a coffee or something. 
 
 **8. Confirm lab is operational**
 
 `kubectl cluster-info --context kind-lab`

`kubectl get nodes`

You should see 2 worker nodes and a control plane running.
 
![get_nodes](https://user-images.githubusercontent.com/32903188/182169551-f2564d91-33e9-4cc6-b4f2-ba9f9cd62834.png)


**9. Do not turn off the VM after setup whilst waiting for the workshop. Otherwise you'll lose all the above (ephemeral storage). ** 

  
   

** Troubleshooting note:**

If you have an empty .kubeconfig file - your session was probably duplicated and not restarted after you installed kind. - make sure to exit your session and start a new one before continuing after the kind install.





