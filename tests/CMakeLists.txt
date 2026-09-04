# QML unit tests, run headless through Clayground's clay_add_qml_test (qmltestrunner).
include(claytest)

clay_add_qml_test(IronfangNavigation
    DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
