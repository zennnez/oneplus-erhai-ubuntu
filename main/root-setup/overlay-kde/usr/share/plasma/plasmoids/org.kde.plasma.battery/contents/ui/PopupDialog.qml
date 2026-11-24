/*
    SPDX-FileCopyrightText: 2011 Viranch Mehta <viranch.mehta@gmail.com>
    SPDX-FileCopyrightText: 2013-2016 Kai Uwe Broulik <kde@privat.broulik.de>
    SPDX-FileCopyrightText: 2026 OnePlus Pad 3 Native Erhai Integration

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kirigami as Kirigami

PlasmaExtras.Representation {
    id: dialog

    property alias model: batteryRepeater.model
    property bool pluggedIn
    property int chargeStopThreshold
    property bool isManuallyInhibited
    property bool isManuallyInhibitedError

    property int remainingTime

    property bool profilesInstalled
    property string activeProfile
    property string activeProfileError
    property var profiles

    property bool isTlpInstalled
    property var requestedInhibitions: []
    property bool inhibitsLidAction
    property string inhibitionReason
    property string degradationReason
    required property var profileHolds

    signal inhibitionChangeRequested(bool inhibit)
    signal activateProfileRequested(string profile)

    collapseMarginsHint: true

    KeyNavigation.down: batteryRepeater.headerItem

    // Erhai Hardware States
    property string erhaiThermal: "balanced"
    property bool erhaiBypass: false
    property string erhaiBypassStatus: "Checking status..."
    property double erhaiWatts: 0.0
    property int erhaiChargeCap: 85
    property string erhaiRemainingStr: ""
    property string erhaiHealthStr: "Good"
    property string erhaiFastchgType: ""

    Plasma5Support.DataSource {
        id: erhaiSource
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            disconnectSource(sourceName)
            if (sourceName.indexOf("json") !== -1 && data["exit code"] === 0) {
                try {
                    var parsed = JSON.parse(data["stdout"])
                    dialog.erhaiThermal = parsed.thermal || "balanced"
                    dialog.erhaiBypass = !!parsed.bypass
                    dialog.erhaiBypassStatus = parsed.bypass_status || (parsed.bypass ? "Bypass active" : "Charging")
                    dialog.erhaiWatts = parsed.battery_watts || 0.0
                    dialog.erhaiChargeCap = parsed.charge_cap || 85
                    dialog.erhaiRemainingStr = parsed.remaining_str || ""
                    dialog.erhaiHealthStr = parsed.health_str || "Good"
                    dialog.erhaiFastchgType = parsed.fastchg_type || ""
                } catch(e) {}
            }
        }
    }

    function runErhai(cmd) {
        erhaiSource.connectSource(cmd)
    }

    function refreshErhai() {
        runErhai("/usr/local/bin/erhai-ctl json")
    }

    function setThermal(profile) {
        dialog.erhaiThermal = profile
        runErhai("/usr/local/bin/erhai-ctl thermal " + profile)
        refreshTimer.restart()
    }

    function toggleBypass() {
        var next = !dialog.erhaiBypass
        dialog.erhaiBypass = next
        runErhai("/usr/local/bin/erhai-ctl bypass " + (next ? "on" : "off"))
        refreshTimer.restart()
    }

    function setChargeCap(cap) {
        dialog.erhaiChargeCap = cap
        runErhai("/usr/local/bin/erhai-ctl charge-cap " + cap)
        refreshTimer.restart()
    }

    Timer {
        id: refreshTimer
        interval: 1000
        repeat: false
        onTriggered: dialog.refreshErhai()
    }

    Timer {
        interval: 4000
        running: dialog.visible
        repeat: true
        onTriggered: dialog.refreshErhai()
    }

    Component.onCompleted: dialog.refreshErhai()
    onVisibleChanged: {
        if (dialog.visible) dialog.refreshErhai()
    }

    contentItem: PlasmaComponents3.ScrollView {
        id: scrollView
        focus: false

        function positionViewAtItem(item: Item): void {
            if (!PlasmaComponents3.ScrollBar.vertical.visible) {
                return;
            }
            const rect = batteryRepeater.contentItem.mapFromItem(item, 0, 0, item.width, item.height);
            if (rect.y < scrollView.contentItem.contentY) {
                scrollView.contentItem.contentY = rect.y;
            } else if (rect.y + rect.height > scrollView.contentItem.contentY + scrollView.height) {
                scrollView.contentItem.contentY = rect.y + rect.height - scrollView.height;
            }
        }

        ListView {
            id: batteryRepeater
            spacing: Kirigami.Units.smallSpacing * 2

            header: Column {
                width: scrollView.availableWidth
                spacing: Kirigami.Units.smallSpacing * 2

                // --- ERHAI THERMAL PROFILES SECTION ---
                PlasmaComponents3.ItemDelegate {
                    width: parent.width
                    hoverEnabled: false

                    contentItem: ColumnLayout {
                        spacing: Kirigami.Units.smallSpacing

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Kirigami.Units.smallSpacing

                            Kirigami.Icon {
                                Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                                Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                                source: "speedometer"
                            }

                            PlasmaComponents3.Label {
                                text: i18n("Thermal Profile")
                                font.bold: true
                                Layout.fillWidth: true
                            }

                            PlasmaComponents3.Label {
                                text: {
                                    switch(dialog.erhaiThermal) {
                                        case "performance": return i18n("Performance (~103°C)");
                                        case "balanced": return i18n("Balanced (~90°C)");
                                        case "cool": return i18n("Cool (~80°C)");
                                        case "cold": return i18n("Cold (~70°C)");
                                        default: return dialog.erhaiThermal;
                                    }
                                }
                                color: Kirigami.Theme.highlightColor
                                font.pointSize: Kirigami.Theme.smallFont.pointSize
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Kirigami.Units.smallSpacing

                            PlasmaComponents3.Button {
                                Layout.fillWidth: true
                                text: i18n("Performance")
                                checked: dialog.erhaiThermal === "performance"
                                checkable: true
                                onClicked: dialog.setThermal("performance")
                            }

                            PlasmaComponents3.Button {
                                Layout.fillWidth: true
                                text: i18n("Balanced")
                                checked: dialog.erhaiThermal === "balanced"
                                checkable: true
                                onClicked: dialog.setThermal("balanced")
                            }

                            PlasmaComponents3.Button {
                                Layout.fillWidth: true
                                text: i18n("Cool")
                                checked: dialog.erhaiThermal === "cool"
                                checkable: true
                                onClicked: dialog.setThermal("cool")
                            }

                            PlasmaComponents3.Button {
                                Layout.fillWidth: true
                                text: i18n("Cold")
                                checked: dialog.erhaiThermal === "cold"
                                checkable: true
                                onClicked: dialog.setThermal("cold")
                            }
                        }
                    }
                }

                // --- ERHAI BYPASS CHARGING SECTION ---
                PlasmaComponents3.ItemDelegate {
                    width: parent.width
                    hoverEnabled: false

                    contentItem: RowLayout {
                        spacing: Kirigami.Units.mediumSpacing

                        Kirigami.Icon {
                            Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                            Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                            source: dialog.erhaiBypass ? "battery-profile-powersave" : "battery-charging"
                            color: dialog.erhaiBypass ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Kirigami.Units.smallSpacing / 2

                            PlasmaComponents3.Label {
                                text: i18n("Bypass Charging")
                                font.bold: true
                            }

                            PlasmaComponents3.Label {
                                text: dialog.erhaiBypass 
                                    ? i18n("Active — Running on adapter power only")
                                    : dialog.erhaiBypassStatus
                                color: dialog.erhaiBypass ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.disabledTextColor
                                font.pointSize: Kirigami.Theme.smallFont.pointSize
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }

                        PlasmaComponents3.Switch {
                            checked: dialog.erhaiBypass
                            onToggled: dialog.toggleBypass()
                        }
                    }
                }

                // --- ERHAI CHARGING CAP SECTION ---
                PlasmaComponents3.ItemDelegate {
                    width: parent.width
                    hoverEnabled: false

                    contentItem: ColumnLayout {
                        spacing: Kirigami.Units.smallSpacing

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Kirigami.Units.mediumSpacing

                            Kirigami.Icon {
                                Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                                Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                                source: "kt-speed-limits"
                            }

                            PlasmaComponents3.Label {
                                text: i18n("Charging Cap")
                                font.bold: true
                                Layout.fillWidth: true
                            }

                            PlasmaComponents3.Label {
                                text: dialog.erhaiChargeCap >= 100 ? i18n("100% (No limit)") : i18n("%1%", dialog.erhaiChargeCap)
                                color: Kirigami.Theme.highlightColor
                                font.pointSize: Kirigami.Theme.smallFont.pointSize
                            }
                        }

                        GridLayout {
                            Layout.fillWidth: true
                            columns: 5
                            rowSpacing: Kirigami.Units.smallSpacing
                            columnSpacing: Kirigami.Units.smallSpacing

                            Repeater {
                                model: [55, 60, 65, 70, 75, 80, 85, 90, 95, 100]
                                PlasmaComponents3.Button {
                                    Layout.fillWidth: true
                                    text: modelData === 100 ? "100%" : (modelData + "%")
                                    checked: dialog.erhaiChargeCap === modelData
                                    checkable: true
                                    onClicked: dialog.setChargeCap(modelData)
                                }
                            }
                        }
                    }
                }

                Kirigami.Separator {
                    width: parent.width
                }
            }

            delegate: BatteryItem {
                width: scrollView.availableWidth

                batteryPercent: Percent
                batteryCapacity: Capacity
                batteryEnergy: Energy
                batteryPluggedIn: PluggedIn
                batteryIsPowerSupply: IsPowerSupply
                batteryChargeState: ChargeState
                batteryPrettyName: PrettyName
                batteryType: Type
                remainingTime: dialog.remainingTime

                KeyNavigation.up: index === 0 ? null : batteryRepeater.itemAtIndex(index - 1)
                KeyNavigation.down: index + 1 < batteryRepeater.count ? batteryRepeater.itemAtIndex(index + 1) : batteryRepeater.footerItem

                pluggedIn: dialog.pluggedIn
                chargeStopThreshold: dialog.chargeStopThreshold

                KeyNavigation.backtab: KeyNavigation.up
                KeyNavigation.tab: KeyNavigation.down

                Keys.onTabPressed: event => {
                    if (index === batteryRepeater.count - 1) {
                        nextItemInFocusChain(false).forceActiveFocus(Qt.TabFocusReason);
                    } else {
                        event.accepted = false;
                    }
                }

                onActiveFocusChanged: if (activeFocus) scrollView.positionViewAtItem(this)
            }

            footer: InhibitionItem {
                readonly property var inhibitionControl: dialog.inhibitionControl

                width: scrollView.availableWidth

                KeyNavigation.up: batteryRepeater.itemAtIndex(batteryRepeater.count - 1)
                KeyNavigation.down: null
                KeyNavigation.backtab:KeyNavigation.up

                requestedInhibitions: dialog.requestedInhibitions
                isManuallyInhibited: dialog.isManuallyInhibited
                isManuallyInhibitedError: dialog.isManuallyInhibitedError
                inhibitsLidAction: dialog.inhibitsLidAction
                pluggedIn: dialog.pluggedIn

                onInhibitionChangeRequested: inhibit => {
                    batterymonitor.inhibitionChangeRequested(inhibit);
                }

                onActiveFocusChanged: if (activeFocus) scrollView.positionViewAtItem(this)
            }
        }
    }
}