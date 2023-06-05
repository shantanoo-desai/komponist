# Caveats

## Compose v1 vs. Compose v2

Komponist relies on Docker Compose V2 (written in golang) as opposed to the Docker Compose V1
(which was written in python). 

> Since Compose v1 is bound to be Deprecated in June 2023, the current way 
> to use `docker compose` is through `ansible.builtin.shell` module as opposed to through the 
> `community.docker.docker_compose` module which relies on python module. 

There is some traction on [`community.docker` collection to integrate Docker Compose V2][2]. If it gets 
integrated the possible `ansible.builtin.shell` module might be replaced with the respective module in the
future.

## Generated Paths on Controller Node

Komponist will resolve the relative paths e.g., `./` to absolute path on the machine where Komponist is executed.
This implies that the `docker-compose.yml` deployed on a remote machine must also have the same paths to the configuration
file as that on the controller node (where Komponist is executed).

This caveat may be mitigated if one uses a well-known directories like `/usr/share/` or `/etc/` because these paths are
reflected similarly on the Controller as well as Remote machines

## QuestDB / InfluxDBv2 UI rendering

Since QuestDB / InfluxDBv2's UI does not provide any configuration to render the UI behind a root path, it is not possible to render
the UI under `/influxdbv2` or `/questdb` path. At the moment, it is only possible to view the UI when visiting the following links:

    http://influxdbv2.localhost

OR

    http://questdb.localhost

[2]: https://github.com/ansible-collections/community.docker/pull/586
