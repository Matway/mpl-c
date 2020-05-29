"Array.Array" use
"HashTable.hash" use
"String.String" use
"String.StringView" use
"String.addLog" use
"String.asView" use
"String.assembleString" use
"String.hash" use
"String.makeStringView" use
"String.print" use
"String.printList" use
"String.toString" use
"control" use

"Block.ArgCopy" use
"Block.ArgGlobal" use
"Block.ArgMeta" use
"Block.ArgRef" use
"Block.ArgRefDeref" use
"Block.ArgReturn" use
"Block.ArgReturnDeref" use
"Block.ArgVirtual" use
"Block.Block" use
"Block.BlockSchema" use
"Block.CFunctionSignature" use
"Block.Capture" use
"Block.CompilerPositionInfo" use
"Block.NameCaseInvalid" use
"Block.NameCaseLocal" use
"Block.NodeCaseCode" use
"Block.NodeCaseCodeRefDeclaration" use
"Block.NodeCaseDeclaration" use
"Block.NodeCaseExport" use
"Block.NodeCaseLambda" use
"Block.NodeCaseList" use
"Block.NodeCaseObject" use
"Block.NodeRecursionStateFail" use
"Block.NodeRecursionStateNew" use
"Block.NodeRecursionStateNo" use
"Block.NodeRecursionStateOld" use
"Block.NodeStateCompiled" use
"Block.NodeStateFailed" use
"Block.NodeStateHasOutput" use
"Block.NodeStateNew" use
"Block.NodeStateNoOutput" use
"Block.ShadowEvent" use
"File.File" use
"Var.Dirty" use
"Var.Dynamic" use
"Var.RefToVar" use
"Var.ShadowReasonCapture" use
"Var.ShadowReasonField" use
"Var.ShadowReasonFieldCapture" use
"Var.ShadowReasonInput" use
"Var.ShadowReasonPointee" use
"Var.Static" use
"Var.VarBuiltin" use
"Var.VarCond" use
"Var.VarImport" use
"Var.VarInvalid" use
"Var.VarReal64" use
"Var.VarRef" use
"Var.VarString" use
"Var.VarStruct" use
"Var.Virtual" use
"Var.Weak" use
"Var.fullUntemporize" use
"Var.getVar" use
"Var.isNonrecursiveType" use
"Var.isPlain" use
"Var.isSchema" use
"Var.isSemiplainNonrecursiveType" use
"Var.isVirtual" use
"Var.makeValuePair" use
"Var.staticityOfVar" use
"Var.varIsMoved" use
"Var.variablesAreSame" use
"astNodeType.AstNode" use
"astNodeType.AstNodeType" use
"astNodeType.IndexArray" use
"codeNode.addBlock" use
"codeNode.astNodeToCodeNode" use
"codeNode.captureName" use
"codeNode.deleteNode" use
"codeNode.finalizeCodeNode" use
"codeNode.getField" use
"codeNode.getFieldForMatching" use
"codeNode.getNameForMatching" use
"codeNode.getNameForMatchingWithOverloadIndex" use
"codeNode.getNameWithOverloadIndex" use
"codeNode.getPointeeForMatching" use
"codeNode.getPointeeNoDerefIR" use
"codeNode.getPossiblePointee" use
"codeNode.makeCompilerPosition" use
"codeNode.makePointeeDirtyIfRef" use
"codeNode.makeStaticity" use
"codeNode.makeVarDirty" use
"codeNode.makeVarDynamic" use
"codeNode.makeVarTreeDirty" use
"codeNode.makeVarTreeDirty" use
"codeNode.makeVarTreeDynamic" use
"codeNode.popForMatching" use
"codeNode.processStaticAt" use
"debugWriter.addDebugReserve" use
"declarations.compilerError" use
"declarations.copyOneVar" use
"declarations.copyVar" use
"declarations.copyVarFromChild" use
"declarations.copyVarToNew" use
"declarations.getMplType" use
"declarations.push" use
"declarations.tryImplicitLambdaCast" use
"defaultImpl.FailProcForProcessor" use
"defaultImpl.addEmptyCapture" use
"defaultImpl.addShadowEvent" use
"defaultImpl.addStackUnderflowInfo" use
"defaultImpl.compilable" use
"defaultImpl.findNameInfo" use
"defaultImpl.getStackDepth" use
"defaultImpl.getStackEntry" use
"defaultImpl.getStackEntryUnchecked" use
"defaultImpl.makeVarRealCaptured" use
"defaultImpl.pop" use
"irWriter.createAllocIR" use
"irWriter.createBranch" use
"irWriter.createCallIR" use
"irWriter.createCheckedCopyToNewNoDie" use
"irWriter.createComment" use
"irWriter.createDerefToRegister" use
"irWriter.createJump" use
"irWriter.createLabel" use
"irWriter.createPhiNode" use
"irWriter.createStaticInitIR" use
"irWriter.createStoreFromRegister" use
"irWriter.getIrName" use
"irWriter.getIrType" use
"irWriter.getMplSchema" use
"processor.IRArgument" use
"processor.Processor" use
"processor.ProcessorErrorInfo" use
"processor.ProcessorResult" use
"processor.RefToVarTable" use
"staticCall.staticCall" use
"variable.isGlobal" use
"variable.isStaticData" use
"variable.markAsAbleToDie" use
"variable.noMatterToCopy" use
"variable.refsAreEqual" use
"variable.unglobalize" use

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

{processor: Processor Cref; comparingMessage: String Ref; makeMessage: Cond; cacheEntry: RefToVar Cref; stackEntry: RefToVar Cref;} Cond {} [
  stackEntry: cacheEntry: makeMessage: comparingMessage: processor: ;;;;;
  stackDynamicBorder: Weak;

  cacheEntry stackEntry variablesAreSame ~ [
    makeMessage ["variables has different type" toString @comparingMessage set] when
    FALSE
  ] [
    cacheEntry stackEntry processor variablesHaveSameGlobality ~ [
      makeMessage ["variables has different globality" toString @comparingMessage set] when
      FALSE
    ] [
      cacheEntryVar: cacheEntry getVar;
      stackEntryVar: stackEntry getVar;

      stackEntryVar.data.getTag VarStruct = [
        cacheStaticity: cacheEntryVar.staticity.end copy;
        stackStaticity: stackEntryVar.staticity.end copy;

        cacheStaticity Dynamic = [Static !cacheStaticity] when
        stackStaticity Dynamic = [Static !stackStaticity] when

        cacheStaticity stackStaticity = ~ [
          makeMessage [
            ("variables has different staticity; was " cacheStaticity " but now " stackStaticity) assembleString @comparingMessage set
          ] when
          FALSE
        ] [
          cacheStruct: VarStruct cacheEntryVar.data.get.get;
          cacheStruct.hasDestructor [cacheEntry varIsMoved stackEntry varIsMoved = ~] && [
            makeMessage ["variables has different moveness" toString @comparingMessage set] when
            FALSE
          ] [
            TRUE
          ] if
        ] if
      ] [
        cacheStaticity: cacheEntryVar.staticity.begin copy;
        stackStaticity: stackEntryVar.staticity.end copy;

        cacheStaticity Weak > ~ stackStaticity stackDynamicBorder > ~ and [
          # both dynamic
          cacheStaticity Dirty = stackStaticity Dirty = = [
            TRUE
          ] [
            makeMessage [
              ("variables has different staticity; was " cacheStaticity " but now " stackStaticity) assembleString @comparingMessage set
            ] when
            FALSE
          ] if
        ] [
          cacheStaticity Weak > stackStaticity stackDynamicBorder > and [
            # both static
            cacheEntry isPlain [
              result: TRUE;

              cacheEntryVar.data.getTag VarCond VarReal64 1 + [
                tag:;
                tag cacheEntryVar.data.get.begin
                tag stackEntryVar.data.get.end =
                !result
              ] staticCall

              result ~ makeMessage and ["variables has different values" toString @comparingMessage set] when
              result
            ] [
              TRUE # go recursive
            ] if
          ] [
            makeMessage [
              ("variables has different staticity; was " cacheStaticity " but now " stackStaticity) assembleString @comparingMessage set
            ] when
            FALSE
          ] if
        ] if
      ] if
    ] if
  ] if
] "variablesAreEqualForMatching" exportFunction

{forLoop: Cond; processor: Processor Cref; cacheEntry: RefToVar Cref; stackEntry: RefToVar Cref; } Cond {} [
  stackEntry: cacheEntry: processor: forLoop: ;;;;

  cacheEntry stackEntry variablesAreSame [cacheEntry stackEntry processor variablesHaveSameGlobality] && [
    cacheEntryVar: cacheEntry getVar;
    stackEntryVar: stackEntry getVar;

    stackEntryVar.data.getTag VarStruct = [
      cacheStaticity: cacheEntryVar.staticity.end copy;
      stackStaticity: stackEntryVar.staticity.end copy;

      cacheStaticity Dynamic = [Static !cacheStaticity] when
      stackStaticity Dynamic = [Static !stackStaticity] when

      cacheStaticity stackStaticity = [
        cacheStruct: VarStruct cacheEntryVar.data.get.get;
        cacheStruct.hasDestructor ~ [cacheEntry varIsMoved stackEntry varIsMoved =] ||
      ] &&
    ] [
      cacheStaticity: cacheEntryVar.staticity.end copy;
      stackStaticity: stackEntryVar.staticity.end copy;


      forLoop [cacheStaticity Static = stackStaticity Dynamic > ~ and] && [ #was dynamic but after loop is static
        TRUE
      ] [
        cacheStaticity Weak > ~ stackStaticity Dynamic > ~ and [ # both dynamic
          cacheStaticity Dirty = stackStaticity Dirty = =
        ] [
          cacheStaticity Weak > stackStaticity Dynamic > and [ # both static
            cacheEntry isPlain [
              result: TRUE;

              cacheEntryVar.data.getTag VarCond VarReal64 1 + [
                tag:;
                tag cacheEntryVar.data.get.end
                tag stackEntryVar.data.get.end =
                !result
              ] staticCall

              result
            ] [
              cacheEntryVar.data.getTag VarRef = [cacheEntry staticityOfVar Virtual <] && [
                r1: VarRef cacheEntryVar.data.get.refToVar;
                r2: VarRef stackEntryVar.data.get.refToVar;
                r1.var r2.var is [r1.mutable r2.mutable =] && [r1 getVar.staticity.end r2 getVar.staticity.end =] &&
              ] [
                TRUE # go recursive
              ] if
            ] if
          ] && # both static and are equal
        ] if
      ] if
    ] if
  ] &&
] "variablesAreEqualWith" exportFunction

variablesAreEqual: [FALSE variablesAreEqualWith];
variablesAreEqualForLoop: [TRUE variablesAreEqualWith];

{processor: Processor Cref; currentMatchingNode: Block Cref; refToVar: RefToVar Cref;} Cond {} [
  refToVar: currentMatchingNode: processor:;;;
  refToVar getVar.host currentMatchingNode is ~ [refToVar noMatterToCopy ~] &&
] "variableIsUnused" exportFunction

{processor: Processor Cref; currentMatchingNode: Block Cref; comparingMessage: String Ref; checkConstness: Cond; cacheEntry: RefToVar Cref; stackEntry: RefToVar Cref;} Cond {} [
  stackEntry: cacheEntry: checkConstness: comparingMessage: currentMatchingNode:  processor:;;;;;;

  checkConstness ~ [cacheEntry.mutable stackEntry.mutable =] || [
    stackEntry cacheEntry currentMatchingNode.nodeCompileOnce @comparingMessage processor variablesAreEqualForMatching [
      TRUE
    ] [
      FALSE
    ] if
  ] [
    currentMatchingNode.nodeCompileOnce ["variables have different constness" toString @comparingMessage set] when
    FALSE
  ] if
] "compareOnePair" exportFunction

getOverloadIndex: [
  cap: block: file: forMathing: ;;;;
  overloadDepth: cap.nameOverloadDepth copy;
  outOverloadDepth: 0;
  index: -1;

  [
    index file cap.nameInfo processor.nameManager.findItem !index
    index 0 < [
      forMathing ~ [
        ("while matching cant call overload for name: " cap.nameInfo processor.nameManager.getText) assembleString @processor block compilerError
      ] when

      FALSE
    ] [
      overloadDepth 0 = [
        FALSE
      ] [
        oldGnr: cap.nameInfo index @processor @block file getNameWithOverloadIndex;
        oldGnr.startPoint block.id = ~ [outOverloadDepth 1 + !outOverloadDepth] when

        overloadDepth 1 - !overloadDepth
        TRUE
      ] if
    ] if
  ] loop

  index outOverloadDepth
];

catShadowEvents: [
  index: currentMatchingNode: message: ;;;

  index 1 + [
    currentEvent: i currentMatchingNode.matchingInfo.shadowEvents.at;
    (
      ShadowReasonInput [
        branch:;
        ("shadow event [" i "] input topology " branch.refToVar getVar.topologyIndex " type " branch.refToVar @processor @block getMplType LF) @message.catMany
      ]
      ShadowReasonCapture [
        branch:;
        ("shadow event [" i "] capture " branch.nameInfo processor.nameManager.getText "(" branch.nameOverloadDepth ") index " branch.refToVar getVar.topologyIndex " type " branch.refToVar @processor @block getMplType LF) @message.catMany
      ]
      ShadowReasonFieldCapture [
        branch:;
        ("shadow event [" i "] fieldCapture " branch.nameInfo processor.nameManager.getText "(" branch.nameOverloadDepth ") [" branch.fieldIndex "] in " branch.object getVar.topologyIndex LF) @message.catMany
      ]
      ShadowReasonPointee [
        branch:;
        ("shadow event [" i "] pointee " branch.pointer getVar.topologyIndex " index " branch.pointee getVar.topologyIndex LF) @message.catMany
      ]
      ShadowReasonField [
        branch:;
        ("shadow event [" i "] field \"" branch.mplFieldIndex VarStruct branch.object getVar.data.get.get.fields.at.nameInfo processor.nameManager.getText "\" [" branch.mplFieldIndex "] of " branch.object getVar.topologyIndex " object type " branch.object @processor @block getMplType " index " branch.field getVar.buildingTopologyIndex LF) @message.catMany
      ]
      []
    ) currentEvent.visit
  ] times
];

tryMatchNode: [
  currentMatchingNode:;

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
   ] &&;

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
    gnr: currentMatchingNode.varNameInfo matchingCapture @processor @block matchingCapture.file getNameForMatching;
    gnr.refToVar.assigned ~
  ] &&;

  canMatch invisibleName ~ and goodReality and [
    mismatchMessage: [
      index:;
      message: ("in compile-one func cache mismatch; " comparingMessage "; matching table events to failing event:" LF) assembleString;

      index currentMatchingNode @message catShadowEvents
      message @processor block compilerError
    ];

    success: TRUE dynamic;
    eventVars: @processor.acquireVarRefArray;
    matchingNodeStackDepth: 0 dynamic;

    addEventVar: [
      stackEntry: cacheEntry: eventVars: ;;;

      success: TRUE dynamic;
      stackEntry noMatterToCopy ~ [
        topologyIndex: cacheEntry getVar.topologyIndex copy;
        [topologyIndex 0 < ~] "Shadow event index is negative!" assert
        topologyIndex eventVars.size < [
          topologyIndex stackEntry getVar.topologyIndexWhileMatching = ~ [
            FALSE dynamic @success set
          ] when
        ] [
          stackEntry getVar.topologyIndexWhileMatching 0 < ~ [
            FALSE dynamic @success set
          ] [
            topologyIndex 1 + @eventVars.enlarge
            topologyIndex @stackEntry getVar.@topologyIndexWhileMatching set
            stackEntry topologyIndex @eventVars.at set
          ] if
        ] if
      ] when

      success
    ];

    currentMatchingNode.matchingInfo.shadowEvents.size [
      success processor compilable and [
        currentEvent: i currentMatchingNode.matchingInfo.shadowEvents.at;
        (
          ShadowReasonInput [
            branch:;
            stackEntry: matchingNodeStackDepth @processor block getStackEntryUnchecked;
            cacheEntry: branch.refToVar;

            stackEntry cacheEntry TRUE @comparingMessage currentMatchingNode processor compareOnePair
            [@stackEntry cacheEntry @eventVars addEventVar] && ~ [
              currentMatchingNode.nodeCompileOnce [i mismatchMessage] when
              FALSE dynamic @success set
            ] when

            matchingNodeStackDepth 1 + !matchingNodeStackDepth
          ]
          ShadowReasonCapture [
            branch:;

            cacheEntry: branch.refToVar;
            overloadIndex: outOverloadDepth: branch @block branch.file TRUE getOverloadIndex;;
            stackEntry: branch.nameInfo branch overloadIndex @processor @block branch.file getNameForMatchingWithOverloadIndex.refToVar;
            stackEntry cacheEntry TRUE @comparingMessage currentMatchingNode processor compareOnePair

            [
              cacheEntry noMatterToCopy [cacheEntry getVar.topologyIndex 0 < ~] || [
                ("captureName=" branch.nameInfo processor.nameManager.getText "; captureType=" cacheEntry @processor @block getMplType LF) printList
                FALSE
              ] ||
            ] "Capture shadow event index is negative!" assert

            [@stackEntry cacheEntry @eventVars addEventVar] && ~ [
              currentMatchingNode.nodeCompileOnce [i mismatchMessage] when
              FALSE dynamic @success set
            ] when
          ]
          ShadowReasonFieldCapture [
            branch:;

            overloadIndex: outOverloadDepth: branch @block branch.file TRUE getOverloadIndex;;
            processor compilable [
              currentFieldInfo: overloadIndex branch.nameInfo processor.nameManager.getItem;
              currentFieldInfo.nameCase branch.captureCase = [branch.object currentFieldInfo.refToVar variablesAreSame] &&
            ] && ~ [
              currentMatchingNode.nodeCompileOnce [i mismatchMessage] when
              FALSE dynamic @success set
            ] when
          ]
          ShadowReasonPointee [
            branch:;
            cacheEntry: branch.pointee;
            stackEntry: branch.pointer getVar.topologyIndex eventVars.at @processor @block getPointeeForMatching;

            stackEntry cacheEntry TRUE @comparingMessage currentMatchingNode processor compareOnePair
            [@stackEntry cacheEntry @eventVars addEventVar] && ~ [
              currentMatchingNode.nodeCompileOnce [i mismatchMessage] when
              FALSE dynamic @success set
            ] when
          ]
          ShadowReasonField [
            branch:;

            cacheEntry: branch.field;
            stackEntry: branch.mplFieldIndex branch.object getVar.topologyIndex eventVars.at @processor @block getFieldForMatching;

            stackEntry cacheEntry FALSE @comparingMessage currentMatchingNode processor compareOnePair
            [@stackEntry cacheEntry @eventVars addEventVar] && ~ [
              currentMatchingNode.nodeCompileOnce [i mismatchMessage] when
              FALSE dynamic @success set
            ] when
          ]
        []
        ) @currentEvent.visit
      ] when
    ] times

    @eventVars [
      refToVar:;
      -1 @refToVar getVar.@topologyIndexWhileMatching set
    ] each

    @eventVars @processor.releaseVarRefArray

    success
  ] &&
];

{processor: Processor Ref; block: Block Ref; forceRealFunction: Cond; indexArrayOfSubNode: IndexArray Cref;} Int32 {} [
  processor:;
  block:;

  overload failProc: processor block FailProcForProcessor;

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
            currentMatchingNode.uncompilable ["nested node error" @processor block compilerError] when

            FALSE
          ] [
            i 1 + @i set processor compilable
          ] if
        ] &&
      ] loop

      result
    ];

    result: -1 dynamic;

    @processor block getStackDepth 0 > [
      byType: 0 @processor block getStackEntry getVar.mplSchemaId fr.value.byMplType.find;

      byType.success [
        byType.value findInIndexArray @result set
      ] when
    ] when

    result 0 < [
      fr.value.unknownMplType findInIndexArray @result set
    ] when

    result
  ] [
    -1
  ] if
] "tryMatchAllNodesWith" exportFunction

tryMatchAllNodes: [
  processor: block: ;;
  FALSE @block @processor tryMatchAllNodesWith
];

tryMatchAllNodesForRealFunction: [
  processor: block: ;;
  TRUE @block @processor tryMatchAllNodesWith
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
  refToVar: appliedVars:; copy;

  var: @refToVar getVar;
  wasVirtual: refToVar isVirtual;
  makeDynamic: FALSE dynamic;
  pointee: VarRef @var.@data.get.@refToVar;
  pointeeVar: pointee getVar;

  pointeeIsLocal: pointeeVar.capturedHead getVar.host currentChangesNode is;
  pointeeWasNotUsed: pointeeVar.host currentChangesNode is ~;
  fixed: pointee copy;

  pointeeWasNotUsed [
  ] [
    pointeeIsLocal ~ [ # has shadow - captured from top
      index: pointeeVar.topologyIndex copy;
      index 0 < ~ [
        index appliedVars.stackVars.at @fixed set
      ] [
        pointee @processor @block copyVarFromChild @fixed set
        TRUE dynamic @makeDynamic set
      ] if
    ] [
      # dont have shadow - to deref of captured dynamic pointer
      # must by dynamic
      var.staticity.end Static = [pointeeVar.storageStaticity Static =] && ["returning pointer to local variable" @processor block compilerError] when
      pointee @processor @block copyVarFromChild @fixed set
      TRUE dynamic @makeDynamic set
    ] if
  ] if

  @fixed.var @pointee.setVar

  wasVirtual [@refToVar Virtual @processor block makeStaticity @refToVar set] [
    makeDynamic [
      @refToVar Dynamic @processor block makeStaticity @refToVar set
    ] when
  ] if

  @refToVar
];

hasGoodSource: [
  refToVar:;
  var: refToVar getVar;

  var.host var.sourceOfValue getVar.host is
];

fixOutputRefsRec: [
  stackEntry: appliedVars: ;;

  unfinishedStack: @processor.acquireVarRefArray;
  stackEntry @unfinishedStack.pushBack

  i: 0 dynamic;
  [
    i unfinishedStack.dataSize < [
      currentFromStack: i @unfinishedStack.at copy;
      stackEntryVar: @currentFromStack getVar;
      sourceVar: stackEntryVar.sourceOfValue getVar;

      currentFromStack noMatterToCopy [
        #do nothing
      ] [
        sourceVar.host block is [
          [currentFromStack hasGoodSource] "Stack var source invariant failed!" assert
        ] [
          sourceIndex: sourceVar.topologyIndex copy;
          sourceIndex 0 < ~ [
            sourceIndex appliedVars.stackVars.at @stackEntryVar.@sourceOfValue set
          ] [
            sourceVar.host currentChangesNode is [
              currentFromStack @stackEntryVar.@sourceOfValue set
            ] [
              [FALSE] "Source of value is unknown!" assert
            ] if
          ] if

          [currentFromStack hasGoodSource] "Stack var source invariant failed!" assert

          stackEntryVar.data.getTag VarRef = [
            currentFromStack isSchema ~ [
              stackPointee: VarRef @stackEntryVar.@data.get.@refToVar;
              stackPointee getVar.host currentChangesNode is [
                fixed: currentFromStack appliedVars fixRef @processor @block getPointeeNoDerefIR;
                fixed @unfinishedStack.pushBack
              ] when
            ] when
          ] [
            stackEntryVar.data.getTag VarStruct = [
              stackStruct: VarStruct stackEntryVar.data.get.get;
              j: 0 dynamic;
              [
                j stackStruct.fields.dataSize < [
                  stackField: j currentFromStack @processor @block getField;
                  stackField @unfinishedStack.pushBack
                  j 1 + @j set TRUE
                ] &&
              ] loop
            ] when
          ] if
        ] if
      ] if

      i 1 + @i set processor compilable

    ] &&
  ] loop

  @unfinishedStack @processor.releaseVarRefArray
];

fixCaptureRefOld: [
  cacheRefToVar: appliedVars: ;;

  result: cacheRefToVar appliedVars fixRef;
  fixed: result copy;

  [
    continue: FALSE;
    var: fixed getVar;

    curPointee: VarRef var.data.get.refToVar;
    curPointeeVar: curPointee getVar;

    curPointeeVar.data.getTag VarRef = [
      index: curPointee getVar.topologyIndexWhileMatching copy;
      index 0 < ~ [
        curPointee appliedVars fixRef @fixed set
        TRUE dynamic @continue set
        # we need deep recursion for captures, becouse if we has dynamic fix to, we will has unfixed pointee
        # need to fix!!!
      ] when
    ] when

    continue
  ] loop

  result
];

fixCaptureRef: [
  stackEntry: cacheEntry: appliedVars: ;;;

  stackVar: @stackEntry getVar;
  cacheVar: @cacheEntry getVar;

  cacheEntry noMatterToCopy ~ [
    cacheVar.data.getTag VarRef = [
      topologyIndex: cacheVar.sourceOfValue getVar.topologyIndex;

      cacheCopy: cacheEntry @processor @block copyOneVar;
      cacheCopyVar: cacheCopy getVar;
      cacheVar.staticity @cacheCopyVar.@staticity set #we need to copy begin and end

      cacheEntry isGlobal [
        TRUE              @cacheCopyVar.@global set
        cacheVar.globalId @cacheCopyVar.@globalId set
      ] when

      topologyIndex 0 < [
        #source is inner variable
        cacheCopy @cacheCopyVar.@sourceOfValue set

        cacheCopyVar.data.getTag VarRef = [
          cacheCopyVar.staticity.end Dynamic > [
            cachePointee: VarRef @cacheCopyVar.@data.get.@refToVar;
            topologyIndexOfPointee: cachePointee getVar.topologyIndex copy;
            topologyIndexOfPointee 0 < [
              cachePointee getVar.storageStaticity Dynamic = [
                #here???
              ] [
                "returning pointer to local variable" @processor block compilerError
              ] if
            ] [
              #fixing here...
              topologyIndexOfPointee appliedVars.stackVars.at getVar @cachePointee.setVar
            ] if
          ] when
        ] when
      ] [
        #we know source of variable
        topologyIndex appliedVars.stackVars.at @cacheCopyVar.@sourceOfValue set
        cacheVar.data.getTag VarRef = [
          VarRef cacheCopyVar.sourceOfValue getVar.data.get.refToVar
          VarRef @cacheCopyVar.@data.get.@refToVar set
        ] when
      ] if

      cacheCopy @cacheEntry set #here cacheCopy is END
    ] [
      stackEntry @stackVar.@sourceOfValue set
    ] if
  ] when
];

applyNodeChanges: [
  compileOnce
  currentChangesNode:;

  appliedVars: {
    stackVars: @processor.acquireVarRefArray;
    cacheVars: @processor.acquireVarRefArray;
    fixedOutputs: @processor.acquireVarRefArray;

    DIE: [
      @stackVars @processor.releaseVarRefArray
      @cacheVars @processor.releaseVarRefArray
      @fixedOutputs @processor.releaseVarRefArray
    ];
  };

  pops: @processor.acquireVarRefArray;

  addAppliedVar: [
    stackEntry: cacheEntry: appliedVars: ;;;

    [stackEntry cacheEntry variablesAreSame] "Applied vars has different type!" assert

    stackEntry noMatterToCopy ~ [
      topologyIndex: cacheEntry getVar.topologyIndex copy;
      [topologyIndex 0 < ~] "Shadow event index is negative!" assert
      topologyIndex appliedVars.stackVars.size < ~ [
        topologyIndex 1 + @appliedVars.@stackVars.enlarge
        topologyIndex 1 + @appliedVars.@cacheVars.enlarge
        stackEntry topologyIndex @appliedVars.@stackVars.at set
        cacheEntry topologyIndex @appliedVars.@cacheVars.at set
        [cacheEntry noMatterToCopy [cacheEntry getVar.host cacheEntry getVar.sourceOfValue getVar.host is] ||] "Val source incorrest!" assert
      ] when

      cacheEntry getVar.capturedAsMutable [
        TRUE stackEntry getVar.@capturedAsMutable set
      ] when
    ] when
  ];

  currentChangesNode.matchingInfo.shadowEvents.size [
    processor compilable [
      shadowEventIndex: i copy;

      currentEvent: shadowEventIndex currentChangesNode.matchingInfo.shadowEvents.at;
      (
        ShadowReasonInput [
          branch:;
          stackEntry: @processor @block popForMatching;
          cacheEntry: branch.refToVar;

          stackEntry getVar.data.getTag VarInvalid = ~ [stackEntry @pops.pushBack] when
          stackEntry cacheEntry @appliedVars addAppliedVar
        ]
        ShadowReasonCapture [
          branch:;
          cacheEntry: branch.refToVar;
          overloadIndex: outOverloadDepth: branch @block branch.file TRUE getOverloadIndex;;
          gnr: branch.nameInfo branch overloadIndex @processor @block branch.file getNameForMatchingWithOverloadIndex;
          stackEntry: gnr outOverloadDepth @processor @block branch.file captureName.refToVar;

          [stackEntry cacheEntry variablesAreSame
            [
              (
                "shadowEventIndex " shadowEventIndex " of " currentChangesNode.matchingInfo.shadowEvents.size LF
                "capture name is " branch.nameInfo processor.nameManager.getText LF
                "stack entry is " stackEntry @processor @block getMplType LF
                "cache entry is " cacheEntry @processor @block getMplType LF) printList
              FALSE
            ] ||
          ] "Applied vars has different type!" assert
          stackEntry cacheEntry @appliedVars addAppliedVar
        ]
        ShadowReasonFieldCapture [
          branch:;
          overloadIndex: outOverloadDepth: branch @block branch.file FALSE getOverloadIndex;;
          fieldCnr: branch.nameInfo overloadIndex @processor @block branch.file getNameWithOverloadIndex outOverloadDepth @processor @block branch.file captureName;
        ]
        ShadowReasonPointee [
          branch:;

          cacheEntry: branch.pointee;
          stackPointer: branch.pointer getVar.topologyIndex appliedVars.stackVars.at;

          stackEntry: stackPointer @processor @block getPointeeNoDerefIR;
          stackEntry cacheEntry @appliedVars addAppliedVar
        ]
        ShadowReasonField [
          branch:;
          cacheObject: branch.object;
          cacheEntry: branch.field;
          stackObject: cacheObject getVar.topologyIndex appliedVars.stackVars.at;

          [stackObject cacheObject variablesAreSame
            [
              (
                "shadowEventIndex " shadowEventIndex " of " currentChangesNode.matchingInfo.shadowEvents.size LF
                "cacheObject topologyIndex " cacheObject getVar.topologyIndex " of " appliedVars.stackVars.size LF
                "stack object is " stackObject @processor @block getMplType LF
                "cache object is " cacheObject @processor @block getMplType LF) printList

              message: String;
              shadowEventIndex currentChangesNode @message catShadowEvents
              message print LF print

              FALSE
            ] ||
          ] "Applied objects has different type!" assert

          stackEntry: branch.mplFieldIndex stackObject @processor @block getField;
          stackEntry cacheEntry @appliedVars addAppliedVar
        ]
      []
      ) @currentEvent.visit
    ] when
  ] times

  i: 0 dynamic;
  [
    i pops.dataSize < [
      pops.dataSize i - 1 - pops.at @block push
      i 1 + @i set processor compilable
    ] &&
  ] loop

  appliedVars.stackVars.size [
    stackEntryVar: i @appliedVars.@stackVars.at getVar;
    i @stackEntryVar.@topologyIndexWhileMatching set
  ] times

  i: 0 dynamic;
  [
    i currentChangesNode.outputs.dataSize < [
      currentOutput: i currentChangesNode.outputs.at;
      outputRef: currentOutput.refToVar @processor @block copyVarFromChild; # output is to inner var

      outputRef appliedVars fixOutputRefsRec # it is End
      outputRef @appliedVars.@fixedOutputs.pushBack
      i 1 + @i set processor compilable
    ] &&
  ] loop

  appliedVars.stackVars.size [
    stackEntry: i @appliedVars.@stackVars.at;
    cacheEntry: i @appliedVars.@cacheVars.at;
    @stackEntry @cacheEntry @appliedVars fixCaptureRef
  ] times

  appliedVars.stackVars.size [
    stackEntryVar: i @appliedVars.@stackVars.at getVar;
    -1 @stackEntryVar.@topologyIndexWhileMatching set
  ] times

  @pops @processor.releaseVarRefArray

  @appliedVars
];

changeVarValue: [
  src: dst: ;;

  processor compilable [
    varSrc: src  getVar;
    varDst: @dst getVar;

    varSrc.data.getTag VarRef = [ #it is optimisation; for another type source has is no matter
      varSrc.sourceOfValue @varDst.@sourceOfValue set
    ] when

    [dst hasGoodSource] "Change var value var source invariant failed!" assert

    varSrc.staticity @varDst.@staticity set
    dst isPlain [
      varDst.data.getTag VarCond VarReal64 1 + [
        copy tag:;
        srcBranch: tag varSrc.data.get;
        dstBranch: tag @varDst.@data.get;
        srcBranch.end @dstBranch.@end set
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
        dst: i @processor @block getStackEntry;
        pointee: @dst @processor @block getPossiblePointee;
        pointee @dst set
      ] when

      i 1 + @i set TRUE
    ] &&
  ] loop
];

applyNamedStackChanges: [
  forcedName:;
  appliedVars:;
  currentChangesNodeIndex: copy dynamic;
  newNode:;
  compileOnce

  inputs: @processor.acquireVarRefArray;
  outputs: @processor.acquireVarRefArray;

  i: 0 dynamic;
  [
    i newNode.matchingInfo.inputs.dataSize < [
      @processor @block pop @inputs.pushBack
      i 1 + @i set TRUE
    ] &&
  ] loop

  i: 0 dynamic;
  [
    i appliedVars.fixedOutputs.getSize < [
      outputRef: i @appliedVars.@fixedOutputs.at;
      outputRef @outputs.pushBack
      outputRef getVar.data.getTag VarStruct = [
        @outputRef markAsAbleToDie
        outputRef @block.@candidatesToDie.pushBack
      ] when
      outputRef @block push
      i 1 + @i set TRUE
    ] &&
  ] loop

  processor compilable [
    inputs @outputs newNode forcedName makeNamedCallInstruction

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
        currentInput @processor getMplSchema.irTypeId @arg.@irTypeId set
        currentInputArgCase ArgRef = [currentInputArgCase ArgRefDeref =] || @arg.@byRef set
        currentInputArgCase ArgCopy = [currentInput @processor @block createDerefToRegister @arg.@irNameId set] when

        arg @argList.pushBack
      ] if

      i 1 + @i set TRUE
    ] &&
  ] loop

  i: 0 dynamic;
  [
    i newNode.outputs.dataSize < [
      currentOutput: i newNode.outputs.at;
      outputRef: i @outputs.at; # output is to inner var

      currentOutput.argCase ArgVirtual = [
      ] [
        refToVar: outputRef;
        outputRef getVar.allocationInstructionIndex 0 <
        [outputRef getVar.globalDeclarationInstructionIndex 0 <] && [
          @outputRef @processor @block createAllocIR r:;
        ] when

        currentOutput.argCase ArgReturn = [currentOutput.argCase ArgReturnDeref =] || [
          refToVar @argRet set
        ] [
          arg: IRArgument;
          refToVar getVar.irNameId @arg.@irNameId set
          refToVar @processor getMplSchema.irTypeId @arg.@irTypeId set
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

      currentCapture.refToVar.assigned [
        currentCapture.argCase ArgRef = [
          overloadIndex: outOverloadDepth: currentCapture @block currentCapture.file FALSE getOverloadIndex;;
          refToVar: currentCapture.nameInfo currentCapture overloadIndex @processor @block currentCapture.file getNameForMatchingWithOverloadIndex outOverloadDepth @processor @block currentCapture.file captureName.refToVar;
          [currentCapture.refToVar refToVar variablesAreSame] "invalid capture type while generating arg list!" assert

          arg: IRArgument;
          refToVar getVar.irNameId @arg.@irNameId set
          refToVar @processor getMplSchema.irTypeId @arg.@irTypeId set
          TRUE @arg.@byRef set
          TRUE @arg.@byRef set

          arg @argList.pushBack
        ] when
      ] when

      i 1 + @i set TRUE
    ] &&
  ] loop

  newNode.empty ~ [
    pureFuncName: forcedName "" = [dynamicFunc [refToVar @processor getIrName][newNode.irName makeStringView] if][forcedName copy] if;
    funcName: newNode.variadic [("(" newNode.argTypes ") " pureFuncName) assembleString][pureFuncName toString] if;
    convName: newNode.convention;
    retName: argRet argList convName funcName @processor @block createCallIR;

    argRet.var isNil ~ [
      @retName argRet @processor @block createStoreFromRegister
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
  forcedName: StringView dynamic;
  forcedName r FALSE dynamic @block makeCallInstructionWith
];

processNamedCallByNode: [
  forcedName:;
  copy dynamic newNodeIndex:;
  newNode: newNodeIndex processor.blocks.at.get;
  compileOnce


  newNodeIndex changeNewNodeState
  newNode.state NodeStateNoOutput = ~ [
    appliedVars: newNode applyNodeChanges;

    appliedVars.stackVars.size [
      stackEntry: i appliedVars.stackVars.at;
      cacheEntry: i appliedVars.cacheVars.at;
      cacheEntry @stackEntry changeVarValue
    ] times

    newNode newNodeIndex @appliedVars forcedName applyNamedStackChanges
  ] when
];

processCallByNode: [
  forcedName: StringView dynamic;
  forcedName processNamedCallByNode
];

useMatchingInfoOnly: [
  newNode: processor: block: ;;;

  pops: @processor.acquireVarRefArray;
  eventVars: @processor.acquireVarRefArray;

  addEventVar: [
    stackEntry: cacheEntry: ;;
    stackEntry noMatterToCopy ~ [
      index: cacheEntry getVar.topologyIndex;
      index eventVars.size < ~ [
        index 1 + @eventVars.resize
        stackEntry index @eventVars.at set
      ] when
    ] when
  ];

  oldSuccess: processor.result.success copy;
  TRUE @processor.@result.@success set

  newNode.matchingInfo.shadowEvents [
    event:;
    (
      ShadowReasonInput [
        branch:;
        cacheEntry: branch.refToVar;
        stackEntry: @processor @block popForMatching;
        stackEntry getVar.data.getTag VarInvalid = ~ [stackEntry @pops.pushBack] when
        stackEntry cacheEntry addEventVar
      ]
      ShadowReasonCapture [
        branch:;
        cacheEntry: branch.refToVar;
        overloadIndex: outOverloadDepth: branch @block branch.file TRUE getOverloadIndex;;
        gnr: branch.nameInfo branch overloadIndex @processor @block branch.file getNameForMatchingWithOverloadIndex;
        stackEntry: gnr outOverloadDepth @processor @block branch.file captureName.refToVar;
        stackEntry cacheEntry addEventVar
      ]
      ShadowReasonFieldCapture [
        branch:;
        overloadIndex: outOverloadDepth: branch @block branch.file FALSE getOverloadIndex;;
        fieldCnr: branch.nameInfo overloadIndex @processor @block branch.file getNameWithOverloadIndex outOverloadDepth @processor @block branch.file captureName;
      ]
      ShadowReasonPointee [
        branch:;
        cacheEntry: branch.pointee;
        stackEntry: branch.pointer getVar.topologyIndex eventVars.at @processor @block getPointeeNoDerefIR;
        stackEntry cacheEntry addEventVar
      ]
      ShadowReasonField [
        branch:;
        cacheEntry: branch.field;
        stackEntry: branch.mplFieldIndex branch.object getVar.topologyIndex eventVars.at @processor @block getField;
        stackEntry cacheEntry addEventVar
      ]
      []
    ) event.visit
  ] each

  @eventVars @processor.releaseVarRefArray

  i: 0 dynamic;
  [
    i pops.dataSize < [
      pops.dataSize i - 1 - pops.at @block push
      i 1 + @i set
      TRUE
    ] &&
  ] loop

  @pops @processor.releaseVarRefArray

  oldSuccess @processor.@result.@success set
];

{block: Block Ref; processor: Processor Ref;
  positionInfo: CompilerPositionInfo Cref; name: StringView Cref; nodeCase: NodeCaseCode; indexArray: IndexArray Cref;} () {} [
  block:;
  processor:;
  positionInfo:;
  name:;
  copy nodeCase:;
  indexArray:;

  overload failProc: processor block FailProcForProcessor;

  forcedNameString: String;
  file: positionInfo.file;

  newNodeIndex: indexArray @processor @block tryMatchAllNodes;
  newNodeIndex 0 < [
    name
    block.id
    nodeCase
    indexArray
    file
    positionInfo
    CFunctionSignature
    @processor
    astNodeToCodeNode @newNodeIndex set
  ] when

  newNode: newNodeIndex @processor.@blocks.at.get;

  processor compilable [
    block.parent 0 = [nodeCase NodeCaseList = nodeCase NodeCaseObject = or] && [newNode.matchingInfo.inputs.getSize 0 =] && [newNode.outputs.getSize 1 =] && [
      realCapturesCount: 0;
      newNode.matchingInfo.captures [
        capture:;
        capture.refToVar.assigned [
          capture.refToVar isVirtual ~ [realCapturesCount 1 + @realCapturesCount set] when
        ] when
      ] each

      realCapturesCount 0 =
    ] && [
      0 newNode.outputs.at.refToVar isStaticData
    ] && [
      result: 0 newNode.outputs.at.refToVar @processor @block copyVarFromChild;
      TRUE @newNode.@deleted set
      @result @processor @block createStaticInitIR @block push
    ] [
      forcedName: forcedNameString makeStringView dynamic;
      newNodeIndex forcedName processNamedCallByNode
    ] if
  ] [
    newNode @processor @block useMatchingInfoOnly
  ] if
] "processCallByIndexArray" exportFunction

{block: Block Ref; processor: Processor Ref; name: StringView Cref; file: File Cref; callAstNodeIndex: Int32;} () {} [
  block:;
  processor:;
  name:;
  file:;
  callAstNodeIndex:;
  overload failProc: processor block FailProcForProcessor;

  astNode: callAstNodeIndex processor.multiParserResult.memory.at;

  positionInfo: astNode file makeCompilerPosition;

  indexArray: Int32 Array Cref;
  nodeCase: Nat8;

  (
    AstNodeType.Code   [!indexArray NodeCaseCode   !nodeCase]
    AstNodeType.List   [!indexArray NodeCaseList   !nodeCase]
    AstNodeType.Object [!indexArray NodeCaseObject !nodeCase]
  ) astNode.data.visit

  indexArray nodeCase dynamic name positionInfo @processor @block processCallByIndexArray
] "processCall" exportFunction

{block: Block Ref; processor: Processor Ref; file: File Cref; preAstNodeIndex: Int32;} Cond {} [
  block:;
  processor:;
  file:;
  preAstNodeIndex:;
  overload failProc: processor block FailProcForProcessor;

  processor compilable [
    astNode: preAstNodeIndex processor.multiParserResult.memory.at;
    positionInfo: astNode file makeCompilerPosition;
    indexArray: AstNodeType.Code @astNode.@data.get;

    oldSuccess: processor compilable;
    oldGlobalErrorCount: processor.result.globalErrorInfo.getSize;

    newNodeIndex: indexArray @processor @block tryMatchAllNodes;
    newNodeIndex 0 < [
      processor.depthOfPre 1 + @processor.@depthOfPre set
      "PRE" makeStringView block.id NodeCaseCode indexArray file positionInfo CFunctionSignature @processor astNodeToCodeNode @newNodeIndex set
      processor.depthOfPre 1 - @processor.@depthOfPre set
    ] when

    newNode: newNodeIndex processor.blocks.at.get;
    newNode @processor @block useMatchingInfoOnly

    oldGlobalErrorCount @processor.@result.@globalErrorInfo.shrink
    oldSuccess [
      processor.@result.passErrorThroughPRE ~ [-1 @processor.@result clearProcessorResult] when
    ] [
      [FALSE] "Has compilerError before trying compiling pre!" assert
    ] if

    newNode.uncompilable ~
    [newNode.outputs.dataSize 0 >] &&
    [
      top: newNode.outputs.last.refToVar;
      top getVar.data.getTag VarCond =
      [top staticityOfVar Weak < ~] && [
        VarCond top getVar.data.get.end copy
      ] [
        TRUE dynamic @processor.@result.@passErrorThroughPRE set
        "PRE code must fail or return static Cond" @processor block compilerError
        FALSE dynamic
      ] if
    ] &&
  ] [
    FALSE dynamic
  ] if
] "processPre" exportFunction

processIf: [
  processor: block: ;;

  fileElse:;
  astNodeElse:;
  fileThen:;
  astNodeThen:;
  refToCond:;

  indexArrayElse: AstNodeType.Code astNodeElse.data.get;
  indexArrayThen: AstNodeType.Code astNodeThen.data.get;

  positionInfoThen: astNodeThen fileThen makeCompilerPosition;
  positionInfoElse: astNodeElse fileElse makeCompilerPosition;

  newNodeThenIndex: @indexArrayThen @processor @block tryMatchAllNodes;
  newNodeThenIndex 0 < [
    "ifThen" makeStringView
    block.id
    NodeCaseCode
    indexArrayThen
    fileThen
    positionInfoThen
    CFunctionSignature
    @processor astNodeToCodeNode @newNodeThenIndex set
  ] when

  newNodeThen: newNodeThenIndex @processor.@blocks.at.get;
  processor compilable ~ [
    newNodeThen @processor @block useMatchingInfoOnly
  ] [
    newNodeElseIndex: @indexArrayElse @processor @block tryMatchAllNodes;
    newNodeElseIndex 0 < [
      "ifElse" makeStringView
      block.id
      NodeCaseCode
      indexArrayElse
      fileElse
      positionInfoElse
      CFunctionSignature
      @processor
      astNodeToCodeNode @newNodeElseIndex set
    ] when

    newNodeElse: newNodeElseIndex @processor.@blocks.at.get;

    processor compilable ~ [
      newNodeElse @processor @block useMatchingInfoOnly
    ] [
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

        appliedVarsThen: newNodeThen applyNodeChanges;
        appliedVarsElse: newNodeElse applyNodeChanges;

        stackDepth: @processor block getStackDepth;
        newNodeThen.matchingInfo.inputs.dataSize stackDepth > ["then branch stack underflow" @processor block compilerError] when
        newNodeElse.matchingInfo.inputs.dataSize stackDepth > ["else branch stack underflow" @processor block compilerError] when
        stackDepth newNodeThen.matchingInfo.inputs.dataSize - newNodeThen.outputs.dataSize +
        stackDepth newNodeElse.matchingInfo.inputs.dataSize - newNodeElse.outputs.dataSize + = ~ ["if branches stack size mismatch" @processor block compilerError] when

        processor compilable [
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
              longestInputSize index - 1 - @processor block getStackEntry copy
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
              longestInputSize 1 - i - @inputs.at copy
            ] [
              index branch.outputs.dataSize + longestOutputSize - @compiledOutputs.at copy
            ] if
          ];

          getCompiledOutput: [
            compiledOutputs:;
            branch:;
            copy index:;
            index branch.outputs.dataSize + longestOutputSize < [
              index @outputs.at
            ] [
              index branch.outputs.dataSize + longestOutputSize - @compiledOutputs.at
            ] if
          ];

          # merge captures
          mergeValues: [
            refToDst: copy;
            value2:;
            value1:;

            [value1 value2 variablesAreSame] "captures changed to different types!" assert
            value1 staticityOfVar Dynamic = value2 staticityOfVar Dynamic = or [
              @value1 @processor @block makePointeeDirtyIfRef
              @value2 @processor @block makePointeeDirtyIfRef
              @refToDst @processor @block makeVarDynamic
            ] [
              value1 value2 processor variablesAreEqual [ # both are static, same value
                value1 @refToDst changeVarValue
              ] [
                @value1 @processor @block makePointeeDirtyIfRef
                @value2 @processor @block makePointeeDirtyIfRef
                @refToDst @processor @block makeVarDynamic
              ] if
            ] if
          ];

          mergeValuesRec: [
            refToDst: copy;
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

                v1Var: lastV1 getVar;
                v2Var: lastV2 getVar;

                @lastV1 @lastV2 lastD mergeValues

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

          appliedVarsThen.stackVars.size [
            stackEntryVar: i @appliedVarsThen.@stackVars.at getVar;
            i @stackEntryVar.@topologyIndexWhileMatching set
          ] times

          appliedVarsElse.stackVars.size [
            stackEntryVar: i @appliedVarsElse.@stackVars.at getVar;
            i @stackEntryVar.@topologyIndexWhileMatching2 set
          ] times

          appliedVarsThen.stackVars.size [
            stackEntry: i @appliedVarsThen.@stackVars.at;

            stackEntry getVar.topologyIndexWhileMatching2 0 < ~ [
              #changed if both branches
              cacheEntryThen: i @appliedVarsThen.@cacheVars.at;
              cacheEntryElse: stackEntry getVar.topologyIndexWhileMatching2 @appliedVarsElse.@cacheVars.at;
              @cacheEntryThen @cacheEntryElse stackEntry mergeValues
            ] [
              #changed in 'then' branch only
              cacheEntryThen: i @appliedVarsThen.@cacheVars.at;
              @cacheEntryThen @stackEntry stackEntry mergeValues
            ] if
          ] times

          appliedVarsElse.stackVars.size [
            stackEntry: i @appliedVarsElse.@stackVars.at;
            stackEntry getVar.topologyIndexWhileMatching 0 < ~ [
              #changed if both branches, we did it
            ] [
              #changed in 'else' branch only
              cacheEntryElse: i @appliedVarsElse.@cacheVars.at;
              @stackEntry @cacheEntryElse stackEntry mergeValues
            ] if
          ] times

          appliedVarsThen.stackVars.size [
            stackEntryVar: i @appliedVarsThen.@stackVars.at getVar;
            -1 @stackEntryVar.@topologyIndexWhileMatching set
          ] times

          appliedVarsElse.stackVars.size [
            stackEntryVar: i @appliedVarsElse.@stackVars.at getVar;
            -1 @stackEntryVar.@topologyIndexWhileMatching2 set
          ] times

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
                  outputElse.mutable outputThen.mutable and @newOutput.setMutable
                  outputElse varIsMoved outputThen varIsMoved and @newOutput.setMoved
                  outputThen outputElse newOutput mergeValuesRec
                  i newNodeThen.outputs.dataSize + longestOutputSize < ~ [newOutput @outputsThen.pushBack] when
                  i newNodeElse.outputs.dataSize + longestOutputSize < ~ [newOutput @outputsElse.pushBack] when
                  @newOutput @processor @block createAllocIR @outputs.pushBack
                ] [
                  ("branch types mismatch; in 'then' type is " outputThen @processor block getMplType "; in 'else' type is " outputElse @processor block getMplType) assembleString @processor block compilerError
                ] if

                isOutputImplicitDerefThen @implicitDerefInfo.pushBack
              ] [
                "branch return cases mismatch" @processor block compilerError
              ] if

              i 1 + @i set processor compilable
            ] &&
          ] loop

          processor compilable [
            i: 0 dynamic;
            [
              i longestInputSize < [
                a: @processor @block pop;
                a @inputs.pushBack
                i newNodeThen.matchingInfo.inputs.dataSize < [a @inputsThen.pushBack] when
                i newNodeElse.matchingInfo.inputs.dataSize < [a @inputsElse.pushBack] when
                i 1 + @i set TRUE
              ] &&
            ] loop

            i: 0 dynamic;
            [
              i outputs.dataSize < [
                outputRef: i @outputs.at;
                outputRef getVar.data.getTag VarStruct = [
                  @outputRef markAsAbleToDie
                  outputRef @block.@candidatesToDie.pushBack
                ] when

                outputRef @block push
                i 1 + @i set TRUE
              ] &&
            ] loop

            processor compilable [
              # create instruction
              #1 prolog, allocate common vars

              createStores: [
                compiledOutputs:;
                branch:;

                i: 0 dynamic;
                [
                  i longestOutputSize < [
                    current: i branch @compiledOutputs getCompiledOutput;
                    curInput: i branch @compiledOutputs getCompiledInput;

                    current.var curInput.var is ~ [
                      curInput isVirtual ~ ["variable states in branches mismatch" @processor block compilerError] when
                      FALSE @curInput getVar.@temporary set
                      @current @curInput @processor @block createCheckedCopyToNewNoDie
                    ] when

                    i 1 + @i set TRUE
                  ] &&
                ] loop
              ];

              wasNestedCall: block.hasNestedCall copy;
              0 refToCond @processor @block createBranch
              @block createLabel
              inputsThen @outputsThen newNodeThen makeCallInstruction
              newNodeThen @outputsThen createStores
              0 @block createJump
              @block createLabel
              wasNestedCall @block.@hasNestedCall set
              inputsElse @outputsElse newNodeElse makeCallInstruction
              newNodeElse @outputsElse createStores
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
    ] if
  ] if
];

processLoop: [
  astNode: processor: block: file: ;;;;
  indexArray: AstNodeType.Code astNode.data.get;
  positionInfo: astNode file makeCompilerPosition;

  iterationNumber: 0 dynamic;
  loopIsDynamic: FALSE;

  [
    newNodeIndex: @indexArray @processor @block tryMatchAllNodes dynamic;
    newNodeIndex 0 < [
      "loop" makeStringView
      block.id
      NodeCaseCode
      indexArray
      file
      positionInfo
      CFunctionSignature
      @processor
      astNodeToCodeNode @newNodeIndex set
    ] when

    newNode: newNodeIndex @processor.@blocks.at.get;
    processor compilable ~ [
      newNode @processor @block useMatchingInfoOnly
      FALSE
    ] [
      newNodeIndex changeNewNodeState
      newNode.state NodeStateHasOutput < [
        FALSE
      ] [
        newNode.state NodeStateHasOutput = [NodeStateHasOutput @block.@state set] when
        appliedVars: newNode applyNodeChanges;

        appliedVars.fixedOutputs.getSize 0 = ["loop body must return Cond" @processor block compilerError] when
        processor compilable [
          condition: newNode.outputs.last.refToVar;
          condVar: condition getVar;
          condVar.data.getTag VarCond = ~ ["loop body must return Cond" @processor block compilerError] when

          processor compilable [
            condition staticityOfVar Weak > [
              appliedVars.stackVars.size [
                stackEntry: i appliedVars.stackVars.at;
                cacheEntry: i appliedVars.cacheVars.at;
                cacheEntry @stackEntry changeVarValue
              ] times

              newNode newNodeIndex @appliedVars applyStackChanges
              a: @processor @block pop;
              VarCond a getVar.data.get.end copy
            ] [
              TRUE dynamic @loopIsDynamic set
              FALSE
            ] if
          ] &&
        ] &&
      ] if
    ] if

    iterationNumber 1 + @iterationNumber set
    iterationNumber processor.options.staticLoopLengthLimit > [
      TRUE @processor.@result.!passErrorThroughPRE
      ("Static loop length limit (" processor.options.staticLoopLengthLimit ") exceeded. Dynamize loop or increase limit using -static_loop_lenght_limit option") assembleString @processor block compilerError
    ] when

    processor compilable and
  ] loop

  loopIsDynamic [indexArray file processDynamicLoop] when
];

processDynamicLoop: [
  indexArray: file:;;

  iterationNumber: 0 dynamic;
  [
    needToRemake: FALSE dynamic;
    newNodeIndex: @indexArray @processor @block tryMatchAllNodes;
    newNodeIndex 0 < [
      "dynamicLoop" makeStringView
      block.id
      NodeCaseCode
      indexArray
      file
      positionInfo
      CFunctionSignature
      @processor astNodeToCodeNode @newNodeIndex set
    ] when

    processor compilable [
      newNode: newNodeIndex @processor.@blocks.at.get;
      newNodeIndex changeNewNodeState

      newNode.state NodeStateHasOutput < [
        FALSE
      ] [
        newNode.state NodeStateHasOutput = [NodeStateHasOutput @block.@state set] when

        appliedVars: newNode applyNodeChanges;

        checkToRecompile: [
          dst:;
          src:;

          result: FALSE dynamic;
          src dst variablesAreSame [
            src dst processor variablesAreEqualForLoop ~ [
              TRUE @result set
            ] when
          ] [
            "loop body changes stack types" @processor block compilerError
          ] if

          result
        ];

        appliedVars.stackVars.size [
          stackEntry: i appliedVars.stackVars.at;
          cacheEntry: i appliedVars.cacheVars.at;

          stackEntry cacheEntry checkToRecompile [
            cacheEntry staticityOfVar Dirty = [
              stackEntry copy @processor @block makeVarDirty
            ] [
              stackEntry copy @processor @block makeVarDynamic
            ] if

            stackEntry copy @processor @block makePointeeDirtyIfRef
            TRUE dynamic @needToRemake set
          ] when
        ] times

        newNode.outputs.dataSize newNode.matchingInfo.inputs.dataSize 1 + = ~ ["loop body must save stack values and return Cond" @processor block compilerError] when
        processor compilable [
          condition: newNode.outputs.last.refToVar;
          condVar: condition getVar;
          condVar.data.getTag VarCond = ~ ["loop body must return Cond" @processor block compilerError] when

          i: 0 dynamic;
          [
            i newNode.matchingInfo.inputs.dataSize < [
              curInput: i @processor block getStackEntry;
              curOutput: newNode.matchingInfo.inputs.dataSize 1 - i - newNode.outputs.at .refToVar;
              curInput curOutput checkToRecompile [
                curInput @processor @block makeVarTreeDynamic
                TRUE dynamic @needToRemake set
              ] when
              i 1 + @i set TRUE
            ] &&
          ] loop
        ] when

        needToRemake ~ processor compilable and [
          inputs:     @processor.acquireVarRefArray;
          nodeInputs: @processor.acquireVarRefArray;
          outputs:    @processor.acquireVarRefArray;

          # apply stack changes
          i: 0 dynamic;
          [
            i newNode.matchingInfo.inputs.dataSize < [
              @processor @block pop @inputs.pushBack
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
                curNodeInput: i inputs.at @processor @block copyVar;
                curNodeInput @nodeInputs.pushBack

                curNodeInput isVirtual ~ [
                  (curNodeInput @processor getIrType "*") assembleString makeStringView # with *
                  curNodeInput @processor getIrName
                  i inputs.at @processor getIrName
                  inputs.dataSize 1 - i - outputs.at @processor getIrName
                  1 @block createPhiNode
                ] when

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
          nodeInputs @outputs newNode makeCallInstruction

          implicitDerefInfo: @processor.@condArray;
          newNode.outputs [.argCase isImplicitDeref @implicitDerefInfo.pushBack] each
          implicitDerefInfo outputs.getSize 1 - @block derefNEntries
          processor.options.verboseIR ["loop end prepare..." @block createComment] when
          1 outputs.last @processor @block createBranch
          @block createLabel

          @inputs     @processor.releaseVarRefArray
          @nodeInputs @processor.releaseVarRefArray
          @outputs    @processor.releaseVarRefArray

          @implicitDerefInfo.clear
        ] when

        needToRemake [
          newNodeIndex processor.blocks.at.get.nodeCompileOnce [
            "loop body compileOnce directive fail" @processor block compilerError
          ] when

          newNodeIndex @processor deleteNode

          iterationNumber processor.options.staticLoopLengthLimit > [
            "loop dynamization iteration count so big" @processor block compilerError
          ] when
        ] when

        iterationNumber 1 + @iterationNumber set

        needToRemake processor compilable and
      ] if
    ] &&
  ] loop
];

{
  block: Block Ref; processor: Processor Ref;
  asCodeRef: Cond; name: StringView Cref; signature: CFunctionSignature Cref;} Natx {} [
  block:;
  processor:;
  overload failProc: processor block FailProcForProcessor;

  copy asCodeRef:;
  name:;
  signature:;
  compileOnce

  @processor addBlock
  declarationNode: @processor.@blocks.last.get;
  block.id @declarationNode.@parent set
  asCodeRef [NodeCaseCodeRefDeclaration][NodeCaseDeclaration] if @declarationNode.@nodeCase set
  signature.variadic @declarationNode.@variadic set

  signature.inputs.getSize [
    r: signature.inputs.getSize 1 - i - signature.inputs.at @processor @block copyVarFromChild;
    @r @processor block unglobalize
    FALSE @r.setMutable
    r @block push
  ] times

  [
    compilerPositionInfo: processor.positions.last copy;
    block: @declarationNode;
    forcedSignature: signature;
    processor.options.debug [
      @processor addDebugReserve @block.@funcDbgIndex set
    ] when
    forcedSignature.inputs   [p:; a: @processor @block pop;] each
    forcedSignature.outputs [@processor @block copyVarFromChild @block push] each
    name compilerPositionInfo forcedSignature @processor @block finalizeCodeNode
  ] call

  signature.inputs   [p:; a: @processor @block pop;] each
  declarationNode storageAddress
] "processImportFunction" exportFunction

{block: Block Ref; processor: Processor Ref; 
  asLambda: Cond; name: StringView Cref; file: File Cref; astNode: AstNode Cref; signature: CFunctionSignature Cref;} Int32 {} [
  block:;
  processor:;
  copy asLambda:;
  name:;
  file:;
  astNode:;
  signature:;
  overload failProc: processor block FailProcForProcessor;

  indexArray: AstNodeType.Code astNode.data.get;
  positionInfo: astNode file makeCompilerPosition;
  compileOnce

  signature.variadic [
    "export function cannot be variadic" @processor block compilerError
  ] when

  ("process export: " makeStringView name makeStringView) addLog

  # we dont know count of used in export entites
  signature.inputs.getSize [
    r: signature.inputs.getSize 1 - i - signature.inputs.at @processor @block copyVarFromChild;
    r @processor @block makeVarTreeDynamic
    @r @processor block unglobalize
    @r fullUntemporize
    r getVar.data.getTag VarRef = [
      @r @processor @block getPointeeNoDerefIR @block push
    ] [
      FALSE @r.setMutable
      r @block push
    ] if
  ] times

  oldSuccess: processor compilable;
  oldRecursiveNodesStackSize: processor.recursiveNodesStack.getSize;

  newNodeIndex: @indexArray @processor @block tryMatchAllNodesForRealFunction;
  newNodeIndex 0 < [
    nodeCase: asLambda [NodeCaseLambda][NodeCaseExport] if;
    processor.exportDepth 1 + @processor.@exportDepth set
    name block.id nodeCase indexArray file positionInfo signature @processor astNodeToCodeNode @newNodeIndex set
    processor.exportDepth 1 - @processor.@exportDepth set
  ] when

  successBeforeCaptures: processor.result.success copy;
  TRUE @processor.@result.@success set

  newNode: newNodeIndex processor.blocks.at.get;
  newNode.matchingInfo.shadowEvents [
    currentEvent:;
    (
      ShadowReasonCapture [
        branch:;

        overloadIndex: outOverloadDepth: branch @block branch.file TRUE getOverloadIndex;;
        gnr: branch.nameInfo branch overloadIndex @processor @block branch.file getNameForMatchingWithOverloadIndex;
        stackEntry: gnr outOverloadDepth @processor @block branch.file captureName.refToVar;
      ]
      []
    ) currentEvent.visit
  ] each

  successBeforeCaptures @processor.@result.@success set

  processor compilable [
    newNodeIndex changeNewExportNodeState

    newNode: newNodeIndex processor.blocks.at.get;
    newNode.outputs.getSize 1 > ["export function cant have 2 or more outputs" @processor block compilerError] when
    newNode.outputs.getSize 1 = [signature.outputs.getSize 0 =] && ["signature is void, export function must be without output" @processor block compilerError] when
    newNode.outputs.getSize 0 = [signature.outputs.getSize 1 =] && ["signature is not void, export function must have output" @processor block compilerError] when
    newNode.state NodeStateCompiled = ~ [
      successBeforeCaptures [
        "can not implement lambda inside itself body" @processor block compilerError
      ] when

      FALSE @oldSuccess set
    ] when

    processor compilable [
      signature.outputs.getSize [
        currentInNode: i newNode.outputs.at.refToVar;
        currentInSignature: i signature.outputs.at;

        currentInNode currentInSignature variablesAreSame ~ [
          ("export function output mismatch, expected " currentInSignature @processor block getMplType ";" LF
            "but found " currentInNode @processor block getMplType) assembleString @processor block compilerError
        ] when
      ] times
    ] when
  ] when

  signature.inputs [p:; a: @processor @block pop;] each

  processor compilable [
    ("successfully processed export: " makeStringView name makeStringView) addLog
  ] [
    ("failed while process export: " makeStringView name makeStringView) addLog
  ] if

  oldSuccess processor compilable ~ and processor.depthOfPre 0 = and processor.result.findModuleFail ~ and [
    @processor.@result.@errorInfo move @processor.@result.@globalErrorInfo.pushBack
    oldRecursiveNodesStackSize @processor.@recursiveNodesStack.shrink
    -1 @processor.@result clearProcessorResult

    signature name FALSE dynamic @processor @block processImportFunction Block addressToReference .id copy !newNodeIndex
  ] when

  newNodeIndex
] "processExportFunction" exportFunction

fixSourcesRec: [
  refToVar:;

  unfinished: @processor.acquireVarRefArray;
  refToVar @unfinished.pushBack

  i: 0 dynamic;

  [
    i unfinished.getSize < [
      current: i @unfinished.at;
      currentVar: @current getVar;
      current @currentVar.@sourceOfValue set
      currentVar.data.getTag VarStruct = [
        VarStruct currentVar.data.get.get.fields [
          .refToVar @unfinished.pushBack
        ] each
      ] when
      i 1 + !i TRUE
    ] &&
  ] loop

  @unfinished @processor.releaseVarRefArray
];

callImportWith: [
  declarationNode: refToVar: dynamicFunc: block:;;;;
  inputs:  @processor.acquireVarRefArray;
  outputs: @processor.acquireVarRefArray;
  (
    [processor compilable]
    [
      i: 0 dynamic;
      [
        i declarationNode.matchingInfo.inputs.dataSize < [
          (
            [processor compilable]
            [stackEntry: @processor @block pop;]
            [
              input: stackEntry copy;
              @input makeVarRealCaptured
              nodeEntry: i @declarationNode.@matchingInfo.@inputs.at.@refToVar;
              nodeMutable: nodeEntry.mutable;
              i declarationNode.csignature.inputs.at getVar.data.getTag VarRef = [
                TRUE @stackEntry getVar.@capturedAsMutable set
              ] when

              stackEntry nodeEntry variablesAreSame ~ [
                lambdaCastResult: input @nodeEntry @processor @block tryImplicitLambdaCast;
                lambdaCastResult.success [
                  lambdaCastResult.refToVar @input set
                ] [
                  ("cant call import, variable types of argument #" i " are incorrect, expected " nodeEntry @processor block getMplType ";" LF "but found " stackEntry @processor block getMplType) assembleString @processor block compilerError
                ] if
              ] when
            ] [
              stackEntry.mutable ~ nodeMutable and [
                ("cant call import, expected mutable argument #" i " with type " nodeEntry @processor block getMplType) assembleString @processor block compilerError
              ] when
            ] [
              nodeMutable [stackEntry @processor @block makeVarTreeDirty] when
              input @inputs.pushBack
            ]
          ) sequence
          i 1 + @i set processor compilable
        ] &&
      ] loop
    ] [
      declarationNode.variadic [
        (
          [processor compilable]
          [refToVarargs: @processor @block pop;]
          [
            varargs: refToVarargs getVar;
            varargs.data.getTag VarStruct = ~ ["varargs must be a struct" @processor block compilerError] when
          ] [
            varStruct: VarStruct varargs.data.get.get;
            varStruct.fields.getSize [
              field: i @refToVarargs @processor @block processStaticAt;
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
          current: currentOutput @processor @block copyVarFromChild;
          current @processor @block makeVarTreeDirty
          current fixSourcesRec

          current @current getVar.@sourceOfValue set
          Dynamic makeValuePair @current getVar.@staticity set
          current @outputs.pushBack
          current getVar.data.getTag VarStruct = [
            current @block.@candidatesToDie.pushBack
          ] when

          i 1 + @i set processor compilable
        ] &&
      ] loop
    ] [
      forcedName: StringView;
      inputs @outputs declarationNode forcedName refToVar dynamicFunc @block makeCallInstructionWith
      i: 0 dynamic;
      [
        i outputs.getSize < [
          currentOutput: i outputs.at;
          currentOutput @block push
          i 1 + @i set processor compilable
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

{block: Block Ref; processor: Processor Ref;
  refToVar: RefToVar Cref;} () {} [
  block:;
  processor:;
  overload failProc: processor block FailProcForProcessor;

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
      "nullpointer call" @processor block compilerError
    ] when
  ] when

  @node refToVar dynamicFunc @block callImportWith
] "processFuncPtr" exportFunction
