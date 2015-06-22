
solution 'csv'
    configurations { 'Debug', 'Release' }
    language 'C'
    defines { 'WIN32', '_WINDOWS' }
    flags { 'StaticRuntime' }

    location 'build'
    targetdir 'bin'
    objdir 'obj'

    configuration 'vs*'
        defines { '_CRT_SECURE_NO_WARNINGS' }

    configuration 'Debug'
        flags { 'Symbols' }
        defines { '_DEBUG' }
        targetsuffix '_d'

    configuration 'Release'
        flags { 'Optimize' }
        defines { 'NDEBUG' }

project 'csv'
    kind 'StaticLib'

    files {
        'src/*.h',
        'src/*.c',
    }

    prebuildcommands
    {
        '@echo on',
        "ragel -G2 ../src/csv.rl",
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
        'test/*.c',
    }

    configuration 'Debug'
        debugdir '$(TargetDir)'
        debugargs 'header.csv >1'

