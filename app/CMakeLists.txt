# Ironfang application target - declared through Clayground's clay_app() helper.
# The entry point must be Main.qml (Clayground convention).
include(clayapp)

# Runtime 3D assets (balsam output under assets/runtime) are bundled as resources.
# They live outside app/, so each file gets an alias that keeps the "assets/runtime/..."
# path Qt.resolvedUrl() expects from the QML files.
file(GLOB_RECURSE IRONFANG_RUNTIME_ASSETS CONFIGURE_DEPENDS
     "${CMAKE_SOURCE_DIR}/assets/runtime/*")
foreach(_f IN LISTS IRONFANG_RUNTIME_ASSETS)
    file(RELATIVE_PATH _rel "${CMAKE_SOURCE_DIR}" "${_f}")
    set_source_files_properties("${_f}" PROPERTIES QT_RESOURCE_ALIAS "${_rel}")
endforeach()

clay_app(ironfang
    VERSION 0.1.0

    LINK_LIBS
        Qt::Core
        Qt::Qml
        Qt::Quick
        Qt::Quick3D
        Qt::Quick3DHelpers
        Qt::Quick3DAssetUtils
        Qt::QuickTimeline

    QML_FILES
        Main.qml
        QmlModules.qml
        IronfangGame.qml
        GameWorld.qml
        RtsCamera.qml
        UnitView.qml
        BuildingView.qml
        Projectile.qml
        HealthBar3D.qml
        Hud.qml
        MenuOverlay.qml
        scripts/NavGrid.js
        scripts/Steering.js
        scripts/Economy.js
        scripts/Production.js
        scripts/Combat.js
        scripts/Gather.js
        scripts/EnemyAI.js
        config/assets.js
        config/balance.js
        config/level.js

    RES_FILES
        ${IRONFANG_RUNTIME_ASSETS}
)
