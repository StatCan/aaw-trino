helm-all:	helm-hive helm-minio helm-trino helm-namespace-controller


helm-deploy:
	kind create cluster --name trino

helm-install: helm-deploy helm-all

helm-hive: helm-repo-bitnami
	kubectl create ns hive-system
	kubectl label namespace hive-system istio-injection=enabled
	helm dependency build ./hive-metastore
	helm upgrade --install -n hive-system \
		hive-metastore ./hive-metastore

helm-minio: helm-repo-bitnami
	kubectl create ns minio-system
	kubectl label namespace minio-system istio-injection=enabled
	helm upgrade --install \
		--repo https://charts.bitnami.com/bitnami \
		-n minio-system \
		minio ./minio

helm-repo-bitnami:
	helm repo add bitnami https://charts.bitnami.com/bitnami

helm-trino:
	kubectl create ns trino-system
	kubectl label namespace trino-system istio-injection=enabled
	helm upgrade --install -n trino-system \
		trino ./trino

helm-namespace-controller:
	kind load docker-image k8scc01covidacr.azurecr.io/namespace-controller:949b8b02d837fcebd64a135d103e61486185b1f4
	helm repo add statcan https://statcan.github.io/charts
	helm install -n trino-system stable statcan/namespace-controller

#export PATH=$PATH:/PATHTOREPO/istio-1.9.0/bin
helm-install-istio:
	istioctl install

helm-delete:
	kind delete cluster --name trino

# helm-postgresql-datasource: helm-repo-bitnami
# 	helm upgrade --install \
# 		--repo https://charts.bitnami.com/bitnami \
# 		--create-namespace \
# 		-n postgresql-datasource \
# 		-f postgresql-datasource.values.yaml \
# 		postgresql-datasource postgresql
# 	kubectl -n postgresql-datasource apply -f adminer-pod.yaml

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