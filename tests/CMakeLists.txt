# QML unit tests, run headless through Clayground's clay_add_qml_test (qmltestrunner).
include(claytest)

clay_add_qml_test(IronfangNavigation
    DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

# Localization completeness: every key used exists in every language (scripts/check-i18n.py)
find_package(Python3 COMPONENTS Interpreter)
if(Python3_Interpreter_FOUND)
    add_test(NAME IronfangLocalization COMMAND ${Python3_EXECUTABLE} ${CMAKE_SOURCE_DIR}/scripts/check-i18n.py)
endif()
