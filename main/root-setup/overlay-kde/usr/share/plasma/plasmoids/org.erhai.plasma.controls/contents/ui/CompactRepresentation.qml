import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.ksvg as KSvg
import org.kde.kirigami as Kirigami

Item {
    id: compactRoot

    readonly property bool inPanel: Plasmoid.location === PlasmaCore.Types.TopEdge
                                 || Plasmoid.location === PlasmaCore.Types.BottomEdge
                                 || Plasmoid.location === PlasmaCore.Types.LeftEdge
                                 || Plasmoid.location === PlasmaCore.Types.RightEdge

    Layout.minimumWidth: Kirigami.Units.gridUnit * 2
    Layout.minimumHeight: Kirigami.Units.gridUnit * 2
    Layout.preferredWidth: inPanel ? Kirigami.Units.gridUnit * 2.8 : Kirigami.Units.gridUnit * 3
    Layout.preferredHeight: Kirigami.Units.gridUnit * 2.5

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.expanded = !root.expanded
    }

    RowLayout {
        anchors.centerIn: parent
        spacing: Kirigami.Units.smallSpacing

        Kirigami.Icon {
            id: mainIcon
            Layout.alignment: Qt.AlignCenter
            implicitWidth: Kirigami.Units.iconSizes.smallMedium
            implicitHeight: Kirigami.Units.iconSizes.smallMedium
            source: {
                if (root.torchOn) return "flashlight-on";
                if (root.bypass) return "ac-adapter-symbolic";
                return "preferences-system-power-management";
            }
            color: {
                if (root.torchOn) return Kirigami.Theme.positiveTextColor;
                if (root.bypass) return Kirigami.Theme.highlightColor;
                if (root.thermal === "performance") return Kirigami.Theme.negativeTextColor;
                if (root.thermal === "balanced") return Kirigami.Theme.neutralTextColor;
                return Kirigami.Theme.textColor;
            }
        }

        Text {
            id: badgeText
            Layout.alignment: Qt.AlignCenter
            visible: compactRoot.width > Kirigami.Units.gridUnit * 2.5
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            font.weight: Font.DemiBold
            color: Kirigami.Theme.textColor
            text: {
                switch (root.thermal) {
                    case "performance": return "Perf";
                    case "balanced":    return "Bal";
                    case "cool":        return "Cool";
                    case "cold":        return "Cold";
                    default:            return "";
                }
            }
        }
    }
}
