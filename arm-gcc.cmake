set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR ARM)
set(CMAKE_CROSSCOMPILING TRUE)

set(TOOLCHAIN_PREFIX arm-none-eabi-)

function(find_armgcc)
    if(MINGW OR CYGWIN OR WIN32)
        set(UTIL_SEARCH_CMD where)
    elseif(UNIX OR APPLE)
        set(UTIL_SEARCH_CMD which)
    endif()

    if(EXISTS ${CMAKE_C_COMPILER})
        set(BINUTILS_PATH ${CMAKE_C_COMPILER})
    elseif(EXISTS ${CMAKE_ASM_COMPILER})
        set(BINUTILS_PATH ${CMAKE_ASM_COMPILER})
    elseif(EXISTS ${CMAKE_CXX_COMPILER})
        set(BINUTILS_PATH ${CMAKE_CXX_COMPILER})
    else()
        execute_process(
            COMMAND ${UTIL_SEARCH_CMD} ${TOOLCHAIN_PREFIX}gcc
            OUTPUT_VARIABLE BINUTILS_PATH
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
    endif()

    # Use only the topmost path, if more than one is found
    string(REGEX REPLACE "\n.+" "" BINUTILS_PATH "${BINUTILS_PATH}")
    
    set(BINUTILS_PATH ${BINUTILS_PATH} PARENT_SCOPE)
endfunction()

if(NOT ARMGCC_TOOLCHAIN_PATH)
    find_armgcc()
elseif(EXISTS "${ARMGCC_TOOLCHAIN_PATH}/${TOOLCHAIN_PREFIX}gcc")
    set(BINUTILS_PATH "${ARMGCC_TOOLCHAIN_PATH}/${TOOLCHAIN_PREFIX}gcc")
elseif(EXISTS "${ARMGCC_TOOLCHAIN_PATH}/bin/${TOOLCHAIN_PREFIX}gcc")
    set(BINUTILS_PATH "${ARMGCC_TOOLCHAIN_PATH}/bin/${TOOLCHAIN_PREFIX}gcc")
else()
    message(FATAL_ERROR "No ${TOOLCHAIN_PREFIX}gcc found at ${ARMGCC_TOOLCHAIN_PATH}")
endif()

get_filename_component(ARMGCC_TOOLCHAIN_PATH "${BINUTILS_PATH}" DIRECTORY)

# Without that flag CMake is not able to pass test compilation check
if (${CMAKE_VERSION} VERSION_EQUAL "3.6.0" OR ${CMAKE_VERSION} VERSION_GREATER "3.6")
    set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
else()
    set(CMAKE_EXE_LINKER_FLAGS_INIT "--specs=nosys.specs")
endif()

# Workaround for VSCode CMake Tools that needs the compiler paths in the CMake cache
set(CMAKE_C_COMPILER "${ARMGCC_TOOLCHAIN_PATH}/${TOOLCHAIN_PREFIX}gcc" CACHE FILEPATH "C Compiler path")
set(CMAKE_ASM_COMPILER "${ARMGCC_TOOLCHAIN_PATH}/${TOOLCHAIN_PREFIX}gcc" CACHE FILEPATH "ASM Compiler path")
set(CMAKE_CXX_COMPILER "${ARMGCC_TOOLCHAIN_PATH}/${TOOLCHAIN_PREFIX}g++" CACHE FILEPATH "C++ Compiler path")

set(CMAKE_OBJCOPY "${ARMGCC_TOOLCHAIN_PATH}/${TOOLCHAIN_PREFIX}objcopy" CACHE INTERNAL "objcopy tool")
set(CMAKE_OBJDUMP "${ARMGCC_TOOLCHAIN_PATH}/${TOOLCHAIN_PREFIX}objdump" CACHE INTERNAL "objdump tool")
set(CMAKE_SIZE_UTIL "${ARMGCC_TOOLCHAIN_PATH}/${TOOLCHAIN_PREFIX}size" CACHE INTERNAL "size tool")

set(CMAKE_SYSROOT "${ARMGCC_TOOLCHAIN_PATH}/../arm-none-eabi")
set(CMAKE_FIND_ROOT_PATH "${BINUTILS_PATH}")
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
