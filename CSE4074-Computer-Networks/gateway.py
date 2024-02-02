from socket import *
import threading
import time
import logging

serverAddress = '127.0.0.1'
TemperaturePort = 12000
HumidityPort = 13000
serverPort = 14000
last_alive_timestamp = 0

def main():
    logging.basicConfig(filename='output.log', level=logging.DEBUG, format='%(asctime)s - %(filename)s - %(levelname)s - %(message)s')

    # Handshake with server
    while True:
        handshakeSocket = socket(AF_INET,SOCK_STREAM)
        try:
            handshakeSocket.connect((serverAddress,serverPort))
            handshakeSocket.send("HELLO FROM GATEWAY".encode())
            break
        except Exception as e:
            print("Server is not available. Waiting for 3 seconds.")
            time.sleep(3)

    while True:
        response = handshakeSocket.recv(1024).decode()
        print(f"Received message from Server: {response}")
        logging.info(f"Received message from Server: {response}")
        if response == "HELLO FROM SERVER":
            handshakeSocket.close()
            break
        
    serverTempSocket = socket(AF_INET,SOCK_STREAM)
    serverTempSocket.bind((serverAddress,TemperaturePort))
    serverTempSocket.settimeout(3)
    serverTempSocket.listen(1)
    print("Temperature socket created and listening from port {0}".format(TemperaturePort))
    logging.info(f"Temperature socket created and listening from port {TemperaturePort}")

    serverHumiditySocket = socket(AF_INET,SOCK_DGRAM)
    serverHumiditySocket.bind((serverAddress,HumidityPort))
    serverHumiditySocket.settimeout(7)
    print("Humidity socket created and listening from port {0}".format(HumidityPort))
    logging.info(f"Humidity socket created and listening from port {HumidityPort}")

    tempSensorThread = threading.Thread(target=listenTempSocket,args=(serverTempSocket,))
    tempSensorThread.start()

    humiditySensorThread = threading.Thread(target=listenHumiditySocket,args=(serverHumiditySocket,))
    humiditySensorThread.start()


def listenTempSocket(serverTempSocket):
    while True:
        try:
            connectionSocket, addr = serverTempSocket.accept()
            message = connectionSocket.recv(1024).decode()
            print("Temperature info from sensor: " + message)
            logging.info(f"Temperature info from sensor: {message}")
            tempature_message = "TEMPDATA " + message
            send_message_to_server(tempature_message)
            connectionSocket.close()
        
        # If temperature socket doesn't connect more than 3 seconds inform server.
        except TimeoutError:
            print("Temperature Device Disconnected.")
            logging.error("Temperature Device Disconnected.")
            send_message_to_server("TEMP SENSOR OFF")

def listenHumiditySocket(serverHumiditySocket):
    global last_alive_timestamp
    last_alive_timestamp = time.time()

    while True:
        try:
            #print("last_alive_timestamp: ", last_alive_timestamp)
            message, clientAddress = serverHumiditySocket.recvfrom(2048)
            message = message.decode()

            # If received message from is ALIVE update last_alive_timestamp   
            if message == "ALIVE":
                last_alive_timestamp = time.time()
                print("Received ALIVE message from humidity sensor")
                logging.info("Received ALIVE message from humidity sensor")
                continue
            else:
                print("Humidity info from sensor: " + message)
                logging.info(f"Humidity info from sensor: {message}")
                humidity_message = "HUMIDITYDATA " + message
                send_message_to_server(humidity_message)
            
        except TimeoutError:
            print("Humidity Device Disconnected.")
            send_message_to_server("HUMIDITY SENSOR OFF")
            logging.error("Humidity Device Disconnected.")



def send_message_to_server(message):
    client_socket = socket(AF_INET, SOCK_STREAM)
    try:
        client_socket.connect((serverAddress, serverPort))
        client_socket.send(message.encode())
        #print(f"Message sent to server: {message}")
        #logging.info(f"Message sent to server: {message}")
    except Exception as e:
        print(f"Error while sending message to Server: {e}")
        logging.error(f"Error while sending message to Server: {e}")

    client_socket.close()

if __name__ == "__main__":
    main()  
