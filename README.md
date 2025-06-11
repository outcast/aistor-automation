# AISTOR Airgap Helm Automation

### DirectPV Instruction to come

## Install AIStor and First Object Store
1. run setup_aistor_airgap.sh (optional)
2. create namespaces `aistor` and <object store name>
3. create image pull secrets for both namespaces with same name
4. export `PULL_SECRET` with name of the pull secret you created
5. export your minio license ie `export MINIO_LICENSE="AAAAAAAAAAA"`
5. If not using the default image project paths export them
   1. `export AISTOR_PREFIX=aistor/`
   2. `export MINIO_PREFIX=minio/`
6. run `gen-operator-values.sh > operator-values.yaml`
7. verify `operator-values.yaml` is correct
8. run `helm upgrade -i -n aistor --create-namespace aistor-operators aistor/operators -f operators-values.yaml`
9. run `gen-objectstore-values.sh <object-store-name> <pool-name> <server-count> <volume-count> <volume-capacity> <volume-storage-class> > objectstore-values.yaml`
10. verify `objectstore-values.yaml` is correct
11. run `helm upgrade -i -n <name of object store> --create-namespace object-store aistor/object-store -f objectstore-values.yaml`
