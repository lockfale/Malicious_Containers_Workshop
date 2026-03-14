# Malicious Kubernetes Workshop - Lab Setup


Welcome to the Malicious Kubernetes workshop. The following instructions will help you set up the lab environment. The K8s lab is built with `kind` (Kubernetes in Docker) for rapid prototyping and `ansible` for orchestration. It's not suitable for production usage, but it builds fast and reliably given our time constraints.

If you have questions about running the lab on something other than GCP, see the [FAQ](#FAQ) at the end.

**Time:** 5-10 mins including spinning dials

## Prerequisites

- A cloud VM (GCP recommended, AWS/Azure also work)
- **OS:** Ubuntu 22.04 LTS
- **Size:** e2-standard-2 (2 vCPU, 8GB RAM) or equivalent
- SSH access to the VM

## Tools Installed by Ansible

| Tool | Version | Purpose |
|------|---------|---------|
| kubectl | v1.31.4 | Kubernetes CLI |
| kind | v0.27.0 | Local K8s clusters |
| Helm | v3.16.4 | K8s package manager |
| cosign | v2.4.1 | Image signing (Sigstore) |
| crane | v0.20.2 | Container registry tool |
| syft | v1.18.1 | SBOM generation |
| grype | v0.85.0 | Vulnerability scanning |
| ngrok | v3 stable | Tunneling |
| Docker | OS package | Container runtime |

---

**1. Create a new VM instance.** Select an e2-standard-2 for this session, so that you can run a large number of nodes and pods.
This should come out to around the following cost per month: $51.92, or $0.07 cents an hour from your free credits you get by registering a new email address.
        Goto: https://cloud.google.com/free
        Create an account, or log in.
![compute_engine](https://user-images.githubusercontent.com/32903188/182159860-24dde591-f87f-4e70-8df1-be6e27455108.png)

**1a. Enable the compute API:**

![compute_api](https://user-images.githubusercontent.com/32903188/182159962-e40dd9f9-d7d1-4410-957a-e03ca309e653.png)

![image](https://user-images.githubusercontent.com/32903188/182160064-ae2c5d3e-baaf-48a5-85ba-8f01c88b511f.png)

**1b. Configure the machine:**

- **Machine type:** e2-standard-2
- **Boot disk:** Ubuntu 22.04 LTS, 20 GB

![machine_config](https://github.com/lockfale/Malicious_Containers_Workshop/assets/32903188/695c07ec-1c25-4d71-a524-d23063e5d764)

**1c. Configure the boot disk and image size.**
![boot_disk](https://user-images.githubusercontent.com/32903188/182160383-ebeb8930-ab12-4a36-8595-ba71622ce26c.png)


**2. Connect to the instance over SSH.** GCloud has a nice web browser based SSH that will work fine for the lab:

![ssh_connect](https://user-images.githubusercontent.com/32903188/182160599-ac61a507-3f02-4a3f-865f-39416aed9e31.png)

**3. Run the following setup commands:**

```
sudo apt update && sudo apt install -y python3-pip
```

```
sudo pip install ansible
```

```
curl -LO https://raw.githubusercontent.com/lockfale/Malicious_Containers_Workshop/main/current/lab-ansible-setup.yml
```

```
ansible-playbook lab-ansible-setup.yml
```

**4. Start a new terminal** - then `exit` the existing one.

  ```
  kind version
  ```

  ```
  kind create cluster --image=kindest/node:v1.31.4
  ```


**Note:** By default kind will pull an older version of Kubernetes, so the `--image` argument specifies the version we want.

```
kubectl version
```

```
docker ps
```

```
kind get clusters
```


```
kind delete cluster
```


**5. Build Lab Cluster**

 The ansible playbook downloaded a file for you:
 ```
 less kind-lab-config.yaml
 ```

 Note that the YAML file is annotated, so you can understand how it works.

 Press &darr; and &uarr; to scroll through file, and `q` to exit

 Run the following command to setup the kind cluster

 ```
 kind create cluster --config=kind-lab-config.yaml
 ```

 This may take a couple of minutes, go get a coffee or something.

 **6. Confirm lab is operational**

 ```
 kubectl cluster-info --context kind-lab
 ```

```
kubectl get nodes
```

You should see 2 worker nodes and a control plane running.

![get_nodes](https://user-images.githubusercontent.com/32903188/182169551-f2564d91-33e9-4cc6-b4f2-ba9f9cd62834.png)

**7. Setup ngrok account**

Sign up for a free ngrok account on https://ngrok.com, you can OAuth through the same Google Account if you want to keep it simple.

You'll likely get redirected to a Setup & Installation page under Getting Started once you're signed in.

Run the command under "Connect your account" in the terminal on your VM. You won't need to run the `unzip` command because we put it on with ansible already.
![image](https://github.com/lockfale/Malicious_Containers_Workshop/assets/32903188/637031ab-73d2-4d43-9535-84e543afd023)


Example: `ngrok config add-authtoken <authtoken>`

Ngrok will be used for some exercises, so having this step completed ahead of time will be useful.

You can check if ngrok is working with `ngrok http 80`.

**8. Verify setup (optional)**

Run the verification script to check all tools are installed correctly:
```
bash scripts/verify-setup.sh
```

**9. Do not turn off the VM after setup whilst waiting for the workshop. Otherwise you'll lose all the above (ephemeral storage).**


**Troubleshooting note:**

If you have an empty .kubeconfig file - your session was probably duplicated and not restarted after you installed kind. Make sure to exit your session and start a new one before continuing after the kind install.

## Alternative Cloud Providers

### AWS
- Launch an EC2 instance: `t3.large` (2 vCPU, 8GB RAM)
- AMI: Ubuntu 22.04 LTS
- Security group: Allow inbound SSH (port 22)
- The ansible playbook works the same way on AWS

### Azure
- Create a VM: `Standard_D2s_v3` (2 vCPU, 8GB RAM)
- Image: Ubuntu 22.04 LTS
- NSG: Allow inbound SSH (port 22)

## FAQ

**Can I just use my own local VM?**

We discourage the use of local VMs during live workshops for several reasons. First, platform agnosticism — we want everyone to participate regardless of their OS/hardware. Second, bandwidth — downloading container images over shared wifi is slow and can cause issues for other students. Cloud VMs download images from the datacenter in seconds.

After the workshop, you're welcome to run the lab setup on a local VM for personal use.

**Can I just use my own favorite cloud provider?**

If you want to use a provider other than GCP, go ahead at your own risk. The lab setup should work on any VM running Ubuntu 22.04 LTS. We recommend GCP during workshops for consistency, but AWS and Azure work fine too.
