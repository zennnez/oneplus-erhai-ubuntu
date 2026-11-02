/*
 * SPDX-FileCopyrightText: 2026 OnePlus Pad 3 Native Erhai Integration
 *
 * SPDX-License-Identifier: LGPL-3.0-only
 *
 * Full-keyboard English layout for plasma-keyboard-custom (Qt Virtual Keyboard).
 *
 *   Landscape : 18-column TKL (Esc/F-row, number row, QWERTY, ASDF, ZXCV,
 *               modifiers, Ins/Home/PgUp/Del/End/PgDn, arrows)
 *   Portrait  : 13-column touch layout with an "Fn" page holding F1-F12,
 *               Home/End/PgUp/PgDn/Ins/Del/PrtSc, arrows and modifiers.
 *               The ASDF row is shifted slightly left (Fn key is 0.75 wide).
 *
 * Every row of a page adds up to the same total weight, so columns line up.
 * Because the F-row is part of the landscape layout, leave the optional
 * "F1-F12 row" in the keyboard settings OFF.
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.VirtualKeyboard
import QtQuick.VirtualKeyboard.Components

KeyboardLayoutLoader {
    id: loader

    // Physical orientation of the screen (the panel itself is always wider than tall)
    readonly property bool portrait: Screen.width < Screen.height
    property bool fnPage: false

    onPortraitChanged: fnPage = false
    onVisibleChanged: if (!visible) fnPage = false

    sourceComponent: portrait ? (fnPage ? portraitFn : portraitMain) : landscape

    // ---------------------------------------------------------------------
    // Building blocks
    // ---------------------------------------------------------------------

    // Non-text key (Tab, Ctrl, F1, Home ...): drawn with the "function" key style
    component FKey: Key {
        functionKey: true
    }

    // Key with a shifted symbol (digits, punctuation). Switches on the real Shift
    // state only, so auto-capitalisation never turns "1" into "!".
    component SymKey: Key {
        property int baseKey: Qt.Key_unknown
        property string baseText
        property int shiftedKey: Qt.Key_unknown
        property string shiftedText
        readonly property bool shiftOn: InputContext.shiftActive
        key: shiftOn ? shiftedKey : baseKey
        text: shiftOn ? shiftedText : baseText
        smallText: shiftOn ? baseText : shiftedText
        smallTextVisible: true
    }

    // ---------------------------------------------------------------------
    // LANDSCAPE  (main block 15 units + 0.25 gap + nav block 3 units = 1825)
    // ---------------------------------------------------------------------
    Component {
        id: landscape
        KeyboardLayout {
            inputMode: InputEngine.InputMode.Latin
            keyWeight: 100

            // Row 0: Esc, F1-F12, PrtSc/ScrLk/Pause   (100+50+400+50+400+50+400+50 = 1500)
            KeyboardRow {
                FKey { key: Qt.Key_Escape; displayText: "Esc"; weight: 100 }
                FillerKey { weight: 50 }
                FKey { key: Qt.Key_F1; displayText: "F1" }
                FKey { key: Qt.Key_F2; displayText: "F2" }
                FKey { key: Qt.Key_F3; displayText: "F3" }
                FKey { key: Qt.Key_F4; displayText: "F4" }
                FillerKey { weight: 50 }
                FKey { key: Qt.Key_F5; displayText: "F5" }
                FKey { key: Qt.Key_F6; displayText: "F6" }
                FKey { key: Qt.Key_F7; displayText: "F7" }
                FKey { key: Qt.Key_F8; displayText: "F8" }
                FillerKey { weight: 50 }
                FKey { key: Qt.Key_F9; displayText: "F9" }
                FKey { key: Qt.Key_F10; displayText: "F10" }
                FKey { key: Qt.Key_F11; displayText: "F11" }
                FKey { key: Qt.Key_F12; displayText: "F12" }
                FillerKey { weight: 50 }
                FillerKey { weight: 25 }
                FKey { key: Qt.Key_Print; displayText: "PrtSc" }
                FKey { key: Qt.Key_ScrollLock; displayText: "ScrLk" }
                FKey { key: Qt.Key_Pause; displayText: "Pause" }
            }

            // Row 1: ` 1-0 - = Backspace | Ins Home PgUp   (1300 + 200 = 1500)
            KeyboardRow {
                SymKey { baseKey: Qt.Key_QuoteLeft; baseText: "`"; shiftedKey: Qt.Key_AsciiTilde; shiftedText: "~" }
                SymKey { baseKey: Qt.Key_1; baseText: "1"; shiftedKey: Qt.Key_Exclam; shiftedText: "!" }
                SymKey { baseKey: Qt.Key_2; baseText: "2"; shiftedKey: Qt.Key_At; shiftedText: "@" }
                SymKey { baseKey: Qt.Key_3; baseText: "3"; shiftedKey: Qt.Key_NumberSign; shiftedText: "#" }
                SymKey { baseKey: Qt.Key_4; baseText: "4"; shiftedKey: Qt.Key_Dollar; shiftedText: "$" }
                SymKey { baseKey: Qt.Key_5; baseText: "5"; shiftedKey: Qt.Key_Percent; shiftedText: "%" }
                SymKey { baseKey: Qt.Key_6; baseText: "6"; shiftedKey: Qt.Key_AsciiCircum; shiftedText: "^" }
                SymKey { baseKey: Qt.Key_7; baseText: "7"; shiftedKey: Qt.Key_Ampersand; shiftedText: "&" }
                SymKey { baseKey: Qt.Key_8; baseText: "8"; shiftedKey: Qt.Key_Asterisk; shiftedText: "*" }
                SymKey { baseKey: Qt.Key_9; baseText: "9"; shiftedKey: Qt.Key_ParenLeft; shiftedText: "(" }
                SymKey { baseKey: Qt.Key_0; baseText: "0"; shiftedKey: Qt.Key_ParenRight; shiftedText: ")" }
                SymKey { baseKey: Qt.Key_Minus; baseText: "-"; shiftedKey: Qt.Key_Underscore; shiftedText: "_" }
                SymKey { baseKey: Qt.Key_Equal; baseText: "="; shiftedKey: Qt.Key_Plus; shiftedText: "+" }
                BackspaceKey { weight: 200 }
                FillerKey { weight: 25 }
                FKey { key: Qt.Key_Insert; displayText: "Ins" }
                FKey { key: Qt.Key_Home; displayText: "Home" }
                FKey { key: Qt.Key_PageUp; displayText: "PgUp"; repeat: true }
            }

            // Row 2: Tab q-p [ ] \ | Del End PgDn   (150 + 1000 + 200 + 150 = 1500)
            KeyboardRow {
                FKey { key: Qt.Key_Tab; text: "\t"; displayText: "Tab"; weight: 150 }
                Key { key: Qt.Key_Q; text: "q" }
                Key { key: Qt.Key_W; text: "w" }
                Key { key: Qt.Key_E; text: "e" }
                Key { key: Qt.Key_R; text: "r" }
                Key { key: Qt.Key_T; text: "t" }
                Key { key: Qt.Key_Y; text: "y" }
                Key { key: Qt.Key_U; text: "u" }
                Key { key: Qt.Key_I; text: "i" }
                Key { key: Qt.Key_O; text: "o" }
                Key { key: Qt.Key_P; text: "p" }
                SymKey { baseKey: Qt.Key_BracketLeft; baseText: "["; shiftedKey: Qt.Key_BraceLeft; shiftedText: "{" }
                SymKey { baseKey: Qt.Key_BracketRight; baseText: "]"; shiftedKey: Qt.Key_BraceRight; shiftedText: "}" }
                SymKey { baseKey: Qt.Key_Backslash; baseText: "\\"; shiftedKey: Qt.Key_Bar; shiftedText: "|"; weight: 150 }
                FillerKey { weight: 25 }
                FKey { key: Qt.Key_Delete; displayText: "Del"; repeat: true }
                FKey { key: Qt.Key_End; displayText: "End" }
                FKey { key: Qt.Key_PageDown; displayText: "PgDn"; repeat: true }
            }

            // Row 3: Caps a-l ; ' Enter | Lang . Hide   (175 + 900 + 200 + 225 = 1500)
            KeyboardRow {
                FKey { key: Qt.Key_CapsLock; displayText: "Caps"; weight: 175 }
                Key { key: Qt.Key_A; text: "a" }
                Key { key: Qt.Key_S; text: "s" }
                Key { key: Qt.Key_D; text: "d" }
                Key { key: Qt.Key_F; text: "f" }
                Key { key: Qt.Key_G; text: "g" }
                Key { key: Qt.Key_H; text: "h" }
                Key { key: Qt.Key_J; text: "j" }
                Key { key: Qt.Key_K; text: "k" }
                Key { key: Qt.Key_L; text: "l" }
                SymKey { baseKey: Qt.Key_Semicolon; baseText: ";"; shiftedKey: Qt.Key_Colon; shiftedText: ":" }
                SymKey { baseKey: Qt.Key_Apostrophe; baseText: "'"; shiftedKey: Qt.Key_QuoteDbl; shiftedText: "\"" }
                EnterKey { weight: 225 }
                FillerKey { weight: 25 }
                ChangeLanguageKey { }
                FillerKey { }
                HideKeyboardKey { }
            }

            // Row 4: Shift z-m , . / Shift | . Up .   (225 + 1000 + 275 = 1500)
            KeyboardRow {
                ShiftKey { weight: 225 }
                Key { key: Qt.Key_Z; text: "z" }
                Key { key: Qt.Key_X; text: "x" }
                Key { key: Qt.Key_C; text: "c" }
                Key { key: Qt.Key_V; text: "v" }
                Key { key: Qt.Key_B; text: "b" }
                Key { key: Qt.Key_N; text: "n" }
                Key { key: Qt.Key_M; text: "m" }
                SymKey { baseKey: Qt.Key_Comma; baseText: ","; shiftedKey: Qt.Key_Less; shiftedText: "<" }
                SymKey { baseKey: Qt.Key_Period; baseText: "."; shiftedKey: Qt.Key_Greater; shiftedText: ">" }
                SymKey { baseKey: Qt.Key_Slash; baseText: "/"; shiftedKey: Qt.Key_Question; shiftedText: "?" }
                ShiftKey { weight: 275 }
                FillerKey { weight: 25 }
                FillerKey { }
                FKey { key: Qt.Key_Up; displayText: "\u2191"; repeat: true }
                FillerKey { }
            }

            // Row 5: Ctrl Meta Alt Space Alt &123 Menu Ctrl | Left Down Right
            //        (3*125 + 625 + 4*125 = 1500)
            KeyboardRow {
                FKey { key: Qt.Key_Control; displayText: "Ctrl"; weight: 125 }
                FKey { key: Qt.Key_Meta; displayText: "Meta"; weight: 125 }
                FKey { key: Qt.Key_Alt; displayText: "Alt"; weight: 125 }
                SpaceKey { weight: 625 }
                FKey { key: Qt.Key_Alt; displayText: "Alt"; weight: 125 }
                SymbolModeKey { weight: 125 }
                FKey { key: Qt.Key_Menu; displayText: "Menu"; weight: 125 }
                FKey { key: Qt.Key_Control; displayText: "Ctrl"; weight: 125 }
                FillerKey { weight: 25 }
                FKey { key: Qt.Key_Left; displayText: "\u2190"; repeat: true }
                FKey { key: Qt.Key_Down; displayText: "\u2193"; repeat: true }
                FKey { key: Qt.Key_Right; displayText: "\u2192"; repeat: true }
            }
        }
    }

    // ---------------------------------------------------------------------
    // PORTRAIT, main page  (13 columns, 5 rows, every row = 1300)
    // ---------------------------------------------------------------------
    Component {
        id: portraitMain
        KeyboardLayout {
            inputMode: InputEngine.InputMode.Latin
            keyWeight: 100

            // Esc 1-0 - =
            KeyboardRow {
                FKey { key: Qt.Key_Escape; displayText: "Esc" }
                SymKey { baseKey: Qt.Key_1; baseText: "1"; shiftedKey: Qt.Key_Exclam; shiftedText: "!" }
                SymKey { baseKey: Qt.Key_2; baseText: "2"; shiftedKey: Qt.Key_At; shiftedText: "@" }
                SymKey { baseKey: Qt.Key_3; baseText: "3"; shiftedKey: Qt.Key_NumberSign; shiftedText: "#" }
                SymKey { baseKey: Qt.Key_4; baseText: "4"; shiftedKey: Qt.Key_Dollar; shiftedText: "$" }
                SymKey { baseKey: Qt.Key_5; baseText: "5"; shiftedKey: Qt.Key_Percent; shiftedText: "%" }
                SymKey { baseKey: Qt.Key_6; baseText: "6"; shiftedKey: Qt.Key_AsciiCircum; shiftedText: "^" }
                SymKey { baseKey: Qt.Key_7; baseText: "7"; shiftedKey: Qt.Key_Ampersand; shiftedText: "&" }
                SymKey { baseKey: Qt.Key_8; baseText: "8"; shiftedKey: Qt.Key_Asterisk; shiftedText: "*" }
                SymKey { baseKey: Qt.Key_9; baseText: "9"; shiftedKey: Qt.Key_ParenLeft; shiftedText: "(" }
                SymKey { baseKey: Qt.Key_0; baseText: "0"; shiftedKey: Qt.Key_ParenRight; shiftedText: ")" }
                SymKey { baseKey: Qt.Key_Minus; baseText: "-"; shiftedKey: Qt.Key_Underscore; shiftedText: "_" }
                SymKey { baseKey: Qt.Key_Equal; baseText: "="; shiftedKey: Qt.Key_Plus; shiftedText: "+" }
            }

            // Tab q-p [ ]
            KeyboardRow {
                FKey { key: Qt.Key_Tab; text: "\t"; displayText: "Tab" }
                Key { key: Qt.Key_Q; text: "q" }
                Key { key: Qt.Key_W; text: "w" }
                Key { key: Qt.Key_E; text: "e" }
                Key { key: Qt.Key_R; text: "r" }
                Key { key: Qt.Key_T; text: "t" }
                Key { key: Qt.Key_Y; text: "y" }
                Key { key: Qt.Key_U; text: "u" }
                Key { key: Qt.Key_I; text: "i" }
                Key { key: Qt.Key_O; text: "o" }
                Key { key: Qt.Key_P; text: "p" }
                SymKey { baseKey: Qt.Key_BracketLeft; baseText: "["; shiftedKey: Qt.Key_BraceLeft; shiftedText: "{" }
                SymKey { baseKey: Qt.Key_BracketRight; baseText: "]"; shiftedKey: Qt.Key_BraceRight; shiftedText: "}" }
            }

            // Fn(0.75) a-l ; ' Backspace(1.25)  -> letters sit a little left of the QWERTY row
            KeyboardRow {
                FKey {
                    displayText: "Fn"
                    weight: 75
                    noKeyEvent: true
                    onClicked: loader.fnPage = true
                }
                Key { key: Qt.Key_A; text: "a" }
                Key { key: Qt.Key_S; text: "s" }
                Key { key: Qt.Key_D; text: "d" }
                Key { key: Qt.Key_F; text: "f" }
                Key { key: Qt.Key_G; text: "g" }
                Key { key: Qt.Key_H; text: "h" }
                Key { key: Qt.Key_J; text: "j" }
                Key { key: Qt.Key_K; text: "k" }
                Key { key: Qt.Key_L; text: "l" }
                SymKey { baseKey: Qt.Key_Semicolon; baseText: ";"; shiftedKey: Qt.Key_Colon; shiftedText: ":" }
                SymKey { baseKey: Qt.Key_Apostrophe; baseText: "'"; shiftedKey: Qt.Key_QuoteDbl; shiftedText: "\"" }
                BackspaceKey { weight: 125 }
            }

            // &123 Shift z-m , . / \
            KeyboardRow {
                SymbolModeKey { }
                ShiftKey { }
                Key { key: Qt.Key_Z; text: "z" }
                Key { key: Qt.Key_X; text: "x" }
                Key { key: Qt.Key_C; text: "c" }
                Key { key: Qt.Key_V; text: "v" }
                Key { key: Qt.Key_B; text: "b" }
                Key { key: Qt.Key_N; text: "n" }
                Key { key: Qt.Key_M; text: "m" }
                SymKey { baseKey: Qt.Key_Comma; baseText: ","; shiftedKey: Qt.Key_Less; shiftedText: "<" }
                SymKey { baseKey: Qt.Key_Period; baseText: "."; shiftedKey: Qt.Key_Greater; shiftedText: ">" }
                SymKey { baseKey: Qt.Key_Slash; baseText: "/"; shiftedKey: Qt.Key_Question; shiftedText: "?" }
                SymKey { baseKey: Qt.Key_Backslash; baseText: "\\"; shiftedKey: Qt.Key_Bar; shiftedText: "|" }
            }

            // Ctrl Alt Space  <  (Up/Down)  >  Enter  Hide   (150+150+450+100+100+100+150+100 = 1300)
            KeyboardRow {
                FKey { key: Qt.Key_Control; displayText: "Ctrl"; weight: 150 }
                FKey { key: Qt.Key_Alt; displayText: "Alt"; weight: 150 }
                SpaceKey { weight: 450 }
                FKey { key: Qt.Key_Left; displayText: "\u2190"; repeat: true }
                KeyboardColumn {
                    Layout.preferredWidth: 100
                    Layout.fillHeight: true
                    FKey { key: Qt.Key_Up; displayText: "\u2191"; repeat: true; Layout.fillHeight: true; Layout.fillWidth: true }
                    FKey { key: Qt.Key_Down; displayText: "\u2193"; repeat: true; Layout.fillHeight: true; Layout.fillWidth: true }
                }
                FKey { key: Qt.Key_Right; displayText: "\u2192"; repeat: true }
                EnterKey { weight: 150 }
                HideKeyboardKey { }
            }
        }
    }

    // ---------------------------------------------------------------------
    // PORTRAIT, Fn page  (13 columns, 5 rows, every row = 1300)
    // ---------------------------------------------------------------------
    Component {
        id: portraitFn
        KeyboardLayout {
            inputMode: InputEngine.InputMode.Latin
            keyWeight: 100

            // Esc F1-F12
            KeyboardRow {
                FKey { key: Qt.Key_Escape; displayText: "Esc" }
                FKey { key: Qt.Key_F1; displayText: "F1" }
                FKey { key: Qt.Key_F2; displayText: "F2" }
                FKey { key: Qt.Key_F3; displayText: "F3" }
                FKey { key: Qt.Key_F4; displayText: "F4" }
                FKey { key: Qt.Key_F5; displayText: "F5" }
                FKey { key: Qt.Key_F6; displayText: "F6" }
                FKey { key: Qt.Key_F7; displayText: "F7" }
                FKey { key: Qt.Key_F8; displayText: "F8" }
                FKey { key: Qt.Key_F9; displayText: "F9" }
                FKey { key: Qt.Key_F10; displayText: "F10" }
                FKey { key: Qt.Key_F11; displayText: "F11" }
                FKey { key: Qt.Key_F12; displayText: "F12" }
            }

            // ` ~ Home End PgUp PgDn Ins Del PrtSc ScrLk Pause Menu Caps
            KeyboardRow {
                Key { key: Qt.Key_QuoteLeft; text: "`" }
                Key { key: Qt.Key_AsciiTilde; text: "~" }
                FKey { key: Qt.Key_Home; displayText: "Home" }
                FKey { key: Qt.Key_End; displayText: "End" }
                FKey { key: Qt.Key_PageUp; displayText: "PgUp"; repeat: true }
                FKey { key: Qt.Key_PageDown; displayText: "PgDn"; repeat: true }
                FKey { key: Qt.Key_Insert; displayText: "Ins" }
                FKey { key: Qt.Key_Delete; displayText: "Del"; repeat: true }
                FKey { key: Qt.Key_Print; displayText: "PrtSc" }
                FKey { key: Qt.Key_ScrollLock; displayText: "ScrLk" }
                FKey { key: Qt.Key_Pause; displayText: "Pause" }
                FKey { key: Qt.Key_Menu; displayText: "Menu" }
                FKey { key: Qt.Key_CapsLock; displayText: "Caps" }
            }

            // ABC(3) <- Up Down -> Backspace(3) Enter(3)
            KeyboardRow {
                FKey {
                    displayText: "ABC"
                    weight: 300
                    noKeyEvent: true
                    onClicked: loader.fnPage = false
                }
                FKey { key: Qt.Key_Left; displayText: "\u2190"; repeat: true }
                FKey { key: Qt.Key_Up; displayText: "\u2191"; repeat: true }
                FKey { key: Qt.Key_Down; displayText: "\u2193"; repeat: true }
                FKey { key: Qt.Key_Right; displayText: "\u2192"; repeat: true }
                BackspaceKey { weight: 300 }
                EnterKey { weight: 300 }
            }

            // Shift Ctrl Alt Meta Tab (2 each) + Language(3)
            KeyboardRow {
                ShiftKey { weight: 200 }
                FKey { key: Qt.Key_Control; displayText: "Ctrl"; weight: 200 }
                FKey { key: Qt.Key_Alt; displayText: "Alt"; weight: 200 }
                FKey { key: Qt.Key_Meta; displayText: "Meta"; weight: 200 }
                FKey { key: Qt.Key_Tab; text: "\t"; displayText: "Tab"; weight: 200 }
                ChangeLanguageKey { weight: 300 }
            }

            // &123(2.5) Space(8) Hide(2.5)
            KeyboardRow {
                SymbolModeKey { weight: 250 }
                SpaceKey { weight: 800 }
                HideKeyboardKey { weight: 250 }
            }
        }
    }
}
