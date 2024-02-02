from socket import *
import random,time
import logging

serverAddress = '127.0.0.1'
humidityPort = 13000

def main():
    logging.basicConfig(filename='output.log', level=logging.DEBUG, format='%(asctime)s - %(filename)s - %(levelname)s - %(message)s')
    while True:
        humidity = readHumidity()
        timestamp = int(time.time())

        # Send humidity data to gateway only if the humidity value exceeds 80
        if(humidity >= 80):
            clientSocket = socket(AF_INET,SOCK_DGRAM)
            message = "{0} {1}".format(timestamp,humidity)
            try:
                clientSocket.sendto(message.encode(),(serverAddress,humidityPort))
                logging.info(f"{timestamp} {humidity}")
                print(message)
            except Exception as e:
                print(f"Error: {e}")
                logging.error(f"Error while sending data to gateway: {e}")
            clientSocket.close()

        # Send Alive message to gateway every 3 seconds
        if int(timestamp) % 3 == 0:
            message = "ALIVE"
            clientSocket = socket(AF_INET,SOCK_DGRAM)
            try:
                clientSocket.sendto(message.encode(),(serverAddress,humidityPort))
                print(timestamp, message)
                logging.info(f"{timestamp} {message}")
            except Exception as e:
                logging.error(f"Error while sending ALIVE message to gateway: {e}")
                print(f"Error: {e}")
        #timestamp += 1
        time.sleep(1)


def readHumidity():
    return random.randint(40,90)

if __name__ == "__main__":
    main()
