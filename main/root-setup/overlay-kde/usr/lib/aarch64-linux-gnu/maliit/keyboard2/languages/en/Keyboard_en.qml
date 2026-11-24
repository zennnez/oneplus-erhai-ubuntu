/*
 * SPDX-FileCopyrightText: 2013 Canonical Ltd.
 * SPDX-FileCopyrightText: 2026 OnePlus Pad 3 Native Erhai Integration
 *
 * SPDX-License-Identifier: LGPL-3.0-only
 */

import QtQuick 2.4
import QtQuick.Window 2.2
import MaliitKeyboard 2.0
import keys 1.0

KeyPad {
    id: rootKeypad
    anchors.fill: parent

    // True screen orientation detection (distinguishes physical tablet rotation)
    readonly property bool isPortrait: (Screen.primaryOrientation === Qt.PortraitOrientation ||
                                        Screen.primaryOrientation === Qt.InvertedPortraitOrientation ||
                                        Screen.width < Screen.height)

    content: isPortrait ? portraitCol : landscapeCol
    symbols: "languages/Keyboard_symbols.qml"

    // Vertical gap between rows, scaled to physical screen density (~1.6 mm), clamped to sane bounds
    readonly property real rowGap: Math.min(16, Math.max(6, Math.round(Screen.pixelDensity * 1.6)))

    // 15 equal columns in landscape with 12px horizontal margin; 6 rows, 5 gaps, 8px top/bottom margin
    readonly property real unitW_land: Math.floor((parent.width - 24) / 15.0)
    readonly property real unitH_land: Math.floor((parent.height - 8 - 5 * rowGap) / 6.0)

    // 10 equal columns in portrait; 5 rows, 4 gaps, 8px top/bottom margin
    readonly property real unitW_port: Math.floor((parent.width - 20) / 10.0)
    readonly property real unitH_port: Math.floor((parent.height - 8 - 4 * rowGap) / 5.0)

    // =========================================================================
    // LANDSCAPE: Full TKL-inspired physical layout (15 columns x 6 rows)
    // =========================================================================
    Column {
        id: landscapeCol
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        anchors.topMargin: 4
        anchors.bottomMargin: 4
        visible: !rootKeypad.isPortrait
        spacing: rootKeypad.rowGap

        // Row 0: Function & System keys (15 units)
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 0

            CharKey { label: "Esc"; shifted: "Esc"; valueToSubmit: "\u001b"; width: unitW_land; height: unitH_land; fontSize: 13; noMagnifier: true }
            CharKey { label: "F1";  shifted: "F1";  width: unitW_land; height: unitH_land; fontSize: 13; noMagnifier: true }
            CharKey { label: "F2";  shifted: "F2";  width: unitW_land; height: unitH_land; fontSize: 13; noMagnifier: true }
            CharKey { label: "F3";  shifted: "F3";  width: unitW_land; height: unitH_land; fontSize: 13; noMagnifier: true }
            CharKey { label: "F4";  shifted: "F4";  width: unitW_land; height: unitH_land; fontSize: 13; noMagnifier: true }
            CharKey { label: "F5";  shifted: "F5";  width: unitW_land; height: unitH_land; fontSize: 13; noMagnifier: true }
            CharKey { label: "F6";  shifted: "F6";  width: unitW_land; height: unitH_land; fontSize: 13; noMagnifier: true }
            CharKey { label: "F7";  shifted: "F7";  width: unitW_land; height: unitH_land; fontSize: 13; noMagnifier: true }
            CharKey { label: "F8";  shifted: "F8";  width: unitW_land; height: unitH_land; fontSize: 13; noMagnifier: true }
            CharKey { label: "F9";  shifted: "F9";  width: unitW_land; height: unitH_land; fontSize: 13; noMagnifier: true }
            CharKey { label: "F10"; shifted: "F10"; width: unitW_land; height: unitH_land; fontSize: 12; noMagnifier: true }
            CharKey { label: "F11"; shifted: "F11"; width: unitW_land; height: unitH_land; fontSize: 12; noMagnifier: true }
            CharKey { label: "F12"; shifted: "F12"; width: unitW_land; height: unitH_land; fontSize: 12; noMagnifier: true }
            CharKey { label: "PrtSc"; shifted: "PrtSc"; width: unitW_land; height: unitH_land; fontSize: 11; noMagnifier: true }
            CharKey { label: "Del"; shifted: "Del"; width: unitW_land; height: unitH_land; fontSize: 13; noMagnifier: true; action: "backspace" }
        }

        // Row 1: Numbers & symbols (15 units)
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 0

            CharKey { label: "`"; shifted: "~"; width: unitW_land; height: unitH_land }
            CharKey { label: "1"; shifted: "!"; width: unitW_land; height: unitH_land }
            CharKey { label: "2"; shifted: "@"; width: unitW_land; height: unitH_land }
            CharKey { label: "3"; shifted: "#"; width: unitW_land; height: unitH_land }
            CharKey { label: "4"; shifted: "$"; width: unitW_land; height: unitH_land }
            CharKey { label: "5"; shifted: "%"; width: unitW_land; height: unitH_land }
            CharKey { label: "6"; shifted: "^"; width: unitW_land; height: unitH_land }
            CharKey { label: "7"; shifted: "&"; width: unitW_land; height: unitH_land }
            CharKey { label: "8"; shifted: "*"; width: unitW_land; height: unitH_land }
            CharKey { label: "9"; shifted: "("; width: unitW_land; height: unitH_land }
            CharKey { label: "0"; shifted: ")"; width: unitW_land; height: unitH_land }
            CharKey { label: "-"; shifted: "_"; width: unitW_land; height: unitH_land }
            CharKey { label: "="; shifted: "+"; width: unitW_land; height: unitH_land }
            BackspaceKey { width: unitW_land; height: unitH_land }
            CharKey { label: "Home"; shifted: "Home"; action: "home"; width: unitW_land; height: unitH_land; fontSize: 12; noMagnifier: true }
        }

        // Row 2: QWERTY (15 units: 1.25 + 12*0.975 + 1.05 + 1.0 = 15.0)
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 0

            CharKey { label: "Tab"; shifted: "Tab"; valueToSubmit: "\t"; width: unitW_land * 1.25; height: unitH_land; fontSize: 13; noMagnifier: true }
            CharKey { label: "q"; shifted: "Q"; width: unitW_land * 0.975; height: unitH_land }
            CharKey { label: "w"; shifted: "W"; width: unitW_land * 0.975; height: unitH_land }
            CharKey { label: "e"; shifted: "E"; width: unitW_land * 0.975; height: unitH_land }
            CharKey { label: "r"; shifted: "R"; width: unitW_land * 0.975; height: unitH_land }
            CharKey { label: "t"; shifted: "T"; width: unitW_land * 0.975; height: unitH_land }
            CharKey { label: "y"; shifted: "Y"; width: unitW_land * 0.975; height: unitH_land }
            CharKey { label: "u"; shifted: "U"; width: unitW_land * 0.975; height: unitH_land }
            CharKey { label: "i"; shifted: "I"; width: unitW_land * 0.975; height: unitH_land }
            CharKey { label: "o"; shifted: "O"; width: unitW_land * 0.975; height: unitH_land }
            CharKey { label: "p"; shifted: "P"; width: unitW_land * 0.975; height: unitH_land }
            CharKey { label: "["; shifted: "{"; width: unitW_land * 0.975; height: unitH_land }
            CharKey { label: "]"; shifted: "}"; width: unitW_land * 0.975; height: unitH_land }
            CharKey { label: "\\"; shifted: "|"; width: unitW_land * 1.05; height: unitH_land }
            CharKey { label: "End"; shifted: "End"; action: "end"; width: unitW_land; height: unitH_land; fontSize: 12; noMagnifier: true }
        }

        // Row 3: ASDF (15 units: 1.5 + 11*1.0 + 1.5 + 1.0 = 15.0)
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 0

            CharKey { label: "Caps"; shifted: "Caps"; width: unitW_land * 1.5; height: unitH_land; fontSize: 13; noMagnifier: true; overridePressArea: true; onPressed: { panel.activeKeypadState = (panel.activeKeypadState === "CAPSLOCK") ? "NORMAL" : "CAPSLOCK"; } }
            CharKey { label: "a"; shifted: "A"; width: unitW_land * 1.0; height: unitH_land }
            CharKey { label: "s"; shifted: "S"; width: unitW_land * 1.0; height: unitH_land }
            CharKey { label: "d"; shifted: "D"; width: unitW_land * 1.0; height: unitH_land }
            CharKey { label: "f"; shifted: "F"; width: unitW_land * 1.0; height: unitH_land }
            CharKey { label: "g"; shifted: "G"; width: unitW_land * 1.0; height: unitH_land }
            CharKey { label: "h"; shifted: "H"; width: unitW_land * 1.0; height: unitH_land }
            CharKey { label: "j"; shifted: "J"; width: unitW_land * 1.0; height: unitH_land }
            CharKey { label: "k"; shifted: "K"; width: unitW_land * 1.0; height: unitH_land }
            CharKey { label: "l"; shifted: "L"; width: unitW_land * 1.0; height: unitH_land }
            CharKey { label: ";"; shifted: ":"; width: unitW_land * 1.0; height: unitH_land }
            CharKey { label: "'"; shifted: "\""; width: unitW_land * 1.0; height: unitH_land }
            ReturnKey { width: unitW_land * 1.5; height: unitH_land }
            CharKey { label: "PgUp"; shifted: "PgUp"; width: unitW_land; height: unitH_land; fontSize: 11; noMagnifier: true; overridePressArea: true; onPressed: { event_handler.onKeyReleased("SelectPreviousLine", "keysequence"); } }
        }

        // Row 4: ZXCV (15 units: 1.5 + 10*1.0 + 1.5 + 1.0 + 1.0 = 15.0)
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 0

            ShiftKey { width: unitW_land * 1.5; height: unitH_land }
            CharKey { label: "z"; shifted: "Z"; width: unitW_land * 1.0; height: unitH_land }
            CharKey { label: "x"; shifted: "X"; width: unitW_land * 1.0; height: unitH_land }
            CharKey { label: "c"; shifted: "C"; width: unitW_land * 1.0; height: unitH_land }
            CharKey { label: "v"; shifted: "V"; width: unitW_land * 1.0; height: unitH_land }
            CharKey { label: "b"; shifted: "B"; width: unitW_land * 1.0; height: unitH_land }
            CharKey { label: "n"; shifted: "N"; width: unitW_land * 1.0; height: unitH_land }
            CharKey { label: "m"; shifted: "M"; width: unitW_land * 1.0; height: unitH_land }
            CharKey { label: ","; shifted: "<"; width: unitW_land * 1.0; height: unitH_land }
            CharKey { label: "."; shifted: ">"; width: unitW_land * 1.0; height: unitH_land }
            CharKey { label: "/"; shifted: "?"; width: unitW_land * 1.0; height: unitH_land }
            ShiftKey { width: unitW_land * 1.5; height: unitH_land }
            CharKey { label: "↑"; shifted: "↑"; action: "up"; width: unitW_land; height: unitH_land; fontSize: 15; noMagnifier: true }
            CharKey { label: "PgDn"; shifted: "PgDn"; width: unitW_land; height: unitH_land; fontSize: 11; noMagnifier: true; overridePressArea: true; onPressed: { event_handler.onKeyReleased("SelectNextLine", "keysequence"); } }
        }

        // Row 5: Modifiers & Space (15 units: 1.5 + 1.25 + 1.25 + 6.0 + 1.25 + 1.25 + 1.25 + 1.25 = 15.0)
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 0

            SymbolShiftKey { width: unitW_land * 1.5; height: unitH_land }
            CharKey { label: "Ctrl"; shifted: "Ctrl"; width: unitW_land * 1.25; height: unitH_land; fontSize: 12; noMagnifier: true; extended: ["Copy", "Paste", "Cut", "Undo", "Redo", "Select All"]; extendedShifted: ["Copy", "Paste", "Cut", "Undo", "Redo", "Select All"] }
            CharKey { label: "Alt";  shifted: "Alt";  width: unitW_land * 1.25; height: unitH_land; fontSize: 12; noMagnifier: true }
            SpaceKey { id: spaceKey; width: unitW_land * 6.0; height: unitH_land; noMagnifier: true }
            CharKey { label: "←"; shifted: "←"; action: "left";  width: unitW_land * 1.25; height: unitH_land; fontSize: 15; noMagnifier: true }
            CharKey { label: "↓"; shifted: "↓"; action: "down";  width: unitW_land * 1.25; height: unitH_land; fontSize: 15; noMagnifier: true }
            CharKey { label: "→"; shifted: "→"; action: "right"; width: unitW_land * 1.25; height: unitH_land; fontSize: 15; noMagnifier: true }
            CharKey { label: "▼"; shifted: "▼"; width: unitW_land * 1.25; height: unitH_land; fontSize: 14; noMagnifier: true; overridePressArea: true; onPressed: { Keyboard.hide(); } }
        }
    }

    // =========================================================================
    // PORTRAIT: Clean 10-column touch layout (spacious, fewer keys, finger-friendly)
    // =========================================================================
    Column {
        id: portraitCol
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.topMargin: 4
        anchors.bottomMargin: 4
        visible: rootKeypad.isPortrait
        spacing: rootKeypad.rowGap

        // Row 0: Numbers 1-0 (10 units: 10 * 1.0 = 10.0)
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 0

            CharKey { label: "1"; shifted: "!"; width: unitW_port; height: unitH_port }
            CharKey { label: "2"; shifted: "@"; width: unitW_port; height: unitH_port }
            CharKey { label: "3"; shifted: "#"; width: unitW_port; height: unitH_port }
            CharKey { label: "4"; shifted: "$"; width: unitW_port; height: unitH_port }
            CharKey { label: "5"; shifted: "%"; width: unitW_port; height: unitH_port }
            CharKey { label: "6"; shifted: "^"; width: unitW_port; height: unitH_port }
            CharKey { label: "7"; shifted: "&"; width: unitW_port; height: unitH_port }
            CharKey { label: "8"; shifted: "*"; width: unitW_port; height: unitH_port }
            CharKey { label: "9"; shifted: "("; width: unitW_port; height: unitH_port }
            CharKey { label: "0"; shifted: ")"; width: unitW_port; height: unitH_port }
        }

        // Row 1: QWERTY (10 units: 10 * 1.0 = 10.0)
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 0

            CharKey { label: "q"; shifted: "Q"; width: unitW_port; height: unitH_port }
            CharKey { label: "w"; shifted: "W"; width: unitW_port; height: unitH_port }
            CharKey { label: "e"; shifted: "E"; width: unitW_port; height: unitH_port }
            CharKey { label: "r"; shifted: "R"; width: unitW_port; height: unitH_port }
            CharKey { label: "t"; shifted: "T"; width: unitW_port; height: unitH_port }
            CharKey { label: "y"; shifted: "Y"; width: unitW_port; height: unitH_port }
            CharKey { label: "u"; shifted: "U"; width: unitW_port; height: unitH_port }
            CharKey { label: "i"; shifted: "I"; width: unitW_port; height: unitH_port }
            CharKey { label: "o"; shifted: "O"; width: unitW_port; height: unitH_port }
            CharKey { label: "p"; shifted: "P"; width: unitW_port; height: unitH_port }
        }

        // Row 2: ASDF (10 units: 10 * 1.0 = 10.0)
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 0

            CharKey { label: "a"; shifted: "A"; width: unitW_port; height: unitH_port }
            CharKey { label: "s"; shifted: "S"; width: unitW_port; height: unitH_port }
            CharKey { label: "d"; shifted: "D"; width: unitW_port; height: unitH_port }
            CharKey { label: "f"; shifted: "F"; width: unitW_port; height: unitH_port }
            CharKey { label: "g"; shifted: "G"; width: unitW_port; height: unitH_port }
            CharKey { label: "h"; shifted: "H"; width: unitW_port; height: unitH_port }
            CharKey { label: "j"; shifted: "J"; width: unitW_port; height: unitH_port }
            CharKey { label: "k"; shifted: "K"; width: unitW_port; height: unitH_port }
            CharKey { label: "l"; shifted: "L"; width: unitW_port; height: unitH_port }
            CharKey { label: "'"; shifted: "\""; width: unitW_port; height: unitH_port }
        }

        // Row 3: Shift, ZXCV, Backspace (10 units: 1.5 + 7*1.0 + 1.5 = 10.0)
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 0

            ShiftKey { width: unitW_port * 1.5; height: unitH_port }
            CharKey { label: "z"; shifted: "Z"; width: unitW_port; height: unitH_port }
            CharKey { label: "x"; shifted: "X"; width: unitW_port; height: unitH_port }
            CharKey { label: "c"; shifted: "C"; width: unitW_port; height: unitH_port }
            CharKey { label: "v"; shifted: "V"; width: unitW_port; height: unitH_port }
            CharKey { label: "b"; shifted: "B"; width: unitW_port; height: unitH_port }
            CharKey { label: "n"; shifted: "N"; width: unitW_port; height: unitH_port }
            CharKey { label: "m"; shifted: "M"; width: unitW_port; height: unitH_port }
            BackspaceKey { width: unitW_port * 1.5; height: unitH_port }
        }

        // Row 4: Symbols, Comma, Space, Period, Return, Hide (10 units: 1.5 + 1.0 + 4.0 + 1.0 + 1.5 + 1.0 = 10.0)
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 0

            SymbolShiftKey { width: unitW_port * 1.5; height: unitH_port }
            CharKey { label: ","; shifted: "<"; width: unitW_port * 1.0; height: unitH_port }
            SpaceKey { width: unitW_port * 4.0; height: unitH_port; noMagnifier: true }
            CharKey { label: "."; shifted: ">"; width: unitW_port * 1.0; height: unitH_port }
            ReturnKey { width: unitW_port * 1.5; height: unitH_port }
            CharKey { label: "▼"; shifted: "▼"; width: unitW_port * 1.0; height: unitH_port; fontSize: 14; noMagnifier: true; overridePressArea: true; onPressed: { Keyboard.hide(); } }
        }
    }
}
