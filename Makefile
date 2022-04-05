# deploy cluster and all resources
helm-all:  helm-deploy cilium-install install-metallb install-istio \
	helm-hive helm-minio helm-trino istio-injection helm-namespace-controller install-gateway


helm-deploy:
	kind create cluster --name trino


helm-hive: helm-repo-bitnami
	helm dependency build ./hive-metastore
	helm upgrade --install --create-namespace -n hive-system \
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


# This image needs to exist in the local docker and be tagged by this name to avoid pull image back-off
helm-namespace-controller:
# This is the name expected by the chart
# This image needs to exist in the local docker and be tagged by this name to avoid the pull image back-off
	kind load docker-image statcan/namespace-controller:0.0.1 --name trino
	helm repo add statcan https://statcan.github.io/charts
	helm upgrade --install -n trino-system stable statcan/namespace-controller


#Installation of istio 1.7.8
# curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.7.8 TARGET_ARCH=x86_64 sh -
install-istio:
	cd istio-1.7.8/
	export PATH=$$PWD/bin:$$PATH
	istioctl install -y


#Installed of Cilium is needed to apply container networking
cilium-install:
	curl -L --remote-name-all https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-amd64.tar.gz{,.sha256sum}
	sha256sum --check cilium-linux-amd64.tar.gz.sha256sum
	sudo tar xzvfC cilium-linux-amd64.tar.gz /usr/local/bin
	rm cilium-linux-amd64.tar.gz.sha256sum
	rm cilium-linux-amd64.tar.gz
	cilium install

istio-injection:
	chmod +x ./istio-injection.sh
	./istio-injection.sh


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
