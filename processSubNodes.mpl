# Copyright (C) 2021 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"Array"     use
"HashTable" use
"String"    use
"algorithm" use
"control"   use

"Block"        use
"MplFile"      use
"Var"          use
"astNodeType"  use
"codeNode"     use
"debugWriter"  use
"declarations" use
"defaultImpl"  use
"irWriter"     use
"logger"       use
"processor"    use
"staticCall"   use
"variable"     use

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

varibaleAreEqualBody: [
  e1Checker: e2Checker: ;;

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

      cacheEntryVar.storageStaticity stackEntryVar.storageStaticity = ~ [
        makeMessage [
          ("variables has different storageStaticity; was " cacheEntryVar.storageStaticity " but now " stackEntryVar.storageStaticity) assembleString @comparingMessage set
        ] when
        FALSE
      ] [
        stackEntryVar.data.getTag VarStruct = [
          cacheStaticity: cacheEntryVar.staticity e1Checker new;
          stackStaticity: stackEntryVar.staticity e2Checker new;

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
          cacheStaticity: cacheEntryVar.staticity e1Checker new;
          stackStaticity: stackEntryVar.staticity e2Checker new;

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
                  cacheValue: tag cacheEntryVar.data.get;
                  stackValue: tag stackEntryVar.data.get;

                  cacheValue e1Checker
                  stackValue e2Checker =
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
  ] if

];

{processor: Processor Cref; comparingMessage: String Ref; makeMessage: Cond; cacheEntry: RefToVar Cref; stackEntry: RefToVar Cref;} Cond {} [
  [.begin] [.begin] @varibaleAreEqualBody ucall
] "variablesAreEqualForTree" exportFunction

{processor: Processor Cref; comparingMessage: String Ref; makeMessage: Cond; cacheEntry: RefToVar Cref; stackEntry: RefToVar Cref;} Cond {} [
  [.begin] [.end] @varibaleAreEqualBody ucall
] "variablesAreEqualForMatching" exportFunction

{forLoop: Cond; processor: Processor Cref; cacheEntry: RefToVar Cref; stackEntry: RefToVar Cref; } Cond {} [
  stackEntry: cacheEntry: processor: forLoop: ;;;;

  cacheEntry stackEntry variablesAreSame [cacheEntry stackEntry processor variablesHaveSameGlobality] && [
    cacheEntryVar: cacheEntry getVar;
    stackEntryVar: stackEntry getVar;

    stackEntryVar.data.getTag VarStruct = [
      cacheStaticity: cacheEntryVar.staticity.end new;
      stackStaticity: stackEntryVar.staticity.end new;

      cacheStaticity Dynamic = [Static !cacheStaticity] when
      stackStaticity Dynamic = [Static !stackStaticity] when

      cacheStaticity stackStaticity = [
        cacheStruct: VarStruct cacheEntryVar.data.get.get;
        cacheStruct.hasDestructor ~ [cacheEntry varIsMoved stackEntry varIsMoved =] ||
      ] &&
    ] [
      cacheStaticity: cacheEntryVar.staticity.end new;
      stackStaticity: stackEntryVar.staticity.end new;

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

{processor: Processor Cref; makeMessage: Cond; comparingMessage: String Ref; checkConstness: Cond; forMatching: Cond; cacheEntry: RefToVar Cref; stackEntry: RefToVar Cref;} Cond {} [
  stackEntry: cacheEntry: forMatching: checkConstness: comparingMessage: makeMessage:  processor:;;;;;;;

  checkConstness ~ [cacheEntry.mutable stackEntry.mutable =] || [
    forMatching [
      stackEntry cacheEntry makeMessage @comparingMessage processor variablesAreEqualForMatching
    ] [
      stackEntry cacheEntry makeMessage @comparingMessage processor variablesAreEqualForTree
    ] if [
      TRUE
    ] [
      FALSE
    ] if
  ] [
    makeMessage ["variables have different constness" toString @comparingMessage set] when
    FALSE
  ] if
] "compareOnePair" exportFunction

getOverloadIndex: [
  cap: block: file: forMathing: ;;;;
  overloadDepth: cap.nameOverloadDepth new;
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
        branch.stable [
          ("shadow event [" i "] capture " branch.nameInfo processor.nameManager.getText " as stable" LF) @message.catMany
        ] [
          ("shadow event [" i "] capture " branch.nameInfo processor.nameManager.getText "(" branch.nameOverloadDepth ") index " branch.refToVar getVar.topologyIndex " type " branch.refToVar @processor @block getMplType LF) @message.catMany
          branch.mplFieldIndex 0 < ~ [("  as field " branch.mplFieldIndex " in object" LF) @message.catMany] when
        ] if
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

addEventVarWhileMatching: [
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
        [
          topologyIndex eventVars.size = [
            message: String;
            currentMatchingNode.matchingInfo.shadowEvents.size 1 - @currentMatchingNode @message catShadowEvents
            message print
            FALSE
          ] ||
        ] "Topology indexes are not sequenced!" assert
        topologyIndex 1 + @eventVars.enlarge
        topologyIndex @stackEntry getVar.@topologyIndexWhileMatching set
        stackEntry topologyIndex @eventVars.at set
      ] if
    ] if
  ] when

  success
];

tryMatchNode: [
  currentMatchingNode:;
  comparingMessage: String;

  currentMatchingNode.changedStableName [currentMatchingNode.nodeCompileOnce new] && [
    "in compile-once node stable name changed" @processor block compilerError
  ] when

  labmdaMismatch: currentMatchingNode.hasEmptyLambdas [
    topNode: block.topNode;
    [topNode.file isNil ~] "Topnode in nil file!" assert
    topNode.file.usedInParams new
  ] &&;

  labmdaMismatch [currentMatchingNode.nodeCompileOnce new] && [
    "in compile-once node was empty lambda, because it was called from unused module" @processor block compilerError
  ] when

  canMatch: currentMatchingNode.deleted ~ [currentMatchingNode.changedStableName ~] && [labmdaMismatch ~] && [
    currentMatchingNode.state NodeStateCompiled =
    currentMatchingNode.state NodeStateFailed = or [
      #recursive condition
      currentMatchingNode.nodeIsRecursive
      [currentMatchingNode.recursionState NodeRecursionStateFail = ~] &&
      [
        currentMatchingNode.state NodeStateNew =
        [currentMatchingNode.state NodeStateHasOutput = [currentMatchingNode.recursionState NodeRecursionStateOld =] &&] ||
        [forceRealFunction new] ||
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
    gnr: currentMatchingNode.varNameInfo @processor @block File Cref getNameForMatching;
    gnr.refToVar.assigned ~
  ] &&;

  canMatch invisibleName ~ and goodReality and
];

{processor: Processor Ref; block: Block Ref; forceRealFunction: Cond; astArrayIndex: Int32;} Int32 {} [
  processor:;
  block:;

  overload failProc: processor block FailProcForProcessor;

  forceRealFunction:;
  astArrayIndex:;

  compileOnce
  astArrayIndex processor.matchingNodes.size < [astArrayIndex processor.matchingNodes.at.valid?] && [
    matchingNode: astArrayIndex @processor.@matchingNodes.at.get;
    matchingNode.entries 1 + @matchingNode.@entries set

    findInIndexArray: [
      where:;

      result: -1 dynamic;
      i: 0 dynamic;
      [
        i where.size < [
          matchingNode.tries 1 + @matchingNode.@tries set
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

    #find-in-tree way
    result: -1 dynamic;
    currentEntryIndex: 0 dynamic;
    eventVars: @processor.acquireVarRefArray;

    success: FALSE dynamic;
    continueSearch: TRUE dynamic;
    comparingMessage: String;
    matchingNodeStackDepth: 0 dynamic;

    addEventVar: [
      stackEntry: eventVars: ;;

      stackEntry noMatterToCopy ~ [
        stackEntry getVar.topologyIndexWhileMatching 0 < [
          eventVars.size @stackEntry getVar.@topologyIndexWhileMatching set
          stackEntry @eventVars.append
        ] when
      ] when
    ];

    [
      currentMemory: currentEntryIndex matchingNode.treeMemory.at;
      currentMemory.childIndices.size 0 = [
        TRUE !success
        FALSE !continueSearch
      ] [
        pattern: 0 currentMemory.childIndices @ .childIndex matchingNode.treeMemory.at.parentEvent;

        matchingFakeEvent: pattern new;

        #step1: get our hash of event
        (
          ShadowReasonInput [
            branch:;
            stackEntry: matchingNodeStackDepth @processor block getStackEntryUnchecked;
            stackEntry @branch.@refToVar set
            stackEntry @eventVars addEventVar
            matchingNodeStackDepth 1 + !matchingNodeStackDepth
          ]
          ShadowReasonCapture [
            branch:;

            overloadIndex: outOverloadDepth: branch @block branch.file TRUE getOverloadIndex;;
            gnr: branch.nameInfo overloadIndex @processor @block branch.file getNameForMatchingWithOverloadIndex;

            branch.file gnr processor nameResultIsStable @branch.@stable set
            stackEntry: gnr.mplFieldIndex 0 < [gnr.refToVar] [gnr.object] if;

            stackEntry @branch.@refToVar set
            stackEntry @eventVars addEventVar
          ]
          ShadowReasonPointee [
            branch:;
            stackPointer: branch.pointer getVar.topologyIndex eventVars.at;
            stackEntry: stackPointer @processor @block getPointeeForMatching;

            stackPointer @branch.@pointer set
            stackEntry   @branch.@pointee set
            stackEntry   @eventVars addEventVar
          ]
          ShadowReasonField [
            branch:;
            stackObject: branch.object getVar.topologyIndex eventVars.at;
            stackEntry: branch.mplFieldIndex stackObject @processor @block getFieldForMatching;

            stackObject @branch.@object set
            stackEntry  @branch.@field set
            stackEntry  @eventVars addEventVar
          ]
          ShadowReasonTreeSplitterLambda [
            branch:;

            processor.options.partial ~ [
              topNode: block.topNode;
              [topNode.file isNil ~] "Topnode in nil file!" assert
              topNode.file.usedInParams new
            ] || @branch set
          ]
          []
        ) @matchingFakeEvent.visit

        continueSearch [
          eventHash: matchingFakeEvent TRUE dynamic @processor @block getShadowEventHash;

          candidates: @currentMemory.@childIndices;
          candidateIndex: -1 dynamic;

          candidates [
            prevVersion:;
            candidateIndex 0 < [
              eventHash prevVersion.eventHash = [
                prevVersionEvent: prevVersion.childIndex matchingNode.treeMemory.at.parentEvent;
                matchingFakeEvent prevVersionEvent @comparingMessage TRUE dynamic @processor compareEvents
              ] && [
                prevVersion.childIndex @candidateIndex set
              ] when
            ] when
          ] each

          candidateIndex 0 < [
            TRUE !success #may be we can find it in
            FALSE !continueSearch
          ] [
            currentMemory.nodeIndexes.size 0 > [
              TRUE !success #may be we can find it in
              FALSE !continueSearch
            ] [
              candidateIndex @currentEntryIndex set
            ] if
          ] if
        ] when
      ] if

      continueSearch new
    ] loop

    eventVars [
      refToVar:;
      -1 @refToVar getVar.@topologyIndexWhileMatching set
    ] each

    @eventVars @processor.releaseVarRefArray

    success [
      currentMemory: currentEntryIndex matchingNode.treeMemory.at;
      currentMemory.nodeIndexes findInIndexArray @result set
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
  i: block.id new;
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
  newNodeIndex: new;
  newNode: newNodeIndex @processor.@blocks.at.get;
  newNode.state NodeStateNew = [
    [newNode.nodeIsRecursive new] "new node must be recursive!" assert
    fixRecursionStack
    NodeRecursionStateNew @newNode.@recursionState set

    processor.recursiveNodesStack.getSize 0 = [processor.recursiveNodesStack.last newNodeIndex = ~] || [
      newNodeIndex @processor.@recursiveNodesStack.append
    ] when

    NodeStateNoOutput @block.@state set
  ] [
    newNode.state NodeStateNoOutput = [
      NodeStateNoOutput @block.@state set
    ] [
      newNode.recursionState NodeRecursionStateNo > [
        [newNode.nodeIsRecursive new] "new node must be recursive!" assert
        fixRecursionStack
      ] when

      newNode.recursionState NodeRecursionStateFail > [newNode.state NodeStateHasOutput =] || [NodeStateHasOutput @block.@state set] when
    ] if
  ] if
];

changeNewExportNodeState: [
  newNodeIndex: new;
  newNode: newNodeIndex @processor.@blocks.at.get;
  newNode.state NodeStateNew = [
    [newNode.nodeIsRecursive new] "new node must be recursive!" assert
    fixRecursionStack
    NodeRecursionStateNew @newNode.@recursionState set

    processor.recursiveNodesStack.getSize 0 = [processor.recursiveNodesStack.last newNodeIndex = ~] || [
      newNodeIndex @processor.@recursiveNodesStack.append
    ] when

    NodeStateHasOutput @block.@state set
  ] [
    newNode.state NodeStateNoOutput = [
      NodeStateHasOutput @block.@state set
    ] [
      newNode.recursionState NodeRecursionStateNo > [
        [newNode.nodeIsRecursive new] "new node must be recursive!" assert
        fixRecursionStack
      ] when

      newNode.recursionState NodeRecursionStateFail > [newNode.state NodeStateHasOutput =] || [NodeStateHasOutput @block.@state set] when
    ] if
  ] if
];

fixRef: [
  refToVar: appliedVars:; new;

  var: @refToVar getVar;
  wasVirtual: refToVar isVirtual;
  makeDynamic: FALSE dynamic;
  pointee: VarRef @var.@data.get.@refToVar;
  pointeeVar: pointee getVar;

  pointeeIsLocal: pointeeVar.capturedHead getVar.host currentChangesNode is;
  pointeeWasNotUsed: pointeeVar.host currentChangesNode is ~;
  fixed: pointee new;

  pointeeWasNotUsed [
  ] [
    pointeeIsLocal ~ [ # has shadow - captured from top
      index: pointeeVar.topologyIndex new;
      index 0 < ~ [
        index appliedVars.stackVars.at @fixed set
      ] [
        #pointee @processor @block copyVarFromChild @fixed set
        #TRUE dynamic @makeDynamic set
      ] if
    ] [
      # dont have shadow - to deref of captured dynamic pointer
      # must by dynamic
      var.staticity.end Static = [pointeeVar.storageStaticity Static =] && [
        "returning pointer to local variable" @processor block compilerError
      ] when

      #pointee getVar.host currentChangesNode is ~

      #pointee @processor @block copyOneVarFromType Dynamic @processor @block makeStorageStaticity @fixed set
      TRUE dynamic @makeDynamic set
    ] if
  ] if

  @fixed.var @pointee.setVar

  wasVirtual [
    @refToVar Virtual @processor block makeStaticity @refToVar set
  ] when

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
  stackEntry @unfinishedStack.append

  i: 0 dynamic;
  [
    i unfinishedStack.size < [
      currentFromStack: i @unfinishedStack.at new;
      stackEntryVar: @currentFromStack getVar;
      sourceVar: stackEntryVar.sourceOfValue getVar;

      currentFromStack noMatterToCopy [
        #do nothing
      ] [
        sourceVar.host block is [
          [currentFromStack hasGoodSource] "Stack var source invariant failed!" assert
        ] [
          sourceVar.host currentChangesNode is [
            sourceIndex: sourceVar.topologyIndex new;
            sourceIndex 0 < ~ [
              sourceIndex appliedVars.stackVars.at @stackEntryVar.@sourceOfValue set
            ] [
              currentFromStack @stackEntryVar.@sourceOfValue set
            ] if
          ] [
            "Source of value is unknown!" failProc
          ] if

          [currentFromStack hasGoodSource] "Stack var source invariant failed!" assert

          stackEntryVar.data.getTag VarRef = [
            stackPointee: VarRef @stackEntryVar.@data.get.@refToVar;
            stackPointee getVar.host currentChangesNode is [
              fixedPointer: currentFromStack appliedVars fixRef;
              fixedPointer staticityOfVar Dynamic > [
                fixed: fixedPointer @processor @block getPointeeNoDerefIR;
                fixed @unfinishedStack.append
              ] when
            ] [
              sourceVar.topologyIndex 0 < ~ [
                stackEntryOfSource: sourceVar.topologyIndex @appliedVars.@stackVars.at;
                stackPointeeBySource: VarRef @stackEntryOfSource getVar.@data.get.@refToVar;
                stackPointeeBySource getVar.host.id block.id = [
                  @stackPointeeBySource getVar @stackPointee.setVar
                ] when
              ] when
            ] if
          ] [
            stackEntryVar.data.getTag VarStruct = [
              stackStruct: VarStruct stackEntryVar.data.get.get;
              j: 0 dynamic;
              [
                j stackStruct.fields.size < [
                  stackEntryVar.storageStaticity Static = [j stackStruct.fields.at.usedHere new] || [
                    stackField: j currentFromStack @processor @block getField;
                    stackField @unfinishedStack.append
                  ] when

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
            topologyIndexOfPointee: cachePointee getVar.topologyIndex new;
            topologyIndexOfPointee 0 < [
              cachePointee getVar.storageStaticity Dynamic = [
                #here dont need to do something
              ] [
                cachePointee getVar.storageStaticity Virtual = [
                  cachePointee @processor @block getLastShadow getVar @cachePointee.setVar
                ] [
                  cachePointee isUnallocable [
                    #its ok
                  ] [
                    "returning pointer to local variable" @processor block compilerError
                  ] if
                ] if
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

    [stackEntry cacheEntry variablesAreSame
      [
        (
          "Stack entry type is " stackEntry @processor @block getMplType LF
          "cache entry type is " cacheEntry @processor @block getMplType LF
        ) printList
        FALSE
      ] ||
    ] "Applied vars has different type!" assert

    stackEntry noMatterToCopy ~ [
      [stackEntry getVar.host.id block.id =] "Stack entry is not from here!" assert

      topologyIndex: cacheEntry getVar.topologyIndex new;
      [topologyIndex 0 < ~] "Shadow event index is negative!" assert
      topologyIndex appliedVars.stackVars.size < ~ [
        topologyIndex 1 + @appliedVars.@stackVars.enlarge
        topologyIndex 1 + @appliedVars.@cacheVars.enlarge
        stackEntry topologyIndex @appliedVars.@stackVars.at set
        cacheEntry topologyIndex @appliedVars.@cacheVars.at set
        [cacheEntry noMatterToCopy [cacheEntry getVar.host cacheEntry getVar.sourceOfValue getVar.host is] ||] "Val source incorrest!" assert
      ] when

      cacheEntry getVar.capturedByPtr [
        stackEntry makeVarPtrCaptured
      ] when

      cacheEntry getVar.capturedAsRealValue [
        stackEntry @processor @block makeVarRealCaptured
      ] when

      cacheEntry getVar.capturedForDeref [
        stackEntry makeVarDerefCaptured
      ] when
    ] when
  ];

  currentChangesNode.matchingInfo.shadowEvents.size [
    processor compilable [
      shadowEventIndex: i new;
      currentEvent: shadowEventIndex currentChangesNode.matchingInfo.shadowEvents.at;
      (
        ShadowReasonInput [
          branch:;
          stackEntry: @processor @block popForMatching;
          cacheEntry: branch.refToVar;
          stackEntry cacheEntry @appliedVars addAppliedVar
          stackEntry @pops.append
        ]
        ShadowReasonCapture [
          branch:;
          branch.stable [
            branch.refToVar branch.nameInfo branch.nameOverloadDepth branch.file @processor @block addStableName
          ] [
            cacheEntry: branch.refToVar;
            overloadIndex: outOverloadDepth: branch @block branch.file TRUE getOverloadIndex;;
            gnr: branch.nameInfo overloadIndex @processor @block branch.file getNameForMatchingWithOverloadIndex;
            cnr: gnr outOverloadDepth @processor @block branch.file captureName;
            stackEntry: cnr.matchingEntry;

            [stackEntry cacheEntry variablesAreSame
              [
                (
                  "astArrayIndex " currentChangesNode.astArrayIndex "; nodeIndex " currentChangesNode.id LF
                  "shadowEventIndex " shadowEventIndex " of " currentChangesNode.matchingInfo.shadowEvents.size LF
                  "capture name is " branch.nameInfo processor.nameManager.getText LF
                  "stack entry is " stackEntry @processor @block getMplType LF
                  "cache entry is " cacheEntry @processor @block getMplType LF) printList

                currentChangesNode.astArrayIndex @processor @block printAstArrayTree

                FALSE
              ] ||
            ] "Applied vars has different type!" assert

            stackEntry cacheEntry @appliedVars addAppliedVar
          ] if
        ]
        ShadowReasonPointee [
          branch:;

          cacheEntry: branch.pointee;
          stackPointer: branch.pointer getVar.topologyIndex @appliedVars.@stackVars.at;

          stackEntry: @stackPointer @processor @block getPointeeNoDerefIR;
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
        ShadowReasonTreeSplitterLambda [
          branch:;
          branch new @processor @block addLambdaEvent
        ]
        []
      ) @currentEvent.visit
    ] when
  ] times

  currentChangesNode.capturedFiles.getSize [
    i currentChangesNode.capturedFiles.at [
      i @block captureFileToBlock
    ] when
  ] times

  currentChangesNode.hasEmptyLambdas [
    @block setBlockEmptyLambdas
  ] when

  i: 0 dynamic;
  [
    i pops.size < [
      pops.size i - 1 - pops.at @block pushForMatching
      i 1 + @i set processor compilable
    ] &&
  ] loop

  appliedVars.stackVars.size [
    stackEntryVar: i @appliedVars.@stackVars.at getVar;
    i @stackEntryVar.@topologyIndexWhileMatching set
  ] times

  i: 0 dynamic;
  [
    i currentChangesNode.outputs.size < [
      currentOutput: i currentChangesNode.outputs.at;
      outputRef: currentOutput.refToVar @processor @block copyVarFromChild; # output is to inner var

      outputRef appliedVars fixOutputRefsRec # it is End
      outputRef @appliedVars.@fixedOutputs.append
      i 1 + @i set processor compilable
    ] &&
  ] loop

  currentChangesNode.hasCallTrace [
    TRUE @block.@hasCallTrace set
  ] when

  currentChangesNode.hasCallImport [
    TRUE @block.@hasCallImport set
  ] when

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

    varSrc.staticity.end @varDst.@staticity.@end set
    dst isPlain [
      varDst.data.getTag VarCond VarReal64 1 + [
        tag: new;
        srcBranch: tag varSrc.data.get;
        dstBranch: tag @varDst.@data.get;
        srcBranch.end @dstBranch.@end set
      ] staticCall
    ] [
      varDst.data.getTag VarRef = [
        srcBranch: VarRef varSrc.data.get;
        dstBranch: VarRef @varDst.@data.get;
        srcBranch.refToVar @dstBranch.@refToVar set
      ] when
    ] if
  ] when
];

isImplicitDeref: [
  case: new;
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
  currentChangesNodeIndex: new dynamic;
  newNode:;
  compileOnce

  inputs: @processor.acquireVarRefArray;
  outputs: @processor.acquireVarRefArray;

  i: 0 dynamic;
  [
    i newNode.matchingInfo.inputs.getSize < [
      @processor @block popForMatching @inputs.append
      i 1 + @i set TRUE
    ] &&
  ] loop

  newNode.matchingInfo.inputs.getSize @block updateInputCount

  i: 0 dynamic;
  [
    i appliedVars.fixedOutputs.getSize < [
      outputRef: i @appliedVars.@fixedOutputs.at;
      outputRef @outputs.append
      outputRef getVar.data.getTag VarStruct = [
        @outputRef markAsAbleToDie
        outputRef @block.@candidatesToDie.append
      ] when
      outputRef @block push
      i 1 + @i set TRUE
    ] &&
  ] loop

  processor compilable [
    inputs @outputs newNode forcedName makeNamedCallInstruction

    implicitDerefInfo: @processor.@condArray;
    newNode.outputs [.argCase isImplicitDeref @implicitDerefInfo.append] each
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
  processor:;
  hasCallTrace: new;
  dynamicFunc: new;
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
        i newNode.matchingInfo.inputs.at.argCase new
      ] [
        ArgCopy
      ] if;

      currentInput: i inputs.at;

      currentInputArgCase ArgVirtual = currentInputArgCase ArgGlobal = or currentInputArgCase ArgMeta = or [
      ] [
        arg: IRArgument;
        currentInput getVar.irNameId @arg.@irNameId set
        currentInput @processor getMplSchema.irTypeId @arg.@irTypeId set
        currentInputArgCase ArgRef = [currentInputArgCase ArgRefDeref =] || @arg.@byRef set
        currentInputArgCase ArgCopy = [
          currentInput @processor @block createDerefToRegister @arg.@irNameId set
        ] when

        arg @argList.append
      ] if

      i 1 + @i set TRUE
    ] &&
  ] loop

  i: 0 dynamic;
  [
    i newNode.outputs.size < [
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

          arg @argList.append
        ] if
      ] if

      i 1 + @i set TRUE
    ] &&
  ] loop

  i: 0 dynamic;
  [
    i newNode.matchingInfo.captures.size < [
      currentCapture: i newNode.matchingInfo.captures.at;

      currentRefToVar: currentCapture.refToVar;

      currentRefToVar.assigned [
        currentCapture.argCase ArgRef = currentCapture.argCase ArgCopy = or currentCapture.argCase ArgDerefCopy = or  [
          overloadIndex: outOverloadDepth: currentCapture @block currentCapture.file FALSE getOverloadIndex;;
          cnr: currentCapture.nameInfo overloadIndex @processor @block currentCapture.file getNameForMatchingWithOverloadIndex outOverloadDepth @processor @block currentCapture.file captureName;
          refToVar: cnr.matchingEntry;
          [currentRefToVar refToVar variablesAreSame] "invalid capture type while generating arg list!" assert

          arg: IRArgument;
          refToVar getVar.irNameId @arg.@irNameId set
          refToVar @processor getMplSchema.irTypeId @arg.@irTypeId set
          currentCapture.argCase ArgRef = [currentCapture.argCase ArgRefDeref =] || @arg.@byRef set

          currentCapture.argCase ArgCopy = [
            refToVar @processor @block createDerefToRegister @arg.@irNameId set
          ] [
            currentCapture.argCase ArgDerefCopy = [
              currentPointee: VarRef refToVar getVar.data.get.refToVar;
              currentPointee @processor getMplSchema.irTypeId @arg.@irTypeId set
              pointeeName: refToVar @processor @block createDerefToRegister;
              pointeeName arg.irTypeId @processor @block createDerefFromRegisterToRegister @arg.@irNameId set
            ] when
          ] if

          arg @argList.append
        ] when
      ] when

      i 1 + @i set TRUE
    ] &&
  ] loop

  dynamicFunc newNode.empty ~ or [
    pureFuncName: forcedName "" = [dynamicFunc [refToVar @processor getIrName][newNode.irName makeStringView] if][forcedName new] if;
    funcName: newNode.variadic [("(" newNode.argTypes ") " pureFuncName) assembleString][pureFuncName toString] if;
    convName: newNode.convention;
    retName: argRet argList convName funcName hasCallTrace [newNode.hasCallTrace new] || @processor @block createCallIR;

    argRet.var isNil ~ [
      @retName argRet @processor @block createStoreFromRegister
    ] when
  ] when

  @argList.clear
];

makeNamedCallInstruction: [
  r: RefToVar;
  r FALSE dynamic FALSE dynamic @processor @block makeCallInstructionWith
];

makeCallInstruction: [
  r: RefToVar;
  forcedName: StringView dynamic;
  forcedName r FALSE dynamic FALSE dynamic @processor @block makeCallInstructionWith
];

processNamedCallByNode: [
  forcedName:;
  newNodeIndex: new dynamic;
  newNode: newNodeIndex processor.blocks.at.get;
  compileOnce

  newNodeIndex changeNewNodeState
  newNode.state NodeStateNoOutput = [
    newNode TRUE @processor @block useMatchingInfoOnly
  ] [
    appliedVars: newNode applyNodeChanges;

    appliedVars.stackVars.size [
      stackEntry: i appliedVars.stackVars.at;
      cacheEntry: i appliedVars.cacheVars.at;
      cacheEntry @stackEntry changeVarValue
    ] times

    newNode newNodeIndex @appliedVars forcedName applyNamedStackChanges
  ] if
];

processCallByNode: [
  forcedName: StringView dynamic;
  forcedName processNamedCallByNode
];

useMatchingInfoOnly: [
  newNode: useArgStatus: processor: block: ;;;;

  eventVars: @processor.acquireVarRefArray;
  pops: @processor.acquireVarRefArray;

  addEventVar: [
    stackEntry: cacheEntry: ;;
    stackEntry noMatterToCopy ~ [
      index: cacheEntry getVar.topologyIndex;
      index eventVars.size < ~ [
        index 1 + @eventVars.resize
        stackEntry index @eventVars.at set
      ] when

      useArgStatus [
        cacheEntry getVar.capturedByPtr [
          stackEntry makeVarPtrCaptured
        ] when

        cacheEntry getVar.capturedAsRealValue [
          stackEntry @processor @block makeVarRealCaptured
        ] when

        cacheEntry getVar.capturedForDeref [
          stackEntry makeVarDerefCaptured
        ] when
      ] when
    ] when
  ];

  oldSuccess: processor.result.success new;
  TRUE @processor.@result.@success set
  oldSuccess @processor.@canBuildTree set

  newNode.matchingInfo.shadowEvents [
    event:;
    (
      ShadowReasonInput [
        branch:;
        cacheEntry: branch.refToVar;
        stackEntry: @processor @block popForMatching;
        stackEntry cacheEntry addEventVar
        stackEntry @pops.append
      ]
      ShadowReasonCapture [
        branch:;
        branch.stable [
          branch.refToVar branch.nameInfo branch.nameOverloadDepth branch.file @processor @block addStableName
        ] [
          cacheEntry: branch.refToVar;
          overloadIndex: outOverloadDepth: branch @block branch.file TRUE getOverloadIndex;;
          gnr: branch.nameInfo overloadIndex @processor @block branch.file getNameForMatchingWithOverloadIndex;
          cnr: gnr outOverloadDepth @processor @block branch.file captureName;
          stackEntry: cnr.matchingEntry;
          stackEntry cacheEntry addEventVar
        ] if
      ]
      ShadowReasonPointee [
        branch:;
        cacheEntry: branch.pointee;
        stackEntry: branch.pointer getVar.topologyIndex @eventVars.at @processor @block getPointeeNoDerefIR;
        stackEntry cacheEntry addEventVar
      ]
      ShadowReasonField [
        branch:;
        cacheEntry: branch.field;
        stackEntry: branch.mplFieldIndex branch.object getVar.topologyIndex eventVars.at @processor @block getField;
        stackEntry cacheEntry addEventVar
      ]
      ShadowReasonTreeSplitterLambda [
        branch:;
        branch new @processor @block addLambdaEvent
      ]
      []
    ) event.visit
  ] each

  TRUE @processor.@canBuildTree set

  i: 0 dynamic;
  [
    i pops.size < [
      pops.size i - 1 - pops.at @block pushForMatching
      i 1 + @i set processor compilable
    ] &&
  ] loop

  @pops @processor.releaseVarRefArray

  newNode.capturedFiles.getSize [
    i newNode.capturedFiles.at [
      i @block captureFileToBlock
    ] when
  ] times

  @eventVars @processor.releaseVarRefArray
  oldSuccess @processor.@result.@success set
];

{block: Block Ref; processor: Processor Ref; name: StringView Cref; nodeCase: NodeCaseCode; astArrayIndex: Int32;} () {} [
  block:;
  processor:;
  name:;
  nodeCase: new;
  astArrayIndex:;

  overload failProc: processor block FailProcForProcessor;

  forcedNameString: String;

  newNodeIndex: astArrayIndex @processor @block tryMatchAllNodes;
  newNodeIndex 0 < [
    name
    block.id
    nodeCase
    astArrayIndex
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
      result @block.@candidatesToDie.append
    ] [
      forcedName: forcedNameString makeStringView dynamic;
      newNodeIndex forcedName processNamedCallByNode
    ] if
  ] [
    newNode FALSE @processor @block useMatchingInfoOnly
  ] if
] "processCallByIndexArray" exportFunction

{block: Block Ref; processor: Processor Ref; name: StringView Cref; astArrayIndex: Int32;} () {} [
  block:;
  processor:;
  name:;
  astArrayIndex:;
  overload failProc: processor block FailProcForProcessor;
  astArrayIndex NodeCaseCode dynamic name @processor @block processCallByIndexArray
] "processCall" exportFunction

{block: Block Ref; processor: Processor Ref; preAstArrayIndex: Int32;} Cond {} [
  block:;
  processor:;
  preAstArrayIndex:;
  overload failProc: processor block FailProcForProcessor;

  processor compilable [
    oldSuccess: processor compilable;
    oldGlobalErrorCount: processor.result.globalErrorInfo.getSize;

    newNodeIndex: preAstArrayIndex @processor @block tryMatchAllNodes;
    newNodeIndex 0 < [
      processor.depthOfPre 1 + @processor.@depthOfPre set
      "PRE" makeStringView block.id NodeCaseCode preAstArrayIndex CFunctionSignature @processor astNodeToCodeNode @newNodeIndex set
      processor.depthOfPre 1 - @processor.@depthOfPre set
    ] when

    newNode: newNodeIndex processor.blocks.at.get;
    newNode FALSE @processor @block useMatchingInfoOnly

    oldGlobalErrorCount @processor.@result.@globalErrorInfo.shrink
    oldSuccess [
      processor.@result.passErrorThroughPRE ~ [-1 @processor.@result clearProcessorResult] when
    ] [
      "Has compilerError before trying compiling pre!" failProc
    ] if

    newNode.uncompilable ~ [
      badResult: [
        TRUE dynamic @processor.@result.@passErrorThroughPRE set
        "PRE code must fail or return static Cond" @processor block compilerError
        FALSE
      ];

      newNode.state NodeStateNoOutput = [
        NodeStateNoOutput @block.@state set
        FALSE
      ] [
        newNode.outputs.size 0 = [
          badResult
        ] [
          top: newNode.outputs.last.refToVar;
          top getVar.data.getTag VarCond =
          [top staticityOfVar Weak < ~] && [
            VarCond top getVar.data.get.end new
          ] [
            badResult
          ] if
        ] if
      ] if
    ] &&
  ] [
    FALSE
  ] if
] "processPre" exportFunction

{
  block: Block Ref; processor: Processor Ref;
  astArrayIndexThen: Int32;
  astArrayIndexElse: Int32;
  refToCond: RefToVar Cref;
} () {} [
  processor: block: ;;

  astArrayIndexThen:;
  astArrayIndexElse:;
  refToCond:;

  overload failProc: processor block FailProcForProcessor;

  newNodeThenIndex: @astArrayIndexThen @processor @block tryMatchAllNodes;
  newNodeThenIndex 0 < [
    "ifThen" makeStringView
    block.id
    NodeCaseCode
    astArrayIndexThen
    CFunctionSignature
    @processor astNodeToCodeNode @newNodeThenIndex set
  ] when

  newNodeThen: newNodeThenIndex @processor.@blocks.at.get;
  processor compilable ~ [
    newNodeThen FALSE @processor @block useMatchingInfoOnly
  ] [
    newNodeElseIndex: @astArrayIndexElse @processor @block tryMatchAllNodes;
    newNodeElseIndex 0 < [
      "ifElse" makeStringView
      block.id
      NodeCaseCode
      astArrayIndexElse
      CFunctionSignature
      @processor
      astNodeToCodeNode @newNodeElseIndex set
    ] when

    newNodeElse: newNodeElseIndex @processor.@blocks.at.get;

    processor compilable ~ [
      newNodeThen FALSE @processor @block useMatchingInfoOnly
      newNodeElse FALSE @processor @block useMatchingInfoOnly
    ] [
      newNodeThenIndex changeNewNodeState
      newNodeElseIndex changeNewNodeState

      newNodeThen.state NodeStateHasOutput < [newNodeElse.state NodeStateHasOutput <] || [
        #merging uncompiled nodes
        newNodeThen.state NodeStateHasOutput < [newNodeElse.state NodeStateHasOutput <] && [
          NodeStateNoOutput @block.@state set
        ] [
          newNodeThen.state NodeStateHasOutput < [
            newNodeThen TRUE @processor @block useMatchingInfoOnly
          ] [
            newNodeThenIndex processCallByNode
          ] if

          newNodeElse.state NodeStateHasOutput < [
            newNodeElse TRUE @processor @block useMatchingInfoOnly
          ] [
            newNodeElseIndex processCallByNode
          ] if

          NodeStateHasOutput @block.@state set
        ] if
      ] [
        newNodeThen.state NodeStateHasOutput = [newNodeElse.state NodeStateHasOutput =] || [NodeStateHasOutput @block.@state set] when

        appliedVarsThen: newNodeThen applyNodeChanges;
        appliedVarsElse: newNodeElse applyNodeChanges;

        stackDepth: @processor block getStackDepth;
        newNodeThen.matchingInfo.inputs.size stackDepth > ["then branch stack underflow" @processor block compilerError] when
        newNodeElse.matchingInfo.inputs.size stackDepth > ["else branch stack underflow" @processor block compilerError] when
        stackDepth newNodeThen.matchingInfo.inputs.size - newNodeThen.outputs.size +
        stackDepth newNodeElse.matchingInfo.inputs.size - newNodeElse.outputs.size + = ~ ["if branches stack size mismatch" @processor block compilerError] when

        processor compilable [
          longestInputSize: newNodeThen.matchingInfo.inputs.size;
          newNodeElse.matchingInfo.inputs.size longestInputSize > [newNodeElse.matchingInfo.inputs.size @longestInputSize set] when
          longestOutputSize: newNodeThen.outputs.size;
          newNodeElse.outputs.size longestOutputSize > [newNodeElse.outputs.size @longestOutputSize set] when
          shortestInputSize: newNodeThen.matchingInfo.inputs.size newNodeElse.matchingInfo.inputs.size + longestInputSize -;
          shortestOutputSize: newNodeThen.outputs.size newNodeElse.outputs.size + longestOutputSize -;

          getOutput: [
            branch:;
            index: new;
            index branch.fixedOutputs.size + longestOutputSize < [
              longestInputSize index - 1 - @processor block getStackEntry new
            ] [
              index branch.fixedOutputs.size + longestOutputSize - branch.fixedOutputs.at new
            ] if
          ];

          isOutputImplicitDeref: [
            branch:;
            index: new;
            index branch.outputs.size + longestOutputSize < [
              FALSE
            ] [
              index branch.outputs.size + longestOutputSize - branch.outputs.at.argCase isImplicitDeref
            ] if
          ];

          getCompiledInput: [
            compiledOutputs:;
            branch:;
            index: new;

            index branch.outputs.size + longestOutputSize < [
              longestInputSize 1 - i - @inputs.at new
            ] [
              index branch.outputs.size + longestOutputSize - @compiledOutputs.at new
            ] if
          ];

          getCompiledOutput: [
            compiledOutputs:;
            branch:;
            index: new;
            index branch.outputs.size + longestOutputSize < [
              index @outputs.at
            ] [
              index branch.outputs.size + longestOutputSize - @compiledOutputs.at
            ] if
          ];

          # merge captures
          mergeValues: [
            refToDst: new;
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
            refToDst: new;
            value2:;
            value1:;

            unfinishedV1: @processor.acquireVarRefArray;
            unfinishedV2: @processor.acquireVarRefArray;
            unfinishedD:  @processor.acquireVarRefArray;

            value1   @unfinishedV1.append
            value2   @unfinishedV2.append
            refToDst @unfinishedD .append

            [
              unfinishedD.size 0 > [
                lastD: unfinishedD.last new;
                lastV1: unfinishedV1.last new;
                lastV2: unfinishedV2.last new;
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
                  [structD.fields.size structV1.fields.size =] "Merging structures fieldCount fail!" assert
                  [structD.fields.size structV2.fields.size =] "Merging structures fieldCount fail!" assert
                  f: 0;
                  [
                    f structD.fields.size < [
                      f structV1.fields.at.refToVar @unfinishedV1.append
                      f structV2.fields.at.refToVar @unfinishedV2.append
                      f structD .fields.at.refToVar @unfinishedD .append
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
                  newOutput: newNodeThen.outputs.size newNodeElse.outputs.size < [outputElse new] [outputThen new] if;
                  outputElse.mutable outputThen.mutable and @newOutput.setMutable
                  outputElse varIsMoved outputThen varIsMoved and @newOutput.setMoved
                  outputThen outputElse newOutput mergeValuesRec
                  i newNodeThen.outputs.size + longestOutputSize < ~ [newOutput @outputsThen.append] when
                  i newNodeElse.outputs.size + longestOutputSize < ~ [newOutput @outputsElse.append] when
                  newOutput isVirtual [
                    @newOutput @outputs.append
                  ] [
                    @newOutput @processor @block createAllocIR @outputs.append
                  ] if
                ] [
                  ("branch types mismatch; in 'then' type is " outputThen @processor block getMplType "; in 'else' type is " outputElse @processor block getMplType) assembleString @processor block compilerError
                ] if

                isOutputImplicitDerefThen @implicitDerefInfo.append
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
                a @inputs.append
                i newNodeThen.matchingInfo.inputs.size < [a @inputsThen.append] when
                i newNodeElse.matchingInfo.inputs.size < [a @inputsElse.append] when
                i 1 + @i set TRUE
              ] &&
            ] loop

            i: 0 dynamic;
            [
              i outputs.size < [
                outputRef: i @outputs.at;
                outputRef getVar.data.getTag VarStruct = [
                  @outputRef markAsAbleToDie
                  outputRef @block.@candidatesToDie.append
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

              0 refToCond @processor @block createBranch
              @block createLabel
              inputsThen @outputsThen newNodeThen makeCallInstruction
              newNodeThen @outputsThen createStores
              0 @block createJump
              @block createLabel
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
] "processIf" exportFunction

processDynamicLoop: [
  astArrayIndex:;

  iterationNumber: 0 dynamic;
  [
    needToRemake: FALSE dynamic;
    newNodeIndex: @astArrayIndex @processor @block tryMatchAllNodes;
    newNodeIndex 0 < [
      "dynamicLoop" makeStringView
      block.id
      NodeCaseCode
      astArrayIndex
      CFunctionSignature
      @processor astNodeToCodeNode @newNodeIndex set
    ] when

    processor compilable [
      newNode: newNodeIndex @processor.@blocks.at.get;
      newNodeIndex changeNewNodeState

      newNode.state NodeStateHasOutput < [
        newNode FALSE @processor @block useMatchingInfoOnly
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
              stackEntry new @processor @block makeVarDirty
            ] [
              stackEntry new @processor @block makeVarDynamic
            ] if

            stackEntry new @processor @block makePointeeDirtyIfRef
            TRUE dynamic @needToRemake set
          ] when
        ] times

        newNode.outputs.size newNode.matchingInfo.inputs.size 1 + = ~ ["loop body must save stack values and return Cond" @processor block compilerError] when
        processor compilable [
          condition: newNode.outputs.last.refToVar;
          condVar: condition getVar;
          condVar.data.getTag VarCond = ~ ["loop body must return Cond" @processor block compilerError] when

          i: 0 dynamic;
          [
            i newNode.matchingInfo.inputs.size < [
              curInput: i @processor block getStackEntry;
              curOutput: newNode.matchingInfo.inputs.size 1 - i - newNode.outputs.at .refToVar;
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
            i newNode.matchingInfo.inputs.size < [
              @processor @block pop @inputs.append
              i 1 + @i set TRUE
            ] &&
          ] loop

          i: 0 dynamic;
          [
            i appliedVars.fixedOutputs.getSize < [
              curOutput: i appliedVars.fixedOutputs.at;
              curOutput @outputs.append
              curOutput getVar.data.getTag VarStruct = [
                curOutput @block.@candidatesToDie.append
              ] when

              i 1 + newNode.outputs.size < [
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
                curNodeInput @nodeInputs.append

                curNodeInput isVirtual ~ [
                  (curNodeInput @processor getIrType "*") assembleString makeStringView # with *
                  curNodeInput @processor getIrName
                  i inputs.at @processor getIrName
                  inputs.size 1 - i - outputs.at @processor getIrName
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
          newNode.outputs [.argCase isImplicitDeref @implicitDerefInfo.append] each
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
  block: Block Ref; processor: Processor Ref; astArrayIndex: Int32;
} () {} [
  astArrayIndex: processor: block: ;;;

  overload failProc: processor block FailProcForProcessor;

  iterationNumber: 0 dynamic;
  loopIsDynamic: FALSE;

  [
    newNodeIndex: @astArrayIndex @processor @block tryMatchAllNodes dynamic;
    newNodeIndex 0 < [
      "loop" makeStringView
      block.id
      NodeCaseCode
      astArrayIndex
      CFunctionSignature
      @processor
      astNodeToCodeNode @newNodeIndex set
    ] when

    newNode: newNodeIndex @processor.@blocks.at.get;
    processor compilable ~ [
      newNode FALSE @processor @block useMatchingInfoOnly
      FALSE
    ] [
      newNodeIndex changeNewNodeState
      newNode.state NodeStateHasOutput < [
        newNode TRUE @processor @block useMatchingInfoOnly
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
              VarCond a getVar.data.get.end new
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
      ("Static loop length limit (" processor.options.staticLoopLengthLimit ") exceeded. Dynamize loop or increase limit using -static_loop_length_limit option") assembleString @processor block compilerError
    ] when

    processor compilable and
  ] loop

  loopIsDynamic [astArrayIndex processDynamicLoop] when
] "processLoop" exportFunction

{
  block: Block Ref; processor: Processor Ref;
  asCodeRef: Cond; name: StringView Cref; signature: CFunctionSignature Cref;} Int32 {} [
  block:;
  processor:;
  overload failProc: processor block FailProcForProcessor;

  asCodeRef: new;
  name:;
  signature:;
  compileOnce

  @processor addBlock
  declarationNode: @processor.@blocks.last.get;
  block.id                     @declarationNode.@parent set
  @processor @block getTopNode @declarationNode.@topNode.set
  asCodeRef [NodeCaseCodeRefDeclaration][NodeCaseDeclaration] if @declarationNode.@nodeCase set
  signature.variadic @declarationNode.@variadic set

  signature.inputs.getSize [
    r: signature.inputs.getSize 1 - i - signature.inputs.at @processor @block copyVarFromChild;
    @r @processor block unglobalize
    FALSE @r.setMutable
    r @block push
  ] times

  [
    block: @declarationNode;
    forcedSignature: signature;
    processor.options.debug [
      @processor addDebugReserve @block.@funcDbgIndex set
    ] when
    forcedSignature.inputs   [p:; a: @processor @block pop;] each
    forcedSignature.outputs [@processor @block copyVarFromChild @block push] each
    name forcedSignature @processor @block finalizeCodeNode
  ] call

  signature.inputs   [p:; a: @processor @block pop;] each
  declarationNode.id new
] "processImportFunction" exportFunction

{block: Block Ref; processor: Processor Ref;
  asLambda: Cond; name: StringView Cref; astArrayIndex: Int32; signature: CFunctionSignature Cref;} Int32 {} [
  block:;
  processor:;
  asLambda: new;
  name:;
  astArrayIndex:;
  signature:;
  overload failProc: processor block FailProcForProcessor;

  compileOnce

  signature.variadic [
    "export function cannot be variadic" @processor block compilerError
  ] when

  processor.options.partial ~ [
    topNode: block.topNode;
    [topNode.file isNil ~] "Topnode in nil file!" assert
    topNode.file.usedInParams new
  ] || [
    ("process export: " makeStringView name makeStringView) addLog

    processor.varForFails @block pushForMatching

    # we dont know count of used in export entites
    signature.inputs.getSize [
      r: signature.inputs.getSize 1 - i - signature.inputs.at @processor @block copyVarFromType;
      r @processor @block makeVarTreeDynamic
      @r @processor block unglobalize
      @r fullUntemporize
      r getVar.data.getTag VarRef = [
        @r @processor @block getPointeeNoDerefIR @block pushForMatching
      ] [
        TRUE @r.setMutable
        r @block pushForMatching
      ] if
    ] times

    oldSuccess: processor compilable;
    oldRecursiveNodesStackSize: processor.recursiveNodesStack.getSize;

    newNodeIndex: astArrayIndex @processor @block tryMatchAllNodesForRealFunction;
    newNodeIndex 0 < [
      nodeCase: asLambda [NodeCaseLambda][NodeCaseExport] if;
      processor.exportDepth 1 + @processor.@exportDepth set
      name block.id nodeCase astArrayIndex signature @processor astNodeToCodeNode @newNodeIndex set
      processor.exportDepth 1 - @processor.@exportDepth set
    ] when

    successBeforeCaptures: processor.result.success new;
    TRUE @processor.@result.@success set

    newNode: newNodeIndex processor.blocks.at.get;

    processor.result.passErrorThroughPRE ~ [
      newNode.matchingInfo.shadowEvents [
        currentEvent:;
        (
          ShadowReasonCapture [
            branch:;
            branch.stable [
              branch.refToVar branch.nameInfo branch.nameOverloadDepth branch.file @processor @block addStableName
            ] [
              overloadIndex: outOverloadDepth: branch @block branch.file TRUE getOverloadIndex;;
              gnr: branch.nameInfo overloadIndex @processor @block branch.file getNameForMatchingWithOverloadIndex;
              stackEntry: gnr outOverloadDepth @processor @block branch.file captureName.refToVar;
            ] if
          ]
          []
        ) currentEvent.visit
      ] each
    ] when

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

    signature.inputs.getSize 1 + [@processor @block popForMatching drop] times

    processor compilable [
      ("successfully processed export: " makeStringView name makeStringView) addLog
      name processor.options.beginFunc = [
        newNodeIndex @processor.@beginFuncIndex set
      ] when

      name processor.options.endFunc = [
        newNodeIndex @processor.@endFuncIndex set
      ] when
    ] [
      ("failed while process export: " makeStringView name makeStringView) addLog
    ] if

    oldSuccess processor compilable ~ and processor.depthOfPre 0 = and processor.result.findModuleFail ~ and processor.result.passErrorThroughPRE ~ and [
      @processor.@result.@errorInfo @processor.@result.@globalErrorInfo.append
      oldRecursiveNodesStackSize @processor.@recursiveNodesStack.shrink
      -1 @processor.@result clearProcessorResult

      signature name FALSE dynamic @processor @block processImportFunction !newNodeIndex
    ] when

    newNodeIndex
  ] [
    ("declare export from another file: " name) addLog
    newNodeIndex: signature name FALSE dynamic @processor @block processImportFunction;
    asLambda [
      block: newNodeIndex @processor.@blocks.at.get;
      TRUE @block.@empty set
    ] when

    newNodeIndex
  ] if

] "processExportFunction" exportFunction

fixSourcesRec: [
  refToVar:;

  unfinished: @processor.acquireVarRefArray;
  refToVar @unfinished.append

  i: 0 dynamic;

  [
    i unfinished.getSize < [
      current: i @unfinished.at;
      currentVar: @current getVar;
      current @currentVar.@sourceOfValue set
      currentVar.data.getTag VarStruct = [
        VarStruct currentVar.data.get.get.fields [
          .refToVar @unfinished.append
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
        i declarationNode.matchingInfo.inputs.size < [
          (
            [processor compilable]
            [stackEntry: @processor @block pop;]
            [
              input: stackEntry new;
              nodeEntry: i @declarationNode.@matchingInfo.@inputs.at.@refToVar;
              forcedInput: i declarationNode.csignature.inputs.at;
              nodeMutable: forcedInput getVar.data.getTag VarRef = [VarRef forcedInput getVar.data.get.refToVar.mutable] &&;

              forcedInput getVar.data.getTag VarRef = [
                @stackEntry makeVarPtrCaptured
              ] [
                @stackEntry @processor @block makeVarRealCaptured
              ] if

              stackEntry nodeEntry variablesAreSame ~ [
                lambdaCastResult: @input @nodeEntry @processor @block tryImplicitLambdaCast;
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
              input @inputs.append
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
              field @inputs.append
            ] times

            @refToVarargs @processor @block makeVarRealCaptured
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
          current @outputs.append
          current getVar.data.getTag VarStruct = [
            current @block.@candidatesToDie.append
          ] when

          i 1 + @i set processor compilable
        ] &&
      ] loop
    ] [
      forcedName: StringView;
      inputs @outputs declarationNode forcedName refToVar dynamicFunc TRUE dynamic @processor @block makeCallInstructionWith
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
        getVar.data.getTag VarRef = @implicitDerefInfo.append
      ] each

      implicitDerefInfo outputs.getSize @block derefNEntries
      @implicitDerefInfo.clear
    ]
  ) sequence

  TRUE @block.@hasCallImport set
  TRUE @block.@hasCallTrace set

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
  protoIndex: VarImport var.data.get new;
  node: protoIndex @processor.@blocks.at.get;
  [
    node.nextRecLambdaId 0 < ~ [
      node.nextRecLambdaId @protoIndex set
      protoIndex @processor.@blocks.at.get !node
      TRUE
    ] &&
  ] loop

  dynamicFunc: refToVar staticityOfVar Dynamic > ~;

  dynamicFunc [
    @refToVar @processor @block makeVarRealCaptured
  ] [
    node.nodeCase NodeCaseCodeRefDeclaration = [
      "nullpointer call" @processor block compilerError
    ] when
  ] if

  @node refToVar dynamicFunc @block callImportWith
] "processFuncPtr" exportFunction
