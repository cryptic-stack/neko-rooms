# HackLab

<p align="center">
  <img src="https://img.shields.io/github/v/release/m1k1o/neko-rooms" alt="release">
  <img src="https://img.shields.io/github/license/m1k1o/neko-rooms" alt="license">
  <img src="https://img.shields.io/docker/pulls/m1k1o/neko-rooms" alt="pulls">
  <img src="https://img.shields.io/github/issues/m1k1o/neko-rooms" alt="issues">
  <a href="https://discord.gg/3U6hWpC" ><img src="https://discordapp.com/api/guilds/665851821906067466/widget.png" alt="Chat on discord"></a>
</p>

Hands-on hacking labs for iHack Nebraska and Hack Your School Club. HackLab gives instructors and club mentors a simple way to launch shared browser and desktop environments for workshops, cybersecurity lessons, and coding activities.

<div align="center">
  <img src="https://github.com/m1k1o/neko-rooms/raw/master/docs/rooms.png" alt="rooms">
  <img src="https://github.com/m1k1o/neko-rooms/raw/master/docs/new_room.png" alt="new lab">
  <img src="https://github.com/m1k1o/neko-rooms/raw/master/docs/neko.gif" alt="learning lab preview">
</div>

## Zero-knowledge installation (with HTTPS)

No experience with Docker and reverse proxy? No problem! Follow these steps to set up HackLab quickly and securely:

- Rent a VPS with public IP and OS Ubuntu.
- Get a domain name pointing to your IP (you can even get some for free).
- Run install script and follow instructions.
- Secure using HTTPs thanks to Let's Encrypt and Traefik or NGINX.

```bash
wget -O neko-rooms-traefik.sh https://raw.githubusercontent.com/m1k1o/neko-rooms/master/traefik/install
sudo bash neko-rooms-traefik.sh
```

### Community Installation Scripts

We have community-contributed installation scripts available. Check out our [community installation guides](./community/README.md) for instructions on installing HackLab on various Linux distributions. These scripts are maintained by the community and support different Linux distributions like Arch Linux, Fedora, and more.

## How to start

If you want to use Traefik as reverse proxy, visit [installation guide for traefik as reverse proxy](./traefik/).

Otherwise modify variables in `docker-compose.yml` and just run `docker-compose up -d`.

### Download images / update

You need to pull all lab images you want to use. Otherwise, you might get this error: `Error response from daemon: No such image:` (see issue #1).

```sh
docker pull crypticstack/ihacknebraska:xfce
docker pull crypticstack/ihacknebraska:kali
docker pull crypticstack/ihacknebraska:firefox
docker pull crypticstack/ihacknebraska:chromium
docker pull crypticstack/ihacknebraska:windows
```

By default, HackLab loads lab images from Docker Hub using:

```sh
crypticstack/ihacknebraska:xfce
crypticstack/ihacknebraska:kali
crypticstack/ihacknebraska:firefox
crypticstack/ihacknebraska:chromium
crypticstack/ihacknebraska:windows
```

To build and publish all default lab images:

```powershell
.\scripts\publish-lab-images.ps1
```

To publish a single image to a different Docker Hub namespace:

```powershell
.\scripts\publish-lab-images.ps1 -Repository your-dockerhub-org/your-lab-image -Images xfce
```

### Windows labs

HackLab includes a Windows lab image wrapper at `lab-images/windows`, based on [`dockurr/windows`](https://github.com/dockur/windows). Dockur Windows uses a web viewer on port `8006`, KVM acceleration, and persistent VM storage. The HackLab image labels its viewer port so room URLs proxy correctly.

Windows rooms need `/dev/kvm`, `/dev/net/tun`, and privileged mode or `NET_ADMIN`. The default `docker-compose.yml` whitelists `crypticstack/ihacknebraska:windows` for privileged room launches. When creating a Windows room, add private storage mounted to `/storage` and add the required devices in expert settings.

Make sure Docker Desktop is logged in to an account with push access before publishing:

```sh
docker login
```

You can override the default lab image list in `docker-compose.yml` with `HACKLAB_LAB_IMAGES`:

```sh
HACKLAB_LAB_IMAGES="crypticstack/ihacknebraska:xfce crypticstack/ihacknebraska:kali"
```

If you want to update a lab image, pull the new image and recreate all labs that use the old image. To update HackLab itself, run:

```sh
docker-compose pull
docker-compose up -d
```

### Enable storage

You might have encountered this error:

> Mounts cannot be specified because storage is disabled or unavailable.

If you didn't specify storage yet, you can do it using [this tutorial](./docs/storage.md).

### Use nvidia GPU

If you want to use nvidia GPU, you need to install [nvidia-docker](https://github.com/NVIDIA/nvidia-docker).

Change lab images to nvidia images in `docker-compose.yml` using environment variable `NEKO_ROOMS_NEKO_IMAGES`:

```bash
NEKO_ROOMS_NEKO_IMAGES="
  ghcr.io/m1k1o/neko/nvidia-chromium:latest
  ghcr.io/m1k1o/neko/nvidia-google-chrome:latest
  ghcr.io/m1k1o/neko/nvidia-microsoft-edge:latest
  ghcr.io/m1k1o/neko/nvidia-brave:latest
"
```

When creating a new lab, enable GPU support in expert settings.

### Docs

For more information visit [docs](./docs).

### Roadmap:
 - [x] add GUI
 - [x] add HTTPS support
 - [x] add authentication provider for traefik
 - [x] allow specifying custom ENV variables
 - [x] allow mounting directories for persistent data
 - [x] optionally remove Traefik as dependency
 - [ ] add upgrade button
 - [ ] auto pull images, that do not exist
 - [ ] add bearer token to for API
 - [ ] add docker SSH / TCP support
 - [ ] add docker swarm support
 - [ ] add k8s support
