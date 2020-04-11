"control" includeModule

failProcForProcessor: [
  failProc: [stringMemory printAddr " - fail while handling fail" stringMemory printAddr];
  message:;
  "ASSERTION FAILED!!!" print LF print
  message print LF print
  "While compiling:" print LF print
  currentNode defaultPrintStackTrace

  "Terminating..." print LF print
  2 exit
];

defaultFailProc: [
  text: pop;
];

defaultCall: [
  block:;
  refToVar: pop;
  compilable [
    var: refToVar getVar;
    var.data.getTag  (
      [VarCode =] [
        VarCode var.data.get.index "call" makeStringView processCall
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
            getNameResult: nameInfo getName;
            nameInfo getNameResult checkFailedName
            captureNameResult: getNameResult captureName;
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
  refToDst: pop;
  refToSrc: pop;
  compilable [
    refToSrc makeVarRealCaptured
    refToDst makeVarRealCaptured

    refToDst refToSrc variablesAreSame [
      refToSrc getVar.data.getTag VarImport = [
        "functions cannot be copied" block compilerError
      ] [
        refToSrc getVar.data.getTag VarString = [
          "builtin-strings cannot be copied" block compilerError
        ] [
          refToDst.mutable [
            [refToDst staticityOfVar Weak = not] "Destination is weak!" assert
            refToSrc refToDst @block createCopyToExists
          ] [
            "destination is immutable" block compilerError
          ] if
        ] if
      ] if
    ] [
      refToDst.mutable not [
        "destination is immutable" block compilerError
      ] [
        lambdaCastResult: refToSrc refToDst tryImplicitLambdaCast;
        lambdaCastResult.success [
          newSrc: lambdaCastResult.refToVar TRUE createRef;
          newSrc refToDst @block createCopyToExists
        ] [
          ("types mismatch, src is " refToSrc getMplType "," LF "dst is " refToDst getMplType) assembleString block compilerError
        ] if
      ] if
    ] if
  ] when
];

defaultRef: [
  copy mutable:;
  refToVar: pop;
  compilable [
    refToVar mutable createRef push
  ] when
];

defaultMakeConstWith: [
  check: block:;;
  refToVar: pop;
  compilable [
    check [refToVar getVar.temporary copy] && [
      "temporary objects cannot be set const" block compilerError
    ] [
      FALSE @refToVar.@mutable set
      refToVar push
    ] if
  ] when
];

defaultUseOrIncludeModule: [
  asUse: block:;;
  (
    [compilable]
    [block.parent 0 = not ["module can be used only in top block" block compilerError] when]
    [refToName: pop;]
    [refToName staticityOfVar Weak < ["name must be static string" block compilerError] when]
    [
      varName: refToName getVar;
      varName.data.getTag VarString = not ["name must be static string" block compilerError] when
    ] [
      string: VarString varName.data.get;
      ("use or include module " string) addLog

      fr: string makeStringView processor.modules.find;
      fr.success [fr.value 0 < not] && [
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
  [
    block.root [
      check ["stack underflow" block compilerError] when
      FALSE
    ] [
      depth block.stack.dataSize < [
        block.stack.dataSize 1 - depth - @block.@stack.at !result
        FALSE
      ] [
        depth block.stack.dataSize - block.buildingMatchingInfo.inputs.dataSize + @depth set
        block.parent @processor.@blocks.at.get !block
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
    block.root not [
      depth block.stack.dataSize + @depth set
      inputsCount block.buildingMatchingInfo.inputs.dataSize + @inputsCount set
      block.parent processor.blocks.at.get !block
      TRUE
    ] &&
  ] loop

  [inputsCount depth > not] "Missed stack overflow!" assert

  depth inputsCount -
];

defaultPrintStack: [
  block:;
  ("stack:" LF "depth=" block getStackDepth LF) printList

  i: 0 dynamic;
  [
    i block getStackDepth < [
      entry: i block getStackEntryUnchecked;
      (entry getMplType entry.mutable ["R"] ["C"] if entry getVar.temporary ["T"] [""] if LF) printList
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
      ("at filename: "   currentBlock.position.fileNumber processor.options.fileNames.at
        ", token: "      currentBlock.position.token
        ", line: "       currentBlock.position.line
        ", column: "     currentBlock.position.column LF) printList

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
