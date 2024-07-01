import socket

# only supports a single client at a time

HOST = ''                 # Symbolic name meaning all available interfaces
PORT = 50007              # Arbitrary non-privileged port
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.bind((HOST, PORT))

    # sets the number of unaccepted waiting connections allowed
    s.listen(1)

    while True:
        # blocks until we have a connection to accept
        conn, addr = s.accept()

        with conn:
            print('Connected by', addr)
            while True:
                # blocks until data are available
                # grabs whatever data have been recieved
                data = conn.recv(1024)

                print('Client sent', repr(data))
                if not data:
                    print('No more data.')
                    break

                # sends data back
                conn.sendall(data)
                print('Data returned to sender.')
