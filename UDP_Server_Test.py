# Client Test Socket

import socket
import time

HOST = '127.0.0.1'  # Standard loopback interface address (localhost)
PORT = 7000       

msgtest1=b"{'VEL':30,'FCW':0,'TTC':23.755}"
msgtest2=b"{'VEL':40,'FCW':1,'TTC':3.309}"
msgtest3=b"{'VEL':50,'FCW':1,'TTC':0.869}"
msgtest4=b"{'VEL':30,'FCW':0,'TTC':23.755}"

while True:
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
        
        s.sendto(msgtest1,(HOST,PORT))
        time.sleep(1)
        s.sendto(msgtest2,(HOST,PORT))
        time.sleep(1)
        s.sendto(msgtest3,(HOST,PORT))
        time.sleep(1)
        s.sendto(msgtest4,(HOST,PORT))
        time.sleep(1)
        print(msgtest1, msgtest2, msgtest3)

