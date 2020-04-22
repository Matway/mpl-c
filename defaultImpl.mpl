"String.addLog" use
"String.print" use
"String.printList" use
"String.toString" use
"control.&&" use
"control.assert" use
"control.cond" use
"control.exit" use
"control.print" use
"control.printf" use
"control.when" use

"Var.RefToVar" use
"irWriter.createCopyToExists" use

failProcForProcessor: [
  failProc: [print " - fail while handling fail" print];
  print

  trace: getCallTrace;
  [
    trace.first trace.last is [
      FALSE
    ] [
      () "\nin \00" printf
      trace.last.name print
      (trace.last.line copy trace.last.column copy) " at %i:%i\00" printf
      trace.last.prev trace.last addressToReference @trace.!last
      TRUE
    ] if
  ] loop

  "\nWhile compiling:\n" print
  block defaultPrintStackTrace

  2 exit
];

defaultFailProc: [
  text: @block pop;
];

defaultCall: [
  block:;
  refToVar: @block pop;
  compilable [
    var: refToVar getVar;
    var.data.getTag  (
      [VarCode =] [
        VarCode var.data.get.index VarCode var.data.get.file "call" makeStringView processCall
      ]
      [VarImport =] [
        refToVar processFuncPtr
      ]
      [VarString =] [
        (
          [compilable]
          [refToVar staticityOfVar Weak < ["name must be a static string" block compilerError] when]
          [
            nameInfo: VarString var.data.get findNameInfo;
            getNameResult: nameInfo @block File Ref getName;
            nameInfo getNameResult checkFailedName
            captureNameResult: @getNameResult @block captureName;
            refToName: captureNameResult.refToVar copy;
          ]
          [
            captureNameResult.object refToName 0 nameInfo pushName
          ]
        ) sequence
      ]
      [drop refToVar isCallable] [
        RefToVar refToVar "call" makeStringView callCallableStruct # call struct with INVALID object
      ]
      [
        "not callable" block compilerError
      ]
    ) cond
  ] when
];

defaultSet: [
  block:;
  refToDst: @block pop;
  refToSrc: @block pop;
  compilable [
    @refToSrc makeVarRealCaptured
    @refToDst makeVarRealCaptured

    refToDst refToSrc variablesAreSame [
      refToSrc getVar.data.getTag VarImport = [
        "functions cannot be copied" block compilerError
      ] [
        refToSrc getVar.data.getTag VarString = [
          "builtin-strings cannot be copied" block compilerError
        ] [
          refToDst.mutable [
            [refToDst staticityOfVar Weak = ~] "Destination is weak!" assert
            @refToSrc refToDst @block createCopyToExists
          ] [
            "destination is immutable" block compilerError
          ] if
        ] if
      ] if
    ] [
      refToDst.mutable ~ [
        "destination is immutable" block compilerError
      ] [
        lambdaCastResult: refToSrc @refToDst @block tryImplicitLambdaCast;
        lambdaCastResult.success [
          newSrc: @lambdaCastResult.@refToVar TRUE @block createRef;
          @newSrc refToDst @block createCopyToExists
        ] [
          ("types mismatch, src is " refToSrc block getMplType "," LF "dst is " refToDst block getMplType) assembleString block compilerError
        ] if
      ] if
    ] if
  ] when
];

defaultRef: [
  mutable: block:;;
  refToVar: @block pop;
  compilable [
    @refToVar mutable @block createRef @block push
  ] when
];

defaultMakeConstWith: [
  check: block:;;
  refToVar: @block pop;
  compilable [
    check [refToVar getVar.temporary copy] && [
      "temporary objects cannot be set const" block compilerError
    ] [
      FALSE @refToVar.setMutable
      refToVar @block push
    ] if
  ] when
];

defaultUseOrIncludeModule: [
  asUse: block:;;
  (
    [compilable]
    [block.parent 0 = ~ ["module can be used only in top block" block compilerError] when]
    [refToName: @block pop;]
    [refToName staticityOfVar Weak < ["name must be static string" block compilerError] when]
    [
      varName: refToName getVar;
      varName.data.getTag VarString = ~ ["name must be static string" block compilerError] when
    ] [
      string: VarString varName.data.get;
      ("use or include module " string) addLog

      fr: string makeStringView processor.modules.find;
      fr.success [fr.value 0 < ~] && [
        frn: fr.value block.usedModulesTable.find;
        frn2: fr.value block.directlyIncludedModulesTable.find;
        frn.success frn2.success or [
          ("duplicate use module: " string) assembleString block compilerError
        ] [
          fr.value asUse processUseModule
        ] if
      ] [
        TRUE dynamic @processorResult.@findModuleFail set
        string @processorResult.@errorInfo.@missedModule set
        ("module not found: " string) assembleString block compilerError
      ] if
    ]
  ) sequence
];

getStackEntryWith: [
  depth: check: block:;; copy;
  result: RefToVar @block isConst [Cref] [Ref] uif; #ref to 0nx
  currentBlock: @block; [
    currentBlock.root [
      check ["stack underflow" block compilerError] when
      FALSE
    ] [
      depth currentBlock.stack.dataSize < [
        currentBlock.stack.dataSize 1 - depth - @currentBlock.@stack.at !result
        FALSE
      ] [
        depth currentBlock.stack.dataSize - currentBlock.buildingMatchingInfo.inputs.dataSize + @depth set
        currentBlock.parent @processor.@blocks.at.get !currentBlock
        TRUE
      ] if
    ] if
  ] loop

  @result
];

getStackEntry:          [depth: block:;; depth TRUE  @block getStackEntryWith];
getStackEntryUnchecked: [depth: block:;; depth FALSE block  getStackEntryWith];

getStackDepth: [
  block:;
  depth: 0 dynamic;
  inputsCount: 0 dynamic;
  [
    block.root ~ [
      depth block.stack.dataSize + @depth set
      inputsCount block.buildingMatchingInfo.inputs.dataSize + @inputsCount set
      block.parent processor.blocks.at.get !block
      TRUE
    ] &&
  ] loop

  [inputsCount depth > ~] "Missed stack overflow!" assert

  depth inputsCount -
];

defaultPrintStack: [
  block:;
  ("stack:" LF "depth=" block getStackDepth LF) printList

  i: 0 dynamic;
  [
    i block getStackDepth < [
      entry: i block getStackEntryUnchecked;
      (entry block getMplType entry.mutable ["R"] ["C"] if entry getVar.temporary ["T"] [""] if LF) printList
      i 1 + @i set TRUE
    ] &&
  ] loop
];

defaultPrintStackTrace: [
  block:;
  currentBlock: block;
  [
    currentBlock.root [
      FALSE
    ] [
      (
        "at filename: " currentBlock.position.file.name
        ", token: "     currentBlock.position.token
        ", line: "      currentBlock.position.line
        ", column: "    currentBlock.position.column LF
      ) printList

      currentBlock.parent processor.blocks.at.get !currentBlock
      TRUE
    ] if
  ] loop

  block defaultPrintStack
];

findNameInfo: [
  key:;
  fr: @key @processor.@nameToId.find;
  fr.success [
    fr.value copy
  ] [
    string: key toString;
    result: processor.nameToId.getSize;
    [result processor.nameInfos.dataSize =] "Name info data sizes inconsistent!" assert
    string result @processor.@nameToId.insert

    newNameInfo: NameInfo;
    string @newNameInfo.@name set
    newNameInfo @processor.@nameInfos.pushBack

    result
  ] if
];
