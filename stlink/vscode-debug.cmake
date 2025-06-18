set(STLINK_DIR "${CMAKE_CURRENT_LIST_DIR}")

foreach(opt IN LISTS CMX_DEBUGGER_OPT)
    string(APPEND STLINK_OPT \"${opt}\",)
endforeach()

function(vscode_debug PROJ_NAME)
    set(PROJ_ELF_PATH "${CMAKE_BINARY_DIR}/${PROJ_NAME}.elf")
    file(MAKE_DIRECTORY "${VSCODE_DIR}")
    if(NOT EXISTS "${VSCODE_DIR}/launch.json")
        set(LAUNCH_JSON "${VSCODE_DIR}/launch.json")
    else()
        message(STATUS "vscode-debug: launch.json already exists, generating file ${VSCODE_DIR}/launch.json.st-link ...")
        message(STATUS "vscode-debug: You can copy or merge with ${VSCODE_DIR}/launch.json")
        set(LAUNCH_JSON "${VSCODE_DIR}/launch.json.st-link")
    endif()
    configure_file(
        "${STLINK_DIR}/vscode-debug.in"
        "${LAUNCH_JSON}"
        @ONLY
    )
endfunction()
