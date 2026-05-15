/*
    SPDX-FileCopyrightText: 2026 AppGrid Contributors
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtTest

TestCase {
    name: "PrefixDetector"

    function detector(input) {
        var c = Qt.createComponent("PrefixDetector.qml")
        verify(c.status === Component.Ready, "component error: " + c.errorString())
        return c.createObject(null, { input: input })
    }

    // --- mode classification ---

    function test_emptyHasNoMode() {
        var d = detector("")
        compare(d.mode, "")
        verify(!d.isPrefixMode)
    }

    function test_plainTextHasNoMode() {
        compare(detector("firefox").mode, "")
        compare(detector("blender 3d").mode, "")
    }

    function test_terminalPrefix() {
        var d = detector("t:ls -la")
        compare(d.mode, "terminal")
        verify(d.isPrefixMode)
        compare(d.argument, "ls -la")
    }

    function test_commandPrefix() {
        var d = detector(":echo hi")
        compare(d.mode, "command")
        compare(d.argument, "echo hi")
    }

    function test_filesAbsolutePath() {
        var d = detector("/usr/bin")
        compare(d.mode, "files")
        compare(d.argument, "/usr/bin")
    }

    function test_filesHomePath() {
        var d = detector("~/Documents")
        compare(d.mode, "files")
        compare(d.argument, "~/Documents")
    }

    function test_infoPrefix() {
        var d = detector("i:")
        compare(d.mode, "info")
        compare(d.argument, "") // info has no argument
    }

    function test_hiddenPrefix() {
        var d = detector("h:")
        compare(d.mode, "hidden")
    }

    function test_helpPrefix() {
        compare(detector("?").mode, "help")
        compare(detector("?anything").mode, "help")
    }

    // --- argument handling ---

    function test_argumentTrimsWhitespace() {
        compare(detector("t:   ls   ").argument, "ls")
        compare(detector(":   echo hi  ").argument, "echo hi")
    }

    function test_argumentEmptyAfterPrefix() {
        compare(detector("t:").argument, "")
        compare(detector(":").argument, "")
    }

    // --- precedence (first match wins per source order) ---

    function test_terminalBeforeCommand() {
        // "t:" starts with "t", not ":" — terminal wins
        compare(detector("t:foo").mode, "terminal")
    }

    function test_questionMarkNotMatchedMidString() {
        // help only triggers on leading '?'
        compare(detector("foo?bar").mode, "")
    }
}
