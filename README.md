# traefik.yml

```yml
entryPoints:
  web:
    address: ":80"
  websecure:
    address: ":443"

certificatesResolvers:
  myresolver:
    acme:
      email: mimach.dev@gmail.com
      storage: acme.json
      httpChallenge:
        entryPoint: web

#api:
 # dashboard: true

providers:
  docker:
    exposedByDefault: false

```



# docker compose
```yml
services:
  reverse-proxy:
    image: traefik:v3.1
    ports:
      - "80:80"
      - "443:443"
      - "8080:8080"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./traefik.yml:/etc/traefik/traefik.yml
      #- ./traefik_dynamic.yml:/etc/traefik/traefik_dynamic.yml:ro

    command:
      - --configFile=/etc/traefik/traefik.yml
      #- --entrypoints.http.address=:80
      #- --providers.docker.exposedByDefault=false
      #- --log.level=DEBUG
      #- --api=true
      #- --api.dashboard=true
      #- --privoders.docker.network=traefik
    #labels:
      #traefik.enable: 'true'
      #traefik.http.routers.reverse-proxy.entrypoints: http
      #traefik.http.routers.reverse-proxy.rule: Host(`traefik.trouvetatable.fr`)
      #traefik.http.routers.reverse-proxy.service: api@internal
      #traefik.http.middlewares.traefik-dashboard-auth.basicauth.users: karl:{SHA}W6ph5Mm5Pz8GgiULbPgzG37mj9g=
      #traefik.http.routers.reverse-proxy.middlewares: traefik-dashboard-auth
    networks:
      - traefik

networks:
  traefik:
    external: true
```
