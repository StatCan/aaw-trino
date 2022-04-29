# deploy cluster and all resources
helm-all:  helm-deploy cilium-install create-ns install-istio install-metallb  \
	secret-creation helm-hive helm-minio helm-namespace-controller helm-trino install-gateway cert-secrets

# This is the secret password for trino and minio for LOCAL DEVELOPMENT
secret-creation:
	kubectl create secret generic trino-secret --from-literal=user=trino --from-literal=password=Q1zx10EMuU21aEgAZm4kJm9DrD0EjjzIYE8y01Ea --namespace=trino-system
	kubectl create secret generic trino-minio-secret --from-literal=user=admin --from-literal=password=Q1zx10EMuU21aEgAZm4kJm9DrD0EjjzIYE8y01Ea --namespace=trino-system

helm-deploy:
	kind create cluster --name trino

create-ns:
	kubectl label --overwrite namespace default istio-injection=enabled

	kubectl create ns trino-system
	kubectl label namespace trino-system istio-injection=enabled

	kubectl create ns hive-system
	kubectl label namespace hive-system istio-injection=enabled

	kubectl create ns minio-system
	kubectl label namespace minio-system istio-injection=enabled

helm-hive: helm-repo-bitnami
	helm dependency build ./hive-metastore
	helm upgrade --install -n hive-system \
		hive-metastore ./hive-metastore


helm-minio: helm-repo-bitnami
	helm upgrade --install \
		--repo https://charts.bitnami.com/bitnami \
		-n minio-system \
		minio ./minio


helm-repo-bitnami:
	helm repo add bitnami https://charts.bitnami.com/bitnami


helm-trino:
	helm upgrade --install -n trino-system \
		trino ./trino


# This image needs to exist in the local docker and be tagged by this name to avoid pull image back-off
helm-namespace-controller:
	kind load docker-image statcan/namespace-controller:0.0.1 --name trino
	helm repo add statcan https://statcan.github.io/charts
	helm upgrade --install -n trino-system stable statcan/namespace-controller


#Installation of istio 1.7.8
# curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.7.8 TARGET_ARCH=x86_64 sh -
install-istio:
	cd istio-1.7.8/
	export PATH=$$PWD/bin:$$PATH
	istioctl install --set profile=demo


#Installed of Cilium is needed to apply container networking
cilium-install:
	curl -L --remote-name-all https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-amd64.tar.gz{,.sha256sum}
	sha256sum --check cilium-linux-amd64.tar.gz.sha256sum
	sudo tar xzvfC cilium-linux-amd64.tar.gz /usr/local/bin
	rm cilium-linux-amd64.tar.gz.sha256sum
	rm cilium-linux-amd64.tar.gz
	cilium install



install-metallb:
	kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/namespace.yaml
	kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/metallb.yaml
	kubectl apply -f metallb-configmap.yaml


install-gateway:
	kubectl apply -f ingress-gateway.yaml


cert-secrets:
	openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -subj '/O=example Inc./CN=example.com' -keyout example.com.key -out example.com.crt
	openssl req -out httpbin.example.com.csr -newkey rsa:2048 -nodes -keyout httpbin.example.com.key -subj "/CN=*.example.com/O=httpbin organization"
	openssl x509 -req -sha256 -days 365 -CA example.com.crt -CAkey example.com.key -set_serial 0 -in httpbin.example.com.csr -out httpbin.example.com.crt
	kubectl create -n istio-system secret tls httpbin-credential --key=httpbin.example.com.key --cert=httpbin.example.com.crt

kind-delete:
	kind delete cluster --name trino


helm-postgresql-datasource: helm-repo-bitnami
	helm upgrade --install \
		--repo https://charts.bitnami.com/bitnami \
		--create-namespace \
		-n postgresql-datasource \
		-f postgresql-datasource.values.yaml \
		postgresql-datasource postgresql
	kubectl -n postgresql-datasource apply -f adminer-pod.yaml

rules:
	kubectl cp /tmp/rules.json trino-system/trino-coordinator-75b89c686-vdppr:/tmp/ -c trino-coordinator
# helm-repo-bitnami:
# 	helm repo add bitnami https://charts.bitnami.com/bitnami

# helm-repo-superset:
# 	helm repo add superset https://apache.github.io/superset

# helm-superset: helm-repo-superset
# 	helm upgrade --install \
# 		--create-namespace \
# 		-n superset-system \
# 		-f superset.values.yaml \
# 		superset superset/superset


.PHONY: \
	helm-all \
	helm-hive \
	helm-minio \
	helm-postgresql-datasource \
	helm-repo-bitnami \
	helm-repo-superset \
	helm-superset \
	helm-trino \
	helm-namespace-controller \
	helm-deploy
