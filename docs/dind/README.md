# dind: Docker in Docker

HackLab manages lab containers in docker and routes them using traefik. This is whole implementation put inside docker, that runs in docker. It is additional layer of security, but still not perfect (because dind requires `--privileged`).

This overhead of putting docker in docker can have negative impact on the usability, therefore users are encouraged to **not deploy HackLab using dind** method.

However, there are some usecases, when this might come in handy:
 - just testing out HackLab
 - absolutely needed additional security layer
 - developing HackLab

## Pull images

In order to pull new lab images run:

```sh
docker-compose exec neko-rooms docker pull crypticstack/ihacknebraska:latest
```
