
solution 'csv'
    configurations { 'Debug', 'Release' }
    language 'C'
    defines { 'WIN32', '_WINDOWS' }
    flags { 'StaticRuntime', 'NoManifest', }

    location 'build'
    targetdir 'bin'
    objdir 'obj'

    filter { 'configurations:vs*' }
        defines { '_CRT_SECURE_NO_WARNINGS' }

    filter { 'configurations:Debug' }
        defines { '_DEBUG' }
        flags { 'Symbols' }
        optimize 'Debug'
        targetsuffix '_d'

    filter { 'configurations:Release' }
        defines { 'NDEBUG' }
        optimize 'Full'

project 'csv'
    kind 'StaticLib'

    files {
        'src/csv.h',
        'src/csv.c',
        'src/csv.rl',
    }

    prebuildcommands {
        '@echo on',
        "ragel -C -T1 ../src/csv.rl",
    }

project 'test'
    kind 'ConsoleApp'

    includedirs {
        'src',
    }
    links {
        'csv',
    }

    files {
        'test/test.c',
    }

    configuration 'Debug'
        debugdir '$(TargetDir)'
        debugargs 'header.csv >1'

