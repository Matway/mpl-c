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
  "  -32bits             Set 32-bit mode, default mode is 64-bit" print LF print
  "  -64bits             Set 64-bit mode, default mode is 64-bit" print LF print
  "  -D <name[ =value]>  Define global name with value, default value is ()" print LF print
  "  -array_checks 0|1   Turn off/on array index checks, by default it is on in debug mode and off in release mode" print LF print
  "  -auto_recursion     Make all code block recursive-by-default" print LF print
  "  -call_trace         Generate information about call trace" print LF print
  "  -dynalit            Number literals are dynamic constants, which are not used in analysis; default mode is static literals" print LF print
  "  -linker_option      Add linker option for LLVM" print LF print
  "  -logs               Value of \"HAS_LOGS\" constant in code turn to TRUE" print LF print
  "  -ndebug             Disable debug info; value of \"DEBUG\" constant in code turn to FALSE" print LF print
  "  -o <file>           Write output to <file>, default output file is \"mpl.ll\"" print LF print
  "  -statlit            Number literals are static constants, which are used in analysis; default mode is static literals" print LF print
  "  -verbose_ir         Print information about current token in IR" print LF print
  "  -version            Print compiler version while compiling" print LF print
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

{argc: 0; argv: 0nx;} 0 {convention: cdecl;} [
  ("Start mplc compiler") addLog
  [
    argc:;
    argv:;

    success: TRUE dynamic;

    OPT_ANY:                [0 dynamic];
    OPT_OUTPUT_FILE_NAME:   [1 dynamic];
    OPT_LINKER_OPTION:      [3 dynamic];
    OPT_DEFINITION:         [4 dynamic];
    OPT_ARRAY_CHECK:        [5 dynamic];
    OPT_CALL_TRACE:         [6 dynamic];
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
            splittedOption: option.split;
            splittedOption.success not [
              "Invalid argument encoding: " print option print LF print
              FALSE @success set
            ] [
              nextOption (
                OPT_ANY [
                  option (
                    "-auto_recursion" [TRUE              @options.!autoRecursion]
                    "-ndebug"         [FALSE             @options.!debug]
                    "-logs"           [TRUE              @options.!logs]
                    "-statlit"        [TRUE              @options.!staticLiterals]
                    "-dynalit"        [FALSE             @options.!staticLiterals]
                    "-32bits"         [32nx              @options.!pointerSize]
                    "-64bits"         [64nx              @options.!pointerSize]
                    "-verbose_ir"     [TRUE              @options.!verboseIR]
                    "-version"        [TRUE                 !hasVersion]
                    "-linker_option"  [OPT_LINKER_OPTION    !nextOption]
                    "-o"              [OPT_OUTPUT_FILE_NAME !nextOption]
                    "-D"              [OPT_DEFINITION       !nextOption]
                    "-array_checks"   [OPT_ARRAY_CHECK      !nextOption]
                    "-call_trace"     [OPT_CALL_TRACE       !nextOption]
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
                OPT_LINKER_OPTION   [
                  option toString @options.@linkerOptions.pushBack
                  OPT_ANY !nextOption
                ]
                OPT_DEFINITION     [
                  splittedOption createDefinition
                  OPT_ANY !nextOption
                ]
                OPT_ARRAY_CHECK     [
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
                OPT_CALL_TRACE     [
                  option (
                    "0"   [0 @forceCallTrace set]
                    "1"   [1 @forceCallTrace set]
                    [
                      "Invalid argument value: " print option print LF print
                      FALSE @success set
                    ]
                  ) case
                  OPT_ANY !nextOption
                ]
                []
              ) case
            ] if
          ] if
        ] if
      ] times
    ] if

    nextOption OPT_ANY = not [
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
      ] if
    ] when

    success not [
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
        [options.debug copy]
      ) case @options.@callTrace set

      hasVersion [
        ("MPL compiler version " COMPILER_SOURCE_VERSION LF) printList
        "Input files ignored" print LF print
      ] [
        options.fileNames [
          pair:;
          filename: pair.value;

          pair.index 0 = [
            filename pair.index definitions addToProcess
          ] [
            loadStringResult: filename loadString;
            loadStringResult.success [
              ("Loaded string from " filename) addLog
              ("HASH=" loadStringResult.data hash) addLog
              filename pair.index loadStringResult.data addToProcess
            ] [
              "Unable to load string:" print filename print LF print
              FALSE @success set
            ] if
          ] if
        ] each

        success [
          multiParserResult: MultiParserResult;
          @parserResults @multiParserResult concatParserResults
          ("trees concated" makeStringView) addLog
          @multiParserResult optimizeNames
          ("names optimized" makeStringView) addLog

          ("filenames:" makeStringView) addLog
          options.fileNames [(.value) addLog] each

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

          processorResult.success not [
            processorResult.globalErrorInfo [
              pair:;
              current: pair.value;
              pair.index 0 > [LF print] when
              current.position.getSize 0 = [
                ("error, "  current.message) printList LF print
              ] [
                current.position [
                  pair:;
                  i: pair.index;
                  nodePosition: pair.value;
                  (nodePosition.fileNumber options.fileNames.at "(" nodePosition.line  ","  nodePosition.column "): ") printList

                  i 0 = [
                    ("error, [" nodePosition.token "], " current.message LF) printList
                  ] [
                    ("[" nodePosition.token "], called from here" LF) printList
                  ] if
                ] each
              ] if

              FALSE @success set
            ] each
          ] when
        ] when
      ] if
    ] if

    success [0][1] if
  ] call

  debugMemory [
    cm: memoryCounterMalloc copy;
    cf: memoryCounterFree copy;
    cx: memoryXor copy;
    cu: memoryUsed copy;
    (LF "mallocs: " cm "; frees: " cf "; xors: " cx "; used: " cu LF) printList
  ] when
] "main" exportFunction
