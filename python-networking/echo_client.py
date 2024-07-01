import socket
import sys
import time

HOST = 'localhost'    # The remote host
PORT = 50007          # The same port as used by the server

msg = sys.argv[1].encode("utf-8")

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.connect((HOST, PORT))
    print("Connected to server")

    while True:
        s.sendall(msg)
        print("Sent:", repr(msg))

        resp = s.recv(1024)
        if len(resp) > 0:
            print("Received:", repr(resp))

        time.sleep(1.0)
