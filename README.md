# A Simple Graphical User Interface in Qt5 using PySide6.

This is a modern PySide6 GUI developped with QtQuick & QML in the Qt5 Framework.

Qt Quick is Qt's declarative user interface design framework, which uses the Qt Modeling Language (QML) to develop bespoke user interfaces. Originally designed for use in mobile apps, it includes dynamic graphical components as well as fluid transitions and effects that allow you to emulate the kind of user interfaces found on mobile devices.

for more information about PySide6 and QML, check the offcial documentation here :
>  **https://doc.qt.io/qtforpython/tutorials/basictutorial/qml.html**

The UI graphics which represent an important part of the project, have been created separately in Adobe Illustrator.

## Purpuse

The aim of the project is to use the potential of Qt5 to create a simple GUI with backend in python, which can display and graph data in real-time.
Originally it was used to display data for a car collision algorithm, therefore the only variables of concern to be shown are the "speed" and the "time to collision".
The communication of the data is done through **UDP Sockets**.

## Dependencies

In order to run this project you must have:

- Qt 5.15.2 
- MinGW 8.1.0 32-bit for C/C++
- Python 3.9.1 or above 
- PySide6 6.3.0 installed on python

## Usage

After making sure that all the dependencies are installed and setup properly you can run the GUI by executing the ***main.py*** file.
In order to communicate data to the GUI use the ***UDP_Server_Test.py*** script. 

## Freeze or deploy for different platforms (never tried!)

For more info on how to deploy the project on different platforms, take a look to this:
> https://doc.qt.io/qtforpython/deployment.html



