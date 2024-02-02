from socket import *
import random,time
import logging

def main():
    serverAddress = '127.0.0.1'
    temperaturePort = 12000
    
    logging.basicConfig(filename='output.log', level=logging.DEBUG, format='%(asctime)s - %(filename)s - %(levelname)s - %(message)s')

    while True:
        timestamp = int(time.time())
        message = "{0} {1}".format(timestamp,readTemperature())
        clientSocket = socket(AF_INET,SOCK_STREAM)
        # Send temperature data to gateway
        try:
            clientSocket.connect((serverAddress,temperaturePort))
            clientSocket.send(message.encode())
            logging.info(f"{timestamp} {message}")
            print(message)
        except Exception as e:
            logging.error(f"Error while sending data to gateway: {e}")
            print(f"Error: {e}")
        clientSocket.close()
        time.sleep(1)


def readTemperature():
    return random.randint(20,30)

if __name__ == "__main__":
    main()
