import core.thread;
import deimos.zmq.zmq;
import std.stdio;

void main()
{
	auto context = zmq_ctx_new();
	auto socket = zmq_socket(context, ZMQ_REQ);
	int rc = zmq_connect(socket, "tcp://localhost:5555");
	assert(rc == 0);

	string req = "Hello";
	writeln(req.length);
	for(int i = 0; i < 5; i++) {
		writeln("Sending request");
		zmq_msg_t msg;
		zmq_msg_init_size(&msg, req.length);
		(cast(ubyte*) zmq_msg_data(&msg))[0 .. req.length] = (cast(ubyte*) &req)[0 .. req.length];
		zmq_msg_send(&msg, socket, 0);

		// not required after send but for good measure
		zmq_msg_close(&msg);

		// reuse struct
		zmq_msg_init(&msg);
		int nbytes = zmq_msg_recv(&msg, socket, 0);
		writeln("Received reply");
		zmq_msg_close(&msg);
	}

	zmq_close(socket);
	zmq_ctx_destroy(context);
}
