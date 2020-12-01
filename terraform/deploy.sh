#!/bin/bash
terraform init
terraform apply

kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.0.3/cert-manager.crds.yaml