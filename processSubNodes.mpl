"control" useModule
"codeNode" includeModule

{processorResult: ProcessorResult Ref; cachedGlobalErrorInfoSize: Int32;} () {} [
  cachedGlobalErrorInfoSize: processorResult:;;
  TRUE               @processorResult.!success
  FALSE              @processorResult.!findModuleFail
  FALSE              @processorResult.!passErrorThroughPRE
  String             @processorResult.!program
  ProcessorErrorInfo @processorResult.!errorInfo

  cachedGlobalErrorInfoSize 0 < ~ [
    cachedGlobalErrorInfoSize @processorResult.@globalErrorInfo.shrink
  ] when
] "clearProcessorResult" exportFunction

{processor: Processor Cref; cacheEntry: RefToVar Cref; stackEntry: RefToVar Cref;} Cond {} [
  stackEntry: cacheEntry: processor:;;;

  cacheEntry isGlobal [
    stackEntry isGlobal [
      cacheEntry getVar.globalId
      stackEntry getVar.globalId =
    ] &&
  ] [
    stackEntry isGlobal ~
  ] if
] "variablesHaveSameGlobality" exportFunction

{processor: Processor Cref; checkRefs: Cond; stackDynamicBorder: Nat8; cacheEntry: RefToVar Cref; stackEntry: RefToVar Cref;} Cond {} [
  stackEntry: cacheEntry: stackDynamicBorder: checkRefs: processor:;;;;;

  cacheEntry stackEntry variablesAreSame [cacheEntry stackEntry processor variablesHaveSameGlobality] && [
    cacheEntryVar: cacheEntry getVar;
    stackEntryVar: stackEntry getVar;

    stackEntryVar.data.getTag VarStruct = [
      cacheStruct: VarStruct cacheEntryVar.data.get.get;
      stackStruct: VarStruct stackEntryVar.data.get.get;
      cacheStruct.hasDestructor ~ [cacheStruct.forgotten stackStruct.forgotten =] ||
    ] [
      cacheStaticity: cacheEntry staticityOfVar;
      stackStaticity: stackEntry staticityOfVar;

      cacheStaticity Weak > ~ stackStaticity stackDynamicBorder > ~ and [ # both dynamic
        cacheStaticity Weak > stackStaticity stackDynamicBorder > and [ # both static
          cacheEntry isSemiplainNonrecursiveType [
            result: TRUE;

            cacheEntryVar.data.getTag VarCond VarImport 1 + [
              tag:;
              tag cacheEntryVar.data.get
              tag stackEntryVar.data.get =
              !result
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
                  r1.hostId r2.hostId = [r1.var r2.var is] && [r1.mutable r2.mutable =] && [r1 staticityOfVar r2 staticityOfVar =] &&
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
] "variablesAreEqualWith" exportFunction

{processor: Processor Cref; cacheEntry: RefToVar Cref; stackEntry: RefToVar Cref;} Cond {} [
  stackEntry: cacheEntry: processor:;;;
  stackEntry cacheEntry Weak FALSE processor variablesAreEqualWith
] "variablesAreEqualForMatching" exportFunction

{processor: Processor Cref; cacheEntry: RefToVar Cref; stackEntry: RefToVar Cref;} Cond {} [
  stackEntry: cacheEntry: processor:;;;
  stackEntry cacheEntry Dynamic TRUE processor variablesAreEqualWith
] "variablesAreEqual" exportFunction

{processor: Processor Cref; currentMatchingNode: Block Cref; refToVar: RefToVar Cref;} Cond {} [
  refToVar: currentMatchingNode: processor:;;;
  refToVar.hostId processor.blocks.at.get currentMatchingNode is ~ [refToVar noMatterToCopy ~] &&
] "variableIsUnused" exportFunction

{processor: Processor Cref; nestedToCur: RefToVarTable Ref; curToNested: RefToVarTable Ref; currentMatchingNode: Block Cref; comparingMessage: String Ref; cacheEntry: RefToVar Cref; stackEntry: RefToVar Cref;} Cond {} [
  stackEntry: cacheEntry: comparingMessage: currentMatchingNode: curToNested: nestedToCur: processor:;;;;;;;
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
        stackEntry cacheEntry processor variablesAreEqualForMatching [TRUE] [
          currentMatchingNode.nodeCompileOnce ["; static values mismatch" @comparingMessage.cat] when
          FALSE
        ] if
      ] && [
        cacheEntry noMatterToCopy ~ [
          cacheEntry stackEntry @nestedToCur.insert
          stackEntry cacheEntry @curToNested.insert
        ] when

        TRUE
      ] &&
    ] if
  ] if
] "compareOnePair" exportFunction

{
  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  block: Block Cref;
  multiParserResult: MultiParserResult Cref;

  comparingMessage: String Ref;
  curToNested: RefToVarTable Ref;
  nestedToCur: RefToVarTable Ref;
  currentMatchingNode: Block Cref;
  cacheEntry: RefToVar Cref;
  stackEntry: RefToVar Cref;
} Cond {convention: cdecl;} [
  multiParserResult: block: processor: processorResult:;;;;
  stackEntry: cacheEntry: currentMatchingNode: nestedToCur: curToNested: comparingMessage:;;;;;;

  failProc: @failProcForProcessor;

  makeWayInfo: [{
    copy currentName:;
    copy current:;
    copy prev:;
  }];

  WayInfo: [
    -1 dynamic -1 dynamic StringView makeWayInfo
  ];

  unfinishedStack: @processor.acquireVarRefArray;
  unfinishedCache: @processor.acquireVarRefArray;
  unfinishedWay: @processor.@unfinishedWay;

  cacheEntry @unfinishedCache.pushBack
  stackEntry @unfinishedStack.pushBack
  WayInfo @unfinishedWay.pushBack

  success: TRUE;

  i: 0 dynamic;
  [
    i unfinishedCache.dataSize < [
      currentFromCache: i unfinishedCache.at copy;
      currentFromStack: i unfinishedStack.at copy;
      currentWay: i unfinishedWay.at copy;

      currentFromCache currentMatchingNode processor variableIsUnused [
        i 1 + !i
      ] [
        currentFromStack currentFromCache @comparingMessage currentMatchingNode @curToNested @nestedToCur processor compareOnePair [ # compare current stack value with initial value of argument
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

              cacheStruct.fields.dataSize stackStruct.fields.dataSize = ~ [
                FALSE !success
              ] [
                j: 0 dynamic;
                [
                  j cacheStruct.fields.dataSize < [
                    cacheFieldNameInfo: j cacheStruct.fields.at.nameInfo;
                    stackFieldNameInfo: j stackStruct.fields.at.nameInfo;

                    cacheFieldNameInfo stackFieldNameInfo = [
                      j currentFromCache block getFieldForMatching @unfinishedCache.pushBack
                      j currentFromStack block getFieldForMatching @unfinishedStack.pushBack
                      i j cacheFieldNameInfo processor.nameInfos.at.name makeStringView makeWayInfo @unfinishedWay.pushBack
                      j 1 + !j
                    ] [
                      FALSE !success
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
            w 0 < ~ [
              curWay:  w unfinishedWay.at;
              curWay.prev unfinishedWay.dataSize < [
                (curWay.current ": " @curWay.@currentName ", " ) @comparingMessage.catMany
                curWay.prev copy !w TRUE
              ] &&
            ] &&
          ] loop

          FALSE !success
        ] if
      ] if

      success copy
    ] &&
  ] loop

  @unfinishedStack @processor.releaseVarRefArray
  @unfinishedCache @processor.releaseVarRefArray
  @unfinishedWay.clear

  success
] "compareEntriesRecImpl" exportFunction

getOverload: [
  cap: block:;;
  overload: cap.nameOverload copy;
  maxOverloadCountCur: cap.nameInfo getOverloadCount;
  maxOverloadCountNes: cap.cntNameOverloadParent copy;
  overload maxOverloadCountCur + maxOverloadCountNes < [
    ("while matching cant call overload for name: " cap.nameInfo processor.nameInfos.at.name) assembleString block compilerError
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

  canMatch: currentMatchingNode.deleted ~ [
    currentMatchingNode.state NodeStateCompiled =
    currentMatchingNode.state NodeStateFailed = or [
      #recursive condition
      currentMatchingNode.nodeIsRecursive
      [currentMatchingNode.recursionState NodeRecursionStateFail = ~] &&
      [
        currentMatchingNode.state NodeStateNew =
        [currentMatchingNode.state NodeStateHasOutput = [currentMatchingNode.recursionState NodeRecursionStateOld =] &&] ||
        [forceRealFunction copy] ||
      ] &&
    ] ||
    [block getStackDepth currentMatchingNode.matchingInfo.inputs.dataSize currentMatchingNode.matchingInfo.preInputs.dataSize + < ~] &&
    [currentMatchingNode.matchingInfo.hasStackUnderflow ~
      [block getStackDepth currentMatchingNode.matchingInfo.inputs.dataSize currentMatchingNode.matchingInfo.preInputs.dataSize + > ~] ||
    ] &&
  ] &&;

  # matching node has 0 inputs and underflow, current node has 0 inputs - TRUE
  # matching node has 0 inputs and underflow, current node has 1 inputs - FALSE
  # matching node has 0 inputs, current node has 0 inputs - TRUE
  # matching node has 0 inputs, current node has 1 inputs - TRUE

  goodReality:
  forceRealFunction ~ [
    currentMatchingNode.nodeCase NodeCaseDeclaration =
    [currentMatchingNode.nodeCase NodeCaseCodeRefDeclaration =] ||
    [currentMatchingNode.nodeCase NodeCaseExport =] ||
    [currentMatchingNode.nodeCase NodeCaseLambda =] ||
  ] ||;

  invisibleName: currentMatchingNode.nodeCase NodeCaseLambda = [currentMatchingNode.varNameInfo 0 < ~] && [
    matchingCapture: Capture;
    currentMatchingNode.refToVar @matchingCapture.@refToVar set
    NameCaseLocal                @matchingCapture.@captureCase set
    gnr: currentMatchingNode.varNameInfo matchingCapture getNameForMatching;
    gnr.refToVar.hostId 0 <
  ] &&;

  canMatch invisibleName ~ and goodReality and [
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
          stackEntry cacheEntry variablesAreSame ~ [
            (", stack type is " stackEntry block getMplType ", cache type is " cacheEntry block getMplType) @s.catMany
          ] [
            stackEntry.mutable cacheEntry.mutable = ~ [
              stackEntry.mutable [", stack is mutable" makeStringView] [", stack is immutable" makeStringView] if @s.cat
              cacheEntry.mutable [", cache is mutable" makeStringView] [", cache is immutable" makeStringView] if @s.cat
            ] [
              comparingMessage @s.cat
            ] if
          ] if
        ] if

        (s) addLog
        s block compilerError
      ] call
    ];

    success: TRUE;
    i: 0 dynamic;
    [
      i currentMatchingNode.matchingInfo.inputs.getSize < [
        stackEntry: i block getStackEntry;
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
          stackEntry: i currentMatchingNode.matchingInfo.inputs.dataSize + block getStackEntry copy;
          cacheEntry: i currentMatchingNode.matchingInfo.preInputs.at;

          cacheEntry.hostId 0 < ~ [stackEntry cacheEntry compareEntriesRec] && [
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
          overload: currentCapture.refToVar.hostId 0 < [-1] [currentCapture @block getOverload] if;
          stackEntry: currentCapture.nameInfo currentCapture overload @block getNameForMatchingWithOverload.refToVar;

          stackEntry.hostId 0 < cacheEntry.hostId 0 < and [
            stackEntry.hostId 0 < ~ cacheEntry.hostId 0 < ~ and [stackEntry cacheEntry compareEntriesRec] &&
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
          overload: currentFieldCapture @block getOverload;
          compilable [
            currentFieldInfo: overload currentFieldCapture.nameInfo processor.nameInfos.at.stack.at.last;
            currentFieldInfo.nameCase currentFieldCapture.captureCase = [currentFieldCapture.object currentFieldInfo.refToVar variablesAreSame] &&
          ] && [
            i 1 + @i set
          ] [
            currentMatchingNode.nodeCompileOnce [
              ("in compiled-once func fieldCapture " currentFieldCapture.nameInfo processor.nameInfos.at.name "\" mismatch") assembleString block compilerError
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

{processorResult: ProcessorResult Ref; processor: Processor Ref; block: Block Ref; multiParserResult: MultiParserResult Cref; forceRealFunction: Cond; indexArrayOfSubNode: IndexArray Cref;} Int32 {convention: cdecl;} [
  processorResult:;
  processor:;
  block:;
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
            currentMatchingNode.uncompilable ["nested node error" block compilerError] when

            FALSE
          ] [
            i 1 + @i set compilable
          ] if
        ] &&
      ] loop

      result
    ];

    result: -1 dynamic;

    block getStackDepth 0 > [
      byType: 0 block getStackEntry getVar.mplSchemaId fr.value.byMplType.find;

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
  FALSE multiParserResult @block @processor @processorResult tryMatchAllNodesWith
];

tryMatchAllNodesForRealFunction: [
  TRUE multiParserResult @block @processor @processorResult tryMatchAllNodesWith
];

fixRecursionStack: [
  i: block.id copy;
  [
    processor.recursiveNodesStack.getSize 0 > [i newNodeIndex = ~] && [
      current: i @processor.@blocks.at.get;
      i processor.recursiveNodesStack.last = [
        NodeRecursionStateNo @current.@recursionState set
        @processor.@recursiveNodesStack.popBack
      ] when

      current.parent @i set
      [i 0 = ~] "NewNodeIndex is not a parent of block.id while fixRecursionStack!" assert
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

    processor.recursiveNodesStack.getSize 0 = [processor.recursiveNodesStack.last newNodeIndex = ~] || [
      newNodeIndex @processor.@recursiveNodesStack.pushBack
    ] when

    NodeStateNoOutput @block.@state set
  ] [
    newNode.state NodeStateNoOutput = [
      NodeStateNoOutput @block.@state set
    ] [
      newNode.recursionState NodeRecursionStateNo > [
        [newNode.nodeIsRecursive copy] "new node must be recursive!" assert
        fixRecursionStack
      ] when

      newNode.recursionState NodeRecursionStateFail > [newNode.state NodeStateHasOutput =] || [NodeStateHasOutput @block.@state set] when
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

    processor.recursiveNodesStack.getSize 0 = [processor.recursiveNodesStack.last newNodeIndex = ~] || [
      newNodeIndex @processor.@recursiveNodesStack.pushBack
    ] when

    NodeStateHasOutput @block.@state set
  ] [
    newNode.state NodeStateNoOutput = [
      NodeStateHasOutput @block.@state set
    ] [
      newNode.recursionState NodeRecursionStateNo > [
        [newNode.nodeIsRecursive copy] "new node must be recursive!" assert
        fixRecursionStack
      ] when

      newNode.recursionState NodeRecursionStateFail > [newNode.state NodeStateHasOutput =] || [NodeStateHasOutput @block.@state set] when
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
  pointeeIsLocal ~ [ # has shadow - captured from top
    fr: pointeeVar.shadowBegin appliedVars.nestedToCur.find;
    fr.success [
      fr.value @fixed set
    ] [
      # dont have prototype - deref of captured dynamic pointer
      pointee @block copyVarFromChild @fixed set
      TRUE dynamic @makeDynamic set
    ] if
  ] [
    # dont have shadow - to deref of captured dynamic pointer
    # must by dynamic
    var.staticity Static = [pointeeVar.storageStaticity Static =] && ["returning pointer to local variable" block compilerError] when
    pointee @block copyVarFromChild @fixed set
    TRUE dynamic @makeDynamic set
  ] if

  fixed.hostId @pointee.@hostId set
  fixed.var @pointee.@var.set

  wasVirtual [refToVar Virtual block makeStaticity @refToVar set] [
    makeDynamic [
      refToVar Dynamic block makeStaticity @refToVar set
    ] when
  ] if
  refToVar
];

applyOnePair: [
  cacheEntry:;
  stackEntry:;

  [
    cacheEntry stackEntry variablesAreSame [TRUE] [
      ("cache type is " makeStringView cacheEntry block getMplType "; stack entry is " makeStringView stackEntry block getMplType) addLog
      FALSE
    ] if
  ] "Applying var has wrong type!" assert
  [cacheEntry noMatterToCopy [cacheEntry.hostId currentChangesNodeIndex =] ||] "Applying unused var!" assert

  cacheEntryVar: cacheEntry getVar;
  stackEntryVar: stackEntry getVar;

  stackEntry cacheEntry staticityOfVar block makeStaticity drop

  cacheEntry noMatterToCopy ~ [cacheEntryVar.shadowEnd getVar.capturedAsMutable copy] && [
    TRUE @stackEntryVar.@capturedAsMutable set
  ] when

  cacheEntry isNonrecursiveType [
    fr: stackEntry @appliedVars.@curToNested.find;
    fr.success [
      fr.value cacheEntry getVar.shadowEnd processor variablesAreEqual ~ [
        "variable changes to incompatible values by two different ways" block compilerError
      ] when
    ] [
      [
        cacheEntry stackEntry processor variablesAreEqualForMatching [
          TRUE
        ] [
          ("match fail, type=" makeStringView cacheEntry block getMplType makeStringView
            "; st=" makeStringView cacheEntry staticityOfVar stackEntry staticityOfVar) addLog
          FALSE
        ] if
      ] "Applying var has wrong value!" assert
      cacheEntry noMatterToCopy ~ [
        [cacheEntryVar.shadowEnd.hostId 0 < ~] "Cache entry has no shadow end!" assert
        stackEntry cacheEntryVar.shadowEnd @appliedVars.@curToNested.insert
        cacheEntry stackEntry @appliedVars.@nestedToCur.insert
      ] when
    ] if
  ] [
    cacheEntryVar.data.getTag VarRef = [
      fr: stackEntry @appliedVars.@curToNested.find;
      fr.success [
        fr.value cacheEntry getVar.shadowEnd processor variablesAreEqual ~ [
          "ref variable changes to incompatible values by two different ways" block compilerError
        ] when
      ] [
        cacheEntry noMatterToCopy ~ [
          [cacheEntryVar.shadowEnd.hostId 0 < ~] "Cache entry has no shadow end!" assert
          stackEntry cacheEntryVar.shadowEnd @appliedVars.@curToNested.insert
          cacheEntry stackEntry @appliedVars.@nestedToCur.insert
        ] when
      ] if
    ] [
      # it may be struct, need add to table anyway for fixing
      cacheEntry noMatterToCopy ~ [
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

  unfinishedStack: @processor.acquireVarRefArray;
  unfinishedCache: @processor.acquireVarRefArray;

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
              cacheFieldRef: j currentFromCache block getFieldForMatching;
              cacheFieldRef.hostId currentChangesNodeIndex = [ # we captured it
                cacheFieldRef @unfinishedCache.pushBack
                j currentFromStack @block getField @unfinishedStack.pushBack
              ] when
              j 1 + @j set TRUE
            ] &&
          ] loop
        ] when
      ] if

      i 1 + @i set compilable
    ] &&
  ] loop

  @unfinishedStack @processor.releaseVarRefArray
  @unfinishedCache @processor.releaseVarRefArray
];

fixOutputRefsRec: [
  stackEntry:;

  unfinishedStack: @processor.acquireVarRefArray;
  stackEntry @unfinishedStack.pushBack

  i: 0 dynamic;
  [
    i unfinishedStack.dataSize < [
      currentFromStack: i @unfinishedStack.at copy;
      stackEntryVar: currentFromStack getVar;

      stackEntryVar.data.getTag VarRef = [
        currentFromStack isSchema ~ [
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

  @unfinishedStack @processor.releaseVarRefArray
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
      fr.success ~ [
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
  currentChangesNodeIndex 0 < ~ [
    currentChangesNode: currentChangesNodeIndex processor.blocks.at.get;

    oldSuccess: @processorResult move copy;
    -1 @processorResult clearProcessorResult

    i: 0 dynamic;
    [
      i currentChangesNode.matchingInfo.captures.dataSize < [
        currentCapture: i currentChangesNode.matchingInfo.captures.at;
        cacheEntry: currentCapture.refToVar;
        overload: currentCapture.refToVar.hostId 0 < [-1] [currentCapture @block getOverload] if;
        gnr: currentCapture.nameInfo currentCapture overload @block getNameForMatchingWithOverload;
        gnr.refToVar.hostId 0 < [
          # it is failed capture
        ] [
          stackEntry: gnr @block captureName.refToVar;

          unfinishedStack: @processor.acquireVarRefArray;
          unfinishedCache: @processor.acquireVarRefArray;
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
                      cacheFieldRef: j currentFromCache block getFieldForMatching;
                      cacheFieldRef.hostId currentChangesNodeIndex = [ # we captured it
                        cacheFieldRef @unfinishedCache.pushBack
                        j currentFromStack @block getField @unfinishedStack.pushBack
                      ] when
                      j 1 + @j set compilable
                    ] &&
                  ] loop
                ] when
              ] if

              i2 1 + @i2 set compilable
            ] &&
          ] loop

          @unfinishedStack @processor.releaseVarRefArray
          @unfinishedCache @processor.releaseVarRefArray
        ] if

        i 1 + @i set compilable
      ] &&
    ] loop

    i: 0 dynamic;
    [
      i currentChangesNode.matchingInfo.fieldCaptures.dataSize < [
        currentFieldCapture: i currentChangesNode.matchingInfo.fieldCaptures.at;
        overload: currentFieldCapture @block getOverload;
        fieldCnr: currentFieldCapture.nameInfo overload getNameWithOverload @block captureName;
        i 1 + @i set compilable
      ] &&
    ] loop

    exitPre ~ [
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
  newCapture @block.@matchingInfo.@captures.pushBack
  block.state NodeStateNew = [
    newCapture @block.@buildingMatchingInfo.@captures.pushBack
  ] when
];

applyNodeChanges: [
  compileOnce
  copy currentChangesNodeIndex:;
  currentChangesNode: currentChangesNodeIndex processor.blocks.at.get;

  [block getStackDepth currentChangesNode.matchingInfo.inputs.dataSize < ~] "Stack underflow!" assert

  appliedVars: {
    curToNested: RefToVarTable;
    nestedToCur: RefToVarTable;
    fixedOutputs: @processor.acquireVarRefArray;
  };

  pops: @processor.acquireVarRefArray;

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
      pops.dataSize i - 1 - pops.at @block push
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
        overload: currentCapture @block getOverload;
        stackEntry: currentCapture.nameInfo currentCapture overload @block getNameForMatchingWithOverload @block captureName.refToVar;
        stackEntry cacheEntry applyEntriesRec
      ] if

      i 1 + @i set compilable
    ] &&
  ] loop

  i: 0 dynamic;
  [
    i currentChangesNode.matchingInfo.fieldCaptures.dataSize < [
      currentFieldCapture: i currentChangesNode.matchingInfo.fieldCaptures.at;

      overload: currentFieldCapture @block getOverload;
      fieldCnr: currentFieldCapture.nameInfo overload getNameWithOverload @block captureName;

      i 1 + @i set compilable
    ] &&
  ] loop

  i: 0 dynamic;
  [
    i currentChangesNode.outputs.dataSize < [
      currentOutput: i currentChangesNode.outputs.at;
      outputRef: currentOutput.refToVar @block copyVarFromChild; # output is to inner var
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
      nestedCopy: pair.value @block copyOneVar;
      pair.value isGlobal [
        pVar: pair.value getVar;
        nVar: nestedCopy getVar;
        pVar.globalId @nVar.@globalId set
      ] when
      nestedCopy fixCaptureRef @pair.@value set
    ] when
  ] each

  @pops @processor.releaseVarRefArray

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
  newNodeIndex 0 < ~ [
    newNode: newNodeIndex processor.blocks.at.get;

    newMinStackDepth: block getStackDepth newNode.matchingInfo.inputs.dataSize - newNode.matchingInfo.preInputs.dataSize -;
    newMinStackDepth block.minStackDepth < [
      newMinStackDepth @block.@minStackDepth set
    ] when

    exitPre ~ [
      newNode.matchingInfo.hasStackUnderflow [
        @block addStackUnderflowInfo
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
  implicitDerefInfo: count: block:;;;
  i: 0 dynamic;
  [
    i count < [
      count 1 - i - implicitDerefInfo.at [
        dst: i @block getStackEntry;
        dst @block getPossiblePointee @dst set
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

  inputs: @processor.acquireVarRefArray;
  outputs: @processor.acquireVarRefArray;

  i: 0 dynamic;
  [
    i newNode.matchingInfo.inputs.dataSize < [
      @block pop @inputs.pushBack
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
        outputRef @block.@candidatesToDie.pushBack
      ] when
      outputRef @block push
      i 1 + @i set TRUE
    ] &&
  ] loop

  compilable [
    inputs outputs newNode forcedName makeNamedCallInstruction

    implicitDerefInfo: @processor.@condArray;
    newNode.outputs [.argCase isImplicitDeref @implicitDerefInfo.pushBack] each
    implicitDerefInfo appliedVars.fixedOutputs.getSize @block derefNEntries
    @implicitDerefInfo.clear
  ] when

  @inputs @processor.releaseVarRefArray
  @outputs @processor.releaseVarRefArray
];

applyStackChanges: [
  forcedName: StringView dynamic;
  forcedName applyNamedStackChanges
];

makeCallInstructionWith: [
  block:;
  copy dynamicFunc:;
  refToVar:;
  forcedName:;
  newNode:;
  outputs:;
  inputs:;
  argRet: RefToVar;
  argList: @processor.@irArgumentArray;

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
        currentInputArgCase ArgCopy = [currentInput @block createDerefToRegister @arg.@irNameId set] when

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
          outputRef @block createAllocIR r:;
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

      currentCapture.refToVar.hostId 0 < ~ [
        currentCapture.argCase ArgRef = [
          overload: currentCapture block getOverload;
          refToVar: currentCapture.nameInfo currentCapture overload @block getNameForMatchingWithOverload @block captureName.refToVar;
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

  newNode.empty ~ [
    pureFuncName: forcedName "" = [dynamicFunc [refToVar getIrName][newNode.irName makeStringView] if][forcedName copy] if;
    funcName: newNode.variadic [("(" newNode.argTypes ") " pureFuncName) assembleString][pureFuncName toString] if;
    convName: newNode.convention;
    retName: argRet argList convName funcName @block createCallIR;

    argRet.var isNil ~ [
      @retName argRet @block createStoreFromRegister
    ] when
  ] when

  @argList.clear
];

makeNamedCallInstruction: [
  r: RefToVar;
  r FALSE dynamic @block makeCallInstructionWith
];

makeCallInstruction: [
  r: RefToVar;
  forcedName: StringView;
  forcedName r FALSE dynamic @block makeCallInstructionWith
];

processNamedCallByNode: [
  forcedName:;
  copy newNodeIndex:;
  newNode: newNodeIndex processor.blocks.at.get;
  compileOnce

  newNodeIndex changeNewNodeState
  newNode.state NodeStateNoOutput = ~ [
    appliedVars: newNodeIndex applyNodeChanges;

    appliedVars.curToNested [
      pair:;
      pair.value pair.key changeVarValue
    ] each

    newNode newNodeIndex @appliedVars forcedName applyNamedStackChanges

    @appliedVars.@fixedOutputs @processor.releaseVarRefArray
  ] when
];

processCallByNode: [
  forcedName: StringView dynamic;
  forcedName processNamedCallByNode
];

{processorResult: ProcessorResult Ref; processor: Processor Ref; block: Block Ref; multiParserResult: MultiParserResult Cref;
  positionInfo: CompilerPositionInfo Cref; name: StringView Cref; nodeCase: NodeCaseCode; file: File Cref; indexArray: IndexArray Cref;} () {convention: cdecl;} [
  processorResult:;
  processor:;
  block:;
  multiParserResult:;
  positionInfo:;
  name:;
  copy nodeCase:;
  file:;
  indexArray:;
  failProc: @failProcForProcessor;
  compileOnce

  forcedNameString: String;

  newNodeIndex: indexArray tryMatchAllNodes;
  newNodeIndex 0 < [compilable] && [
    name
    block.id
    nodeCase
    @processorResult
    @processor
    indexArray
    file
    multiParserResult
    positionInfo
    CFunctionSignature
    astNodeToCodeNode @newNodeIndex set
  ] when

  compilable [
    newNode: newNodeIndex @processor.@blocks.at.get;
    block.parent 0 = [nodeCase NodeCaseList = nodeCase NodeCaseObject = or] && [newNode.matchingInfo.inputs.getSize 0 =] && [newNode.outputs.getSize 1 =] && [
      realCapturesCount: 0;
      newNode.matchingInfo.captures [
        capture:;
        capture.refToVar.hostId 0 < ~ [
          capture.refToVar isVirtual ~ [realCapturesCount 1 + @realCapturesCount set] when
        ] when
      ] each

      realCapturesCount 0 =
    ] && [
      0 newNode.outputs.at.refToVar isStaticData
    ] && [
      result: 0 newNode.outputs.at.refToVar @block copyVarFromChild;
      TRUE @newNode.@deleted set
      result @block createStaticInitIR @block push
    ] [
      forcedName: forcedNameString makeStringView;
      newNodeIndex forcedName processNamedCallByNode
    ] if
  ] [
    newNodeIndex usePreInputs
    newNodeIndex usePreCaptures
  ] if
] "processCallByIndexArrayImpl" exportFunction

{processorResult: ProcessorResult Ref; processor: Processor Ref; block: Block Ref; multiParserResult: MultiParserResult Cref; name: StringView Cref; file: File Cref; callAstNodeIndex: Int32;} () {convention: cdecl;} [
  processorResult:;
  processor:;
  block:;
  multiParserResult:;
  name:;
  file:;
  callAstNodeIndex:;
  failProc: @failProcForProcessor;

  astNode: callAstNodeIndex @multiParserResult.@memory.at;

  positionInfo: astNode file makeCompilerPosition;

  indexArray: Int32 Array Cref;
  nodeCase: Nat8;
  (
    AstNodeType.Code   [!indexArray NodeCaseCode   !nodeCase]
    AstNodeType.List   [!indexArray NodeCaseList   !nodeCase]
    AstNodeType.Object [!indexArray NodeCaseObject !nodeCase]
  ) astNode.data.visit

  indexArray file nodeCase dynamic name positionInfo processCallByIndexArray
] "processCallImpl" exportFunction

{processorResult: ProcessorResult Ref; processor: Processor Ref; block: Block Ref; multiParserResult: MultiParserResult Cref; file: File Cref; preAstNodeIndex: Int32;} Cond {convention: cdecl;} [
  processorResult:;
  processor:;
  block:;
  multiParserResult:;
  file:;
  preAstNodeIndex:;
  failProc: @failProcForProcessor;

  compilable [
    astNode: preAstNodeIndex @multiParserResult.@memory.at;
    positionInfo: astNode file makeCompilerPosition;
    indexArray: AstNodeType.Code @astNode.@data.get;

    oldSuccess: compilable;
    oldGlobalErrorCount: processorResult.globalErrorInfo.getSize;

    newNodeIndex: indexArray tryMatchAllNodes;
    newNodeIndex 0 < [compilable] && [
      processor.depthOfPre 1 + @processor.@depthOfPre set
      "PRE" makeStringView block.id NodeCaseCode @processorResult @processor indexArray file multiParserResult positionInfo CFunctionSignature astNodeToCodeNode @newNodeIndex set
      processor.depthOfPre 1 - @processor.@depthOfPre set
    ] when

    oldGlobalErrorCount @processorResult.@globalErrorInfo.shrink
    oldSuccess [
      processorResult.passErrorThroughPRE ~ [-1 @processorResult clearProcessorResult] when
    ] [
      [FALSE] "Has compilerError before trying compiling pre!" assert
    ] if

    newNode: newNodeIndex processor.blocks.at.get;
    newNodeIndex TRUE dynamic usePreInputsWith
    newNodeIndex TRUE dynamic usePreCapturesWith

    newNode.matchingInfo.hasStackUnderflow [
      block.minStackDepth 1 - @block.@minStackDepth set
    ] when

    newNode.matchingInfo.unfoundedNames [
      .key copy addFailedCapture
    ] each

    newNode.uncompilable ~
    [newNode.outputs.dataSize 0 >] &&
    [
      top: newNode.outputs.last.refToVar;
      top getVar.data.getTag VarCond =
      [top staticityOfVar Weak < ~] && [
        VarCond top getVar.data.get copy
      ] [
        TRUE dynamic @processorResult.@passErrorThroughPRE set
        "PRE code must fail or return static Cond" block compilerError
        FALSE dynamic
      ] if
    ] &&
  ] [
    FALSE dynamic
  ] if
] "processPreImpl" exportFunction

processIf: [
  fileElse:;
  astNodeElse:;
  fileThen:;
  astNodeThen:;
  refToCond:;

  indexArrayElse: AstNodeType.Code astNodeElse.data.get;
  indexArrayThen: AstNodeType.Code astNodeThen.data.get;

  positionInfoThen: astNodeThen fileThen makeCompilerPosition;
  positionInfoElse: astNodeElse fileElse makeCompilerPosition;

  newNodeThenIndex: @indexArrayThen tryMatchAllNodes;
  newNodeThenIndex 0 < [compilable] && [
    "ifThen" makeStringView
    block.id
    NodeCaseCode
    @processorResult
    @processor
    indexArrayThen
    fileThen
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
      block.id
      NodeCaseCode
      @processorResult
      @processor
      indexArrayElse
      fileElse
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
          NodeStateNoOutput @block.@state set
        ] [
          newNodeThen.state NodeStateHasOutput < [
            newNodeElseIndex processCallByNode
          ] [
            newNodeThenIndex processCallByNode
          ] if

          NodeStateHasOutput @block.@state set
        ] if
      ] [
        newNodeThen.state NodeStateHasOutput = [newNodeElse.state NodeStateHasOutput =] || [NodeStateHasOutput @block.@state set] when

        appliedVarsThen: newNodeThenIndex applyNodeChanges;
        appliedVarsElse: newNodeElseIndex applyNodeChanges;

        stackDepth: block getStackDepth;
        newNodeThen.matchingInfo.inputs.dataSize stackDepth > ["then branch stack underflow" block compilerError] when
        newNodeElse.matchingInfo.inputs.dataSize stackDepth > ["else branch stack underflow" block compilerError] when
        stackDepth newNodeThen.matchingInfo.inputs.dataSize - newNodeThen.outputs.dataSize +
        stackDepth newNodeElse.matchingInfo.inputs.dataSize - newNodeElse.outputs.dataSize + = ~ ["if branches stack size mismatch" block compilerError] when

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
              longestInputSize index - 1 - block getStackEntry copy
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
              value1 value2 processor variablesAreEqual [ # both are static, same value
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

            unfinishedV1: @processor.acquireVarRefArray;
            unfinishedV2: @processor.acquireVarRefArray;
            unfinishedD:  @processor.acquireVarRefArray;

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

            @unfinishedV1 @processor.releaseVarRefArray
            @unfinishedV2 @processor.releaseVarRefArray
            @unfinishedD  @processor.releaseVarRefArray
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
          inputsThen:  @processor.acquireVarRefArray;
          inputsElse:  @processor.acquireVarRefArray;
          outputsThen: @processor.acquireVarRefArray;
          outputsElse: @processor.acquireVarRefArray;
          inputs:      @processor.acquireVarRefArray;
          outputs:     @processor.acquireVarRefArray;

          implicitDerefInfo: @processor.@condArray;

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
                  i newNodeThen.outputs.dataSize + longestOutputSize < ~ [newOutput @outputsThen.pushBack] when
                  i newNodeElse.outputs.dataSize + longestOutputSize < ~ [newOutput @outputsElse.pushBack] when
                  newOutput @block createAllocIR @outputs.pushBack
                ] [
                  ("branch types mismatch; in 'then' type is " outputThen block getMplType "; in 'else' type is " outputElse block getMplType) assembleString block compilerError
                ] if

                isOutputImplicitDerefThen @implicitDerefInfo.pushBack
              ] [
                "branch return cases mismatch" block compilerError
              ] if

              i 1 + @i set compilable
            ] &&
          ] loop

          compilable [
            i: 0 dynamic;
            [
              i longestInputSize < [
                a: @block pop;
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
                  outputRef @block.@candidatesToDie.pushBack
                ] when

                outputRef @block push
                i 1 + @i set TRUE
              ] &&
            ] loop

            compilable [
              # create instruction
              #1 prolog, allocate common vars

              createStores: [
                compiledOutputs:;
                branch:;

                i: 0 dynamic;
                [
                  i longestOutputSize < [
                    current: i branch compiledOutputs getCompiledOutput;
                    curInput: i branch compiledOutputs getCompiledInput;

                    current.var curInput.var is ~ [
                      curInput isVirtual ~ ["variable states in branches mismatch" block compilerError] when
                      FALSE curInput getVar.@temporary set
                      curInput current @block createCheckedCopyToNewNoDie
                    ] when

                    i 1 + @i set TRUE
                  ] &&
                ] loop
              ];

              wasNestedCall: block.hasNestedCall copy;
              0 refToCond @block createBranch
              @block createLabel
              inputsThen outputsThen newNodeThen makeCallInstruction
              newNodeThen outputsThen createStores
              0 @block createJump
              @block createLabel
              wasNestedCall @block.@hasNestedCall set
              inputsElse outputsElse newNodeElse makeCallInstruction
              newNodeElse outputsElse createStores
              1 @block createJump
              @block createLabel
              implicitDerefInfo longestOutputSize @block derefNEntries
              processor.options.verboseIR ["create phi nodes..." @block createComment] when
              processor.options.verboseIR ["end if" @block createComment] when
            ] when
          ] when

          @inputsThen  @processor.releaseVarRefArray
          @inputsElse  @processor.releaseVarRefArray
          @outputsThen @processor.releaseVarRefArray
          @outputsElse @processor.releaseVarRefArray
          @inputs      @processor.releaseVarRefArray
          @outputs     @processor.releaseVarRefArray

          @implicitDerefInfo.clear
        ] when

        @appliedVarsThen.@fixedOutputs @processor.releaseVarRefArray
        @appliedVarsElse.@fixedOutputs @processor.releaseVarRefArray
      ] if
    ] when
  ] when

];

processLoop: [
  astNode: file:;;
  indexArray: AstNodeType.Code astNode.data.get;
  positionInfo: astNode file makeCompilerPosition;

  iterationNumber: 0 dynamic;
  loopIsDynamic: FALSE;

  [
    newNodeIndex: @indexArray tryMatchAllNodes;
    newNodeIndex 0 < [compilable] && [
      "loop" makeStringView
      block.id
      NodeCaseCode
      @processorResult
      @processor
      indexArray
      file
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
        newNode.state NodeStateHasOutput = [NodeStateHasOutput @block.@state set] when
        appliedVars: newNodeIndex applyNodeChanges;

        appliedVars.fixedOutputs.getSize 0 = ["loop body must return Cond" block compilerError] when
        compilable [
          condition: newNode.outputs.last.refToVar;
          condVar: condition getVar;
          condVar.data.getTag VarCond = ~ ["loop body must return Cond" block compilerError] when

          compilable [
            condition staticityOfVar Weak > [
              appliedVars.curToNested [
                pair:;
                pair.value pair.key changeVarValue
              ] each

              newNode newNodeIndex @appliedVars applyStackChanges
              a: @block pop;
              VarCond a getVar.data.get copy
            ] [
              TRUE dynamic @loopIsDynamic set
              FALSE
            ] if
          ] &&
        ] &&

        @appliedVars.@fixedOutputs @processor.releaseVarRefArray
      ] if
    ] &&

    iterationNumber 1 + @iterationNumber set
    iterationNumber processor.options.staticLoopLengthLimit > [
      TRUE @processorResult.!passErrorThroughPRE
      ("Static loop length limit (" processor.options.staticLoopLengthLimit ") exceeded. Dynamize loop or increase limit using -static_loop_lenght_limit option") assembleString block compilerError
    ] when

    compilable and
  ] loop

  loopIsDynamic [indexArray file processDynamicLoop] when
];

processDynamicLoop: [
  indexArray: file:;;

  iterationNumber: 0 dynamic;
  [
    needToRemake: FALSE dynamic;
    newNodeIndex: @indexArray tryMatchAllNodes;
    newNodeIndex 0 < [compilable] && [
      "dynamicLoop" makeStringView
      block.id
      NodeCaseCode
      @processorResult
      @processor
      indexArray
      file
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
        newNode.state NodeStateHasOutput = [NodeStateHasOutput @block.@state set] when

        appliedVars: newNodeIndex applyNodeChanges;

        checkToRecompile: [
          dst:;
          src:;

          result: FALSE dynamic;
          src dst variablesAreSame [
            src staticityOfVar Weak >
            [src dst processor variablesAreEqual ~] && [
              TRUE @result set
            ] when
          ] [
            "loop body changes stack types" block compilerError
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

        newNode.outputs.dataSize newNode.matchingInfo.inputs.dataSize 1 + = ~ ["loop body must save stack values and return Cond" block compilerError] when
        compilable [
          condition: newNode.outputs.last.refToVar;
          condVar: condition getVar;
          condVar.data.getTag VarCond = ~ ["loop body must return Cond" block compilerError] when

          i: 0 dynamic;
          [
            i newNode.matchingInfo.inputs.dataSize < [
              curInput: i block getStackEntry;
              curOutput: newNode.matchingInfo.inputs.dataSize 1 - i - newNode.outputs.at .refToVar;
              curInput curOutput checkToRecompile [
                curInput makeVarTreeDynamic
                TRUE dynamic @needToRemake set
              ] when
              i 1 + @i set TRUE
            ] &&
          ] loop
        ] when

        needToRemake ~ compilable and [
          inputs:     @processor.acquireVarRefArray;
          nodeInputs: @processor.acquireVarRefArray;
          outputs:    @processor.acquireVarRefArray;

          # apply stack changes
          i: 0 dynamic;
          [
            i newNode.matchingInfo.inputs.dataSize < [
              @block pop @inputs.pushBack
              i 1 + @i set TRUE
            ] &&
          ] loop

          i: 0 dynamic;
          [
            i appliedVars.fixedOutputs.getSize < [
              curOutput: i appliedVars.fixedOutputs.at;
              curOutput @outputs.pushBack
              curOutput getVar.data.getTag VarStruct = [
                curOutput @block.@candidatesToDie.pushBack
              ] when

              i 1 + newNode.outputs.dataSize < [
                curOutput @block push
              ] when
              i 1 + @i set TRUE
            ] &&
          ] loop

          createPhiNodes: [
            i: 0 dynamic;
            [
              i inputs.getSize < [
                curNodeInput: i inputs.at @block copyVar;
                curNodeInput @nodeInputs.pushBack

                (curNodeInput getIrType "*") assembleString makeStringView # with *
                curNodeInput getIrName
                i inputs.at getIrName
                inputs.dataSize 1 - i - outputs.at getIrName
                1 @block createPhiNode

                i 1 + @i set TRUE
              ] &&
            ] loop
          ];

          # create instruction
          processor.options.verboseIR ["loop prepare..." @block createComment] when
          1 @block createJump
          @block createLabel
          createPhiNodes # for each input-output!
          processor.options.verboseIR ["phi nodes prepared" @block createComment] when
          nodeInputs outputs newNode makeCallInstruction

          implicitDerefInfo: @processor.@condArray;
          newNode.outputs [.argCase isImplicitDeref @implicitDerefInfo.pushBack] each
          implicitDerefInfo outputs.getSize 1 - @block derefNEntries
          processor.options.verboseIR ["loop end prepare..." @block createComment] when
          1 outputs.last @block createBranch
          @block createLabel

          @inputs     @processor.releaseVarRefArray
          @nodeInputs @processor.releaseVarRefArray
          @outputs    @processor.releaseVarRefArray

          @implicitDerefInfo.clear
        ] when

        needToRemake [
          newNodeIndex processor.blocks.at.get.nodeCompileOnce [
            "loop body compileOnce directive fail" block compilerError
          ] when

          newNodeIndex deleteNode

          iterationNumber processor.options.staticLoopLengthLimit > [
            "loop dynamisation iteration count so big" block compilerError
          ] when
        ] when

        iterationNumber 1 + @iterationNumber set

        needToRemake compilable and

        @appliedVars.@fixedOutputs @processor.releaseVarRefArray
      ] if
    ] &&
  ] loop
];

{processorResult: ProcessorResult Ref; processor: Processor Ref; block: Block Ref; multiParserResult: MultiParserResult Cref;
  asLambda: Cond; name: StringView Cref; file: File Cref; astNode: AstNode Cref; signature: CFunctionSignature Cref;} Int32 {convention: cdecl;} [
  processorResult:;
  processor:;
  block:;
  multiParserResult:;
  copy asLambda:;
  name:;
  file:;
  astNode:;
  signature:;
  failProc: @failProcForProcessor;

  indexArray: AstNodeType.Code astNode.data.get;
  positionInfo: astNode file makeCompilerPosition;
  compileOnce

  signature.variadic [
    "export function cannot be variadic" block compilerError
  ] when

  ("process export: " makeStringView name makeStringView) addLog

  # we dont know count of used in export entites
  signature.inputs.getSize [
    r: signature.inputs.getSize 1 - i - signature.inputs.at @block copyVarFromChild;
    r makeVarTreeDynamic
    r block unglobalize
    r fullUntemporize
    r getVar.data.getTag VarRef = [
      r getPointeeNoDerefIR @block push
    ] [
      FALSE @r.@mutable set
      r @block push
    ] if
  ] times

  oldSuccess: compilable;
  oldRecursiveNodesStackSize: processor.recursiveNodesStack.getSize;

  newNodeIndex: @indexArray tryMatchAllNodesForRealFunction;
  newNodeIndex 0 < [compilable] && [
    nodeCase: asLambda [NodeCaseLambda][NodeCaseExport] if;
    processor.exportDepth 1 + @processor.@exportDepth set
    name block.id nodeCase @processorResult @processor indexArray file multiParserResult positionInfo signature astNodeToCodeNode @newNodeIndex set
    processor.exportDepth 1 - @processor.@exportDepth set
  ] when

  newNodeIndex usePreCaptures

  compilable [
    newNodeIndex changeNewExportNodeState

    newNode: newNodeIndex processor.blocks.at.get;
    newNode.outputs.getSize 1 > ["export function cant have 2 or more outputs" block compilerError] when
    newNode.outputs.getSize 1 = [signature.outputs.getSize 0 =] && ["signature is void, export function must be without output" block compilerError] when
    newNode.outputs.getSize 0 = [signature.outputs.getSize 1 =] && ["signature is not void, export function must have output" block compilerError] when
    newNode.state NodeStateCompiled = ~ [
      "can not implement lambda inside itself body" block compilerError
      FALSE @oldSuccess set
    ] when

    compilable [
      newNode.captureNames [
        currentCaptureName:;
        currentCaptureName.startPoint block.id = ~ [
          fr: currentCaptureName.startPoint @block.@usedModulesTable.find;
          fr.success [TRUE @fr.@value.@used set] when
        ] when
      ] each

      signature.outputs.getSize [
        currentInNode: i newNode.outputs.at.refToVar;
        currentInSignature: i signature.outputs @;

        currentInNode currentInSignature variablesAreSame ~ [
          ("export function output mismatch, expected " currentInSignature block getMplType ";" LF
            "but found " currentInNode block getMplType) assembleString block compilerError
        ] when
      ] times
    ] when
  ] when

  signature.inputs [p:; a: @block pop;] each

  oldSuccess compilable ~ and processor.depthOfPre 0 = and [
    @processorResult.@errorInfo move @processorResult.@globalErrorInfo.pushBack
    oldRecursiveNodesStackSize @processor.@recursiveNodesStack.shrink
    -1 @processorResult clearProcessorResult

    signature name FALSE dynamic processImportFunction Block addressToReference .id copy !newNodeIndex
  ] when

  ("processed export: " makeStringView name makeStringView) addLog

  newNodeIndex
] "processExportFunctionImpl" exportFunction

{processorResult: ProcessorResult Ref; processor: Processor Ref; block: Block Ref; multiParserResult: MultiParserResult Cref;
  asCodeRef: Cond; name: StringView Cref; signature: CFunctionSignature Cref;} Natx {convention: cdecl;} [
  processorResult:;
  processor:;
  block:;
  multiParserResult:;
  failProc: @failProcForProcessor;

  copy asCodeRef:;
  name:;
  signature:;
  compileOnce

  addBlock
  declarationNode: @processor.@blocks.last.get;
  block.id @declarationNode.@parent set
  asCodeRef [NodeCaseCodeRefDeclaration][NodeCaseDeclaration] if @declarationNode.@nodeCase set
  signature.variadic @declarationNode.@variadic set

  signature.inputs.getSize [
    r: signature.inputs.getSize 1 - i - signature.inputs.at @block copyVarFromChild;
    r block unglobalize
    FALSE @r.@mutable set
    r @block push
  ] times

  [
    curPosition: block.position;
    block: @declarationNode;
    curPosition @block.@position set
    position: curPosition copy;
    compilerPositionInfo: position;
    forcedSignature: signature;
    processor.options.debug [
      addDebugReserve @block.@funcDbgIndex set
    ] when
    forcedSignature.inputs   [p:; a: @block pop;] each
    forcedSignature.outputs [@block copyVarFromChild @block push] each
    name finalizeCodeNode
  ] call

  signature.inputs   [p:; a: @block pop;] each
  declarationNode storageAddress
] "processImportFunctionImpl" exportFunction

callImportWith: [
  declarationNode: refToVar: dynamicFunc: block:;;;;
  inputs:  @processor.acquireVarRefArray;
  outputs: @processor.acquireVarRefArray;
  (
    [compilable]
    [
      i: 0 dynamic;
      [
        i declarationNode.matchingInfo.inputs.dataSize < [
          (
            [compilable]
            [stackEntry: @block pop;]
            [
              input: stackEntry copy;
              input makeVarRealCaptured
              nodeEntry: i declarationNode.matchingInfo.inputs.at.refToVar;
              nodeMutable: nodeEntry.mutable copy;
              i declarationNode.csignature.inputs.at getVar.data.getTag VarRef = [
                TRUE stackEntry getVar.@capturedAsMutable set
              ] when

              stackEntry nodeEntry variablesAreSame ~ [
                lambdaCastResult: input nodeEntry @block tryImplicitLambdaCast;
                lambdaCastResult.success [
                  lambdaCastResult.refToVar @input set
                ] [
                  ("cant call import, variable types of argument #" i " are incorrect, expected " nodeEntry block getMplType ";" LF "but found " stackEntry block getMplType) assembleString block compilerError
                ] if
              ] when
            ] [
              stackEntry.mutable ~ nodeMutable and [
                ("cant call import, expected mutable argument #" i " with type " nodeEntry block getMplType) assembleString block compilerError
              ] when
            ] [
              nodeMutable [stackEntry @block makeVarTreeDirty] when
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
          [refToVarargs: @block pop;]
          [
            varargs: refToVarargs getVar;
            varargs.data.getTag VarStruct = ~ ["varargs must be a struct" block compilerError] when
          ] [
            varStruct: VarStruct varargs.data.get.get;
            varStruct.fields.getSize [
              field: i refToVarargs @block processStaticAt;
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
          current: currentOutput @block copyVarFromChild;
          Dynamic current getVar.@staticity set
          current @outputs.pushBack
          current getVar.data.getTag VarStruct = [
            current @block.@candidatesToDie.pushBack
          ] when

          i 1 + @i set compilable
        ] &&
      ] loop
    ] [
      forcedName: StringView;
      inputs outputs declarationNode forcedName refToVar dynamicFunc @block makeCallInstructionWith
      i: 0 dynamic;
      [
        i outputs.getSize < [
          currentOutput: i outputs.at;
          currentOutput @block push
          i 1 + @i set compilable
        ] &&
      ] loop
    ] [
      implicitDerefInfo: @processor.@condArray;
      outputs [
        getVar.data.getTag VarRef = @implicitDerefInfo.pushBack
      ] each

      implicitDerefInfo outputs.getSize @block derefNEntries
      @implicitDerefInfo.clear
    ]
  ) sequence

  @inputs  @processor.releaseVarRefArray
  @outputs @processor.releaseVarRefArray
];

{processorResult: ProcessorResult Ref; processor: Processor Ref; block: Block Ref; multiParserResult: MultiParserResult Cref;
  refToVar: RefToVar Cref;} () {convention: cdecl;} [
  processorResult:;
  processor:;
  block:;
  multiParserResult:;
  failProc: @failProcForProcessor;

  refToVar:;
  var: refToVar getVar;
  protoIndex: VarImport var.data.get copy;
  node: protoIndex @processor.@blocks.at.get;
  [
    node.nextRecLambdaId 0 < ~ [
      node.nextRecLambdaId @protoIndex set
      protoIndex @processor.@blocks.at.get !node
      TRUE
    ] &&
  ] loop

  dynamicFunc: refToVar staticityOfVar Dynamic > ~;
  dynamicFunc ~ [
    node.nodeCase NodeCaseCodeRefDeclaration = [
      "nullpointer call" block compilerError
    ] when
  ] when

  @node refToVar dynamicFunc @block callImportWith
] "processFuncPtrImpl" exportFunction
