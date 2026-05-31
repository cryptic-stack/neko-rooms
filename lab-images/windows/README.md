# HackLab Windows Image

This image wraps `dockurr/windows` so HackLab can publish a branded Windows lab tag:

```powershell
.\scripts\publish-lab-images.ps1 -Images windows
```

The container runs Dockur's Windows VM web viewer on port `8006`; the Dockerfile labels that port so HackLab proxies the room URL correctly.

By default this image installs Windows 10 Pro with a 30 GB disk, 4 GB RAM, and 2 CPU cores.

## Runtime requirements

Dockur Windows needs VM support from the Docker host:

- `/dev/kvm`
- `/dev/net/tun`
- `NET_ADMIN` capability, or privileged mode
- Persistent storage mounted at `/storage`

For HackLab rooms, add the devices in expert settings:

```json
{
  "resources": {
    "devices": ["/dev/kvm", "/dev/net/tun"]
  },
  "mounts": [
    {
      "type": "private",
      "host_path": "/windows",
      "container_path": "/storage"
    }
  ]
}
```

Enable privileged mode for the published image tag in the HackLab server config:

```yaml
NEKO_ROOMS_NEKO_PRIVILEGED_IMAGES=crypticstack/ihacknebraska:windows
```

You can tune the VM with standard Dockur environment variables such as `VERSION`, `RAM_SIZE`, `CPU_CORES`, and `DISK_SIZE`.
