```bash
keytool -importcert -trustcacerts \
  -file /run/secrets/kubernetes.io/serviceaccount/ca.crt \
  -alias kube-root-ca -keystore mykeys.jks
jshell -R-Djavax.net.ssl.trustStore=mykeys.jks -R-Djavax.net.ssl.trustStorePassword=changeit

# Or better...
cp /usr/lib/jvm/zulu11/lib/security/cacerts .
keytool -importcert -trustcacerts \
  -file /run/secrets/kubernetes.io/serviceaccount/ca.crt \
  -alias kube-root-ca -keystore cacerts -storepass changeit -noprompt
jshell -R-Djavax.net.ssl.trustStore=cacerts \
  -R-Djavax.net.ssl.trustStorePassword=changeit
```
