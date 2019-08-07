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

    optAny:            [0 dynamic];
    optOutputFileName: [1 dynamic];
    optLinkerOption:   [3 dynamic];
    optDefinition:     [4 dynamic];
    optArrayCheck:     [5 dynamic];
    nextOption: optAny;

    options: ProcessorOptions;
    hasVersion: FALSE dynamic;
    parserResults: ParserResults;
    definitions: String;
    hasVersion: FALSE dynamic;
    outputFileName: "mpl.ll" toString;

    forceArrayChecks: -1 dynamic;

    "*definitions" toString @options.@fileNames.pushBack

    argc 1 = [
      printInfo
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
            printInfo
          ] [
            splittedOption: option.split;
            splittedOption.success not [
              "Invalid argument encoding: " print option print LF print
              printInfo
            ] [
              nextOption (
                optAny [
                  option (
                    "-auto_recursion" [TRUE              @options.!autoRecursion]
                    "-ndebug"         [FALSE             @options.!debug]
                    "-logs"           [TRUE              @options.!logs]
                    "-statlit"        [TRUE              @options.!staticLiterals]
                    "-dynalit"        [FALSE             @options.!staticLiterals]
                    "-32bits"         [32nx              @options.!pointerSize]
                    "-64bits"         [64nx              @options.!pointerSize]
                    "-verbose_ir"     [TRUE              @options.!verboseIR]
                    "-version"        [TRUE              !hasVersion]
                    "-linker_option"  [optLinkerOption   !nextOption]
                    "-o"              [optOutputFileName !nextOption]
                    "-D"              [optDefinition     !nextOption]
                    "-array_checks"   [optArrayCheck     !nextOption]
                    [
                      0 splittedOption.chars.at "-" = [
                        "Invalid argument: " print option print LF print
                        printInfo
                      ] [
                        option toString @options.@fileNames.pushBack
                      ] if
                    ]
                  ) case
                ]
                optOutputFileName [
                  option toString @outputFileName set
                  optAny !nextOption
                ]
                optLinkerOption   [
                  option toString @options.@linkerOptions.pushBack
                  optAny !nextOption
                ]
                optDefinition     [
                  splittedOption createDefinition
                  optAny !nextOption
                ]
                optArrayCheck     [
                  option (
                    "0"   [0 @forceArrayChecks set]
                    "1"   [1 @forceArrayChecks set]
                    [
                      "Invalid argument value: " print option print LF print
                      printInfo
                    ]
                  ) case
                  optAny !nextOption
                ]
                []
              ) case
            ] if
          ] if
        ] if
      ] times
    ] if

    nextOption optAny = not [
      "Value expected" print LF print
      printInfo
      FALSE @success set
    ] [
      forceArrayChecks (
        0 [FALSE]
        1 [TRUE]
        [options.debug copy]
      ) case @options.@arrayChecks set

      options.fileNames.getSize 1 = [
        hasVersion [
          DEBUG [
            ("MPL compiler version " COMPILER_SOURCE_VERSION " debug" LF) printList
          ] [
            ("MPL compiler version " COMPILER_SOURCE_VERSION LF) printList
          ] if
        ] [
          "No input files" print LF print
        ] if
      ] [
        hasVersion [
          ("MPL compiler version " COMPILER_SOURCE_VERSION LF) printList
          "Input files ignored" print LF print
        ] [
          outputFileName "" = [
            "No output file" print LF print
            printInfo
            FALSE @success set
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
