#!/usr/bin/env bash

# configure the directory where spin-operator is cloned
SPIN_OPERATOR_HOME="${SPIN_OPERATOR_HOME:-$HOME/Development/spinkube/spin-operator}"

# configure the image name for the operator
AZURE_CONTAINER_REGISTRY_ENDPOINT="${AZURE_CONTAINER_REGISTRY_ENDPOINT:-zeissddb96297acr.azurecr.io}"
OPERATOR_REP="${AZURE_CONTAINER_REGISTRY_ENDPOINT}/spin-operator"
OPERATOR_IMG="${OPERATOR_REP}:latest"

# ensure the runtimeclass is applied
kubectl apply -f runtimeclass.yaml

# deploy cert-manager as a dependency for the spin-operator if validating webhook is enabled
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.2/cert-manager.yaml

pushd "$SPIN_OPERATOR_HOME"
# build and publish the operator's image to ACR
# see: https://github.com/spinkube/spin-operator/blob/main/documentation/content/quickstart.md#set-up-your-kubernetes-cluster
# NOTE: this target uses docker buildx for multi-platform images
make docker-build-and-publish-all IMG=$OPERATOR_IMG

# install the spin-operator's CRDs
make install

# actually deploy the spin-operator
# see: https://github.com/spinkube/spin-operator/blob/main/documentation/content/quickstart.md#deploy-the-spin-operator
make deploy IMG=$OPERATOR_IMG

# install the SpinAppExecutor
kubectl apply -f spin-executor-shim.yaml

popd
