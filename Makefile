helm-all: cilium-install helm-hive helm-minio helm-trino helm-namespace-controller


helm-deploy:
	kind create cluster --name trino

helm-install: helm-deploy helm-all

helm-hive: helm-repo-bitnami
	helm dependency build ./hive-metastore
	helm upgrade  --install --create-namespace -n hive-system \
		hive-metastore ./hive-metastore

helm-minio: helm-repo-bitnami
	helm upgrade --create-namespace --install \
		--repo https://charts.bitnami.com/bitnami \
		-n minio-system \
		minio ./minio

helm-repo-bitnami:
	helm repo add bitnami https://charts.bitnami.com/bitnami

helm-trino:
	helm upgrade --create-namespace --install -n trino-system \
		trino ./trino

helm-namespace-controller:
	kind load docker-image statcan/namespace-controller:0.0.1 --name goku
	helm repo add statcan https://statcan.github.io/charts
	helm upgrade --install -n trino-system stable statcan/namespace-controller

helm-install-istio:
	cd istio-1.7.8/
	export PATH=$PWD/bin:$PATH
	istioctl install

cilium-install:
	curl -L --remote-name-all https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-amd64.tar.gz{,.sha256sum}
	sha256sum --check cilium-linux-amd64.tar.gz.sha256sum
	sudo tar xzvfC cilium-linux-amd64.tar.gz /usr/local/bin
	rm cilium-linux-amd64.tar.gz{,.sha256sum}
	cilium install

helm-delete:
	kind delete cluster --name trino

helm-postgresql-datasource: helm-repo-bitnami
	helm upgrade --install \
		--repo https://charts.bitnami.com/bitnami \
		--create-namespace \
		-n postgresql-datasource \
		-f postgresql-datasource.values.yaml \
		postgresql-datasource postgresql
	kubectl -n postgresql-datasource apply -f adminer-pod.yaml

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