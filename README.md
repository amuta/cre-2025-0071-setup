# Redis OOM Failure: Write Rejection due to 'maxmemory'

This project demonstrates a high-severity Redis failure where the server reaches its `maxmemory` limit and, due to its effective memory policy (typically 'noeviction' by default when `maxmemory` is set), starts rejecting write commands.

## Description of Failure

When Redis is configured with a `maxmemory` limit and its active memory policy prevents key eviction, any new commands attempting to write data that would exceed this limit will fail. The Redis server sends an "(error) OOM command not allowed when used memory > 'maxmemory'" error message back to the client attempting the write.

This reproduction uses `redis-cli` (executed inside the Redis Docker container) as the client to demonstrate this behavior.

## Prerequisites

* Docker
* Docker Compose

## Reproduction Steps

1.  **Clone this repository**

2.  **Start the Redis Service:**
    In your project directory, run:
    ```bash
    docker-compose up -d
    ```
    Wait a few seconds for Redis to initialize.

3.  **Trigger the OOM Error:**
    Execute the test script:
    ```bash
    ./run_oom_test.sh
    ```

## Expected Outcome & Example Log (`test.log`)

The `run_oom_test.sh` script will:
* Execute a series of commands against the Redis server using `redis-cli` (running inside the Docker container).
* Display the interaction on your console.
* Create/overwrite a file named `test.log` in the same directory. This file will contain **only the timestamped output from the `redis-cli` client session**, capturing the commands sent and the direct responses (including errors) from the Redis server.

You should see an error similar to the following in your console output and within `test.log` (timestamps will vary):