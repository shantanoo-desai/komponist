# Development Workflow Guide

This document provides a guide to integrate new services / containers into Komponist. Since this is more 
Configuration and less Programming, it is worth following these steps to make the development and integration of
these services / containers more _seamless_

## Configuration / Credentials Definition

Start by defining your service's configuration requirements in `vars/config.yml` (see other services for reference).
Try to keep more fine-tuning configuration to boolean.

Define the respective credentials for the services in `vars/creds.yml` (see other services for reference).
Depending on how they need to be applied i.e., in a configuration file template or in a dedicated environment variables file
depends on the container requirement.

When the container needs to be configured via some environment variables one can do so directly in to the respective
`docker-compose.<service>.yml.j2` and generated a dedicated `<service>/<service>.env` which contains all the necessary 
credentials. This structure keeps credentials separate before the merging of the Compose files.

## Templates

### Configuration Files

Create a dedicated directory under `templates/config/<service>` with your Jinja2 Template that use variables from the 
`vars/config.yml` and `vars/creds.yml`.

### Docker Compose Service Files

Create a Jinja2 template called `docker-compose.<service>.yml.j2` under `templates/services` that use the variables from 
`vars/config.yml`

## Traefik Reverse-Proxy Files

Under [../templates/config/traefik/configurations] directory exists a the following directories and the `dynamic.yml.j2` file:

```bash
../templates/config/traefik/configurations
├── dynamic.yml.j2
├── middlewares-http
├── routers-http
├── routers-tcp
├── services-http
└── services-tcp
```

Depending on the service to be introduced (either HTTP or TCP), add __ONLY the YAML Snippet__ of the router, middleware, and 
service into the `routers-{http/tcp}`, `middlewares-{http,tcp}`, `services-{http,tcp}` respectively.

Depending on conditions from `vars/config.yml` file use the `include` Jinja2 filter and include the respective files into the 
`dynamic.yml.y2` file.

## Ansible Tasks file for Service

Create an Ansible Tasks file under `tasks/configure-<service>.yml` which converts the templates to dedicated configuration files
under the `deploy_dir/<service>` directory.
