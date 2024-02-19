#####################################
# Convert .elf to .bin              #
#####################################

function(mcu_elf2bin PROJ_NAME)
    separate_arguments(EXTRA_OPTS UNIX_COMMAND "${ARGN}")
    add_custom_command(TARGET ${PROJ_NAME} POST_BUILD
        COMMAND "${CMAKE_OBJCOPY}" -O binary ${EXTRA_OPTS}
        "${PROJ_NAME}.elf"
        "${PROJ_NAME}.bin"
        BYPRODUCTS "${PROJ_NAME}.bin"
        COMMENT "Generating ${PROJ_NAME}.bin"
    )
    set_property(TARGET ${PROJ_NAME} PROPERTY TARGET_FILE_BIN "${CMAKE_CURRENT_BINARY_DIR}/${CMX_TARGET}.bin")
endfunction()

#####################################
# Convert .elf to .lst              #
#####################################

function(mcu_elf2lst PROJ_NAME)
    separate_arguments(EXTRA_OPTS UNIX_COMMAND "${ARGN}")
    add_custom_command(TARGET ${PROJ_NAME} POST_BUILD
        COMMAND "${CMAKE_OBJDUMP}" -S ${EXTRA_OPTS}
        "${PROJ_NAME}.elf"
        > "${PROJ_NAME}.lst"
        BYPRODUCTS "${PROJ_NAME}.lst"
        COMMENT "Generating ${PROJ_NAME}.lst"
    )
    set_property(TARGET ${PROJ_NAME} PROPERTY TARGET_FILE_LST "${CMAKE_CURRENT_BINARY_DIR}/${CMX_TARGET}.lst")
endfunction()

#####################################
# Create symbol map                 #
#####################################

function(mcu_map PROJ_NAME)
    target_link_options(${PROJ_NAME} PRIVATE -Wl,-Map=${PROJ_NAME}.map,--cref)
    set_target_properties(${PROJ_NAME} PROPERTIES ADDITIONAL_CLEAN_FILES
        "${PROJ_NAME}.map"
    )
    set_property(TARGET ${PROJ_NAME} PROPERTY TARGET_FILE_MAP "${CMAKE_CURRENT_BINARY_DIR}/${CMX_TARGET}.map")
endfunction()

#####################################
# Display size                      #
#####################################

function(mcu_imgsize PROJ_NAME)
    add_custom_command(TARGET ${PROJ_NAME} POST_BUILD
        COMMAND "${CMAKE_SIZE_UTIL}"
        "$<TARGET_FILE:${PROJ_NAME}>"
    )
endfunction()

#####################################
# Create all of the above           #
#####################################

function(mcu_image_utils PROJ_NAME ELF2BIN_OPTS ELF2LST_OPTS)
    mcu_elf2bin(${PROJ_NAME} ${ELF2BIN_OPTS})
    if(NOT NOLST)
        message("-- 'NOLST' is not set. Listing ${PROJ_NAME}.lst will be generated.")
        mcu_elf2lst(${PROJ_NAME} ${ELF2LST_OPTS})
    else()
        message("-- 'NOLST' is set. Listing ${PROJ_NAME}.lst will be skipped.")
    endif()
    mcu_map(${PROJ_NAME})
    mcu_imgsize(${PROJ_NAME})
endfunction()
