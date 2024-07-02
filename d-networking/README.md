# D Networking Examples
Examples of networking in the [systems language D](https://dlang.org/).

## Running
The examples include a client and two servers (one multiplexed, one handling a single connection).
To run the server, run the following in a terminal:

```bash
$ dub run :echo-multiplexed-server
```

In a separate terminal, start the client:

```bash
$ dub run :echo-client
```
