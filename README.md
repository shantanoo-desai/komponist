# komponist
A _Composer_ for Docker Compose v2 Applications powered by Jinja2 + Ansible + Docker Compose v2.
Komponist aims to reduce the effort of creating lengthy [Docker Compose V2][1] powered stacks of popular
open-source containers.

_Why? you might ask._ Well why do manual work of developing configuration files when tools can automate
their creation for you. Komponist brings the much needed logic of templating into Docker Compose applications.

## Requirements

Komponist relies on the _Shoulder of Giants_ to achieve a lot of configuration abstraction. The following are 
required to make Komponist work:

| Name       | Version    | Purpose                                                           |
|:-----------|:----------:|:-----------------------------------------------------------------:|
| `ansible`  | `> 2.14.x` | Almost _all_ things within Komponist are achieved via ansible     |
| `docker`   | `23.0.x`   | Container Runtime where your compose stacks will run              |
| `docker compose` | `2.16.0` | Docker Compose V2 Plugin for Docker Engine                    |

Make sure to install them on your host accordingly.

### Python Pip Packages

| Name      | Version | Purpose                                                                      |
|:----------|:-------:|:----------------------------------------------------------------------------:|
| `passlib` | `1.7.x` | required for password encryption hashing requirements for certain containers |
| `docker`  | `>5.x.x`| required to control single container instances                               | 

Make sure to install these packages via `pip install <package>` on your host accordingly.

## Caveats

### Compose v1 vs. Compose v2

Komponist relies on [Docker Compose V2][1] (written in golang) as opposed to the Docker Compose V1
(which was written in python). 

> Since Compose v1 is bound to be Deprecated in June 2023, the current way 
> to use `docker compose` is through `ansible.builtin.shell` module as opposed to through the 
> `community.docker.docker_compose` module which relies on python module. 

There is some traction on [`community.docker` collection to integrate Docker Compose V2][2]. If it gets 
integrated the possible `ansible.builtin.shell` module might be replaced with the respective module in the
future.

### Generated Paths on Controller Node

Komponist will resolve the relative paths e.g., `./` to absolute path on the machine where Komponist is executed.
This implies that the `docker-compose.yml` deployed on a remote machine must also have the same paths to the configuration
file as that on the controller node (where Komponist is executed).

This caveat may be mitigated if one uses a well-known directories like `/usr/share/` or `/etc/` because these paths are
reflected similarly on the Controller as well as Remote machines

### QuestDB / InfluxDBv2 UI rendering

Since QuestDB / InfluxDBv2's UI does not provide any configuration to render the UI behind a root path, it is not possible to render
the UI under `/influxdbv2` or `/questdb` path. At the moment, it is only possible to view the UI when visiting the following links:

    http://influxdbv2.localhost

OR

    http://questdb.localhost

## Usage

Komponist relies on two core configuration files:

- `vars/config.yml`: contains the necessary parameters to configure the komponist project and the respective containers 
- `vars/creds.yml` : contains the credentials needed for the containers

Configure the files according to requirements and generate the respective configurations + a deployment-ready `docker-compose.yml`
using:

```bash
ansible-playbook generate_stack.yml
```
This should create a directory called `deploy` (or depending on how you configure `deploy_dir` in `vars/config.yml`) with the 
configuration / settings / credentials files along with the respective `docker-compose.<service>.yml` files and a __validated__
`docker-compose.yml`.

### Deployment using Docker Context with Compose

By creating [Contexts][3] to remote devices, the stack can be deployed to remote machines without having to copy the generated
`docker-compose.yml` file to them.

1. Create an SSH Docker Context using:

    ```bash
    docker context create <name_of_context> --docker "host=ssh://<user>@<remote-machine_ip or hostname>
    ```
2. Copy the generated configurations to the remote machine (see __Caveats__ above in order to avoid filesystem mismatch errors).
No need to copy the `docker-compose.yml` file

3. Deploy the Compose application using:

    ```bash
    docker --context=<name_of_context_from_above> compose --project-directory=deploy up -d
    ```

### Security: Encrypting Credentials (Recommended)

If you want to encrypt credentials (`creds.yml`) file using `ansible-vault` perform:

```bash
ansible-vault encrypt vars/creds.yml
```
enter a vault password for the encryption process and use the playbook `generate_stack.yml` using:

```bash
ansible-playbook generate_stack.yml --ask-vault-pass
```
enter your vault password for the decryption to occur and Komponist does the rest for you!

## Services

Currently the following services are available / planned to configure and run:

| Service Name                       | Version |
|:----------------------------------:|:-------:|
| __Node-RED__                       | `3.0.1` |
| __Mosquitto MQTT Broker__          | `2.0.15`|
| __Traefik Reverse-Proxy__          | `2.9.8` |
| __InfluxDB__                       | `1.8`<br> `2.6`|
| __TimescaleDB__                    | `v15`   |
| __Grafana__                        | `9.5.1` |
| __QuestDB__                        | `7.1.1` |

## Contributing / Development

Contributions are welcome for additional services by opening feature requests as Issues. Please report
bugs, erroneous behaviours as Issues.

If you would like to add your own Services / containers to Komponist, refer to the [Development Workflow Guide][4].

## Licensing

Komponist is licensed under __Affero GNU Public License v3.0__.

[1]: https://docs.docker.com/compose/compose-v2/
[2]: https://github.com/ansible-collections/community.docker/pull/586
[3]: https://www.docker.com/blog/how-to-deploy-on-remote-docker-hosts-with-docker-compose/
[4]: docs/Development.md
