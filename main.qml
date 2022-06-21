import QtQuick 2.10
import QtQuick.Window 2.15
import QtCharts 2.15
import QtQuick.Shapes 1.12
import Qt.labs.animation 1.0
//import QtGraphicalEffects
import QtQuick.Controls 2.1
//import QtMultimedia 5.0

Window {
    id: root
    flags: Qt.Window | Qt.FramelessWindowHint
    width: 480
    height: 320
    x : Screen.width / 2 - width / 2
    y : Screen.height / 2 - height / 2
    minimumHeight : 320
    minimumWidth : 480
    maximumHeight : minimumHeight
    maximumWidth : minimumWidth
    visible: true
    color: "transparent"
    title: qsTr("Car Data Visualizer")

    FontLoader {
        id: interBold
        source: "src/fonts/Inter-Bold.ttf"
    }
    FontLoader {
        id: interSemiBold
        source: "src/fonts/Inter-SemiBold.ttf"
    }
    FontLoader {
        id: interMedium
        source: "src/fonts/Inter-Medium.ttf"
    }

    property color yellowish: "#FFF955"

    MouseArea {
        id: windowDrag
        anchors.fill: parent;
        property var clickPos

        onPressed: (mouse)=> {
            clickPos  = Qt.point(mouse.x,mouse.y)
        }

        onPositionChanged: (mouse)=> {
            var delta = Qt.point(mouse.x-clickPos.x, mouse.y-clickPos.y)
            root.x += delta.x;
            root.y += delta.y;
        }
    }

    Item {
        id: uiFrame

        Image {
            id: background
            x: 0
            y: 0
            source: "src/graphics/background.png"
            scale: 1
            fillMode: Image.PreserveAspectFit

        }
        Image {
            id: circularbar_frame_component
            x: 249
            y: 96
            source: "src/graphics/circularbar_frame_component.png"
            fillMode: Image.PreserveAspectFit

        }
        Item {
            id: speedPanel
            width: 266
            height: 196

            Image {
                id: speed_component
                x: 14
                y: 13
                source: "src/graphics/speed_component.png"
                fillMode: Image.PreserveAspectFit
            }
            Text {
                id: speedTextField
                anchors.fill : parent
                horizontalAlignment: Text.AlignRight
                anchors.rightMargin: 92
                anchors.bottomMargin: 74
                anchors.leftMargin: 55
                anchors.topMargin: 74
                text: "0.000"
                font.family: interBold.name
                font.pointSize: 29
                color: 'white'

                Connections {
                    target: speed_display

                    function onSpeedSignal(speedValue){
                        if (speedValue < 1 && speedValue > 0) {
                            speedTextField.text = speedValue.toFixed(3);
                        }
                        else if (speedValue < 0 && speedValue > -1){
                            speedTextField.text = speedValue.toFixed(2)
                        }
                        else if (speedValue < -1){
                            speedTextField.text = speedValue.toPrecision(3)
                        }
                        else
                            speedTextField.text = speedValue.toPrecision(4)
                    }
                    function onUdpStatusSignal(udpStatus){
                        if(udpStatus) {
                            udp_on.opacity = 1;
                            udp_off.opacity = 0;
                        }
                        else{
                            udp_on.opacity = 0;
                            udp_off.opacity = 1;
                            bipMaxSound.stop()
                            circularProgressBar.state = "dangerOff";
                            bipTimer.stop()
                        }
                    }
                }
            }
            Text {
                id: speedUnit
                x: speedTextField.width +55
                y: 78
                width: 45
                text: "km/h"
                font.family: interSemiBold.name
                font.pointSize: 12
                color: 'white'
            }
            Text {
                x: 61
                y: 58
                text: "Speed"
                font.family: interMedium.name
                font.pointSize: 10
                color: yellowish
            }

            ChartView {

                id: splineChart
                x: 29
                y: 89
                width: 199
                height: 97
                backgroundColor: "transparent"
                legend.visible: false

                Timer {
                    id: miTimer
                    interval: 50
                    //running: true
                    repeat: true
                    onTriggered: {
                        chart_component.update_series(splineChart.series("splineSeries"), axisY)
                    }
                }

                SplineSeries {
                    name: "splineSeries"
                    capStyle:  Qt.RoundCap
                    width : 1.5
                    color: "#fff953"
                    axisX: ValuesAxis{
                                color : "#29ffffff"
                                gridVisible: false
                                tickCount : 2
                                visible: false
                                labelsVisible : false
                            }
                    axisY: ValuesAxis{
                            id: axisY
                            color : "#83ffffff"
                            gridLineColor : "#83ffffff"
                            labelsColor : "#89ffffff"
                            gridVisible: false
                            tickCount : 3
                            labelsFont.pointSize: 5
                            }

                    XYPoint { x: 0; y: 0 }
                    XYPoint { x: 1; y: 0 }
                    XYPoint { x: 2; y: 0 }
                    XYPoint { x: 3; y: 0 }
                    XYPoint { x: 4; y: 0 }
                    XYPoint { x: 5; y: 0 }
                    XYPoint { x: 6; y: 0 }
                    XYPoint { x: 7; y: 0 }
                    XYPoint { x: 8; y: 0 }
                    XYPoint { x: 9; y: 0 }
                    XYPoint { x: 10; y: 0 }
                    XYPoint { x: 11; y: 0 }

                }
            }
        }
        Item {
            id: timeCollisionPanel

            Connections {
                target: ttc_display

                function onTimeToCollisonSignal(ttcValue){
                    if (ttcValue < 1 && ttcValue > 0) {
                        timeCollisionTextField.text = ttcValue.toFixed(3);
                    }
                    else if (ttcValue < 0 && ttcValue > -1){
                        timeCollisionTextField.text = ttcValue.toFixed(2)
                    }
                    else if (ttcValue < -1){
                        timeCollisionTextField.text = ttcValue.toPrecision(3)
                    }
                    else
                        timeCollisionTextField.text = ttcValue.toPrecision(4)

                    circularProgressBar.value = ttcValue;
                }
                function onFcwSignal(fcwValue){
                    if(fcwValue){
                       dangerIconOff.opacity = 0.0;
                       dangerIconOn.opacity = 1.0;
                    }
                    else{
                        dangerIconOff.opacity = 1.0;
                        dangerIconOn.opacity = 0.0;
                    }
                }
            }

            Image {
                id: timecollision_component
                x: 14
                y: 180
                source: "src/graphics/timecollision_component.png"
                fillMode: Image.PreserveAspectFit

                Text {
                    id: timeCollisionTextField
                    anchors.fill: parent
                    font.family: interBold.name
                    font.pointSize: 21
                    color: 'white'
                    text: "0.000"
                    horizontalAlignment: Text.AlignRight
                    anchors.rightMargin: 83
                    anchors.topMargin: 58
                    anchors.bottomMargin: 21
                    anchors.leftMargin: 66
                }
                Text {
                    id: timeUnit
                    x: timeCollisionTextField.width + 67
                    y: 58
                    text: "ms"
                    font.family: interSemiBold.name
                    font.pointSize: 12
                    color: 'white'
                }
                Text {
                    x: 66
                    y: 39
                    text: "Time to collision"
                    font.family: interMedium.name
                    font.pointSize: 10
                    color: yellowish
                }

                Image {
                    id: gUI_carcollisions
                    x: -14
                    y: -180
                    opacity: 0.151
                    visible: false
                    source: "src/graphics/GUI_car collisions.png"
                    fillMode: Image.PreserveAspectFit
                }
            }
        }
        Item {
            id: toggleSwitch
            property bool on: true
            x: 297
            y: 31
            width: onBackground.width
            height: onBackground.height

            function toggleTheSwitch() {
                if (toggleSwitch.state === "on"){
                    soundDeactivate.play()
                    toggleSwitch.state = "off";
                }
                else{
                    toggleSwitch.state = "on";
                    soundActivate.play();
                    }
            }

            function releaseSwitch() {
                if (onKnob.x === 24) {
                    if (toggleSwitch.state === "off") return;
                }
                if (onKnob.x === 58) {
                    if (toggleSwitch.state === "on") return;
                }
                toggleTheSwitch();
            }

            SoundEffect {
                id: soundActivate
                source: "src/sounds/toggle_on_sound.wav"
            }
            SoundEffect {
                id: soundDeactivate
                source: "src/sounds/toggle_off_sound.wav"
            }
            Image {
                id: onBackground
                x: 0
                y: 0
                opacity: 1.0
                source: "src/graphics/toggle_on_background.png"
                fillMode: Image.PreserveAspectFit
                //MouseArea { anchors.fill: parent; anchors.rightMargin: 248; anchors.bottomMargin: 36; anchors.leftMargin: -248; anchors.topMargin: -36; onClicked: toggle() }

            }

            Image {
                id: offBackground
                x: onBackground.x
                y: onBackground.y
                opacity: 0.0
                source: "src/graphics/toggle_off_background.png"
                fillMode: Image.PreserveAspectFit

                MouseArea {
                            anchors.fill: parent;
                            anchors.bottomMargin: 12;
                            anchors.rightMargin: 11;
                            anchors.leftMargin: 20;
                            anchors.topMargin: 20;
                            onClicked: toggleSwitch.toggleTheSwitch()
                }
            }

            Image {
                id: onKnob
                x: 58
                y: 24
                opacity: 1.0
                source: "src/graphics/toggle_on_knob.png"
                fillMode: Image.PreserveAspectFit
                MouseArea {
                    anchors.fill: parent
                    drag.target: onKnob; drag.axis: Drag.XAxis; drag.minimumX: 24; drag.maximumX: 58
                    onClicked: toggleSwitch.toggleTheSwitch()
                    onReleased: toggleSwitch.releaseSwitch()
                }
            }
            Image {
                id: offKnob
                x: onKnob.x
                y: onKnob.y
                opacity: 0.0
                source: "src/graphics/toggle_off_knob.png"
                fillMode: Image.PreserveAspectFit
            }

            Image {
                id: soundOnIcon
                x: -26
                y: 9
                opacity: 1.0
                source: "src/graphics/sound_on_icon.png"
                fillMode: Image.PreserveAspectFit
            }
            Image {
                id: soundOffIcon
                x: -17
                y: 19
                opacity: 0.0
                source: "src/graphics/sound_off_icon.png"
                scale: 0.9
                fillMode: Image.PreserveAspectFit
            }

            states: [
                State {
                    name: "on"
                    PropertyChanges { target: onKnob; x: 58 }
                    PropertyChanges { target: onKnob; opacity: 1.0 }
                    PropertyChanges { target: offKnob; opacity: 0.0 }
                    PropertyChanges { target: onBackground; opacity: 1.0 }
                    PropertyChanges { target: offBackground; opacity: 0.0 }
                    PropertyChanges { target: soundOnIcon; opacity: 1.0 }
                    PropertyChanges { target: soundOffIcon; opacity: 0.0 }
                    PropertyChanges { target: toggleSwitch; on: true }
                    PropertyChanges { target: bipMaxSound; muted: false }
                    PropertyChanges { target: bipSound; muted: false }
                    PropertyChanges { target: lightOnSound; muted: false }
                },
                State {
                    name: "off"
                    PropertyChanges { target: onKnob; x: 24 }
                    PropertyChanges { target: onKnob; opacity: 0.0 }
                    PropertyChanges { target: offKnob; opacity: 1.0 }
                    PropertyChanges { target: onBackground; opacity: 0.0 }
                    PropertyChanges { target: offBackground; opacity: 1.0 }
                    PropertyChanges { target: soundOnIcon; opacity: 0.0 }
                    PropertyChanges { target: soundOffIcon; opacity: 1.0 }
                    PropertyChanges { target: toggleSwitch; on: false }
                    PropertyChanges { target: bipMaxSound; muted: true }
                    PropertyChanges { target: bipSound; muted: true }
                    PropertyChanges { target: lightOnSound; muted: true }
                }
            ]

            transitions: Transition {
                NumberAnimation { properties: "x"; easing.type: Easing.InOutQuad; duration: 50 }
                NumberAnimation { properties: "opacity"; easing.type: Easing.InOutQuad; duration: 300 }
            }

        }
        Item {

            id: circularProgressBar
            implicitWidth: 134
            implicitHeight: 134
            x: 288
            y: 135
            width: 124 + lineWidth
            height: 124 + lineWidth
            property real maxValue: 40
            property real value: 0
            property real lineWidth: 11

            property real threashold: maxValue*(1-0.01)
            property bool thresholdReached: false

            Timer {
                id: bipTimer
                interval: 500
                //running: true
                repeat: false
                onTriggered: {
                    bipSound.play()
                    var x_ratio = 1-circularProgressBar.value/circularProgressBar.maxValue
                    var b = -160
                    var a = - 580 - b
                    bipTimer.interval = a*(x_ratio**2)+ b*x_ratio +600
                    bipTimer.start()
                }
            }

            function checkThreshold() {
                if (value <= threashold && value > 0){
                    bipMaxSound.stop()
                    circularProgressBar.state = "dangerOn";
                    bipTimer.start()
                }
                else if(value == 0){
                    bipTimer.stop()
                    bipMaxSound.play()
                }
                else{
                    bipMaxSound.stop()
                    circularProgressBar.state = "dangerOff";
                    bipTimer.stop()
                }
            }
            SoundEffect{
                id:bipSound
                source: "src/sounds/bip_sound.wav"
            }
            SoundEffect{
                id:bipMaxSound
                source: "src/sounds/bip_max_sound.wav"
                loops: SoundEffect.Infinite
            }

            onValueChanged :{
                checkThreshold()
            }

            BoundaryRule on value {
                minimum: 0
                maximum: circularProgressBar.maxValue
            }

            /*MouseArea {
                id : mouse
                anchors.fill: parent
            }*/

            Text{
                id: collisionMag
                property real value: 100*(1-circularProgressBar.value/circularProgressBar.maxValue)
                anchors.fill: parent
                text: collisionMag.value.toPrecision(3)
                horizontalAlignment: Text.AlignRight
                anchors.leftMargin: 53
                anchors.topMargin: 57
                anchors.rightMargin: 53
                anchors.bottomMargin: 57
                font.family: interMedium.name
                font.pointSize: 13
                color: 'white'
            }
            Text{
                id: collisionUnit
                x: collisionMag.width +52
                y: collisionMag.y
                text: "%"
                font.family: interMedium.name
                font.pointSize: 7
                color: 'white'
            }
            Shape{
                id: progressShape
                anchors.fill: parent
                layer.smooth: false
                anchors.rightMargin: 0
                anchors.bottomMargin: 0
                anchors.leftMargin: 0
                anchors.topMargin: 0
                //smooth: true
                layer.enabled: true
                layer.samples: 2
                //antialiasing: true
                ShapePath {
                    id: path
                    //strokeColor: progress.progressColor
                    strokeColor: yellowish
                    fillColor: "transparent"
                    strokeWidth: circularProgressBar.lineWidth
                    capStyle: ShapePath.RoundCap

                    PathAngleArc {
                        radiusX: (circularProgressBar.width / 2) - circularProgressBar.lineWidth/2
                        radiusY: (circularProgressBar.height / 2) - circularProgressBar.lineWidth/2
                        centerX: circularProgressBar.width / 2
                        centerY: circularProgressBar.height / 2
                        startAngle: 131
                        sweepAngle: (360-81)*(1-circularProgressBar.value/circularProgressBar.maxValue)

                        Behavior on sweepAngle {
                            NumberAnimation { easing.type: Easing.OutExpo; duration: 700 }
                        }

                    }
                }
            }

            Image {
                id: dangerIconOn
                x: 46
                y: 95
                opacity: 0.0
                source: "src/graphics/danger_icon_on.png"
                fillMode: Image.PreserveAspectFit
            }

            Image {
                id: dangerIconOff
                x: 48
                y: 97
                opacity: 1.0
                source: "src/graphics/danger_icon_off.png"
                fillMode: Image.PreserveAspectFit
            }
            states: [
                State {
                    name: "dangerOn"
                    PropertyChanges { target: circularProgressBar; thresholdReached: true }
                },
                State {
                    name: "dangerOff"
                    PropertyChanges { target: circularProgressBar; thresholdReached: false }
                }
            ]

            transitions: Transition {
                NumberAnimation { properties: "opacity"; easing.type: Easing.InOutQuad; duration: 300 }
            }

        }
        Item {
            id: powerOffButton
            implicitWidth: 40
            implicitHeight: 40
            x : 432
            y : 8
            Image {
                id: quitButtonOff
                opacity:1.0
                source: "src/graphics/quit_button_off.png"
                fillMode: Image.PreserveAspectFit
            }
            Image {
                id: quitButtonOn
                x:  -12
                y: -9
                opacity: 0.0
                source: "src/graphics/quit_button_on.png"
                fillMode: Image.PreserveAspectFit
            }

            SoundEffect {
                id: lightOnSound
                source: "src/sounds/light_up_sound.wav"
            }

            MouseArea{
                id: exiter
                anchors.fill: parent
                anchors.leftMargin: 9
                anchors.topMargin: 9
                anchors.rightMargin: 11
                anchors.bottomMargin: 10
                hoverEnabled: true
                onEntered: {
                    quitButtonOff.opacity = 0
                    quitButtonOn.opacity = 1
                    lightOnSound.play()
                }
                onExited: {
                    quitButtonOff.opacity = 1
                    quitButtonOn.opacity = 0
                }
                Connections {
                    target: exiter
                    function onClicked(exiter){
                        quitButtonOff.opacity = 0
                        quitButtonOn.opacity = 1
                        Qt.callLater(Qt.quit)
                    }
                }
            }
        }
        Item {
            id: udpConnection
            Image {
                id: udp_on
                x: 170
                y: 38
                opacity:0.0
                source: "src/graphics/udp_on.png"
                fillMode: Image.PreserveAspectFit
            }
            Image {
                id: udp_off
                x: 175
                y: 43
                opacity:1.0
                source: "src/graphics/udp_off.png"
                fillMode: Image.PreserveAspectFit
            }
        }
        Item {
            id: lockMove
            implicitWidth: 40
            implicitHeight: 40
            x : 386
            y : -3
            width: 57
            height: 54

            Image {
                id: lock_open
                anchors.fill: parent
                visible: true
                source: "src/graphics/lock_open.png"
                anchors.rightMargin: -3
                anchors.bottomMargin: -2
                anchors.leftMargin: 2
                anchors.topMargin: 2
                fillMode: Image.Pad
            }
            Image {
                id: lock_open_mouseOn
                x: 391
                anchors.fill: parent
                visible: false
                source: "src/graphics/lock_open_mouse_on.png"
                fillMode: Image.Pad
            }
            Image {
                id: lock_closed
                anchors.fill: parent
                visible: false
                source: "src/graphics/lock_closed.png"
                fillMode: Image.Pad
            }
            MouseArea{
                id: lockMouseRegion
                anchors.fill: parent
                anchors.leftMargin: 24
                anchors.topMargin: 19
                anchors.rightMargin: 16
                anchors.bottomMargin: 13
                hoverEnabled: true
                onEntered: {
                    lightOnSound.play()
                    if(lock_open.visible){
                        lock_open.visible = false
                        lock_open_mouseOn.visible = true
                    }
                }
                onExited: {
                    if(lock_open_mouseOn.visible){
                        lock_open_mouseOn.visible = false
                        lock_open.visible = true
                    }
                }
                onClicked: {
                    if(lock_open_mouseOn.visible || lock_open.visible){
                        lightOnSound.play()
                        lock_open_mouseOn.visible = false
                        lock_open.visible = false
                        root.x = Screen.width / 2 - root.width / 2
                        root.y = Screen.height / 2 - root.height / 2
                        windowDrag.enabled = false
                        lock_closed.visible = true
                    }
                    else{
                        lightOnSound.play()
                        lock_open_mouseOn.visible = true
                        lock_open.visible = false
                        windowDrag.enabled = true
                        lock_closed.visible = false
                    }
                }
            }
        }
        Component.onCompleted: {
            //var series = splineChart.createSeries(ChartView.SeriesTypeSpline,"speedSeries",axisX,axisY)

            miTimer.start()
            toggleSwitch.state = "on"
        }
    }
}
