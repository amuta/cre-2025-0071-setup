# File: redis-oom-repro/README.md
# Redis High-Severity Failure Reproduction: OOM with `noeviction`

This project reproduces a high-severity Redis failure where Redis runs out of memory (`maxmemory` limit reached) and, due to the `noeviction` policy, starts rejecting write commands.

## Description of Failure

Redis is configured with a `--maxmemory` limit of 10MB and a `--maxmemory-policy` of `noeviction`. When data is written to Redis exceeding this limit, new write commands are rejected with an "(error) OOM command not allowed when used memory > 'maxmemory'" error. This can lead to application failures if not handled correctly.

## Prerequisites

* Docker
* Docker Compose
* `redis-cli` (can be installed locally or you can use `docker exec -it <container_name> redis-cli`)

## Setup and Reproduction Steps

1.  **Clone this repository or create the files:**
    * `docker-compose.yml`
    * `force_memory.sh`
    * `README.md` (this file)

2.  **Ensure `force_memory.sh` is executable:**
    ```bash
    chmod +x force_memory.sh
    ```

3.  **Start the Redis container:**
    Open your terminal in the project directory (`redis-oom-repro/`) and run:
    ```bash
    docker-compose up -d
    ```
    Wait a few seconds for Redis to initialize. You can check the status with `docker-compose ps`.

4.  **Run the reproduction script:**
    This script will attempt to write data to Redis until the OOM error is triggered. Its output, including the error and Redis memory information, will be saved to `test.log`.
    ```bash
    ./force_memory.sh > test.log 2>&1
    ```

5.  **Observe the failure:**
    Inspect the generated `test.log`. You should see output similar to:
    ```
    Attempting to force Redis OOM...
    OK
    (error) OOM command not allowed when used memory > 'maxmemory'. script: ..., on @user_script:1.
    # Memory
    used_memory_human:10.02M 
    maxmemory_human:10.00M
    maxmemory_policy:noeviction
    ...
    Script finished. Check output for OOM errors.
    ```
    The key line is `(error) OOM command not allowed when used memory > 'maxmemory'`.

6.  **Check Redis Server Logs (Optional):**
    To see the server-side perspective, you can view the Redis container's logs:
    ```bash
    docker-compose logs redis 
    ```
    (Or `docker logs <container_id_or_name>` if you prefer)
    With `loglevel verbose`, you might see entries related to memory limits or command processing.

## Deliverables

* **Reproduction Setup:** The files in this directory (`docker-compose.yml`, `force_memory.sh`).
* **Example Logs:** See `test.log` for the captured output demonstrating the failure.
* **Detection Rule (CRE Playground Link):**
    [Link to your rule in the CRE playground will go here] 
    *(Example idea for detection: Look for "OOM command not allowed" messages in logs, or monitor if `used_memory` consistently equals `maxmemory` with `noeviction` policy and `rejected_commands` count increases).*

## Cleanup

To stop and remove the Redis container and associated volume:
```bash
docker-compose down -v# cre-2025-0070-setup
