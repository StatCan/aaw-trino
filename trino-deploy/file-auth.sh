# Compiles a list of all profiles in the cluster
kubectl get profile -o json | jq -c '.items[] | (.metadata.name)' > profiles.txt
python file-auth.py
