import std.conv : to;
import std.socket;
import std.stdio;

// Echo server that handles only a single connection
// Note that this example doesn't handle the case where the number of bytes sent
// or recieved was fewer than expected.  Calls to send() and recieve() would normally
// be wrapped in loops to keep calling send() / recieve() until all bytes are transmitted
// or the connection is closed unexpectedly.

void main()
{
	Socket listeningSocket = new Socket(AddressFamily.INET, SocketType.STREAM, ProtocolType.TCP);
	writeln("Created socket");

	InternetAddress serverAddr = new InternetAddress("127.0.0.1", 50007);
	listeningSocket.bind(serverAddr);
	writeln("Bound socket");
	listeningSocket.listen(5);
	writeln("Socket set to listen");

	while(true) {
		// When we accepted connections, a new socket is created for
		// active connections.  The original socket used for listening
		// for connections isn't closed -- it's kept open to keep
		// listening for more connections.
		Socket acceptedSocket = listeningSocket.accept();
		Address clientAddress = acceptedSocket.remoteAddress;
		writeln("Accepted connection from " ~ clientAddress.toAddrString());

		ubyte[] buffer = new ubyte[512];

		while(true) {
			ptrdiff_t bytesRecvd = acceptedSocket.receive(buffer);
			writeln("Received " ~ to!string(bytesRecvd) ~ " bytes: '" ~ cast(string) buffer[0 .. bytesRecvd] ~ "'");

			if(bytesRecvd <= 0) {
				writeln("Client closed connection prematurely.");
				break;
			}
	
			ptrdiff_t bytesSent = acceptedSocket.send(buffer[0 .. bytesRecvd]);
			writeln("Sent " ~ to!string(bytesSent) ~ " bytes");

			if(bytesSent <= 0) {
				writeln("Client closed connection prematurely.");
				break;			
			}
		}

		acceptedSocket.shutdown(SocketShutdown.BOTH);
		acceptedSocket.close();
	}

	// D docs recommend shutdown before close: https://dlang.org/phobos/std_socket.html#.Socket.close
	listeningSocket.shutdown(SocketShutdown.BOTH);
	listeningSocket.close();
	writeln("Connection closed");
}
