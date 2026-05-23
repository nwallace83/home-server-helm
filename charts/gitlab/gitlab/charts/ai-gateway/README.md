# ai-gateway-helm-chart

:warning: This helm chart is meant for self-hosted models users only!

For all other purposes please consider using [Runway](https://docs.runway.gitlab.com/guides/onboarding/). 

## Installation

To install the Helm chart using self-hosted models,

```shell
helm repo add ai-gateway \
  https://gitlab.com/api/v4/projects/gitlab-org%2fcharts%2fai-gateway-helm-chart/packages/helm/devel

helm repo update

helm upgrade --install ai-gateway \
  ai-gateway/ai-gateway \
  --version 0.8.1 \
  --namespace=ai-gateway \
  --create-namespace \
```

## JWT Signing Keys

The AI Gateway requires RSA signing and validation keys for issuing short-lived JWTs. There are two sets of keys:

- **AI Gateway keys** (`AIGW_SELF_SIGNED_JWT__SIGNING_KEY` / `AIGW_SELF_SIGNED_JWT__VALIDATION_KEY`) - used by the AI Gateway for features like Duo Chat.
- **Duo Workflow keys** (`DUO_WORKFLOW_SELF_SIGNED_JWT__SIGNING_KEY` / `DUO_WORKFLOW_SELF_SIGNED_JWT__VALIDATION_KEY`) - used by the GitLab Duo Agent Platform.

By default, the chart auto-generates all four RSA keys and stores them in a Kubernetes Secret named `<release>-jwt-keys`. No additional configuration is needed.

### Using your own keys (optional)

If you need to manage keys externally (for example, for key rotation or to share keys across deployments), you can point the chart to a pre-existing Kubernetes Secret instead.

1. Generate the keys:

    ```shell
    openssl genrsa -out aigw_signing.key 2048
    openssl genrsa -out aigw_validation.key 2048
    openssl genrsa -out duo_workflow_signing.key 2048
    openssl genrsa -out duo_workflow_validation.key 2048
    ```

1. Create the Secret:

    ```shell
    kubectl -n ai-gateway create secret generic my-jwt-secret \
      --from-file=aigw-signing-key=aigw_signing.key \
      --from-file=aigw-validation-key=aigw_validation.key \
      --from-file=duo-workflow-signing-key=duo_workflow_signing.key \
      --from-file=duo-workflow-validation-key=duo_workflow_validation.key
    ```

1. Reference the Secret in your `values.yaml`:

    ```yaml
    aigwSigningKey:
      secret: "my-jwt-secret"
      key: "aigw-signing-key"
    aigwValidationKey:
      secret: "my-jwt-secret"
      key: "aigw-validation-key"

    duoWorkflowSigningKey:
      secret: "my-jwt-secret"
      key: "duo-workflow-signing-key"
    duoWorkflowValidationKey:
      secret: "my-jwt-secret"
      key: "duo-workflow-validation-key"
    ```

You can mix and match - for example, provide your own AI Gateway keys while letting the chart auto-generate the Duo Workflow keys, or vice versa.

## Local development

To test any changes during local development, perform the following steps.

1. Setup a Kubernetes cluster. [Rancher Desktop](https://rancherdesktop.io/), [Minikube](https://minikube.sigs.k8s.io/docs/start/?arch=%2Fmacos%2Fx86-64%2Fstable%2Fbinary+download) or any other Kubernetes distribution should work.
1. Install [Helm](https://helm.sh/docs/intro/install/).
1. Create a `test.values.yaml` file with the following context

    ```yaml
    image:
      tag: latest
    
    logging:
      level: "debug"
      json: false

    gitlab:
      url: "http://gdk.test:3000/"
      apiUrl: "http://gdk.test:3000/api/v4/"

    customerPortalUrl: "http://gdk.test:5000/"

    anthropicApiKey:
      value: "REPLACE_ME"

    vertexTextModel:
      project: "REPLACE_ME"
      jsonKey:
        value: |-
          {
            "type": "service_account",
            "project_id": "REPLACE_ME",
            "private_key_id": "REPLACE_ME",
            "private_key": "REPLACE_ME",
            "client_email": "REPLACE_ME",
            "client_id": "REPLACE_ME",
            "auth_uri": "https://accounts.google.com/o/oauth2/auth",
            "token_uri": "https://oauth2.googleapis.com/token",
            "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
            "client_x509_cert_url": "REPLACE_ME",
            "universe_domain": "googleapis.com"
          }

    extraEnvironmentVariables:
      - name: TEST
        value: test
    ```

1. Replace all instances of `REPLACE_ME` in the above file with appropriate values.
  1. Tip - Follow https://developers.google.com/workspace/guides/create-credentials if you need to create the `GOOGLE_APPLICATION_CREDENTIALS`. 
1. Verify the helm chart is rendering correctly

    ```shell
    helm template ai-gateway-test . \
      -f values.yaml \
      -f test.values.yaml
    ```

1. Install the helm chart

    ```shell
    helm upgrade --install ai-gateway . \
      --namespace ai-gateway \
      --create-namespace \
      --set="gitlab.url=<your-local-gitlab>" \
      --set="gitlab.apiUrl=<your-local-gitlab>/api/v4/"
    ```

1. Access the AI Gateway locally

    Get the pod name

    ```shell
    export POD_NAME=$(kubectl get pods --namespace ai-gateway-test -l "app.kubernetes.io/name=ai-gateway,app.kubernetes.io/instance=ai-gateway-test" -o jsonpath="{.items[0].metadata.name}")
    ```
    
    Get the AI Gateway server's port and portforward from local to the pod

    ```shell
    export CONTAINER_PORT=$(kubectl get pod --namespace ai-gateway-test $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
    kubectl --namespace ai-gateway-test port-forward $POD_NAME 5052:$CONTAINER_PORT
    ```

    You should be able to access the AI Gateway now

    ```shell
    $ curl localhost:5052/docs
    {"error":"No authorization header presented"}
    ```

1. Access the Duo Workflow Service locally

    **If you have a terminal running a port-forward, open a new terminal window.**

    Get the pod name

    ```shell
    export POD_NAME=$(kubectl get pods --namespace ai-gateway-test -l "app.kubernetes.io/name=ai-gateway,app.kubernetes.io/instance=ai-gateway-test" -o jsonpath="{.items[0].metadata.name}")
    kubectl --namespace ai-gateway-test logs -f $POD_NAME
    ```

    Get the Workflow service port and portforward from local to the pod

    ```shell
    export CONTAINER_PORT=$(kubectl get pod --namespace ai-gateway-test $POD_NAME -o jsonpath="{.spec.containers[1].ports[1].containerPort}")
    kubectl --namespace ai-gateway-test port-forward $POD_NAME 50052:$CONTAINER_PORT
    ```
    
    You should be able to access the The Workflow service through gRPC now

    ```shell
    $ grpcurl  -plaintext localhost:50052 list
    DuoWorkflow
    grpc.reflection.v1alpha.ServerReflection
    Timing Data: 15.602496ms
      Dial: 5.341735ms
        BlockingDial: 5.309769ms
    ```
1. Test locally with ingress

  1. Setup a fresh cluster with NGINX Ingress.

  1. Install the chart and enabled the grpc ingress.

    ```
    $ helm upgrade --install aigw . -n aigw --create-namespace \
        -f test.values.yaml \
        --set ingress.enabled=true \
        --set ingress.className=nginx
    ```

  1. Confirm HTTP is forwared to the AI gateway backend:

    ```bash
    $ curl http://chart-example.local:80
    {"error":"No authorization header presented"}
    ```

  1. Confirm GRPC is forwared to the Duo Workflow backend:

    ```bash
    $ grpcurl -vv -plaintext grpc-chart-example.local:80 list
    DuoWorkflow
    grpc.reflection.v1alpha.ServerReflection
    Timing Data: 15.602496ms
      Dial: 5.341735ms
        BlockingDial: 5.309769ms
    ```

1. Delete the helm chart

    ```shell
    helm -n ai-gateway-test delete ai-gateway-test
    ```

## Build and publish assets

To release a new version of the GitLab Helm chart:

1. Update the `version` and `appVersion` in `Chart.yaml` to the desired release version.
1. **Double-check the chart version** in `Chart.yaml` before proceeding.
1. Merge the changes to the `main` branch.
1. Push a git tag matching the chart version (e.g., `v0.7.0`).
    ```shell
    git tag v0.7.0
    git push origin v0.7.0
    ```

Pushing the git tag will automatically trigger the CI/CD pipeline, which will build and publish the Helm chart to the GitLab package registry.

## gRPC TLS Proxy

The chart includes a `grpc-tls-proxy` subchart that runs a standalone NGINX pod to provide TLS termination for the Duo Workflow Service gRPC endpoint (port 50052). When enabled, the gRPC ingress routes external traffic through the proxy over TLS, making the Duo Agent Platform service accessible to GitLab without any manual post-upgrade patching.

**Traffic flow:**
```
GitLab → ingress:443 (GRPCS) → grpc-tls-proxy:8443 (TLS termination) → ai-gateway:50052 (plaintext gRPC)
```

### Prerequisites

1. `duoWorkflow.enabled` must be `true`
2. A TLS secret containing `tls.crt` and `tls.key`:

    ```shell
    kubectl create secret tls ai-gateway-tls \
      --cert=path/to/tls.crt \
      --key=path/to/tls.key \
      -n ai-gateway
    ```

### Enabling the gRPC TLS Proxy

```yaml
grpc-tls-proxy:
  enabled: true
  tlsSecretName: ai-gateway-tls
  upstream:
    host: ai-gateway  # must match your Helm release name
    port: 50052
```

The chart automatically sets the gRPC ingress `backend-protocol` to `GRPCS` when the proxy is enabled. No manual annotation override is required.

### Full Example

See [`examples/values-grpc-tls.yaml`](examples/values-grpc-tls.yaml) for a complete working configuration.

```shell
# Install with gRPC TLS proxy enabled
helm upgrade --install ai-gateway \
  ai-gateway/ai-gateway \
  --namespace=ai-gateway \
  --create-namespace \
  -f examples/values-grpc-tls.yaml
```

In GitLab admin settings, set the **Duo Agent Platform service URL** to:

```
ai-gateway.example.com:443
```

### GitLab Admin Configuration

Navigate to **Admin → GitLab Duo → Configuration** and set:

- **Local AI Gateway URL**: `https://ai-gateway.example.com`
- **Local URL for the GitLab Duo Agent Platform service**: `ai-gateway.example.com:443`

### Custom NGINX Configuration

Override the full NGINX config by providing a complete `nginx.conf`:

```yaml
grpc-tls-proxy:
  enabled: true
  tlsSecretName: ai-gateway-tls
  upstream:
    host: ai-gateway
    port: 50052
  nginxConfig: |
    events {
        worker_connections 2048;
    }
    http {
        upstream grpcservers {
            server ai-gateway:50052;
        }
        server {
            listen 8443 ssl;
            http2 on;
            ssl_certificate /etc/nginx/ssl/tls.crt;
            ssl_certificate_key /etc/nginx/ssl/tls.key;
            location / {
                grpc_pass grpc://grpcservers;
            }
        }
    }
```

> **Note:** `nginxConfig` must be a complete `nginx.conf`. The default config uses `http2 on;` which requires NGINX 1.25.1+ (`nginx:alpine` ships 1.27+).

### Advanced Configuration

```yaml
grpc-tls-proxy:
  enabled: true
  tlsSecretName: ai-gateway-tls
  upstream:
    host: ai-gateway
    port: 50052

  # Scale the proxy independently of the AI Gateway
  replicaCount: 2

  # Private registry support (GCR, ECR, ACR, etc.)
  imagePullSecrets:
    - name: my-registry-secret

  # Security contexts for PodSecurityAdmission-enforced clusters
  podSecurityContext:
    fsGroup: 101
  securityContext:
    runAsNonRoot: true
    runAsUser: 101
    allowPrivilegeEscalation: false
    capabilities:
      drop: [ALL]

  # Resource tuning
  resources:
    requests:
      cpu: 100m
      memory: 64Mi
    limits:
      cpu: 200m
      memory: 128Mi

  # Service type — ClusterIP is correct when using an ingress controller.
  # Set to LoadBalancer if exposing the proxy port directly without ingress
  # and add cloud-specific annotations as needed.
  service:
    type: ClusterIP
    annotations: {}
    # AWS NLB:
    #   service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    # GCP internal LB:
    #   cloud.google.com/load-balancer-type: "Internal"
```

## Custom Sidecars

For advanced use cases, you can add custom sidecar containers to the AI Gateway pod:

```yaml
sidecars:
  - name: custom-sidecar
    image: my-custom-image:latest
    ports:
      - containerPort: 9090
    volumeMounts:
      - name: custom-volume
        mountPath: /data
```

