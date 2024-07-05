import core.thread;
import core.time : dur;
import std.concurrency;
import std.container;
import std.conv : to;
import std.random;
import std.stdio;

// Echo server that handles multiple connections using multiplexed I/O
// with select() and non-blocking I/O
//
// Note that this example doesn't handle the case where the number of bytes sent
// or recieved was fewer than expected.  Calls to send() and recieve() would normally
// be wrapped in loops to keep calling send() / recieve() until all bytes are transmitted
// or the connection is closed unexpectedly.

enum OpType { Read, Write };

struct OpRequest {
	OpType type;
	Tid requester;
}

struct OpResponse{
	bool found;
	Tid workerId;
	Tid requester;
}

void workerFunc() {
	bool isDone = false;
	while(!isDone) {
		void requestHandler(OpRequest op) {
			Thread.sleep(dur!("seconds")(1));
			OpResponse response = { false, thisTid, op.requester };
			send(ownerTid, response);
		}
		
		receive(&requestHandler);
	}
}

void controllerFunc(uint nWorkers) {
	uint nReady, nReading, nWriting;
	DList!Tid ready;
	DList!Tid reading;
	DList!Tid writing;
	DList!OpRequest requestQueue;
	bool isDone = false;

	for(int i = 1; i <= nWorkers; i++) {
		Tid childTid = spawn(&workerFunc);
		ready ~= childTid;
		nReady += 1;
		writeln("Spawned worker " ~ to!string(i));
	}	
	
	while(!isDone) {
		void scheduleOp() {
			writeln("Workers " ~ to!string(nReady) ~ " ready " ~ to!string(nReading) ~ " reading " ~ to!string(nWriting) ~ " writing");
			bool anythingScheduled = true;
			while(!requestQueue.empty() && !ready.empty() && anythingScheduled) {
				OpRequest nextOp = requestQueue.front;
				writeln("Trying to schedule " ~ to!string(nextOp.type));

				// start read operation if there are no
				// ongoing write operations and workers
				// are available
				if(nextOp.type == OpType.Read && writing.empty() && !ready.empty()) {
					writeln("Assigning read op");
					Tid child = ready.front;
					ready.removeFront();
					nReady -= 1;
					send(child, nextOp);
					reading ~= child;
					nReading += 1;
					requestQueue.removeFront();
					writeln("Workers " ~ to!string(nReady) ~ " ready " ~ to!string(nReading) ~ " reading " ~ to!string(nWriting) ~ " writing");
				}

				// start write operation if nothing is running
				else if(nextOp.type == OpType.Write && writing.empty() && reading.empty()) {
					writeln("Assigning write op");
					Tid child = ready.front();
					ready.removeFront();
					nReady -= 1;
					send(child, nextOp);
					writing ~= child;
					nWriting += 1;
					requestQueue.removeFront();
					writeln("Workers " ~ to!string(nReady) ~ " ready " ~ to!string(nReading) ~ " reading " ~ to!string(nWriting) ~ " writing");
				} else {
					writeln("Nothing scheduled");
					anythingScheduled = false;
				}
			}
		}

		void opHandler(OpRequest req) {
			requestQueue.insertFront(req);

			scheduleOp();
		}

		void respHandler(OpResponse resp) {
			send(resp.requester, resp);
		
			// operation completed; update worker status
			ready.insertBack(resp.workerId);
			nReady += 1;
			if(reading.linearRemoveElement(resp.workerId)) {
				nReading -= 1;
			} else if(writing.linearRemoveElement(resp.workerId)) {
				nWriting -= 1;
			}

			scheduleOp();
		}

		receive(&opHandler, &respHandler);
	}
}

void main()
{
	uint nWorkers = 4;
	Tid controllerId = spawn(&controllerFunc, nWorkers);

	auto rng = Random(23462u);
	for(int i = 0; i < 100; i++) {
		double r = uniform(0.0, 1.0, rndGen());
		OpType type;
		if(r < 0.75) {
			type = OpType.Read;
		} else {
			type = OpType.Write;
		}
		writeln("Queueing " ~ to!string(type) ~ " operation");
		OpRequest req = { type, thisTid() };
		send(controllerId, req);
	}

	Thread.sleep(dur!("minutes")(10));
}
