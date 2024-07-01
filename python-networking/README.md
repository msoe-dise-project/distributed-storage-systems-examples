# TCP/IP Echo examples
This directory contains examples for a TCP/IP echo client and three servers. The server examples are implemented using:

* Blocking I/O: handles one connection at a time
* Blocking I/O with threads: handles multiple connections at a time, each in its own thread
* Nonblocking I/O with select: handles multiple connections by multiplexing the connections using select()

## Running
Start one of the servers in a terminal:

```bash
$ python echo_server_multiplexed.py
```

Start clients, each in their own terminals:

```bash
$ python echo_client.py "The first digit of pi is 3"
```

Kill the clients using Ctrl-C.
