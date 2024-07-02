import std.conv : to;
import std.socket;
import std.stdio;

// Echo client
// Note that this example doesn't handle the case where the number of bytes sent
// or recieved was fewer than expected.  Calls to send() and recieve() would normally
// be wrapped in loops to keep calling send() / recieve() until all bytes are transmitted
// or the connection is closed unexpectedly.

void main()
{
	Socket socket = new Socket(AddressFamily.INET, SocketType.STREAM, ProtocolType.TCP);
	writeln("Created socket");

	InternetAddress serverAddr = new InternetAddress("127.0.0.1", 50007);
	socket.connect(serverAddr);
	writeln("Connect to server");

	string msg = "Hello from D!";
	ubyte[] msgBytes = cast(ubyte[]) msg;
	ptrdiff_t bytesSent = socket.send(msgBytes);
	writeln("Sent " ~ to!string(bytesSent) ~ " bytes");

	if(bytesSent <= 0) {
		writeln("Connection closed unexpectedly");
	} else if(bytesSent < msgBytes.length) {
		writeln("Sent fewer bytes than expected");
	}

	ubyte[] recvBuffer = new ubyte[512];
	ptrdiff_t bytesRecvd = socket.receive(recvBuffer);
	writeln("Received " ~ to!string(bytesRecvd) ~ " bytes");

	// D docs recommend shutdown before close: https://dlang.org/phobos/std_socket.html#.Socket.close
	socket.shutdown(SocketShutdown.BOTH);
	socket.close();
	writeln("Connection closed");
}
