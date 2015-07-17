
externalrule 'ragel'
    location 'ragel'
    filename 'ragel'
    fileextension '.rl'
    propertydefinition {
        name = 'OutputFileName',
    }
    propertydefinition {
        name = 'Outputs',
    }
    propertydefinition {
        name = 'CodeStyle',
    }

solution 'csv'
    configurations { 'Debug', 'Release' }
    language 'C'
    defines { 'WIN32', '_WIN32', 'WINDOWS', '_WINDOWS' }
    flags { 'StaticRuntime', 'NoManifest', }

    location 'build'
    targetdir 'bin'
    objdir 'obj'

    rules { 'ragel' }
    ragelVars {
        OutputFileName = '../src/%(Filename).c',
        Outputs        = '%(OutputFileName)',
        CodeStyle      = '6',
    }

    filter { 'action:vs*' }
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
    includedirs {
        'src',
    }
    files {
        'src/csv.h',
        'src/csv.rl',
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

