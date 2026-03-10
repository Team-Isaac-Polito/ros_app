import rclpy
from rclpy.node import Node
from std_srvs.srv import Trigger
import numpy as np
import cv2 # Se non hai cv2, puoi usare il metodo numpy di prima
import base64

class ImageServiceServer(Node):
    def __init__(self):
        super().__init__('image_service_server')
        # Creiamo un servizio di tipo Trigger (standard ROS 2)
        self.srv = self.create_service(Trigger, '/detection/capture_frame', self.handle_screenshot)
        self.get_logger().info('Servizio Screenshot pronto su /request_screenshot')

    def handle_screenshot(self, request, response):
        self.get_logger().info('Richiesta ricevuta! Generazione immagine...')
        
        # 1. Crea un'immagine di test (640x480)
        # Qui potresti leggere dalla RealSense con cv2.VideoCapture(0)
        img = np.zeros((480, 640, 3), dtype=np.uint8)
        cv2.putText(img, 'ISAAC ROBOT FRAME', (150, 240), 
                    cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 255, 255), 2)
        
        # Aggiungiamo un cerchio che si muove per capire se l'immagine cambia
        import time
        t = int(time.time() * 10) % 640
        cv2.circle(img, (t, 100), 40, (0, 255, 0), -1)

        # 2. Converti in Base64 (che è quello che si aspetta la tua app)
        _, buffer = cv2.imencode('.jpg', img)
        img_base64 = base64.b64encode(buffer).decode('utf-8')

        # Usiamo il campo 'message' del Trigger per mandare la stringa Base64
        response.success = True
        response.message = img_base64
        
        return response

def main():
    rclpy.init()
    node = ImageServiceServer()
    rclpy.spin(node)
    rclpy.shutdown()

if __name__ == '__main__':
    main()