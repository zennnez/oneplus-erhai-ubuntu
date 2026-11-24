import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    property int brightness: 0
    property bool torchOn: brightness > 0

    Plasmoid.icon: torchOn ? "flashlight-on" : "flashlight-off"
    toolTipMainText: i18n("Torch")
    toolTipSubText: torchOn ? i18n("On (%1%)", brightness) : i18n("Off")

    Plasma5Support.DataSource {
        id: execSource
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            disconnectSource(sourceName)
            if (sourceName.indexOf("json") !== -1 && data["exit code"] === 0) {
                try {
                    var parsed = JSON.parse(data["stdout"])
                    root.brightness = parsed.torch_pct || 0
                } catch(e) {}
            }
        }
    }

    function runCmd(cmd) {
        execSource.connectSource(cmd)
    }

    function refresh() {
        runCmd("/usr/local/bin/erhai-ctl json")
    }

    function setTorch(val) {
        root.brightness = val
        runCmd("/usr/local/bin/erhai-ctl torch " + val)
    }

    function toggleTorch() {
        if (root.torchOn) {
            setTorch(0)
        } else {
            setTorch(100)
        }
    }

    Timer {
        interval: 3000
        running: root.expanded
        repeat: true
        onTriggered: root.refresh()
    }

    Component.onCompleted: root.refresh()
    onExpandedChanged: {
        if (root.expanded) {
            root.refresh()
        }
    }

    compactRepresentation: MouseArea {
        id: compactArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.toggleTorch()

        Kirigami.Icon {
            anchors.centerIn: parent
            width: Math.min(parent.width, parent.height) - Kirigami.Units.smallSpacing * 2
            height: width
            source: root.torchOn ? "flashlight-on" : "flashlight-off"
            color: root.torchOn ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
        }
    }

    fullRepresentation: ColumnLayout {
        id: fullLayout
        spacing: Kirigami.Units.largeSpacing
        Layout.preferredWidth: Kirigami.Units.gridUnit * 18
        Layout.preferredHeight: Kirigami.Units.gridUnit * 11

        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Icon {
                Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                source: root.torchOn ? "flashlight-on" : "flashlight-off"
                color: root.torchOn ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
            }

            PlasmaComponents3.Label {
                text: i18n("Torch / Flashlight")
                font.bold: true
                font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.1
                Layout.fillWidth: true
            }

            PlasmaComponents3.Switch {
                id: torchSwitch
                checked: root.torchOn
                onToggled: root.toggleTorch()
            }
        }

        PlasmaComponents3.Label {
            text: root.torchOn ? i18n("Brightness: %1%", root.brightness) : i18n("Torch is turned off")
            color: Kirigami.Theme.disabledTextColor
        }

        PlasmaComponents3.Slider {
            id: slider
            Layout.fillWidth: true
            from: 0
            to: 100
            stepSize: 5
            value: root.brightness
            onMoved: {
                root.setTorch(Math.round(value))
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            PlasmaComponents3.Button {
                text: "Off"
                Layout.fillWidth: true
                checked: root.brightness === 0
                onClicked: root.setTorch(0)
            }
            PlasmaComponents3.Button {
                text: "25%"
                Layout.fillWidth: true
                checked: root.brightness === 25
                onClicked: root.setTorch(25)
            }
            PlasmaComponents3.Button {
                text: "50%"
                Layout.fillWidth: true
                checked: root.brightness === 50
                onClicked: root.setTorch(50)
            }
            PlasmaComponents3.Button {
                text: "100%"
                Layout.fillWidth: true
                checked: root.brightness === 100
                onClicked: root.setTorch(100)
            }
        }
    }
}