MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==MYBOUNDARY=="

--==MYBOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
set -eu

# Bootstrap EKS worker so it can join the cluster
/etc/eks/bootstrap.sh "${cluster_name}" \
  --apiserver-endpoint "${cluster_endpoint}" \
  --b64-cluster-ca "${cluster_ca}"

--==MYBOUNDARY==--
