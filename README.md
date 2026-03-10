# keycloak-theme

A custom Keycloak login theme (`teknoir-theme`) with a modern dark UI, packaged in a custom Docker image and deployed to Kubernetes via a local Helm chart that wraps the [codecentric keycloakx](https://github.com/codecentric/helm-charts/tree/master/charts/keycloakx) sub-chart.

---

## Repository layout

```
keycloak-theme/
├── Dockerfile                          # Builds the custom Keycloak image
├── themes/
│   └── teknoir-theme/
│       └── login/
│           ├── theme.properties        # Extends the built-in "keycloak" theme
│           ├── login.ftl               # FreeMarker login page template
│           └── resources/
│               └── css/
│                   └── login.css       # Modern dark-mode styles
└── charts/
    └── stage-7-auth/
        ├── Chart.yaml                  # Helm chart metadata + keycloakx dependency
        ├── values.yaml                 # Values that point to the custom image
        └── realm.json                  # Realm import JSON (sets loginTheme)
```

---

## 1. Build & push the Docker image

```bash
# Build
docker build -t <REGISTRY>/teknoir-keycloak:26.5.3 .

# Push
docker push <REGISTRY>/teknoir-keycloak:26.5.3
```

Replace `<REGISTRY>` with your actual container registry path, e.g.
`europe-docker.pkg.dev/my-project/keycloak`.

---

## 2. Helm deployment

### 2a. Create the realm ConfigMap

```bash
kubectl create configmap keycloak-realm-config \
  --from-file=teknoir-realm.json=charts/stage-7-auth/realm.json \
  -n <namespace>
```

### 2b. Create the admin-credentials Secret

```bash
kubectl create secret generic keycloak-admin-credentials \
  --from-literal=KC_BOOTSTRAP_ADMIN_USERNAME=admin \
  --from-literal=KC_BOOTSTRAP_ADMIN_PASSWORD=<secure-password> \
  -n <namespace>
```

### 2c. Install / upgrade the Helm chart

```bash
# Fetch dependencies (only needed on first run or after Chart.yaml changes)
helm dependency update charts/stage-7-auth

# Install
helm upgrade --install stage-7-auth charts/stage-7-auth \
  --namespace <namespace> \
  --create-namespace \
  --set keycloakx.image.repository=<REGISTRY>/teknoir-keycloak \
  --set keycloakx.image.tag=26.5.3
```

---

## 3. Istio VirtualService

The chart itself does not create an Istio `VirtualService`. Apply one separately, for example:

```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: keycloak
  namespace: <namespace>
spec:
  hosts:
    - auth.example.com
  gateways:
    - istio-system/ingressgateway
  http:
    - route:
        - destination:
            host: stage-7-auth-keycloakx
            port:
              number: 80
```

---

## 4. Theme details

| File | Purpose |
|---|---|
| `theme.properties` | Declares the theme parent (`keycloak`) and registers the custom CSS |
| `login.ftl` | Full FreeMarker login page (username/password, remember-me, social IdP list) |
| `login.css` | Dark-mode design using CSS custom properties (`--tn-*`) |

The theme automatically appears in the Keycloak Admin Console under
**Realm Settings → Themes → Login theme** as `teknoir-theme`, or it is set
automatically on first startup via the realm import JSON in `charts/stage-7-auth/realm.json`.
