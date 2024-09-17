include .env

prepare: argocd-prepare sealed-secrets-prepare traefik-prepare

argocd-prepare:
	kubectl create namespace argocd \
		--dry-run=client -o yaml | kubectl apply -f -
	helm repo add argo https://argoproj.github.io/argo-helm
	mkdir -p argo-cd/crds
	helm template argo/argo-cd --version 7.5.2 | \
		yq 'select(.kind == "CustomResourceDefinition")' -s '"./argo-cd/crds/" + .metadata.name + ".yaml"'

argocd-install:
	kubectl apply -f argo-cd/crds
	helm upgrade --install argocd argo-cd \
		--namespace argo

sealed-secrets-prepare:
	helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
	
sealed-secrets-install:
	cd sealed-secrets
	helm upgrade --install sealed-secrets sealed-secrets/sealed-secrets \
		--namespace kube-system

traefik-prepare:
	kubectl create namespace traefik \
		--dry-run=client -o yaml | kubectl apply -f -
	helm repo add traefik https://traefik.github.io/charts
	mkdir -p traefik/crds
	kubectl apply -k https://github.com/traefik/traefik-helm-chart/traefik/crds/ \
		--dry-run=server --output yaml | \
			yq '.items[]' -s '"./traefik/crds/" + .metadata.name + ".yaml"'

traefik-install:
	kubectl apply -f traefik/crds
