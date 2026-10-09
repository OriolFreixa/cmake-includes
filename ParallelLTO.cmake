# juce::juce_recommended_lto_flags passes bare -flto. On GCC that makes the
# linker run LTRANS jobs serially and print:
#   lto-wrapper: warning: using serial compilation of N LTRANS jobs
# Use parallel LTO instead so Release links use all available cores.
#
# Usage: link colours::parallel_lto_flags instead of juce::juce_recommended_lto_flags.
#
#   target_link_libraries(SharedCode INTERFACE colours::parallel_lto_flags)

add_library(colours_parallel_lto_flags INTERFACE)
add_library(colours::parallel_lto_flags ALIAS colours_parallel_lto_flags)

if((CMAKE_CXX_COMPILER_ID STREQUAL "MSVC") OR (CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC"))
    target_compile_options(colours_parallel_lto_flags INTERFACE
        $<$<CONFIG:Release>:$<IF:$<STREQUAL:"${CMAKE_CXX_COMPILER_ID}","MSVC">,-GL,-flto>>)
    target_link_libraries(colours_parallel_lto_flags INTERFACE
        $<$<CONFIG:Release>:$<$<STREQUAL:"${CMAKE_CXX_COMPILER_ID}","MSVC">:-LTCG>>)
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    target_compile_options(colours_parallel_lto_flags INTERFACE $<$<CONFIG:Release>:-flto=auto>)
    target_link_options(colours_parallel_lto_flags INTERFACE $<$<CONFIG:Release>:-flto=auto>)
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    # ThinLTO parallelises across cores; full LTO stays closer to serial.
    target_compile_options(colours_parallel_lto_flags INTERFACE $<$<CONFIG:Release>:-flto=thin>)
    target_link_options(colours_parallel_lto_flags INTERFACE $<$<CONFIG:Release>:-flto=thin>)
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang")
    target_compile_options(colours_parallel_lto_flags INTERFACE $<$<CONFIG:Release>:-flto>)
    target_link_options(colours_parallel_lto_flags INTERFACE $<$<CONFIG:Release>:-flto>)
    # Xcode 15.0 requires this flag to avoid a compiler bug (same as JUCE).
    target_link_options(colours_parallel_lto_flags INTERFACE
        $<$<CONFIG:Release>:-Wl,-weak_reference_mismatches,weak>)
endif()
