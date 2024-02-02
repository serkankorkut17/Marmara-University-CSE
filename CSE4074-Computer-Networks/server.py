from socket import *
import threading
import logging


temp_data = []
humidity_data = []

is_temp_active = False
is_humidity_active = False   

server_ip = '127.0.0.1'
server_port = 14000
http_port = 8080

def main():
    logging.basicConfig(filename='output.log', level=logging.DEBUG, format='%(asctime)s - %(filename)s - %(levelname)s - %(message)s')

     
    # Read Gateway Port
    server_gateway_listen_socket = socket(AF_INET,SOCK_STREAM)
    server_gateway_listen_socket.bind((server_ip, server_port))
    server_gateway_listen_socket.listen(1)

    # hanshake with gateway
    while True:
        conn, addr = server_gateway_listen_socket.accept()
        message = conn.recv(1024).decode()
        if message == "HELLO FROM GATEWAY":
            logging.info(f"Received HELLO FROM GATEWAY: {message}")
            conn.send("HELLO FROM SERVER".encode())
            conn.close()
            break

    # HTTP Port
    http_server_socket = socket(AF_INET,SOCK_STREAM)
    http_server_socket.bind((server_ip, http_port)) 
    http_server_socket.listen(1)
    
    # Read Gateway Thread
    server_gateway_listen_thread = threading.Thread(target=read_data,args=(server_gateway_listen_socket,))
    server_gateway_listen_thread.start()

    # HTTP Port Thread
    http_server_thread = threading.Thread(target=create_HTTP_server,args=(http_server_socket,))
    http_server_thread.start()

def read_data(server_gateway_listen_socket):
    global is_temp_active, is_humidity_active
    while True:
        conn, addr = server_gateway_listen_socket.accept()
        message = conn.recv(1024).decode()
        print(f"Received message from Gateway: {message}")
        logging.info(f"Received message from Gateway: {message}")
        
        # We get temperature data if message starts with TEMPDATA
        if message.startswith("TEMPDATA"):
            temp_data.append([message.split()[1], message.split()[2]])
            is_temp_active = True
        
        # We get humidity data if message starts with HUMIDITYDATA
        elif message.startswith("HUMIDITYDATA"):
            humidity_data.append([message.split()[1], message.split()[2]])
            is_humidity_active = True
        
        # Temperature socket is disconnected if message is TEMP SENSOR OFF
        elif message == "TEMP SENSOR OFF":
            is_temp_active = False
        
        # Humidity socket is disconnected if message is HUMIDITY SENSOR OFF
        elif message == "HUMIDITY SENSOR OFF":
            is_humidity_active = False
        
        conn.close()

# Create HTTP server
def create_HTTP_server(http_server_socket):
    try:
        while True:
            client_socket, address = http_server_socket.accept()
            rd = client_socket.recv(1024).decode()
            if(rd == ""): 
                print("asdasdasds")
                client_socket.close() 
                continue
            if rd.split()[0] == "GET":
                if "temperature" in rd.lower():
                    print("temperature page requested")
                    html = prepare_temperature_html()
                elif "humidity" in rd.lower():
                    print("humidity page requested")
                    html = prepare_humidity_html()
                elif "/" in rd.lower():
                    print("homepage requested")
                    html = prepare_homepage_html()
                client_socket.sendall(html.encode())

            client_socket.close()
    except Exception as exc:
        print(exc)
       
def prepare_homepage_html():
    data = "HTTP/1.1 200 OK\r\n"
    data += "Content-Type: text/html; charset=utf-8\r\n"
    data += "\r\n"
    data += "<html><head><title>Computer Networks Project</title></head>\r\n"
    data += "<body><h1>Computer Networks HomePage</h1>\r\n"
    data += "<a href='temperature'>Temperature</a>\r\n"
    data += "<a href='humidity'>Humidity</a>\r\n"
    data += "</body></html>\r\n\r\n"
    return data

def prepare_temperature_html():

    data = "HTTP/1.1 200 OK\r\n"
    data += "Content-Type: text/html; charset=utf-8\r\n"
    data += "\r\n"
    data += "<html><head><title>Temperature</title></head>\r\n"

    data += "<h1>Temperature Data</h1><table border='1'>\r\n"
    data += "<tr><th>Timestamp</th><th>Temperature</th></tr>\r\n"
    for temp_value in temp_data:
        data += f"<tr><td>{temp_value[0]}</td><td>{temp_value[1]}</td></tr>\r\n"
    data += "</table>\r\n"
    if not is_temp_active:
        data += "<h1>TEMP SENSOR OFF</h1></body>\r\n"

    data += "</html>\r\n\r\n"
    return data

def prepare_humidity_html():

    data = "HTTP/1.1 200 OK\r\n"
    data += "Content-Type: text/html; charset=utf-8\r\n"
    data += "\r\n"
    data += "<html><head><title>Humidity</title></head>\r\n"

    data += "<h1>Humidity Data</h1><table border='1'>\r\n"
    data += "<tr><th>Timestamp</th><th>Humidity</th></tr>\r\n"
    for humidity_value in humidity_data:
        data += f"<tr><td>{humidity_value[0]}</td><td>{humidity_value[1]}</td></tr>\r\n"
    data += "</table>\r\n"
    if not is_humidity_active:
        data += "<h1>HUMIDITY SENSOR OFF</h1></body>\r\n"

    data += "</html>\r\n\r\n"
    return data

    
if __name__ == "__main__":
    main()  
 
