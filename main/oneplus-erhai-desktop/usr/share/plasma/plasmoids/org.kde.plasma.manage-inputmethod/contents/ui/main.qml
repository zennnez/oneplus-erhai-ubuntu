/*
 * SPDX-FileCopyrightText: 2026 OnePlus Pad 3 Native Erhai Integration
 * SPDX-License-Identifier: LGPL-3.0-only
 */

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    property bool vkEnabled: true
    property bool vkActive: false
    property bool vkVisible: false
    property string vkEngine: "plasma-custom"
    property string vkEngineName: "Plasma Keyboard Custom"

    Plasmoid.icon: "input-keyboard-virtual"
    Plasmoid.title: i18n("Virtual Keyboard")
    toolTipMainText: i18n("Virtual Keyboard")
    toolTipSubText: vkEnabled ? (vkActive ? i18n("Active (%1)", vkEngineName) : i18n("Standby (%1)", vkEngineName)) : i18n("Disabled")

    Plasma5Support.DataSource {
        id: execSource
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            disconnectSource(sourceName)
            if (data["exit code"] === 0 && sourceName.indexOf("vk json") !== -1) {
                try {
                    var parsed = JSON.parse(data["stdout"])
                    root.vkEnabled = parsed.enabled
                    root.vkActive = parsed.active
                    root.vkVisible = parsed.visible
                    root.vkEngine = parsed.engine
                    root.vkEngineName = parsed.engine_name
                } catch(e) {}
            }
        }
    }

    function runCmd(cmd) {
        execSource.connectSource(cmd)
    }

    function refresh() {
        runCmd("/usr/local/bin/erhai-ctl vk json")
    }

    function setEnabled(val) {
        root.vkEnabled = val
        runCmd(val ? "/usr/local/bin/erhai-ctl vk enable" : "/usr/local/bin/erhai-ctl vk disable")
        refreshTimer.restart()
    }

    function setEngine(engineKey) {
        root.vkEngine = engineKey
        runCmd("/usr/local/bin/erhai-ctl vk engine " + engineKey)
        refreshTimer.restart()
    }

    function toggleVisibility() {
        runCmd("/usr/local/bin/erhai-ctl vk toggle")
        refreshTimer.restart()
    }

    Timer {
        id: refreshTimer
        interval: 800
        onTriggered: root.refresh()
    }

    Timer {
        interval: 3000
        running: true
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
        activeFocusOnTab: true

        onClicked: {
            root.expanded = !root.expanded
        }

        Item {
            anchors.centerIn: parent
            width: Math.min(parent.width, parent.height) - Kirigami.Units.smallSpacing * 2
            height: width

            Kirigami.Icon {
                anchors.fill: parent
                source: "input-keyboard-virtual"
                active: compactArea.containsMouse || compactArea.activeFocus
                color: root.vkActive && root.vkEnabled ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.textColor
            }

            Rectangle {
                width: Math.max(6, Math.round(parent.width * 0.28))
                height: width
                radius: width / 2
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                color: root.vkActive && root.vkEnabled ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.disabledTextColor
                visible: root.vkActive && root.vkEnabled
                border.width: 1
                border.color: Kirigami.Theme.backgroundColor
            }
        }
    }

    fullRepresentation: ColumnLayout {
        id: fullLayout
        spacing: Kirigami.Units.largeSpacing
        Layout.preferredWidth: Kirigami.Units.gridUnit * 20
        Layout.preferredHeight: Kirigami.Units.gridUnit * 18

        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Icon {
                Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                source: "input-keyboard-virtual"
                color: root.vkActive && root.vkEnabled ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.textColor
            }

            PlasmaComponents3.Label {
                text: i18n("Virtual Keyboard")
                font.bold: true
                font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.15
                Layout.fillWidth: true
            }

            PlasmaComponents3.Switch {
                id: enableSwitch
                checked: root.vkEnabled
                onToggled: root.setEnabled(checked)
            }
        }

        PlasmaComponents3.Label {
            text: root.vkEnabled ? (root.vkActive ? i18n("Active · %1", root.vkEngineName) : i18n("Standby · %1", root.vkEngineName)) : i18n("Virtual Keyboard is turned off")
            color: root.vkActive && root.vkEnabled ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.disabledTextColor
            font.pointSize: Kirigami.Theme.smallFont.pointSize
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        PlasmaComponents3.Label {
            text: i18n("Active Keyboard Engine:")
            font.bold: true
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            PlasmaComponents3.RadioButton {
                text: i18n("Plasma Keyboard Custom (Full Layout)")
                checked: root.vkEngine === "plasma-custom"
                enabled: root.vkEnabled
                onClicked: root.setEngine("plasma-custom")
            }

            PlasmaComponents3.RadioButton {
                text: i18n("Maliit Keyboard")
                checked: root.vkEngine === "maliit"
                enabled: root.vkEnabled
                onClicked: root.setEngine("maliit")
            }

            PlasmaComponents3.RadioButton {
                text: i18n("Default Plasma Keyboard")
                checked: root.vkEngine === "plasma"
                enabled: root.vkEnabled
                onClicked: root.setEngine("plasma")
            }

            PlasmaComponents3.RadioButton {
                text: i18n("None / Disabled")
                checked: root.vkEngine === "none" || !root.vkEnabled
                onClicked: root.setEngine("none")
            }
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            PlasmaComponents3.Button {
                text: root.vkVisible ? i18n("Hide Keyboard") : i18n("Show Keyboard")
                icon.name: "input-keyboard-virtual"
                Layout.fillWidth: true
                enabled: root.vkEnabled && root.vkEngine !== "none"
                onClicked: root.toggleVisibility()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            PlasmaComponents3.Button {
                text: i18n("KDE Virtual Keyboard...")
                icon.name: "preferences-system-windows"
                Layout.fillWidth: true
                onClicked: {
                    root.runCmd("WAYLAND_DISPLAY=wayland-0 kcmshell6 kcm_virtualkeyboard")
                    root.expanded = false
                }
            }

            PlasmaComponents3.Button {
                text: i18n("Layout Settings...")
                icon.name: "configure"
                Layout.fillWidth: true
                visible: root.vkEngine === "plasma-custom"
                onClicked: {
                    root.runCmd("WAYLAND_DISPLAY=wayland-0 kcmshell6 kcm_plasmakeyboardcustom")
                    root.expanded = false
                }
            }
        }
    }
}
