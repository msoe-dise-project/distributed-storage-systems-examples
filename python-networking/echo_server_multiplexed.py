import select
import socket

# supports multiple clients through non-blocking I/O and multiplexing

HOST = ''                 # Symbolic name meaning all available interfaces
PORT = 50007              # Arbitrary non-privileged port
NUM_CONN = 100

entrance_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
entrance_socket.bind((HOST, PORT))
entrance_socket.listen(NUM_CONN)
entrance_socket.setblocking(False)

accepted_conn_sockets = []

while True:
    read_sockets = [entrance_socket] + accepted_conn_sockets
    write_sockets = []
    except_sockets = []
    ready_read_sockets, _, _ = select.select(read_sockets, write_sockets, except_sockets)

    for sock in ready_read_sockets:
        # new connection ready to be accepted
        if sock == entrance_socket:
            accepted_sock, addr = sock.accept()
            accepted_sock.setblocking(False)
            accepted_conn_sockets.append(accepted_sock)
            print("Accepted", accepted_sock, "from", addr)
        else:
            data = sock.recv(1024)
            if data:
                print("Echoing", repr(data), "to", sock)
                sock.sendall(data)
            else:
                print("Closing", sock)
                accepted_conn_sockets.remove(sock)
                sock.close()
