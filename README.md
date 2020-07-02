# Ansible Kops

The purpose of this repository is to provide a Kubernetes platform in a Public Cloud. 
The deployment of the cluster is fully automated and managed by multiple tools such as Ansible or Kops.

It follows the Best Practices of Docker, Kubernetes, AWS and Ansible as much as possible.

## Used tools

- [Kops](https://github.com/kubernetes/kops) - Kops is an official Kubernetes project for managing production-grade Kubernetes clusters to Amazon Web Services.
- [Kubectl](https://kubernetes.io/docs/reference/kubectl/kubectl) - Kubectl is a command line tool for controlling Kubernetes clusters.
- [Helm](https://github.com/helm/helm) - Helm is a tool for managing Charts. Charts are packages of pre-configured Kubernetes resources.
- [Ansible](https://github.com/ansible/ansible) - Ansible is a radically simple IT automation platform that makes your applications and systems easier to deploy. 
- [Docker](https://github.com/docker/docker-ce) - Docker is a set of platform as a service (PaaS) products that use OS-level virtualization to deliver software in packages called containers.


## Kubernetes add-ons

- [Kube2IAM](https://github.com/jtblin/kube2iam) - 
kube2iam provides different AWS IAM roles for pods running on Kubernetes
- [External-DNS](https://github.com/kubernetes-sigs/external-dns) - Configure external DNS servers (AWS Route53, Google CloudDNS and others) for Kubernetes Ingresses and Services.
- [Ingress NGINX](https://github.com/kubernetes/ingress-nginx) - Ingress-nginx is an Ingress controller for Kubernetes using NGINX as a reverse proxy and load balancer.
- [Cert-manager](https://github.com/jetstack/cert-manager) - Automatically provision and manage TLS certificates in Kubernetes.

## Docker Images

- [Varnish](https://hub.docker.com/_/varnish) - Varnish Cache is an HTTP accelerator designed for content-heavy dynamic web sites as well as APIs.
- [MariaDB](https://hub.docker.com/_/mariadb) - MariaDB is a community-developed fork of the MySQL relational database management system.
- [Wordpress](https://hub.docker.com/repository/docker/jreisser/wordpress) -  Wordpress is a free and open source blogging tool and a content management system (CMS) based on PHP and MySQL, which runs on a web hosting service. This Docker image of Wordpress has been [created from scratch](https://github.com/dysonfrost/wordpress).
- [Maintenance Page](https://hub.docker.com/r/fatir/maintenance) - Nginx serving html page indicating system maintenance.



## Prerequisites

- An AWS account
- Docker
- Docker Compose
- A registered domain
- Certbot
- Aws-cli
- Ansible
- Boto3
- jq

## TL;DR

I created a Vagrantfile that will setup an Ubuntu 16.04 box using libvirt or virtualbox.

Depending on your distribution/OS, install vagrant then run the following commands:

```sh
$ vagrant up && vagrant ssh
$ cd ansible-kops
```

Inside the virtual machine, setup the environment:

```sh
# Configure an AWS IAM User
$ aws configure

# You will be prompted for your access keys
AWS Access Key ID [None]: AKIA************
AWS Secret Access Key [None]: Bk84****************
Default region name [None]: eu-west-1
Default output format [None]: json


# Set up your domain
# Initiate a dns01 challenge using certbot-dns-route53
# This task is optional if you've already done this before
$ certbot certonly --dns-route53 -d example.mydomain.com \
--config-dir ~/.config/letsencrypt \
--logs-dir /tmp/letsencrypt \
--work-dir /tmp/letsencrypt \
--dns-route53-propagation-seconds 30


# Edit the group_vars directory then run ansible-playbook
$ ansible-playbook deploy.yml


# Grab a cup of coffee
```

## Environment Setup

This code has been tester on the following Linux distributions:

- Archlinux
- Ubuntu 16.04
- Ubuntu 18.04

The ansible packages for Kops & Kubectl are compatible with Linux-AMD64 and Darwin-AMD64 architectures.

### AWS Account

As per [AWS documentation about Kops](https://aws.amazon.com/blogs/opensource/deploying-aws-iam-authenticator-kubernetes-kops/), you must pocess an AWS account and create an IAM user with the following permissions:

- AmazonEC2FullAccess
- AmazonRoute53FullAccess
- AmazonS3FullAccess
- IAMFullAccess

#### AWS cli

You must have aws-cli installed in your environment. When you've created the IAM user mentioned above, run the following command.

```sh
$ aws configure

# Optionally you can specify the AWS Profile
$ aws configure --profile <profile_name>
```


### Registered Domain

You must own a registered domain in order to complete the Kubernetes cluster deployment.

#### New domain
[Register a new domain](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/domain-register.html) using AWS Route53.

#### Existing domain
[Create a subdomain](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/CreatingNewSubdomain.html) without migrating the parent domain.


- Create a hosted zone for your subdomain (example.mydomain.com.)
- Take note of your NS record
- Log in to your domain registrar account
- Create the correspond NS record to let your domain know that your subdomain is hosted on AWS

```
DOMAIN                   TTL       TYPE                     TARGET
example.mydomain.com.      0         NS      ns-xxxx.awsdns-xx.org
example.mydomain.com.      0         NS      ns-yyy.awsdns-yy.org
...
```


### Certbot

We'll use the Route53 DNS plugin for Certbot.

This plugin automates the process of completing a dns-01 challenge (DNS01) by creating, and subsequently removing, TXT records using the Amazon Web Services Route 53 API.

Certbot-dns-route53 is available on [Debian](https://packages.debian.org/sid/python3-certbot-dns-route53), [Ubuntu](https://packages.ubuntu.com/bionic/python3-certbot-dns-route53), [Archlinux](https://www.archlinux.org/packages/community/any/certbot-dns-route53/) or [PyPi](https://pypi.org/project/certbot-dns-route53/).

```bash
# Ubuntu
$ sudo add-apt-repository ppa:certbot/certbot -y && sudo apt-get update -qq
$ sudo apt-get install -q -y python3-certbot-dns-route53

# PyPi
$ python3 -m pip install pip --upgrade --user
$ python3 -m pip install certbot-dns-route53 --user
```

To initiate a dns challenge, please execute the following command:

```sh
certbot certonly --dns-route53 -d example.mydomain.com \
--config-dir ~/.config/letsencrypt \
--logs-dir /tmp/letsencrypt \
--work-dir /tmp/letsencrypt \
--dns-route53-propagation-seconds 30
```

### Ansible

Install Ansible using Python Package Index:

```sh
$ python -m pip install pip --upgrade --user
$ python -m pip install ansible --user
```

### GitHub

Clone the repository and enter the root directory

```sh
$ git clone https://github.com/dysonfrost/ansible-kops.git && cd ansible-kops
```

## Environment variables

You will find all of the environment variables in the [group_vars](group_vars) directory.

- [group_vars/all.yml](group_vars/all.yml) contains the global environment variables
- [group_vars/secrets.yml](group_vars/secrets.yml) contains the sensitive data related to wordpress and mariadb deployments



## Deploy!

When you environment is set and the pre-requisites are met, please run the following playbook with Ansible:

```sh
ansible-playbook deploy.yml --ask-become-pass
```

It will take approximately 10 minutes to complete.

## Verify

Congratulations, you've just deployed a Kubernetes cluster on AWS with a set of add-ons and a fresh new wordpress pod.


You should have access to wordpress using the following url: https://wordpress.example.com

Note that the certificate is self-signed, that's because we're using the cert-manager staging cluster-issuer by default.

To access to your website using a production let's encrypt certificate, replace the `cert-manager.io/cluster-issuer` line in your wordpress-ingress manifest:

```yaml
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: wordpress-ingress
  namespace: wordpress
  annotations:
    kubernetes.io/ingress.class: nginx
    kubernetes.io/tls-acme: "true"
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  tls:
  - hosts:
    - "*.example.com"
    secretName: wordpress-tls-cert-prod

```

Apply the change and check your ingress's status using the following command:

```sh
kubectl -n wordpress get cert
```

If the value is set to `True`, you'll be able to access to wordpress using a production certificate.

## Maintenance

I've created a simple [script](scripts/maintenance.sh) to help you interact with your wordpress pods.

Just execute the following command to set maintenance mode on wordpress

```sh
$ cd scripts && ./maintenance.sh on

# Will output if a change has been applied or not
```

To turn off maintenance mode, just switch the script parameter to `off`
```sh
$ ./maintenance.sh off
```

## Cleanup

To terminate your Kubernetes cluster, run the following playbook:

```sh
$ ansible-playbook cleanup.yml
```
