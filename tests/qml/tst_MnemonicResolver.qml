/*
    SPDX-FileCopyrightText: 2026 AppGrid Contributors
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtTest

TestCase {
    name: "MnemonicResolver"

    function resolver(names) {
        var c = Qt.createComponent("MnemonicResolver.qml")
        verify(c.status === Component.Ready, "component error: " + c.errorString())
        return c.createObject(null, { names: names })
    }

    // --- assignment ---

    function test_emptyHasEmptyMap() {
        var r = resolver([])
        compare(Object.keys(r.map).length, 0)
    }

    function test_firstLetterAssignedFirst() {
        var r = resolver(["Apple", "Banana", "Cherry"])
        compare(r.map["A"], "Apple")
        compare(r.map["B"], "Banana")
        compare(r.map["C"], "Cherry")
    }

    function test_collisionPicksNextAvailableLetter() {
        // Apricot's 'A' taken; falls to 'P'
        var r = resolver(["Apple", "Apricot"])
        compare(r.map["A"], "Apple")
        compare(r.map["P"], "Apricot")
    }

    function test_noLettersLeavesUnassigned() {
        var r = resolver(["123", "456"])
        compare(Object.keys(r.map).length, 0)
    }

    function test_caseInsensitiveCollision() {
        // 'A' from "Apple" should block "ant" too
        var r = resolver(["Apple", "ant"])
        compare(r.map["A"], "Apple")
        compare(r.map["N"], "ant")
    }

    // --- indexFor ---

    function test_indexForReturnsLetterPosition() {
        var r = resolver(["Apple", "Apricot"])
        compare(r.indexFor("Apple"), 0)    // 'A' at 0
        compare(r.indexFor("Apricot"), 1)  // 'p' at 1 (since 'A' taken)
    }

    function test_indexForUnknownReturnsMinusOne() {
        var r = resolver(["Apple"])
        compare(r.indexFor("Banana"), -1)
    }

    // --- richTextFor ---

    function test_richTextWrapsAssignedLetter() {
        var r = resolver(["Apple"])
        compare(r.richTextFor("Apple"), "<u>A</u>pple")
    }

    function test_richTextWrapsAtCollisionFallback() {
        var r = resolver(["Apple", "Apricot"])
        compare(r.richTextFor("Apricot"), "A<u>p</u>ricot")
    }

    function test_richTextFallsBackToPlainTextWhenUnassigned() {
        var r = resolver(["123"])
        compare(r.richTextFor("123"), "123")
    }

    // --- nameForKey ---

    function test_nameForKeyResolvesLetter() {
        var r = resolver(["Apple", "Banana"])
        compare(r.nameForKey(Qt.Key_A), "Apple")
        compare(r.nameForKey(Qt.Key_B), "Banana")
    }

    function test_nameForKeyReturnsEmptyForUnknown() {
        var r = resolver(["Apple"])
        compare(r.nameForKey(Qt.Key_Z), "")
    }
}
