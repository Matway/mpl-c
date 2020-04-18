"control" useModule
"pathUtils" useModule
"astNodeType" useModule
"parser" useModule
"astOptimizers" useModule
"processor" useModule
"processorImpl" useModule
"file" useModule

printInfo: [
  "USAGE: mplc.exe [options] <inputs>" print LF print
  "OPTIONS:" print LF print
  "  -32bits                             Set 32-bit mode, default mode is 64-bit" print LF print
  "  -64bits                             Set 64-bit mode, default mode is 64-bit" print LF print
  "  -D <name[ =value]>                  Define global name with value, default value is ()" print LF print
  "  -array_checks 0|1                   Turn off/on array index checks, by default it is on in debug mode and off in release mode" print LF print
  "  -auto_recursion                     Make all code block recursive-by-default" print LF print
  "  -call_trace                         Generate information about call trace" print LF print
  debugMemory [
    "  -debug_memory                       Produce memory usage information" print LF print
  ] when
  "  -dynalit                            Number literals are dynamic constants, which are not used in analysis; default mode is static literals" print LF print
  "  -linker_option                      Add linker option for LLVM" print LF print
  "  -logs                               Value of \"HAS_LOGS\" constant in code turn to TRUE" print LF print
  "  -ndebug                             Disable debug info; value of \"DEBUG\" constant in code turn to FALSE" print LF print
  "  -o <file>                           Write output to <file>, default output file is \"mpl.ll\"" print LF print
  "  -pre_recursion_depth_limit <number> Set PRE recursion depth limit, default value is " print DEFAULT_PRE_RECURSION_DEPTH_LIMIT print LF print
  "  -recursion_depth_limit <number>     Set recursion depth limit, default value is " print DEFAULT_RECURSION_DEPTH_LIMIT print LF print
  "  -static_loop_length_limit <number>  Set static loop length limit, default value is " print DEFAULT_STATIC_LOOP_LENGTH_LIMIT print LF print
  "  -statlit                            Number literals are static constants, which are used in analysis; default mode is static literals" print LF print
  "  -verbose_ir                         Print information about current token in IR" print LF print
  "  -version                            Print compiler version while compiling" print LF print
  FALSE @success set
];

addToProcess: [
  fileText:;
  copy fileNumber:;
  fileName:;
  parserResult: ParserResult;

  @parserResult fileText makeStringView fileNumber parseString

  parserResult.success [
    @parserResult optimizeLabels
    @parserResult move @parserResults.pushBack
  ] [
    ("ERROR") addLog

    (fileName "(" parserResult.errorInfo.position.line "," makeStringView parserResult.errorInfo.position.column "): syntax error, "
      parserResult.errorInfo.message) assembleString print LF print
    FALSE @success set
  ] if
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
    name: 0 eqIndex splittedOption.chars makeSubRange assembleString;
    value: eqIndex 1 + splittedOption.chars.getSize splittedOption.chars makeSubRange assembleString;
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
        asciiCode: codepoint.data Nat8 addressToReference Nat32 cast;
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

{argc: 0; argv: 0nx;} 0 {convention: cdecl;} [
  ("Start mplc compiler") addLog
  [
    argc:;
    argv:;

    success: TRUE dynamic;

    OPT_ANY:                       [0 dynamic];
    OPT_OUTPUT_FILE_NAME:          [1 dynamic];
    OPT_LINKER_OPTION:             [3 dynamic];
    OPT_DEFINITION:                [4 dynamic];
    OPT_ARRAY_CHECK:               [5 dynamic];
    OPT_CALL_TRACE:                [6 dynamic];
    OPT_RECURSION_DEPTH_LIMIT:     [7 dynamic];
    OPT_PRE_RECURSION_DEPTH_LIMIT: [8 dynamic];
    OPT_STATIC_LOOP_LENGTH_LIMIT:  [9 dynamic];

    nextOption: OPT_ANY;

    options: ProcessorOptions;
    hasVersion: FALSE dynamic;
    parserResults: ParserResults;
    definitions: String;
    hasVersion: FALSE dynamic;
    outputFileName: "mpl.ll" toString;

    forceArrayChecks: -1 dynamic;
    forceCallTrace: -1 dynamic;

    "*definitions" toString @options.@fileNames.pushBack

    argc 1 = [
      FALSE @success set
    ] [
      argc [
        i 0 = [
          addr: 0nx storageSize i 0ix cast 0nx cast * argv + Natx addressToReference;
          addr makeStringViewByAddress extractClearPath @options.@mainPath set
        ] [
          addr: 0nx storageSize i 0ix cast 0nx cast * argv + Natx addressToReference;
          option: addr makeStringViewByAddress;

          option textSize 0nx = [
            "Error, argument cannot be empty" print LF print
            FALSE @success set
          ] [
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
                    "-array_checks"              [OPT_ARRAY_CHECK               !nextOption]
                    "-auto_recursion"            [TRUE                          @options.!autoRecursion]
                    "-call_trace"                [OPT_CALL_TRACE                !nextOption]
                    debugMemory [
                      "-debug_memory"            [TRUE                          @options.!debugMemory]
                    ] when
                    "-dynalit"                   [FALSE                         @options.!staticLiterals]
                    "-linker_option"             [OPT_LINKER_OPTION             !nextOption]
                    "-logs"                      [TRUE                          @options.!logs]
                    "-ndebug"                    [FALSE                         @options.!debug]
                    "-o"                         [OPT_OUTPUT_FILE_NAME          !nextOption]
                    "-pre_recursion_depth_limit" [OPT_PRE_RECURSION_DEPTH_LIMIT !nextOption]
                    "-recursion_depth_limit"     [OPT_RECURSION_DEPTH_LIMIT     !nextOption]
                    "-static_loop_length_limit"  [OPT_STATIC_LOOP_LENGTH_LIMIT  !nextOption]
                    "-verbose_ir"                [TRUE                          @options.!verboseIR]
                    "-statlit"                   [TRUE                          @options.!staticLiterals]
                    "-version"                   [TRUE                          !hasVersion]
                    [
                      0 splittedOption.chars.at "-" = [
                        "Invalid argument: " print option print LF print
                        FALSE @success set
                      ] [
                        option toString @options.@fileNames.pushBack
                      ] if
                    ]
                  ) case
                ]
                OPT_OUTPUT_FILE_NAME [
                  option toString @outputFileName set
                  OPT_ANY !nextOption
                ]
                OPT_LINKER_OPTION [
                  option toString @options.@linkerOptions.pushBack
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
                []
              ) case
            ] if
          ] if
        ] if
      ] times
    ] if

    nextOption OPT_ANY = ~ [
      "Value expected" print LF print
      FALSE @success set
    ] when

    outputFileName "" = [
      "No output file" print LF print
      FALSE @success set
    ] when

    options.fileNames.getSize 1 = [
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
          [options.debug copy]
        ) case @options.@arrayChecks set

        forceCallTrace (
          0 [FALSE]
          1 [TRUE]
          2 [TRUE]
          [options.debug copy]
        ) case @options.@callTrace set

        forceCallTrace 2 = [1 @options.@threadModel set] when

        hasVersion [
          ("MPL compiler version " COMPILER_SOURCE_VERSION LF) printList
          "Input files ignored" print LF print
        ] [
          options.fileNames.getSize [
            filename: i options.fileNames @;

            i 0 = [
              filename i definitions addToProcess
            ] [
              loadStringResult: filename loadString;
              loadStringResult.success [
                ("Loaded string from " filename) addLog
                ("HASH=" loadStringResult.data hash) addLog
                filename i loadStringResult.data addToProcess
              ] [
                "Unable to load string:" print filename print LF print
                FALSE @success set
              ] if
            ] if
          ] times

          success [
            multiParserResult: MultiParserResult;
            @parserResults @multiParserResult concatParserResults
            ("trees concated" makeStringView) addLog
            @multiParserResult optimizeNames
            ("names optimized" makeStringView) addLog

            ("filenames:" makeStringView) addLog
            options.fileNames [fileName:; (fileName) addLog] each

            processorResult: ProcessorResult;
            multiParserResult options 0 @processorResult process
            processorResult.success [
              outputFileName @processorResult.@program saveString [
                ("program written to " outputFileName) addLog
              ] [
                ("failed to save program" LF) printList
                FALSE @success set
              ] if
            ] when

            processorResult.success ~ [
              processorResult.globalErrorInfo.getSize [
                current: i processorResult.globalErrorInfo @;
                i 0 > [LF print] when
                current.position.getSize 0 = [
                  ("error, "  current.message) printList LF print
                ] [
                  current.position.getSize [
                    nodePosition: i current.position @;
                    (nodePosition.file.name "(" nodePosition.line  ","  nodePosition.column "): ") printList

                    i 0 = [
                      ("error, [" nodePosition.token "], " current.message LF) printList
                    ] [
                      ("[" nodePosition.token "], called from here" LF) printList
                    ] if
                  ] times
                ] if

                FALSE @success set
              ] times
            ] when
          ] when
        ] if
      ] if
    ] if

    success [0][1] if
    debugMemory [options.debugMemory copy] when
  ] call

  debugMemory [] && [
    (
      "allocations: " memoryCurrentAllocationCount copy "/" memoryTotalAllocationCount copy
      ", bytes: " memoryCurrentAllocationSize copy "/" memoryTotalAllocationSize copy
      ", max: " memoryMaxAllocationSize copy
      ", checksum: " memoryChecksum copy
      LF
    ) printList
  ] when
] "main" exportFunction
