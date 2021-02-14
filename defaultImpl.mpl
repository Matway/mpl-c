"Array"       use
"String"      use
"algorithm"   use
"control"     use
"conventions" use

"Block"        use
"Var"          use
"declarations" use
"processor"    use
"staticCall"   use

FailProcForProcessor: [{
  processor: block: ;;

  CALL: [
    overload failProc: [print " - fail while handling fail" print];

    "INTERNAL COMPILER ERROR" print LF print
    print

    trace: getCallTrace;
    [
      trace storageAddress 0nx = [
        FALSE
      ] [
        (trace.name trace.line new trace.column new) " in %s at %i:%i\n\00" printf drop
        trace.prev trace addressToReference !trace
        TRUE
      ] if
    ] loop

    "\nWhile compiling:\n" print
    processor block defaultPrintStackTrace
    "\nCommand line:\n" print
    processor.options.fullLine print
    "\n" print

    2 exit
  ];
} dynamic];

pop: [
  processor: block: ;;
  result: RefToVar;
  @result FALSE @processor @block popWith
  @result
];

createRef:     [processor: block:;;  TRUE dynamic @processor @block createRefWith];
createRefNoOp: [processor: block:;; FALSE dynamic @processor @block createRefWith];

compilable: [processor:; processor.result.success new];

makeVarRealCaptured: [
  refToVar: processor: block: ;;;
  refToVar getVar.storageStaticity Virtual = [
    "accessing nullptr" @processor @block compilerError
  ] when

  TRUE @refToVar getVar.@capturedAsRealValue set
];

makeVarPtrCaptured: [
  refToVar:;
  TRUE @refToVar getVar.@capturedByPtr set
];

makeVarDerefCaptured: [
  refToVar:;
  TRUE @refToVar getVar.@capturedForDeref set
];

defaultFailProc: [
  processor: block: ;;
  text: @processor @block pop;
];

defaultSet: [
  processor: block: ;;
  refToDst: @processor @block pop;
  refToSrc: @processor @block pop;
  processor compilable [
    refToDst refToSrc variablesAreSame [
      refToSrc getVar.data.getTag VarImport = [
        "functions cannot be copied" @processor block compilerError
      ] [
        refToSrc getVar.data.getTag VarString = [
          "builtin-strings cannot be copied" @processor block compilerError
        ] [
          refToDst.mutable [
            [refToDst staticityOfVar Weak = ~] "Destination is weak!" assert
            refToSrc.mutable [refToSrc isVirtual ~ [refToSrc getVar .data.getTag VarStruct =] &&] && [
              TRUE @refToSrc.setMoved
            ] when

            @refToSrc @refToDst @processor @block createCopyToExists
          ] [
            "destination is immutable" @processor block compilerError
          ] if
        ] if
      ] if
    ] [
      refToDst.mutable ~ [
        "destination is immutable" @processor block compilerError
      ] [
        lambdaCastResult: @refToSrc @refToDst @processor @block tryImplicitLambdaCast;
        lambdaCastResult.success [
          newSrc: @lambdaCastResult.@refToVar TRUE @processor @block createRef;
          @newSrc @refToDst @processor @block createCopyToExists
        ] [
          ("types mismatch, src is " refToSrc @processor block getMplType "," LF "dst is " refToDst @processor block getMplType) assembleString @processor block compilerError
        ] if
      ] if
    ] if
  ] when
];

defaultRef: [
  mutable: processor: block: ;;;
  refToVar: @processor @block pop;
  processor compilable [
    @refToVar mutable @processor @block createRef @block push
  ] when
];

setRef: [
  processor: block: ;;
  refToVar:; # destination
  compileOnce

  var: refToVar getVar;
  var.data.getTag VarRef = [
    refToVar isVirtual [
      "can not write to virtual" @processor block compilerError
    ] [
      pointee: VarRef var.data.get.refToVar;
      pointee.mutable ~ [
        FALSE @processor @block defaultMakeConstWith #source
      ] when

      processor compilable [
        src: @processor @block pop;
        processor compilable [
          src pointee variablesAreSame [
            src @block push
            @src makeVarPtrCaptured
            TRUE @processor @block defaultRef #source
            refToVar @block push
            @processor @block defaultSet
          ] [
            src @block push
            refToVar @block push
            @processor @block defaultSet
          ] if
        ] when
      ] when
    ] if
  ] [
    #rewrite value case!
    src: @processor @block pop;
    processor compilable [
      src getVar.temporary [
        src @block push
        refToVar @block push
        @processor @block defaultSet
      ] [
        "rewrite value works only with temporary values" @processor block compilerError
      ] if
    ] when
  ] if
];

defaultMakeConstWith: [
  check: processor: block: ;;;
  refToVar: @processor @block pop;
  processor compilable [
    check [refToVar getVar.temporary new] && [
      "temporary objects cannot be set const" @processor block compilerError
    ] [
      FALSE @refToVar.setMutable
      refToVar @block push
    ] if
  ] when
];

getStackEntryWith: [
  depth: check: processor: block: ;; new; new;

  result: @block isConst [processor.varForFails] [@processor.@varForFails] uif;
  currentBlock: @block; [
    currentBlock.root [
      check [
        "stack underflow" @processor block compilerError
      ] when

      FALSE
    ] [
      depth currentBlock.stack.size < [
        currentBlock.stack.size 1 - depth - @currentBlock.@stack.at !result
        check [result getVar.data.getTag VarInvalid =] && [
          "stack underflow" @processor block compilerError
        ] when

        FALSE
      ] [
        depth currentBlock.stack.size - currentBlock.buildingMatchingInfo.inputs.size + @depth set
        currentBlock.parent @processor.@blocks.at.get !currentBlock
        TRUE
      ] if
    ] if
  ] loop

  @result
];

getStackEntry:          [depth: processor: block:;; new; depth TRUE  @processor @block getStackEntryWith];
getStackEntryUnchecked: [depth: processor: block:;; new; depth FALSE processor block  getStackEntryWith];

getStackDepth: [
  processor: block:;;
  depth: 0 dynamic;
  inputsCount: 0 dynamic;
  [
    block.root ~ [
      depth block.stack.size + @depth set
      inputsCount block.buildingMatchingInfo.inputs.size + @inputsCount set
      block.parent processor.blocks.at.get !block
      TRUE
    ] &&
  ] loop

  [inputsCount depth > ~] "Missed stack overflow!" assert

  depth inputsCount -
];

{
  block: Block Cref;
  processor: Processor Cref;
} () {} [
  processor: block:;;
  hasInvalid: FALSE dynamic;
  depth: 0 dynamic;
  @processor @block getStackDepth  [
    hasInvalid ~ [
      entry: i @processor block getStackEntryUnchecked;
      entry getVar.data.getTag VarInvalid = [
        TRUE !hasInvalid
      ] [
        depth 1 + !depth
      ] if
    ] when
  ] times

  ("stack:" LF "depth=" depth LF) printList

  depth [
    entry: i @processor block getStackEntryUnchecked;
    (entry @processor block getMplType entry.mutable ["R"] ["C"] if entry getVar.temporary ["T"] [""] if
      entry isPlain [entry getPlainValueInformation] [String] if LF) printList
  ] times
] "defaultPrintStack" exportFunction

{
  block: Block Cref;
  processor: Processor Cref;
} () {} [
  processor: block: ;;

  processor.positions.getSize [
    currentPosition: processor.positions.getSize 1 - i - processor.positions.at;

    processor.options.hidePrefixes [currentPosition.file.name swap beginsWith ~] all [
      (
        "at fileName: " currentPosition.file.name
        ", token: "     currentPosition.token
        ", line: "      currentPosition.line
        ", column: "    currentPosition.column LF
      ) printList
    ] when
  ] times

  @processor block defaultPrintStack
] "defaultPrintStackTrace" exportFunction

printShadowEvent: [
  event: index: building: processor: block: ;;;;;

  getFileName: [
    file:; file isNil ["NIL" makeStringView] [file.name makeStringView] if
  ];

  getTopologyIndex: [
    building [
      .buildingTopologyIndex
    ] [
      .topologyIndex
    ] if
  ];

  (
    ShadowReasonInput [
      branch:;
      ("shadow event [" index "] input as " branch.refToVar getVar getTopologyIndex LF) printList
    ]
    ShadowReasonCapture [
      branch:;
      branch.stable [
        ("shadow event [" index "] capture " branch.nameInfo processor.nameManager.getText " as stable name" "(" branch.nameOverloadDepth ") in " branch.file getFileName "; type " branch.refToVar @processor @block getMplType LF) printList
      ] [
        ("shadow event [" index "] capture " branch.nameInfo processor.nameManager.getText "(" branch.nameOverloadDepth ") in " branch.file getFileName "; staticity=" branch.refToVar getVar.staticity.begin " as " branch.refToVar getVar getTopologyIndex " type " branch.refToVar @processor @block getMplType LF) printList
        branch.mplFieldIndex 0 < ~ [("  as field " branch.mplFieldIndex " in object" LF) printList] when
      ] if
    ]
    ShadowReasonPointee [
      branch:;
      ("shadow event [" index "] pointee " branch.pointer getVar getTopologyIndex " as " branch.pointee getVar getTopologyIndex LF) printList
    ]
    ShadowReasonField [
      branch:;
      ("shadow event [" index "] field " branch.object getVar getTopologyIndex " [" branch.mplFieldIndex "] as " branch.field getVar getTopologyIndex LF) printList
    ]
    ShadowReasonTreeSplitterLambda [
      branch:;
      ("shadow event [" index "] tree splitter lambda " branch LF) printList
    ]
    []
  ) event.visit
];

printAstArrayTree: [
  astArrayIndex: processor: block: ;;;

  ("Print astArrayTree for " astArrayIndex LF) printList
  matchingMode: astArrayIndex processor.matchingNodes.at.get;
  matchingMode.treeMemory.getSize [
    entry: i matchingMode.treeMemory.at;
    (i "  nodeIndexes: ") printList
    entry.nodeIndexes [v:; (v " ") printList] each
    ("  childs: ") printList
    entry.childIndices [v:; (v.childIndex " ") printList] each
    LF print
  ] times
];

findNameInfo: [
  processor:;
  @processor.@nameManager.createName
];

addStackUnderflowInfo: [
  processor: block:;;

  newEvent: ShadowEvent;
  ShadowReasonInput @newEvent.setTag
  branch: ShadowReasonInput @newEvent.get;
  processor.varForFails @branch.@refToVar set
  ArgMeta   @branch.@argCase set
  @newEvent @processor @block addShadowEvent
];

nodeHasCode: [
  node:;
  node.emptyDeclaration ~ [node.uncompilable ~] && [node.empty ~] && [node.deleted ~] && [node.nodeCase NodeCaseCodeRefDeclaration = ~] &&
];

addBlockIdTo: [
  whereNames: nameInfo: nameOverloadDepth: file: processor: block: ;;;;;;

  addToLine: [
    line:;
    index: line.size 1 -;
    result: TRUE dynamic;

    [
      index 0 < [index line.at.block block is ~] || [
        FALSE #no such item
      ] [
        index line.at.file file is [
          FALSE !result #we have such item
          FALSE
        ] [
          index 1 - !index
          TRUE #find deeper
        ] if
      ] if
    ] loop

    result [
      NameInfoCoord @line.pushBack
      block @line.last.@block.set
      file  @line.last.@file.set

      nameWithOverload: NameWithOverload;
      nameInfo          @nameWithOverload.@nameInfo set
      nameOverloadDepth @nameWithOverload.@nameOverloadDepth set
      #other fields does not matter
      nameWithOverload @block.@captureNames.pushBack
    ] when

    result
  ];

  nameInfo whereNames.simpleNames.size < ~ [nameInfo 1 + @whereNames.@simpleNames.resize] when
  whereOverloads: nameInfo @whereNames.@simpleNames.at;
  nameOverloadDepth whereOverloads.size < ~ [nameOverloadDepth 1 + @whereOverloads.resize] when
  whereIds: nameOverloadDepth @whereOverloads.at;
  @whereIds addToLine
];

addEmptyCapture: [
  processor: block: ;;
  nameInfo: nameOverloadDepth: ;;
  file:;

  @processor.@captureTable nameInfo nameOverloadDepth file @processor @block addBlockIdTo [
    newEvent: ShadowEvent;
    ShadowReasonCapture @newEvent.setTag
    branch: ShadowReasonCapture @newEvent.get;

    -1                    @branch.@mplFieldIndex set
    processor.varForFails @branch.@refToVar set
    nameInfo              @branch.@nameInfo set
    nameOverloadDepth     @branch.@nameOverloadDepth set
    file                  @branch.@file.set
    ArgMeta               @branch.@argCase set
    @newEvent @processor @block addShadowEvent
  ] when
];

getShadowEventHash: [
  event: whileMatching: processor: block: ;;;;

  apply: [
    value:;
    result 0x8088405n32 * 1n32 + value xor !result
  ];

  applyRefToVar: [
    refToVar: checkMutable: ;;
    var: refToVar getVar;

    whileMatching [
      var.topologyIndexWhileMatching Nat32 cast apply
      var.staticity.end Nat32 cast apply
    ] [
      var.buildingTopologyIndex Nat32 cast apply
      var.staticity.begin Nat32 cast apply
    ] if

    var.mplSchemaId Nat32 cast apply
    var.globalId Nat32 cast apply
    var.storageStaticity Nat32 cast apply

    checkMutable [
      refToVar.mutable [5n32][4n32] if apply
    ] when

    refToVar isAutoStruct [
      refToVar.moved   [3n32][2n32] if apply
    ] when

    refToVar isPlain [
      currentStaticity: whileMatching [var.staticity.end new] [var.staticity.begin new] if;
      currentStaticity Dynamic > [
        var.data.getTag VarCond VarReal64 1 + [
          tag:;
          applyData: 0n64;
          value: whileMatching [tag var.data.get.end new] [tag var.data.get.begin new] if;
          value applyData storageAddress @value addressToReference set
          applyData 32n32 rshift applyData 48n32 rshift xor applyData xor Nat32 cast apply
        ] staticCall
      ] when
    ] when
  ];

  result: 0n32;
  event.getTag Nat32 cast apply
  (
    ShadowReasonInput [
      branch:;
      # key - none
      branch.refToVar TRUE applyRefToVar
    ]
    ShadowReasonCapture [
      branch:;
      # key - nameInfo
      branch.stable [
        0n32 apply
        branch.refToVar TRUE applyRefToVar
      ] [
        10n32 apply
        branch.mplFieldIndex Nat32 cast apply
        branch.refToVar TRUE applyRefToVar
      ] if
    ]
    ShadowReasonPointee [
      branch:;
      # key - pointer topologyIndex
      branch.pointee TRUE applyRefToVar
    ]
    ShadowReasonField [
      branch:;
      # key - object topologyIndex, object mplFieldIndex
      branch.field FALSE applyRefToVar
    ]
    ShadowReasonTreeSplitterLambda [
      branch:;
      # key - node
      branch [0n32] [1n32] if apply
    ]
    []
  ) event.visit

  result
];

sameEvents: [
  event1: event2: ;;

  event1.getTag event2.getTag = [
    event1.getTag (
      ShadowReasonInput [
        # key - none
        TRUE
      ]
      ShadowReasonCapture [
        # key - nameInfo
        branch1: ShadowReasonCapture event1.get;
        branch2: ShadowReasonCapture event2.get;

        branch1.nameInfo branch2.nameInfo =
        [branch1.nameOverloadDepth branch2.nameOverloadDepth =] &&
        [branch1.file branch2.file is] && [
          TRUE
        ] [
          getFileName: [
            file:;
            file isNil ["NIL" makeStringView] [file.name makeStringView] if
          ];

          ("Capture events are different; "
            LF branch1.nameInfo processor.nameManager.getText ":" branch1.nameOverloadDepth ":" branch1.file getFileName
            LF branch2.nameInfo processor.nameManager.getText ":" branch2.nameOverloadDepth ":" branch2.file getFileName
            LF) printList
          FALSE
        ] if
      ]
      ShadowReasonPointee [
        # key - pointer topologyIndex
        branch1: ShadowReasonPointee event1.get;
        branch2: ShadowReasonPointee event2.get;
        pointer1: branch1.pointer getVar;
        pointer2: branch2.pointer getVar;
        pointer1.buildingTopologyIndex pointer2.topologyIndex = [
          TRUE
        ] [
          ("Pointee events are different; " pointer1.buildingTopologyIndex " and " pointer2.topologyIndex LF) printList
          FALSE
        ] if
      ]
      ShadowReasonField [
        # key - object topologyIndex
        branch1: ShadowReasonField event1.get;
        branch2: ShadowReasonField event2.get;
        object1: branch1.object getVar;
        object2: branch2.object getVar;
        object1.buildingTopologyIndex object2.topologyIndex =
        [branch1.mplFieldIndex branch2.mplFieldIndex =] && [
          TRUE
        ] [
          ("Field events are different; " object1.buildingTopologyIndex ":" branch1.mplFieldIndex " and " object2.topologyIndex ":" branch2.mplFieldIndex LF) printList
          FALSE
        ] if
      ]
      ShadowReasonTreeSplitterLambda [
        # key - none
        TRUE
      ]
      [
        ("Event tags are invalid; " event1.getTag LF) printList
        FALSE
      ]
    ) case
  ] [
    ("Event tags are different; " event1.getTag " and " event2.getTag LF) printList
    FALSE
  ] if
];

compareShadows: [
  processor:;
  comparingMessage:;
  whileMatching:;
  checkConstness:;
  refToVar2:;
  refToVar1:;
  refToVar1 refToVar2 whileMatching checkConstness @comparingMessage FALSE @processor compareOnePair
];

compareTopologyIndex: [
  refToVar1: refToVar2: whileMatching: ;;;

  var1: refToVar1 getVar;
  var2: refToVar2 getVar;

  ti1: refToVar1 noMatterToCopy [-1][
    whileMatching [
      var1.topologyIndexWhileMatching new
    ] [
      var1.buildingTopologyIndex new
    ] if
  ] if;

  ti2: refToVar2 noMatterToCopy [-1][
    whileMatching [
      var2.topologyIndex new
    ] [
      var2.topologyIndex new
    ] if
  ] if;

  ti1 ti2 =
];

compareEvents: [
  event1: event2: comparingMessage: whileMatching: processor: ;;;;;

  result: TRUE;
  event1.getTag event2.getTag = [
    event1.getTag (
      ShadowReasonInput [
        branch1: ShadowReasonInput event1.get;
        branch2: ShadowReasonInput event2.get;

        branch1.refToVar branch2.refToVar whileMatching compareTopologyIndex
        [branch1.refToVar branch2.refToVar TRUE whileMatching @comparingMessage @processor compareShadows] && ~ [
          FALSE !result
        ] when
      ]
      ShadowReasonCapture [
        branch1: ShadowReasonCapture event1.get;
        branch2: ShadowReasonCapture event2.get;

        branch1.stable branch2.stable and [
          branch1.refToVar branch2.refToVar TRUE whileMatching @comparingMessage @processor compareShadows ~ [
            FALSE !result
          ] when
        ] [
          branch1.stable ~ branch2.stable ~ and
          [branch1.refToVar branch2.refToVar whileMatching compareTopologyIndex] &&
          [branch1.mplFieldIndex branch2.mplFieldIndex =] &&
          [branch1.refToVar branch2.refToVar TRUE whileMatching @comparingMessage @processor compareShadows] && ~ [
            FALSE !result
          ] when
        ] if
      ]
      ShadowReasonPointee [
        branch1: ShadowReasonPointee event1.get;
        branch2: ShadowReasonPointee event2.get;

        branch1.pointee branch2.pointee whileMatching compareTopologyIndex
        [branch1.pointee branch2.pointee TRUE whileMatching @comparingMessage @processor compareShadows] && ~ [
          FALSE !result
        ] when
      ]
      ShadowReasonField [
        branch1: ShadowReasonField event1.get;
        branch2: ShadowReasonField event2.get;

        branch1.field branch2.field whileMatching compareTopologyIndex
        [branch1.field branch2.field FALSE whileMatching @comparingMessage @processor compareShadows] && ~ [
          FALSE !result
        ] when
      ]
      ShadowReasonTreeSplitterLambda [
        branch1: ShadowReasonTreeSplitterLambda event1.get;
        branch2: ShadowReasonTreeSplitterLambda event2.get;

        branch1 branch2 = ~ [
          FALSE !result
        ] when
      ]
      []
    ) case
  ] [
    FALSE !result
  ] if

  result
];

deleteMatchingNodeFrom: [
  processor: block: matchingChindIndex: full: ;;;;

  matchingChindIndex 0 < ~ [
    astArrayIndex: block.astArrayIndex new;
    matchingNode: astArrayIndex @processor.@matchingNodes.at.get;
    currentMemory: matchingChindIndex @matchingNode.@treeMemory.at;

    index: -1 dynamic;
    i: currentMemory.nodeIndexes.size 1 -;
    [i 0 < ~ index 0 < and] [
      i currentMemory.nodeIndexes.at block.id = [
        i @index set
      ] when

      i 1 - !i
    ] while

    full [
      index: matchingChindIndex new;
      [
        parentIndex: index matchingNode.treeMemory.at.parentIndex new;
        parentIndex 0 < ~ [
          parentNode: parentIndex @matchingNode.@treeMemory.at;
          parentNode.childIndices.size 1 = [
            i: parentNode.childIndices.size 1 -;
            [i 0 < ~ [i parentNode.childIndices.at.childIndex index = ~] &&] [
              i 1 - !i
            ] while

            [i 0 < ~] "No such child in parent in matchingTree!" assert
            i @parentNode.@childIndices.erase

            parentIndex @index set
            TRUE
          ] &&
        ] &&
      ] loop
    ] when

    index 0 < ~ [
      index @currentMemory.@nodeIndexes.erase
    ] when
  ] when
];

deleteMatchingNode: [
  processor: block: full: ;;;

  block.matchingChindIndex 0 < ~ [
    @processor @block block.matchingChindIndex full deleteMatchingNodeFrom
    -1 @block.@matchingChindIndex set
  ] when
];

addShadowEvent: [
  event: processor: block: ;;;

  block.astArrayIndex 0 < ~ [
    #begin of var go to matching
    event @block.@buildingMatchingInfo.@shadowEvents.pushBack

    block.state NodeStateNew = [
      event @block.@matchingInfo.@shadowEvents.pushBack
    ] when

    block.recursionState NodeRecursionStateNew = [
    ] [
      addChild: [
        event: machingMemoryNode:;;

        matchingNodePair: MatchingNodePair;
        result: matchingNode.treeMemory.getSize;

        eventHash @matchingNodePair.@eventHash set
        result    @matchingNodePair.@childIndex set

        @matchingNodePair @machingMemoryNode.@childIndices.pushBack

        newMatchingNodeEntry: MatchingNodeEntry;
        event             @newMatchingNodeEntry.@parentEvent set
        currentEntryIndex @newMatchingNodeEntry.@parentIndex set
        @newMatchingNodeEntry @matchingNode.@treeMemory.pushBack

        result
      ];

      currentEntryIndex: block.matchingChindIndex new;
      comparingMessage: String;
      matchingNode: block.astArrayIndex @processor.@matchingNodes.at.get;
      currentMemory: currentEntryIndex @matchingNode.@treeMemory.at;

      eventHash: event FALSE dynamic @processor @block getShadowEventHash;

      currentMemory.childIndices.size 0 = [
        event @currentMemory addChild @currentEntryIndex set
      ] [
        pattern: 0 currentMemory.childIndices @ .childIndex matchingNode.treeMemory.at.parentEvent;
        [
          event pattern sameEvents [
            ("First event is new event; second is pattern; astNode index = " block.astArrayIndex LF) printList
            ("Current try matching events: " LF) printList

            block.buildingMatchingInfo.shadowEvents.size [
              event: i block.buildingMatchingInfo.shadowEvents.at;

              getFileName: [
                file:; file isNil ["NIL" makeStringView] [file.name makeStringView] if
              ];

              (
                ShadowReasonInput [
                  branch:;
                  ("shadow event [" i "] input as " branch.refToVar getVar.buildingTopologyIndex LF) printList
                ]
                ShadowReasonCapture [
                  branch:;
                  branch.stable [
                    ("shadow event [" i "] capture " branch.nameInfo processor.nameManager.getText " as stable name" LF) printList
                  ] [
                    ("shadow event [" i "] capture " branch.nameInfo processor.nameManager.getText "(" branch.nameOverloadDepth ") in " branch.file getFileName "; staticity=" branch.refToVar getVar.staticity.begin " as " branch.refToVar getVar.buildingTopologyIndex " type " branch.refToVar @processor @block getMplType LF) printList
                    branch.mplFieldIndex 0 < ~ [("  as field " branch.mplFieldIndex " in object" LF) printList] when
                  ] if
                ]
                ShadowReasonPointee [
                  branch:;
                  ("shadow event [" i "] pointee " branch.pointer getVar.buildingTopologyIndex " as " branch.pointee getVar.buildingTopologyIndex LF) printList
                ]
                ShadowReasonField [
                  branch:;
                  ("shadow event [" i "] field " branch.object getVar.buildingTopologyIndex " [" branch.mplFieldIndex "] as " branch.field getVar.buildingTopologyIndex LF) printList
                ]
                ShadowReasonTreeSplitterLambda [
                  branch:;
                  ("shadow event [" i "] tree splitter lambda " branch LF) printList
                ]
                []
              ) event.visit
            ] times

            FALSE
          ] ||
        ] "Matching events are not consistent" assert

        candidates: @currentMemory.@childIndices;

        prevEventIndex: -1 dynamic;
        candidates [
          prevVersion:;
          prevEventIndex 0 < [
            prevVersion.eventHash eventHash = [
              prevVersionEvent: prevVersion.childIndex matchingNode.treeMemory.at.parentEvent;
              event prevVersionEvent @comparingMessage FALSE dynamic @processor compareEvents
            ] && [
              prevVersion.childIndex @prevEventIndex set
            ] when
          ] when
        ] each

        prevEventIndex 0 < [
          candidates [
            prevVersion:;
            prevEventIndex 0 < [
              prevVersion.eventHash eventHash = [
                prevVersionEvent: prevVersion.childIndex matchingNode.treeMemory.at.parentEvent;
                event prevVersionEvent @comparingMessage FALSE dynamic @processor compareEvents
              ] && [
                prevVersion.childIndex @prevEventIndex set
              ] when
            ] when
          ] each

          event @currentMemory addChild @currentEntryIndex set
        ] [
          prevEventIndex @currentEntryIndex set
        ] if
      ] if

      @processor @block FALSE deleteMatchingNode
      currentEntryIndex @block.@matchingChindIndex set
      currentMemory: currentEntryIndex @matchingNode.@treeMemory.at;
      block.id @currentMemory.@nodeIndexes.pushBack
    ] if
  ] when
];

getTopNode: [
  processor: topNode:;;
  [topNode.parent 0 = ~] [
    topNode.parent @processor.@blocks.at.get !topNode
  ] while

  @topNode
];
