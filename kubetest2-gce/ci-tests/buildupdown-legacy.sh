#!/bin/bash

# Copyright 2023 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

make install
make install-deployer-gce
make install-tester-ginkgo

cd "${GOPATH}/src/k8s.io/kubernetes"
# kubetest2 against k/k
kubetest2 gce \
    -v=2 \
    --repo-root=. \
    --build \
    --up \
    --down \
    --legacy-mode \
    --test=ginkgo \
    --target-build-arch=linux/amd64 \
    --master-size=e2-standard-2 \
    --node-size=e2-standard-2 \
    --env=KUBE_IMAGE_FAMILY=ubuntu-2204-lts \
    --env=KUBE_MASTER_OS_DISTRIBUTION=ubuntu \
    --env=KUBE_GCE_MASTER_PROJECT=ubuntu-os-cloud \
    --env=KUBE_NODE_OS_DISTRIBUTION=ubuntu \
    --env=KUBE_GCE_NODE_PROJECT=ubuntu-os-cloud \
    -- \
    --focus-regex='Secrets should be consumable via the environment' \
    --skip-regex='\[Driver:.gcepd\]|\[Slow\]|\[Serial\]|\[Disruptive\]|\[Flaky\]|\[Feature:.+\]' \
    --timeout=30m
