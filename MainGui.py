# This Python file uses the following encoding: utf-8
import os
import sys
import time
import socket

from pathlib import Path
from ast import literal_eval
from PyQt5.QtWidgets import QApplication
from PyQt5.QtQml import QQmlApplicationEngine
from PyQt5.QtCore import pyqtSignal, QObject, pyqtSlot, QPointF, QThread
from PyQt5.QtChart import QChart, QChartView

class gui():

    def __init__(self,
                 HOST='127.0.0.1',
                 PORT=7000,
                 ChartBoundaryMaxY=1000,
                 ChartBoundaryMinY=-1000,
                 MaxSpeed=None,
                 MinSpeed=None,
                 MaxTTC=None,
                 MinTTC=None):

        self.app = QApplication(sys.argv)
        # app.setWindowIcon(QIcon("/src/icon/icon_app.ico"))
        self.engine = QQmlApplicationEngine()
        self.chart_component = self._ChartComponent(ChartBoundaryMaxY,
                                                    ChartBoundaryMinY)
        self.speed_display = self._SpeedDisplay(MaxSpeed, MinSpeed)
        self.ttc_display = self._TimeToCollisionDisplay(MaxTTC, MinTTC)

        self.data_receive = self._DataReceiveThread(HOST, PORT)

        self.data_receive.speed.connect(self.chart_component.get_data)
        self.data_receive.speed.connect(self.speed_display.get_data)
        self.data_receive.is_connected.connect(
                                        self.speed_display.get_udp_status)
        self.data_receive.ttc.connect(self.ttc_display.get_data)
        self.data_receive.fcw.connect(self.ttc_display.get_fcw)

        self.engine.rootContext().setContextProperty("chart_component",
                                                     self.chart_component)
        self.engine.rootContext().setContextProperty("speed_display",
                                                     self.speed_display)
        self.engine.rootContext().setContextProperty("ttc_display",
                                                     self.ttc_display)
        self.engine.load(os.fspath(
                         Path(__file__).resolve().parent / "main.qml"))

    def run(self):

        if not self.engine.rootObjects():
            return -1

        self.data_receive.start()
        ret = self.app.exec()

        self.data_receive.requestInterruption()
        self.data_receive.wait()

        return ret

    class _DataReceiveThread(QThread):

        speed = pyqtSignal(float)
        ttc = pyqtSignal(float)
        fcw = pyqtSignal(bool)
        # strr = Signal(str)
        is_connected = pyqtSignal(bool)

        def __init__(self, HOST='127.0.0.1', PORT=7000, parent=None):
            super().__init__(parent)
            self.HOST = HOST
            self.PORT = PORT
            os.system('cls' if os.name == 'nt' else 'clear')

        def run(self):
            time.sleep(1)
            with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
                s.bind((self.HOST, self.PORT))
                s.setblocking(0)
                s.settimeout(1.1)
                while not self.isInterruptionRequested():
                    try:
                        # print('before recvfrom')
                        data, addr = s.recvfrom(225)
                        # print('after recvfrom')
                        data_dict = literal_eval(data.decode())
                        self.speed.emit(float(data_dict['VEL']))
                        self.ttc.emit(float(data_dict['TTC']))
                        self.fcw.emit(bool(data_dict['FCW']))
                        self.is_connected.emit(True)
                        # print(float(data_dict['VEL']))
                    except socket.timeout:
                        # print("closing socket: " + str(e))
                        self.speed.emit(0.0)
                        self.ttc.emit(0.0)
                        self.fcw.emit(False)
                        self.is_connected.emit(False)
                        # s.close()
                    except SyntaxError:
                        self.speed.emit(0.0)
                        self.ttc.emit(0.0)
                        self.fcw.emit(False)
                        self.is_connected.emit(False)
                        print("Error: received message format error")
                    except Exception:
                        self.speed.emit(0.0)
                        self.ttc.emit(0.0)
                        self.fcw.emit(False)
                        self.is_connected.emit(False)
                        print("Error: Unknown Error")
                s.close()

    class _ChartComponent(QObject):

        def __init__(self,
                     BoundaryMaxY=1000,
                     BoundaryMinY=-1000,
                     parent=None):

            super().__init__(parent)
            self.maxY = BoundaryMaxY
            self.minY = BoundaryMinY
            self.XPoints = [0]*12
            self.XYQPoints = [QPointF(i, self.XPoints[i])
                              for i in range(0, len(self.XPoints))]
            # print("hello")

        @pyqtSlot(QObject, QObject)
        def update_series(self, series, axisY):
            series.replace(self.XYQPoints)

            if(self.XPoints and self.XPoints):
                range = max(self.XPoints) - min(self.XPoints)
                if range == 0:
                    range = 0.001
                axisY.setMax(max(self.XPoints) + range*0.15)
                axisY.setMin(min(self.XPoints) - range*0.15)

        @pyqtSlot(float)
        def get_data(self, speed):

            if(speed > self.maxY):
                speed = self.maxY
            elif(speed < self.minY):
                speed = self.minY

            if len(self.XPoints) > 11:
                self.XPoints.pop(0)
            self.XPoints.append(speed)

            self.XYQPoints = [QPointF(i, self.XPoints[i])
                              for i in range(0, len(self.XPoints))]
            # print(self.XYQPoints)

    class _SpeedDisplay(QObject):

        speedSignal = pyqtSignal(float)
        udpStatusSignal = pyqtSignal(bool)

        def __init__(self,
                     MaxSpeed=None,
                     MinSpeed=None,
                     parent=None):

            super().__init__(parent)
            self.maxSpeed = MaxSpeed
            self.minSpeed = MinSpeed

        @pyqtSlot(float)
        def get_data(self, speed):

            if(self.maxSpeed is not None):
                if(speed > self.maxSpeed):
                    speed = self.maxSpeed
            if(self.minSpeed is not None):
                if(speed < self.minSpeed):
                    speed = self.minSpeed

            self.speedSignal.emit(speed)

        @pyqtSlot(bool)
        def get_udp_status(self, status):
            self.udpStatusSignal.emit(status)

    class _TimeToCollisionDisplay(QObject):

        timeToCollisonSignal = pyqtSignal(float)
        fcwSignal = pyqtSignal(bool)

        def __init__(self,
                     MaxTTC=None,
                     MinTTC=None,
                     parent=None):

            super().__init__(parent)
            self.maxTTC = MaxTTC
            self.minTTC = MinTTC

        @pyqtSlot(float)
        def get_data(self, ttc):
            # print(ttc)
            if(self.maxTTC is not None):
                if(ttc > self.maxTTC):
                    ttc = self.maxTTC
            if(self.minTTC is not None):
                if(ttc < self.minTTC):
                    ttc = self.minTTC

            self.timeToCollisonSignal.emit(ttc)

        @pyqtSlot(bool)
        def get_fcw(self, fcw):
            self.fcwSignal.emit(fcw)
