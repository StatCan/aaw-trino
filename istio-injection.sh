# kubectl apply -f samples/addons -n istio-system

kubectl label namespace trino-system istio-injection=enabled
kubectl label namespace hive-system istio-injection=enabled
kubectl label namespace minio-system istio-injection=enabled

kubectl rollout restart deploy trino-coordinator -n trino-system
kubectl rollout restart deploy trino-worker -n trino-system
kubectl rollout restart deploy minio -n minio-system

kubectl delete pod hive-metastore-0 -n hive-system
kubectl delete pod hive-metastore-mariadb-0 -n hive-system

kubectl label --overwrite namespace default istio-injection=enabled
kubectl apply -f ingress-gateway.yaml

openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -subj '/O=example Inc./CN=example.com' -keyout example.com.key -out example.com.crt

openssl req -out httpbin.example.com.csr -newkey rsa:2048 -nodes -keyout httpbin.example.com.key -subj "/CN=*.example.com/O=httpbin organization"
openssl x509 -req -sha256 -days 365 -CA example.com.crt -CAkey example.com.key -set_serial 0 -in httpbin.example.com.csr -out httpbin.example.com.crt
kubectl create -n istio-system secret tls httpbin-credential --key=httpbin.example.com.key --cert=httpbin.example.com.crt

# curl -v -HHost:httpbin.example.com --resolve "httpbin.example.com:$SECURE_INGRESS_PORT:$INGRESS_HOST" \
# --cacert example.com.crt "https://httpbin.example.com:$SECURE_INGRESS_PORT/status/418"
#curl -s -I -HHost:httpbin.example.com "http://$INGRESS_HOST:$INGRESS_PORT/headers"

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/metallb.yaml


cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 172.21.255.200-172.21.255.250
EOF


curl -L --remote-name-all https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-amd64.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-amd64.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-amd64.tar.gz /usr/local/bin
rm cilium-linux-amd64.tar.gz{,.sha256sum}

cilium install
