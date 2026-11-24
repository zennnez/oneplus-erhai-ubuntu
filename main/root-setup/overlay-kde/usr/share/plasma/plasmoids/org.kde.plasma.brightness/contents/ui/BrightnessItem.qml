/*
    SPDX-FileCopyrightText: 2012-2013 Daniel Nicoletti <dantti12@gmail.com>
    SPDX-FileCopyrightText: 2013, 2015 Kai Uwe Broulik <kde@privat.broulik.de>
    SPDX-FileCopyrightText: 2026 OnePlus Pad 3 Native Erhai Integration

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kirigami as Kirigami

PlasmaComponents3.ItemDelegate {
    id: root

    enum Type {
        Screen,
        Keyboard
    }

    property alias slider: control
    property real value
    property alias minimumValue: control.from
    property alias maximumValue: control.to
    property alias stepSize: control.stepSize
    required property int type

    // Hardware State for Display
    property bool adaptiveBrightness: false
    property bool autoRotate: false

    Plasma5Support.DataSource {
        id: erhaiSource
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            disconnectSource(sourceName)
            if (sourceName.indexOf("json") !== -1 && data["exit code"] === 0) {
                try {
                    var parsed = JSON.parse(data["stdout"])
                    root.adaptiveBrightness = !!parsed.autobrightness
                    root.autoRotate = !!parsed.autorotate
                } catch(e) {}
            }
        }
    }

    function runCmd(cmd) {
        erhaiSource.connectSource(cmd)
    }

    function refreshHardware() {
        if (root.type === BrightnessItem.Type.Screen) {
            runCmd("/usr/local/bin/erhai-ctl json")
        }
    }

    function toggleAdaptive() {
        var next = !root.adaptiveBrightness
        root.adaptiveBrightness = next
        runCmd("/usr/local/bin/erhai-ctl autobrightness " + (next ? "on" : "off"))
        refreshTimer.restart()
    }

    function toggleAutoRotate() {
        var next = !root.autoRotate
        root.autoRotate = next
        runCmd("/usr/local/bin/erhai-ctl autorotate " + (next ? "on" : "off"))
        refreshTimer.restart()
    }

    Timer {
        id: refreshTimer
        interval: 1000
        repeat: false
        onTriggered: root.refreshHardware()
    }

    Timer {
        interval: 3000
        running: root.visible && root.type === BrightnessItem.Type.Screen
        repeat: true
        onTriggered: root.refreshHardware()
    }

    Component.onCompleted: {
        if (root.type === BrightnessItem.Type.Screen) {
            root.refreshHardware()
        }
    }

    Binding {
        when: !control.pressed
        control.value: root.value
    }

    readonly property real percentage: Math.round(100 * value / maximumValue)
    readonly property string brightnessLevelOff: i18nc("Backlight on or off", "Off")
    readonly property string brightnessLevelLow: i18nc("Brightness level", "Low")
    readonly property string brightnessLevelMedium: i18nc("Brightness level", "Medium")
    readonly property string brightnessLevelHigh: i18nc("Brightness level", "High")
    readonly property string brightnessLevelOn: i18nc("Backlight on or off", "On")
    readonly property string labelText: {
        if (maximumValue == 1) {
            const levels = [brightnessLevelOff, brightnessLevelOn];
            return levels[value];
        } else if (maximumValue == 2) {
            const levels = [brightnessLevelOff, brightnessLevelLow, brightnessLevelHigh];
            return levels[value];
        } else if (maximumValue == 3) {
            const levels = [brightnessLevelOff, brightnessLevelLow, brightnessLevelMedium, brightnessLevelHigh];
            return levels[value];
        } else {
            return i18nc("Placeholder is brightness percentage", "%1%", percentage);
        }
    }

    signal moved()

    background.visible: highlighted
    highlighted: activeFocus
    hoverEnabled: false

    Accessible.ignored: true
    Keys.forwardTo: [slider]

    contentItem: RowLayout {
        spacing: Kirigami.Units.gridUnit

        Kirigami.Icon {
            id: image
            Layout.alignment: Qt.AlignTop
            Layout.preferredWidth: Kirigami.Units.iconSizes.medium
            Layout.preferredHeight: Kirigami.Units.iconSizes.medium
            source: root.icon.name
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            spacing: Kirigami.Units.smallSpacing

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                PlasmaComponents3.Label {
                    id: title
                    text: root.text
                    textFormat: Text.PlainText
                    elide: Text.ElideRight
                    Accessible.ignored: true
                    font.bold: true
                }

                PlasmaComponents3.Button {
                    id: adaptiveBtn
                    visible: root.type === BrightnessItem.Type.Screen
                    icon.name: root.adaptiveBrightness ? "brightness-high" : "brightness-low"
                    text: i18n("Auto")
                    checkable: true
                    checked: root.adaptiveBrightness
                    onClicked: root.toggleAdaptive()
                }

                PlasmaComponents3.Button {
                    id: rotateBtn
                    visible: root.type === BrightnessItem.Type.Screen
                    icon.name: "rotation-allowed"
                    text: i18n("Rotate")
                    checkable: true
                    checked: root.autoRotate
                    onClicked: root.toggleAutoRotate()
                }

                Item {
                    Layout.fillWidth: true
                }

                PlasmaComponents3.Label {
                    id: hint
                    text: i18nc("Display brightness", "Brightness")
                    textFormat: Text.PlainText
                    opacity: 0.75
                    visible: labelText != brightnessLevelOff && labelText != brightnessLevelOn
                }

                PlasmaComponents3.Label {
                    id: brightnessValue
                    Layout.alignment: Qt.AlignRight
                    text: root.labelText
                    textFormat: Text.PlainText
                    Accessible.ignored: true
                }
            }

            PlasmaComponents3.Slider {
                id: control
                Layout.fillWidth: true

                activeFocusOnTab: false
                from: 0
                stepSize: 1

                Accessible.name: root.type === BrightnessItem.Type.Screen ? i18nc("Placeholder is display name", "Display Brightness - %1", root.text) : root.text
                Accessible.description: brightnessValue.text
                Accessible.onPressAction: this.moved()

                onMoved: {
                    root.value = value
                    root.moved()
                }
            }
        }
    }
}