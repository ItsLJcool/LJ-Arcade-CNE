import socket
from threading import Thread
connections = []
def new_client(conn2, address, socket):
    while True:
        data = conn2.recv(1024)
        if not data:
            print("Data null")
            break

        print("User Sent Data: " + str(data))

        for i in connections:
            if i != conn2: i.send(data)
    print("Stopping Thread and Removing Client!")
    connections.remove(conn2)
    conn2.close()

server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server_socket.bind(("127.0.0.1", 5000))
server_socket.listen(5)

while True:
    conn, playerAddress = server_socket.accept()
    connections.append(conn)
    print(len(connections))
    print("Connection from: " + str(playerAddress) + ", Ready to play")
    Thread(target = new_client, args=(conn,playerAddress,server_socket)).start()