# komponist
A _Composer_ for Docker Compose v2 Applications powered by Jinja2 + Ansible + Docker Compose v2.
Komponist aims to reduce the effort of creating lengthy [Docker Compose V2][0] powered stacks of popular
open-source containers. Komponist brings the much needed logic of templating into Docker Compose applications.

## Requirements

Komponist relies on the _Shoulder of Giants_ to achieve a lot of configuration / templating
abstraction. The following are required to make Komponist work:

### OS Packages

| Name       | Version    | Purpose                                                           |
|:-----------|:----------:|:-----------------------------------------------------------------:|
| `docker`   | `24.0.x`   | Container Runtime where your compose stacks will run              |
| `docker compose` | `2.18.1` | Docker Compose V2 Plugin for Docker Engine                    |

Install them on your host accordingly. See [Docker Documentations][1]

### Python Pip Packages

| Name      | Version | Purpose                                                                      |
|:----------|:-------:|:----------------------------------------------------------------------------:|
| `ansible`  | `> 2.14.x` | Almost _all_ things within Komponist are achieved via ansible            |
| `passlib` | `1.7.x` | required for password encryption hashing requirements for certain containers |
| `docker`  | `>5.x.x`| required to control single container instances                               | 

Install these packages via:

```bash
pip install --user -r requirements.txt
```

## Quickstart / Usage

Currently the following services are available to configure and run:

| Service Name                       | Version |
|:----------------------------------:|:-------:|
| __Node-RED__                       | `3.0.1` |
| __Mosquitto MQTT Broker__          | `2.0.15`|
| __Traefik Reverse-Proxy__          | `2.9.8` |
| __InfluxDB__                       | `1.8`<br> `2.6`|
| __TimescaleDB__                    | `v15`   |
| __Grafana__                        | `9.5.1` |
| __QuestDB__                        | `7.1.1` |


### Complete Komponist Stack

A complete stack with all the mentioned services above can be configured using:

```bash
ansible-playbook generate_stack.yml
```

This will generate all the respective configuration files and Docker Compose services
files in the `deploy` directory in the root of the repository

### Custom Komponist Stack

It is possible to generate the `config.yml` / `creds.yml` template files using a 
Terminal User-Interface (TUI).

1. create an `examples/custom_stack` directory:

    ```bash
    mkdir -p examples/custom_stack
    ```
2. use `komponist-tui` Docker Container to select and generate the configuration YAML files:

    ```bash
    docker run -it --rm \
        -v ./examples/custom_stack:/home/komponist \
        ghcr.io/shantanoo-desai/komponist-tui:main
    ```

3. select and fill out the prompts in the TUI which will generate a `config.yml` / `creds.yml` in
  `examples/custom_stack` directory

4. fill in the placeholder values in `examples/custom_stack/creds.yml` with your credentials

5. (OPTIONAL) encrypt the `creds.yml` using:

    ```bash
    ansible-vault encrypt examples/custom_stack/creds.yml
    ```

    enter a vault password and this will encrypt credentials

6. Bring the custom stack up:

    ```bash
    ansible-playbook -e "@examples/custom_stack/config.yml" \
        -e "@examples/custom_stack/creds.yml" \
        --ask-vault-pass \
        generate_stack.yml
    ```
    The `--ask-vault-pass` is required only if the credentials file is encrypted
    using Step 5

### Bringing the Stack Up

You can bring the stack up using:

```bash
docker compose --project-directory=deploy up -d
```

### Service Endpoints

The following service names can be used to obtain log information using:

```bash
docker compose --project-directory=deploy logs -f <service_name>
```

| Service Name | URL                           |
|:------------:|:-----------------------------:|
| `nodered`    | `http://localhost/nodered`    |
| `mosquito`   | `mqtt://localhost:1883`       |
| `traefik`    |  N/A                          |
| `influxdvb1` | `http://localhost/influxdbv1` |
| `influxdbv2` | `http://influxdbv2.localhost` |
| `timescaledb` | Not Configured to an API     |
| `grafana`    | `http://localhost/grafana`    |
| `questdb`    | `http://questdb.localhost`    |


## Contributing / Development

Contributions are welcome for additional services by opening feature requests as Issues. Please report
bugs, erroneous behaviours as Issues.

If you would like to add your own Services / containers to Komponist, refer to the
[Development Workflow Guide (WIP)][2].

## Licensing

Komponist is licensed under __Affero GNU Public License v3.0__.

[0]: https://docs.docker.com/compose/compose-v2/
[1]: https://docs.docker.com/get-docker/
[2]: docs/Development.md
