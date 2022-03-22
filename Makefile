helm-all: helm-hive helm-minio helm-trino

helm-hive: helm-repo-bitnami
	helm dependency build ./hive-metastore
	helm upgrade --install --create-namespace -n hive-system \
		hive-metastore ./hive-metastore

helm-minio: helm-repo-bitnami
	helm upgrade --install \
		--repo https://charts.bitnami.com/bitnami \
		--create-namespace \
		-n minio-system \
		minio ./minio

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

helm-trino:
	helm upgrade --install --create-namespace -n trino-system \
		trino ./trino

# kubectl -n trino-system apply -f ./trino.netpols.yaml

.PHONY: \
	helm-all \
	helm-hive \
	helm-minio \
	helm-postgresql-datasource \
	helm-repo-bitnami \
	helm-repo-superset \
	helm-superset \
	helm-trino