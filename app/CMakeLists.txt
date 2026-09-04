# Ironfang application target - declared through Clayground's clay_app() helper.
# The entry point must be Main.qml (Clayground convention).
include(clayapp)

# Runtime 3D assets (balsam output under assets/runtime) and audio live outside app/, so
# each file gets an alias that keeps the "assets/..." path Qt.resolvedUrl() expects.
#  * desktop: compiled into the binary as resources (qrc:/assets/...)
#  * WebAssembly: NOT embedded - scripts/build-wasm.sh ships them as separate files that
#    Qt's loader preloads into the in-memory filesystem (/game/assets/...), so the 40 MB
#    wasm stays cacheable on its own and assets download in parallel.
file(GLOB_RECURSE IRONFANG_RUNTIME_ASSETS CONFIGURE_DEPENDS "${CMAKE_SOURCE_DIR}/assets/runtime/*")
file(GLOB IRONFANG_AUDIO_ASSETS CONFIGURE_DEPENDS "${CMAKE_SOURCE_DIR}/assets/audio/*.wav")
set(IRONFANG_RES_FILES ${IRONFANG_AUDIO_ASSETS})
if(NOT EMSCRIPTEN)
    list(APPEND IRONFANG_RES_FILES ${IRONFANG_RUNTIME_ASSETS})
endif()
foreach(_f IN LISTS IRONFANG_RES_FILES)
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
        Qt::Multimedia

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
        AudioController.qml
        AssetShowcase.qml
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
        config/assetmeta.js

    RES_FILES
        ${IRONFANG_RES_FILES}
)

if(EMSCRIPTEN)
    # Clayground defaults the wasm heap to 64 MB; the runtime assets compiled into the binary
    # (QRC) plus Qt Quick 3D need more. The heap still grows on demand (ALLOW_MEMORY_GROWTH).
    set_target_properties(ironfang PROPERTIES QT_WASM_INITIAL_MEMORY "256MB")
endif()
