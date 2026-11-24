import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami

Item {
    id: fullRoot

    Layout.minimumWidth: Kirigami.Units.gridUnit * 19
    Layout.preferredWidth: Kirigami.Units.gridUnit * 21
    Layout.maximumWidth: Kirigami.Units.gridUnit * 25

    Layout.minimumHeight: contentColumn.implicitHeight + Kirigami.Units.gridUnit * 1.5
    Layout.preferredHeight: Layout.minimumHeight

    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing
        spacing: Kirigami.Units.largeSpacing

        // ---- Header ----
        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Icon {
                source: "preferences-system-power-management"
                implicitWidth: Kirigami.Units.iconSizes.medium
                implicitHeight: Kirigami.Units.iconSizes.medium
                color: Kirigami.Theme.highlightColor
            }

            ColumnLayout {
                spacing: 0
                PC3.Label {
                    text: "Erhai Controls"
                    font.weight: Font.Bold
                    font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.15
                }
                PC3.Label {
                    text: "OnePlus Pad 3 Hardware"
                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                    opacity: 0.7
                }
            }

            Item { Layout.fillWidth: true }

            PC3.Button {
                icon.name: "view-refresh"
                flat: true
                onClicked: root.refreshState()
                PC3.ToolTip { text: "Refresh status" }
            }
        }

        Kirigami.Separator { Layout.fillWidth: true }

        // ---- Section 1: Thermal Profile ----
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            RowLayout {
                spacing: Kirigami.Units.smallSpacing
                Kirigami.Icon {
                    source: "temperature-symbolic"
                    implicitWidth: Kirigami.Units.iconSizes.small
                    implicitHeight: Kirigami.Units.iconSizes.small
                }
                PC3.Label {
                    text: "Thermal Profile"
                    font.weight: Font.DemiBold
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: Kirigami.Units.smallSpacing
                columnSpacing: Kirigami.Units.smallSpacing

                PC3.Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 2.5
                    checkable: true
                    checked: root.thermal === "performance"
                    text: "⚡ Performance (~103°C)"
                    font.weight: checked ? Font.Bold : Font.Normal
                    onClicked: root.setThermal("performance")
                }

                PC3.Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 2.5
                    checkable: true
                    checked: root.thermal === "balanced"
                    text: "⚖️ Balanced (~90°C)"
                    font.weight: checked ? Font.Bold : Font.Normal
                    onClicked: root.setThermal("balanced")
                }

                PC3.Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 2.5
                    checkable: true
                    checked: root.thermal === "cool"
                    text: "❄️ Cool (~80°C)"
                    font.weight: checked ? Font.Bold : Font.Normal
                    onClicked: root.setThermal("cool")
                }

                PC3.Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 2.5
                    checkable: true
                    checked: root.thermal === "cold"
                    text: "🧊 Cold (~70°C)"
                    font.weight: checked ? Font.Bold : Font.Normal
                    onClicked: root.setThermal("cold")
                }
            }
        }

        Kirigami.Separator { Layout.fillWidth: true }

        // ---- Section 2: Bypass Charging ----
        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.largeSpacing

            Kirigami.Icon {
                source: root.bypass ? "ac-adapter-symbolic" : "battery-charging"
                implicitWidth: Kirigami.Units.iconSizes.medium
                implicitHeight: Kirigami.Units.iconSizes.medium
                color: root.bypass ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                PC3.Label {
                    text: "Bypass Charging"
                    font.weight: Font.DemiBold
                }
                PC3.Label {
                    text: root.bypassStatus
                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                    opacity: 0.75
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }

            PC3.Switch {
                id: bypassSwitch
                checked: root.bypass
                onToggled: root.setBypass(checked)
            }
        }

        Kirigami.Separator { Layout.fillWidth: true }

        // ---- Section 3: Rear Flashlight / Torch ----
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.largeSpacing

                Kirigami.Icon {
                    source: root.torchOn ? "flashlight-on" : "flashlight-off"
                    implicitWidth: Kirigami.Units.iconSizes.medium
                    implicitHeight: Kirigami.Units.iconSizes.medium
                    color: root.torchOn ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.textColor
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    PC3.Label {
                        text: "Rear Flashlight (Torch)"
                        font.weight: Font.DemiBold
                    }
                    PC3.Label {
                        text: root.torchOn ? ("Active: " + root.torchPct + "%") : "Off"
                        font.pointSize: Kirigami.Theme.smallFont.pointSize
                        opacity: 0.75
                    }
                }

                PC3.Switch {
                    id: torchSwitch
                    checked: root.torchOn
                    onToggled: root.setTorch(checked ? (root.torchPct > 0 ? root.torchPct : 33) : 0)
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing
                visible: root.torchOn || torchSlider.value > 0

                PC3.Label {
                    text: "Brightness:"
                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                    opacity: 0.8
                }

                PC3.Slider {
                    id: torchSlider
                    Layout.fillWidth: true
                    from: 5
                    to: 100
                    stepSize: 5
                    value: root.torchPct > 0 ? root.torchPct : 33
                    onMoved: root.setTorch(Math.round(value))
                }

                PC3.Label {
                    text: Math.round(torchSlider.value) + "%"
                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                    font.weight: Font.Bold
                    Layout.minimumWidth: Kirigami.Units.gridUnit * 2
                }
            }
        }

        Kirigami.Separator { Layout.fillWidth: true }

        // ---- Section 4: Sensors & Display Toggles ----
        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.largeSpacing

            // Auto-Brightness
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Kirigami.Icon {
                    source: "display-brightness-symbolic"
                    implicitWidth: Kirigami.Units.iconSizes.smallMedium
                    implicitHeight: Kirigami.Units.iconSizes.smallMedium
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    PC3.Label {
                        text: "Auto-Brightness"
                        font.weight: Font.DemiBold
                        font.pointSize: Kirigami.Theme.smallFont.pointSize * 1.05
                    }
                    PC3.Label {
                        text: "Ambient sensor"
                        font.pointSize: Kirigami.Theme.smallFont.pointSize * 0.9
                        opacity: 0.7
                    }
                }

                PC3.Switch {
                    checked: root.autoBrightness
                    onToggled: root.setAutoBrightness(checked)
                }
            }

            // Auto-Rotate
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Kirigami.Icon {
                    source: "rotation-allowed-symbolic"
                    implicitWidth: Kirigami.Units.iconSizes.smallMedium
                    implicitHeight: Kirigami.Units.iconSizes.smallMedium
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    PC3.Label {
                        text: "Auto-Rotate"
                        font.weight: Font.DemiBold
                        font.pointSize: Kirigami.Theme.smallFont.pointSize * 1.05
                    }
                    PC3.Label {
                        text: "Orientation"
                        font.pointSize: Kirigami.Theme.smallFont.pointSize * 0.9
                        opacity: 0.7
                    }
                }

                PC3.Switch {
                    checked: root.autoRotate
                    onToggled: root.setAutoRotate(checked)
                }
            }
        }

        // Bottom status note
        PC3.Label {
            Layout.fillWidth: true
            text: "Battery: " + root.batterySoc + "% · " + (root.online ? "Charger connected" : "On battery")
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            opacity: 0.6
        }
    }
}
