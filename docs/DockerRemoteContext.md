# Deployment using Docker Context with Compose

By creating [Contexts][1] to remote devices, the stack can be deployed to remote machines without having to copy the generated
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

[1]: https://www.docker.com/blog/how-to-deploy-on-remote-docker-hosts-with-docker-compose/
