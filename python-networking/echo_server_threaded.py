import socket
import threading

# supports multiple connections through threading

def handle_connection(conn, addr):
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
            print('Data sent back.')


HOST = ''                 # Symbolic name meaning all available interfaces
PORT = 50007              # Arbitrary non-privileged port

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.bind((HOST, PORT))

    # sets the number of unaccepted waiting connections allowed
    s.listen(60)

    while True:
        # blocks until we have a connection to accept
        conn, addr = s.accept()

        print('Accepted connection')
        thread = threading.Thread(target=handle_connection,
                                  args=(conn, addr))
        thread.start()

        print(threading.active_count(), 'threads currently running')

        # do I need to join inactive threads?
