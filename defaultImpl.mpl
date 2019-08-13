"defaultImpl" module
"control" includeModule

failProcForProcessor: [
  failProc: [stringMemory printAddr " - fail while handling fail" stringMemory printAddr];
  copy message:;
  "ASSERTION FAILED!!!" print LF print
  message print LF print
  "While compiling:" print LF print
  defaultPrintStackTrace

  "Terminating..." print LF print
  2 exit
];

defaultFailProc: [
  text: pop;
];

defaultCall: [
  refToVar: pop;
  compilable [
    var: refToVar getVar;
    var.data.getTag VarCode = [
      VarCode var.data.get.index "call" makeStringView processCall
    ] [
      var.data.getTag VarImport = [
        refToVar processFuncPtr
      ] [
        refToVar isCallable [
          RefToVar refToVar "call" makeStringView callCallableStruct # call struct with INVALID object
        ] [
          "not callable" makeStringView compilerError
        ] if
      ] if
    ] if
  ] when
];

defaultSet: [
  refToDst: pop;
  refToSrc: pop;

  compilable [
    refToSrc makeVarRealCaptured
    refToDst makeVarRealCaptured

    refToDst refToSrc variablesAreSame [
      refToSrc getVar.data.getTag VarImport = [
        "functions cannot be copied" compilerError
      ] [
        refToDst.mutable [
          [refToDst staticnessOfVar Weak = not] "Destination is weak!" assert
          refToSrc refToDst createCopyToExists
        ] [
          "destination is immutable" compilerError
        ] if
      ] if
    ] [
      refToDst.mutable not [
        "destination is immutable" compilerError
      ] [
        lambdaCastResult: refToSrc refToDst tryImplicitLambdaCast;
        lambdaCastResult.success [
          newSrc: lambdaCastResult.refToVar TRUE createRef;
          newSrc refToDst createCopyToExists
        ] [
          ("types mismatch, src is " refToSrc getMplType "," LF "dst is " refToDst getMplType) assembleString compilerError
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
  copy check:;
  refToVar: pop;
  compilable [
    check [refToVar getVar.temporary copy] && [
      "temporary objects cannot be set const" compilerError
    ] [
      FALSE @refToVar.@mutable set
      refToVar push
    ] if
  ] when
];

defaultUseOrIncludeModule: [
  copy asUse:;
  (
    [compilable]
    [currentNode.parent  0 = not ["module can be used only in top node" compilerError] when]
    [refToName: pop;]
    [refToName staticnessOfVar Weak < ["name must be static string" compilerError] when]
    [
      varName: refToName getVar;
      varName.data.getTag VarString = not ["name must be static string" compilerError] when
    ] [
      string: VarString varName.data.get;
      fr: string makeStringView processor.modules.find;
      fr.success [fr.value 0 < not] && [
        frn: fr.value currentNode.usedModulesTable.find;
        frn2: fr.value currentNode.directlyIncludedModulesTable.find;
        frn.success frn2.success or [
          ("duplicate use module: " string) assembleString compilerError
        ] [
          fr.value asUse processUseModule
        ] if
      ] [
        TRUE dynamic @processorResult.@findModuleFail set
        string @processorResult.@errorInfo.@missedModule set
        ("module not found: " string) assembleString compilerError
      ] if
    ]
  ) sequence
];

getStackEntryWith: [
  copy check:;
  copy depth:;

  index: indexOfNode copy;
  result: RefToVar Ref; #ref to 0nx

  [
    node: index @processor.@nodes.at .get;

    node.root [
      check ["stack underflow" compilerError] when
      FALSE
    ] [
      depth node.stack.dataSize < [
        node.stack.dataSize 1 - depth - @node.@stack.at !result
        FALSE
      ] [
        depth node.stack.dataSize - node.buildingMatchingInfo.inputs.dataSize + @depth set
        node.parent @index set
        TRUE
      ] if
    ] if
  ] loop
  @result
];

getStackEntry:          [compileOnce TRUE  static getStackEntryWith];
getStackEntryUnchecked: [            FALSE static getStackEntryWith];

getStackDepth: [
  depth: 0 dynamic;
  inputsCount: 0 dynamic;
  index: indexOfNode copy;
  [
    node: index processor.nodes.at.get;
    node.root not [
      depth node.stack.dataSize + @depth set
      inputsCount node.buildingMatchingInfo.inputs.dataSize + @inputsCount set
      node.parent @index set
      TRUE
    ] &&
  ] loop

  [inputsCount depth > not] "Missed stack overflow!" assert

  depth inputsCount -
];

defaultPrintStack: [
  ("stack:" LF "depth=" getStackDepth LF) printList

  i: 0 dynamic;
  [
    i getStackDepth < [
      entry: i getStackEntryUnchecked;
      (i getStackEntryUnchecked getMplType entry.mutable ["R" makeStringView]["C" makeStringView] if LF) printList
      i 1 + @i set TRUE
    ] &&
  ] loop
];

defaultPrintStackTrace: [
  nodeIndex: indexOfNode copy;
  [
    node: nodeIndex processor.nodes.at.get;
    node.root [
      FALSE
    ] [
      ("at filename: "   node.position.fileNumber processor.options.fileNames.at
        ", token: "      node.position.token
        ", nodeIndex: "  nodeIndex
        ", line: "       node.position.line
        ", column: "     node.position.column LF) printList

      node.parent @nodeIndex set
      TRUE
    ] if
  ] loop

  defaultPrintStack
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
