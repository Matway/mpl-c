# Copyright (C) 2021 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"Array"       use
"HashTable"   use
"String"      use
"algorithm"   use
"ascii"       use
"control"     use
"conventions" use
"file"        use
"memory"      use

"NameManager"   use
"astNodeType"   use
"declarations"  use
"logger"        use
"pathUtils"     use
"processor"     use
"processorImpl" use

debugMemory [
  "memory.getMemoryMetrics" use
] [] uif

printInfo: [
  "USAGE: mplc.exe [options] <inputs>" print LF print
  "OPTIONS:" print LF print
  "  -32bits                             Set 32-bit mode, default mode is 64-bit" print LF print
  "  -64bits                             Set 64-bit mode, default mode is 64-bit" print LF print
  "  -D <name[ =value]>                  Define global name with value, default value is ()" print LF print
  "  -I <path>                           Add include path to find files" print LF print
  "  -array_checks 0|1                   Turn off/on array index checks, by default it is on in debug mode and off in release mode" print LF print
  "  -auto_recursion                     Make all code block recursive-by-default" print LF print
  "  -begin_func <name>                  Name of begin function, default value is \"main\"" print LF print
  "  -call_trace                         Generate information about call trace" print LF print
  ("  -data_layout                        Specify data layout; default value is " DEFAULT_DATA_LAYOUT_32 " in 32-bit mode and " DEFAULT_DATA_LAYOUT_32 " in 64-bit mode" LF) printList
  debugMemory [
    "  -debug_memory                       Produce memory usage information" print LF print
  ] when
  "  -dynalit                            Number literals are dynamic constants, which are not used in analysis; default mode is static literals" print LF print
  "  -end_func <name>                    Name of end function, default value is \"main\"" print LF print
  "  -hide_prefix <path>                 Ignore files with this prefix in stack trace outputs" print LF print
  "  -linker_option                      Add linker option for LLVM" print LF print
  "  -ndebug                             Disable debug info; value of \"DEBUG\" constant in code turn to FALSE" print LF print
  "  -o <file>                           Write output to <file>, default output file is \"mpl.ll\"" print LF print
  "  -part                               Create ll only for files in cmd line" print LF print
  ("  -pre_recursion_depth_limit <number> Set PRE recursion depth limit, default value is " DEFAULT_PRE_RECURSION_DEPTH_LIMIT LF) printList
  ("  -recursion_depth_limit <number>     Set recursion depth limit, default value is " DEFAULT_RECURSION_DEPTH_LIMIT LF) printList
  ("  -static_loop_length_limit <number>  Set static loop length limit, default value is " DEFAULT_STATIC_LOOP_LENGTH_LIMIT LF) printList
  "  -statlit                            Number literals are static constants, which are used in analysis; default mode is static literals" print LF print
  ("  -triple                             Specify target triple; default value is " DEFAULT_TRIPLE_32 " in 32-bit mode and " DEFAULT_TRIPLE_64 " in 64-bit mode" LF) printList
  "  -verbose_ir                         Print information about current token in IR" print LF print
  "  -version                            Print compiler version while compiling" print LF print
  FALSE @success set
];

createDefinition: [
  splittedOption:;
  eqIndex: -1;
  i: 0;

  [
    i splittedOption.chars.getSize < [
      i splittedOption.chars.at "=" = [
        i @eqIndex set
        FALSE
      ] [
        i 1 + @i set
        TRUE
      ] if
    ] &&
  ] loop

  eqIndex 0 < [
    (splittedOption.chars assembleString ": ();" LF) assembleString @definitions.cat
  ] [
    name: splittedOption.chars eqIndex head assembleString;
    value: splittedOption.chars eqIndex 1 + unhead assembleString;
    (name makeStringView ": [" value makeStringView " static];" LF) assembleString @definitions.cat
  ] if
];

parseIntegerOption: [
  text:;
  result: {
    error: "" toString;
    value: 0;
  };

  (
    [result.error "" =]
    [
      splitResult: text splitString;
      splitResult.success ~ [
        "value is not value UTF-8 sequence" toString @result.!error
      ] when
    ]
    [
      codepoints: splitResult.chars;
      codepoints.getSize 0 = [
        "value is empty" toString @result.!error
      ] when
    ]
    [
      codepointIndex: 0;
      [result.error "" = [codepointIndex codepoints.getSize <] &&] [
        codepoint: codepointIndex codepoints @;
        asciiCode: codepoint.data Nat32 cast;
        asciiCode (
          [code:; asciiCode ascii.zero < [asciiCode ascii.nine >] ||] ["value has non-digit character" toString @result.!error]
          [code:; code ascii.zero = [codepointIndex 0 =] && [codepoints.getSize 1 >] &&] ["value has leading zeros" toString @result.!error]
          [
            digit: asciiCode ascii.zero - Int32 cast;
            result.value 10 * digit + @result.@value set
          ]
        ) cond

        codepointIndex 1 + !codepointIndex
      ] while
    ]
  ) sequence

  result
];

processIntegerOption: [
  text:option:;;
  parserResult: text parseIntegerOption;
  parserResult.error "" = ~ [
    ("Invalid argument value: " text ", " parserResult.error LF) printList
    FALSE !success
  ] [
    parserResult.value @option set
  ] if
];

addToProcessAndCheck: [
  errorMessage: addToProcess;
  errorMessage "" = ~ [
    errorMessage print LF print
    FALSE !success
  ] when
];

checkedSaveString: [
  name: string: ;;

  loadResult: name loadString;
  loadResult.success [loadResult.data string =] && [
    (name ".temp") assembleString string saveString
  ] [
    name string saveString
  ] if
];

{argc: 0; argv: 0nx;} 0 {convention: cdecl;} [
  #debugMemory [TRUE !memoryDebugEnabled] when
  ("Start mplc compiler") addLog

  [
    argc:;
    argv:;

    success: TRUE dynamic;

    OPT_ANY:                       [ 0 dynamic];
    OPT_OUTPUT_FILE_NAME:          [ 1 dynamic];
    OPT_LINKER_OPTION:             [ 3 dynamic];
    OPT_DEFINITION:                [ 4 dynamic];
    OPT_ARRAY_CHECK:               [ 5 dynamic];
    OPT_CALL_TRACE:                [ 6 dynamic];
    OPT_RECURSION_DEPTH_LIMIT:     [ 7 dynamic];
    OPT_PRE_RECURSION_DEPTH_LIMIT: [ 8 dynamic];
    OPT_STATIC_LOOP_LENGTH_LIMIT:  [ 9 dynamic];
    OPT_INCLUDE_PATH:              [10 dynamic];
    OPT_BEGIN_FUNC:                [11 dynamic];
    OPT_END_FUNC:                  [12 dynamic];
    OPT_TRIPLE:                    [13 dynamic];
    OPT_DATA_LAYOUT:               [14 dynamic];
    OPT_HIDE_PREFIX:               [15 dynamic];

    nextOption: OPT_ANY;

    options: ProcessorOptions;
    hasVersion: FALSE dynamic;
    definitions: String;
    outputFileName: "mpl.ll" toString;

    forceArrayChecks: -1 dynamic;
    forceCallTrace: -1 dynamic;
    hasTriple:     FALSE dynamic;
    hasDataLayout: FALSE dynamic;

    multiParserResult: MultiParserResult;
    nameManager: NameInfoEntry NameManager;

    "*builtins"    toString @options.@fileNames.append
    "*definitions" toString @options.@fileNames.append
    "main" toString @options.@beginFunc set
    "main" toString @options.@endFunc set

    fullLine: String;

    argc 1 = [
      FALSE @success set
    ] [
      argc [
        i 0 = [
          addr: 0nx storageSize i 0ix cast 0nx cast * argv + Natx addressToReference;
          option:  addr makeStringViewByAddress;
          option @fullLine.cat
          option extractClearPath @options.@mainPath set
        ] [
          addr: 0nx storageSize i 0ix cast 0nx cast * argv + Natx addressToReference;
          option: addr makeStringViewByAddress;
          (" " option) @fullLine.catMany

          splittedOption: option splitString;
          splittedOption.success ~ [
            "Invalid argument encoding: " print option print LF print
            FALSE @success set
          ] [
            nextOption (
              OPT_ANY [
                option (
                  "-32bits"                    [32nx                          @options.!pointerSize]
                  "-64bits"                    [64nx                          @options.!pointerSize]
                  "-D"                         [OPT_DEFINITION                !nextOption]
                  "-I"                         [OPT_INCLUDE_PATH              !nextOption]
                  "-array_checks"              [OPT_ARRAY_CHECK               !nextOption]
                  "-auto_recursion"            [TRUE                          @options.!autoRecursion]
                  "-begin_func"                [OPT_BEGIN_FUNC                !nextOption]
                  "-call_trace"                [OPT_CALL_TRACE                !nextOption]
                  "-data_layout"               [OPT_DATA_LAYOUT               !nextOption]
                  debugMemory [
                    "-debug_memory"            [TRUE                          @options.!debugMemory]
                  ] when
                  "-dynalit"                   [FALSE                         @options.!staticLiterals]
                  "-end_func"                  [OPT_END_FUNC                  !nextOption]
                  "-hide_prefix"               [OPT_HIDE_PREFIX               !nextOption]
                  "-linker_option"             [OPT_LINKER_OPTION             !nextOption]
                  "-ndebug"                    [FALSE                         @options.!debug]
                  "-o"                         [OPT_OUTPUT_FILE_NAME          !nextOption]
                  "-part"                      [TRUE                          @options.!partial]
                  "-pre_recursion_depth_limit" [OPT_PRE_RECURSION_DEPTH_LIMIT !nextOption]
                  "-recursion_depth_limit"     [OPT_RECURSION_DEPTH_LIMIT     !nextOption]
                  "-static_loop_length_limit"  [OPT_STATIC_LOOP_LENGTH_LIMIT  !nextOption]
                  "-verbose_ir"                [TRUE                          @options.!verboseIR]
                  "-statlit"                   [TRUE                          @options.!staticLiterals]
                  "-triple"                    [OPT_TRIPLE                    !nextOption]
                  "-version"                   [TRUE                          !hasVersion]
                  [
                    splittedOption.chars.size 0 > [0 splittedOption.chars.at "-" =] && [
                      "Invalid argument: " print option print LF print
                      FALSE @success set
                    ] [
                      option simplifyFileName @options.@fileNames.append
                    ] if
                  ]
                ) case
              ]
              OPT_OUTPUT_FILE_NAME [
                option toString @outputFileName set
                OPT_ANY !nextOption
              ]
              OPT_LINKER_OPTION [
                option toString @options.@linkerOptions.append
                OPT_ANY !nextOption
              ]
              OPT_DEFINITION [
                splittedOption createDefinition
                OPT_ANY !nextOption
              ]
              OPT_ARRAY_CHECK [
                option (
                  "0"   [0 @forceArrayChecks set]
                  "1"   [1 @forceArrayChecks set]
                  [
                    "Invalid argument value: " print option print LF print
                    FALSE @success set
                  ]
                ) case
                OPT_ANY !nextOption
              ]
              OPT_CALL_TRACE [
                option (
                  "0"   [0 @forceCallTrace set]
                  "1"   [1 @forceCallTrace set]
                  "2"   [2 @forceCallTrace set]
                  [
                    "Invalid argument value: " print option print LF print
                    FALSE @success set
                  ]
                ) case
                OPT_ANY !nextOption
              ]
              OPT_RECURSION_DEPTH_LIMIT [
                option @options.@recursionDepthLimit processIntegerOption
                OPT_ANY !nextOption
              ]
              OPT_PRE_RECURSION_DEPTH_LIMIT [
                option @options.@preRecursionDepthLimit processIntegerOption
                OPT_ANY !nextOption
              ]
              OPT_STATIC_LOOP_LENGTH_LIMIT [
                option @options.@staticLoopLengthLimit processIntegerOption
                OPT_ANY !nextOption
              ]
              OPT_INCLUDE_PATH [
                option simplifyFileName @options.@includePaths.append
                OPT_ANY !nextOption
              ]
              OPT_BEGIN_FUNC [
                option toString @options.@beginFunc set
                OPT_ANY !nextOption
              ]
              OPT_END_FUNC [
                option toString @options.@endFunc set
                OPT_ANY !nextOption
              ]
              OPT_DATA_LAYOUT [
                option toString @options.@dataLayout set
                TRUE !hasDataLayout
                OPT_ANY !nextOption
              ]
              OPT_TRIPLE [
                option toString @options.@triple set
                TRUE !hasTriple
                OPT_ANY !nextOption
              ]
              OPT_HIDE_PREFIX [
                option simplifyFileName @options.@hidePrefixes.append
                OPT_ANY !nextOption
              ]
              []
            ) case
          ] if
        ] if
      ] times
    ] if

    @fullLine @options.@fullLine set

    nextOption OPT_ANY = ~ [
      "Value expected" print LF print
      FALSE @success set
    ] when

    outputFileName "" = [
      "No output file" print LF print
      FALSE @success set
    ] when

    options.fileNames.getSize 2 = [
      hasVersion [
        DEBUG [
          ("MPL compiler version " COMPILER_SOURCE_VERSION " debug" LF) printList
        ] [
          ("MPL compiler version " COMPILER_SOURCE_VERSION LF) printList
        ] if
      ] [
        "No input files" print LF print
        FALSE @success set
        printInfo
      ] if
    ] [
      success ~ [
        printInfo
      ] [
        forceArrayChecks (
          0 [FALSE]
          1 [TRUE]
          [options.debug new]
        ) case @options.@arrayChecks set

        forceCallTrace (
          0 [FALSE]
          1 [TRUE]
          2 [TRUE]
          [FALSE]
        ) case @options.@callTrace set

        hasDataLayout ~ [
          options.pointerSize (
            32nx [DEFAULT_DATA_LAYOUT_32 toString @options.@dataLayout set]
            64nx [DEFAULT_DATA_LAYOUT_64 toString @options.@dataLayout set]
            []
          ) case
        ] when

        hasTriple ~ [
          options.pointerSize (
            32nx [DEFAULT_TRIPLE_32 toString @options.@triple set]
            64nx [DEFAULT_TRIPLE_64 toString @options.@triple set]
            []
          ) case
        ] when

        forceCallTrace 2 = [1 @options.@threadModel set] when

        hasVersion [
          ("MPL compiler version " COMPILER_SOURCE_VERSION LF) printList
          "Input files ignored" print LF print
        ] [
          options.fileNames.size @options.@fileTexts.resize
          options.fileNames.getSize [
            fileName: i options.fileNames @;

            i 0 = [
              #builtins
            ] [
              i 1 = [
                i fileName makeStringView definitions makeStringView @multiParserResult @nameManager addToProcessAndCheck
              ] [
                loadStringResult: fileName loadString;
                loadStringResult.success [
                  ("Loaded string from " fileName) addLog
                  ("HASH=" loadStringResult.data hash) addLog
                  i fileName makeStringView loadStringResult.data makeStringView @multiParserResult @nameManager addToProcessAndCheck
                  @loadStringResult.@data i @options.@fileTexts !
                ] [
                  "Unable to load string:" print fileName print LF print
                  FALSE @success set
                ] if
              ] if
            ] if
          ] times

          success [

            ("filenames:" makeStringView) addLog
            options.fileNames [fileName:; (fileName) addLog] each

            result: String;
            program: String;
            @multiParserResult @nameManager options 0 @result @program process
            result.size 0 = [
              outputFileName program checkedSaveString [
                ("program written to " outputFileName) addLog
              ] [
                ("failed to save program" LF) printList
                FALSE @success set
              ] if
            ] [
              result print
              FALSE @success set
            ] if
          ] when
        ] if
      ] if
    ] if

    success [0][1] if
    debugMemory [options.debugMemory new] when
  ] call

  debugMemory [] && [
    #mplReleaseCache
    getMemoryMetrics.memoryChecksum 0nx = ~ [
      (
        "allocations: " getMemoryMetrics.memoryCurrentAllocationCount new By3 "/" getMemoryMetrics.memoryTotalAllocationCount new By3
        ", bytes: " getMemoryMetrics.memoryCurrentAllocationSize new By3 "/" getMemoryMetrics.memoryTotalAllocationSize new By3
        ", max: " getMemoryMetrics.memoryMaxAllocationSize new By3
        ", checksum: " getMemoryMetrics.memoryChecksum new By3
        LF
      ) printList
    ] [
      (
        "allocations: " getMemoryMetrics.memoryTotalAllocationCount new By3
        ", bytes: " getMemoryMetrics.memoryTotalAllocationSize new By3
        ", max: " getMemoryMetrics.memoryMaxAllocationSize new By3
        LF
      ) printList
    ] if
  ] when
] "main" exportFunction
