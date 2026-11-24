import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as P5Support

PlasmoidItem {
    id: root

    // State properties
    property string thermal: "performance"
    property bool bypass: false
    property string bypassStatus: "Loading..."
    property bool online: false
    property int batterySoc: 100
    property real batteryWatts: 0.0
    property int torchPct: 0
    property bool torchOn: false
    property bool autoBrightness: false
    property bool autoRotate: true

    preferredRepresentation: fullRepresentation
    compactRepresentation: CompactRepresentation { }
    fullRepresentation: FullRepresentation { }

    toolTipMainText: "Erhai Controls (" + thermal + ")"
    toolTipSubText: "Bypass: " + (bypass ? "ON" : "OFF") + " · Torch: " + (torchOn ? (torchPct + "%") : "OFF")

    P5Support.DataSource {
        id: execSource
        engine: "executable"
        connectedSources: []

        onNewData: function(source, data) {
            disconnectSource(source)
            var out = (data["stdout"] || "").trim()
            if (!out) return

            // If it's JSON from `erhai-ctl json`
            if (out.startsWith("{") && out.endsWith("}")) {
                try {
                    var st = JSON.parse(out)
                    root.thermal = st.thermal || "performance"
                    root.bypass = !!st.bypass
                    root.bypassStatus = st.bypass_status || ""
                    root.online = !!st.online
                    root.batterySoc = st.battery_soc || 100
                    root.batteryWatts = st.battery_watts || 0.0
                    root.torchPct = st.torch_pct || 0
                    root.torchOn = !!st.torch_on
                    root.autoBrightness = !!st.autobrightness
                    root.autoRotate = !!st.autorotate
                } catch (e) {
                    console.log("Erhai Plasmoid: JSON parse error:", e)
                }
            } else {
                // Command executed, immediately refresh JSON state
                root.refreshState()
            }
        }
    }

    function refreshState() {
        execSource.connectSource("/usr/local/bin/erhai-ctl json")
    }

    function setThermal(prof) {
        root.thermal = prof
        execSource.connectSource("/usr/local/bin/erhai-ctl thermal " + prof)
    }

    function setBypass(enable) {
        root.bypass = enable
        execSource.connectSource("/usr/local/bin/erhai-ctl bypass " + (enable ? "on" : "off"))
    }

    function setTorch(pct) {
        root.torchPct = pct
        root.torchOn = pct > 0
        execSource.connectSource("/usr/local/bin/erhai-ctl torch " + pct)
    }

    function setAutoBrightness(enable) {
        root.autoBrightness = enable
        execSource.connectSource("/usr/local/bin/erhai-ctl autobrightness " + (enable ? "on" : "off"))
    }

    function setAutoRotate(enable) {
        root.autoRotate = enable
        execSource.connectSource("/usr/local/bin/erhai-ctl autorotate " + (enable ? "on" : "off"))
    }

    // Refresh state when expanded opens
    onExpandedChanged: function() {
        if (root.expanded) {
            root.refreshState()
        }
    }

    // Polling timer only runs while popup is open (zero battery drain when closed!)
    Timer {
        id: pollTimer
        interval: 3000
        running: root.expanded
        repeat: true
        onTriggered: root.refreshState()
    }

    Component.onCompleted: {
        refreshState()
    }
}
