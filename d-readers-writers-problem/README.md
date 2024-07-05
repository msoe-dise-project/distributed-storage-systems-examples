# Readers-Writers Solutions
In the readers-writers problem, we have multiple concurrent readers and writers who want access to a resource.
The readers can read concurrently, while the writers each need exclusive access.  There are several solutions
to the problem, each with a set of tradeoffs.

In this case, we implemented a version in which read and write requests are stored in a queue.  A controller
schedules requests to a thread pool.  Runs of read operations are allowed to run concurrently.  When a write
operation is encountered, the current requests are allowed to finish, and then the write operation is scheduled
exclusively.

## Running
To run the example, use the following command:

```bash
$ dub run :concurrent-reader
```
