import core.thread;
import deimos.zmq.zmq;
import std.stdio;

void main()
{
	auto context = zmq_ctx_new();
	auto socket = zmq_socket(context, ZMQ_REP);
	int rc = zmq_bind(socket, "tcp://localhost:5555");
	assert(rc == 0);

	string rep = "World";
	while(true) {
		zmq_msg_t msg;
		zmq_msg_init(&msg);
		int bytes = zmq_msg_recv(&msg, socket, 0);
		writeln("Received request");
		zmq_msg_close(&msg);

		zmq_msg_init_size(&msg, rep.length);
		(cast(ubyte*) zmq_msg_data(&msg))[0 .. rep.length] = (cast(ubyte*) rep)[0 .. rep.length];
		zmq_msg_send(&msg, socket, 0);
		writeln("Sending response");
		zmq_msg_close(&msg);
	}

	zmq_close(socket);
	zmq_ctx_destroy(context);
}
