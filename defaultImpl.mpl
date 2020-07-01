"String" use
"control" use
"conventions" use

"Block" use
"Var" use
"declarations" use
"processor" use

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
        (trace.name trace.line copy trace.column copy) " in %s at %i:%i\n\00" printf
        trace.prev trace addressToReference !trace
        TRUE
      ] if
    ] loop

    "\nWhile compiling:\n" print
    processor block defaultPrintStackTrace

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

compilable: [processor:; processor.result.success copy];

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
    check [refToVar getVar.temporary copy] && [
      "temporary objects cannot be set const" @processor block compilerError
    ] [
      FALSE @refToVar.setMutable
      refToVar @block push
    ] if
  ] when
];

getStackEntryWith: [
  depth: check: processor: block: ;; copy; copy;

  result: @block isConst [processor.varForFails] [@processor.@varForFails] uif;
  currentBlock: @block; [
    currentBlock.root [
      check ["stack underflow" @processor block compilerError] when
      FALSE
    ] [
      depth currentBlock.stack.size < [
        currentBlock.stack.size 1 - depth - @currentBlock.@stack.at !result
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

getStackEntry:          [depth: processor: block:;; copy; depth TRUE  @processor @block getStackEntryWith];
getStackEntryUnchecked: [depth: processor: block:;; copy; depth FALSE processor block  getStackEntryWith];

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

  ("stack:" LF "depth=" processor block getStackDepth LF) printList

  i: 0 dynamic;
  [
    i @processor block getStackDepth < [
      entry: i @processor block getStackEntryUnchecked;
      (entry @processor block getMplType entry.mutable ["R"] ["C"] if entry getVar.temporary ["T"] [""] if
        entry isPlain [entry getPlainValueInformation] [String] if LF) printList
      i 1 + @i set TRUE
    ] &&
  ] loop
] "defaultPrintStack" exportFunction

{
  block: Block Cref;
  processor: Processor Cref;
} () {} [
  processor: block: ;;

  processor.positions.getSize [
    currentPosition: processor.positions.getSize 1 - i - processor.positions.at;

    (
      "at fileName: " currentPosition.file.name
      ", token: "     currentPosition.token
      ", line: "      currentPosition.line
      ", column: "    currentPosition.column LF
    ) printList
  ] times

  @processor block defaultPrintStack
] "defaultPrintStackTrace" exportFunction

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
  @newEvent @block addShadowEvent
];

nodeHasCode: [
  node:;
  node.emptyDeclaration ~ [node.uncompilable ~] && [node.empty ~] && [node.deleted ~] && [node.nodeCase NodeCaseCodeRefDeclaration = ~] &&
];

addBlockIdTo: [
  whereNames: nameInfo: nameOverloadDepth: captureCase: mplSchemaId: file: processor: block: ;;;;;;;;

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
    ] when

    result
  ];

  addBlockToObjectCase: [
    nameOverloadDepth: mplSchemaId: table: ;;;

    nameOverloadDepth table.size < ~ [nameOverloadDepth 1 + @table.resize] when
    whereTypes: nameOverloadDepth @table.at;
    mplSchemaId whereTypes.size < ~ [mplSchemaId 1 + @whereTypes.resize] when
    whereIds: mplSchemaId @whereTypes.at;
    @whereIds addToLine
  ];

  nameInfo processor.specialNames.selfNameInfo = [
    nameOverloadDepth mplSchemaId @whereNames.@selfNames addBlockToObjectCase
  ] [
    nameInfo processor.specialNames.closureNameInfo =  [
      nameOverloadDepth mplSchemaId @whereNames.@closureNames addBlockToObjectCase
    ] [
      nameInfo whereNames.simpleNames.size < ~ [nameInfo 1 + @whereNames.@simpleNames.resize] when
      whereOverloads: nameInfo @whereNames.@simpleNames.at;
      nameOverloadDepth whereOverloads.size < ~ [nameOverloadDepth 1 + @whereOverloads.resize] when
      whereIds: nameOverloadDepth @whereOverloads.at;
      @whereIds addToLine
    ] if
  ] if
];

addEmptyCapture: [
  processor: block: ;;
  nameInfo: nameOverloadDepth: ;;
  file:;

  @processor.@captureTable nameInfo nameOverloadDepth NameCaseInvalid processor.varForFails getVar.mplSchemaId file @processor @block addBlockIdTo [
    newEvent: ShadowEvent;
    ShadowReasonCapture @newEvent.setTag
    branch: ShadowReasonCapture @newEvent.get;

    processor.varForFails @branch.@refToVar set
    nameInfo              @branch.@nameInfo set
    nameOverloadDepth     @branch.@nameOverloadDepth set
    NameCaseInvalid       @branch.@captureCase set
    file                  @branch.@file.set
    ArgMeta               @branch.@argCase set
    @newEvent @block addShadowEvent
  ] when
];

addShadowEvent: [
  event: block: ;;

  #begin of var go to matching

  event @block.@buildingMatchingInfo.@shadowEvents.pushBack

  block.state NodeStateNew = [
    event @block.@matchingInfo.@shadowEvents.pushBack
  ] when
];

getTopNode: [
  processor: topNode:;;
  [topNode.parent 0 = ~] [
    topNode.parent @processor.@blocks.at.get !topNode
  ] while

  @topNode
];
