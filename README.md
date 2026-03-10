# Teknoir Keycloak Theme

A custom Keycloak login theme featuring the Teknoir brand identity with proper typography (Proxima Nova), brand colors, and logo. The theme is packaged as a Docker image extending the official Keycloak image, ready for deployment with the [codecentric keycloakx Helm chart](https://github.com/codecentric/helm-charts/tree/master/charts/keycloakx).

---

## Repository Structure

```
keycloak-theme/
├── Dockerfile                          # Custom Keycloak image with theme
├── scripts/
│   └── build.sh                        # Build script with configurable options
├── themes/
│   └── teknoir-theme/
│       └── login/
│           ├── theme.properties        # Theme configuration
│           ├── login.ftl               # Login page template
│           └── resources/
│               ├── css/
│               │   └── login.css       # Teknoir-branded styles
│               ├── fonts/              # Proxima Nova font files
│               └── img/                # Teknoir logo and favicons
├── resources/                          # Source assets (fonts, logos, icons)
└── example-realm.json                  # Example realm configuration with theme
```

---

## Building the Image

### Using the build script

The included build script supports configurable options:

```bash
# Build and push to default registry
./scripts/build.sh

# Build with custom Keycloak version
KEYCLOAK_VERSION=27.0.0 ./scripts/build.sh

# Build locally without pushing
PUSH=false ./scripts/build.sh

# Custom image name and tag
IMAGE=my-registry/keycloak-themed \
BRANCH_NAME=main \
SHORT_SHA=v1.0.0 \
./scripts/build.sh
```

### Manual build

```bash
# Build with default Keycloak version (26.5.3)
docker build -t <REGISTRY>/keycloak-themed:latest .

# Build with custom Keycloak version
docker build \
  --build-arg KEYCLOAK_VERSION=27.0.0 \
  -t <REGISTRY>/keycloak-themed:27.0.0 \
  .

# Push to registry
docker push <REGISTRY>/keycloak-themed:latest
```

---

## Deploying with keycloakx Helm Chart

### Add the codecentric Helm repository

```bash
helm repo add codecentric https://codecentric.github.io/helm-charts
helm repo update
```

### Deploy with custom image

```bash
helm upgrade --install keycloak codecentric/keycloakx \
  --namespace keycloak \
  --create-namespace \
  --set image.repository=<REGISTRY>/keycloak-themed \
  --set image.tag=latest
```

### Using a values file

Create a `values.yaml`:

```yaml
image:
  repository: <REGISTRY>/keycloak-themed
  tag: latest
  pullPolicy: IfNotPresent

replicas: 1

database:
  vendor: postgres
  hostname: postgresql
  port: 5432
  database: keycloak
  username: keycloak
  existingSecret: keycloak-db-secret
  existingSecretKey: password

http:
  relativePath: "/"

extraEnv: |
  - name: KC_BOOTSTRAP_ADMIN_USERNAME
    valueFrom:
      secretKeyRef:
        name: keycloak-admin-secret
        key: username
  - name: KC_BOOTSTRAP_ADMIN_PASSWORD
    valueFrom:
      secretKeyRef:
        name: keycloak-admin-secret
        key: password
  - name: KEYCLOAK_ADMIN
    valueFrom:
      secretKeyRef:
        name: keycloak-admin-secret
        key: username
  - name: KEYCLOAK_ADMIN_PASSWORD
    valueFrom:
      secretKeyRef:
        name: keycloak-admin-secret
        key: password
```

Then deploy:

```bash
helm upgrade --install keycloak codecentric/keycloakx \
  --namespace keycloak \
  --create-namespace \
  --values values.yaml
```

### Configuring the Theme

Once deployed, the `teknoir-theme` will be available in Keycloak. You can activate it in several ways:

#### Option 1: Via Admin Console (Manual)

1. Log into Keycloak Admin Console
2. Select your realm
3. Navigate to **Realm Settings → Themes**
4. Set **Login theme** to `teknoir-theme`
5. Click **Save**

#### Option 2: Via Realm Import (Recommended)

Create or modify your realm configuration JSON to include the theme setting:

```json
{
  "realm": "your-realm",
  "loginTheme": "teknoir-theme",
  "enabled": true,
  ...
}
```

See `example-realm.json` in this repository for a complete example with the Teknoir theme pre-configured.

#### Option 3: Import via Helm Chart

You can provide the realm configuration as a ConfigMap and use Keycloak's import feature:

```yaml
# In your keycloakx values.yaml
extraInitContainers: |
  - name: realm-import
    image: busybox
    command:
      - sh
    args:
      - -c
      - |
        cp /realm-config/*.json /opt/keycloak/data/import/
    volumeMounts:
      - name: realm-config
        mountPath: /realm-config
      - name: realm-import
        mountPath: /opt/keycloak/data/import

extraVolumeMounts: |
  - name: realm-import
    mountPath: /opt/keycloak/data/import

extraVolumes: |
  - name: realm-config
    configMap:
      name: keycloak-realm-config
  - name: realm-import
    emptyDir: {}

command:
  - "/opt/keycloak/bin/kc.sh"
  - "start"
  - "--import-realm"
```

Create the ConfigMap:

```bash
kubectl create configmap keycloak-realm-config \
  --from-file=realm.json=example-realm.json \
  -n keycloak
```

#### Option 4: Environment Variable (Simple Method)

For new realms, you can set the default theme via environment variable:

```yaml
# In your keycloakx values.yaml
extraEnv: |
  - name: KC_SPI_THEME_DEFAULT
    value: "teknoir-theme"
```

Note: This sets the default for new realms but won't affect existing ones.

---

## Theme Details

### Design System

The theme implements the Teknoir design standard with:

- **Typography**: Proxima Nova font family (Regular, Medium, Semibold with italic variants)
- **Brand Colors**:
  - Off White: `#E0DED9` (text)
  - Ocean Blue: `#3B61BF` (primary actions)
  - Outrun Orange: `#ED6D36` (accents/errors)
  - Horizon Yellow: `#E0AD1B` (warnings)
  - Pale Tree Purple: `#9B357D`
- **Logo**: Teknoir full logo with trademark
- **Dark Theme**: Modern dark background with proper contrast

### File Structure

| File | Purpose |
|---|---|
| `theme.properties` | Theme configuration extending base Keycloak theme |
| `login.ftl` | Login page template with Teknoir branding |
| `login.css` | Complete theme styles with CSS custom properties |
| `resources/fonts/` | Proxima Nova font files (woff, woff2) |
| `resources/img/` | Teknoir logo (SVG) and favicon files |

---

## Build Script Options

The `scripts/build.sh` supports these environment variables:

| Variable | Default | Description |
|---|---|---|
| `KEYCLOAK_VERSION` | `26.5.3` | Base Keycloak version to use |
| `IMAGE` | `us-docker.pkg.dev/teknoir/gcr.io/keycloak-themed` | Image name |
| `BRANCH_NAME` | `local` | Branch/environment name for tagging |
| `SHORT_SHA` | Current timestamp | Short SHA or version for tagging |
| `PLATFORM` | `linux/amd64` | Target platform(s) |
| `PUSH` | `true` | Push to registry (`false` for local builds) |

---

## Development

### Theme Customization

1. Modify theme files in `themes/teknoir-theme/login/`
2. Rebuild the Docker image
3. Deploy to test environment
4. Verify changes in Keycloak login page

### Testing Locally

```bash
# Build without pushing
PUSH=false ./scripts/build.sh

# Run locally with docker-compose or kind
docker run -p 8080:8080 \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  <REGISTRY>/keycloak-themed:latest \
  start-dev
```

Access Keycloak at http://localhost:8080 and configure a realm to use `teknoir-theme`.

---

## License

Custom theme for Teknoir. Keycloak is licensed under Apache License 2.0.
