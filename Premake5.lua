
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
    characterset ("MBCS")

    location 'build'
    targetdir 'bin'
    objdir 'obj'

    rules { 'ragel' }
    ragelVars {
        OutputFileName = '../src/%(Filename).c',
        Outputs        = '%(OutputFileName)',
        CodeStyle      = '1',
    }

    filter { 'action:vs*' }
        defines { '_CRT_SECURE_NO_WARNINGS' }

    filter { 'configurations:Debug' }
        defines { '_DEBUG' }
        symbols 'On'
        symbolspath '$(OutDir)$(TargetName).pdb'
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

    filter { 'configurations:Debug' }
        debugdir '$(TargetDir)'
        debugargs 'header.csv >1'

