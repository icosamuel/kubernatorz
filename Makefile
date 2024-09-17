include .env

argocd-prepare:
	helm repo add argo https://argoproj.github.io/argo-helm
	mkdir argo-cd/crds -p
	helm template argo/argo-cd --version 7.5.2 | \
		yq 'select(.kind == "CustomResourceDefinition")' -s '"./argo-cd/crds/" + .metadata.name + ".yaml"'

argocd-install:
	kubectl apply -f argo-cd/crds
	helm upgrade --install argocd argo-cd \
		--namespace argo

argocd-enable-self-update:
	kubectl apply -f argo-cd/meta

sealed-secrets-prepare:
	helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
	
sealed-secrets-install:
	cd sealed-secrets
	helm upgrade --install sealed-secrets sealed-secrets/sealed-secrets \
		--namespace kube-system
