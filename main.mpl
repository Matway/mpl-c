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
    fileNames: String Array;
    linkerOptions: String Array;
    outputFileName: "mpl.ll" toString;

    options: ProcessorOptions;
    optOutputFileName: FALSE dynamic;
    optLinkerOption: FALSE dynamic;
    optDefinition: FALSE dynamic;
    hasVersion: FALSE dynamic;
    parserResults: ParserResults;
    definitions: String;

    forceArrayChecks: -1 dynamic;

    "definitions" toString @fileNames.pushBack

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
              optOutputFileName [
                FALSE dynamic @optOutputFileName set
                option toString @outputFileName set
              ] [
                optLinkerOption [
                  FALSE dynamic @optLinkerOption set
                  option toString @linkerOptions.pushBack
                ] [
                  forceArrayChecks -2 = [
                    option (
                      "0"   [0 @forceArrayChecks set]
                      "1"   [1 @forceArrayChecks set]
                      [
                        "Invalid argument value: " print option print LF print
                        printInfo
                      ]
                    ) case
                  ] [
                    optDefinition [
                      FALSE @optDefinition set
                      splittedOption createDefinition
                    ] [
                      option (
                        "-auto_recursion" [TRUE  @options.@autoRecursion set]
                        "-array_checks"   [-2    @forceArrayChecks set]
                        "-ndebug"         [FALSE @options.@debug set]
                        "-logs"           [TRUE  @options.@logs set]
                        "-statlit"        [TRUE  @options.@staticLiterals set]
                        "-dynalit"        [FALSE @options.@staticLiterals set]
                        "-32bits"         [32nx  @options.@pointerSize set]
                        "-64bits"         [64nx  @options.@pointerSize set]
                        "-linker_option"  [TRUE  @optLinkerOption set]
                        "-verbose_ir"     [TRUE  @options.@verboseIR set]
                        "-version"        [TRUE  @hasVersion set]
                        "-o"              [TRUE  @optOutputFileName set]
                        "-D"              [TRUE  @optDefinition set]
                        [
                          0 splittedOption.chars.at "-" = [
                            "Invalid argument: " print option print LF print
                            printInfo
                          ] [
                            option toString @fileNames.pushBack
                          ] if
                        ]
                      ) case
                    ] if
                  ] if
                ] if
              ] if
            ] if
          ] if
        ] if
      ] times
    ] if

    optDefinition optOutputFileName or -2 forceArrayChecks = or optLinkerOption or [
      "Value expected" print LF print
      printInfo
    ] [
      forceArrayChecks (
        0 [FALSE]
        1 [TRUE]
        [options.debug copy]
      ) case @options.@arrayChecks set

      fileNames.getSize 1 = [
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
          fileNames [
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
            fileNames [(.value) addLog] each
            @fileNames move @options.@fileNames set
            @linkerOptions move @options.@linkerOptions set

            processorResult: ProcessorResult;
            multiParserResult options 0 @processorResult process

            processorResult.success [
              outputFileName @processorResult.@program saveString [
                ("program written to " outputFileName) addLog
              ] [
                ("failed to save program" LF) printList
                FALSE @success set
              ] if
            ] [
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
            ] if
          ] when
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
