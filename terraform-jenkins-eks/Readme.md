# Terraform-Jenkins-EKS

## Introduction
----------------------

The aim of this project is to create and EKS cluster atomatically using the devops tool which is Jenkins

## Pre-requisite:
Below are pre requisites which is needed to be installed on our system, before starting with the project:


* AWS Account: Set up an AWS Account
* ACESS KEYS: Configure the access keys (Ex: aws configure)
* Terraform: Terraform is needed to be installed in our system
* Kubernetes

## Steps/ High Level Workflow:

1. Create and EC2 instance and Install Jenkins on it.
2. Write the terraform files to create the EKS Cluster.
3. Push the code on Github.
4. Create a Jenkins Pipeline which triggers the creaation of EKS Cluster.
5.  Deploy the chnages to AWS.