# SPDX-FileCopyrightText: 2026 AppGrid Contributors
# SPDX-License-Identifier: GPL-2.0-or-later

find_package(Qt6 REQUIRED COMPONENTS Test)

set(TEST_COMMON_SOURCES
    ${CMAKE_SOURCE_DIR}/src/appmodel.cpp
    ${CMAKE_SOURCE_DIR}/src/appfiltermodel.cpp
)

set(TEST_COMMON_LIBS
    Qt6::Test
    Qt6::Gui
    KF6::Service
    KF6::I18n
    KF6::CoreAddons
    KF6::KIOGui
)

include_directories(${CMAKE_SOURCE_DIR}/src)

# Helper: defines a Qt test executable and registers it with CTest.
# Pass extra headers (e.g. Q_OBJECT-containing helpers) as ARGN so AUTOMOC
# generates moc files for them.
function(appgrid_add_test name)
    add_executable(${name} ${name}.cpp ${TEST_COMMON_SOURCES} ${ARGN})
    target_link_libraries(${name} PRIVATE ${TEST_COMMON_LIBS})
    add_test(NAME ${name} COMMAND ${name})
endfunction()

appgrid_add_test(test_appfiltermodel ${CMAKE_CURRENT_SOURCE_DIR}/stubappmodel.h)
appgrid_add_test(test_search_ranking ${CMAKE_CURRENT_SOURCE_DIR}/stubappmodel.h)
appgrid_add_test(test_filter ${CMAKE_CURRENT_SOURCE_DIR}/stubappmodel.h)
appgrid_add_test(test_sort ${CMAKE_CURRENT_SOURCE_DIR}/stubappmodel.h)
appgrid_add_test(test_appmodel_helpers)

# --- QML tests (QtQuickTest) ---

find_package(Qt6 OPTIONAL_COMPONENTS QuickTest Quick Qml)

if(Qt6QuickTest_FOUND)
    # Copy PrefixDetector.qml next to the test so it can be loaded relatively.
    configure_file(
        ${CMAKE_SOURCE_DIR}/package/contents/ui/PrefixDetector.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/qml/PrefixDetector.qml
        COPYONLY
    )

    add_executable(tst_qml qml/main.cpp)
    target_link_libraries(tst_qml PRIVATE Qt6::QuickTest Qt6::Quick Qt6::Qml Qt6::Core)
    target_compile_definitions(tst_qml PRIVATE
        QUICK_TEST_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}/qml")
    add_test(NAME tst_qml COMMAND tst_qml)
else()
    message(STATUS "Qt6QuickTest not found — skipping QML tests")
endif()
