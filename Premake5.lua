
solution 'csv'
    configurations { 'Debug', 'Release' }
    language 'C'
    defines { 'WIN32', '_WINDOWS' }
    flags { 'StaticRuntime', 'NoManifest', }

    location 'build'
    targetdir 'bin'
    objdir 'obj'

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

    rules { 'ragel' }
    externalrule 'ragel'
        location 'ragel'
        filename 'ragel'
        fileextension '.rl'
        propertydefinition {
            name  = "OutputFileName",
            kind  = "string",
--            value = 'src\\%(Filename).c',
        }

--    filter { 'configurations:Release' }
--        ragelVars {
--            OutputFileName = 'src\\%(Filename).c',
--        }

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

