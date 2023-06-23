# Infrastructure

Hey, I'm so glad to se you here!!!

This repo it's demonstration of how we can use terraform to manage infra as code.
Fell free to clone or reuse this repo at your own risk rs.

## Important note

This project is not for beginners, so you should have basic knowledge about AWS.

## Requirements

1 - aws-cli/2.12.3

2 - Terraform v1.5.0

## Getting Started

1 - Make sure you have a valid AWS profile configured on you machine.
```bash
cat ~/.aws/credentials
```

2 - Add the required env vars by adding the `tfvars file` on `env folder`. There you will find a sample with all vars that are required.
```bash
cp ./env/terraform.tfvars.sample ./env/terraform.production.tfvars
```
Note that we're using the following pattern: `terraform.ENVIRONMENT_NAME.tfvars`

3 - To deploy the infra:
```bash
INFRA_ENV=production make deploy
```
The `INFRA_ENV=ENVIRONMENT_NAME` must match the terraform file we just created.

4 - To destroy the infra:
```bash
INFRA_ENV=production make destroy
```


## Optional configs

### K8S

This project has a K8S module enable by default so it will create a new cluster using a few default configs.
In order to finish the cluster configuration you will need to perform some extra steps.

1 - Setup Kubernetes credentials `~/.kube/config`
```bash
aws eks --region REGION update-kubeconfig --name CLUSTER_NAME --profile AWS_PROFILE
```
Update the kube config locally

2 - Apply the rbac rules
```bash
kubectl apply -f ./extra/config/rbac_rules.yaml
```

3 - Update aws-auth configmap
```bash
kubectl edit configmap aws-auth -n kube-system
```
This will open the aws-auth configmap on your default editor. The current config map will be like this:
```yaml
apiVersion: v1
data:
mapRoles: |
    - groups:
    - system:bootstrappers
    - system:nodes
    rolearn: arn:aws:iam::[account_ID]:role/ServiceRoleForEKSClusterNodeGroup[cluster_NAME][environment]
    username: system:node:{{EC2PrivateDNSName}}
kind: ConfigMap
metadata:
creationTimestamp: "2022-01-02T22:42:27Z"
name: aws-auth
namespace: kube-system
resourceVersion: "1234"
uid: 4371-beae-3daa-fc99a6d1f3a9-3b40be1f
```
Just add the mapUsers section as below:
```yaml
apiVersion: v1
data:
mapRoles: |
    - groups:
    - system:bootstrappers
    - system:nodes
    rolearn: arn:aws:iam::[account_ID]:role/ServiceRoleForEKSClusterNodeGroup[cluster_NAME][environment]
    username: system:node:{{EC2PrivateDNSName}}
mapUsers: |
    - userarn: arn:aws:iam::[account_ID]:root
    groups:
        - system:masters
    - userarn: arn:aws:iam::[account_ID]:user/developer 
    username: developer
    groups:
        - read-only-group
kind: ConfigMap
metadata:
creationTimestamp: "2022-01-02T22:42:27Z"
name: aws-auth
namespace: kube-system
resourceVersion: "1234"
uid: 4371-beae-3daa-fc99a6d1f3a9-3b40be1f
```
Don't forget to change `[account_ID]` with you account ID.

Ref: [StackOverflow](https://stackoverflow.com/questions/70787520/your-current-user-or-role-does-not-have-access-to-kubernetes-objects-on-this-eks#:~:text=the%20cluster%20nodes.-,Your%20current%20user%20or%20role%20does%20not%20have%20access%20to,the%20cluster%27s%20auth%20config%20map.)


### Refs:

- https://github.com/whiskyneat/terraform-eks-pubcloud/blob/main/main.tf
- https://docs.aws.amazon.com/pt_br/eks/latest/userguide/add-user-role.html
- https://varlogdiego.com/eks-your-current-user-or-role-does-not-have-access-to-kubernetes
- https://youtu.be/aIpHYYcR7oU


### Issues

If you found any issue feel free to suggest any improvement. 