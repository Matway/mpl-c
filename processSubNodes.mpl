"processSubNodes" module

"control" useModule
"codeNode" includeModule

clearProcessorResult: [
  copy cachedGlobalErrorInfoSize:;
  TRUE dynamic              @processorResult.@success set
  FALSE dynamic             @processorResult.@findModuleFail set
  FALSE dynamic             @processorResult.@maxDepthExceeded set
  String                    @processorResult.@program set
  ProcessorErrorInfo        @processorResult.@errorInfo set
  cachedGlobalErrorInfoSize 0 < not [
    cachedGlobalErrorInfoSize @processorResult.@globalErrorInfo.shrink
  ] when
] func;

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
] func;

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
      cacheStaticness: cacheEntry staticnessOfVar;
      stackStaticness: stackEntry staticnessOfVar;

      cacheStaticness Weak > not stackStaticness stackDynamicBorder > not and [ # both dynamic
        cacheStaticness Weak > stackStaticness stackDynamicBorder > and [ # both static
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
                checkRefs [cacheEntryVar.data.getTag VarRef =] && [cacheEntry staticnessOfVar Virtual <] && [
                  r1: VarRef cacheEntryVar.data.get;
                  r2: VarRef stackEntryVar.data.get;
                  r1.hostId r2.hostId = [r1.varId r2.varId =] && [r1.mutable r2.mutable =] && [r1 staticnessOfVar r2 staticnessOfVar =] &&
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
] func;

variablesAreEqualForMatching: [
  Weak FALSE dynamic variablesAreEqualWith
] func;

variablesAreEqual: [
  Dynamic TRUE dynamic variablesAreEqualWith
] func;

variableIsUnused: [
  refToVar:;
  #refToVar variableIsDeleted [
  refToVar.hostId currentMatchingNodeIndex = not [refToVar noMatterToCopy not] &&
  #] ||
  #] ||
] func;

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

] func;

{
  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  indexOfNode: Int32;
  currentNode: CodeNode Ref;
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
  copy indexOfNode:;
  currentNode:;
  multiParserResult:;
  failProc: @failProcForProcessor;

  comparingMessage:;
  curToNested:;
  nestedToCur:;
  currentMatchingNodeIndex:;
  cacheEntry:;
  stackEntry:;

  currentMatchingNode: currentMatchingNodeIndex processor.nodes.at.get;

  makeWayInfo: [{
    copy currentName:;
    copy current:;
    copy prev:;
  }] func;

  WayInfo: [
    -1 dynamic -1 dynamic StringView makeWayInfo
  ] func;

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
          cacheEntryVar.data.getTag VarRef = [currentFromCache staticnessOfVar Virtual <] && [currentFromCache staticnessOfVar Weak >] && [

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
  maxOverloadCountNes: cap.cntNameOverload copy;
  overload maxOverloadCountCur + maxOverloadCountNes < [
    ("While matching cant call overload for name: " cap.nameInfo processor.nameInfos.at.name) assembleString compilerError
    0
  ] [
    overload maxOverloadCountCur + maxOverloadCountNes -
  ] if
] func;

tryMatchNode: [
  currentMatchingNode:;

  curToNested: RefToVarTable;
  nestedToCur: RefToVarTable;
  comparingMessage: String;

  canMatch: currentMatchingNode.deleted not [
    currentMatchingNode.state NodeStateCompiled = [
      #recursive condition
      currentMatchingNode.nodeIsRecursive
      [currentMatchingNode.recursionState NodeRecursionStateFail = not] &&
      [
        currentMatchingNode.state NodeStateNew =
        [currentMatchingNode.state NodeStateHasOutput = [currentMatchingNode.recursionState NodeRecursionStateOld =] &&] ||
        [forceRealFunction copy] ||
      ] &&
    ] ||
    [getStackDepth currentMatchingNode.matchingInfo.inputs.dataSize currentMatchingNode.matchingInfo.preInputs.dataSize + < not] &&
  ] &&;

  goodReality: 
    forceRealFunction not [
      currentMatchingNode.nodeCase NodeCaseDeclaration =
      [currentMatchingNode.nodeCase NodeCaseDllDeclaration =] ||
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
            (", stack type is " stackEntry getMplType ", cache type is " cacheEntry getMplType) @s.catMany
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
        s compilerError
      ] call
    ] func;

    success: TRUE;
    i: 0 dynamic;
    [
      i currentMatchingNode.matchingInfo.inputs.dataSize < [
        stackEntry: i getStackEntry;
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
          stackEntry: i currentMatchingNode.matchingInfo.inputs.dataSize + getStackEntry copy;
          cacheEntry: i currentMatchingNode.matchingInfo.preInputs.at;
          stackEntry cacheEntry compareEntriesRec [
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
          overload: currentCapture getOverload;
          stackEntry: currentCapture.nameInfo currentCapture overload getNameForMatchingWithOverload.refToVar;

          stackEntry.hostId 0 < not [stackEntry cacheEntry compareEntriesRec] && [
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
              ("in compiled-once func fieldCapture " currentFieldCapture.nameInfo processor.nameInfos.at.name "\" mismatch") assembleString compilerError
            ] when

            FALSE dynamic @success set
          ] if

          success compilable and
        ] &&
      ] loop
    ] when

    success
  ] &&
] func;

{processorResult: ProcessorResult Ref; processor: Processor Ref; indexOfNode: Int32; currentNode: CodeNode Ref; multiParserResult: MultiParserResult Cref; forceRealFunction: Cond; indexArrayOfSubNode: IndexArray Cref;} Int32 {convention: cdecl;} [
  processorResult:;
  processor:;
  copy indexOfNode:;
  currentNode:;
  multiParserResult:;
  failProc: @failProcForProcessor;

  forceRealFunction:;
  indexArrayOfSubNode:;

  compileOnce
  indexArrayAddr: indexArrayOfSubNode storageAddress;
  fr: indexArrayAddr @processor.@matchingNodes.find;
  fr.success [
    matchingNodes: fr.value;
    result: -1 dynamic;
    i: 0 dynamic;
    [
      i matchingNodes.dataSize < [
        currentMatchingNodeIndex: i matchingNodes.at;
        currentMatchingNode: currentMatchingNodeIndex processor.nodes.at.get;

        currentMatchingNode tryMatchNode [
          currentMatchingNodeIndex @result set
          FALSE
        ] [
          i 1 + @i set compilable
        ] if
      ] &&
    ] loop

    result
  ] [
    -1 dynamic
  ] if
] "tryMatchAllNodesWith" exportFunction

tryMatchAllNodes: [
  FALSE multiParserResult @currentNode indexOfNode @processor @processorResult tryMatchAllNodesWith
] func;

tryMatchAllNodesForRealFunction: [
  TRUE multiParserResult @currentNode indexOfNode @processor @processorResult tryMatchAllNodesWith
] func;

fixRecursionStack: [
  i: indexOfNode copy;
  [
    processor.recursiveNodesStack.getSize 0 > [i newNodeIndex = not] && [
      current: i @processor.@nodes.at.get;
      i processor.recursiveNodesStack.last = [
        NodeRecursionStateNo @current.@recursionState set
        @processor.@recursiveNodesStack.popBack
      ] when

      current.parent @i set
      [i 0 = not] "NewNodeIndex is not a parent of indexOfNode while fixRecursionStack!" assert
      TRUE
    ] &&
  ] loop
] func;

changeNewNodeState: [
  copy newNodeIndex:;
  newNode: newNodeIndex @processor.@nodes.at.get;
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
] func;

changeNewExportNodeState: [
  copy newNodeIndex:;
  newNode: newNodeIndex @processor.@nodes.at.get;
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
] func;

fixRef: [
  copy refToVar:;

  var: refToVar getVar;
  wasVirtual: refToVar isVirtualRef;
  makeDynamic: FALSE dynamic;
  pointee: VarRef @var.@data.get;
  pointeeVar: pointee getVar;
  pointeeIsLocal: pointeeVar.capturedHead.hostId currentChangesNodeIndex =;

  #("fix " refToVar.hostId ":" refToVar.varId "; to " pointee.hostId ":" pointee.varId) addLog
  #pointee: refToVar getPointeeNoDerefIR;

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
    var.staticness Static = [pointeeVar.storageStaticness Static =] && ["returning pointer to local variable" compilerError] when
    pointee copyVarFromChild @fixed set
    TRUE dynamic @makeDynamic set

    #todo: make it good
    #var.shadowBegin.hostId processor.nodes.dataSize < [
    #  refShadowBegin: var.shadowBegin;
    #  shadowBeginPointee: VarRef refShadowBegin getVar.@data.get;
    #  shadowBeginPointee.hostId processor.nodes.dataSize < not [
    #    pointee copyVarFromChild @shadowBeginPointee set
    #  ] when
    #  shadowBeginPointee pointee getVar.@shadowBegin set
    #  pointee shadowBeginPointee getVar.@shadowEnd set
    #] when
  ] if

  fixed.hostId @pointee.@hostId set
  fixed.varId  @pointee.@varId  set
  #("/fix " refToVar.hostId ":" refToVar.varId "; to " pointee.hostId ":" pointee.varId) addLog

  wasVirtual [refToVar Virtual makeStaticness @refToVar set] [
    makeDynamic [
      refToVar Dynamic makeStaticness @refToVar set
    ] when
  ] if
  refToVar
] func;

applyOnePair: [
  cacheEntry:;
  stackEntry:;

  #("aop, type=" cacheEntry getMplType
  #  "; ce=" cacheEntry.hostId ":" cacheEntry.varId ":" cacheEntry isGlobal
  #  "; se=" stackEntry.hostId ":" stackEntry.varId ":" stackEntry isGlobal) addLog

  [
    cacheEntry stackEntry variablesAreSame [TRUE] [
      ("cache type is " makeStringView cacheEntry getMplType "; stack entry is " makeStringView stackEntry getMplType) addLog
      FALSE
    ] if
  ] "Applying var has wrong type!" assert
  [cacheEntry noMatterToCopy [cacheEntry.hostId currentChangesNodeIndex =] ||] "Applying unused var!" assert

  cacheEntryVar: cacheEntry getVar;
  stackEntryVar: stackEntry getVar;

  stackEntry cacheEntry staticnessOfVar makeStaticness drop:;

  cacheEntry noMatterToCopy not [cacheEntryVar.shadowEnd getVar.capturedAsMutable copy] && [
    TRUE @stackEntryVar.@capturedAsMutable set
  ] when

  cacheEntry isNonrecursiveType [
    fr: stackEntry @appliedVars.@curToNested.find;
    fr.success [
      fr.value cacheEntry getVar.shadowEnd variablesAreEqual not [
        "variable changes to incompatible values by two different ways" makeStringView compilerError
      ] when
    ] [
      [
        cacheEntry stackEntry variablesAreEqualForMatching [
          TRUE
        ] [
          ("match fail, type=" makeStringView cacheEntry getMplType makeStringView
            "; st=" makeStringView cacheEntry staticnessOfVar stackEntry staticnessOfVar) addLog

          cg: cacheEntry isGlobal;
          sg: stackEntry isGlobal;
          cg sg = not [
            ("globality fail cache " cacheEntry.hostId ":" cacheEntry.varId " g=" cg [1][0] if
              "; stack " stackEntry.hostId ":" stackEntry.varId " g=" sg [1][0] if) addLog
          ] when
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
          "ref variable changes to incompatible values by two different ways" makeStringView compilerError
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
] func;

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

      cacheEntryVar.data.getTag VarRef = [currentFromCache staticnessOfVar Virtual <] && [currentFromCache staticnessOfVar Dynamic >] && [
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
] func;

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
        stackPointee: VarRef @stackEntryVar.@data.get;
        stackPointee.hostId currentChangesNodeIndex = [
          fixed: currentFromStack fixRef getPointeeNoDerefIR;
          #("fix ref output, fixed=" fixed.hostId ":" fixed.varId " g=" fixed isGlobal) addLog
          fixed @unfinishedStack.pushBack
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
] func;

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
] func;

usePreCaptures: [
  compileOnce
  currentChangesNode:;

  i: 0 dynamic;
  [
    i currentChangesNode.matchingInfo.captures.dataSize < [
      currentCapture: i currentChangesNode.matchingInfo.captures.at;
      cacheEntry: currentCapture.refToVar;
      overload: currentCapture getOverload;
      stackEntry: currentCapture.nameInfo currentCapture overload getNameForMatchingWithOverload captureName.refToVar;
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
] func;

applyNodeChanges: [
  compileOnce
  copy currentChangesNodeIndex:;
  currentChangesNode: currentChangesNodeIndex processor.nodes.at.get;

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
      overload: currentCapture getOverload;

      stackEntry: currentCapture.nameInfo currentCapture overload getNameForMatchingWithOverload captureName.refToVar;
      #("capture; name=" currentCapture.nameInfo processor.nameInfos.at.name "; ctype=" cacheEntry getMplType "; stype=" stackEntry getMplType) addLog
      #("capture; se=" stackEntry.hostId ":" stackEntry.varId ":" stackEntry staticnessOfVar) addLog
      #("capture; ce=" cacheEntry.hostId ":" cacheEntry.varId ":" cacheEntry staticnessOfVar) addLog
      stackEntry cacheEntry applyEntriesRec
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

  #("curToNested") addLog
  #appliedVars.curToNested [
  #  pair:;
  #  (pair.key.hostId ":" pair.key.varId " s " pair.key staticnessOfVar " <-> " pair.value.hostId ":" pair.value.varId " s " pair.value staticnessOfVar " t" pair.key getMplType) addLog
  #] each

  #("nestedToCur") addLog
  #appliedVars.nestedToCur [
  #  pair:;
  #  (pair.key.hostId ":" pair.key.varId " s " pair.key staticnessOfVar " <-> " pair.value.hostId ":" pair.value.varId " s " pair.value staticnessOfVar " t" pair.key getMplType) addLog
  #] each

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
] func;

changeVarValue: [
  dst:;
  src:;

  compilable [
    varSrc: src getVar;
    varDst: dst getVar;

    varSrc.staticness @varDst.@staticness set
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
] func;

usePreInputs: [
  newNode:;
  newMinStackDepth: getStackDepth newNode.matchingInfo.inputs.dataSize - newNode.matchingInfo.preInputs.dataSize -;
  newMinStackDepth currentNode.minStackDepth < [
    newMinStackDepth @currentNode.@minStackDepth set
  ] when
] func;

#useCapturesAsPreCaptures: [
#  newNode:;
#  newNode.captures [.value @currentNode.@preCaptures.pushBack] each
#  newNode.fieldCaptures [.value @currentNode.@preFieldCaptures.pushBack] each
#] func;

#usePreCaptures: [
#  newNode:;
#  newNode.preCaptures [.value @currentNode.@preCaptures.pushBack] each
#  newNode.preFieldCaptures [.value @currentNode.@preFieldCaptures.pushBack] each
#] func;

pushOutput: [push] func;

isImplicitDeref: [
  copy case:;
  case ArgReturnDeref =
  case ArgRefDeref = or
] func;

derefNEntries: [
  copy count:;
  implicitDerefInfo:;
  i: 0 dynamic;
  [
    i count < [
      count 1 - i - implicitDerefInfo.at [
        dst: i getStackEntry;
        dst getPossiblePointee @dst set
      ] when
      i 1 + @i set TRUE
    ] &&
  ] loop
] func;

applyNamedStackChanges: [
  forcedName:;
  appliedVars:;
  copy currentChangesNodeIndex:;
  newNode:;
  compileOnce

  newNode usePreInputs
  #newNode usePreCaptures

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
      outputRef pushOutput
      i 1 + @i set TRUE
    ] &&
  ] loop

  compilable [
    inputs outputs newNode forcedName makeNamedCallInstruction

    implicitDerefInfo: Cond Array;
    newNode.outputs [.value.argCase isImplicitDeref @implicitDerefInfo.pushBack] each
    implicitDerefInfo appliedVars.fixedOutputs.getSize derefNEntries
  ] when
] func;

applyStackChanges: [
  forcedName: StringView;
  forcedName applyNamedStackChanges
] func;

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
        currentInput getVar.irTypeId @arg.@irTypeId set
        currentInputArgCase ArgRef = [currentInputArgCase ArgRefDeref =] || @arg.@byRef set
        currentInputArgCase ArgCopy = [currentInput createDerefToRegister @arg.@irNameId set] when

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
          outputRef createAllocIR r:;
        ] when

        currentOutput.argCase ArgReturn = [currentOutput.argCase ArgReturnDeref =] || [
          refToVar @argRet set
        ] [
          arg: IRArgument;
          refToVar getVar.irNameId @arg.@irNameId set
          refToVar getVar.irTypeId @arg.@irTypeId set
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

      currentCapture.argCase ArgRef = [
        overload: currentCapture getOverload;
        refToVar: currentCapture.nameInfo currentCapture overload getNameForMatchingWithOverload captureName.refToVar;
        [currentCapture.refToVar refToVar variablesAreSame] "invalid capture type while generating arg list!" assert

        arg: IRArgument;
        refToVar getVar.irNameId @arg.@irNameId set
        refToVar getVar.irTypeId @arg.@irTypeId set
        TRUE @arg.@byRef set
        TRUE @arg.@byRef set

        arg @argList.pushBack
      ] when

      i 1 + @i set TRUE
    ] &&
  ] loop

  newNode.empty not [
    pureFuncName: forcedName "" = [dynamicFunc [refToVar getIrName][newNode.irName makeStringView] if][forcedName copy] if;
    funcName: newNode.variadic [("(" newNode.argTypes ") " pureFuncName) assembleString][pureFuncName toString] if;
    convName: newNode.convention;
    retName: argRet argList convName funcName createCallIR;

    argRet.varId 0 < not [
      @retName argRet createStoreFromRegister
    ] when
  ] when
] func;

makeNamedCallInstruction: [
  r: RefToVar;
  r FALSE dynamic makeCallInstructionWith
] func;

makeCallInstruction: [
  r: RefToVar;
  forcedName: StringView;
  forcedName r FALSE dynamic makeCallInstructionWith
] func;

processNamedCallByNode: [
  forcedName:;
  copy newNodeIndex:;
  newNode: newNodeIndex processor.nodes.at.get;
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
] func;

processCallByNode: [
  forcedName: StringView;
  forcedName processNamedCallByNode
] func;

{processorResult: ProcessorResult Ref; processor: Processor Ref; indexOfNode: Int32; currentNode: CodeNode Ref; multiParserResult: MultiParserResult Cref; 
  positionInfo: CompilerPositionInfo Cref; name: StringView Cref; nodeCase: NodeCaseCode; indexArray: IndexArray Cref;} () {convention: cdecl;} [

  processorResult:;
  processor:;
  copy indexOfNode:;
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
    indexOfNode
    nodeCase
    @processorResult
    @processor
    indexArray
    multiParserResult
    positionInfo
    CFunctionSignature
    astNodeToCodeNode @newNodeIndex set

    #newNodeIndex @processor.@nodes.at.get.irName @forcedNameString set
  ] [
    #newNode: newNodeIndex @processor.@nodes.at.get;
    #newNode.state NodeStateCompiled = [
    #  "@alias_" toString @forcedNameString set
    #  splitted: name.split;
    #  splitted.success [
    #    splitted.chars [
    #      symbol: .value;
    #      codePoint: symbol stringMemory Nat8 addressToReference;
    #      codePoint 48n8 < not [codePoint 57n8 > not] &&         #0..9
    #      [codePoint 65n8 < not [codePoint 90n8 > not] &&] ||    #A..Z
    #      [codePoint 97n8 < not [codePoint 122n8 > not] &&] || [ #a..z
    #        symbol @forcedNameString.cat
    #      ] when
    #    ] each
    #  ] when

    #  ("." processor.funcAliasCount) @forcedNameString.catMany
    #  processor.funcAliasCount 1 + @processor.@funcAliasCount set
    #  forcedNameString newNode.irName newNodeIndex getFuncIrType createFuncAliasIR @newNode.@aliases.pushBack
    #] [
    #  newNodeIndex @processor.@nodes.at.get.irName @forcedNameString set
    #] if
  ] if

  compilable [
    newNode: newNodeIndex @processor.@nodes.at.get;
    currentNode.parent 0 = [nodeCase NodeCaseList = nodeCase NodeCaseObject = or] && [newNode.matchingInfo.inputs.getSize 0 =] && [newNode.outputs.getSize 1 =] && [
      realCapturesCount: 0;
      newNode.matchingInfo.captures [.value.refToVar isVirtual not [realCapturesCount 1 + @realCapturesCount set] when] each
      realCapturesCount 0 =
    ] && [
      0 newNode.outputs.at.refToVar isStaticData
    ] && [
      result: 0 newNode.outputs.at.refToVar copyVarFromChild;
      TRUE @newNode.@deleted set
      result createStaticInitIR push
    ] [
      forcedName: forcedNameString makeStringView;
      newNodeIndex forcedName processNamedCallByNode
    ] if
  ] when
] "processCallByIndexArrayImpl" exportFunction

{processorResult: ProcessorResult Ref; processor: Processor Ref; indexOfNode: Int32; currentNode: CodeNode Ref; multiParserResult: MultiParserResult Cref; name: StringView Cref; callAstNodeIndex: Int32;} () {convention: cdecl;} [
  processorResult:;
  processor:;
  copy indexOfNode:;
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

{processorResult: ProcessorResult Ref; processor: Processor Ref; indexOfNode: Int32; currentNode: CodeNode Ref; multiParserResult: MultiParserResult Cref; preAstNodeIndex: Int32;} Cond {convention: cdecl;} [
  processorResult:;
  processor:;
  copy indexOfNode:;
  currentNode:;
  multiParserResult:;
  failProc: @failProcForProcessor;

  copy preAstNodeIndex:;

  compilable [
    astNode: preAstNodeIndex @multiParserResult.@memory.at;
    positionInfo: astNode makeCompilerPosition;
    indexArray: AstNodeType.Code @astNode.@data.get;

    newNodeIndex: indexArray tryMatchAllNodes;
    newNodeIndex 0 < [compilable] && [
      oldSuccess: compilable;
      oldGlobalErrorCount: processorResult.globalErrorInfo.getSize;

      processor.depthOfPre 1 + @processor.@depthOfPre set
      "PRE" makeStringView indexOfNode NodeCaseCode  @processorResult @processor indexArray multiParserResult positionInfo CFunctionSignature astNodeToCodeNode @newNodeIndex set
      processor.depthOfPre 1 - @processor.@depthOfPre set

      oldGlobalErrorCount @processorResult.@globalErrorInfo.shrink

      oldSuccess [
        processorResult.maxDepthExceeded not [-1 clearProcessorResult] when
      ] [
        [FALSE] "Has compilerError before trying compiling pre!" assert
      ] if
    ] when

    newNode: newNodeIndex processor.nodes.at.get;
    newNode usePreInputs
    newNode usePreCaptures
    #newNode useCapturesAsPreCaptures
    #newNode usePreCaptures

    newNode.uncompilable not
    [newNode.outputs.dataSize 0 >] &&
    [
      top: newNode.outputs.last.refToVar;
      top getVar.data.getTag VarCond =
      [top staticnessOfVar Weak < not] && [
        VarCond top getVar.data.get copy
      ] [
        "PRE code must fail or return static Cond" compilerError
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
    indexOfNode
    NodeCaseCode
    @processorResult
    @processor
    indexArrayThen
    multiParserResult
    positionInfoThen
    CFunctionSignature astNodeToCodeNode @newNodeThenIndex set
  ] when

  compilable [
    newNodeThen: newNodeThenIndex @processor.@nodes.at.get;
    newNodeElseIndex: @indexArrayElse tryMatchAllNodes;
    newNodeElseIndex 0 < [compilable] && [
      "ifElse" makeStringView
      indexOfNode
      NodeCaseCode
      @processorResult
      @processor
      indexArrayElse
      multiParserResult
      positionInfoElse
      CFunctionSignature astNodeToCodeNode @newNodeElseIndex set
    ] when

    compilable [
      newNodeElse: newNodeElseIndex @processor.@nodes.at.get;

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
        newNodeThen usePreInputs
        #newNodeThen usePreCaptures
        newNodeElse usePreInputs
        #newNodeElse usePreCaptures

        stackDepth: getStackDepth;
        newNodeThen.matchingInfo.inputs.dataSize stackDepth > ["then branch stack underflow" makeStringView compilerError] when
        newNodeElse.matchingInfo.inputs.dataSize stackDepth > ["else branch stack underflow" makeStringView compilerError] when
        stackDepth newNodeThen.matchingInfo.inputs.dataSize - newNodeThen.outputs.dataSize +
        stackDepth newNodeElse.matchingInfo.inputs.dataSize - newNodeElse.outputs.dataSize + = not ["if branches stack size mismatch" makeStringView compilerError] when

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
              longestInputSize index - 1 - getStackEntry copy
            ] [
              index branch.fixedOutputs.dataSize + longestOutputSize - branch.fixedOutputs.at copy
            ] if
          ] func;

          isOutputImplicitDeref: [
            branch:;
            copy index:;
            index branch.outputs.dataSize + longestOutputSize < [
              FALSE
            ] [
              index branch.outputs.dataSize + longestOutputSize - branch.outputs.at.argCase isImplicitDeref
            ] if
          ] func;

          getCompiledInput: [
            compiledOutputs:;
            branch:;
            copy index:;

            index branch.outputs.dataSize + longestOutputSize < [
              longestInputSize 1 - i - inputs.at copy
            ] [
              index branch.outputs.dataSize + longestOutputSize - compiledOutputs.at copy
            ] if
          ] func;

          getCompiledOutput: [
            compiledOutputs:;
            branch:;
            copy index:;
            index branch.outputs.dataSize + longestOutputSize < [
              index outputs.at
            ] [
              index branch.outputs.dataSize + longestOutputSize - compiledOutputs.at
            ] if
          ] func;

          # merge captures
          mergeValues: [
            refToDst:;
            value2:;
            value1:;

            [value1 value2 variablesAreSame] "captures changed to different types!" assert
            value1 staticnessOfVar Dynamic = value2 staticnessOfVar Dynamic = or [
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
          ] func;

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
          ] func;

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
                  newOutput createAllocIR @outputs.pushBack
                ] [
                  ("branch types mismatch; in 'then' type is " outputThen getMplType "; in 'else' type is " outputElse getMplType) assembleString compilerError
                ] if

                isOutputImplicitDerefThen @implicitDerefInfo.pushBack
              ] [
                "branch return cases mismatch" compilerError
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

                outputRef pushOutput
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
                      curInput isVirtual not ["variable states in branches mismatch" compilerError] when
                      FALSE curInput getVar.@temporary set
                      curInput current createCheckedCopyToNewNoDie
                    ] when
                    -1 @result.pushBack
                    i 1 + @i set TRUE
                  ] &&
                ] loop
                result
              ] func;

              0 refToCond createBranch
              createLabel
              inputsThen outputsThen newNodeThen makeCallInstruction
              storesThen: newNodeThen outputsThen createStores;
              0 createJump
              createLabel
              inputsElse outputsElse newNodeElse makeCallInstruction
              storesElse: newNodeElse outputsElse createStores;
              1 createJump
              createLabel
              implicitDerefInfo longestOutputSize derefNEntries
              processor.options.verboseIR ["create phi nodes..." makeStringView createComent] when
              processor.options.verboseIR ["end if" makeStringView createComent] when
            ] when
          ] when

        ] when
      ] if
    ] when
  ] when

] func;

maxLoopLength: [64 dynamic] func;

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
      indexOfNode
      NodeCaseCode
      @processorResult
      @processor
      indexArray
      multiParserResult
      positionInfo
      CFunctionSignature astNodeToCodeNode @newNodeIndex set
    ] when


    compilable [
      newNode: newNodeIndex @processor.@nodes.at.get;
      newNodeIndex changeNewNodeState

      newNode.state NodeStateHasOutput < [
        FALSE
      ] [
        newNode.state NodeStateHasOutput = [NodeStateHasOutput @currentNode.@state set] when
        appliedVars: newNodeIndex applyNodeChanges;
        newNode usePreInputs
        #newNode usePreCaptures

        appliedVars.fixedOutputs.getSize 0 = ["loop body must return Cond" makeStringView compilerError] when
        compilable [
          condition: newNode.outputs.last.refToVar;
          condVar: condition getVar;
          condVar.data.getTag VarCond = not ["loop body must return Cond" makeStringView compilerError] when

          compilable [
            condition staticnessOfVar Weak > [
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
    iterationNumber maxLoopLength > [
      "static loop length too big, did you forget to add \"dynamic\"?" makeStringView compilerError
    ] when

    compilable and
  ] loop

  loopIsDynamic [indexArray processDynamicLoop] when
] func;

processDynamicLoop: [

  indexArray:;

  iterationNumber: 0 dynamic;
  [
    needToRemake: FALSE dynamic;
    newNodeIndex: @indexArray tryMatchAllNodes;
    newNodeIndex 0 < [compilable] && [
      "dynamicLoop" makeStringView
      indexOfNode
      NodeCaseCode
      @processorResult
      @processor
      indexArray
      multiParserResult
      positionInfo
      CFunctionSignature astNodeToCodeNode @newNodeIndex set
    ] when

    compilable [
      newNode: newNodeIndex @processor.@nodes.at.get;
      newNodeIndex changeNewNodeState

      newNode.state NodeStateHasOutput < [
        FALSE
      ] [
        newNode.state NodeStateHasOutput = [NodeStateHasOutput @currentNode.@state set] when

        appliedVars: newNodeIndex applyNodeChanges;
        newNode usePreInputs
        #newNode usePreCaptures

        checkToRecompile: [
          dst:;
          src:;

          result: FALSE dynamic;
          src dst variablesAreSame [
            src staticnessOfVar Weak >
            [src dst variablesAreEqual not] && [
              TRUE @result set
            ] when
          ] [
            "loop body changes stack types" makeStringView compilerError
          ] if

          result
        ] func;

        appliedVars.curToNested [
          pair:;

          #("loop checking; key=" pair.key.hostId ":" pair.key.varId " g=" pair.key isGlobal ":" pair.key getVar.globalId " s=" pair.key staticnessOfVar
          #  "; value=" pair.value.hostId ":" pair.value.varId " g=" pair.value isGlobal ":" pair.value getVar.globalId " s=" pair.value staticnessOfVar
          #  "; type=" pair.key getMplType) addLog
          pair.key pair.value checkToRecompile [
            pair.value staticnessOfVar Dirty = [
              pair.key makeVarDirty
            ] [
              pair.key makeVarDynamic
            ] if
            pair.key makePointeeDirtyIfRef
            TRUE dynamic @needToRemake set
          ] when
        ] each

        newNode.outputs.dataSize newNode.matchingInfo.inputs.dataSize 1 + = not ["loop body must save stack values and return Cond" makeStringView compilerError] when
        compilable [
          condition: newNode.outputs.last.refToVar;
          condVar: condition getVar;
          condVar.data.getTag VarCond = not ["loop body must return Cond" makeStringView compilerError] when

          i: 0 dynamic;
          [
            i newNode.matchingInfo.inputs.dataSize < [
              curInput: i getStackEntry;
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
                curOutput pushOutput
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
                1 createPhiNode

                i 1 + @i set TRUE
              ] &&
            ] loop
          ] func;

          # create instruction
          processor.options.verboseIR ["loop prepare..." makeStringView createComent] when
          1 createJump
          createLabel
          createPhiNodes # for each input-output!
          processor.options.verboseIR ["phi nodes prepared" makeStringView createComent] when
          nodeInputs outputs newNode makeCallInstruction

          implicitDerefInfo: Cond Array;
          newNode.outputs [.value.argCase isImplicitDeref @implicitDerefInfo.pushBack] each
          implicitDerefInfo outputs.getSize 1 - derefNEntries
          processor.options.verboseIR ["loop end prepare..." makeStringView createComent] when
          1 outputs.last createBranch
          createLabel
        ] when

        needToRemake [
          newNodeIndex processor.nodes.at.get.nodeCompileOnce [
            "loop body compileOnce directive fail" compilerError
          ] when

          newNodeIndex deleteNode

          iterationNumber maxLoopLength > [
            "loop dynamisation iteration count so big" compilerError
          ] when
        ] when

        iterationNumber 1 + @iterationNumber set

        needToRemake compilable and
      ] if
    ] &&
  ] loop
] func;

nSwap: [
  copy n:;
  [n currentNode.stask.getSize > not] "Swap count too big!" assert
  i: 0;
  j: n 1 -;
  [i j <] [
    e1: i getStackEntry;
    e2: j getStackEntry;
    tmp: e1 move;
    e2 move @e1 set
    tmp moce @e2 set
    i 1 + @i set
    j 1 - @j set
  ] while
] func;

{processorResult: ProcessorResult Ref; processor: Processor Ref; indexOfNode: Int32; currentNode: CodeNode Ref; multiParserResult: MultiParserResult Cref;
  asLambda: Cond; name: StringView Cref; astNode: AstNode Cref; signature: CFunctionSignature Cref;} Int32 {convention: cdecl;} [
  processorResult:;
  processor:;
  copy indexOfNode:;
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

  ("process export: " makeStringView name makeStringView) addLog

  # we dont know count of used in export entites
  signature.inputs [
    pair:;
    r: signature.inputs.getSize 1 - pair.index - signature.inputs.at copyVarFromChild;
    r makeVarTreeDynamic
    r unglobalize
    r fullUntemporize
    FALSE @r.@mutable set
    r push
  ] each

  signature.variadic [
    "export function cannot be variadic" compilerError
  ] when

  oldSuccess: compilable;
  oldRecursiveNodesStackSize: processor.recursiveNodesStack.getSize;

  newNodeIndex: @indexArray tryMatchAllNodesForRealFunction;
  newNodeIndex 0 < [compilable] && [
    nodeCase: asLambda [NodeCaseLambda][NodeCaseExport] if;
    processor.processingExport 1 + @processor.@processingExport set
    name indexOfNode nodeCase @processorResult @processor indexArray multiParserResult positionInfo signature astNodeToCodeNode @newNodeIndex set

    processor.processingExport 1 - @processor.@processingExport set
  ] when

  compilable [
    newNodeIndex changeNewExportNodeState

    newNode: newNodeIndex processor.nodes.at.get;
    newNode.outputs.getSize 1 > ["export function cant have 2 or more outputs" compilerError] when
    newNode.outputs.getSize 1 = [signature.outputs.getSize 0 =] && ["signature is void, export function must be without output" compilerError] when
    newNode.outputs.getSize 0 = [signature.outputs.getSize 1 =] && ["signature is not void, export function must have output" compilerError] when
    newNode.state NodeStateCompiled = not [
      "can not implement lambda inside itself body" compilerError
      FALSE @oldSuccess set
    ] when

    compilable [
      newNode.captureNames [
        currentCaptureName: .value;
        currentCaptureName.startPoint indexOfNode = not [
          #("use cap from module " currentCaptureName.startPoint " while get name " currentCaptureName.nameInfo processor.nameInfos.at.name " type " refToVar getMplType) addLog
          fr: currentCaptureName.startPoint @currentNode.@usedModulesTable.find;
          fr.success [TRUE @fr.@value.@used set] when
        ] when
      ] each

      newNode usePreCaptures

      #newNode.matchingInfo.captures [
      #  capture: .value;
      #  ("capture; name=" capture.nameInfo processor.nameInfos.at.name "; ctype=" capture.refToVar getMplType) addLog
      #] each

      signature.outputs [
        pair:;
        currentInNode: pair.index newNode.outputs.at.refToVar;
        currentInSignature: pair.value;

        currentInNode currentInSignature variablesAreSame not [
          ("export function output mismatch, expected " currentInSignature getMplType ";" LF
            "but found " currentInNode getMplType) assembleString compilerError
        ] when
      ] each
    ] when
  ] when

  oldSuccess compilable not and [
    @processorResult.@errorInfo move @processorResult.@globalErrorInfo.pushBack
    oldRecursiveNodesStackSize @processor.@recursiveNodesStack.shrink
    -1 clearProcessorResult
  ] when

  signature.inputs [p:; a: pop;] each
  ("processed export: " makeStringView name makeStringView) addLog

  newNodeIndex
] "processExportFunctionImpl" exportFunction

{processorResult: ProcessorResult Ref; processor: Processor Ref; indexOfNode: Int32; currentNode: CodeNode Ref; multiParserResult: MultiParserResult Cref;
  asCodeRef: Cond; name: StringView Cref; signature: CFunctionSignature Cref;} Int32 {convention: cdecl;} [
  processorResult:;
  processor:;
  copy indexOfNode:;
  currentNode:;
  multiParserResult:;
  failProc: @failProcForProcessor;

  copy asCodeRef:;
  name:;
  signature:;
  compileOnce

  addCodeNode
  declarationNodeIndex: processor.nodes.dataSize 1 -;
  declarationNode: declarationNodeIndex @processor.@nodes.at.get;
  indexOfNode @declarationNode.@parent set
  asCodeRef [NodeCaseCodeRefDeclaration][NodeCaseDeclaration] if @declarationNode.@nodeCase set
  signature.variadic @declarationNode.@variadic set

  signature.inputs [
    pair:;
    r: signature.inputs.getSize 1 - pair.index - signature.inputs.at copyVarFromChild;
    r unglobalize
    FALSE @r.@mutable set
    r push
  ] each

  #signature.inputs.getSize nSwap

  [
    curPosition: currentNode.position;
    indexOfNode: declarationNodeIndex copy;
    currentNode: @declarationNode;
    curPosition @currentNode.@position set
    position: curPosition copy;
    compilerPositionInfo: position;
    forcedSignature: signature;
    processor.options.debug [
      addDebugReserve @currentNode.@funcDbgIndex set
    ] when
    forcedSignature.inputs   [p:; a: pop;] each
    forcedSignature.outputs [.value copyVarFromChild push] each
    name finalizeCodeNode
  ] call

  signature.inputs   [p:; a: pop;] each
  declarationNodeIndex
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
                  ("cant call import, variable types of argument #" i " are incorrect, expected " nodeEntry getMplType ";" LF "but found " stackEntry getMplType) assembleString compilerError
                ] if
              ] when
            ] [
              stackEntry.mutable not nodeMutable and [
                ("cant call import, expected mutable argument #" i " with type " nodeEntry getMplType) assembleString compilerError
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
            varargs.data.getTag VarStruct = not ["varargs must be a struct" compilerError] when
          ] [
            varStruct: VarStruct varargs.data.get.get;
            varStruct.fields [
              pair:;
              field: pair.index refToVarargs processStaticAt;
              field @inputs.pushBack
            ] each
          ]
        ) sequence
      ] when
    ] [
      #i: 0 dynamic;
      #[
      #  i declarationNode.matchingInfo.captures.dataSize < [
      #    currentCapture: i declarationNode.matchingInfo.captures.at;
      #    currentCapture.refToVar isVirtual not [
      #      (
      #        [compilable]
      #        [
      #          overload: currentCapture getOverload;
      #          stackEntry: currentCapture.nameInfo currentCapture.refToVar overload getNameForMatchingWithOverload.refToVar;
      #          stackEntry.hostId 0 < [
      #            ("cant call import, capture " currentCapture.nameInfo processor.nameInfos.at.name " not found") assembleString compilerError
      #          ] when

      #        ] [
      #          nodeEntry: currentCapture.refToVar;
      #          stackEntry nodeEntry variablesAreSame not [
      #            ("cant call import, capture " currentCapture.nameInfo processor.nameInfos.at.name " types are incorrect, expected " nodeEntry getMplType ";" LF "but found " stackEntry getMplType) assembleString compilerError
      #          ] when
      #        ] [
      #          stackEntry makeVarTreeDynamic
      #          #dont need pushBack to captures, it will find it itself
      #        ]
      #      ) sequence
      #    ] when
      #    i 1 + @i set compilable
      #  ] &&
      #] loop
    ] [
      i: 0 dynamic;
      [
        i declarationNode.outputs.getSize < [
          currentOutput: i declarationNode.outputs.at.refToVar;
          current: currentOutput copyVarFromChild;
          Dynamic current getVar.@staticness set
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
          currentOutput pushOutput
          i 1 + @i set compilable
        ] &&
      ] loop
    ] [
      implicitDerefInfo: Cond Array;
      outputs [
        .value getVar.data.getTag VarRef = @implicitDerefInfo.pushBack
      ] each
      implicitDerefInfo outputs.getSize derefNEntries
    ]
  ) sequence
] func;

callImport: [RefToVar FALSE dynamic callImportWith] func;

{processorResult: ProcessorResult Ref; processor: Processor Ref; indexOfNode: Int32; currentNode: CodeNode Ref; multiParserResult: MultiParserResult Cref; 
  refToVar: RefToVar Cref;} () {convention: cdecl;} [

  processorResult:;
  processor:;
  copy indexOfNode:;
  currentNode:;
  multiParserResult:;
  failProc: @failProcForProcessor;

  refToVar:;
  var: refToVar getVar;
  protoIndex: VarImport var.data.get copy;
  node: protoIndex @processor.@nodes.at.get;
  [
    node.nextRecLambdaId 0 < not [
      node.nextRecLambdaId @protoIndex set
      protoIndex @processor.@nodes.at.get !node
      TRUE
    ] &&
  ] loop

  dynamicFunc: refToVar staticnessOfVar Dynamic > not;
  dynamicFunc not [
    node.nodeCase NodeCaseCodeRefDeclaration = [
      "nullpointer call" compilerError
    ] when
  ] when

  @node refToVar dynamicFunc callImportWith
] "processFuncPtrImpl" exportFunction
