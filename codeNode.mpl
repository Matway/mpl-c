"Array" use
"HashTable" use
"Owner" use
"String" use
"control" use
"conventions" use
"memory" use

"Block" use
"MplFile" use
"Var" use
"astNodeType" use
"debugWriter" use
"declarations" use
"defaultImpl" use
"irWriter" use
"pathUtils" use
"processor" use
"staticCall" use
"variable" use

startsFrom: [
  s1: s2: makeStringView; makeStringView;
  s1.size s2.size < ~ [s2.size Natx cast s2.data storageAddress s1.data storageAddress memcmp 0 =] &&
];

addNameInfo: [
  processor: block: ;;
  params:;

  forOverload:    params "overload"       has [params.overload copy] [FALSE dynamic] if;
  mplFieldIndex:  params "mplFieldIndex"  has [params.mplFieldIndex copy] [-1 dynamic] if;
  object:         params "object"         has [params.object copy] [RefToVar] if;
  reg:            params "reg"            has [params.reg copy] [TRUE dynamic] if;
  startPoint:     params "startPoint"     has [params.startPoint copy] [block.id copy] if;
  overloadDepth:  params "overloadDepth"  has [params.overloadDepth copy] [0 dynamic] if;
  file:           params "file"           has [params.file] [processor.positions.last.file] if;
  addNameCase:    params.addNameCase copy dynamic;
  refToVar:       params.refToVar copy dynamic;
  nameInfo:       params.nameInfo copy dynamic;

  [params.refToVar.assigned] "Add name must have corrent refToVar!" assert

  #reg [block.parent 0 =] && [
  #  nameInfo processor.nameManager.getText "lambda." startsFrom [
  #    "Lambdas are not allowed in root!" failProc
  #  ] when
  #] when

  [
    nameInfo 0 < ~ [
      addInfo: TRUE;

      reg ~ [addNameCase NameCaseBuiltin =] || [
      ] [
        nameWithOverload: NameWithOverloadAndRefToVar;
        refToVar      @nameWithOverload.@refToVar          set
        overloadDepth @nameWithOverload.@nameOverloadDepth set
        nameInfo      @nameWithOverload.@nameInfo          set
        startPoint    @nameWithOverload.@startPoint        set
        forOverload   @nameWithOverload.@hasOverloadWord   set

        addNameCase NameCaseLocal = [
          nameWithOverload @block.@labelNames.pushBack
        ] [
          addNameCase NameCaseFromModule = [
            nameWithOverload @block.@fromModuleNames.pushBack
          ] [
            addNameCase NameCaseCapture = [addNameCase NameCaseSelfObjectCapture =] || [addNameCase NameCaseClosureObjectCapture =] || [
              FALSE @addInfo set
            ] [
              addNameCase NameCaseSelfMember = [addNameCase NameCaseClosureMember =] || [
                FALSE @addInfo set
              ] [
                addNameCase NameCaseSelfObject = [addNameCase NameCaseClosureObject =] || [
                  # do nothing
                  FALSE @addInfo set
                ] [
                  [FALSE] "wrong name info case" assert
                ] if
              ] if
            ] if
          ] if
        ] if
      ] if

      addInfo [ # captures dont live in stack
        nameInfoEntry: NameInfoEntry;
        forOverload [
          File Cref @nameInfoEntry.!file
        ] [
          file @nameInfoEntry.!file
        ] if

        isLocal: startPoint processor.blocks.at.get.parent 0 = ~;

        object        @nameInfoEntry.@object set
        refToVar      @nameInfoEntry.@refToVar set
        addNameCase   @nameInfoEntry.@nameCase set
        startPoint    @nameInfoEntry.@startPoint set
        mplFieldIndex @nameInfoEntry.@mplFieldIndex set
        isLocal       @nameInfoEntry.@isLocal set

        @nameInfoEntry nameInfo @processor.@nameManager.addItem
      ] when
    ] [
      #we add "self" or "closure" but dont use them in program
    ] if
  ] call
];

getNameLastIndexInfo: [
  nameInfo:;
  currentNameInfo: nameInfo @processor.@nameInfos.at;

  result: IndexInfo;
  currentNameInfo.stack.size 1 - @result.@overload set
  currentNameInfo.stack.last.size 1 - @result.@index set
  result
];

deleteNameInfo: [
  copy nameInfo:;

  nameInfo @processor.@nameManager.removeItem
];

makeStaticity: [
  refToVar: staticity: processor: block:;;;;
  refToVar isVirtual ~ [
    var: @refToVar getVar;
    staticity @var.@staticity.@begin set
    staticity @var.@staticity.@end set

    staticity Virtual < ~ [
      @refToVar @processor block makeVariableType
    ] when
  ] when

  refToVar copy
];

makeEndStaticity: [
  refToVar: staticity: processor: block:;;;;
  refToVar isVirtual ~ [
    var: @refToVar getVar;
    staticity @var.@staticity.@end set
    staticity Virtual < ~ [
      @refToVar @processor block makeVariableType
    ] when
  ] when

  refToVar copy
];

makeStorageStaticity: [
  refToVar: staticity: processor: block:;;;;

  refToVar isVirtual ~ [
    staticity @refToVar getVar.@storageStaticity set
  ] when

  refToVar copy
];

createVariable: [
  processor: block:;;
  FALSE dynamic TRUE dynamic @processor @block createVariableWithVirtual
];

createVariableWithVirtual: [
  processor: block: ;;
  copy makeType:;
  copy makeVirtual:;
  copy tag:;
  dataIsMoved: isMoved;
  data:;

  v: Variable;
  tag @v.@data.setTag
  branch: tag @v.@data.get;

  @data dataIsMoved moveIf @branch set
  block.parent 0 = @v.@global set

  v.global [
    processor.globalVarId @v.@globalId set
    processor.globalVarId 1 + @processor.@globalVarId set
  ] when

  processor.variables.size 0 = [processor.variables.last.size 4096 =] || [
    processor.variables.size 1 + @processor.@variables.enlarge
    4096 @processor.@variables.last.setReserve
  ] when

  @v move @processor.@variables.last.pushBack
  # now forget about v

  result: RefToVar;
  @processor.@variables.last.last @result.setVar
  TRUE @result.setMoved
  @block @result getVar.@host.set
  result @result getVar.@sourceOfValue set

  makeVirtual [
    Virtual @result getVar.@staticity.@begin set
  ] [
    result isPlain [processor.options.staticLiterals ~] && [
      Weak @result getVar.@staticity.@begin set
    ] [
      Static @result getVar.@staticity.@begin set
    ] if
  ] if

  result getVar.staticity.begin @result getVar.@staticity.@end set

  result @result getVar.@capturedHead set
  result @result getVar.@capturedTail set

  result isNonrecursiveType ~ [result isUnallocable ~] && @result.setMutable

  makeType [@result @processor block makeVariableType] when
  @result @processor block makeVariableIRName

  processor.varCount 1 + @processor.@varCount set

  @result
];

createRefVariable: [
  branch: createDependent: processor: block: ;;;;
  result: branch VarRef @processor @block createVariable;

  branch.refToVar getVar.storageStaticity Dynamic = [
    @result Dynamic @processor @block makeStaticity drop
    createDependent [
      (result copy branch.refToVar copy TRUE) @block.@dependentPointers.pushBack
    ] when
  ] when

  @result
];

getNilVar: [
  refToVar: processor: block: ;;;

  varSchema: refToVar @processor getMplSchema;
  varSchema.nilVar.assigned ~ [
    block: 0 @processor.@blocks.at.get;
    refToVar @processor @block copyVarFromType Dirty @processor @block makeStaticity Virtual @processor @block makeStorageStaticity @varSchema.@nilVar set
    var: @varSchema.@nilVar getVar;
    "null" toString @processor makeStringId @var.@irNameId set
    @varSchema.@nilVar fullUntemporize
    "; null" @block createComment
    block.program.size 1 - @var.@allocationInstructionIndex set
  ] when

  varSchema.nilVar copy
];

getLastShadow: [
  refToVar: processor: block: ;;;

  result: RefToVar;
  @result refToVar ShadowReasonCapture @processor @block makeShadows
  @result fullUntemporize
  @result
];

updateInputCountInMatchingInfo: [
  delta: matchingInfo: ;;

  matchingInfo.currentInputCount delta + @matchingInfo.!currentInputCount
  matchingInfo.currentInputCount matchingInfo.maxInputCount > [
    matchingInfo.currentInputCount copy @matchingInfo.!maxInputCount
  ] when
];

updateInputCount: [
  delta: block:;;


  delta @block.@buildingMatchingInfo updateInputCountInMatchingInfo
  block.state NodeStateNew = [
    delta @block.@matchingInfo updateInputCountInMatchingInfo
  ] when
];

{
  block: Block Ref;
  entry: RefToVar Cref;
} () {} [
  entry: block:;;

  entry @block.@stack.pushBack
  -1 @block updateInputCount
] "push" exportFunction

{
  block: Block Ref;
  entry: RefToVar Cref;
} () {} [
  entry: block:;;

  entry @block.@stack.pushBack
] "pushForMatching" exportFunction

setTopologyIndex: [
  block: refToVar: ;;

  refToVar noMatterToCopy ~ [
    var: @refToVar getVar;
    var.buildingTopologyIndex 0 < [
      topologyIndex: @block.@buildingMatchingInfo.@lastTopologyIndex;

      topologyIndex @var.@buildingTopologyIndex set
      block.state NodeStateNew = [topologyIndex @var.@topologyIndex set] when
      topologyIndex 1 + @topologyIndex set
    ] when
  ] when
];

makeVarCode:   [VarCode   @processor @block createVariable];
makeVarInt8:   [VarInt8   @processor @block checkValue makeValuePair VarInt8   @processor @block createVariable @processor @block createPlainIR];
makeVarInt16:  [VarInt16  @processor @block checkValue makeValuePair VarInt16  @processor @block createVariable @processor @block createPlainIR];
makeVarInt32:  [VarInt32  @processor @block checkValue makeValuePair VarInt32  @processor @block createVariable @processor @block createPlainIR];
makeVarInt64:  [VarInt64  @processor @block checkValue makeValuePair VarInt64  @processor @block createVariable @processor @block createPlainIR];
makeVarIntX:   [VarIntX   @processor @block checkValue makeValuePair VarIntX   @processor @block createVariable @processor @block createPlainIR];
makeVarNat8:   [VarNat8   @processor @block checkValue makeValuePair VarNat8   @processor @block createVariable @processor @block createPlainIR];
makeVarNat16:  [VarNat16  @processor @block checkValue makeValuePair VarNat16  @processor @block createVariable @processor @block createPlainIR];
makeVarNat32:  [VarNat32  @processor @block checkValue makeValuePair VarNat32  @processor @block createVariable @processor @block createPlainIR];
makeVarNat64:  [VarNat64  @processor @block checkValue makeValuePair VarNat64  @processor @block createVariable @processor @block createPlainIR];
makeVarNatX:   [VarNatX   @processor @block checkValue makeValuePair VarNatX   @processor @block createVariable @processor @block createPlainIR];
makeVarReal32: [VarReal32 @processor @block checkValue makeValuePair VarReal32 @processor @block createVariable @processor @block createPlainIR];
makeVarReal64: [VarReal64 @processor @block checkValue makeValuePair VarReal64 @processor @block createVariable @processor @block createPlainIR];

getPointeeForMatching: [
  processor: block: ;;
  refToVar:;
  var: refToVar getVar;
  [var.data.getTag VarRef =] "Not a reference!" assert
  pointee: VarRef var.data.get.refToVar; # reference
  result: pointee copy;
  refToVar.mutable pointee.mutable and @result.setMutable # to deref is
  result
];

getPointeeWith: [
  refToVar: makeDerefIR: dynamize: processor: block: ;;;;;
  var: @refToVar getVar;
  [var.data.getTag VarRef =] "Not a reference!" assert
  refToVar isVirtualType [
    refToVar copy
  ] [
    pointee: VarRef @var.@data.get.@refToVar; # reference

    fromParent: pointee getVar.host block is ~;
    pointeeIsGlobal: FALSE dynamic;
    needReallyDeref: FALSE dynamic;

    refToVar staticityOfVar Dynamic > ~ [
      # create new var of dynamic dereference
      result: pointee @processor @block copyOneVarFromType
        Dynamic @processor @block  makeStorageStaticity
        Dirty @processor @block makeStaticity;
      @result @processor block unglobalize
      result.var     @pointee.setVar
      result.mutable @pointee.setMutable
      (refToVar copy pointee copy TRUE) @block.@dependentPointers.pushBack

      TRUE @needReallyDeref set
    ] [
      pointeeGDI: pointee getVar.globalDeclarationInstructionIndex;
      fromParent [ # capture or argument
        result: RefToVar;
        @result pointee ShadowReasonPointee @processor @block makeShadows
        result.var     @pointee.setVar
        result.mutable @pointee.setMutable

        TRUE @needReallyDeref set
      ] when

      pointee isGlobal [
        TRUE @pointeeIsGlobal set
      ] when

      sourceValueVar: var.sourceOfValue getVar;
      sourceValueVar.buildingTopologyIndex 0 < ~ [ #source can be local var in child scope, we must handle this case
        shadowUsed: VarRef @sourceValueVar.@data.get.@usedHere;

        refToVar noMatterToCopy ~ [sourceValueVar.capturedHead getVar.host block is ~] && [pointee noMatterToCopy ~] && [shadowUsed ~] && [sourceValueVar.staticity.begin Static =] && [
          TRUE @shadowUsed set
          newEvent: ShadowEvent;
          ShadowReasonPointee @newEvent.setTag
          branch: ShadowReasonPointee @newEvent.get;
          [sourceValueVar.host var.host is] "Source of value is from another node!" assert
          var.sourceOfValue @branch.@pointer set
          pointee           @branch.@pointee set
          @block @branch.@pointee setTopologyIndex

          @newEvent @processor @block addShadowEvent
        ] when

      ] when
    ] if

    pointee untemporize
    pointeeVar: @pointee getVar;
    pointeeVar.getInstructionIndex 0 <  [pointeeVar.allocationInstructionIndex 0 <] && [pointeeIsGlobal ~] && [
      TRUE @needReallyDeref set
    ] [
      FALSE @needReallyDeref set
    ] if

    needReallyDeref makeDerefIR and [
      refToVar pointeeVar.irNameId @processor @block createDerefTo
      block.program.size 1 - @pointeeVar.@getInstructionIndex set
    ] when

    result: pointee copy;
    refToVar.mutable pointee.mutable and @result.setMutable # to deref is
    result
  ] if
];

getPointee:              [processor: block: ;; TRUE  FALSE @processor @block getPointeeWith];
getPointeeNoDerefIR:     [processor: block: ;; FALSE FALSE @processor @block getPointeeWith];
getPointeeWhileDynamize: [processor: block: ;; FALSE TRUE  @processor @block getPointeeWith];

getFieldForMatching: [
  mplFieldIndex: refToVar: processor: block: ;;;;

  var: refToVar getVar;
  [var.data.getTag VarStruct =] "Not a combined!" assert
  structInfo: VarStruct @var.@data.get.get;

  mplFieldIndex 0 < ~ [
    fieldRefToVar: mplFieldIndex structInfo.fields.at.refToVar copy;
    refToVar.mutable @fieldRefToVar.setMutable
    @fieldRefToVar @processor block unglobalize
    refToVar varIsMoved @fieldRefToVar.setMoved

    fieldRefToVar
  ] [
    "index is out of bounds" @processor block compilerError
    RefToVar
  ] if
];

getFieldWith: [
  whileMakingTreeDynamicStoraged: mplFieldIndex: refToVar: processor: block: ;;;;;
  var: @refToVar getVar;
  [var.data.getTag VarStruct =] "Not a combined!" assert
  structInfo: VarStruct @var.@data.get.get;

  mplFieldIndex 0 < ~ [mplFieldIndex structInfo.fields.getSize <] && [
    fieldRefToVar: mplFieldIndex @structInfo.@fields.at.@refToVar;
    fieldVar: @fieldRefToVar getVar;
    fieldVar.data.getTag VarStruct = [
      fieldStruct: VarStruct @fieldVar.@data.get.get;
      refToVar varIsMoved @fieldRefToVar.setMoved
    ] when

    structIsDynamicStoraged: var.storageStaticity Dynamic =;
    fieldShadow: RefToVar;

    fieldRefToVar noMatterToCopy ~ [
      structIsDynamicStoraged [
        mplFieldIndex structInfo.fields.at.usedHere ~ [
          fieldRefToVar @processor @block copyOneVarFromType Dynamic @processor @block makeStorageStaticity Dirty @processor @block makeStaticity @fieldShadow set
          TRUE mplFieldIndex @structInfo.@fields.at.!usedHere
          TRUE
        ] &&
      ] [
        fieldVar.host block is ~ [
          @fieldShadow fieldRefToVar ShadowReasonField @processor @block makeShadows
          var.storageStaticity Virtual = [
            @fieldShadow Dirty @processor @block makeStaticity drop
          ] when
          @fieldShadow @processor block unglobalize
          TRUE
        ] &&
      ] if
    ] && [ # capture or argument
      fieldShadow getVar.data.getTag VarStruct = [
        fieldStruct: VarStruct @fieldShadow getVar.@data.get.get;
        refToVar varIsMoved @fieldShadow.setMoved
      ] when

      fieldShadow @fieldRefToVar set
      fieldVar: @fieldRefToVar getVar;

      var.staticity.end fieldVar.staticity.end < [
        var.staticity.end @fieldVar.@staticity.@end set
      ] when
    ] when

    fieldRefToVar.mutable @fieldRefToVar.setMutable

    refToVar noMatterToCopy ~ [fieldRefToVar noMatterToCopy ~] && [
      var.capturedHead getVar.host block is ~ [var.buildingTopologyIndex 0 < ~] && [mplFieldIndex structInfo.fields.at.usedHere ~] && [structIsDynamicStoraged ~] && [
        TRUE mplFieldIndex @structInfo.@fields.at.!usedHere

        newEvent: ShadowEvent;
        ShadowReasonField @newEvent.setTag
        branch: ShadowReasonField @newEvent.get;

        refToVar      @branch.@object set
        mplFieldIndex @branch.@mplFieldIndex set
        fieldRefToVar @branch.@field set

        @block @branch.@field setTopologyIndex
        @newEvent @processor @block addShadowEvent
      ] [
        structIsDynamicStoraged [
          (refToVar copy fieldRefToVar copy FALSE) @block.@dependentPointers.pushBack
        ] when
      ] if
    ] when

    refToVar.mutable @fieldRefToVar.setMutable
    @fieldRefToVar
  ] [
    "index is out of bounds" @processor block compilerError
    failResult: RefToVar Ref;
    @failResult
  ] if
];

getField: [
  mplFieldIndex: refToVar: processor: block: ;;;;
  FALSE dynamic mplFieldIndex refToVar @processor @block getFieldWith
];

captureEntireStruct: [
  refToVar:;
  unprocessed: RefToVar Array;

  refToVar @unprocessed.pushBack

  i: 0 dynamic;
  [
    i unprocessed.size < [
      current: i unprocessed.at copy;
      currentVar: current getVar;
      currentVar.data.getTag VarStruct = [current noMatterToCopy ~] && [
        branch: VarStruct currentVar.data.get.get;
        f: 0 dynamic;
        [
          f branch.fields.size < [
            f @current @processor @block getField @unprocessed.pushBack
            f 1 + @f set TRUE
          ] &&
        ] loop
      ] when

      i 1 + @i set TRUE
    ] &&
  ] loop
];

setOneVar: [
  copy first:;
  refDst:;
  refSrc:;

  srcVar: refSrc  getVar;
  dstVar: @refDst getVar;

  [srcVar.data.getTag dstVar.data.getTag =] "Variable types mismatch!" assert
  [refSrc isVirtual refDst isVirtual =] "Virtualness mismatch!" assert
  [refDst.mutable] "Constness mismatch!" assert

  srcVar.data.getTag VarStruct = ~ [
    srcVar.data.getTag VarRef = [
      VarRef srcVar.data.get
      VarRef @dstVar.@data.get set
    ] [
      srcVar.data.getTag VarCond VarReal64 1 + [
        copy tag:;
        tag srcVar.data.get.end
        tag @dstVar.@data.get.@end set
      ] staticCall
    ] if
  ] when

  @refDst makeVarPtrCaptured
  @refDst @processor @block makeVarRealCaptured

  [srcVar.sourceOfValue getVar.host dstVar.sourceOfValue getVar.host is] "Source of value is from another node!" assert
  srcVar.sourceOfValue @dstVar.@sourceOfValue set

  refDst staticityOfVar Dirty > [
    staticity: refSrc staticityOfVar;
    staticity Weak = [refDst staticityOfVar @staticity set] when
    @refDst staticity @processor block makeEndStaticity drop
  ] [
    srcVar.data.getTag VarRef = [refSrc.mutable] && [VarRef srcVar.data.get.refToVar.mutable] && [
      staticity: refSrc staticityOfVar;
      refSrc @processor @block makeVarTreeDirty
      @refSrc staticity @processor block makeEndStaticity drop
    ] when
  ] if
];

{
  block: Block Ref;
  processor: Processor Ref;
  createOperation: Cond;
  mutable: Cond;
  refToVar: RefToVar Cref;
  result: RefToVar Ref;
} () {} [
  result: refToVar: mutable: createOperation: processor: block: ;;;;;;
  overload failProc: processor block FailProcForProcessor;

  refToVar isVirtual [
    @refToVar untemporize
    refToVar @result set #for dropping or getting callables for example
  ] [
    pointee: refToVar copy;
    var: @pointee getVar;
    pointee staticityOfVar Weak = [Dynamic @var.@staticity.@end set] when
    @pointee fullUntemporize

    pointee.mutable [mutable copy] && @pointee.setMutable
    newRefToVar: pointee makeRefBranch TRUE @processor @block createRefVariable;
    createOperation [pointee @newRefToVar @processor @block createRefOperation] when
    newRefToVar @result set
  ] if
] "createRefWithImpl" exportFunction

createCheckedStaticGEP: [
  fieldRef: index: refToStruct: processor: block: ;;;;;
  fieldVar: @fieldRef getVar;
  fieldVar.getInstructionIndex 0 < [fieldVar.allocationInstructionIndex 0 <] && [
    @fieldRef @processor block unglobalize
    fieldRef index refToStruct @processor @block createStaticGEP
    block.program.size 1 - @fieldVar.@getInstructionIndex set
  ] when
];

makeVirtualVarReal: [
  refToVar: processor: block: ;;;

  refToVar isVirtualType [
    refToVar copy
  ] [
    processor.options.verboseIR [("made virtual var real, type: " refToVar @processor block getMplType) assembleString @block createComment] when

    realValue: @refToVar getVar.@realValue;

    unfinishedSrc: RefToVar Array;
    unfinishedDst: RefToVar Array;

    result: refToVar @processor @block copyOneVar;

    result isVirtualType ~ [
      Static makeValuePair @result getVar.@staticity set

      refToVar @unfinishedSrc.pushBack
      result @unfinishedDst.pushBack

      # first pass: make new variable type
      [
        unfinishedSrc.size 0 > [
          lastSrc: unfinishedSrc.last copy;
          lastDst: unfinishedDst.last copy;
          @unfinishedSrc.popBack
          @unfinishedDst.popBack

          varSrc: lastSrc  getVar;
          varDst: @lastDst getVar;

          lastDst noMatterToCopy ~ [lastDst @varDst.@sourceOfValue set] when

          # noMatterToCopy
          varSrc.data.getTag VarStruct = [
            struct: VarStruct varSrc.data.get.get;
            j: 0 dynamic;
            [
              j struct.fields.size < [
                srcField: j struct.fields.at;
                srcField.refToVar isVirtual ~ [
                  srcField.refToVar @unfinishedSrc.pushBack
                  dstField: j @lastDst @processor @block getField;
                  dstField @unfinishedDst.pushBack
                  @dstField @processor block unglobalize
                ] [
                  dstField: j @lastDst @processor @block getField;
                  @dstField Virtual @processor block makeStaticity r:;
                  @dstField @processor block unglobalize
                ] if

                j 1 + @j set TRUE
              ] &&
            ] loop
          ] when

          processor compilable
        ] &&
      ] loop

      # second pass: create IR code for variable
      @result @processor block makeVariableType
      refToVar @unfinishedSrc.pushBack
      @result @processor @block createAllocIR @unfinishedDst.pushBack

      [
        unfinishedSrc.size 0 > [
          lastSrc: unfinishedSrc.last copy;
          lastDst: unfinishedDst.last copy;
          @unfinishedSrc.popBack
          @unfinishedDst.popBack

          varSrc: lastSrc getVar;
          varSrc.data.getTag VarStruct = [
            struct: VarStruct varSrc.data.get.get;
            j: 0 dynamic;
            [
              j struct.fields.size < [
                srcField: j struct.fields.at;
                srcField.refToVar isVirtual ~ [
                  srcField.refToVar @unfinishedSrc.pushBack
                  dstField: j @lastDst @processor @block getField;
                  dstField @unfinishedDst.pushBack
                  @dstField @processor block unglobalize
                  @dstField j lastDst @processor @block createCheckedStaticGEP
                ] when

                j 1 + @j set TRUE
              ] &&
            ] loop
          ] [
            lastSrc isVirtualType ~ [
              varSrc.data.getTag VarRef = [
              ] [
                lastSrc isPlain [
                  lastSrc lastDst @processor @block createStoreConstant
                ] when
              ] if
            ] when
          ] if

          processor compilable
        ] &&
      ] loop
    ] when

    result isPlain [
      FALSE @result.setMutable
    ] when

    result @realValue set

    realValue copy
  ] if
];

makeVarSchema: [
  refToVar:;
  @refToVar Schema @processor block makeStaticity drop
];

makeVarVirtual: [
  refToVar:;
  unfinished: RefToVar Array;
  refToVar @unfinished.pushBack
  [
    unfinished.size 0 > [
      cur: @unfinished.last copy;
      @unfinished.popBack
      curVar: cur getVar;
      curVar.data.getTag VarStruct = [
        cur isAutoStruct [
          "can not virtualize automatic struct" @processor block compilerError
        ] [
          struct: VarStruct curVar.data.get.get;
          j: 0 dynamic;
          [
            j struct.fields.size < [processor compilable] && [
              curField: j struct.fields.at;
              curField.refToVar isVirtual ~ [
                curField.refToVar @unfinished.pushBack
              ] when
              j 1 + @j set TRUE
            ] &&
          ] loop
        ] if
      ] [
        curVar.data.getTag VarRef = [
          pointee:  VarRef curVar.data.get.refToVar;

          pointee isUnallocable [
            cur staticityOfVar Weak < [
              "can not virtualize dynamic value" @processor block compilerError
            ] when
          ] [
            pointee getVar.storageStaticity Virtual = [
            ] [
              "can not virtualize reference to local variable" @processor block compilerError
            ] if
          ] if
        ] [
          cur staticityOfVar Weak < [
            "can not virtualize dynamic value" @processor block compilerError
          ] when
        ] if
      ] if
      processor compilable
    ] &&
  ] loop

  processor compilable [
    @refToVar Virtual @processor block makeStaticity drop
  ] when
];

makeVarTreeDirty: [
  refToVar: processor: block:;;;
  unfinishedVars: RefToVar Array;
  refToVar @unfinishedVars.pushBack

  [
    unfinishedVars.size 0 > [
      lastRefToVar: unfinishedVars.last copy;
      @unfinishedVars.popBack

      lastRefToVar staticityOfVar Virtual = ["can't dynamize virtual value" @processor block compilerError] when
      lastRefToVar staticityOfVar Dirty = [
        #skip
      ] [
        processor compilable [
          var: lastRefToVar getVar;
          var.data.getTag VarStruct = [
            struct: VarStruct var.data.get.get;
            j: 0 dynamic;
            [
              j struct.fields.size < [
                j struct.fields.at.refToVar isVirtual ~ [
                  j @lastRefToVar @processor @block getField @unfinishedVars.pushBack
                ] when
                j 1 + @j set TRUE
              ] &&
            ] loop
          ] [
            var.data.getTag VarRef = [
              lastRefToVar staticityOfVar Static = [
                pointee: @lastRefToVar @processor @block getPointeeWhileDynamize;
                pointee @unfinishedVars.pushBack
              ] [
                [lastRefToVar staticityOfVar Dynamic > ~] "Ref must be only Static or Dynamic!" assert
              ] if
            ] when
          ] if

          var.data.getTag VarImport = ~ var.data.getTag VarString = ~ and [
            @lastRefToVar Dirty @processor block makeEndStaticity @lastRefToVar set
          ] when
        ] when
      ] if

      processor compilable
    ] &&
  ] loop
];

makePointeeDirtyIfRef: [
  refToVar: processor: block: ;;;
  var: refToVar getVar;
  var.data.getTag VarRef = [var.staticity.end Static =] && [
    pointee: @refToVar @processor @block getPointeeWhileDynamize;
    @pointee makeVarPtrCaptured
    pointee.mutable [pointee @processor @block makeVarTreeDirty] when
  ] when
];

makeVarDynamicOrDirty: [
  processor: block: ;;
  newStaticity:;
  refToVar:;
  var: refToVar getVar;

  refToVar staticityOfVar Virtual = ["can't dynamize virtual value" @processor block compilerError] when

  @refToVar @processor @block makePointeeDirtyIfRef

  newStaticity var.staticity.end < [
    newStaticity @var.@staticity.@end set
  ] when
];

makeVarDynamic: [processor: block: ;; Dynamic @processor @block makeVarDynamicOrDirty];
makeVarDirty:   [processor: block: ;; Dirty   @processor @block makeVarDynamicOrDirty];

makeVarTreeDynamicWith: [
  refToVar: dynamicStoraged: processor: block: ;;;;
  unfinishedVars: RefToVar Array;
  refToVar @unfinishedVars.pushBack

  [
    unfinishedVars.size 0 > [
      lastRefToVar: unfinishedVars.last copy;
      @unfinishedVars.popBack

      var: lastRefToVar getVar;
      lastRefToVar staticityOfVar Virtual = ["can't dynamize virtual value" @processor block compilerError] when

      var.data.getTag VarStruct = [
        struct: VarStruct var.data.get.get;
        j: 0 dynamic;
        [
          j struct.fields.size < [
            j struct.fields.at.refToVar isVirtual ~ [
              dynamicStoraged j @lastRefToVar @processor @block getFieldWith @unfinishedVars.pushBack
            ] when
            j 1 + @j set TRUE
          ] &&
        ] loop
      ] [
        var.data.getTag VarRef = [
          lastRefToVar staticityOfVar Static = [
            dynamicStoraged ~ [
              pointee: @lastRefToVar @processor @block getPointeeWhileDynamize;
              pointee.mutable [pointee @processor @block makeVarTreeDirty] when
            ] when # dynamic storaged data is not real
          ] [
            [lastRefToVar staticityOfVar Dynamic = lastRefToVar staticityOfVar Dirty = or] "Ref must be only Static or Dirty or Dynamic!" assert
          ] if
        ] when
      ] if

      dynamicStoraged [
        lastRefToVar  Dynamic @processor block makeStorageStaticity drop
        @lastRefToVar Dirty   @processor block makeEndStaticity drop
      ] [
        var.data.getTag VarStruct = ~ [var.staticity.end Dynamic >] && [
          @lastRefToVar Dynamic @processor block makeEndStaticity drop
        ] when
      ] if

      processor compilable
    ] &&
  ] loop
];

makeVarTreeDynamic:         [processor: block: ;; FALSE dynamic @processor @block makeVarTreeDynamicWith];
makeVarTreeDynamicStoraged: [processor: block: ;; TRUE  dynamic @processor @block makeVarTreeDynamicWith];

checkPossibleUnstables: [
  nameInfo: processor: block: ;;;

  block.parent 0 = [
    nameInfo processor.possibleUnstables.getSize < [
      current: nameInfo @processor.@possibleUnstables.at;
      current [
        blockId:;
        unstableBlock: blockId @processor.@blocks.at.get;
        TRUE @unstableBlock.@changedStableName set
      ] each

      @current.clear
    ] when
  ] when
];

createNamedVariable: [
  nameInfo: refToVar: processor: block: ;;;;

  processor compilable [
    newRefToVar: refToVar copy;
    staticity: refToVar staticityOfVar;
    var: @newRefToVar getVar;

    block.nextLabelIsVirtual [
      refToVar isVirtual ~ [
        staticity Weak = [Static @var.@staticity.@end set] when
      ] when
    ] when

    isGlobalLabel: [
      refToVar:;
      block.nextLabelIsVirtual ~ [refToVar isVirtual ~] && [refToVar isGlobal] &&
    ];

    var.temporary [refToVar isGlobalLabel] && [
      refToVar @processor @block makeVarTreeDirty
      Dirty @staticity set
    ] when

    var.temporary [
      staticity @var.@staticity.@end set
      staticity Weak = [Dynamic @var.@staticity.@end set] when
    ] [
      newRefToVar noMatterToCopy [
        refToVar @newRefToVar set
      ] [
        @refToVar TRUE block.nextLabelIsVirtual ~ @processor @block createRefWith @newRefToVar set
        newRefToVar isGlobalLabel [newRefToVar @processor @block makeVarTreeDirty] when
      ] if
    ] if

    TRUE dynamic @newRefToVar.setMutable

    @newRefToVar fullUntemporize
    FALSE @newRefToVar getVar.@tref set

    block.nextLabelIsVirtual [
      @newRefToVar @processor block makeVariableType
      @newRefToVar makeVarVirtual
      FALSE @block.@nextLabelIsVirtual set
    ] when

    {
      addNameCase: NameCaseLocal;
      refToVar:    newRefToVar copy;
      nameInfo:    nameInfo copy;
      overload:    block.nextLabelIsOverload copy;
    } @processor @block addNameInfo

    nameInfo @processor @block checkPossibleUnstables

    block.parent 0 = [
      fr: nameInfo @block.@globalVariableNames.find;
      fr.success [
        newRefToVar @fr.@value.pushBack
      ] [
        newEntry: RefToVar Array;
        newRefToVar @newEntry.pushBack
        nameInfo @newEntry move @block.@globalVariableNames.insert
      ] if
    ] when

    FALSE @block.!nextLabelIsOverload

    processor compilable [processor.options.debug copy] && [newRefToVar isVirtual ~] && [
      newRefToVar isGlobal [
        processor.options.partial copy [
          varBlock: block;
          [varBlock.file isNil ~] "Topnode in nil file!" assert
          varBlock.file.usedInParams ~
        ] && [
          #do not create dbg info
        ] [
          d: nameInfo newRefToVar @processor block addGlobalVariableDebugInfo;
          globalInstruction: newRefToVar getVar.globalDeclarationInstructionIndex @processor.@prolog.at;
          ", !dbg !"   @globalInstruction.cat
          d            @globalInstruction.cat
        ] if
      ] [
        nameInfo newRefToVar @processor @block addVariableMetadata
      ] if
    ] when

    block.nodeCase NodeCaseObject = [
      newField: Field;
      nameInfo    @newField.@nameInfo set
      newRefToVar @newField.@refToVar set

      newField @block.@struct.@fields.pushBack
    ] when

    nameInfo @newRefToVar getVar.@mplNameId set
  ] when
];

processLabelNode: [
  .nameInfo @processor @block pop @processor @block createNamedVariable
];

processCodeNode: [
  astNodeBranch: ;
  codeInfo: CodeNodeInfo;

  processor.positions.last.file        @codeInfo.@file.set
  processor.positions.last.line   copy @codeInfo.!line
  processor.positions.last.column copy @codeInfo.!column
  astNodeBranch                   copy @codeInfo.!index #it is index of array

  @codeInfo move makeVarCode @block push
];

processObjectNode: [
  astNodeBranch: ;
  name: "objectInitializer" makeStringView;
  astNodeBranch NodeCaseObject dynamic name @processor @block processCallByIndexArray
];

processListNode: [
  astNodeBranch: ;
  name: "listInitializer" makeStringView;
  astNodeBranch NodeCaseList dynamic name @processor @block processCallByIndexArray
];

{
  processor: Processor Ref;
  block: Block Cref;
  message: StringView Cref;
} () {} [
  processor:;
  block:;
  message:;
  overload failProc: processor block FailProcForProcessor;

  processor.result.findModuleFail ~ [processor.depthOfPre 0 =] && [hasLogs] && [
    ("COMPILATION ERROR") addLog
    (message) addLog
    @processor block defaultPrintStackTrace
  ] when

  processor compilable [
    FALSE dynamic @processor.@result.@success set

    processor.depthOfPre 0 = [processor.result.passErrorThroughPRE copy] || [
      message toString @processor.@result.@errorInfo.@message set
      processor.positions.getSize [
        currentPosition: processor.positions.getSize 1 - i - processor.positions.at;
        currentPosition @processor.@result.@errorInfo.@position.pushBack
      ] times
    ] when
  ] when
] "compilerErrorImpl" exportFunction

findPossibleModules: [
  nameInfo: processor: ;;

  result: String Array;

  processor.modules [
    pair:;

    fileBlock: pair.value processor.blocks.at.get;
    labelCount: 0;

    fileBlock.labelNames [
      label:;
      label.nameInfo nameInfo = [label.refToVar isVirtual [label.refToVar getVar.data.getTag VarImport =] ||] && [
        labelCount 1 + !labelCount
      ] when
    ] each

    labelCount 0 > [
      pair.key @result.pushBack
    ] when
  ] each

  result
];

catPossibleModulesList: [
  message: nameInfo: processor: ;;;

  possibleModuleNames: nameInfo processor findPossibleModules;
  possibleModuleNames.getSize 0 > [
    "; try use name from modules: " @message.cat
    possibleModuleNames.getSize [
      i 0 > [", " @message.cat] when
      i possibleModuleNames.at @message.cat
    ] times
  ] when
];

getNameAs: [
  file:;
  processor: block: ;;
  copy forMatching:;

  copy overloadIndex:;
  copy nameInfo:;

  unknownName: [
    processor.varForFails @result.@refToVar set

    forMatching ~ [
      message: ("unknown name: " nameInfo processor.nameManager.getText) assembleString;
      @message nameInfo @processor catPossibleModulesList

      message @processor block compilerError
    ] when
  ];

  result: {
    refToVar:          RefToVar;
    startPoint:        -1 dynamic;
    nameInfo:          nameInfo copy;
    overloadIndex:     -1 dynamic;
    object:            RefToVar;
    mplFieldIndex:     -1 dynamic;
    nameCase:          NameCaseInvalid;
  };

  overloadIndex 0 < [
    overloadIndex file nameInfo processor.nameManager.findItem !overloadIndex
  ] when

  overloadIndex 0 < [
    unknownName
  ] [
    nameInfoEntry: overloadIndex nameInfo processor.nameManager.getItem;

    overloadIndex              @result.@overloadIndex set
    nameInfoEntry.nameCase     @result.@nameCase      set
    nameInfoEntry.startPoint   @result.@startPoint    set

    nameInfoEntry.nameCase NameCaseSelfMember = [nameInfoEntry.nameCase NameCaseClosureMember =] || [
      object: nameInfoEntry.object;
      nameInfoEntry.object        @result.@object set
      nameInfoEntry.mplFieldIndex @result.@mplFieldIndex set
      nameInfoEntry.refToVar      @result.@refToVar set
    ] [
      nameInfoEntry.refToVar @result.@refToVar set
    ] if

    moveToTail: [
      refToVar:;
      refToVar.assigned [
        # if var was captured somewhere, we must use it
        head: refToVar getVar.capturedHead;
        result: head getVar.capturedTail copy;
        refToVar.mutable @result.setMutable # tail cant keep correct staticity in some cases
        refToVar varIsMoved @result.setMoved # tail cant keep correct staticity in some cases

        result
      ] [
        refToVar copy
      ] if
    ];

    result.refToVar moveToTail @result.@refToVar set
    result.object   moveToTail @result.@object   set
  ] if

  @result
];

getName:           [processor: block:;; -1 dynamic  FALSE dynamic @processor @block processor.positions.last.file getNameAs];
getNameEverywhere: [processor: block:;; -1 dynamic  FALSE dynamic @processor @block File Cref                     getNameAs];

getNameForMatching: [
  processor: block: file: ;;;
  -1 dynamic TRUE dynamic @processor @block file getNameAs
];

getNameWithOverloadIndex: [
  overloadIndex: processor: block: file: ;;;;
  overloadIndex FALSE dynamic @processor @block file getNameAs
];

getNameForMatchingWithOverloadIndex: [
  overloadIndex: processor: block: file: ;;;;
  overloadIndex TRUE dynamic @processor @block file getNameAs
];

nameResultIsStable: [
  file: getNameResult: processor:  ;;;

  getNameResult.nameCase NameCaseCapture > ~
  [getNameResult.nameInfo processor.nameManager.hasOverload ~] &&
  [getNameResult.nameInfo processor.nameManager.hasLocalDefinition ~] &&
  [getNameResult.nameCase NameCaseInvalid = ~] &&
  [getNameResult.startPoint processor.blocks.at.get.parent 0 =] &&
  [getNameResult.refToVar isVirtual] &&
];

addStableName: [
  refToVar: nameInfo: nameOverloadDepth: file: processor: block: ;;;;;;

  nameInfo processor.captureTable.stableNames.getSize < ~ [nameInfo 1 + @processor.@captureTable.@stableNames.resize] when
  current: nameInfo @processor.@captureTable.@stableNames.at;
  current.getSize 0 = [current.last block.id = ~] || [
    block.id @current.pushBack
    nameInfo @block.@stableNames.pushBack

    newEvent: ShadowEvent;
    ShadowReasonCapture @newEvent.setTag
    branch: ShadowReasonCapture @newEvent.get;
    refToVar          @branch.@refToVar set
    nameInfo          @branch.@nameInfo set
    nameOverloadDepth @branch.@nameOverloadDepth set
    file              @branch.@file.set
    TRUE              @branch.@stable set
    @newEvent @processor @block addShadowEvent
  ] when

  nameInfo @processor @block addToPossibleUnstables
];

addToPossibleUnstables: [
  nameInfo: processor: block: ;;;

  nameInfo processor.possibleUnstables.getSize < ~ [nameInfo 1 + @processor.@possibleUnstables.resize] when
  block.id nameInfo @processor.@possibleUnstables.at.pushBack
];

captureFileToBlock: [
  fileId: block: ;;
  [fileId block.capturedFiles.getSize < ~] [
    FALSE @block.@capturedFiles.pushBack
  ] while

  TRUE fileId @block.@capturedFiles.at set
];

captureName: [
  getNameResult: overloadDepth: processor: block: file: ;;;;;

  result: {
    matchingEntry: RefToVar;
    object:        RefToVar;
    refToVar:      RefToVar;
  };

  checkStable: file getNameResult processor nameResultIsStable;
  file.fileId @block captureFileToBlock

  checkStable [
    getNameResult.refToVar getNameResult.nameInfo overloadDepth file @processor @block addStableName
    getNameResult.refToVar @result.@matchingEntry set
    getNameResult.refToVar @result.@refToVar set
  ] [
    processor compilable [getNameResult.nameCase NameCaseInvalid = ~] && [
      captureRefToVar: [
        copy captureCase:;
        refToVar:;
        copy overloadDepth:;
        copy nameInfo:;

        result: {
          object: RefToVar;
          refToVar: RefToVar;
          newVar: FALSE;
        };

        shadow: RefToVar;
        getNameResult.startPoint block.id = ~ [@processor.@captureTable nameInfo overloadDepth file @processor @block addBlockIdTo] && [
          @shadow refToVar ShadowReasonCapture @processor @block makeShadows
          @shadow fullUntemporize

          newCapture: Capture;
          shadow   @newCapture.@refToVar set
          nameInfo @newCapture.@nameInfo set
          [getNameResult.overloadIndex 0 < ~] "name overload not initialized!" assert

          FALSE                       @newCapture.@stable set
          getNameResult.mplFieldIndex @newCapture.@mplFieldIndex set
          overloadDepth               @newCapture.@nameOverloadDepth set
          file                        @newCapture.@file.set

          refToVar isVirtual [ArgVirtual] [refToVar isGlobal [ArgGlobal] [ArgRef] if ] if @newCapture.@argCase set
          realCapture: newCapture.argCase ArgRef =;

          realCapture [block.exportDepth refToVar getVar.host.exportDepth = ~] && [
            @newCapture.@refToVar @processor @block makeVarTreeDirty
            captureId: block.buildingMatchingInfo.captures.size;
            fr: captureId block.captureErrors.find;
            fr.success ~ [
              captureId processor.positions.last @block.@captureErrors.insert
            ] when
          ] when

          refToVar getVar.data.getTag VarString = ~ refToVar getVar.data.getTag VarImport = ~ and [
            newEvent: ShadowEvent;
            ShadowReasonCapture @newEvent.setTag
            branch: ShadowReasonCapture @newEvent.get;
            newCapture @branch set

            newCapture @block.@buildingMatchingInfo.@captures.pushBack
            block.state NodeStateNew = [
              newCapture @block.@matchingInfo.@captures.pushBack
            ] when

            @block @shadow setTopologyIndex
            @newEvent @processor @block addShadowEvent
          ] when

          getNameResult.mplFieldIndex 0 < ~ [
            shadow @result.@object set
            getNameResult.mplFieldIndex shadow @processor @block processStaticAt @result.@refToVar set
            gii: result.refToVar getVar.getInstructionIndex;
            gii 0 < ~ [
              TRUE gii @block.@program.at.@fakePointer set
            ] when
          ] [
            shadow @result.@refToVar set
          ] if

          processor.options.debug [
            createFakePointer: [
              varForFake: nameInfo: ;;
              varForFake isVirtual ~ [varForFake isGlobal ~] && [
                fakePointer: varForFake makeRefBranch FALSE @processor @block createRefVariable;
                varForFake @fakePointer @processor @block createRefOperation
                nameInfo fakePointer @processor @block addVariableMetadata
                3 [
                  TRUE block.program.getSize 1 - i - @block.@program.at.@fakePointer set
                ] times
                @processor @block addDebugLocationForLastInstruction
              ] when
            ];

            result.refToVar nameInfo createFakePointer

            getNameResult.mplFieldIndex 0 < ~ [
              result.object getVar.usedInDebugInfo ~ [
                captureCase NameCaseSelfMember = [
                  result.object processor.specialNames.selfNameInfo createFakePointer
                ] [
                  captureCase NameCaseClosureMember = [
                    result.object processor.specialNames.closureNameInfo createFakePointer
                  ] when
                ] if

                TRUE @result.@object getVar.!usedInDebugInfo
              ] when
            ] when
          ] when

          TRUE @result.@newVar set

          [shadow getVar.temporary ~] "Captured var must not be temporary!" assert
        ] [
          @shadow refToVar ShadowReasonCapture @processor @block makeShadows

          getNameResult.mplFieldIndex 0 < ~ [
            shadow @result.@object set
            getNameResult.mplFieldIndex shadow @processor @block getField @result.@refToVar set
          ] [
            shadow @result.@refToVar set
          ] if
        ] if

        result
      ];

      # now we must capture and create GEP instruction
      getNameResult.mplFieldIndex 0 < ~ [
        cro: getNameResult.nameInfo overloadDepth @getNameResult.@object getNameResult.nameCase captureRefToVar;
        cro.object    @result.@matchingEntry set
        cro.object    @result.@object set
        cro.refToVar  @result.@refToVar set
        [cro.object noMatterToCopy [cro.object getVar.host.id block.id =] ||] "Capture object is not from here!" assert
      ] [
        cr: getNameResult.nameInfo overloadDepth @getNameResult.@refToVar getNameResult.nameCase captureRefToVar;
        cr.refToVar @result.@matchingEntry set
        RefToVar    @result.@object set
        cr.refToVar @result.@refToVar set
      ] if
    ] [
      file getNameResult.nameInfo overloadDepth @processor @block addEmptyCapture
      processor.varForFails @result.@refToVar set
      processor.varForFails @result.@matchingEntry set
    ] if
  ] if

  result
];

isCallable: [
  refToVar:;
  var: refToVar getVar;
  var.data.getTag VarBuiltin =
  [var.data.getTag VarCode =] ||
  [var.data.getTag VarImport =] || [
    var.data.getTag VarStruct = [
      processor.specialNames.callNameInfo refToVar @processor block findField.success copy
    ] &&
  ] ||
];

addFieldsNameInfos: [
  copy addNameCase:;
  file:;
  refToVar:;

  var: refToVar getVar;
  struct: VarStruct var.data.get.get;

  i: 0 dynamic;
  [
    i struct.fields.size < [
      currentField: i struct.fields.at;
      [currentField.nameInfo processor.specialNames.emptyNameInfo = ~] "Closured list!" assert

      {
        nameInfo:      currentField.nameInfo copy;
        mplFieldIndex: i copy;
        addNameCase:   addNameCase copy;
        object:        refToVar copy;
        refToVar:      currentField.refToVar copy;
        file:          file;
        reg:           FALSE;
      } @processor @block addNameInfo

      i 1 + @i set TRUE
    ] &&
  ] loop
];

deleteFieldsNameInfos: [
  refToVar:;

  var: refToVar getVar;
  struct: VarStruct var.data.get.get;

  i: struct.fields.size;
  [
    i 0 > [
      i 1 - @i set TRUE
      currentField: i struct.fields.at;
      [currentField.nameInfo processor.specialNames.emptyNameInfo = ~] "Closured list!" assert
      currentField.nameInfo deleteNameInfo # name info pointing to the struct, not to a field!
    ] &&
  ] loop
];

regNamesClosure: [
  object: file: ;;
  object.assigned [
    {
      nameInfo:      processor.specialNames.closureNameInfo copy;
      addNameCase:   NameCaseClosureObject;
      refToVar:      object copy;
      reg:           FALSE;
      file:          file;
    } @processor @block addNameInfo

    object file NameCaseClosureMember addFieldsNameInfos
  ] when
];

regNamesSelf: [
  object: file: ;;
  object.assigned [
    {
      nameInfo:      processor.specialNames.selfNameInfo copy;
      addNameCase:   NameCaseSelfObject;
      refToVar:      object copy;
      reg:           FALSE;
      file:          file;
    } @processor @block addNameInfo

    object file NameCaseSelfMember addFieldsNameInfos
  ] when
];

unregNamesClosure: [
  object:;
  object.assigned [
    object deleteFieldsNameInfos
    processor.specialNames.closureNameInfo deleteNameInfo
  ] when
];

unregNamesSelf: [
  object:;
  object.assigned [
    object deleteFieldsNameInfos
    processor.specialNames.selfNameInfo deleteNameInfo
  ] when
];

callCallableStruct: [
  name:;
  refToVar:;
  object:;
  copy field:;

  var: refToVar getVar;
  nextIteration: FALSE;

  struct: VarStruct var.data.get.get;

  fr: processor.specialNames.callNameInfo refToVar @processor block findField;
  [fr.success copy] "Struct is not callable!" assert

  codeField: fr.index struct.fields.at .refToVar;
  codeVar: codeField getVar;
  codeVar.data.getTag VarCode = [
    file: VarCode codeVar.data.get.file;

    object file regNamesSelf
    refToVar file regNamesClosure
    VarCode codeVar.data.get.index name @processor @block processCall
    refToVar unregNamesClosure
    object unregNamesSelf
  ] [
    "CALL field is not a code" @processor block compilerError
  ] if
];

callCallableField: [
  object: refToVar: name: ;;;
  compileOnce

  var: refToVar getVar;
  code: VarCode var.data.get.index;
  file: VarCode var.data.get.file;

  object file regNamesClosure
  code @name @processor @block processCall
  object unregNamesClosure
];

callCallableStructWithPre: [
  nameInfo:;
  refToVar: copy dynamic;
  object: copy dynamic;
  copy findInside:;

  overloadDepth: 0 dynamic;
  findFieldDepth: 0 dynamic;
  overloadIndex: -1 dynamic;

  findInside ~ [
    overloadIndex processor.positions.last.file nameInfo @processor.@nameManager.findItem !overloadIndex
  ] when

  [
    var: refToVar getVar;
    nextIteration: FALSE;

    struct: VarStruct var.data.get.get;

    fr: processor.specialNames.callNameInfo refToVar @processor block findField;
    [fr.success copy] "Struct is not callable!" assert

    codeField: fr.index struct.fields.at .refToVar;

    codeVar: codeField getVar;
    codeVar.data.getTag VarCode = [

      needPre: FALSE;
      pfr: processor.specialNames.preNameInfo refToVar @processor block findField;
      pfr.success [
        preField: pfr.index struct.fields.at .refToVar;
        preVar: preField getVar;
        preVar.data.getTag VarCode = [
          VarCode preVar.data.get.index @processor @block processPre ~ @needPre set
        ] [
          "PRE field must be a code" @processor block compilerError
        ] if
      ] when

      block.state NodeStateNoOutput = ~ [
        needPre [
          findInside [
            findFieldDepth 1 + !findFieldDepth

            fr: nameInfo object findFieldDepth @processor block findFieldWithOverloadDepth;
            fr.success [
              fr.index @object @processor @block processStaticAt @refToVar set
            ] [
              name: nameInfo processor.nameManager.getText;
              ("cant call overload for field with name: " name) assembleString @processor block compilerError
            ] if

          ] [
            oldGnr: nameInfo overloadIndex @processor @block processor.positions.last.file getNameWithOverloadIndex;
            oldGnr.startPoint block.id = ~ [overloadDepth 1 + !overloadDepth] when

            overloadIndex processor.positions.last.file nameInfo processor.nameManager.findItem !overloadIndex
            overloadIndex 0 < [
              name: nameInfo processor.nameManager.getText;
              processor.positions.last.file nameInfo overloadDepth @processor @block addEmptyCapture

              ("cant call overload for name: " name) assembleString @processor block compilerError
            ] when

            processor compilable [
              gnr: nameInfo overloadIndex @processor @block processor.positions.last.file getNameWithOverloadIndex;
              processor compilable [
                cnr: @gnr overloadDepth @processor @block processor.positions.last.file captureName;
                cnr.refToVar @refToVar set
              ] when
            ] when
          ] if

          processor compilable [
            findInside object refToVar nameInfo [
              TRUE @nextIteration set # for builtin or import or pure code go out of loop
            ] callCallable
          ] when
        ] [
          # no need pre, just call it!
          file: VarCode codeVar.data.get.file;

          object file regNamesSelf
          refToVar file regNamesClosure
          VarCode codeVar.data.get.index nameInfo processor.nameManager.getText @processor @block processCall
          refToVar unregNamesClosure
          object unregNamesSelf
        ] if
      ] when
    ] [
      "CALL field is not a code" @processor block compilerError
    ] if

    nextIteration [processor compilable] &&
  ] loop
];

callCallable: [
  predicate:;
  nameInfo:;
  refToVar:;
  object:;
  field:;

  var: refToVar getVar;
  var.data.getTag VarBuiltin = [
    VarBuiltin var.data.get @processor @block callBuiltin
  ] [
    var.data.getTag VarCode = [
      file: VarCode var.data.get.file;
      object file regNamesSelf
      VarCode var.data.get.index @nameInfo processor.nameManager.getText @processor @block processCall
      object unregNamesSelf
    ] [
      var.data.getTag VarImport = [
        refToVar @processor @block processFuncPtr
      ] [
        var.data.getTag VarStruct = [
          @predicate call
        ] [
          "not callable" @processor @block compilerError
        ] if
      ] if
    ] if
  ] if
];

getPossiblePointee: [
  refToVar: processor: block: ;;;
  refToVar getVar.data.getTag VarRef = [
    @refToVar @processor @block getPointee
  ] [
    refToVar copy
  ] if
];

derefAndPush: [
  processor: block: ;;
  @processor @block getPossiblePointee @block push
];

setBlockEmptyLambdas: [
  block:;
  TRUE @block.!hasEmptyLambdas
];

checkVarForGlobalsFromAnotherFile: [
  refToVar:;
  processor.options.partial [
    refToVar isVirtual ~ [
      topNode: block.topNode;
      [topNode isNil ~] "Topnode is nil!" assert
      [topNode.file isNil ~] "Topnode in nil file!" assert
      topNode.file.usedInParams ~ [
        var: refToVar getVar;
        varBlock: var.host;
        varBlock.file isNil ~ [
          varBlock.file.usedInParams ~ [
            TRUE @block.!empty
            @block setBlockEmptyLambdas
          ] when
        ] when
      ] when
    ] when
  ] when
];

{
  block: Block Ref;
  processor: Processor Ref;

  dynamicStoraged: Cond;

  reason: Int32;
  refToVar: RefToVar Cref;
  result: RefToVar Ref;
} () {} [
  block:;
  processor:;
  dynamicStoraged:;
  reason:;
  refToVar:;
  result:;

  overload failProc: processor block FailProcForProcessor;

  refToVar noMatterToCopy [
    refToVar @result set
  ] [
    var: refToVar getVar;
    head: var.capturedHead copy;
    headVar: @head getVar;

    reallyCreateShadows: [
      shadowSrc: headVar.capturedTail copy;
      refToVar.mutable @shadowSrc.setMutable

      shadowSrc @processor @block copyOneVar @result set

      resultVar: @result getVar;
      global: refToVar isGlobal;

      var.storageStaticity @resultVar.@storageStaticity set

      global [
        TRUE @resultVar.@global set

        reason ShadowReasonField = ~ [
          var.irNameId @resultVar.@irNameId set
          result checkVarForGlobalsFromAnotherFile
        ] when
      ] [
        @result @processor block unglobalize
      ] if

      result   @resultVar.@sourceOfValue set

      var.globalId @resultVar.@globalId set
      var.globalDeclarationInstructionIndex @resultVar.@globalDeclarationInstructionIndex set

      # add info  to linked list, link to end (changed value)
      headVar.capturedTail @resultVar.@capturedPrev set # newTail->oldTail
      result               @headVar.@capturedTail set # head->newTail
      head                 @resultVar.@capturedHead set # newTail->head
      result @block.@capturedVars.pushBack       # remember
    ];

    dynamicStoraged [
      reallyCreateShadows
    ] [
      headVar.capturedTail getVar.host block is [
        headVar.capturedTail @result set
        refToVar.mutable @result.setMutable
        refToVar.moved   @result.setMoved
        [result getVar.host block is] "Begin hostId incorrect in makeShadows!" assert
      ] [
        reallyCreateShadows
      ] if
    ] if
  ] if
] "makeShadowsWith" exportFunction

{
  block: Block Ref;
  processor: Processor Ref;

  flags: Nat8;

  refToVar: RefToVar Cref;
  result: RefToVar Ref;
} () {} [
  src: flags: processor: block: ;;;;
  result:;
  overload failProc: processor block FailProcForProcessor;

  fromChild: flags CopyVarFlags.FROM_CHILD and 0n8 = ~;
  toNew:     flags CopyVarFlags.TO_NEW     and 0n8 = ~;
  fromType:  flags CopyVarFlags.FROM_TYPE  and 0n8 = ~;

  srcVar: src getVar;

  checkedStaticityOfVar: [
    toNew [staticityOfVar Dynamic maxStaticity] [staticityOfVar] if
  ];

  srcVar.data.getTag VarStruct = [
    srcStruct: VarStruct srcVar.data.get.get;
    # manually copy only nececcary fields
    dstStruct: Struct;
    srcStruct.fields          @dstStruct.@fields set
    @dstStruct.@fields [field:; FALSE @field.@usedHere set] each
    @dstStruct move owner VarStruct src isVirtual FALSE dynamic @processor @block createVariableWithVirtual
    src checkedStaticityOfVar @processor block makeStaticity @result set
    dstStructAc: VarStruct @result getVar.@data.get.get;
    srcStruct.homogeneous       @dstStructAc.@homogeneous set
    srcStruct.fullVirtual       @dstStructAc.@fullVirtual set
    srcStruct.hasPreField       @dstStructAc.@hasPreField set
    srcStruct.hasDestructor     @dstStructAc.@hasDestructor set
    srcStruct.realFieldIndexes  @dstStructAc.@realFieldIndexes set
    srcStruct.structAlignment   @dstStructAc.@structAlignment set
    srcStruct.structStorageSize @dstStructAc.@structStorageSize set
  ] [
    src isPlain [
      srcVar.data.getTag VarCond VarReal64 1 + [
        copy tag:;
        tag srcVar.data.get.end makeValuePair tag src isVirtual FALSE dynamic @processor @block createVariableWithVirtual
        src checkedStaticityOfVar @processor block makeStaticity
        @result set
      ] staticCall
    ] [
      srcVar.data.getTag VarInvalid VarEnd [
        copy tag:;

        tag VarStruct = ~ [
          tag srcVar.data.get tag src isVirtual FALSE dynamic @processor @block createVariableWithVirtual
          src checkedStaticityOfVar @processor block makeStaticity
          @result set
        ] when
      ] staticCall
    ] if

    srcVar.data.getTag VarRef = [
      dstVar: @result getVar;
      FALSE VarRef @dstVar.@data.get.@usedHere set
    ] when  #for ttest48
  ] if

  src.mutable @result.setMutable
  toNew fromChild or fromType or ~ [src varIsMoved @result.setMoved] when
  dstVar: @result getVar;

  fromType ~ [
    srcVar.sourceOfValue @dstVar.@sourceOfValue set
    [srcVar.sourceOfValue getVar.host dstVar.sourceOfValue getVar.host is] "Source of value is from another node!" assert
  ] when

  srcVar.mplSchemaId @dstVar.@mplSchemaId set
] "copyOneVarWithImpl" exportFunction

{
  block: Block Ref;
  processor: Processor Ref;

  flags: Nat8;
  refToVar: RefToVar Cref;
  result: RefToVar Ref;
} () {} [
  refToVar: flags: processor: block: ;;;;
  result:;
  overload failProc: processor block FailProcForProcessor;

  fromChild: flags CopyVarFlags.FROM_CHILD and 0n8 = ~;
  toNew:     flags CopyVarFlags.TO_NEW     and 0n8 = ~;
  fromType:  flags CopyVarFlags.FROM_TYPE  and 0n8 = ~;

  refToVar noMatterToCopy [fromChild toNew or refToVar isUnallocable and] || [
    refToVar @result set
  ] [
    RefToVar @result set
    uncopiedSrc: RefToVar Array;
    uncopiedDst: RefToVar AsRef Array;

    refToVar @uncopiedSrc.pushBack
    @result AsRef @uncopiedDst.pushBack

    i: 0 dynamic;
    [
      i uncopiedSrc.size < [
        currentSrc: i uncopiedSrc.at copy;
        currentDst: i @uncopiedDst.at.@data;

        currentSrc noMatterToCopy [
          currentSrc @currentDst set
        ] [
          currentSrc flags @processor @block copyOneVarWith @currentDst set

          currentSrcVar: currentSrc getVar;
          currentDstVar: @currentDst getVar;
          currentSrcVar.data.getTag VarStruct = [
            branchSrc: VarStruct currentSrcVar.data.get.get;
            branchDst: VarStruct @currentDstVar.@data.get.get;
            f: 0 dynamic;
            [
              f branchSrc.fields.size < [
                fromChild fromType or [
                  f branchSrc.fields.at.refToVar @uncopiedSrc.pushBack
                ] [
                  f @currentSrc @processor @block getField @uncopiedSrc.pushBack
                ] if

                f @branchDst.@fields.at.@refToVar AsRef @uncopiedDst.pushBack

                f 1 + @f set TRUE
              ] &&
            ] loop
          ] when
        ] if

        i 1 + @i set TRUE
      ] &&
    ] loop
  ] if
] "copyVarImpl" exportFunction

{
  block: Block Ref;
  processor: Processor Ref;
  refToDst: RefToVar Cref;
  refToSrc: RefToVar Cref;
} () {} [
  refSrc: refDst: processor: block: ;; copy;;
  overload failProc: processor block FailProcForProcessor;

  uncopiedSrc: RefToVar Array;
  uncopiedDst: RefToVar AsRef Array;

  refSrc @uncopiedSrc.pushBack
  @refDst AsRef @uncopiedDst.pushBack

  i: 0 dynamic;
  [
    i uncopiedSrc.size < [
      currentSrc: i uncopiedSrc.at copy;
      currentDst: i @uncopiedDst.at.@data;
      currentSrc noMatterToCopy ~ [@currentSrc @currentDst i 0 = setOneVar] when

      currentSrcVar: currentSrc getVar;
      currentDstVar: currentDst getVar;
      currentSrcVar.data.getTag VarStruct = [
        branchSrc: VarStruct currentSrcVar.data.get.get;
        branchDst: VarStruct currentDstVar.data.get.get;
        f: 0 dynamic;
        [
          f branchSrc.fields.size < [
            fieldSrc: f @currentSrc @processor @block getField;
            fieldDst: f @currentDst @processor @block getField;

            fieldSrc @uncopiedSrc.pushBack
            @fieldDst AsRef @uncopiedDst.pushBack

            f 1 + @f set TRUE
          ] &&
        ] loop
      ] when

      i 1 + @i set TRUE
    ] &&
  ] loop
] "setVar" exportFunction

{
  block: Block Ref;
  processor: Processor Ref;
  forMatching: Cond;
  result: RefToVar Ref;
} () {} [
  block:;
  processor:;
  copy forMatching:;
  result:;

  overload failProc: processor block FailProcForProcessor;

  block.stack.size 0 = [
    entryRef: forMatching [
      0 @processor block getStackEntryUnchecked
    ] [
      0 @processor block getStackEntry
    ] if;

    processor compilable [
      entry: entryRef copy;
      entry staticityOfVar Weak = [
        @entry Dynamic @processor block makeStaticity @entry set
      ] when

      @result entry ShadowReasonInput @processor @block makeShadows

      entry varIsMoved [
        @result untemporize
      ] [
        @result fullUntemporize
      ] if

      [result noMatterToCopy [result getVar.host block is] ||] "Shadow host incorrect!" assert

      result getVar.data.getTag VarRef = [
        # it is for exports only
        # we have immutable reference, becouse it is a rule of signature
        # after deref we must force mutability
        mutableOfPointee: VarRef result getVar.data.get.refToVar.mutable;
        @result @processor @block getPointee @result set
        mutableOfPointee @result.setMutable
      ] when

      newInput: Argument;
      result @newInput.@refToVar set
      ArgRef @newInput.@argCase set

      entry isGlobal [ArgGlobal @newInput.@argCase set] when

      newEvent: ShadowEvent;
      ShadowReasonInput @newEvent.setTag
      branch: ShadowReasonInput @newEvent.get;
      newInput @branch set
      result @branch.@refToVar set
      @block @result setTopologyIndex
      @newEvent @processor @block addShadowEvent

      #add input
      newInput @block.@buildingMatchingInfo.@inputs.pushBack
      block.state NodeStateNew = [
        newInput @block.@matchingInfo.@inputs.pushBack
      ] when

      forMatching ~ [result getVar.data.getTag VarInvalid = ~] && [
        1 @block updateInputCount
      ] when
    ] [
      processor.varForFails @result set
      @processor @block addStackUnderflowInfo
    ] if
  ] [
    block.stack.last @result set
    @block.@stack.popBack

    forMatching ~ [result getVar.data.getTag VarInvalid = ~] && [
      1 @block updateInputCount
    ] when
  ] if
] "popWith" exportFunction

popForMatching: [
  processor: block: ;;
  result: RefToVar;
  @result TRUE @processor @block popWith
  result
];

pushName: [
  copy nameInfo:;
  copy read:;
  refToVar:;
  object:;
  copy isField:;

  read -1 = [
    refToVar @processor @block setRef
  ] [
    varToPush: refToVar isVirtual [
      @refToVar @processor @block makeVirtualVarReal
    ] [
      @refToVar copy
    ] if dynamic;

    read 1 = [
      @varToPush @processor @block derefAndPush
    ] [
      possiblePointee: @varToPush @processor @block getPossiblePointee;
      possiblePointee isCallable [
        isField object possiblePointee nameInfo [field object possiblePointee @nameInfo callCallableStructWithPre] callCallable
      ] [
        FALSE dynamic @possiblePointee.setMutable
        possiblePointee @block push
      ] if
    ] if
  ] if
];

processNameNode: [
  data:;
  gnr: data.nameInfo @processor @block getName;
  cnr: @gnr 0 dynamic @processor @block processor.positions.last.file captureName;
  refToVar: cnr.refToVar copy dynamic;

  processor compilable [
    FALSE dynamic cnr.object refToVar 0 data.nameInfo pushName
  ] when
];

processNameReadNode: [
  data:;
  gnr: data.nameInfo @processor @block getName;
  cnr: @gnr 0 dynamic @processor @block processor.positions.last.file captureName;
  refToVar: cnr.refToVar;

  processor compilable [
    var: refToVar getVar;
    var.data.getTag VarBuiltin = [
      "can't use @name for builtins, use [name] instead" @processor block compilerError
    ] [
      var.data.getTag VarImport = [
        FALSE dynamic RefToVar refToVar 1 data.nameInfo pushName
      ] [
        FALSE dynamic RefToVar refToVar 1 data.nameInfo pushName
      ] if
    ] if
  ] when
];

processNameWriteNode: [
  data:;
  gnr: data.nameInfo @processor @block getName;
  cnr: @gnr 0 dynamic @processor @block processor.positions.last.file captureName;
  refToVar: cnr.refToVar;

  processor compilable [refToVar @processor @block setRef] when
];

processStaticAt: [
  index: refToStruct: processor: block: ;;;;
  fieldRef: index @refToStruct @processor @block getField;

  processor compilable [
    fieldVar: fieldRef getVar;
    fieldRef isVirtual [
      @fieldRef @processor block unglobalize
    ] [
      [refToStruct isVirtual ~] "fields of virtual struct must be virtual!" assert
      @fieldRef @processor block unglobalize
      @fieldRef index refToStruct @processor @block createCheckedStaticGEP
    ] if

    @fieldRef fullUntemporize
    fieldRef copy dynamic
  ] [
    RefToVar
  ] if
];

processMember: [
  processor: block: ;;

  copy read:;
  refToStruct:;
  nameInfo:;

  processor compilable [
    fieldError: [
      (refToStruct @processor block getMplType " has no field " nameInfo processor.nameManager.getText) assembleString @processor block compilerError
    ];

    refToStruct getVar.data.getTag VarStruct = [
      fr: nameInfo refToStruct @processor block findField;
      fr.success [
        index: fr.index copy;
        fieldRef: index @refToStruct @processor @block processStaticAt;
        TRUE dynamic refToStruct fieldRef read nameInfo pushName # let it be marker about field
      ] [
        fieldError
      ] if
    ] [
      "not a combined" @processor block compilerError
    ] if
  ] when
];

processNameMemberNode:      [.nameInfo @processor @block pop  0 dynamic @processor @block processMember];
processNameReadMemberNode:  [.nameInfo @processor @block pop  1 dynamic @processor @block processMember];
processNameWriteMemberNode: [.nameInfo @processor @block pop -1 dynamic @processor @block processMember];

processStringNode: [@processor @block makeVarString @block push];
processInt8Node:   [makeVarInt8   @block push];
processInt16Node:  [makeVarInt16  @block push];
processInt32Node:  [makeVarInt32  @block push];
processInt64Node:  [makeVarInt64  @block push];
processIntXNode:   [makeVarIntX   @block push];
processNat8Node:   [makeVarNat8   @block push];
processNat16Node:  [makeVarNat16  @block push];
processNat32Node:  [makeVarNat32  @block push];
processNat64Node:  [makeVarNat64  @block push];
processNatXNode:   [makeVarNatX   @block push];
processReal32Node: [makeVarReal32 @block push];
processReal64Node: [makeVarReal64 @block push];

{
  block: Block Ref;
  processor: Processor Ref;
} () {} [
  processor: block: ;;

  overload failProc: processor block FailProcForProcessor;

  processor.options.debug [
    instruction: @block.@program.last;
    instruction.codeSize 0 >
    [instruction.codeOffset instruction.codeSize 1 - + block.programTemplate.chars.at 58n8 =  ~] && # label detector, code of ":"
    [processor.positions.last.line 0 < ~] &&
    [
      @block.@programTemplate.makeNZ
      offset: block.programTemplate.chars.getSize;

      offset instruction.codeSize + @block.@programTemplate.@chars.enlarge # Make sure the string can be copied without relocation
      offset @block.@programTemplate.@chars.shrink
      block.programTemplate.getStringView instruction.codeOffset instruction.codeSize view @block.@programTemplate.catStringNZ

      @block.@programTemplate.makeZ

      fileDbgIndex: processor.positions.last.file.debugId;
      fr: fileDbgIndex block.fileLexicalBlocks.find;
      lexicalBlockLocation: -1;
      fr.success [
        fr.value @lexicalBlockLocation set
      ] [
        fileDbgIndex block.funcDbgIndex @processor addLexicalBlockLocation @lexicalBlockLocation set
        fileDbgIndex lexicalBlockLocation @block.@fileLexicalBlocks.insert
      ] if

      locationIndex: processor.positions.last lexicalBlockLocation block.funcDbgIndex @processor addDebugLocation;
      (", !dbg !" locationIndex) @block.@programTemplate.catMany

      offset copy @instruction.!codeOffset
      block.programTemplate.size offset - @instruction.!codeSize
    ] when
  ] when
] "addDebugLocationForLastInstruction" exportFunction

addBlock: [
  processor:;
  Block owner @processor.@blocks.pushBack
  processor.blocks.getSize 1 - @processor.@blocks.last.get.!id
];

{
  block: Block Ref;
  processor: Processor Ref;
} () {} [
  processor: block: ;;

  overload failProc: processor block FailProcForProcessor;

  refToVar: @processor @block pop;
  processor compilable [
    var: refToVar getVar;
    var.data.getTag  (
      [VarCode =] [
        VarCode var.data.get.index "call" makeStringView @processor @block processCall
      ]
      [VarImport =] [
        refToVar @processor @block processFuncPtr
      ]
      [VarString =] [
        (
          [processor compilable]
          [refToVar staticityOfVar Weak < ["name must be a static string" @processor block compilerError] when]
          [
            nameInfo: VarString var.data.get makeStringView @processor findNameInfo;
            getNameResult: nameInfo @processor @block getName;
            captureNameResult: @getNameResult 0 dynamic @processor @block processor.positions.last.file captureName;
            refToName: captureNameResult.refToVar copy;
          ]
          [
            TRUE dynamic captureNameResult.refToVar refToName 0 nameInfo pushName
          ]
        ) sequence
      ]
      [drop refToVar isCallable] [
        TRUE dynamic RefToVar refToVar "call" makeStringView callCallableStruct # call struct with INVALID object
      ]
      [
        "not callable" @processor block compilerError
      ]
    ) cond
  ] when
] "defaultCall" exportFunction

{
  block: Block Ref;
  processor: Processor Ref;
  string: String Ref;
  result: RefToVar Ref;
} () {} [
  result: string: processor: block: ;;;;
  refToVar: RefToVar;

  overload failProc: processor block FailProcForProcessor;

  fr: string @processor.@stringNames.find;
  fr.success [
    fr.value @refToVar set
  ] [
    block: 0 @processor.@blocks.at.get;

    string VarString @processor @block createVariable @refToVar set
    string.getStringView @refToVar @processor createStringIR
    string refToVar @processor.@stringNames.insert

    @refToVar fullUntemporize

    {
      addNameCase: NameCaseLocal;
      refToVar:    refToVar copy;
      nameInfo:    refToVar getVar.mplNameId copy;
      overload:    TRUE;
      file:        0 processor.files.at.get;
    } @processor @block addNameInfo
  ] if

  gnr: refToVar getVar.mplNameId @processor @block getName;
  cnr: @gnr 0 dynamic @processor @block processor.positions.last.file captureName;

  cnr.refToVar @result set
] "makeVarStringImpl" exportFunction

addLambdaEvent: [
  success: processor: block: ;;;

  newEvent: ShadowEvent;
  ShadowReasonTreeSplitterLambda @newEvent.setTag
  branch: ShadowReasonTreeSplitterLambda @newEvent.get;
  success @branch set
  @newEvent @processor @block addShadowEvent
];

{
  block: Block Ref;
  processor: Processor Ref;
  refToDst: RefToVar Ref;
  refToSrc: RefToVar Ref;
  result: TryImplicitLambdaCastResult Ref;
} () {} [
  refToSrc: refToDst: processor: block: ;;;;
  result:;

  overload failProc: processor block FailProcForProcessor;

  varSrc: refToSrc getVar;
  varSrc.data.getTag VarCode = [refToDst isVirtual ~] && [
    dstPointee: @refToDst @processor @block getPossiblePointee;
    dstPointeeVar: dstPointee getVar;

    dstPointeeVar.data.getTag VarImport = [
      declarationIndex: VarImport dstPointeeVar.data.get;
      declarationNode: declarationIndex processor.blocks.at.get;
      csignature: declarationNode.csignature;

      implName: ("lambda." block.id "." block.lastLambdaName) assembleString;
      astArrayIndex: VarCode refToSrc getVar.data.get.index;

      processor.options.partial [
        topNode: block.topNode;
        [topNode.file isNil ~] "Topnode in nil file!" assert
        topNode.file.usedInParams ~
      ] && [
        @block setBlockEmptyLambdas
        FALSE @processor @block addLambdaEvent
      ] [
        TRUE @processor @block addLambdaEvent
      ] if

      implIndex: csignature astArrayIndex implName makeStringView TRUE dynamic @processor @block processExportFunction;
      processor compilable [
        implNode: implIndex processor.blocks.at.get;
        implNode.state NodeStateCompiled = ~ [
          block.state NodeStateHasOutput > [NodeStateHasOutput @block.@state set] when
          dstPointee @result.@refToVar set
          TRUE dynamic @result.@success set
        ] when

        implNode.refToVar.assigned [implNode.refToVar dstPointee variablesAreSame] && [
          implNode.varNameInfo 0 < ~ [
            gnr: implNode.varNameInfo @processor @block getNameEverywhere;
            processor compilable ~ [
              [FALSE] "Name of new lambda is not visible!" assert
            ] [
              cnr: @gnr 0 dynamic @processor @block processor.positions.last.file captureName;
              cnr.refToVar @result.@refToVar set
              TRUE dynamic @result.@success set
            ] if
          ] when
        ] [
          "unable to create lambda, signature mismatch" @processor @block compilerError
        ] if
      ] when

      block.lastLambdaName 1 + @block.@lastLambdaName set
    ] when
  ] when
] "tryImplicitLambdaCastImpl" exportFunction

argAbleToCopy: [
  arg: processor: ;;
  arg @processor isTinyArg
];

argRecommendedToCopy: [
  arg: processor: ;;
  arg @processor argAbleToCopy [arg getVar.capturedByPtr ~] &&
];

{
  block: Block Ref;
  processor: Processor Ref;
  refToVar: RefToVar Cref;
} () {} [
  refToVar: processor: block: ;; copy;
  overload failProc: processor block FailProcForProcessor;

  processor compilable [
    uninited: RefToVar Array;
    refToVar isVirtual ~ [
      refToVar @processor @block makeVarTreeDynamic
      @refToVar Static @processor @block makeStaticity drop
    ] when

    TRUE dynamic @refToVar.setMutable
    refToVar @uninited.pushBack
    i: 0 dynamic;
    [
      i uninited.size < [
        current: i uninited.at copy;
        current getVar.data.getTag VarStruct = [
          struct: VarStruct current getVar.data.get.get;
          f: struct.fields.size;
          [
            f 0 > [
              f 1 - @f set TRUE
              f struct.fields.at.refToVar isAutoStruct [
                f @current @processor @block processStaticAt @uninited.pushBack
              ] when
            ] &&
          ] loop
        ] when
        i 1 + @i set processor compilable
      ] &&
    ] loop

    i: uninited.size;
    [
      i 0 > [
        i 1 - @i set
        current: i @uninited.at copy dynamic;
        current getVar.data.getTag VarStruct = [
          fr: processor.specialNames.dieNameInfo current @processor block findField;
          fr.success [
            fr: processor.specialNames.initNameInfo current @processor block findField;
            fr.success [
              index: fr.index copy;
              fieldRef: index @current @processor @block processStaticAt;
              initName: processor.specialNames.initNameInfo processor.nameManager.getText;
              stackSize: block.stack.size;
              fieldRef getVar.data.getTag VarCode = [
                current fieldRef @initName callCallableField
                processor compilable [block.state NodeStateNoOutput = ~] && [block.stack.size stackSize = ~] && [
                  ("Struct " current @processor block getMplType "'s INIT method dont save stack") assembleString @processor block compilerError
                ] when
              ] [
                ("Struct " current @processor block getMplType "'s INIT method is not a CODE") assembleString @processor block compilerError
              ] if
            ] [
              ("Struct " current @processor block getMplType " is automatic, but has not INIT field") assembleString @processor block compilerError
            ] if
          ] when
        ] when
        processor compilable [block.state NodeStateNoOutput = ~] &&
      ] &&
    ] loop
  ] when
] "callInit" exportFunction

{
  block: Block Ref;
  processor: Processor Ref;
  refToDst: RefToVar Cref;
  refToSrc: RefToVar Cref;
} () {} [
  refToSrc: refToDst: processor: block: ;;;;
  overload failProc: processor block FailProcForProcessor;

  processor compilable [
    # no struct - simple copy
    # no die - enum fields
    # has die, no assign - error
    # has die, has assign - call assign, no enum fields
    unfinishedSrc: RefToVar Array;
    unfinishedDst: RefToVar Array;

    refToSrc @unfinishedSrc.pushBack
    refToDst @unfinishedDst.pushBack
    [
      unfinishedSrc.size 0 > [
        curSrc: @unfinishedSrc.last copy;
        curDst: @unfinishedDst.last copy dynamic;
        [curSrc curDst variablesAreSame] "Assign vars must have same type!" assert
        @unfinishedSrc.popBack
        @unfinishedDst.popBack
        curSrcVar: curSrc getVar;
        curDstVar: curDst getVar;

        curSrcVar.data.getTag VarStruct = [
          fr: processor.specialNames.dieNameInfo curSrc @processor block findField;
          fr.success [
            fr: processor.specialNames.assignNameInfo curSrc @processor block findField;
            fr.success [
              index: fr.index copy;
              fieldRef: index @curSrc @processor @block processStaticAt;
              assignName: processor.specialNames.assignNameInfo processor.nameManager.getText;
              stackSize: block.stack.size;

              fieldRef getVar.data.getTag VarCode = [
                curDst isVirtual [
                  "unable to copy virtual autostruct" @processor block compilerError
                ] [
                  curSrc @block push
                  curDst fieldRef @assignName callCallableField
                  processor compilable [block.state NodeStateNoOutput = ~] && [block.stack.size stackSize = ~] && [
                    ("Struct " curSrc @processor block getMplType "'s ASSIGN method dont save stack") assembleString @processor block compilerError
                  ] when
                ] if
              ] [
                ("Struct " curSrc @processor block getMplType "'s ASSIGN method is not a CODE") assembleString @processor block compilerError
              ] if
            ] [
              ("Struct " curSrc @processor block getMplType " is automatic, but has not ASSIGN field") assembleString @processor block compilerError
            ] if
          ] [
            structSrc: VarStruct curSrcVar.data.get.get;
            structDst: VarStruct curDstVar.data.get.get;
            f: 0 dynamic;
            [
              f structSrc.fields.size < [
                srcField: f @curSrc @processor @block processStaticAt;
                srcField @unfinishedSrc.pushBack
                f @curDst @processor @block processStaticAt @unfinishedDst.pushBack
                f 1 + @f set TRUE
              ] &&
            ] loop
          ] if
        ] [
          curSrc curDst @processor @block createMemset
        ] if
        processor compilable [block.state NodeStateNoOutput = ~] &&
      ] &&
    ] loop
  ] when
] "callAssign" exportFunction

{
  block: Block Ref;
  processor: Processor Ref;
  refToVar: RefToVar Cref;
} () {} [
  refToVar: processor: block: ;; copy;
  overload failProc: processor block FailProcForProcessor;

  processor compilable [
    unkilled: @processor.acquireVarRefArray;
    @refToVar fullUntemporize
    TRUE dynamic @refToVar.setMutable
    refToVar @unkilled.pushBack

    [
      unkilled.size 0 > [
        last: unkilled.last copy dynamic;
        @unkilled.popBack
        last getVar.data.getTag VarStruct = [
          struct: VarStruct last getVar.data.get.get;
          fr: processor.specialNames.dieNameInfo last @processor block findField;
          fr.success [
            index: fr.index copy;
            fieldRef: index @last @processor @block processStaticAt;
            dieName: processor.specialNames.dieNameInfo processor.nameManager.getText;
            stackSize: block.stack.size;

            fieldRef getVar.data.getTag VarCode = [
              last fieldRef @dieName callCallableField
              processor compilable [block.state NodeStateNoOutput = ~] && [block.stack.size stackSize = ~] && [
                ("Struct " last @processor block getMplType "'s DIE method dont save stack") assembleString @processor block compilerError
              ] when
            ] [
              ("Struct " last @processor block getMplType "'s DIE method is not a CODE") assembleString @processor block compilerError
            ] if
          ] when

          f: 0 dynamic;
          [
            f struct.fields.size < [
              f struct.fields.at.refToVar isAutoStruct [
                f @last @processor @block processStaticAt @unkilled.pushBack
              ] when
              f 1 + @f set TRUE
            ] &&
          ] loop
        ] when
        processor compilable [block.state NodeStateNoOutput = ~] &&
      ] &&
    ] loop

    @unkilled @processor.releaseVarRefArray
  ] when
] "callDie" exportFunction

killStruct: [
  processor: block: ;;
  refToVar:;
  [refToVar getVar.data.getTag VarStruct =] "Destructors works only for structs!" assert
  VarStruct refToVar getVar.data.get.get.unableToDie ~ [
    refToVar @processor @block callDie
  ] when
];

{
  block: Block Ref;
  processor: Processor Ref;
  message: String Ref;
} () {} [
  message: processor: block: ;;;

  overload failProc: processor block FailProcForProcessor;

  gnr: processor.specialNames.failProcNameInfo @processor @block getName;
  cnr: @gnr 0 dynamic @processor @block processor.positions.last.file captureName;
  failProcRefToVar: cnr.refToVar copy;
  @message @processor @block makeVarString @block push

  failProcRefToVar getVar.data.getTag VarBuiltin = [
    #no overload
    @processor @block defaultFailProc
  ] [
    @failProcRefToVar @processor @block derefAndPush
    @processor @block defaultCall
  ] if
] "createFailWithMessageImpl" exportFunction

{
  processor: Processor Ref;
  block: Block Ref;
  astNode: AstNode Cref;
} () {} [
  processor:;
  block:;
  astNode:;

  overload failProc: processor block FailProcForProcessor;

  processor.options.verboseIR [
    ("fileName: " processor.positions.last.file.name
      ", line: " processor.positions.last.line ", column: " processor.positions.last.column ", token: " processor.positions.last.token) assembleString @block createComment
  ] when

  programSize: block.program.size;

  (
    AstNodeType.Code            [processCodeNode]
    AstNodeType.Label           [processLabelNode]
    AstNodeType.List            [processListNode]
    AstNodeType.Name            [processNameNode]
    AstNodeType.NameMember      [processNameMemberNode]
    AstNodeType.NameRead        [processNameReadNode]
    AstNodeType.NameReadMember  [processNameReadMemberNode]
    AstNodeType.NameWrite       [processNameWriteNode]
    AstNodeType.NameWriteMember [processNameWriteMemberNode]
    AstNodeType.Numberi16       [processInt16Node          ]
    AstNodeType.Numberi32       [processInt32Node          ]
    AstNodeType.Numberi64       [processInt64Node          ]
    AstNodeType.Numberi8        [processInt8Node           ]
    AstNodeType.Numberix        [processIntXNode           ]
    AstNodeType.Numbern16       [processNat16Node          ]
    AstNodeType.Numbern32       [processNat32Node          ]
    AstNodeType.Numbern64       [processNat64Node          ]
    AstNodeType.Numbern8        [processNat8Node           ]
    AstNodeType.Numbernx        [processNatXNode           ]
    AstNodeType.Object          [processObjectNode]
    AstNodeType.Real32          [processReal32Node]
    AstNodeType.Real64          [processReal64Node]
    AstNodeType.String          [processStringNode]
  ) astNode.data.visit

  block.program.size programSize > [
    @processor @block addDebugLocationForLastInstruction
  ] when
] "processNodeImpl" exportFunction

processNode: [
  astNode: ;
  astNode @block @processor processNodeImpl
];

addNamesFromModule: [
  copy moduleId:;

  moduleNode: moduleId processor.blocks.at.get;
  moduleNode.labelNames [
    current:;

    {
      nameInfo:    current.nameInfo copy;
      addNameCase: NameCaseFromModule;
      refToVar:    current.refToVar copy;
    } @processor @block addNameInfo #it is not own local variable
  ] each
];

finalizeListNode: [
  struct: Struct;
  validOutputCount: block.stack.size;

  processor compilable [
    i: 0 dynamic;

    [
      i block.stack.size < [
        curRef: i @block.@stack.at;
        curRef getVar.data.getTag VarInvalid = [
          i @validOutputCount set
          FALSE
        ] [
          newField: Field;
          processor.specialNames.emptyNameInfo @newField.@nameInfo set

          curRef getVar.temporary [
            curRef @newField.@refToVar set
          ] [
            @curRef TRUE dynamic @processor @block createRef @newField.@refToVar set
            @curRef makeVarPtrCaptured
          ] if

          newField @struct.@fields.pushBack
          i 1 + @i set processor compilable
        ] if
      ] &&
    ] loop
  ] when

  processor compilable [
    refToStruct: @struct move owner VarStruct @processor @block createVariable;
    struct: VarStruct @refToStruct getVar.@data.get.get;

    refToStruct isVirtual ~ [
      @refToStruct @processor @block createAllocIR @refToStruct set
    ] when

    i: 0 dynamic;
    [
      i validOutputCount < [
        curFieldRef: i @struct.@fields.at.@refToVar;

        curFieldRef isVirtual [
          @curFieldRef markAsUnableToDie
        ] [
          @curFieldRef markAsUnableToDie
          staticity: curFieldRef staticityOfVar;
          staticity Weak = [Dynamic @staticity set] when
          staticity Virtual = ~ [@curFieldRef staticity @processor block makeStaticity drop] when
          @curFieldRef i refToStruct @processor @block createGEPInsteadOfAlloc
        ] if

        i 1 + @i set processor compilable
      ] &&
    ] loop

    block.stack.size validOutputCount - @block.@stack.shrink
    refToStruct @block.@stack.pushBack
  ] when
];

finalizeObjectNode: [
  refToStruct: @block.@struct move owner VarStruct @processor @block createVariable;
  structInfo: VarStruct @refToStruct getVar.@data.get.get;

  i: 0 dynamic;
  [
    i structInfo.fields.size < [
      dstFieldRef: i @structInfo.@fields.at.@refToVar;

      dstFieldRef isVirtual ~ [dstFieldRef getVar.data.getTag VarRef =] && [
        pointee: VarRef dstFieldRef getVar.data.get.refToVar;
        @pointee makeVarPtrCaptured
      ] when

      @dstFieldRef markAsUnableToDie
      i 1 + @i set TRUE
    ] &&
  ] loop

  refToStruct isVirtual ~ [
    @refToStruct @processor @block createAllocIR drop
    i: 0 dynamic;
    [
      i structInfo.fields.size < [
        dstFieldRef: i @structInfo.@fields.at.@refToVar;

        [dstFieldRef staticityOfVar Weak = ~] "Field label is weak!" assert
        [dstFieldRef noMatterToCopy [dstFieldRef getVar.host block is] ||] "field host incorrect" assert
        dstFieldRef isVirtual ~ [
          [dstFieldRef getVar.allocationInstructionIndex block.program.size <] "field is not allocated" assert
          @dstFieldRef i refToStruct @processor @block createGEPInsteadOfAlloc
        ] when

        i 1 + @i set TRUE
      ] &&
    ] loop
  ] when

  refToStruct @block.@stack.pushBack
];

unregCodeNodeNames: [
  unregisterNamesIn: [
    [
      nameWithOverload:;
      nameWithOverload.refToVar getVar.data.getTag VarImport = ~ [
        nameWithOverload.nameInfo deleteNameInfo
      ] when
    ] each
  ];

  unregTable: [
    whereNames:;

    [
      nameWithOverloadAndRefToVar:;

      unregInLine: [
        line:;
        [line.last.block block is] "Wrong block id while unreg object name!" assert
        @line.popBack
      ];

      unregInObjectTable: [
        depth: mplSchemaId: where: ;;;

        whereTypes: depth @where.at;
        whereIds: mplSchemaId @whereTypes.at;
        @whereIds unregInLine
      ];

      whereOverloads: nameWithOverloadAndRefToVar.nameInfo @whereNames.@simpleNames.at;
      whereIds: nameWithOverloadAndRefToVar.nameOverloadDepth @whereOverloads.at;
      @whereIds unregInLine
    ] each
  ];

  unregStableNames: [
    whereNames:;
    [
      current: @whereNames.@stableNames.at;
      [current.last block.id =] "Wrong block id while unreg object name!" assert
      @current.popBack
    ] each
  ];

  registerWithoutOverload: [
    addNameCase:;
    [
      nameWithOverload:;

      {
        addNameCase: addNameCase copy;
        refToVar:    nameWithOverload.refToVar copy;
        nameInfo:    nameWithOverload.nameInfo copy;
      } @processor @block addNameInfo
    ] each
  ];

  processor compilable ~ block.parent 0 = ~ or [
    @block.@labelNames      unregisterNamesIn
    @block.@fromModuleNames unregisterNamesIn
  ] when

  @block.@captureNames      @processor.@captureTable unregTable
  @block.@stableNames       @processor.@captureTable unregStableNames

  @block.@capturedVars [
    curVar: getVar;
    curVar.capturedPrev @curVar.@capturedHead getVar.@capturedTail set # head->prev of tail
  ] each

  @block.@capturedVars.release
  @block.@captureNames.release
  @block.@stableNames.release
];

addMatchingNode: [
  block:;
  copy astArrayIndex:;

  astArrayIndex @block.@astArrayIndex set

  astArrayIndex processor.matchingNodes.size < [astArrayIndex processor.matchingNodes.at.valid?] && [
    #it exists
  ] [
    tableValue: MatchingNode;
    processor.positions.last @tableValue.@compilerPositionInfo set
    1 @tableValue.@size set
    0 @tableValue.@tries set
    0 @tableValue.@entries set

    astArrayIndex processor.matchingNodes.size < ~ [astArrayIndex 1 + @processor.@matchingNodes.resize] when
    @tableValue move owner astArrayIndex @processor.@matchingNodes.at set
  ] if

  matchingNode: astArrayIndex @processor.@matchingNodes.at.get;
  matchingNode.treeMemory.getSize 0 = [
    MatchingNodeEntry @matchingNode.@treeMemory.pushBack
  ] when

  matchingNode.count 1 + @matchingNode.@count set

  0 @block.@matchingChindIndex set
  block.id 0 @matchingNode.@treeMemory.at.@nodeIndexes.pushBack
];

createGlobalAliases: [
  processor: block: ;;

  @block.@globalVariableNames [
    pair:;

    nameInfo: pair.key;
    pair.value.getSize [
      index: pair.value.getSize 1 - i -;
      refToVar: i @pair.@value.at;
      refToVar isVirtual ~ [
        var: @refToVar getVar;
        oldIrNameId: var.irNameId copy;
        ("@" block.file.name stripExtension nameWithoutBadSymbols "." nameInfo processor.nameManager.getText "." index) assembleString @processor makeStringId @var.@irNameId set

        [block.file isNil ~] "createGlobalAliases in nil file!" assert
        processor.options.partial [
          [block.file isNil ~] "Nil file in createGlobalAliases!" assert
          block.file.usedInParams ~
        ] && [
          refToVar @processor @block createVarImportIR drop
          processor.options.debug [
            d: nameInfo refToVar @processor block addGlobalVariableDebugInfo;
            globalInstruction: refToVar getVar.globalDeclarationInstructionIndex @processor.@prolog.at;
            ", !dbg !"   @globalInstruction.cat
            d            @globalInstruction.cat
          ] when
        ] [
          var.irNameId oldIrNameId refToVar @processor getMplSchema.irTypeId @processor createGlobalAliasIR
        ] if
      ] when
    ] times
  ] each
];

deleteNode: [
  processor:;
  copy nodeIndex:;
  node: nodeIndex @processor.@blocks.at.get;
  TRUE dynamic @node.@empty   set
  TRUE dynamic @node.@deleted set

  @node.@program.release
  @processor @node TRUE deleteMatchingNode
];

clearRecursionStack: [
  processor.recursiveNodesStack.getSize 0 > [processor.recursiveNodesStack.last block.id =] && [
    @processor.@recursiveNodesStack.popBack
  ] when
];

changeTopologyIndexForAllVars: [
  events: clearBuildingMatchingInfo: ;;

  eachEventVar: [
    eachEventVarAction:;
    @events [
      currentEvent:;

      (
        ShadowReasonInput [
          branch:;
          @branch.@refToVar eachEventVarAction
        ]
        ShadowReasonCapture [
          branch:;
          branch.stable ~ [
            @branch.@refToVar eachEventVarAction
          ] when
        ]
        ShadowReasonPointee [
          branch:;
          @branch.@pointee eachEventVarAction
        ]
        ShadowReasonField [
          branch:;
          @branch.@field eachEventVarAction
        ]
        []
      ) @currentEvent.visit
    ] each
  ];

  [
    refToVar:;
    refToVar noMatterToCopy ~ [
      var: @refToVar getVar;
      var.buildingTopologyIndex @var.@topologyIndex set
    ] when
  ] eachEventVar

  clearBuildingMatchingInfo [
    [
      refToVar:;
      refToVar noMatterToCopy ~ [
        var: @refToVar getVar;
        -1 @var.@buildingTopologyIndex set
      ] when
    ] eachEventVar
  ] when
];

checkRecursionOfCodeNode: [
  clearBuildingMatchingInfo: FALSE dynamic;

  removePrevNodes: [
    #go back from end of   nodes to current node, delete "hasOutput" and "noOutput" nodes
    i: processor.blocks.getSize 1 -;
    processed: FALSE dynamic;
    [
      i 0 < ~ [
        current: i @processor.@blocks.at.get;
        current.deleted ~ [
          current.recursionState NodeRecursionStateFail > [
            [i block.id =] "Another recursive node!" assert
            TRUE @processed set
            NodeRecursionStateOld @current.@recursionState set
          ] [
            [i block.id = ~] "Current node no more recursive!" assert
            [current.state NodeStateCompiled = [current.state NodeStateNoOutput =] || [current.state NodeStateHasOutput =] ||] "Invalid node state in resursion backward deleter!" assert
            current.state NodeStateNoOutput = [current.state NodeStateHasOutput =] || [
              i @processor deleteNode
            ] when
          ] if
        ] when
        i 1 - @i set
        processed ~
      ] &&
    ] loop
    #recursion need more iterations
    @block.@program.clear
    @block.@stack.clear
    TRUE @clearBuildingMatchingInfo set
  ];

  approvePrevNodes: [
    [processor.recursiveNodesStack.getSize 0 >] "recursiveNodesStack is empty!" assert
    [
      processor.recursiveNodesStack.last block.id = [
        ("processor.recursiveNodesStack.last=" processor.recursiveNodesStack.last "; but block.id=" block.id) addLog
        FALSE
      ] ||
    ] "Processor.recursionStack mismatch!" assert
    @processor.@recursiveNodesStack.popBack
    #go back from end of   nodes to current node, mark "hasOutput" nodes as "Compiled"; "noOutput" nodes - logic error, assert
    i: processor.blocks.getSize 1 -;
    processed: FALSE dynamic;
    [
      i 0  < ~ [
        current: i @processor.@blocks.at.get;
        current.deleted ~ [
          current.recursionState NodeRecursionStateFail > [
            [i block.id =] "Another recursive node!" assert
            NodeRecursionStateNo @block.@recursionState set
            TRUE @processed set
          ] [
            [i block.id = ~] "Current node no more recursive!" assert
            [
              current.state NodeStateCompiled = [current.state NodeStateHasOutput =] || [
                ("failed state " current.state " in node " i " while " block.id) addLog
                FALSE
              ] ||
            ] "Invalid node state in resursion backward approver!" assert
            current.state NodeStateHasOutput = [
              NodeStateCompiled @current.@state set
            ] when
          ] if
        ] when
        i 1 - @i set
        processed ~
      ] &&
    ] loop
    #recursion successful
  ];

  block.state NodeStateNew = [
    NodeStateCompiled @block.@state set
  ] [
    block.recursionState NodeRecursionStateFail > ~ [
      NodeRecursionStateNo @block.@recursionState set #node will die anyway
    ] [
      result: block.recursionState NodeRecursionStateOld =;
      [block.state NodeStateNew = ~] "Recursion logic failed!" assert
      block.state NodeStateNoOutput = [
        #it is NOT a recursion
        removePrevNodes
        NodeStateNew @block.@state set
        MatchingInfo @block.@matchingInfo set
        NodeRecursionStateFail @block.@recursionState set
        [processor.recursiveNodesStack.last block.id =] "Processor.recursionStack mismatch!" assert
        @processor.@recursiveNodesStack.popBack
      ] [
        block.state NodeStateHasOutput = [
          comparingMessage: String;

          #compare shadow events
          result [
            block.matchingInfo.shadowEvents.getSize block.buildingMatchingInfo.shadowEvents.getSize = ~ [
              FALSE @result set
            ] when
          ] when

          result [
            approvePrevNodes
          ] [
            removePrevNodes
          ] if
        ] when

        result [NodeStateCompiled] [NodeStateHasOutput] if @block.@state set
      ] if
    ] if
  ] if

  block.buildingMatchingInfo.shadowEvents clearBuildingMatchingInfo changeTopologyIndexForAllVars
  block.buildingMatchingInfo @block.@matchingInfo set

  clearBuildingMatchingInfo [
    MatchingInfo @block.@buildingMatchingInfo set
    0            @block.@lastLambdaName set
  ] when
];

astFileIdToFileRef: [
  processor.files.at.get
];

makeCompilerPosition: [
  positionInfo: processor: ;;
  result: CompilerPositionInfo;

  positionInfo.fileId astFileIdToFileRef @result.@file.set
  positionInfo.line                 copy @result.!line
  positionInfo.column               copy @result.!column
  positionInfo.token      makeStringView @result.!token

  result
];

{
  block: Block Ref;
  processor: Processor Ref;
  forcedSignature: CFunctionSignature Cref;
  functionName: StringView Cref;
} () {} [
  processor: block: ;;
  forcedSignature:;
  functionName:;

  overload failProc: processor block FailProcForProcessor;

  block.nextLabelIsVirtual  ["unused virtual specifier"  @processor block compilerError] when
  block.nextLabelIsOverload ["unused overload specifier" @processor block compilerError] when

  block.nodeCase NodeCaseList   = [finalizeListNode] when
  block.nodeCase NodeCaseObject = [finalizeObjectNode] when

  processor.options.verboseIR ["return" @block createComment] when


  retType: String;
  argumentList: String;
  signature: String;
  hasEffect: FALSE;
  hasRet: FALSE;
  retRef: RefToVar;

  "void" makeStringView @retType.cat

  isRefDeref: [
    refToVar:;
    var: refToVar getVar;

    var.usedInHeader [var.allocationInstructionIndex 0 <] || [
      refToVar isVirtual ~
      [isDeclaration ~] &&
    ] &&
  ];

  checkOutput: [
    refToVar:;
    var: refToVar getVar;

    var.usedInHeader [var.allocationInstructionIndex 0 <] || [
      refToVar isVirtual ~
      [isDeclaration ~] && [
        refForArg: refToVar makeRefBranch FALSE @processor @block createRefVariable;
        refToVar @refForArg @processor @block createRefOperation
        refForArg TRUE
      ] [
        copyForArg: refToVar @processor @block copyVarToNew;
        TRUE dynamic @copyForArg.setMutable
        @refToVar @copyForArg @processor @block createCopyToNew
        copyForArg FALSE
      ] if
    ] [
      refToVar copy FALSE
    ] if
  ];

  addArg: [
    copy asCopy:;
    copy output:;
    copy regNameId:;
    refToVar: copy dynamic;
    var: refToVar getVar;

    refToVar getVar.host block is [
      output [
        [var.usedInHeader ~ [var.allocationInstructionIndex 0 < ~] &&] "Cannot use simple return!" assert

        [
          refToVar getVar.data.getTag VarStruct = ~ [
            struct: VarStruct refToVar getVar.@data.get.get;
            struct.unableToDie ~
          ] ||
        ] "Double returning same struct!" assert

        @refToVar markAsUnableToDie
      ] [
        var.usedInHeader [
          copyForArg: refToVar @processor @block copyOneVar;
          copyForArg @refToVar set
        ] when
      ] if
    ] when

    asCopy [
    ] [
      var: @refToVar getVar;
      regNameId 0 < [var.irNameId @regNameId set] when
      TRUE @var.@usedInHeader set

      aii: refToVar getVar.allocationInstructionIndex copy;
      aii 0 < ~ [
        FALSE aii @block.@program.at.@enabled set
      ] when # otherwise it was popped or captured
    ] if

    asCopy output and ~ [
      refToVar getVar.host block is [
        dii: refToVar getVar.getInstructionIndex copy;
        dii 0 < ~ [ #it was got by
          FALSE dii @block.@program.at.@enabled set
        ] when
      ] when

      argumentList.chars.size 0 > [", " makeStringView @argumentList.cat] when
      refToVar @processor getIrType @argumentList.cat
      asCopy ~ ["*"                 @argumentList.cat] when

      signature.chars.size 0 > [", " makeStringView @signature.cat] when
      refToVar @processor getIrType @signature.cat
      asCopy ~ ["*"                 @signature.cat] when

      isDeclaration ~ [
        " "                              @argumentList.cat
        regNameId @processor getNameById @argumentList.cat
      ] when
    ] when

    TRUE @hasEffect set
  ];

  addCopyArg: [FALSE TRUE addArg];
  addRetArg: [-1 dynamic TRUE TRUE addArg];
  addRefArg: [copy output:; -1 dynamic output FALSE addArg];
  addOutputArg: [TRUE dynamic addRefArg];

  addVirtualOutput: [
    copy refToVar:;

    var: @refToVar getVar;
    refToVar isAutoStruct [
      var.usedInHeader [
        copyForArg: refToVar @processor @block copyVarToNew;
        TRUE dynamic @copyForArg.setMutable
        @refToVar @copyForArg @processor @block createCopyToNew
        copyForArg @refToVar set
      ] when

      [
        refToVar getVar.data.getTag VarStruct = ~ [
          struct: VarStruct refToVar getVar.@data.get.get;
          struct.unableToDie ~
        ] ||
      ] "Double returning same struct!" assert

      TRUE @var.@usedInHeader set
      @refToVar markAsUnableToDie
    ] when
  ];

  backPassEvents: [
    block.dependentPointers.getSize [
      current: block.dependentPointers.size 1 - i - @block.@dependentPointers.at;
      dependent: 1 @current @ getVar;

      2 current @ [
        dependent.capturedByPtr [
          0 @current @ @processor @block makeVarRealCaptured
        ] when

        dependent.capturedAsRealValue [
          0 @current @ makeVarDerefCaptured
        ] when

        currentVar: 0 @current @ getVar;
        currentVar.capturedAsRealValue [
          1 @current @ makeVarPtrCaptured
        ] when

        currentVar.capturedForDeref [
          1 @current @ @processor @block makeVarRealCaptured
        ] when
      ] [
        dependent.capturedByPtr [
          0 @current @ makeVarPtrCaptured
        ] when

        dependent.capturedAsRealValue [
          0 @current @ @processor @block makeVarRealCaptured
        ] when

        dependent.capturedForDeref [
          0 @current @ @processor @block makeVarRealCaptured
        ] when
      ] if
    ] times

    block.buildingMatchingInfo.shadowEvents.size [
      event: block.buildingMatchingInfo.shadowEvents.size 1 - i - @block.@buildingMatchingInfo.@shadowEvents.at;

      (
        ShadowReasonInput [
          branch:;
        ]
        ShadowReasonCapture [
          branch:;
        ]
        ShadowReasonField [
          branch:;

          branch.field getVar.capturedByPtr [
            @branch.@object makeVarPtrCaptured
          ] when

          branch.field getVar.capturedAsRealValue [
            @branch.@object @processor @block makeVarRealCaptured
          ] when

          branch.field getVar.capturedForDeref [
            @branch.@object @processor @block makeVarRealCaptured
          ] when
        ]
        ShadowReasonPointee [
          branch:;

          branch.pointee getVar.capturedByPtr [
            @branch.@pointer @processor @block makeVarRealCaptured
          ] when

          branch.pointee getVar.capturedAsRealValue [
            @branch.@pointer makeVarDerefCaptured
          ] when
        ]
        []
      ) event.visit
    ] times
  ];

  callDestructors: [
    block.parent 0 = [
      i: 0 dynamic;
      [
        i block.candidatesToDie.size < [
          current: i @block.@candidatesToDie.at;
          current @processor.@globalDestructibleVars.pushBack
          i 1 + @i set TRUE
        ] &&
      ] loop

      block.candidatesToDie [
        refToVar:;
        refToVar isAutoStruct [
          refToVar @processor createDtorForGlobalVar
        ] when
      ] each
    ] [
      retInstructionIndex: block.program.size 1 -;
      i: block.candidatesToDie.size;
      [
        i 0 > [
          i 1 - @i set
          current: i @block.@candidatesToDie.at;
          current @processor @block killStruct
          processor compilable
        ] &&
      ] loop

      retInstruction: retInstructionIndex @block.@program.at copy;
      @retInstruction move @block.@program.pushBack
      FALSE retInstructionIndex @block.@program.at.@enabled set
    ] if
  ];

  isDeclaration:
    block.nodeCase NodeCaseDeclaration =
    [block.nodeCase NodeCaseCodeRefDeclaration =] ||;

  isRealFunction:
    block.nodeCase NodeCaseExport =
    [block.nodeCase NodeCaseLambda =] ||;

  hasForcedSignature: isDeclaration isRealFunction or;

  block.state NodeStateNoOutput = [@block.@stack.clear] when
  String @block.@header set
  String @block.@signature set

  inputCountMismatch: [
    ("In signature there are " forcedSignature.inputs.getSize " inputs, but really here " validInputCount " inputs") assembleString @processor block compilerError
  ];

  block.buildingMatchingInfo.maxInputCount @block.@buildingMatchingInfo.@inputs.shrink
  validInputCount: block.@buildingMatchingInfo.inputs.size;

  hasForcedSignature [
    forcedSignature @block.@csignature set
    validInputCount forcedSignature.inputs.getSize = ~ [
      inputCountMismatch
    ] when
  ] when

  addRefOrCopyArg: [
    needToCopy: refToVar: argCase: ;;;

    needToCopy [
      regNameId: @processor @block generateRegisterIRName;
      ArgCopy @argCase set
      refToVar regNameId addCopyArg

      refToVar isGlobal ~ [
        refToVar getVar.allocationInstructionIndex 0 <] && [
        regNameId @refToVar @processor @block createAllocIR @processor @block createStoreFromRegister
        TRUE @block.@program.last.@alloca set #fake for good sorting
      ] when
    ] [
      ArgRef @argCase set
      refToVar FALSE addRefArg
    ] if
  ];

  addMetaArg: [
    refToVar:;

    refToVar isGlobal [refToVar isVirtual] || ~ [
      dii: refToVar getVar.getInstructionIndex copy;
      dii 0 < ~ [
        FALSE dii @block.@program.at.@enabled set
      ] when

      aii: refToVar getVar.allocationInstructionIndex copy; #may be was faked before
      aii 0 < [
        refToVar @processor @block createAllocIR drop #it is fake
        TRUE @block.@program.last.@fakeAlloca set #fake for good sorting
      ] when
    ] when
  ];

  processor compilable [
    block.stack [
      current:;
      @current isRefDeref [
        @current makeVarPtrCaptured
      ] when
    ] each
  ] when

  backPassEvents

  processor compilable [
    i: 0 dynamic;
    [
      i block.buildingMatchingInfo.inputs.size < [
        # const to plain make copy
        current: i @block.@buildingMatchingInfo.@inputs.at;

        current.refToVar staticityOfVar Dirty > ~ [current.refToVar getVar.capturedAsRealValue copy] && [
          current.refToVar makeVarPtrCaptured
        ] when

        hasForcedSignature ~ [current.refToVar getVar.capturedAsRealValue ~] && [current.refToVar getVar.capturedByPtr ~] && [
          ArgMeta @current.@argCase set
        ] when

        current.refToVar getVar.usedInParams [
          processor.options.verboseIR [
            ("already used " current.refToVar @processor getIrName) assembleString @block createComment
          ] when
          ArgAlreadyUsed @current.@argCase set
        ] when

        current.refToVar getVar.data.getTag VarInvalid = [
          ArgMeta @current.@argCase set
        ] [
          current.refToVar isVirtual [
            ArgVirtual @current.@argCase set
          ] [
            current.argCase ArgGlobal = [
              TRUE @hasEffect set
            ] [
              current.argCase ArgMeta = [
                current.refToVar addMetaArg
              ] [
                currentVar: current.refToVar getVar;
                currentIsRef: hasForcedSignature [i forcedSignature.inputs.at getVar.data.getTag VarRef =] &&;

                TRUE @currentVar.!usedInParams

                needToCopy: hasForcedSignature [
                  currentIsRef ~
                ] [
                  current.refToVar @processor argRecommendedToCopy
                ] if;

                needToCopy [current.refToVar @processor argAbleToCopy ~] && [isRealFunction copy] && [
                  "getting huge agrument by copy; mpl's export function can not have this signature" @processor block compilerError
                ] when

                needToCopy @current.@refToVar @current.@argCase addRefOrCopyArg
              ] if
            ] if
          ] if
        ] if

        i 1 + @i set processor compilable
      ] &&
    ] loop
  ] when

  invalidOutputCount: block.matchingInfo.inputs.getSize block.matchingInfo.maxInputCount -;

  block.parent 0 =
  [block.stack.size invalidOutputCount >] && [
    "module can not have inputs or outputs" @processor block compilerError
  ] when

  @block.@outputs.clear
  i: invalidOutputCount copy dynamic;
  [
    i block.stack.size < [
      current: i @block.@stack.at;
      newArg: Argument;

      current isVirtual [
        ArgVirtual @newArg.@argCase set
        current addVirtualOutput
        current @newArg.@refToVar set
      ] [
        @current checkOutput refDeref:; output:;

        passAsRet: isDeclaration [output @processor isTinyArg [hasRet ~] &&] ||;
        passAsRet ~ [isRealFunction copy] && [
          "returning two arguments or non-primitive object; mpl's function can not have this signature" @processor block compilerError
        ] when

        processor compilable [
          passAsRet [
            refDeref [ArgReturnDeref] [ArgReturn] if @newArg.@argCase set
            TRUE @hasRet set
            output addRetArg
            output @retRef set
            output @processor getIrType toString @retType set
          ] [
            output captureEntireStruct

            output addOutputArg
            refDeref [ArgRefDeref] [ArgRef] if @newArg.@argCase set
          ] if
        ] when
        output @newArg.@refToVar set
      ] if

      newArg @block.@outputs.pushBack
      i 1 + @i set processor compilable
    ] &&
  ] loop

  block.program.size @block.@instructionCountBeforeRet set

  hasRet [
    retRef @processor @block createRetValue
  ] [
    ("  ret void") @block appendInstruction
  ] if

  block.parent 0 = ~
  [processor.options.partial ~] ||
  [
    [block.file isNil ~] "Block in nil file!" assert
    block.file.usedInParams copy
  ] || [
    callDestructors
  ] when

  processor.options.verboseIR ["called destructors" @block createComment] when

  i: 0 dynamic;
  [
    i block.buildingMatchingInfo.captures.size < [
      current: i @block.@buildingMatchingInfo.@captures.at;
      currentRefToVar: @current.@refToVar;

      currentRefToVar.assigned [
        currentVar: currentRefToVar getVar;

        currentVar.usedInParams [
          processor.options.verboseIR [
            ("already used " currentRefToVar @processor getIrName) assembleString @block createComment
          ] when
          ArgAlreadyUsed @current.@argCase set
        ] when

        current.refToVar staticityOfVar Dirty > ~ [currentVar.capturedAsRealValue copy] && [
          current.refToVar makeVarPtrCaptured
        ] when

        currentVar.capturedForDeref [
          pointee: VarRef currentVar.data.get.refToVar;
          pointee staticityOfVar Dirty > ~ [
            pointee makeVarPtrCaptured
          ] when
        ] when

        needToDerefCopy:
          currentVar.capturedForDeref
          [currentVar.capturedByPtr ~] &&
          [currentVar.capturedAsRealValue ~] &&
          [currentVar.data.getTag VarRef =] &&
          [VarRef currentVar.data.get.refToVar @processor argAbleToCopy] &&;

        currentVar.capturedAsRealValue ~
        [currentVar.capturedForDeref ~] &&
        [currentVar.capturedByPtr ~] && [
          ArgMeta @current.@argCase set
        ] when

        current.argCase ArgRef = [
          isRealFunction [
            fr: i block.captureErrors.find;
            fr.success [
              fr.value @processor.@positions.last set
            ] when

            ("real function can not have local capture; name=" current.nameInfo processor.nameManager.getText "; type=" currentRefToVar @processor block getMplType) assembleString @processor block compilerError
          ] when

          needToCopy: currentRefToVar @processor argRecommendedToCopy;
          TRUE @currentVar.!usedInParams

          needToDerefCopy [
            pointee: VarRef currentVar.data.get.refToVar;
            regNameId: @processor @block generateRegisterIRName;
            ArgDerefCopy @current.@argCase set
            pointee regNameId addCopyArg
            TRUE @pointee getVar.!usedInParams

            pointee getVar.host block is [
              pointee isGlobal ~ [pointee getVar.allocationInstructionIndex 0 <] && [
                regNameId @pointee @processor @block createAllocIR @processor @block createStoreFromRegister
                TRUE @block.@program.last.@alloca set #fake for good sorting
              ] when

              currentRefToVar isGlobal ~ [currentVar.allocationInstructionIndex 0 <] && [
                pointee getVar.irNameId @currentRefToVar @processor @block createAllocIR @processor @block createStoreFromRegister
                TRUE @block.@program.last.@alloca set #fake for good sorting
              ] when
            ] [
              pointee isGlobal ~  [
                pointeeNameId: @processor @block generateRegisterIRName;
                pointeeNameId pointee @processor getMplSchema.irTypeId @processor @block createAllocIRByReg
                regNameId pointeeNameId pointee @processor getMplSchema.irTypeId @processor @block createStoreFromRegisterToRegister
                TRUE @block.@program.last.@alloca set #fake for good sorting

                currentRefToVar isGlobal ~ [currentVar.allocationInstructionIndex 0 <] && [
                  pointeeNameId @currentRefToVar @processor @block createAllocIR @processor @block createStoreFromRegister
                  TRUE @block.@program.last.@alloca set #fake for good sorting
                ] when
              ] when
            ] if
          ] [
            needToCopy @currentRefToVar @current.@argCase addRefOrCopyArg
          ] if
        ] [
          current.argCase ArgGlobal = [
            TRUE @hasEffect set
          ] [
            current.argCase ArgMeta = [
              currentRefToVar addMetaArg
            ] when
          ] if
        ] if
      ] when
      i 1 + @i set processor compilable
    ] &&
  ] loop

  block.variadic [
    isDeclaration [
      block.buildingMatchingInfo.inputs.getSize 0 = [
        "..." @signature.cat
        "..." @argumentList.cat
      ] [
        ", ..." @signature.cat
        ", ..." @argumentList.cat
      ] if
    ] [
      "export function cannot be variadic" @processor block compilerError
    ] if
  ] when

  @block @processor sortInstructions

  addNames: [
    s:;
    names:;
    i: 0 dynamic;
    [
      i names.size < [
        nameWithOverload: i names.at;
        nameWithOverload.nameInfo processor.nameManager.getText @s.cat
        nameWithOverload.nameOverloadDepth 0 > [
          ("(" nameWithOverload.nameOverloadDepth ")") @s.catMany
        ] when
        ", " @s.cat
        i 1 + @i set TRUE
      ] &&
    ] loop
  ];

  noname: hasForcedSignature ~;

  block.nodeCase NodeCaseEmpty = [
    noname
    [block.nodeCase NodeCaseLambda = ~] &&
    [block.recursionState NodeRecursionStateNo =] &&
    [block.hasCallImport ~] &&
    [hasRet ~] &&
    [hasEffect ~] &&
    [block.parent 0 = ~] &&
  ] || @block.@empty set

  @processor @block addDebugLocationForLastInstruction

  processor.options.verboseIR [
    "shadow events: " @block createComment
    block.buildingMatchingInfo.shadowEvents.size [
      event: i block.buildingMatchingInfo.shadowEvents.at;

      getFileName: [
        file:; file isNil ["NIL" makeStringView] [file.name makeStringView] if
      ];

      (
        ShadowReasonInput [
          branch:;
          ("shadow event [" i "] input as " branch.refToVar getVar.buildingTopologyIndex " type " branch.refToVar @processor @block getMplType) assembleString @block createComment
        ]
        ShadowReasonCapture [
          branch:;
          branch.stable [
            ("shadow event [" i "] capture " branch.nameInfo processor.nameManager.getText " as stable name") assembleString @block createComment
          ] [
            ("shadow event [" i "] capture " branch.nameInfo processor.nameManager.getText "(" branch.nameOverloadDepth ") in " branch.file getFileName "; staticity=" branch.refToVar getVar.staticity.begin " as " branch.refToVar getVar.buildingTopologyIndex " type " branch.refToVar @processor @block getMplType) assembleString @block createComment
            branch.mplFieldIndex 0 < ~ [("  as field " branch.mplFieldIndex " in object") assembleString @block createComment] when
          ] if
        ]
        ShadowReasonPointee [
          branch:;
          ("shadow event [" i "] pointee " branch.pointer getVar.buildingTopologyIndex " as " branch.pointee getVar.buildingTopologyIndex)  assembleString @block createComment
        ]
        ShadowReasonField [
          branch:;
          ("shadow event [" i "] field " branch.object getVar.buildingTopologyIndex " [" branch.mplFieldIndex "] as " branch.field getVar.buildingTopologyIndex) assembleString @block createComment
        ]
        []
      ) event.visit
    ] times

    ("inputCount: " block.buildingMatchingInfo.maxInputCount) assembleString @block createComment

    info: String;
    "labelNames: " @info.cat
    block.labelNames @info addNames
    info @block createComment

    info: String;
    "fromModuleNames: " @info.cat
    block.fromModuleNames @info addNames
    info @block createComment

    #info: String;
    #"captureNames: " @info.cat
    #block.captureNames @info addNames
    #info @block createComment

    info: String;
    "captureNames: " @info.cat
    block.matchingInfo.captures [
      c:;
      (c.nameInfo processor.nameManager.getText "(" c.nameOverloadDepth "), ") @info.catMany
    ] each

    info @block createComment

    info: String;
    "outputs: " @info.cat
    block.outputs [
      c:;
      (c.refToVar @processor @block getMplType ", ") @info.catMany
    ] each

    info @block createComment
  ] when

  block.parent 0 = [
    [block.nodeCase NodeCaseCode = [block.nodeCase NodeCaseDtor =] ||] "Root node bust be simple code node or dtor node!" assert
    block.nodeCase NodeCaseCode = [
      block.id @processor.@moduleFunctions.pushBack
    ] [
      block.id @processor.@dtorFunctions.pushBack
    ] if
  ] when

  unregCodeNodeNames

  String @block.@irName set
  hasForcedSignature [forcedSignature.convention "" = ~] && [
    (forcedSignature.convention " ") assembleString @block.@convention set
    forcedSignature.convention @block.@mplConvention set
  ] [
    String @block.@convention set
    "" toString @block.@mplConvention set
  ] if

  (retType "(" signature ")") assembleString @block.@signature set

  # fix declarations
  addFunctionVariableInfo: [
    declarationNodeIndex: block.id copy;
    declarationNode: @block;

    # we can call func as imported
    topNode: @block.topNode;
    currentFile: processor.positions.last.file;

    topNode.file currentFile is ~ [ #we calling func description from another file
      currentFile.rootBlock.id @processor.@blocks.at.get !topNode
    ] when

    refToVar: RefToVar;
    fr: @functionName @processor.@namedFunctions.find;
    fr.success [
      prev: fr.value @processor.@blocks.at.get;
      prev.refToVar @refToVar set
      refToVar.assigned [
        declarationNodeIndex @prev.@nextRecLambdaId set
      ] when
    ] [
      functionName toString declarationNodeIndex @processor.@namedFunctions.insert
    ] if

    refToVar.assigned ~ [
      declarationNodeIndex VarImport @processor @topNode createVariable @refToVar set
    ] when

    refToVar @declarationNode.@refToVar set
    FALSE @refToVar getVar.@temporary set

    declarationNode.nodeCase NodeCaseCodeRefDeclaration = [
      Virtual @refToVar getVar.@storageStaticity set
      "null" toString @processor makeStringId @refToVar getVar.@irNameId set
      "null" toString @declarationNode.@irName set
      topNode.parent 0 = [
        ("; declare func: " functionName) assembleString @processor addStrToProlog #fix global import var matching bug
        processor.prolog.size 1 - @refToVar getVar.@globalDeclarationInstructionIndex set
      ] [
        ("; declare func: " functionName) assembleString @topNode createComment #fix global import var matching bug
        topNode.program.size 1 - @refToVar getVar.@allocationInstructionIndex set
      ] if
    ] [
      declarationNode.irName toString @processor makeStringId @refToVar getVar.@irNameId set
      ("; declare func: " functionName) assembleString @processor addStrToProlog #fix global import var matching bug
      processor.prolog.size 1 - @refToVar getVar.@globalDeclarationInstructionIndex set
    ] if

    nameInfo: functionName @processor findNameInfo;
    nameInfo @declarationNode.@varNameInfo set

    #it is not own local variable
    {
      nameInfo:      nameInfo copy;
      addNameCase:   NameCaseLocal;
      refToVar:      refToVar copy;
      reg:           block.nodeCase NodeCaseCodeRefDeclaration = ~  block.nodeCase NodeCaseLambda = ~ and;
      file:          block.nodeCase NodeCaseLambda = [File Cref][topNode.file] if;
    } @processor @topNode addNameInfo
  ];

  #generate function header
  noname [processor.result.findModuleFail copy] || [
    internal: TRUE;

    block.nodeCase NodeCaseDtor = [
      "@"          @block.@irName.cat
      functionName @block.@irName.cat
    ] [
      block.parent 0 = [
        ("@module." block.file.name stripExtension nameWithoutBadSymbols ".ctor") @block.@irName.catMany
        FALSE !internal
      ] [
        "@func."   @block.@irName.cat

        (block.beginPosition.file.name stripExtension nameWithoutBadSymbols "."
          block.beginPosition.line "."
          block.beginPosition.column ".id"
          block.id) @block.@irName.catMany
      ] if

      # create name with only correct symbols
      block.nodeCase NodeCaseLambda = [
        ".lambda" @block.@irName.cat
      ] [
        goodName: functionName nameWithoutBadSymbols;
        goodName.size 0 > [
          ("." goodName) @block.@irName.catMany
        ] when
      ] if
    ] if

    block.nodeCase NodeCaseLambda = [
      addFunctionVariableInfo
    ] when

    internal [
      "define internal " makeStringView @block.@header.cat
    ] [
      "define " makeStringView @block.@header.cat
    ] if
  ] [
    processor compilable [
      # export func!!!
      "@" makeStringView         @block.@irName.cat
      @functionName              @block.@irName.cat

      block.nodeCase NodeCaseDeclaration = [block.nodeCase NodeCaseCodeRefDeclaration =] || [
        "declare " makeStringView   @block.@header.cat
      ] [
        block.nodeCase NodeCaseExport = [
          "define " makeStringView   @block.@header.cat
        ] [
          "define internal " makeStringView @block.@header.cat
        ] if
      ] if

      block.nodeCase NodeCaseCodeRefDeclaration = [block.nodeCase NodeCaseLambda =] || [
        addFunctionVariableInfo
      ] [
        parentBlock: @block.topNode;
        fr: @functionName @processor.@namedFunctions.find;
        fr.success [
          prevNode: fr.value @processor.@blocks.at.get;
          fakeNode: block.id VarImport @processor @parentBlock createVariable;

          prevNode.state NodeStateCompiled = [
            prevNode.refToVar fakeNode variablesAreSame ~ [
              ("node " functionName " was defined with another signature") assembleString @processor block compilerError
            ] [
              block.nodeCase NodeCaseDeclaration = [
                TRUE @block.@emptyDeclaration set
              ] [
                prevNode.nodeCase NodeCaseDeclaration = [
                  TRUE @prevNode.@emptyDeclaration set
                  prevNode.refToVar @block.@refToVar set #for signature comparings only
                  block.id @fr.@value set
                ] [
                  "dublicated func implementation" @processor block compilerError
                ] if
              ] if
            ] if

            fr: @functionName @parentBlock.@namedFunctions.find;
            fr.success ~ [
              functionName toString block.id @parentBlock.@namedFunctions.insert
              refToVar: @prevNode.@refToVar;

              nameInfo: functionName @processor findNameInfo;

              {
                nameInfo:       nameInfo copy;
                addNameCase:    NameCaseLocal;
                refToVar:       refToVar copy;
              } @processor @parentBlock addNameInfo #it is not own local variable
            ] when
          ] when
        ] [
          functionName toString block.id @processor.@namedFunctions.insert
          functionName toString block.id @parentBlock.@namedFunctions.insert
          addFunctionVariableInfo
        ] if
      ] if
    ] when
  ] if

  (block.convention retType " " block.irName "(" argumentList ")") @block.@header.catMany
  signature @block.@argTypes set

  processor.options.debug [block.empty ~] && [isDeclaration ~] && [block.nodeCase NodeCaseEmpty = ~] && [
    fullFunctionName: functionName;

    block.beginPosition fullFunctionName makeStringView block.irName makeStringView block.funcDbgIndex @processor addFuncDebugInfo
    block.funcDbgIndex @processor moveLastDebugString
    " !dbg !"          @block.@header.cat
    block.funcDbgIndex @block.@header.cat
  ] when

  checkRecursionOfCodeNode

  processor compilable ~ [TRUE @block.@empty set] when
] "finalizeCodeNode" exportFunction

addIndexArrayToProcess: [
  astNodeArray: block: ;;

  i: astNodeArray.nodes.size;
  [
    i 0 > [
      i 1 - @i set
      astNode: i astNodeArray.nodes.at;
      block.unprocessedAstNodes.size 1 + @block.@unprocessedAstNodes.enlarge
      unprocessedAstNode: @block.@unprocessedAstNodes.last;
      astNode @unprocessedAstNode.!astNode
      TRUE
    ] &&
  ] loop
];

{
  processor: Processor Ref;
  signature: CFunctionSignature Cref;
  astArrayIndex: Int32;
  nodeCase: NodeCaseCode;
  parentIndex: Int32;
  functionName: StringView Cref;
} Int32 {} [
  processor:;
  forcedSignature:;
  astArrayIndex:;
  copy nodeCase:;
  copy parentIndex:;
  functionName:;
  compileOnce

  @processor addBlock
  codeNode: @processor.@blocks.last.get;
  block: @codeNode;
  overload failProc: processor block FailProcForProcessor;

  processor.options.autoRecursion @codeNode.@nodeIsRecursive set
  nodeCase                        @codeNode.@nodeCase set
  parentIndex                     @codeNode.@parent set
  @processor block getStackDepth  @codeNode.@minStackDepth set
  processor.varCount              @codeNode.@variableCountDelta set
  processor.exportDepth           @codeNode.@exportDepth set
  CompilerPositionInfo            @codeNode.@beginPosition set
  @processor @codeNode getTopNode @codeNode.@topNode.set
  0                               @codeNode.@globalPriority set

  compilerPositionInfo:  astArrayIndex processor.multiParserResult.memory.at.positionInfo @processor makeCompilerPosition;

  compilerPositionInfo.file   @codeNode.@file.set
  compilerPositionInfo        @codeNode.@beginPosition set
  compilerPositionInfo        @processor.@positions.pushBack

  processor.depthOfRecursion 1 + @processor.@depthOfRecursion set
  processor.depthOfRecursion processor.maxDepthOfRecursion > [
    processor.depthOfRecursion @processor.@maxDepthOfRecursion set
  ] when

  processor.depthOfRecursion processor.options.recursionDepthLimit > [
    TRUE dynamic @processor.@result.@passErrorThroughPRE set
    ("Recursion depth limit (" processor.options.recursionDepthLimit ") exceeded. It can be changed using -recursion_depth_limit option.") assembleString @processor block compilerError
  ] when

  processor.depthOfPre processor.options.preRecursionDepthLimit > [
    TRUE dynamic @processor.@result.@passErrorThroughPRE set
    ("PRE recursion depth limit (" processor.options.preRecursionDepthLimit  ") exceeded. It can be changed using -pre_recursion_depth_limit option.") assembleString @processor block compilerError
  ] when

  #add to match table

  block.parent 0 = [
    block.id 0 > [
      0 dynamic addNamesFromModule #builtins
    ] when

    block.id 1 > [
      1 dynamic addNamesFromModule #definitions
    ] when

    @processor.@possibleUnstables [.clear] each
  ] when

  recursionTries: 0 dynamic;
  [
    @block createLabel
    prevBlockMatchingChindIndex: block.matchingChindIndex copy;
    astArrayIndex @block addMatchingNode
    0 @block.@countOfUCall set
    @block.@labelNames.clear
    @block.@fromModuleNames.clear
    @block.@captureNames.clear
    @block.@stableNames.clear
    @block.@unprocessedAstNodes.clear
    @block.@dependentPointers.clear
    @block.@captureErrors.clear
    @block.@fileLexicalBlocks.clear
    FALSE @block.!hasNestedCall

    processor.options.debug [
      @processor addDebugReserve @block.@funcDbgIndex set
    ] when

    astArrayIndex processor.multiParserResult.memory.at @block addIndexArrayToProcess

    [
      block.unprocessedAstNodes.size 0 > [
        tokenRef: block.unprocessedAstNodes.last copy;
        @block.@unprocessedAstNodes.popBack

        astNode: tokenRef.astNode;
        astNode.positionInfo @processor makeCompilerPosition @processor.@positions.last set

        astNode processNode
        processor compilable [block.state NodeStateNoOutput = ~] &&
      ] &&
    ] loop

    processor compilable [
      functionName forcedSignature @processor @block finalizeCodeNode
    ] [
      unregCodeNodeNames
      block.id @processor deleteNode
      clearRecursionStack

      NodeStateFailed @block.@state set
      TRUE @block.@uncompilable set
    ] if

    prevBlockMatchingChindIndex 0 < ~ [
      @processor @block prevBlockMatchingChindIndex TRUE deleteMatchingNodeFrom
    ] when

    recursionTries 1 + @recursionTries set
    recursionTries 64 > ["recursion processing loop length too big" @processor block compilerError] when

    processor compilable [
      block.recursionState NodeRecursionStateNo > [block.state NodeStateCompiled = ~] &&
    ] &&

    printEventsOfBlock: FALSE;
    printEventsOfBlock [
      ("current try matching events of " block.id " in " astArrayIndex ": " LF) printList
      block.matchingInfo.shadowEvents.size [
        event: i block.matchingInfo.shadowEvents.at;
        event i FALSE @processor @block printShadowEvent
      ] times
    ] when
  ] loop

  processor compilable [block.state NodeStateCompiled =] && [
    block.parent 0 = [
      @processor @block createGlobalAliases
    ] when

    block.hasEmptyLambdas
    [
      block.parent 0 =
      [processor.options.partial copy] &&
      [
        topNode: block.topNode;
        [topNode.file isNil ~] "Topnode in nil file!" assert
        topNode.file.usedInParams ~
      ] &&
    ] ||
    [block.id 1 =] || [
      TRUE @block.@empty set
    ] when

  ] when


  processor.varCount codeNode.variableCountDelta - @codeNode.@variableCountDelta set

  processor.depthOfRecursion 1 - @processor.@depthOfRecursion set
  @processor.@positions.popBack
  block.id copy
] "astNodeToCodeNode" exportFunction
