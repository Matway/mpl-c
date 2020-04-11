"control" useModule
"codeNode" includeModule

clearProcessorResult: [
  copy cachedGlobalErrorInfoSize:;
  TRUE dynamic              @processorResult.@success set
  FALSE dynamic             @processorResult.@findModuleFail set
  FALSE dynamic             @processorResult.@passErrorThroughPRE set
  String                    @processorResult.@program set
  ProcessorErrorInfo        @processorResult.@errorInfo set
  cachedGlobalErrorInfoSize 0 < not [
    cachedGlobalErrorInfoSize @processorResult.@globalErrorInfo.shrink
  ] when
];

variablesHaveSameGlobality: [
  cacheEntry:;
  stackEntry:;

  cacheEntry isGlobal [
    stackEntry isGlobal [
      cacheEntry getVar.globalId
      stackEntry getVar.globalId =
    ] &&
  ] [
    stackEntry isGlobal not
  ] if
];

variablesAreEqualWith: [
  copy checkRefs:;
  copy stackDynamicBorder:;
  cacheEntry:;
  stackEntry:;

  cacheEntry stackEntry variablesAreSame [cacheEntry stackEntry variablesHaveSameGlobality] && [
    cacheEntryVar: cacheEntry getVar;
    stackEntryVar: stackEntry getVar;

    stackEntryVar.data.getTag VarStruct = [
      cacheStruct: VarStruct cacheEntryVar.data.get.get;
      stackStruct: VarStruct stackEntryVar.data.get.get;
      cacheStruct.hasDestructor not [cacheStruct.forgotten stackStruct.forgotten =] ||
    ] [
      cacheStaticity: cacheEntry staticityOfVar;
      stackStaticity: stackEntry staticityOfVar;

      cacheStaticity Weak > not stackStaticity stackDynamicBorder > not and [ # both dynamic
        cacheStaticity Weak > stackStaticity stackDynamicBorder > and [ # both static
          cacheEntry isSemiplainNonrecursiveType [
            result: TRUE;
            cacheEntryVar.data.getTag VarCond VarImport 1 + [
              copy tag:;
              tag cacheEntryVar.data.get
              tag stackEntryVar.data.get =
              @result set
            ] staticCall
            result
          ] [
            cacheEntryVar.data.getTag VarBuiltin = cacheEntryVar.data.getTag VarImport = or [
              [FALSE] "Impossible to create var with builtin or import!" assert
              FALSE
            ] [
              cacheEntryVar.data.getTag VarString = [
                VarString cacheEntryVar.data.get
                VarString stackEntryVar.data.get =
              ] [
                checkRefs [cacheEntryVar.data.getTag VarRef =] && [cacheEntry staticityOfVar Virtual <] && [
                  r1: VarRef cacheEntryVar.data.get;
                  r2: VarRef stackEntryVar.data.get;
                  r1.hostId r2.hostId = [r1.varId r2.varId =] && [r1.mutable r2.mutable =] && [r1 staticityOfVar r2 staticityOfVar =] &&
                ] [
                  TRUE # go recursive
                ] if
              ] if
            ] if
          ] if
        ] && # both static and are equal
      ] || # both dynamic
    ] if
  ] &&
];

variablesAreEqualForMatching: [
  Weak FALSE dynamic variablesAreEqualWith
];

variablesAreEqual: [
  Dynamic TRUE dynamic variablesAreEqualWith
];

variableIsUnused: [
  refToVar:;
  refToVar.hostId currentMatchingNodeIndex = not [refToVar noMatterToCopy not] &&
];

compareOnePair: [
  copy first:;
  cacheEntry:;
  stackEntry:;

  fr1: cacheEntry @nestedToCur.find;
  fr1.success [
    fr1.value stackEntry refsAreEqual [TRUE] [
      currentMatchingNode.nodeCompileOnce ["; aliasing mismatch" @comparingMessage.cat] when
      FALSE
    ] if
  ] [
    fr2: stackEntry @curToNested.find;
    fr2.success [
      fr2.value cacheEntry refsAreEqual [TRUE] [
        currentMatchingNode.nodeCompileOnce ["; aliasing mismatch" @comparingMessage.cat] when
        FALSE
      ] if
    ] [
      cacheEntry.mutable stackEntry.mutable = [
        stackEntry cacheEntry variablesAreEqualForMatching [TRUE] [
          currentMatchingNode.nodeCompileOnce ["; static values mismatch" @comparingMessage.cat] when
          FALSE
        ] if
      ] && [
        cacheEntry noMatterToCopy not [
          cacheEntry stackEntry @nestedToCur.insert
          stackEntry cacheEntry @curToNested.insert
        ] when

        TRUE
      ] &&
    ] if
  ] if

];

{
  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  currentNode: Block Ref;
  multiParserResult: MultiParserResult Cref;

  comparingMessage: String Ref;
  curToNested: RefToVarTable Ref;
  nestedToCur: RefToVarTable Ref;
  currentMatchingNodeIndex: Int32;
  cacheEntry: RefToVar Cref;
  stackEntry: RefToVar Cref;
} Cond {convention: cdecl;} [
  processorResult:;
  processor:;
  currentNode:;
  multiParserResult:;
  failProc: @failProcForProcessor;

  comparingMessage:;
  curToNested:;
  nestedToCur:;
  currentMatchingNodeIndex:;
  cacheEntry:;
  stackEntry:;

  currentMatchingNode: currentMatchingNodeIndex processor.blocks.at.get;

  makeWayInfo: [{
    copy currentName:;
    copy current:;
    copy prev:;
  }];

  WayInfo: [
    -1 dynamic -1 dynamic StringView makeWayInfo
  ];

  unfinishedStack: RefToVar Array;
  unfinishedCache: RefToVar Array;
  unfinishedWay: WayInfo Array;

  cacheEntry @unfinishedCache.pushBack
  stackEntry @unfinishedStack.pushBack
  WayInfo @unfinishedWay.pushBack

  success: TRUE;
  first: TRUE;

  i: 0 dynamic;
  [
    i unfinishedCache.dataSize < [
      currentFromCache: i unfinishedCache.at copy;
      currentFromStack: i unfinishedStack.at copy;
      currentWay: i unfinishedWay.at copy;

      currentFromCache variableIsUnused [
        i 1 + @i set
      ] [
        currentFromStack currentFromCache first compareOnePair [ # compare current stack value with initial value of argument
          cacheEntryVar: currentFromCache getVar;
          stackEntryVar: currentFromStack getVar;
          cacheEntryVar.data.getTag VarRef = [currentFromCache staticityOfVar Virtual <] && [currentFromCache staticityOfVar Weak >] && [
            currentFromStack getPointeeForMatching @unfinishedStack.pushBack
            currentFromCache getPointeeForMatching @unfinishedCache.pushBack
            i -1 "deref" makeStringView makeWayInfo @unfinishedWay.pushBack
          ] [
            cacheEntryVar.data.getTag VarStruct = [
              cacheStruct: VarStruct cacheEntryVar.data.get.get;
              stackStruct: VarStruct stackEntryVar.data.get.get;

              cacheStruct.fields.dataSize stackStruct.fields.dataSize = not [
                FALSE dynamic @success set
              ] [
                j: 0 dynamic;
                [
                  j cacheStruct.fields.dataSize < [
                    cacheField: j cacheStruct.fields.at copy;
                    stackField: j stackStruct.fields.at copy;
                    cacheField.nameInfo stackField.nameInfo = [
                      j currentFromCache getFieldForMatching @unfinishedCache.pushBack
                      j currentFromStack getFieldForMatching @unfinishedStack.pushBack
                      i j cacheField.nameInfo processor.nameInfos.at.name makeStringView makeWayInfo @unfinishedWay.pushBack
                      j 1 + @j set
                    ] [
                      FALSE dynamic @success set
                    ] if
                    success copy
                  ] &&
                ] loop
              ] if
            ] [
              # just continue
            ] if
          ] if

          i 1 + @i set
        ] [
          "; way to field: " @comparingMessage.cat
          w: i copy;
          [
            w 0 < not [
              curWay:  w unfinishedWay.at;
              curWay.prev unfinishedWay.dataSize < [
                (curWay.current ": " @curWay.@currentName ", " ) @comparingMessage.catMany
                curWay.prev @w set TRUE
              ] &&
            ] &&
          ] loop
          FALSE dynamic @success set
        ] if
      ] if

      success copy
    ] &&
  ] loop

  success
] "compareEntriesRecImpl" exportFunction

getOverload: [
  cap:;
  overload: cap.nameOverload copy;
  maxOverloadCountCur: cap.nameInfo getOverloadCount;
  maxOverloadCountNes: cap.cntNameOverloadParent copy;
  overload maxOverloadCountCur + maxOverloadCountNes < [
    ("while matching cant call overload for name: " cap.nameInfo processor.nameInfos.at.name) assembleString currentNode compilerError
    0
  ] [
    overload maxOverloadCountCur + maxOverloadCountNes -
  ] if
];

tryMatchNode: [
  currentMatchingNode:;

  curToNested: RefToVarTable;
  nestedToCur: RefToVarTable;
  comparingMessage: String;

  canMatch: currentMatchingNode.deleted not [
    currentMatchingNode.state NodeStateCompiled =
    currentMatchingNode.state NodeStateFailed = or [
      #recursive condition
      currentMatchingNode.nodeIsRecursive
      [currentMatchingNode.recursionState NodeRecursionStateFail = not] &&
      [
        currentMatchingNode.state NodeStateNew =
        [currentMatchingNode.state NodeStateHasOutput = [currentMatchingNode.recursionState NodeRecursionStateOld =] &&] ||
        [forceRealFunction copy] ||
      ] &&
    ] ||
    [currentNode getStackDepth currentMatchingNode.matchingInfo.inputs.dataSize currentMatchingNode.matchingInfo.preInputs.dataSize + < not] &&
    [currentMatchingNode.matchingInfo.hasStackUnderflow not
      [currentNode getStackDepth currentMatchingNode.matchingInfo.inputs.dataSize currentMatchingNode.matchingInfo.preInputs.dataSize + > not] ||
    ] &&
  ] &&;

  # matching node has 0 inputs and underflow, current node has 0 inputs - TRUE
  # matching node has 0 inputs and underflow, current node has 1 inputs - FALSE
  # matching node has 0 inputs, current node has 0 inputs - TRUE
  # matching node has 0 inputs, current node has 1 inputs - TRUE

  goodReality:
  forceRealFunction not [
    currentMatchingNode.nodeCase NodeCaseDeclaration =
    [currentMatchingNode.nodeCase NodeCaseCodeRefDeclaration =] ||
    [currentMatchingNode.nodeCase NodeCaseExport =] ||
    [currentMatchingNode.nodeCase NodeCaseLambda =] ||
  ] ||;

  invisibleName: currentMatchingNode.nodeCase NodeCaseLambda = [currentMatchingNode.varNameInfo 0 < not] && [
    matchingCapture: Capture;
    currentMatchingNode.refToVar @matchingCapture.@refToVar set
    NameCaseLocal                @matchingCapture.@captureCase set
    gnr: currentMatchingNode.varNameInfo matchingCapture getNameForMatching;
    gnr.refToVar.hostId 0 <
  ] &&;

  canMatch invisibleName not and goodReality and [
    mismatchMessage: [
      idadd:;
      msg: makeStringView;
      [
        s: String;
        @msg                        @s.cat
        @idadd call
        " mismatch" makeStringView  @s.cat
        stackEntry.hostId 0 < [
          ", stack entry not found" @s.cat
        ] [
          stackEntry cacheEntry variablesAreSame not [
            (", stack type is " stackEntry currentNode getMplType ", cache type is " cacheEntry currentNode getMplType) @s.catMany
          ] [
            stackEntry.mutable cacheEntry.mutable = not [
              stackEntry.mutable [", stack is mutable" makeStringView] [", stack is immutable" makeStringView] if @s.cat
              cacheEntry.mutable [", cache is mutable" makeStringView] [", cache is immutable" makeStringView] if @s.cat
            ] [
              comparingMessage @s.cat
            ] if
          ] if
        ] if

        (s) addLog
        s currentNode compilerError
      ] call
    ];

    success: TRUE;
    i: 0 dynamic;
    [
      i currentMatchingNode.matchingInfo.inputs.getSize < [
        stackEntry: i currentNode getStackEntry;
        cacheEntry: i currentMatchingNode.matchingInfo.inputs.at.refToVar;

        stackEntry cacheEntry compareEntriesRec [
          i 1 + @i set
        ] [
          currentMatchingNode.nodeCompileOnce [
            "in compiled-once func input " [i 1 + @s.cat] mismatchMessage
          ] when

          FALSE dynamic @success set
        ] if

        success compilable and
      ] &&
    ] loop

    # calling of pre does not have effect in inputs, but can be used in matching
    success compilable and [
      i: 0 dynamic;
      [
        i currentMatchingNode.matchingInfo.preInputs.dataSize < [
          stackEntry: i currentMatchingNode.matchingInfo.inputs.dataSize + currentNode getStackEntry copy;
          cacheEntry: i currentMatchingNode.matchingInfo.preInputs.at;

          cacheEntry.hostId 0 < not [stackEntry cacheEntry compareEntriesRec] && [
            i 1 + @i set
          ] [
            currentMatchingNode.nodeCompileOnce [
              "in compiled-once func preinput " makeStringView [i 1 + @s.cat] mismatchMessage
            ] when

            FALSE dynamic @success set
          ] if

          success compilable and
        ] &&
      ] loop
    ] when

    success compilable and [
      i: 0 dynamic;
      [
        i currentMatchingNode.matchingInfo.captures.dataSize < [
          currentCapture: i currentMatchingNode.matchingInfo.captures.at;
          cacheEntry: currentCapture.refToVar;
          overload: currentCapture.refToVar.hostId 0 < [-1][currentCapture getOverload] if;
          stackEntry: currentCapture.nameInfo currentCapture overload getNameForMatchingWithOverload.refToVar;

          stackEntry.hostId 0 < cacheEntry.hostId 0 < and [
            stackEntry.hostId 0 < not cacheEntry.hostId 0 < not and [stackEntry cacheEntry compareEntriesRec] &&
          ] || [
            i 1 + @i set
          ] [
            currentMatchingNode.nodeCompileOnce [
              "in compiled-once func capture " makeStringView [currentCapture.nameInfo processor.nameInfos.at.name @s.cat] mismatchMessage
            ] when

            FALSE dynamic @success set
          ] if

          success compilable and
        ] &&
      ] loop
    ] when

    success compilable and [
      i: 0 dynamic;
      [
        i currentMatchingNode.matchingInfo.fieldCaptures.dataSize < [
          currentFieldCapture: i currentMatchingNode.matchingInfo.fieldCaptures.at;
          overload: currentFieldCapture getOverload;
          compilable [
            currentFieldInfo: overload currentFieldCapture.nameInfo processor.nameInfos.at.stack.at.last;
            currentFieldInfo.nameCase currentFieldCapture.captureCase = [currentFieldCapture.object currentFieldInfo.refToVar variablesAreSame] &&
          ] && [
            i 1 + @i set
          ] [
            currentMatchingNode.nodeCompileOnce [
              ("in compiled-once func fieldCapture " currentFieldCapture.nameInfo processor.nameInfos.at.name "\" mismatch") assembleString currentNode compilerError
            ] when

            FALSE dynamic @success set
          ] if

          success compilable and
        ] &&
      ] loop
    ] when

    success
  ] &&
];

{processorResult: ProcessorResult Ref; processor: Processor Ref; currentNode: Block Ref; multiParserResult: MultiParserResult Cref; forceRealFunction: Cond; indexArrayOfSubNode: IndexArray Cref;} Int32 {convention: cdecl;} [
  processorResult:;
  processor:;
  currentNode:;
  multiParserResult:;
  failProc: @failProcForProcessor;

  forceRealFunction:;
  indexArrayOfSubNode:;

  compileOnce
  indexArrayAddr: indexArrayOfSubNode storageAddress;
  fr: indexArrayAddr @processor.@matchingNodes.find;
  fr.success [
    fr.value.entries 1 + @fr.@value.@entries set

    findInIndexArray: [
      where:;

      result: -1 dynamic;
      i: 0 dynamic;
      [
        i where.dataSize < [
          fr.value.tries 1 + @fr.@value.@tries set
          currentMatchingNodeIndex: i where.at;
          currentMatchingNode: currentMatchingNodeIndex processor.blocks.at.get;

          currentMatchingNode tryMatchNode [
            currentMatchingNodeIndex @result set
            currentMatchingNode.uncompilable ["nested node error" currentNode compilerError] when

            FALSE
          ] [
            i 1 + @i set compilable
          ] if
        ] &&
      ] loop

      result
    ];

    result: -1 dynamic;

    currentNode getStackDepth 0 > [
      byType: 0 currentNode getStackEntry getVar.mplSchemaId fr.value.byMplType.find;

      byType.success [
        byType.value findInIndexArray @result set
      ] when
    ] when

    result 0 < [
      fr.value.unknownMplType findInIndexArray @result set
    ] when

    result
  ] [
    -1 dynamic
  ] if

] "tryMatchAllNodesWith" exportFunction

tryMatchAllNodes: [
  FALSE multiParserResult @currentNode @processor @processorResult tryMatchAllNodesWith
];

tryMatchAllNodesForRealFunction: [
  TRUE multiParserResult @currentNode @processor @processorResult tryMatchAllNodesWith
];

fixRecursionStack: [
  i: currentNode.id copy;
  [
    processor.recursiveNodesStack.getSize 0 > [i newNodeIndex = not] && [
      current: i @processor.@blocks.at.get;
      i processor.recursiveNodesStack.last = [
        NodeRecursionStateNo @current.@recursionState set
        @processor.@recursiveNodesStack.popBack
      ] when

      current.parent @i set
      [i 0 = not] "NewNodeIndex is not a parent of currentNode.id while fixRecursionStack!" assert
      TRUE
    ] &&
  ] loop
];

changeNewNodeState: [
  copy newNodeIndex:;
  newNode: newNodeIndex @processor.@blocks.at.get;
  newNode.state NodeStateNew = [
    [newNode.nodeIsRecursive copy] "new node must be recursive!" assert
    fixRecursionStack
    NodeRecursionStateNew @newNode.@recursionState set

    processor.recursiveNodesStack.getSize 0 = [processor.recursiveNodesStack.last newNodeIndex = not] || [
      newNodeIndex @processor.@recursiveNodesStack.pushBack
    ] when

    NodeStateNoOutput @currentNode.@state set
  ] [
    newNode.state NodeStateNoOutput = [
      NodeStateNoOutput @currentNode.@state set
    ] [
      newNode.recursionState NodeRecursionStateNo > [
        [newNode.nodeIsRecursive copy] "new node must be recursive!" assert
        fixRecursionStack
      ] when

      newNode.recursionState NodeRecursionStateFail > [newNode.state NodeStateHasOutput =] || [NodeStateHasOutput @currentNode.@state set] when
    ] if
  ] if
];

changeNewExportNodeState: [
  copy newNodeIndex:;
  newNode: newNodeIndex @processor.@blocks.at.get;
  newNode.state NodeStateNew = [
    [newNode.nodeIsRecursive copy] "new node must be recursive!" assert
    fixRecursionStack
    NodeRecursionStateNew @newNode.@recursionState set

    processor.recursiveNodesStack.getSize 0 = [processor.recursiveNodesStack.last newNodeIndex = not] || [
      newNodeIndex @processor.@recursiveNodesStack.pushBack
    ] when

    NodeStateHasOutput @currentNode.@state set
  ] [
    newNode.state NodeStateNoOutput = [
      NodeStateHasOutput @currentNode.@state set
    ] [
      newNode.recursionState NodeRecursionStateNo > [
        [newNode.nodeIsRecursive copy] "new node must be recursive!" assert
        fixRecursionStack
      ] when

      newNode.recursionState NodeRecursionStateFail > [newNode.state NodeStateHasOutput =] || [NodeStateHasOutput @currentNode.@state set] when
    ] if
  ] if
];

fixRef: [
  copy refToVar:;

  var: refToVar getVar;
  wasVirtual: refToVar isVirtual;
  makeDynamic: FALSE dynamic;
  pointee: VarRef @var.@data.get;
  pointeeVar: pointee getVar;
  pointeeIsLocal: pointeeVar.capturedHead.hostId currentChangesNodeIndex =;

  fixed: pointee copy;
  pointeeIsLocal not [ # has shadow - captured from top
    fr: pointeeVar.shadowBegin appliedVars.nestedToCur.find;
    fr.success [
      fr.value @fixed set
    ] [
      # dont have prototype - deref of captured dynamic pointer
      pointee copyVarFromChild @fixed set
      TRUE dynamic @makeDynamic set
    ] if
  ] [
    # dont have shadow - to deref of captured dynamic pointer
    # must by dynamic
    var.staticity Static = [pointeeVar.storageStaticity Static =] && ["returning pointer to local variable" currentNode compilerError] when
    pointee copyVarFromChild @fixed set
    TRUE dynamic @makeDynamic set
  ] if

  fixed.hostId @pointee.@hostId set
  fixed.varId  @pointee.@varId  set

  wasVirtual [refToVar Virtual makeStaticity @refToVar set] [
    makeDynamic [
      refToVar Dynamic makeStaticity @refToVar set
    ] when
  ] if
  refToVar
];

applyOnePair: [
  cacheEntry:;
  stackEntry:;

  [
    cacheEntry stackEntry variablesAreSame [TRUE] [
      ("cache type is " makeStringView cacheEntry getMplType "; stack entry is " makeStringView stackEntry getMplType) addLog
      FALSE
    ] if
  ] "Applying var has wrong type!" assert
  [cacheEntry noMatterToCopy [cacheEntry.hostId currentChangesNodeIndex =] ||] "Applying unused var!" assert

  cacheEntryVar: cacheEntry getVar;
  stackEntryVar: stackEntry getVar;

  stackEntry cacheEntry staticityOfVar makeStaticity drop:;

  cacheEntry noMatterToCopy not [cacheEntryVar.shadowEnd getVar.capturedAsMutable copy] && [
    TRUE @stackEntryVar.@capturedAsMutable set
  ] when

  cacheEntry isNonrecursiveType [
    fr: stackEntry @appliedVars.@curToNested.find;
    fr.success [
      fr.value cacheEntry getVar.shadowEnd variablesAreEqual not [
        "variable changes to incompatible values by two different ways" currentNode compilerError
      ] when
    ] [
      [
        cacheEntry stackEntry variablesAreEqualForMatching [
          TRUE
        ] [
          ("match fail, type=" makeStringView cacheEntry getMplType makeStringView
            "; st=" makeStringView cacheEntry staticityOfVar stackEntry staticityOfVar) addLog
          FALSE
        ] if
      ] "Applying var has wrong value!" assert
      cacheEntry noMatterToCopy not [
        [cacheEntryVar.shadowEnd.hostId 0 < not] "Cache entry has no shadow end!" assert
        stackEntry cacheEntryVar.shadowEnd @appliedVars.@curToNested.insert
        cacheEntry stackEntry @appliedVars.@nestedToCur.insert
      ] when
    ] if
  ] [
    cacheEntryVar.data.getTag VarRef = [
      fr: stackEntry @appliedVars.@curToNested.find;
      fr.success [
        fr.value cacheEntry getVar.shadowEnd variablesAreEqual not [
          "ref variable changes to incompatible values by two different ways" currentNode compilerError
        ] when
      ] [
        cacheEntry noMatterToCopy not [
          [cacheEntryVar.shadowEnd.hostId 0 < not] "Cache entry has no shadow end!" assert
          stackEntry cacheEntryVar.shadowEnd @appliedVars.@curToNested.insert
          cacheEntry stackEntry @appliedVars.@nestedToCur.insert
        ] when
      ] if
    ] [
      # it may be struct, need add to table anyway for fixing
      cacheEntry noMatterToCopy not [
        fr: cacheEntry @appliedVars.@nestedToCur.find;
        fr.success [
          [fr.value stackEntry refsAreEqual] "CacheEntry is already in table with another stackEntry!" assert
        ] [
          cacheEntry stackEntry @appliedVars.@nestedToCur.insert
        ] if
      ] when
    ] if
  ] if
];

applyEntriesRec: [
  cacheEntry:;
  stackEntry:;

  unfinishedStack: RefToVar Array;
  unfinishedCache: RefToVar Array;

  cacheEntry @unfinishedCache.pushBack
  stackEntry @unfinishedStack.pushBack

  i: 0 dynamic;
  [
    i unfinishedCache.dataSize < [
      currentFromCache: i unfinishedCache.at copy;
      currentFromStack: i unfinishedStack.at copy;

      currentFromStack currentFromCache applyOnePair

      cacheEntryVar: currentFromCache getVar;
      stackEntryVar: currentFromStack getVar;

      cacheEntryVar.capturedAsRealValue [currentFromStack makeVarRealCaptured] when

      cacheEntryVar.data.getTag VarRef = [currentFromCache staticityOfVar Virtual <] && [currentFromCache staticityOfVar Dynamic >] && [
        clearPointee: VarRef cacheEntryVar.data.get copy; # if captured, host index will be currentChangesNodeIndex
        clearPointee.hostId currentChangesNodeIndex = [ # we captured it
          clearPointee @unfinishedCache.pushBack
          currentFromStack getPointeeNoDerefIR @unfinishedStack.pushBack
        ] when
      ] [
        cacheEntryVar.data.getTag VarStruct = [
          cacheStruct: VarStruct cacheEntryVar.data.get.get;

          j: 0 dynamic;
          [
            j cacheStruct.fields.dataSize < [
              cacheFieldRef: j currentFromCache getFieldForMatching;
              cacheFieldRef.hostId currentChangesNodeIndex = [ # we captured it
                cacheFieldRef @unfinishedCache.pushBack
                j currentFromStack getField @unfinishedStack.pushBack
              ] when
              j 1 + @j set TRUE
            ] &&
          ] loop
        ] when
      ] if

      i 1 + @i set compilable
    ] &&
  ] loop
];

fixOutputRefsRec: [
  stackEntry:;

  unfinishedStack: RefToVar Array;
  stackEntry @unfinishedStack.pushBack

  i: 0 dynamic;
  [
    i unfinishedStack.dataSize < [
      currentFromStack: i @unfinishedStack.at copy;
      stackEntryVar: currentFromStack getVar;

      stackEntryVar.data.getTag VarRef = [
        currentFromStack isSchema not [
          stackPointee: VarRef @stackEntryVar.@data.get;
          stackPointee.hostId currentChangesNodeIndex = [
            fixed: currentFromStack fixRef getPointeeNoDerefIR;
            fixed @unfinishedStack.pushBack
          ] when
        ] when
      ] [
        stackEntryVar.data.getTag VarStruct = [
          stackStruct: VarStruct stackEntryVar.data.get.get;
          j: 0 dynamic;
          [
            j stackStruct.fields.dataSize < [
              stackField: j stackStruct.fields.at.refToVar;
              stackField @unfinishedStack.pushBack
              j 1 + @j set TRUE
            ] &&
          ] loop
        ] when
      ] if

      i 1 + @i set compilable
    ] &&
  ] loop
];

fixCaptureRef: [
  refToVar:;
  result: refToVar fixRef;
  fixed: result copy;

  [
    continue: FALSE;
    var: fixed getVar;

    curPointee: VarRef var.data.get;
    curPointeeVar: curPointee getVar;

    curPointeeVar.data.getTag VarRef = [
      fr: curPointee @appliedVars.@curToNested.find;
      fr.success not [
        curPointee fixRef @fixed set
        TRUE dynamic @continue set
        # we need deep recursion for captures, becouse if we has dynamic fix to, we will has unfixed pointee
        # need to fix!!!
      ] when
    ] when

    continue
  ] loop

  result
];

usePreCapturesWith: [
  compileOnce
  copy exitPre:;
  currentChangesNodeIndex:;
  currentChangesNodeIndex 0 < not [
    currentChangesNode: currentChangesNodeIndex processor.blocks.at.get;

    oldSuccess: @processorResult move copy;
    -1 clearProcessorResult

    i: 0 dynamic;
    [
      i currentChangesNode.matchingInfo.captures.dataSize < [
        currentCapture: i currentChangesNode.matchingInfo.captures.at;
        cacheEntry: currentCapture.refToVar;
        overload: currentCapture.refToVar.hostId 0 < [-1] [currentCapture getOverload] if;
        gnr: currentCapture.nameInfo currentCapture overload getNameForMatchingWithOverload;
        gnr.refToVar.hostId 0 < [
          # it is failed capture
        ] [
          stackEntry: gnr captureName.refToVar;

          unfinishedStack: RefToVar Array;
          unfinishedCache: RefToVar Array;
          cacheEntry @unfinishedCache.pushBack
          stackEntry @unfinishedStack.pushBack
          i2: 0 dynamic;
          [
            i2 unfinishedCache.getSize < [
              currentFromCache: i2 unfinishedCache.at copy;
              currentFromStack: i2 unfinishedStack.at copy;
              cacheEntryVar: currentFromCache getVar;
              stackEntryVar: currentFromStack getVar;

              cacheEntryVar.data.getTag VarRef = [currentFromCache staticityOfVar Virtual <] && [currentFromCache staticityOfVar Dynamic >] && [
                clearPointee: VarRef cacheEntryVar.data.get copy; # if captured, host index will be currentChangesNodeIndex
                clearPointee.hostId currentChangesNodeIndex = [ # we captured it
                  clearPointee                         @unfinishedCache.pushBack
                  currentFromStack getPointeeNoDerefIR @unfinishedStack.pushBack
                ] when
              ] [
                cacheEntryVar.data.getTag VarStruct = [
                  cacheStruct: VarStruct cacheEntryVar.data.get.get;

                  j: 0 dynamic;
                  [
                    j cacheStruct.fields.dataSize < [
                      cacheFieldRef: j currentFromCache getFieldForMatching;
                      cacheFieldRef.hostId currentChangesNodeIndex = [ # we captured it
                        cacheFieldRef @unfinishedCache.pushBack
                        j currentFromStack getField @unfinishedStack.pushBack
                      ] when
                      j 1 + @j set compilable
                    ] &&
                  ] loop
                ] when
              ] if

              i2 1 + @i2 set compilable
            ] &&
          ] loop
        ] if

        i 1 + @i set compilable
      ] &&
    ] loop

    i: 0 dynamic;
    [
      i currentChangesNode.matchingInfo.fieldCaptures.dataSize < [
        currentFieldCapture: i currentChangesNode.matchingInfo.fieldCaptures.at;
        fieldName: currentFieldCapture.nameInfo copy;
        overload: currentFieldCapture getOverload;
        fieldCnr: currentFieldCapture.nameInfo overload getNameWithOverload captureName;
        i 1 + @i set compilable
      ] &&
    ] loop

    exitPre not [
      currentChangesNode.matchingInfo.unfoundedNames [
        .key addUnfoundedName
      ] each
    ] when

    @oldSuccess move @processorResult set
  ] when
];

usePreCaptures: [FALSE dynamic usePreCapturesWith];

addFailedCapture: [
  nameInfo:;
  newCapture: Capture;
  nameInfo @newCapture.@nameInfo set
  newCapture @currentNode.@matchingInfo.@captures.pushBack
  currentNode.state NodeStateNew = [
    newCapture @currentNode.@buildingMatchingInfo.@captures.pushBack
  ] when
];

applyNodeChanges: [
  compileOnce
  copy currentChangesNodeIndex:;
  currentChangesNode: currentChangesNodeIndex processor.blocks.at.get;

  [getStackDepth currentChangesNode.matchingInfo.inputs.dataSize < not] "Stack underflow!" assert

  appliedVars: {
    curToNested: RefToVarTable;
    nestedToCur: RefToVarTable;
    fixedOutputs: RefToVar Array;
  };

  pops: RefToVar Array;

  i: 0 dynamic;
  [
    i currentChangesNode.matchingInfo.inputs.dataSize < [
      stackEntry: popForMatching;
      cacheEntry: i currentChangesNode.matchingInfo.inputs.at.refToVar;

      stackEntry cacheEntry applyEntriesRec
      stackEntry @pops.pushBack

      i 1 + @i set compilable
    ] &&
  ] loop

  i: 0 dynamic;
  [
    i pops.dataSize < [
      pops.dataSize i - 1 - pops.at push
      i 1 + @i set compilable
    ] &&
  ] loop

  i: 0 dynamic;
  [
    i currentChangesNode.matchingInfo.captures.dataSize < [
      currentCapture: i currentChangesNode.matchingInfo.captures.at;

      cacheEntry: currentCapture.refToVar;
      cacheEntry.hostId 0 < [
        currentCapture.nameInfo addFailedCapture
      ] [
        overload: currentCapture getOverload;
        stackEntry: currentCapture.nameInfo currentCapture overload getNameForMatchingWithOverload captureName.refToVar;
        stackEntry cacheEntry applyEntriesRec
      ] if

      i 1 + @i set compilable
    ] &&
  ] loop

  i: 0 dynamic;
  [
    i currentChangesNode.matchingInfo.fieldCaptures.dataSize < [
      currentFieldCapture: i currentChangesNode.matchingInfo.fieldCaptures.at;

      fieldName: currentFieldCapture.nameInfo copy;
      overload: currentFieldCapture getOverload;
      fieldCnr: currentFieldCapture.nameInfo overload getNameWithOverload captureName;

      i 1 + @i set compilable
    ] &&
  ] loop

  i: 0 dynamic;
  [
    i currentChangesNode.outputs.dataSize < [
      currentOutput: i currentChangesNode.outputs.at;
      outputRef: currentOutput.refToVar copyVarFromChild; # output is to inner var
      outputRef fixOutputRefsRec
      outputRef @appliedVars.@fixedOutputs.pushBack
      i 1 + @i set compilable
    ] &&
  ] loop

  appliedVars.curToNested [
    pair:;
    pair.value pair.key @appliedVars.@nestedToCur.insert
  ] each

  @appliedVars.@curToNested [
    pair:;
    curVar:    pair.key getVar;
    nestedVar: pair.value getVar;
    nestedVar.data.getTag VarRef = [
      nestedCopy: pair.value copyOneVar;
      pair.value isGlobal [
        pVar: pair.value getVar;
        nVar: nestedCopy getVar;
        pVar.globalId @nVar.@globalId set
      ] when
      nestedCopy fixCaptureRef @pair.@value set
    ] when
  ] each

  @appliedVars
];

changeVarValue: [
  dst:;
  src:;

  compilable [
    varSrc: src getVar;
    varDst: dst getVar;

    varSrc.staticity @varDst.@staticity set
    dst isNonrecursiveType [
      varDst.data.getTag VarCond VarString 1 + [
        copy tag:;
        srcBranch: tag varSrc.data.get;
        dstBranch: tag @varDst.@data.get;
        srcBranch @dstBranch set
      ] staticCall
    ] [
      varDst.data.getTag VarRef = [
        srcBranch: VarRef varSrc.data.get;
        dstBranch: VarRef @varDst.@data.get;
        srcBranch @dstBranch set
      ] when
    ] if
  ] when
];

usePreInputsWith: [
  copy exitPre:;
  newNodeIndex:;
  newNodeIndex 0 < not [
    newNode: newNodeIndex processor.blocks.at.get;

    newMinStackDepth: currentNode getStackDepth newNode.matchingInfo.inputs.dataSize - newNode.matchingInfo.preInputs.dataSize -;
    newMinStackDepth currentNode.minStackDepth < [
      newMinStackDepth @currentNode.@minStackDepth set
    ] when

    exitPre not [
      newNode.matchingInfo.hasStackUnderflow [
        addStackUnderflowInfo
      ] when
    ] when
  ] when
];

usePreInputs: [FALSE dynamic usePreInputsWith];

isImplicitDeref: [
  copy case:;
  case ArgReturnDeref =
  case ArgRefDeref = or
];

derefNEntries: [
  copy count:;
  implicitDerefInfo:;
  i: 0 dynamic;
  [
    i count < [
      count 1 - i - implicitDerefInfo.at [
        dst: i @currentNode getStackEntry;
        dst getPossiblePointee @dst set
      ] when
      i 1 + @i set TRUE
    ] &&
  ] loop
];

applyNamedStackChanges: [
  forcedName:;
  appliedVars:;
  copy currentChangesNodeIndex:;
  newNode:;
  compileOnce

  currentChangesNodeIndex usePreInputs

  inputs: RefToVar Array;
  outputs: RefToVar Array;

  i: 0 dynamic;
  [
    i newNode.matchingInfo.inputs.dataSize < [
      pop @inputs.pushBack
      i 1 + @i set TRUE
    ] &&
  ] loop

  i: 0 dynamic;
  [
    i appliedVars.fixedOutputs.getSize < [
      outputRef: i appliedVars.fixedOutputs.at;
      outputRef @outputs.pushBack
      outputRef getVar.data.getTag VarStruct = [
        outputRef markAsAbleToDie
        outputRef @currentNode.@candidatesToDie.pushBack
      ] when
      outputRef push
      i 1 + @i set TRUE
    ] &&
  ] loop

  compilable [
    inputs outputs newNode forcedName makeNamedCallInstruction

    implicitDerefInfo: Cond Array;
    newNode.outputs [.argCase isImplicitDeref @implicitDerefInfo.pushBack] each
    implicitDerefInfo appliedVars.fixedOutputs.getSize derefNEntries
  ] when
];

applyStackChanges: [
  forcedName: StringView;
  forcedName applyNamedStackChanges
];

makeCallInstructionWith: [
  copy dynamicFunc:;
  refToVar:;
  forcedName:;
  newNode:;
  outputs:;
  inputs:;
  compileOnce

  argRet: RefToVar;
  argList: IRArgument Array;

  [newNode.variadic [inputs.getSize newNode.matchingInfo.inputs.getSize =] ||] "Input count mismatch!" assert

  i: 0 dynamic;
  [
    i inputs.getSize < [
      currentInputArgCase: i newNode.matchingInfo.inputs.getSize < [
        i newNode.matchingInfo.inputs.at.argCase copy
      ] [
        ArgCopy
      ] if;

      currentInput: i inputs.at;

      currentInputArgCase ArgVirtual = [currentInputArgCase ArgGlobal =] || [
      ] [
        arg: IRArgument;
        currentInput getVar.irNameId @arg.@irNameId set
        currentInput getMplSchema.irTypeId @arg.@irTypeId set
        currentInputArgCase ArgRef = [currentInputArgCase ArgRefDeref =] || @arg.@byRef set
        currentInputArgCase ArgCopy = [currentInput @currentNode createDerefToRegister @arg.@irNameId set] when

        arg @argList.pushBack
      ] if

      i 1 + @i set TRUE
    ] &&
  ] loop

  i: 0 dynamic;
  [
    i newNode.outputs.dataSize < [
      currentOutput: i newNode.outputs.at;
      outputRef: i outputs.at; # output is to inner var

      currentOutput.argCase ArgVirtual = [
      ] [
        refToVar: outputRef;
        outputRef getVar.allocationInstructionIndex 0 <
        [outputRef getVar.globalDeclarationInstructionIndex 0 <] && [
          outputRef @currentNode createAllocIR r:;
        ] when

        currentOutput.argCase ArgReturn = [currentOutput.argCase ArgReturnDeref =] || [
          refToVar @argRet set
        ] [
          arg: IRArgument;
          refToVar getVar.irNameId @arg.@irNameId set
          refToVar getMplSchema.irTypeId @arg.@irTypeId set
          TRUE @arg.@byRef set

          arg @argList.pushBack
        ] if
      ] if

      i 1 + @i set TRUE
    ] &&
  ] loop

  i: 0 dynamic;
  [
    i newNode.matchingInfo.captures.dataSize < [
      currentCapture: i newNode.matchingInfo.captures.at;

      currentCapture.refToVar.hostId 0 < not [
        currentCapture.argCase ArgRef = [
          overload: currentCapture getOverload;
          refToVar: currentCapture.nameInfo currentCapture overload getNameForMatchingWithOverload captureName.refToVar;
          [currentCapture.refToVar refToVar variablesAreSame] "invalid capture type while generating arg list!" assert

          arg: IRArgument;
          refToVar getVar.irNameId @arg.@irNameId set
          refToVar getMplSchema.irTypeId @arg.@irTypeId set
          TRUE @arg.@byRef set
          TRUE @arg.@byRef set

          arg @argList.pushBack
        ] when
      ] when

      i 1 + @i set TRUE
    ] &&
  ] loop

  newNode.empty not [
    pureFuncName: forcedName "" = [dynamicFunc [refToVar getIrName][newNode.irName makeStringView] if][forcedName copy] if;
    funcName: newNode.variadic [("(" newNode.argTypes ") " pureFuncName) assembleString][pureFuncName toString] if;
    convName: newNode.convention;
    retName: argRet argList convName funcName @currentNode createCallIR;

    argRet.varId 0 < not [
      @retName argRet @currentNode createStoreFromRegister
    ] when
  ] when
];

makeNamedCallInstruction: [
  r: RefToVar;
  r FALSE dynamic makeCallInstructionWith
];

makeCallInstruction: [
  r: RefToVar;
  forcedName: StringView;
  forcedName r FALSE dynamic makeCallInstructionWith
];

processNamedCallByNode: [
  forcedName:;
  copy newNodeIndex:;
  newNode: newNodeIndex processor.blocks.at.get;
  compileOnce

  newNodeIndex changeNewNodeState
  newNode.state NodeStateNoOutput = not [
    appliedVars: newNodeIndex applyNodeChanges;

    appliedVars.curToNested [
      pair:;
      pair.value pair.key changeVarValue
    ] each

    newNode newNodeIndex @appliedVars forcedName applyNamedStackChanges
  ] when
];

processCallByNode: [
  forcedName: StringView;
  forcedName processNamedCallByNode
];

{processorResult: ProcessorResult Ref; processor: Processor Ref; currentNode: Block Ref; multiParserResult: MultiParserResult Cref;
  positionInfo: CompilerPositionInfo Cref; name: StringView Cref; nodeCase: NodeCaseCode; indexArray: IndexArray Cref;} () {convention: cdecl;} [

  processorResult:;
  processor:;
  currentNode:;
  multiParserResult:;
  failProc: @failProcForProcessor;

  positionInfo:;
  name:;
  copy nodeCase:;
  indexArray:;
  compileOnce

  forcedNameString: String;

  newNodeIndex: indexArray tryMatchAllNodes;
  newNodeIndex 0 < [compilable] && [
    name
    currentNode.id
    nodeCase
    @processorResult
    @processor
    indexArray
    multiParserResult
    positionInfo
    CFunctionSignature
    astNodeToCodeNode @newNodeIndex set
  ] when

  compilable [
    newNode: newNodeIndex @processor.@blocks.at.get;
    currentNode.parent 0 = [nodeCase NodeCaseList = nodeCase NodeCaseObject = or] && [newNode.matchingInfo.inputs.getSize 0 =] && [newNode.outputs.getSize 1 =] && [
      realCapturesCount: 0;
      newNode.matchingInfo.captures [
        capture:;
        capture.refToVar.hostId 0 < ~ [
          capture.refToVar isVirtual not [realCapturesCount 1 + @realCapturesCount set] when
        ] when
      ] each

      realCapturesCount 0 =
    ] && [
      0 newNode.outputs.at.refToVar isStaticData
    ] && [
      result: 0 newNode.outputs.at.refToVar copyVarFromChild;
      TRUE @newNode.@deleted set
      result @currentNode createStaticInitIR push
    ] [
      forcedName: forcedNameString makeStringView;
      newNodeIndex forcedName processNamedCallByNode
    ] if
  ] [
    newNodeIndex usePreInputs
    newNodeIndex usePreCaptures
  ] if
] "processCallByIndexArrayImpl" exportFunction

{processorResult: ProcessorResult Ref; processor: Processor Ref; currentNode: Block Ref; multiParserResult: MultiParserResult Cref; name: StringView Cref; callAstNodeIndex: Int32;} () {convention: cdecl;} [
  processorResult:;
  processor:;
  currentNode:;
  multiParserResult:;
  failProc: @failProcForProcessor;

  name:;
  callAstNodeIndex:;
  astNode: callAstNodeIndex @multiParserResult.@memory.at;

  positionInfo: astNode makeCompilerPosition;

  astNode.data.getTag AstNodeType.Code AstNodeType.List 1 + [
    copy tag:;
    indexArray: tag astNode.data.get;

    nodeCase: NodeCaseCode;
    tag AstNodeType.List   = [NodeCaseList   @nodeCase set] when
    tag AstNodeType.Object = [NodeCaseObject @nodeCase set] when

    indexArray nodeCase dynamic name positionInfo processCallByIndexArray
  ] staticCall
] "processCallImpl" exportFunction

{processorResult: ProcessorResult Ref; processor: Processor Ref; currentNode: Block Ref; multiParserResult: MultiParserResult Cref; preAstNodeIndex: Int32;} Cond {convention: cdecl;} [
  processorResult:;
  processor:;
  currentNode:;
  multiParserResult:;
  failProc: @failProcForProcessor;

  copy preAstNodeIndex:;

  compilable [
    astNode: preAstNodeIndex @multiParserResult.@memory.at;
    positionInfo: astNode makeCompilerPosition;
    indexArray: AstNodeType.Code @astNode.@data.get;

    oldSuccess: compilable;
    oldGlobalErrorCount: processorResult.globalErrorInfo.getSize;

    newNodeIndex: indexArray tryMatchAllNodes;
    newNodeIndex 0 < [compilable] && [
      processor.depthOfPre 1 + @processor.@depthOfPre set
      "PRE" makeStringView currentNode.id NodeCaseCode @processorResult @processor indexArray multiParserResult positionInfo CFunctionSignature astNodeToCodeNode @newNodeIndex set
      processor.depthOfPre 1 - @processor.@depthOfPre set
    ] when

    oldGlobalErrorCount @processorResult.@globalErrorInfo.shrink
    oldSuccess [
      processorResult.passErrorThroughPRE not [-1 clearProcessorResult] when
    ] [
      [FALSE] "Has compilerError before trying compiling pre!" assert
    ] if

    newNode: newNodeIndex processor.blocks.at.get;
    newNodeIndex TRUE dynamic usePreInputsWith
    newNodeIndex TRUE dynamic usePreCapturesWith

    newNode.matchingInfo.hasStackUnderflow [
      currentNode.minStackDepth 1 - @currentNode.@minStackDepth set
    ] when

    newNode.matchingInfo.unfoundedNames [
      .key copy addFailedCapture
    ] each

    newNode.uncompilable not
    [newNode.outputs.dataSize 0 >] &&
    [
      top: newNode.outputs.last.refToVar;
      top getVar.data.getTag VarCond =
      [top staticityOfVar Weak < not] && [
        VarCond top getVar.data.get copy
      ] [
        TRUE dynamic @processorResult.@passErrorThroughPRE set
        "PRE code must fail or return static Cond" currentNode compilerError
        FALSE dynamic
      ] if
    ] &&
  ] [
    FALSE dynamic
  ] if
] "processPreImpl" exportFunction

processIf: [
  astNodeElse:;
  astNodeThen:;
  refToCond:;

  indexArrayElse: AstNodeType.Code astNodeElse.data.get;
  indexArrayThen: AstNodeType.Code astNodeThen.data.get;

  positionInfoThen: astNodeThen makeCompilerPosition;
  positionInfoElse: astNodeElse makeCompilerPosition;

  newNodeThenIndex: @indexArrayThen tryMatchAllNodes;
  newNodeThenIndex 0 < [compilable] && [
    "ifThen" makeStringView
    currentNode.id
    NodeCaseCode
    @processorResult
    @processor
    indexArrayThen
    multiParserResult
    positionInfoThen
    CFunctionSignature astNodeToCodeNode @newNodeThenIndex set
  ] when

  newNodeThenIndex usePreInputs

  compilable [
    newNodeThen: newNodeThenIndex @processor.@blocks.at.get;
    newNodeElseIndex: @indexArrayElse tryMatchAllNodes;
    newNodeElseIndex 0 < [compilable] && [
      "ifElse" makeStringView
      currentNode.id
      NodeCaseCode
      @processorResult
      @processor
      indexArrayElse
      multiParserResult
      positionInfoElse
      CFunctionSignature astNodeToCodeNode @newNodeElseIndex set
    ] when

    newNodeElseIndex usePreInputs

    compilable [
      newNodeElse: newNodeElseIndex @processor.@blocks.at.get;

      newNodeThenIndex changeNewNodeState
      newNodeElseIndex changeNewNodeState

      newNodeThen.state NodeStateHasOutput < [newNodeElse.state NodeStateHasOutput <] || [
        #merging uncompiled nodes
        newNodeThen.state NodeStateHasOutput < [newNodeElse.state NodeStateHasOutput <] && [
          NodeStateNoOutput @currentNode.@state set
        ] [
          newNodeThen.state NodeStateHasOutput < [
            newNodeElseIndex processCallByNode
          ] [
            newNodeThenIndex processCallByNode
          ] if

          NodeStateHasOutput @currentNode.@state set
        ] if
      ] [
        newNodeThen.state NodeStateHasOutput = [newNodeElse.state NodeStateHasOutput =] || [NodeStateHasOutput @currentNode.@state set] when

        appliedVarsThen: newNodeThenIndex applyNodeChanges;
        appliedVarsElse: newNodeElseIndex applyNodeChanges;

        stackDepth: currentNode getStackDepth;
        newNodeThen.matchingInfo.inputs.dataSize stackDepth > ["then branch stack underflow" currentNode compilerError] when
        newNodeElse.matchingInfo.inputs.dataSize stackDepth > ["else branch stack underflow" currentNode compilerError] when
        stackDepth newNodeThen.matchingInfo.inputs.dataSize - newNodeThen.outputs.dataSize +
        stackDepth newNodeElse.matchingInfo.inputs.dataSize - newNodeElse.outputs.dataSize + = not ["if branches stack size mismatch" currentNode compilerError] when

        compilable [
          longestInputSize: newNodeThen.matchingInfo.inputs.dataSize copy;
          newNodeElse.matchingInfo.inputs.dataSize longestInputSize > [newNodeElse.matchingInfo.inputs.dataSize @longestInputSize set] when
          longestOutputSize: newNodeThen.outputs.dataSize copy;
          newNodeElse.outputs.dataSize longestOutputSize > [newNodeElse.outputs.dataSize @longestOutputSize set] when
          shortestInputSize: newNodeThen.matchingInfo.inputs.dataSize newNodeElse.matchingInfo.inputs.dataSize + longestInputSize -;
          shortestOutputSize: newNodeThen.outputs.dataSize newNodeElse.outputs.dataSize + longestOutputSize -;

          getOutput: [
            branch:;
            copy index:;
            index branch.fixedOutputs.dataSize + longestOutputSize < [
              longestInputSize index - 1 - currentNode getStackEntry copy
            ] [
              index branch.fixedOutputs.dataSize + longestOutputSize - branch.fixedOutputs.at copy
            ] if
          ];

          isOutputImplicitDeref: [
            branch:;
            copy index:;
            index branch.outputs.dataSize + longestOutputSize < [
              FALSE
            ] [
              index branch.outputs.dataSize + longestOutputSize - branch.outputs.at.argCase isImplicitDeref
            ] if
          ];

          getCompiledInput: [
            compiledOutputs:;
            branch:;
            copy index:;

            index branch.outputs.dataSize + longestOutputSize < [
              longestInputSize 1 - i - inputs.at copy
            ] [
              index branch.outputs.dataSize + longestOutputSize - compiledOutputs.at copy
            ] if
          ];

          getCompiledOutput: [
            compiledOutputs:;
            branch:;
            copy index:;
            index branch.outputs.dataSize + longestOutputSize < [
              index outputs.at
            ] [
              index branch.outputs.dataSize + longestOutputSize - compiledOutputs.at
            ] if
          ];

          # merge captures
          mergeValues: [
            refToDst:;
            value2:;
            value1:;

            [value1 value2 variablesAreSame] "captures changed to different types!" assert
            value1 staticityOfVar Dynamic = value2 staticityOfVar Dynamic = or [
              refToDst makeVarDynamic
              value1 makePointeeDirtyIfRef
              value2 makePointeeDirtyIfRef
            ] [
              value1 value2 variablesAreEqual [ # both are static, same value
                value1 refToDst changeVarValue
              ] [
                refToDst makeVarDynamic
                value1 makePointeeDirtyIfRef
                value2 makePointeeDirtyIfRef
              ] if
            ] if
          ];

          mergeValuesRec: [
            refToDst:;
            value2:;
            value1:;

            unfinishedV1: RefToVar Array;
            unfinishedV2: RefToVar Array;
            unfinishedD: RefToVar Array;

            value1   @unfinishedV1.pushBack
            value2   @unfinishedV2.pushBack
            refToDst @unfinishedD .pushBack

            [
              unfinishedD.dataSize 0 > [
                lastD: unfinishedD.last copy;
                lastV1: unfinishedV1.last copy;
                lastV2: unfinishedV2.last copy;
                @unfinishedD.popBack
                @unfinishedV1.popBack
                @unfinishedV2.popBack

                lastV1 lastV2 lastD mergeValues

                lastD getVar.data.getTag VarStruct = [
                  [lastV1 getVar.data.getTag VarStruct =] "Merging structures type fail!" assert
                  [lastV2 getVar.data.getTag VarStruct =] "Merging structures type fail!" assert
                  structD: VarStruct lastD getVar.data.get.get;
                  structV1: VarStruct lastV1 getVar.data.get.get;
                  structV2: VarStruct lastV2 getVar.data.get.get;
                  [structD.fields.dataSize structV1.fields.dataSize =] "Merging structures fieldCount fail!" assert
                  [structD.fields.dataSize structV2.fields.dataSize =] "Merging structures fieldCount fail!" assert
                  f: 0;
                  [
                    f structD.fields.dataSize < [
                      f structV1.fields.at.refToVar @unfinishedV1.pushBack
                      f structV2.fields.at.refToVar @unfinishedV2.pushBack
                      f structD .fields.at.refToVar @unfinishedD .pushBack
                      f 1 + @f set TRUE
                    ] &&
                  ] loop
                ] when

                TRUE
              ] &&
            ] loop
          ];

          appliedVarsThen.curToNested [
            pair:;
            fr: pair.key @appliedVarsElse.@curToNested.find;
            fr.success [
              pair.value fr.value pair.key mergeValues
            ] [
              pair.value pair.key pair.key mergeValues
            ] if
          ] each

          appliedVarsElse.curToNested [
            pair:;
            fr: pair.key @appliedVarsThen.@curToNested.find;
            fr.success [
              # capture changed in both branches, we just applied it
            ] [
              pair.value pair.key pair.key mergeValues
            ] if
          ] each

          # check stack consistency
          inputsThen:  RefToVar Array;
          inputsElse:  RefToVar Array;
          outputsThen: RefToVar Array;
          outputsElse: RefToVar Array;
          inputs:      RefToVar Array;
          outputs:     RefToVar Array;

          implicitDerefInfo: Cond Array;

          i: 0 dynamic;
          [
            i longestOutputSize < [
              outputThen: i appliedVarsThen getOutput;
              outputElse: i appliedVarsElse getOutput;
              isOutputImplicitDerefThen: i newNodeThen isOutputImplicitDeref;
              isOutputImplicitDerefElse: i newNodeElse isOutputImplicitDeref;

              isOutputImplicitDerefThen isOutputImplicitDerefElse = [
                outputThen outputElse variablesAreSame [
                  newOutput: outputThen copy;
                  outputElse.mutable outputThen.mutable and @newOutput.@mutable set
                  outputThen outputElse newOutput mergeValuesRec
                  i newNodeThen.outputs.dataSize + longestOutputSize < not [newOutput @outputsThen.pushBack] when
                  i newNodeElse.outputs.dataSize + longestOutputSize < not [newOutput @outputsElse.pushBack] when
                  newOutput @currentNode createAllocIR @outputs.pushBack
                ] [
                  ("branch types mismatch; in 'then' type is " outputThen currentNode getMplType "; in 'else' type is " outputElse currentNode getMplType) assembleString currentNode compilerError
                ] if

                isOutputImplicitDerefThen @implicitDerefInfo.pushBack
              ] [
                "branch return cases mismatch" currentNode compilerError
              ] if

              i 1 + @i set compilable
            ] &&
          ] loop

          compilable [
            i: 0 dynamic;
            [
              i longestInputSize < [
                a: pop;
                a @inputs.pushBack
                i newNodeThen.matchingInfo.inputs.dataSize < [a @inputsThen.pushBack] when
                i newNodeElse.matchingInfo.inputs.dataSize < [a @inputsElse.pushBack] when
                i 1 + @i set TRUE
              ] &&
            ] loop

            i: 0 dynamic;
            [
              i outputs.dataSize < [
                outputRef: i outputs.at;
                outputRef getVar.data.getTag VarStruct = [
                  outputRef markAsAbleToDie
                  outputRef @currentNode.@candidatesToDie.pushBack
                ] when

                outputRef push
                i 1 + @i set TRUE
              ] &&
            ] loop

            compilable [
              # create instruction
              #1 prolog, allocate common vars

              createStores: [
                compiledOutputs:;
                branch:;

                result: Int32 Array;
                i: 0 dynamic;
                [
                  i longestOutputSize < [
                    current: i branch compiledOutputs getCompiledOutput;
                    curInput: i branch compiledOutputs getCompiledInput;

                    current.varId curInput.varId = not [
                      curInput isVirtual not ["variable states in branches mismatch" currentNode compilerError] when
                      FALSE curInput getVar.@temporary set
                      curInput current @currentNode createCheckedCopyToNewNoDie
                    ] when
                    -1 @result.pushBack
                    i 1 + @i set TRUE
                  ] &&
                ] loop
                result
              ];

              wasNestedCall: currentNode.hasNestedCall copy;
              0 refToCond @currentNode createBranch
              @currentNode createLabel
              inputsThen outputsThen newNodeThen makeCallInstruction
              storesThen: newNodeThen outputsThen createStores;
              0 @currentNode createJump
              @currentNode createLabel
              wasNestedCall @currentNode.@hasNestedCall set
              inputsElse outputsElse newNodeElse makeCallInstruction
              storesElse: newNodeElse outputsElse createStores;
              1 @currentNode createJump
              @currentNode createLabel
              implicitDerefInfo longestOutputSize derefNEntries
              processor.options.verboseIR ["create phi nodes..." @currentNode createComment] when
              processor.options.verboseIR ["end if" @currentNode createComment] when
            ] when
          ] when
        ] when
      ] if
    ] when
  ] when

];

processLoop: [
  astNode:;
  indexArray: AstNodeType.Code astNode.data.get;
  positionInfo: astNode makeCompilerPosition;

  iterationNumber: 0 dynamic;
  loopIsDynamic: FALSE;

  [
    newNodeIndex: @indexArray tryMatchAllNodes;
    newNodeIndex 0 < [compilable] && [
      "loop" makeStringView
      currentNode.id
      NodeCaseCode
      @processorResult
      @processor
      indexArray
      multiParserResult
      positionInfo
      CFunctionSignature astNodeToCodeNode @newNodeIndex set
    ] when

    newNodeIndex usePreInputs

    compilable [
      newNode: newNodeIndex @processor.@blocks.at.get;
      newNodeIndex changeNewNodeState

      newNode.state NodeStateHasOutput < [
        FALSE
      ] [
        newNode.state NodeStateHasOutput = [NodeStateHasOutput @currentNode.@state set] when
        appliedVars: newNodeIndex applyNodeChanges;

        appliedVars.fixedOutputs.getSize 0 = ["loop body must return Cond" currentNode compilerError] when
        compilable [
          condition: newNode.outputs.last.refToVar;
          condVar: condition getVar;
          condVar.data.getTag VarCond = not ["loop body must return Cond" currentNode compilerError] when

          compilable [
            condition staticityOfVar Weak > [
              appliedVars.curToNested [
                pair:;
                pair.value pair.key changeVarValue
              ] each

              newNode newNodeIndex @appliedVars applyStackChanges
              a: pop;
              VarCond a getVar.data.get copy
            ] [
              TRUE dynamic @loopIsDynamic set
              FALSE
            ] if
          ] &&
        ] &&
      ] if
    ] &&

    iterationNumber 1 + @iterationNumber set
    iterationNumber processor.options.staticLoopLengthLimit > [
      TRUE @processorResult.!passErrorThroughPRE
      ("Static loop length limit (" processor.options.staticLoopLengthLimit ") exceeded. Dynamize loop or increase limit using -static_loop_lenght_limit option") assembleString currentNode compilerError
    ] when

    compilable and
  ] loop

  loopIsDynamic [indexArray processDynamicLoop] when
];

processDynamicLoop: [

  indexArray:;

  iterationNumber: 0 dynamic;
  [
    needToRemake: FALSE dynamic;
    newNodeIndex: @indexArray tryMatchAllNodes;
    newNodeIndex 0 < [compilable] && [
      "dynamicLoop" makeStringView
      currentNode.id
      NodeCaseCode
      @processorResult
      @processor
      indexArray
      multiParserResult
      positionInfo
      CFunctionSignature astNodeToCodeNode @newNodeIndex set
    ] when

    newNodeIndex usePreInputs

    compilable [
      newNode: newNodeIndex @processor.@blocks.at.get;
      newNodeIndex changeNewNodeState

      newNode.state NodeStateHasOutput < [
        FALSE
      ] [
        newNode.state NodeStateHasOutput = [NodeStateHasOutput @currentNode.@state set] when

        appliedVars: newNodeIndex applyNodeChanges;

        checkToRecompile: [
          dst:;
          src:;

          result: FALSE dynamic;
          src dst variablesAreSame [
            src staticityOfVar Weak >
            [src dst variablesAreEqual not] && [
              TRUE @result set
            ] when
          ] [
            "loop body changes stack types" currentNode compilerError
          ] if

          result
        ];

        appliedVars.curToNested [
          pair:;

          pair.key pair.value checkToRecompile [
            pair.value staticityOfVar Dirty = [
              pair.key makeVarDirty
            ] [
              pair.key makeVarDynamic
            ] if
            pair.key makePointeeDirtyIfRef
            TRUE dynamic @needToRemake set
          ] when
        ] each

        newNode.outputs.dataSize newNode.matchingInfo.inputs.dataSize 1 + = not ["loop body must save stack values and return Cond" currentNode compilerError] when
        compilable [
          condition: newNode.outputs.last.refToVar;
          condVar: condition getVar;
          condVar.data.getTag VarCond = not ["loop body must return Cond" currentNode compilerError] when

          i: 0 dynamic;
          [
            i newNode.matchingInfo.inputs.dataSize < [
              curInput: i currentNode getStackEntry;
              curOutput: newNode.matchingInfo.inputs.dataSize 1 - i - newNode.outputs.at .refToVar;
              curInput curOutput checkToRecompile [
                curInput makeVarTreeDynamic
                TRUE dynamic @needToRemake set
              ] when
              i 1 + @i set TRUE
            ] &&
          ] loop
        ] when

        needToRemake not compilable and [
          inputs:     RefToVar Array;
          nodeInputs: RefToVar Array;
          outputs:    RefToVar Array;

          # apply stack changes
          i: 0 dynamic;
          [
            i newNode.matchingInfo.inputs.dataSize < [
              pop @inputs.pushBack
              i 1 + @i set TRUE
            ] &&
          ] loop

          i: 0 dynamic;
          [
            i appliedVars.fixedOutputs.getSize < [
              curOutput: i appliedVars.fixedOutputs.at;
              curOutput @outputs.pushBack
              curOutput getVar.data.getTag VarStruct = [
                curOutput @currentNode.@candidatesToDie.pushBack
              ] when

              i 1 + newNode.outputs.dataSize < [
                curOutput push
              ] when
              i 1 + @i set TRUE
            ] &&
          ] loop

          createPhiNodes: [
            i: 0 dynamic;
            [
              i inputs.getSize < [
                curNodeInput: i inputs.at copyVar;
                curNodeInput @nodeInputs.pushBack

                (curNodeInput getIrType "*") assembleString makeStringView # with *
                curNodeInput getIrName
                i inputs.at getIrName
                inputs.dataSize 1 - i - outputs.at getIrName
                1 @currentNode createPhiNode

                i 1 + @i set TRUE
              ] &&
            ] loop
          ];

          # create instruction
          processor.options.verboseIR ["loop prepare..." @currentNode createComment] when
          1 @currentNode createJump
          @currentNode createLabel
          createPhiNodes # for each input-output!
          processor.options.verboseIR ["phi nodes prepared" @currentNode createComment] when
          nodeInputs outputs newNode makeCallInstruction

          implicitDerefInfo: Cond Array;
          newNode.outputs [.argCase isImplicitDeref @implicitDerefInfo.pushBack] each
          implicitDerefInfo outputs.getSize 1 - derefNEntries
          processor.options.verboseIR ["loop end prepare..." @currentNode createComment] when
          1 outputs.last @currentNode createBranch
          @currentNode createLabel
        ] when

        needToRemake [
          newNodeIndex processor.blocks.at.get.nodeCompileOnce [
            "loop body compileOnce directive fail" currentNode compilerError
          ] when

          newNodeIndex deleteNode

          iterationNumber processor.options.staticLoopLengthLimit > [
            "loop dynamisation iteration count so big" currentNode compilerError
          ] when
        ] when

        iterationNumber 1 + @iterationNumber set

        needToRemake compilable and
      ] if
    ] &&
  ] loop
];

{processorResult: ProcessorResult Ref; processor: Processor Ref; currentNode: Block Ref; multiParserResult: MultiParserResult Cref;
  asLambda: Cond; name: StringView Cref; astNode: AstNode Cref; signature: CFunctionSignature Cref;} Int32 {convention: cdecl;} [
  processorResult:;
  processor:;
  currentNode:;
  multiParserResult:;
  failProc: @failProcForProcessor;

  copy asLambda:;
  name:;
  astNode:;
  signature:;

  indexArray: AstNodeType.Code astNode.data.get;
  positionInfo: astNode makeCompilerPosition;
  compileOnce

  signature.variadic [
    "export function cannot be variadic" currentNode compilerError
  ] when

  ("process export: " makeStringView name makeStringView) addLog

  # we dont know count of used in export entites
  signature.inputs.getSize [
    r: signature.inputs.getSize 1 - i - signature.inputs.at copyVarFromChild;
    r makeVarTreeDynamic
    r unglobalize
    r fullUntemporize
    r getVar.data.getTag VarRef = [
      r getPointeeNoDerefIR push
    ] [
      FALSE @r.@mutable set
      r push
    ] if
  ] times

  oldSuccess: compilable;
  oldRecursiveNodesStackSize: processor.recursiveNodesStack.getSize;

  newNodeIndex: @indexArray tryMatchAllNodesForRealFunction;
  newNodeIndex 0 < [compilable] && [
    nodeCase: asLambda [NodeCaseLambda][NodeCaseExport] if;
    processor.exportDepth 1 + @processor.@exportDepth set
    name currentNode.id nodeCase @processorResult @processor indexArray multiParserResult positionInfo signature astNodeToCodeNode @newNodeIndex set
    processor.exportDepth 1 - @processor.@exportDepth set
  ] when

  newNodeIndex usePreCaptures

  compilable [
    newNodeIndex changeNewExportNodeState

    newNode: newNodeIndex processor.blocks.at.get;
    newNode.outputs.getSize 1 > ["export function cant have 2 or more outputs" currentNode compilerError] when
    newNode.outputs.getSize 1 = [signature.outputs.getSize 0 =] && ["signature is void, export function must be without output" currentNode compilerError] when
    newNode.outputs.getSize 0 = [signature.outputs.getSize 1 =] && ["signature is not void, export function must have output" currentNode compilerError] when
    newNode.state NodeStateCompiled = not [
      "can not implement lambda inside itself body" currentNode compilerError
      FALSE @oldSuccess set
    ] when

    compilable [
      newNode.captureNames [
        currentCaptureName:;
        currentCaptureName.startPoint currentNode.id = not [
          fr: currentCaptureName.startPoint @currentNode.@usedModulesTable.find;
          fr.success [TRUE @fr.@value.@used set] when
        ] when
      ] each

      signature.outputs.getSize [
        currentInNode: i newNode.outputs.at.refToVar;
        currentInSignature: i signature.outputs @;

        currentInNode currentInSignature variablesAreSame not [
          ("export function output mismatch, expected " currentInSignature currentNode getMplType ";" LF
            "but found " currentInNode currentNode getMplType) assembleString currentNode compilerError
        ] when
      ] times
    ] when
  ] when

  signature.inputs [p:; a: pop;] each

  oldSuccess compilable not and processor.depthOfPre 0 = and [
    @processorResult.@errorInfo move @processorResult.@globalErrorInfo.pushBack
    oldRecursiveNodesStackSize @processor.@recursiveNodesStack.shrink
    -1 clearProcessorResult

    signature name FALSE dynamic processImportFunction Block addressToReference .id copy !newNodeIndex
  ] when

  ("processed export: " makeStringView name makeStringView) addLog

  newNodeIndex
] "processExportFunctionImpl" exportFunction

{processorResult: ProcessorResult Ref; processor: Processor Ref; currentNode: Block Ref; multiParserResult: MultiParserResult Cref;
  asCodeRef: Cond; name: StringView Cref; signature: CFunctionSignature Cref;} Natx {convention: cdecl;} [
  processorResult:;
  processor:;
  currentNode:;
  multiParserResult:;
  failProc: @failProcForProcessor;

  copy asCodeRef:;
  name:;
  signature:;
  compileOnce

  addBlock
  declarationNode: @processor.@blocks.last.get;
  currentNode.id @declarationNode.@parent set
  asCodeRef [NodeCaseCodeRefDeclaration][NodeCaseDeclaration] if @declarationNode.@nodeCase set
  signature.variadic @declarationNode.@variadic set

  signature.inputs.getSize [
    r: signature.inputs.getSize 1 - i - signature.inputs.at copyVarFromChild;
    r unglobalize
    FALSE @r.@mutable set
    r push
  ] times

  [
    curPosition: currentNode.position;
    currentNode: @declarationNode;
    curPosition @currentNode.@position set
    position: curPosition copy;
    compilerPositionInfo: position;
    forcedSignature: signature;
    processor.options.debug [
      addDebugReserve @currentNode.@funcDbgIndex set
    ] when
    forcedSignature.inputs   [p:; a: pop;] each
    forcedSignature.outputs [copyVarFromChild push] each
    name finalizeCodeNode
  ] call

  signature.inputs   [p:; a: pop;] each
  declarationNode storageAddress
] "processImportFunctionImpl" exportFunction

callImportWith: [
  copy dynamicFunc:;
  refToVar:;
  declarationNode:;

  inputs:   RefToVar Array;
  outputs:  RefToVar Array;
  (
    [compilable]
    [
      i: 0 dynamic;
      [
        i declarationNode.matchingInfo.inputs.dataSize < [
          (
            [compilable]
            [stackEntry: pop;]
            [
              input: stackEntry copy;
              input makeVarRealCaptured
              nodeEntry: i declarationNode.matchingInfo.inputs.at.refToVar;
              nodeMutable: nodeEntry.mutable copy;
              i declarationNode.csignature.inputs.at getVar.data.getTag VarRef = [
                TRUE stackEntry getVar.@capturedAsMutable set
              ] when

              stackEntry nodeEntry variablesAreSame not [
                lambdaCastResult: input nodeEntry tryImplicitLambdaCast;
                lambdaCastResult.success [
                  lambdaCastResult.refToVar @input set
                ] [
                  ("cant call import, variable types of argument #" i " are incorrect, expected " nodeEntry currentNode getMplType ";" LF "but found " stackEntry currentNode getMplType) assembleString currentNode compilerError
                ] if
              ] when
            ] [
              stackEntry.mutable not nodeMutable and [
                ("cant call import, expected mutable argument #" i " with type " nodeEntry currentNode getMplType) assembleString currentNode compilerError
              ] when
            ] [
              nodeMutable [stackEntry makeVarTreeDirty] when
              input @inputs.pushBack
            ]
          ) sequence
          i 1 + @i set compilable
        ] &&
      ] loop
    ] [
      declarationNode.variadic [
        (
          [compilable]
          [refToVarargs: pop;]
          [
            varargs: refToVarargs getVar;
            varargs.data.getTag VarStruct = not ["varargs must be a struct" currentNode compilerError] when
          ] [
            varStruct: VarStruct varargs.data.get.get;
            varStruct.fields.getSize [
              field: i refToVarargs processStaticAt;
              field @inputs.pushBack
            ] times
          ]
        ) sequence
      ] when
    ] [
      i: 0 dynamic;
      [
        i declarationNode.outputs.getSize < [
          currentOutput: i declarationNode.outputs.at.refToVar;
          current: currentOutput copyVarFromChild;
          Dynamic current getVar.@staticity set
          current @outputs.pushBack
          current getVar.data.getTag VarStruct = [
            current @currentNode.@candidatesToDie.pushBack
          ] when

          i 1 + @i set compilable
        ] &&
      ] loop
    ] [
      forcedName: StringView;
      inputs outputs declarationNode forcedName refToVar dynamicFunc makeCallInstructionWith

      i: 0 dynamic;
      [
        i outputs.getSize < [
          currentOutput: i outputs.at;
          currentOutput push
          i 1 + @i set compilable
        ] &&
      ] loop
    ] [
      implicitDerefInfo: Cond Array;
      outputs [
        getVar.data.getTag VarRef = @implicitDerefInfo.pushBack
      ] each
      implicitDerefInfo outputs.getSize derefNEntries
    ]
  ) sequence
];

{processorResult: ProcessorResult Ref; processor: Processor Ref; currentNode: Block Ref; multiParserResult: MultiParserResult Cref;
  refToVar: RefToVar Cref;} () {convention: cdecl;} [

  processorResult:;
  processor:;
  currentNode:;
  multiParserResult:;
  failProc: @failProcForProcessor;

  refToVar:;
  var: refToVar getVar;
  protoIndex: VarImport var.data.get copy;
  node: protoIndex @processor.@blocks.at.get;
  [
    node.nextRecLambdaId 0 < not [
      node.nextRecLambdaId @protoIndex set
      protoIndex @processor.@blocks.at.get !node
      TRUE
    ] &&
  ] loop

  dynamicFunc: refToVar staticityOfVar Dynamic > not;
  dynamicFunc not [
    node.nodeCase NodeCaseCodeRefDeclaration = [
      "nullpointer call" currentNode compilerError
    ] when
  ] when

  @node refToVar dynamicFunc callImportWith
] "processFuncPtrImpl" exportFunction
