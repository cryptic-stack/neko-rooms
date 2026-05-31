# HackLab DFIR-IRIS Image

This image wraps the official DFIR-IRIS Docker Compose deployment in a single HackLab-selectable lab image.

```powershell
.\scripts\publish-lab-images.ps1 -Images dfir-iris
```

DFIR-IRIS is not a single upstream container. The project documents IRIS as a Docker Compose deployment split across five services: app, db, RabbitMQ, worker, and nginx. This wrapper runs Docker-in-Docker, starts those official services internally, and exposes the nginx HTTPS endpoint on port `443`.

Default login:

- Username: `administrator`
- Password: `ihacknebraska`

Override the default admin fields with environment variables if needed:

- `IRIS_ADM_USERNAME`
- `IRIS_ADM_PASSWORD`
- `IRIS_ADM_EMAIL`

The wrapper uses `ghcr.io/dfir-iris/iriswebapp_*:v2.4.27` by default and can be tuned with `IRIS_VERSION`.

## Runtime requirements

This image requires privileged mode because it runs Docker-in-Docker. The default HackLab Compose file whitelists `crypticstack/ihacknebraska:dfir-iris` for privileged launches.

The first start pulls the official IRIS service images inside the lab container, so it can take a few minutes.
