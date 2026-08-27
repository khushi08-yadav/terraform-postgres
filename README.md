# PostgreSQL Deployment using Terraform, Kubernetes and Helm

## About the Project

This project is created to deploy PostgreSQL on a Kubernetes cluster running on an AWS EC2 instance.

I used Terraform to create the EC2 infrastructure and a shell script to install Kubernetes and Helm on the instance. The PostgreSQL application is deployed using a Helm chart.

Docker is used to build the PostgreSQL image, and the image is stored on Docker Hub. GitHub Actions is used to automate the complete deployment process.

## Technologies Used

* AWS EC2
* Terraform
* Kubernetes
* Helm
* Docker
* Docker Hub
* GitHub Actions
* PostgreSQL
* Ubuntu
* Git and GitHub

## Project Structure

```text
terraform-postgres/
│
├── .github/
│   └── workflows/
│       └── test.yml
│
├── module-postgres/
│   ├── ec2_instance.tf
│   ├── variables.tf
│   └── install-k8s.sh
│
├── templates/
│   ├── statefulset.yaml
│   ├── service.yaml
│   ├── migration-job.yaml
│   └── configmap-init-sql.yaml
│
├── Chart.yaml
├── values.yaml
├── Dockerfile
├── init.sql
├── main.tf
└── provider.tf
```

## How It Works

First, Terraform creates the EC2 instance in AWS.

The `install-k8s.sh` script runs on the instance and installs Kubernetes, containerd, kubectl, kubeadm, Flannel and Helm.

After the Kubernetes cluster is ready, the GitHub Actions workflow connects to the EC2 instance using SSH.

The Docker image is built and pushed to Docker Hub. The image tag is generated from the Git commit.

Then Helm is used to deploy PostgreSQL:

```bash
helm upgrade --install postgres-k8s . \
  --namespace postgresql \
  --create-namespace
```

The image repository and tag are passed from the GitHub Actions workflow.

## PostgreSQL Configuration

The PostgreSQL configuration is maintained in `values.yaml`.

```yaml
postgres:
  db: postgres_db
  user: db_admin
  password: dbpassword
  storage:
    size: 10Gi
    storageClass: local-path
```

The PostgreSQL database runs as a Kubernetes StatefulSet.

A PersistentVolumeClaim is created for PostgreSQL data using the `local-path` StorageClass.

## Database Migration

The Helm chart contains a migration Job.

The Job waits until PostgreSQL is available and then runs the SQL file:

```text
/migrations/init.sql
```

The migration Job is configured as a Helm post-install and post-upgrade hook.

## GitHub Actions

The GitHub Actions workflow performs these steps:

1. Checkout the repository.
2. Login to Docker Hub.
3. Generate the Docker image tag.
4. Build the Docker image.
5. Push the image to Docker Hub.
6. Configure AWS credentials.
7. Configure SSH.
8. Run Terraform init.
9. Run Terraform plan.
10. Run Terraform apply.
11. Wait for Kubernetes to become ready.
12. Deploy PostgreSQL using Helm.
13. Verify PostgreSQL pods, PVC and service.
14. Run Terraform destroy.

The workflow also contains `workflow_dispatch`, so the workflow can be started manually from GitHub Actions.

## Kubernetes Commands

To check the Kubernetes nodes:

```bash
kubectl get nodes
```

To check PostgreSQL:

```bash
kubectl get pods -n postgresql
```

To check the PVC:

```bash
kubectl get pvc -n postgresql
```

To check the Helm release:

```bash
helm list -A
```

To check the migration Job:

```bash
kubectl get jobs -n postgresql
```

## GitHub Secrets

The workflow uses GitHub Secrets for credentials and connection details.

Required secrets:

```text
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
EC2_PRIVATE_KEY
EC2_HOST
DOCKER_USERNAME
DOCKER_PASSWORD
```

Sensitive credentials and private keys should not be committed to GitHub.

## Cleanup

For testing, Terraform destroys the EC2 infrastructure after the deployment verification:

```bash
terraform destroy -auto-approve
```

This project was built to practice Terraform, Docker, Kubernetes, Helm and GitHub Actions together in one deployment workflow.
