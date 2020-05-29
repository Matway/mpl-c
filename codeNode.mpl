"Array.Array" use
"HashTable.hash" use
"Owner.owner" use
"String.String" use
"String.StringView" use
"String.addLog" use
"String.assembleString" use
"String.hash" use
"String.makeStringView" use
"String.print" use
"String.splitString" use
"String.toString" use
"control" use
"conventions.cdecl" use

"Block.ArgCopy" use
"Block.ArgGlobal" use
"Block.ArgMeta" use
"Block.ArgRef" use
"Block.ArgRefDeref" use
"Block.ArgReturn" use
"Block.ArgReturnDeref" use
"Block.ArgVirtual" use
"Block.Argument" use
"Block.Block" use
"Block.BlockSchema" use
"Block.CFunctionSignature" use
"Block.Capture" use
"Block.CompilerPositionInfo" use
"Block.FieldCapture" use
"Block.MatchingInfo" use
"Block.MemberCaseToObjectCaptureCase" use
"Block.MemberCaseToObjectCase" use
"Block.NameCaseBuiltin" use
"Block.NameCaseCapture" use
"Block.NameCaseClosureMember" use
"Block.NameCaseClosureObject" use
"Block.NameCaseClosureObjectCapture" use
"Block.NameCaseFromModule" use
"Block.NameCaseInvalid" use
"Block.NameCaseLocal" use
"Block.NameCaseSelfMember" use
"Block.NameCaseSelfObject" use
"Block.NameCaseSelfObjectCapture" use
"Block.NameWithOverload" use
"Block.NameWithOverloadAndRefToVar" use
"Block.NodeCaseCode" use
"Block.NodeCaseCodeRefDeclaration" use
"Block.NodeCaseDeclaration" use
"Block.NodeCaseDtor" use
"Block.NodeCaseEmpty" use
"Block.NodeCaseExport" use
"Block.NodeCaseLambda" use
"Block.NodeCaseList" use
"Block.NodeCaseObject" use
"Block.NodeRecursionStateFail" use
"Block.NodeRecursionStateNo" use
"Block.NodeRecursionStateOld" use
"Block.NodeStateCompiled" use
"Block.NodeStateFailed" use
"Block.NodeStateHasOutput" use
"Block.NodeStateNew" use
"Block.NodeStateNoOutput" use
"Block.ShadowEvent" use
"File.File" use
"Var.CodeNodeInfo" use
"Var.Dirty" use
"Var.Dynamic" use
"Var.Field" use
"Var.RefToVar" use
"Var.Schema" use
"Var.ShadowReasonCapture" use
"Var.ShadowReasonField" use
"Var.ShadowReasonFieldCapture" use
"Var.ShadowReasonInput" use
"Var.ShadowReasonPointee" use
"Var.Static" use
"Var.Struct" use
"Var.VarBuiltin" use
"Var.VarCode" use
"Var.VarCond" use
"Var.VarEnd" use
"Var.VarImport" use
"Var.VarInt16" use
"Var.VarInt32" use
"Var.VarInt64" use
"Var.VarInt8" use
"Var.VarIntX" use
"Var.VarInvalid" use
"Var.VarInvalid" use
"Var.VarNat16" use
"Var.VarNat32" use
"Var.VarNat64" use
"Var.VarNat8" use
"Var.VarNatX" use
"Var.VarReal32" use
"Var.VarReal64" use
"Var.VarRef" use
"Var.VarString" use
"Var.VarStruct" use
"Var.Variable" use
"Var.Virtual" use
"Var.Weak" use
"Var.fullUntemporize" use
"Var.getPlainConstantIR" use
"Var.getVar" use
"Var.isAutoStruct" use
"Var.isNonrecursiveType" use
"Var.isPlain" use
"Var.isSchema" use
"Var.isTinyArg" use
"Var.isUnallocable" use
"Var.isVirtual" use
"Var.isVirtualType" use
"Var.makeRefBranch" use
"Var.makeStringId" use
"Var.makeValuePair" use
"Var.markAsUnableToDie" use
"Var.staticityOfVar" use
"Var.varIsMoved" use
"Var.variablesAreSame" use
"astNodeType.AstNode" use
"astNodeType.AstNodeType" use
"astNodeType.IndexArray" use
"debugWriter.addDebugLocation" use
"debugWriter.addDebugReserve" use
"debugWriter.addFuncDebugInfo" use
"debugWriter.addGlobalVariableDebugInfo" use
"debugWriter.addVariableMetadata" use
"debugWriter.moveLastDebugString" use
"declarations.CopyVarFlags" use
"declarations.TryImplicitLambdaCastResult" use
"declarations.callBuiltin" use
"declarations.compareOnePair" use
"declarations.compilerError" use
"declarations.copyOneVar" use
"declarations.copyOneVarWith" use
"declarations.copyVar" use
"declarations.copyVarFromChild" use
"declarations.copyVarFromType" use
"declarations.copyVarToNew" use
"declarations.createDtorForGlobalVar" use
"declarations.createRefWith" use
"declarations.defaultPrintStack" use
"declarations.defaultPrintStackTrace" use
"declarations.getMplType" use
"declarations.makeShadows" use
"declarations.makeShadowsDynamic" use
"declarations.makeVarString" use
"declarations.makeVariableType" use
"declarations.popWith" use
"declarations.processCall" use
"declarations.processCallByIndexArray" use
"declarations.processExportFunction" use
"declarations.processFuncPtr" use
"declarations.processPre" use
"defaultImpl.FailProcForProcessor" use
"defaultImpl.addEmptyCapture" use
"defaultImpl.addShadowEvent" use
"defaultImpl.addStackUnderflowInfo" use
"defaultImpl.compilable" use
"defaultImpl.createRef" use
"defaultImpl.defaultFailProc" use
"defaultImpl.defaultMakeConstWith" use
"defaultImpl.defaultRef" use
"defaultImpl.defaultSet" use
"defaultImpl.findNameInfo" use
"defaultImpl.getStackDepth" use
"defaultImpl.getStackEntry" use
"defaultImpl.getStackEntryUnchecked" use
"defaultImpl.makeVarRealCaptured" use
"defaultImpl.nodeHasCode" use
"defaultImpl.pop" use
"irWriter.addStrToProlog" use
"irWriter.appendInstruction" use
"irWriter.createAllocIR" use
"irWriter.createComment" use
"irWriter.createCopyToNew" use
"irWriter.createDerefTo" use
"irWriter.createGEPInsteadOfAlloc" use
"irWriter.createJump" use
"irWriter.createLabel" use
"irWriter.createMemset" use
"irWriter.createPlainIR" use
"irWriter.createRefOperation" use
"irWriter.createRetValue" use
"irWriter.createStaticGEP" use
"irWriter.createStoreConstant" use
"irWriter.createStoreFromRegister" use
"irWriter.createStringIR" use
"irWriter.generateRegisterIRName" use
"irWriter.getIrName" use
"irWriter.getIrType" use
"irWriter.getMplSchema" use
"irWriter.getNameById" use
"irWriter.sortInstructions" use
"pathUtils.extractFilename" use
"pathUtils.stripExtension" use
"processor.MatchingNode" use
"processor.NameInfoCoord" use
"processor.NameInfoEntry" use
"processor.Processor" use
"processor.ProcessorResult" use
"processor.RefToVarTable" use
"staticCall.staticCall" use
"variable.NameInfo" use
"variable.Overload" use
"variable.checkValue" use
"variable.findField" use
"variable.findFieldWithOverloadDepth" use
"variable.isGlobal" use
"variable.makeVariableIRName" use
"variable.maxStaticity" use
"variable.noMatterToCopy" use
"variable.unglobalize" use
"variable.untemporize" use

addNameInfo: [
  processor: block: ;;
  params:;

  forOverload:    params "overload"       has [params.overload copy] [FALSE dynamic] if;
  mplFieldIndex:  params "mplFieldIndex"  has [params.mplFieldIndex copy] [-1 dynamic] if;
  reg:            params "reg"            has [params.reg copy] [TRUE dynamic] if;
  startPoint:     params "startPoint"     has [params.startPoint copy] [block.id copy] if;
  overloadDepth:  params "overloadDepth"  has [params.overloadDepth copy] [0 dynamic] if;
  file:           params "file"           has [params.file] [processor.positions.last.file] if;
  addNameCase:    params.addNameCase copy dynamic;
  refToVar:       params.refToVar copy dynamic;
  nameInfo:       params.nameInfo copy dynamic;

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
              nameWithOverload @block.@captureNames.pushBack
              FALSE @addInfo set
            ] [
              addNameCase NameCaseSelfMember = [addNameCase NameCaseClosureMember =] || [
                nameWithOverload @block.@fieldCaptureNames.pushBack
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

        refToVar      @nameInfoEntry.@refToVar set
        addNameCase   @nameInfoEntry.@nameCase set
        startPoint    @nameInfoEntry.@startPoint set
        mplFieldIndex @nameInfoEntry.@mplFieldIndex set

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
  currentNameInfo.stack.dataSize 1 - @result.@overload set
  currentNameInfo.stack.last.dataSize 1 - @result.@index set
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
  FALSE dynamic FALSE dynamic TRUE dynamic @processor @block createVariableWithVirtual
];

createVariableWithVirtual: [
  processor: block: ;;
  copy makeType:;
  copy makeSchema:;
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
    makeSchema [Schema] [Virtual] if @result getVar.@staticity.@begin set
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

{
  block: Block Ref;
  entry: RefToVar Cref;
} () {} [
  entry: block:;;

  entry @block.@stack.pushBack
] "push" exportFunction

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

getStackEntryForPreInput: [
  copy depth:;
  depth @processor block getStackDepth < [
    entry: depth @processor block getStackEntry;
    [entry getVar.host block is ~] "Pre input is just in inputs!" assert
    shadowBegin: RefToVar;
    shadowEnd: RefToVar;
    entry @shadowBegin @shadowEnd ShadowReasonInput @processor @block makeShadows

    newEvent: ShadowEvent;
    ShadowReasonInput @newEvent.setTag
    branch: ShadowReasonInput @newEvent.get;
    shadowBegin @branch.@refToVar set
    ArgMeta     @branch.@argCase set
    @block @shadowBegin setTopologyIndex
    @newEvent @block addShadowEvent

    shadowEnd
  ] [
    RefToVar
  ] if
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
      fromParent [
        pointeeCopy: pointee @processor @block copyOneVar;
        result: RefToVar;
        @result pointeeCopy ShadowReasonPointee @processor @block makeShadowsDynamic
        @result @processor block unglobalize
        dynamize ~ [result @processor @block makeVarTreeDynamicStoraged] when
        result.var     @pointee.setVar
        result.mutable @pointee.setMutable
      ] [
        pointeeCopy: pointee @processor @block copyVarFromType; #this type of copy dont create shadows
        @pointeeCopy @processor block unglobalize
        dynamize ~ [pointeeCopy @processor @block makeVarTreeDynamicStoraged] when
        pointeeCopy.var     @pointee.setVar
        pointeeCopy.mutable @pointee.setMutable
      ] if

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
      var.sourceOfValue getVar.buildingTopologyIndex 0 < ~ [ #source can be local var in child scope, we must handle this case
        shadowUsed: VarRef @sourceValueVar.@data.get.@usedHere;

        refToVar noMatterToCopy ~ [sourceValueVar.capturedHead getVar.host block is ~] && [pointee noMatterToCopy ~] && [shadowUsed ~] && [
          TRUE @shadowUsed set

          newEvent: ShadowEvent;
          ShadowReasonPointee @newEvent.setTag
          branch: ShadowReasonPointee @newEvent.get;
          [var.sourceOfValue getVar.host var.host is] "Source of value is from another node!" assert
          var.sourceOfValue @branch.@pointer set
          pointee           @branch.@pointee set
          @block @branch.@pointee setTopologyIndex

          @newEvent @block addShadowEvent
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
      block.program.dataSize 1 - @pointeeVar.@getInstructionIndex set
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

    fieldRefToVar noMatterToCopy [fieldVar.host block is] || ~ [ # capture or argument
      fieldShadow: RefToVar;
      @fieldShadow fieldRefToVar ShadowReasonField @processor @block makeShadows
      @fieldShadow @processor block unglobalize

      fieldShadow getVar.data.getTag VarStruct = [
        fieldStruct: VarStruct @fieldShadow getVar.@data.get.get;
        refToVar varIsMoved @fieldShadow.setMoved
      ] when

      fieldShadow @fieldRefToVar set

      var.staticity.end fieldRefToVar getVar.staticity.end < [
        var.staticity.end @fieldRefToVar getVar.@staticity.@end set
      ] when
    ] when

    refToVar.mutable @fieldRefToVar.setMutable

    var.buildingTopologyIndex 0 < ~ [refToVar noMatterToCopy ~] && [var.capturedHead getVar.host block is ~] && [fieldRefToVar noMatterToCopy ~] && [mplFieldIndex structInfo.fields.at.usedHere ~] &&  [
      TRUE mplFieldIndex @structInfo.@fields.at.!usedHere

      newEvent: ShadowEvent;
      ShadowReasonField @newEvent.setTag
      branch: ShadowReasonField @newEvent.get;

      refToVar      @branch.@object set
      mplFieldIndex @branch.@mplFieldIndex set
      fieldRefToVar @branch.@field set

      @block @branch.@field setTopologyIndex
      @newEvent @block addShadowEvent
    ] when

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
    i unprocessed.dataSize < [
      current: i unprocessed.at copy;
      currentVar: current getVar;
      currentVar.data.getTag VarStruct = [current noMatterToCopy ~] && [
        branch: VarStruct currentVar.data.get.get;
        f: 0 dynamic;
        [
          f branch.fields.dataSize < [
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
    newRefToVar: pointee makeRefBranch VarRef @processor @block createVariable;
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
    block.program.dataSize 1 - @fieldVar.@getInstructionIndex set
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
        unfinishedSrc.dataSize 0 > [
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
              j struct.fields.dataSize < [
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
        unfinishedSrc.dataSize 0 > [
          lastSrc: unfinishedSrc.last copy;
          lastDst: unfinishedDst.last copy;
          @unfinishedSrc.popBack
          @unfinishedDst.popBack

          varSrc: lastSrc getVar;
          varSrc.data.getTag VarStruct = [
            struct: VarStruct varSrc.data.get.get;
            j: 0 dynamic;
            [
              j struct.fields.dataSize < [
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

    FALSE @result.setMutable
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
    unfinished.dataSize 0 > [
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
            j struct.fields.dataSize < [processor compilable] && [
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
          VarRef curVar.data.get.refToVar isUnallocable [
          ] [
            "can not virtualize reference to local variable" @processor block compilerError
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
    unfinishedVars.dataSize 0 > [
      lastRefToVar: unfinishedVars.last copy;
      @unfinishedVars.popBack

      lastRefToVar staticityOfVar Virtual = ["can't dynamize virtual value" @processor block compilerError] when
      lastRefToVar staticityOfVar Schema = ["can't dynamize schema" @processor block compilerError] when
      lastRefToVar staticityOfVar Dirty = [
        #skip
      ] [
        processor compilable [
          var: lastRefToVar getVar;
          var.data.getTag VarStruct = [
            struct: VarStruct var.data.get.get;
            j: 0 dynamic;
            [
              j struct.fields.dataSize < [
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
                pointee.mutable [pointee @unfinishedVars.pushBack] when
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
    @pointee makeVarRealCaptured
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
    unfinishedVars.dataSize 0 > [
      lastRefToVar: unfinishedVars.last copy;
      @unfinishedVars.popBack

      var: lastRefToVar getVar;
      lastRefToVar staticityOfVar Virtual = ["can't dynamize virtual value" @processor block compilerError] when

      var.data.getTag VarStruct = [
        struct: VarStruct var.data.get.get;
        j: 0 dynamic;
        [
          j struct.fields.dataSize < [
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
        var.staticity.end Dynamic > [
          @lastRefToVar Dynamic @processor block makeEndStaticity drop
        ] when
      ] if

      processor compilable
    ] &&
  ] loop
];

makeVarTreeDynamic:         [processor: block: ;; FALSE dynamic @processor @block makeVarTreeDynamicWith];
makeVarTreeDynamicStoraged: [processor: block: ;; TRUE  dynamic @processor @block makeVarTreeDynamicWith];

createNamedVariable: [
  nameInfo: refToVar: processor: block: ;;;;

  processor compilable [
    newRefToVar: refToVar copy;
    staticity: refToVar staticityOfVar;
    var: @newRefToVar getVar;

    block.nextLabelIsVirtual [
      refToVar isVirtual ~ [
        staticity Dynamic > ~ ["value for virtual label must be static" @processor block compilerError] when
        staticity Weak = [Static @var.@staticity.@end set] when
      ] when
    ] when

    isGlobalLabel: [
      refToVar:;
      block.nextLabelIsVirtual ~ [refToVar isVirtual ~] && [refToVar isGlobal] &&
    ];

    var.temporary [refToVar isGlobalLabel] &&  [
      refToVar @processor @block makeVarTreeDirty
      Dirty @staticity set
    ] when

    var.temporary block.nextLabelIsSchema ~ and [
      staticity @var.@staticity.@end set
      staticity Weak = [Dynamic @var.@staticity.@end set] when
    ] [
      newRefToVar noMatterToCopy block.nextLabelIsVirtual or newRefToVar isUnallocable ~ and [
        refToVar @processor @block copyVarToNew @newRefToVar set
      ] [
        TRUE @var.@capturedAsMutable set #we need ref
        @refToVar TRUE block.nextLabelIsSchema ~ @processor @block createRefWith @newRefToVar set
        newRefToVar isGlobalLabel [newRefToVar @processor @block makeVarTreeDirty] when
      ] if
    ] if

    TRUE dynamic @newRefToVar.setMutable

    @newRefToVar fullUntemporize
    FALSE @newRefToVar getVar.@tref set

    block.nextLabelIsVirtual block.nextLabelIsSchema or [
      @newRefToVar @processor block makeVariableType
      block.nextLabelIsSchema [@newRefToVar makeVarSchema][@newRefToVar makeVarVirtual] if
      FALSE @block.@nextLabelIsVirtual set
      FALSE @block.@nextLabelIsSchema set
    ] when

    {
      addNameCase: NameCaseLocal;
      refToVar:    newRefToVar copy;
      nameInfo:    nameInfo copy;
      overload:    block.nextLabelIsOverload copy;
    } @processor @block addNameInfo

    FALSE @block.!nextLabelIsOverload

    processor compilable [processor.options.debug copy] && [newRefToVar isVirtual ~] && [
      newRefToVar isGlobal [
        d: nameInfo newRefToVar @processor block addGlobalVariableDebugInfo;
        globalInstruction: newRefToVar getVar.globalDeclarationInstructionIndex @processor.@prolog.at;
        ", !dbg !"   @globalInstruction.cat
        d            @globalInstruction.cat
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
  indexOfAstNode: ;
  astNode: indexOfAstNode processor.multiParserResult.memory.at; #we have info from parser anyway
  codeInfo: CodeNodeInfo;

  processor.positions.last.file @codeInfo.@file.set
  astNode.line   copy @codeInfo.!line
  astNode.column copy @codeInfo.!column
  indexOfAstNode copy @codeInfo.!index

  @codeInfo move makeVarCode @block push
];

processObjectNode: [
  data: ;
  position: processor.positions.last copy;
  name: "objectInitializer" makeStringView;
  data NodeCaseObject dynamic name position @processor @block processCallByIndexArray
];

processListNode: [
  data: ;
  position: processor.positions.last copy;
  name: "listInitializer" makeStringView;
  data NodeCaseList dynamic name position @processor @block processCallByIndexArray
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

  processor.result.findModuleFail ~ [processor.depthOfPre 0 =] && [HAS_LOGS] && [
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

findLocalObject: [
  pattern: captureCase: block: resultRefToVar: ;; copy;;

  pattern @resultRefToVar set
  i: 0 dynamic;
  [
    i block.buildingMatchingInfo.captures.dataSize < [
      currentCapture: i block.buildingMatchingInfo.captures.at;
      currentCapture.captureCase captureCase = [
        currentCapture.refToVar pattern variablesAreSame
      ] && [
        currentCapture.refToVar @resultRefToVar set
        FALSE
      ] [
        i 1 + @i set
        TRUE
      ] if
    ] &&
  ] loop
];

findNameStackObject: [
  nameInfo: pattern: file: nameCase: result:; copy;;; copy;

  i: -1 dynamic;
  [
    i file nameInfo processor.nameManager.findItem !i
    i 0 < [
      processor.varForFails @result.@refToVar set 
      FALSE
    ] [
      item: i nameInfo processor.nameManager.getItem;
      nameCase item.nameCase = [pattern item.refToVar variablesAreSame] && [
        item.refToVar   @result.@refToVar set 
        item.nameCase   @result.@nameCase   set
        item.startPoint @result.@startPoint set
        FALSE
      ] [
        TRUE
      ] if
    ] if
  ] loop
];

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
  copy overloadIndex:;
  copy forMatching:;
  matchingCapture:;
  copy nameInfo:;

  unknownName: [
    forMatching [
      processor.varForFails @result.@refToVar set
    ] [
      message: ("unknown name: " nameInfo processor.nameManager.getText) assembleString;
      @message nameInfo @processor catPossibleModulesList

      message @processor block compilerError
    ] if
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

  overloadIndex 0 < [overloadIndex file nameInfo processor.nameManager.findItem !overloadIndex] when
  overloadIndex 0 < [
    unknownName
  ] [
    nameInfoEntry: overloadIndex nameInfo processor.nameManager.getItem;

    overloadIndex            @result.@overloadIndex set
    nameInfoEntry.nameCase   @result.@nameCase   set
    nameInfoEntry.startPoint @result.@startPoint set

    nameCase: matchingCapture.captureCase NameCaseInvalid = [result.nameCase copy] [matchingCapture.captureCase copy] if;

    nameCase NameCaseSelfMember = [nameCase NameCaseClosureMember =] || [
      object: nameInfoEntry.refToVar;
      fields: VarStruct object getVar.data.get.get.fields;
      nameInfoEntry.mplFieldIndex 0 < ~ [nameInfoEntry.mplFieldIndex fields.getSize <] && [nameInfoEntry.mplFieldIndex fields.at.nameInfo nameInfo =] && [
        object nameCase MemberCaseToObjectCase @block @result.@object findLocalObject   #tut nujen object
        nameInfoEntry.mplFieldIndex @result.@mplFieldIndex set
        nameInfoEntry.mplFieldIndex fields.at.refToVar @result.@refToVar set
        object.mutable @result.@refToVar.setMutable
      ] [
        ("Internal error, mismatch structures for name:" nameInfo processor.nameManager.getText) assembleString @processor block compilerError
      ] if
    ] [
      nameCase NameCaseSelfObject = [nameCase NameCaseClosureObject =] || [
        forMatching [
          nameInfo matchingCapture.refToVar file nameCase @result findNameStackObject
        ] [
          nameInfoEntry.refToVar nameCase @block @result.@refToVar findLocalObject
        ] if
      ] [
        nameInfoEntry.refToVar @result.@refToVar set
      ] if
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

getName: [processor: block:;; Capture FALSE dynamic -1 dynamic @processor @block processor.positions.last.file getNameAs];
getNameEverywhere: [processor: block:;; Capture FALSE dynamic -1 dynamic @processor @block File Cref getNameAs];

getNameForMatching: [
  processor: block: file: ;;;
  TRUE dynamic -1 dynamic @processor @block file getNameAs
];

getNameWithOverloadIndex: [
  overloadIndex: processor: block: file: ;;;;
  Capture FALSE dynamic overloadIndex @processor @block file getNameAs
];

getNameForMatchingWithOverloadIndex: [
  overloadIndex: processor: block: file: ;;;;
  TRUE dynamic overloadIndex @processor @block file getNameAs
];

captureName: [
  getNameResult: overloadDepth: processor: block: file: ;;;;;

  result: {
    refToVar: RefToVar;
    object: RefToVar;
  };

  processor compilable [getNameResult.nameCase NameCaseInvalid = ~] && [
    captureError: FALSE dynamic;

    addBlockIdTo: [
      whereNames: nameInfo: nameOverloadDepth: captureCase: mplSchemaId: ;;;;;

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

      nameInfo processor.selfNameInfo = [
        nameOverloadDepth mplSchemaId @whereNames.@selfNames addBlockToObjectCase
      ] [
        nameInfo processor.closureNameInfo =  [
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

    captureRefToVar: [
      copy captureCase:;
      refToVar:;
      copy overloadDepth:;
      copy nameInfo:;

      result: {
        refToVar: refToVar copy;
        newVar: FALSE;
      };

      getNameResult.startPoint block.id = ~ [@processor.@captureTable nameInfo overloadDepth captureCase refToVar getVar.mplSchemaId addBlockIdTo] && [
        TRUE @refToVar getVar.@capturedAsMutable set
        refToVar @result.@refToVar set

        shadow: RefToVar;
        @shadow refToVar ShadowReasonCapture @processor @block makeShadows
        @shadow fullUntemporize

        newCapture: Capture;
        shadow @newCapture.@refToVar set
        nameInfo @newCapture.@nameInfo set
        [getNameResult.overloadIndex 0 < ~] "name overload not initialized!" assert

        overloadDepth @newCapture.@nameOverloadDepth set
        captureCase   @newCapture.@captureCase set
        file          @newCapture.@file.set

        refToVar isVirtual [ArgVirtual] [refToVar isGlobal [ArgGlobal] [ArgRef] if ] if @newCapture.@argCase set
        realCapture: newCapture.argCase ArgRef =;

        realCapture [block.exportDepth refToVar getVar.host.exportDepth = ~] && [
          TRUE !captureError
        ] when

        nameInfo processor.selfNameInfo = [overloadDepth 0 = ~] && [
          [FALSE] "Self cannot have overloads!" assert
        ] when

        newEvent: ShadowEvent;
        ShadowReasonCapture @newEvent.setTag
        branch: ShadowReasonCapture @newEvent.get;
        newCapture @branch set
        shadow @branch.@refToVar set

        newCapture @block.@buildingMatchingInfo.@captures.pushBack
        block.state NodeStateNew = [
          newCapture @block.@matchingInfo.@captures.pushBack
        ] when

        @block @shadow setTopologyIndex
        @newEvent @block addShadowEvent

        processor.options.debug [shadow isVirtual ~] && [shadow isGlobal ~] && [
          fakePointer: shadow makeRefBranch VarRef @processor @block createVariable;
          shadow @fakePointer @processor @block createRefOperation
          nameInfo fakePointer @processor @block addVariableMetadata
          programSize: block.program.getSize;
          TRUE programSize 3 - @block.@program.at.@fakePointer set
          TRUE programSize 2 - @block.@program.at.@fakePointer set
          TRUE programSize 1 - @block.@program.at.@fakePointer set
          @processor @block addDebugLocationForLastInstruction
        ] when

        shadow @result.@refToVar set
        TRUE @result.@newVar set

        [shadow getVar.temporary ~] "Captured var must not be temporary!" assert
      ] when

      result
    ];

    # now we must capture and create GEP instruction
    getNameResult.mplFieldIndex 0 < ~ [
      nameInfo: getNameResult.nameCase NameCaseSelfMember = [
        processor.selfNameInfo copy
      ] [
        getNameResult.nameCase NameCaseClosureMember = [
          processor.closureNameInfo copy
        ] [
          [FALSE] "Invalid getName case for members!" assert
          processor.closureNameInfo copy
        ] if
      ] if;

      cro: nameInfo 0 @getNameResult.@object getNameResult.nameCase MemberCaseToObjectCase captureRefToVar;

      cro.refToVar @result.@object set
      [cro.refToVar noMatterToCopy [cro.refToVar getVar.host block is] ||] "Captured name is not from here!" assert
      getNameResult.mplFieldIndex @cro.@refToVar @processor @block processStaticAt @result.@refToVar set
      cro.newVar [
        {
          nameInfo:      nameInfo copy;
          mplFieldIndex: getNameResult.mplFieldIndex copy;
          startPoint:    getNameResult.startPoint copy;
          overloadDepth: 0;
          addNameCase:   getNameResult.nameCase MemberCaseToObjectCaptureCase;
          refToVar:      cro.refToVar copy;
        } @processor @block addNameInfo
      ] when # add name info for "self"/"closure" as Object; result is object

      getNameResult.startPoint block.id = ~ [@processor.@captureTable getNameResult.nameInfo overloadDepth NameCaseCapture -1 addBlockIdTo] && [
        {
          nameInfo:      getNameResult.nameInfo copy;
          mplFieldIndex: getNameResult.mplFieldIndex copy;
          startPoint:    getNameResult.startPoint copy;
          overloadDepth: overloadDepth copy;
          addNameCase:   getNameResult.nameCase copy;
          refToVar:      result.refToVar copy;
        } @processor @block addNameInfo

        newFieldCapture: FieldCapture;
        [overloadDepth 0 < ~] "name overload not initialized!" assert

        getNameResult.nameInfo      @newFieldCapture.@nameInfo set
        overloadDepth               @newFieldCapture.@nameOverloadDepth set
        result.object               @newFieldCapture.@object set
        getNameResult.nameCase      @newFieldCapture.@captureCase set
        getNameResult.mplFieldIndex @newFieldCapture.@fieldIndex set
        file                        @newFieldCapture.@file.set

        newEvent: ShadowEvent;
        ShadowReasonFieldCapture @newEvent.setTag
        branch: ShadowReasonFieldCapture @newEvent.get;
        newFieldCapture @branch set
        result.object @branch.@object set
        @newEvent @block addShadowEvent
      ] when
    ] [
      cr: getNameResult.nameInfo overloadDepth @getNameResult.@refToVar getNameResult.nameCase captureRefToVar;
      cr.refToVar @result.@refToVar set
      cr.newVar [
        {
          nameInfo:      getNameResult.nameInfo copy;
          startPoint:    getNameResult.startPoint copy;
          overloadDepth: overloadDepth copy;
          addNameCase:   NameCaseCapture;
          refToVar:      result.refToVar copy;
        } @processor @block addNameInfo
      ] when
    ] if

    captureError [
      "real function can not have real local capture" @processor block compilerError
    ] when
  ] [
     newEvent: ShadowEvent;
     ShadowReasonCapture @newEvent.setTag
     branch: ShadowReasonCapture @newEvent.get;
     NameCaseInvalid        @branch.@captureCase set
     ArgMeta                @branch.@argCase set
     getNameResult.nameInfo @branch.@nameInfo set
     overloadDepth          @branch.@nameOverloadDepth set
     file                   @branch.@file.set
     processor.varForFails  @branch.@refToVar set
     @newEvent @block addShadowEvent

     processor.varForFails @result.@refToVar set
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
      processor.callNameInfo refToVar @processor block findField.success copy
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
    i struct.fields.dataSize < [
      currentField: i struct.fields.at;
      [currentField.nameInfo processor.emptyNameInfo = ~] "Closured list!" assert

      {
        nameInfo:      currentField.nameInfo copy;
        mplFieldIndex: i copy;
        addNameCase:   addNameCase copy;
        refToVar:      refToVar copy;
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

  i: struct.fields.dataSize copy dynamic;
  [
    i 0 > [
      i 1 - @i set TRUE
      currentField: i struct.fields.at;
      [currentField.nameInfo processor.emptyNameInfo = ~] "Closured list!" assert
      currentField.nameInfo deleteNameInfo # name info pointing to the struct, not to a field!
    ] &&
  ] loop
];

regNamesClosure: [
  object: file: ;;
  object.assigned [
    {
      nameInfo:      processor.closureNameInfo copy;
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
      nameInfo:      processor.selfNameInfo copy;
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
    processor.closureNameInfo deleteNameInfo
  ] when
];

unregNamesSelf: [
  object:;
  object.assigned [
    object deleteFieldsNameInfos
    processor.selfNameInfo deleteNameInfo
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

  fr: processor.callNameInfo refToVar @processor block findField;
  [fr.success copy] "Struct is not callable!" assert

  codeField: fr.index struct.fields.at .refToVar;
  codeVar: codeField getVar;
  codeVar.data.getTag VarCode = [
    file: VarCode codeVar.data.get.file;

    object file regNamesSelf
    refToVar file regNamesClosure
    VarCode codeVar.data.get.index file name @processor @block processCall
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
  code file @name @processor @block processCall
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

    fr: processor.callNameInfo refToVar @processor block findField;
    [fr.success copy] "Struct is not callable!" assert

    codeField: fr.index struct.fields.at .refToVar;

    codeVar: codeField getVar;
    codeVar.data.getTag VarCode = [

      needPre: FALSE;
      pfr: processor.preNameInfo refToVar @processor block findField;
      pfr.success [
        preField: pfr.index struct.fields.at .refToVar;
        preVar: preField getVar;
        preVar.data.getTag VarCode = [
          VarCode preVar.data.get.index VarCode preVar.data.get.file @processor @block processPre ~ @needPre set
        ] [
          "PRE field must be a code" @processor block compilerError
        ] if
      ] when

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
              cnr.object @object set
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

        findInside [
          object file regNamesSelf
          refToVar file regNamesClosure
          VarCode codeVar.data.get.index file nameInfo processor.nameManager.getText @processor @block processCall
          refToVar unregNamesClosure
          object unregNamesSelf
        ] [
          object file regNamesSelf
          refToVar file regNamesClosure
          VarCode codeVar.data.get.index file nameInfo processor.nameManager.getText @processor @block processCall
          refToVar unregNamesClosure
          object unregNamesSelf
        ] if
      ] if
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

      field [
        object file regNamesSelf
        VarCode var.data.get.index file @nameInfo processor.nameManager.getText @processor @block processCall
        object unregNamesSelf
      ] [
        object file regNamesSelf
        VarCode var.data.get.index file @nameInfo processor.nameManager.getText @processor @block processCall
        object unregNamesSelf
      ] if
    ] [
      var.data.getTag VarImport = [
        refToVar @processor @block processFuncPtr
      ] [
        var.data.getTag VarStruct = [
          @predicate call
        ] [
          [FALSE] "Wrong type to call!" assert
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

setRef: [
  processor: block: ;;
  refToVar:; # destination
  compileOnce

  var: refToVar getVar;
  var.data.getTag VarRef = [
    refToVar isSchema [
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
        reason ShadowReasonField = ~ [
          var.irNameId @resultVar.@irNameId set
        ] when

        TRUE @resultVar.@global set
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
    @dstStruct move owner VarStruct src isVirtual src isSchema FALSE dynamic @processor @block createVariableWithVirtual
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
        tag srcVar.data.get.end makeValuePair tag src isVirtual src isSchema FALSE dynamic @processor @block createVariableWithVirtual
        src checkedStaticityOfVar @processor block makeStaticity
        @result set
      ] staticCall
    ] [
      srcVar.data.getTag VarInvalid VarEnd [
        copy tag:;

        tag VarStruct = ~ [
          tag srcVar.data.get tag src isVirtual src isSchema FALSE dynamic @processor @block createVariableWithVirtual
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
      i uncopiedSrc.dataSize < [
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
              f branchSrc.fields.dataSize < [
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
    i uncopiedSrc.dataSize < [
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
          f branchSrc.fields.dataSize < [
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

  block.stack.dataSize 0 = [
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
      result.mutable [TRUE @result getVar.@capturedAsMutable set] when

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
      @newEvent @block addShadowEvent

      #add input
      result getVar.data.getTag VarInvalid = ~ [
        newInput @block.@buildingMatchingInfo.@inputs.pushBack
        block.state NodeStateNew = [
          newInput @block.@matchingInfo.@inputs.pushBack
        ] when
      ] when
    ] [
      processor.varForFails @result set
      @processor @block addStackUnderflowInfo
    ] if
  ] [
    block.stack.last @result set
    @block.@stack.popBack
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

    refToStruct isSchema [
      read -1 = [
        "can not write to field of struct schema" @processor block compilerError
      ] [
        structVar: refToStruct getVar;
        pointee: VarRef structVar.data.get.refToVar;
        pointeeVar: pointee getVar;
        pointeeVar.data.getTag VarStruct = [
          fr: nameInfo pointee @processor block findField;
          fr.success [
            index: fr.index copy;
            field: index 0 cast VarStruct pointeeVar.data.get.get.fields.at.refToVar;
            result: field makeRefBranch VarRef TRUE dynamic TRUE dynamic TRUE dynamic @processor @block createVariableWithVirtual;
            @result fullUntemporize
            read 1 = result.mutable and @result.setMutable
            result @block push
          ] [
            fieldError
          ] if
        ] [
          "not a combined" @processor block compilerError
        ] if
      ] if
    ] [
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

      locationIndex: processor.positions.last block.funcDbgIndex @processor addDebugLocation;
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
        VarCode var.data.get.index VarCode var.data.get.file "call" makeStringView @processor @block processCall
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
            TRUE dynamic captureNameResult.object refToName 0 nameInfo pushName
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
    } @processor @block addNameInfo
  ] if

  gnr: refToVar getVar.mplNameId @processor @block getName;
  cnr: @gnr 0 dynamic @processor @block processor.positions.last.file captureName;

  cnr.refToVar @result set
] "makeVarStringImpl" exportFunction

{
  block: Block Ref;
  processor: Processor Ref;
  refToDst: RefToVar Cref;
  refToSrc: RefToVar Cref;
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
      astNode: VarCode refToSrc getVar.data.get.index processor.multiParserResult.memory.at;
      implIndex: csignature astNode VarCode refToSrc getVar.data.get.file implName makeStringView TRUE dynamic @processor @block processExportFunction;

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
  arg:;
  arg isTinyArg
];

argRecommendedToCopy: [
  arg:;
  arg.mutable ~ [arg argAbleToCopy] && [arg getVar.capturedAsMutable ~] &&
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
    refToVar isVirtual ~ [refToVar @processor @block makeVarTreeDynamic] when
    TRUE dynamic @refToVar.setMutable
    refToVar @uninited.pushBack
    i: 0 dynamic;
    [
      i uninited.dataSize < [
        current: i uninited.at copy;
        current getVar.data.getTag VarStruct = [
          struct: VarStruct current getVar.data.get.get;
          f: struct.fields.dataSize copy dynamic;
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

    i: uninited.dataSize copy dynamic;
    [
      i 0 > [
        i 1 - @i set
        current: i @uninited.at;
        current getVar.data.getTag VarStruct = [
          fr: processor.dieNameInfo current @processor block findField;
          fr.success [
            fr: processor.initNameInfo current @processor block findField;
            fr.success [
              index: fr.index copy;
              fieldRef: index @current @processor @block processStaticAt;
              initName: processor.initNameInfo processor.nameManager.getText;
              stackSize: block.stack.dataSize copy;
              fieldRef getVar.data.getTag VarCode = [
                current fieldRef @initName callCallableField
                processor compilable [block.state NodeStateNoOutput = ~] && [block.stack.dataSize stackSize = ~] && [
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
      unfinishedSrc.dataSize 0 > [
        curSrc: @unfinishedSrc.last copy;
        curDst: @unfinishedDst.last copy dynamic;
        [curSrc curDst variablesAreSame] "Assign vars must have same type!" assert
        @unfinishedSrc.popBack
        @unfinishedDst.popBack
        curSrcVar: curSrc getVar;
        curDstVar: curDst getVar;

        curSrcVar.data.getTag VarStruct = [
          fr: processor.dieNameInfo curSrc @processor block findField;
          fr.success [
            fr: processor.assignNameInfo curSrc @processor block findField;
            fr.success [
              index: fr.index copy;
              fieldRef: index @curSrc @processor @block processStaticAt;
              assignName: processor.assignNameInfo processor.nameManager.getText;
              stackSize: block.stack.dataSize copy;

              fieldRef getVar.data.getTag VarCode = [
                curDst isVirtual [
                  "unable to copy virtual autostruct" @processor block compilerError
                ] [
                  curSrc @block push
                  curDst fieldRef @assignName callCallableField
                  processor compilable [block.state NodeStateNoOutput = ~] && [block.stack.dataSize stackSize = ~] && [
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
              f structSrc.fields.dataSize < [
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
    unkilled: RefToVar Array;
    @refToVar fullUntemporize
    TRUE dynamic @refToVar.setMutable
    refToVar @unkilled.pushBack

    [
      unkilled.dataSize 0 > [
        last: unkilled.last copy dynamic;
        @unkilled.popBack
        last getVar.data.getTag VarStruct = [
          struct: VarStruct last getVar.data.get.get;
          fr: processor.dieNameInfo last @processor block findField;
          fr.success [
            index: fr.index copy;
            fieldRef: index @last @processor @block processStaticAt;
            dieName: processor.dieNameInfo processor.nameManager.getText;
            stackSize: block.stack.dataSize copy;

            fieldRef getVar.data.getTag VarCode = [
              last fieldRef @dieName callCallableField
              processor compilable [block.state NodeStateNoOutput = ~] && [block.stack.dataSize stackSize = ~] && [
                ("Struct " last @processor block getMplType "'s DIE method dont save stack") assembleString @processor block compilerError
              ] when
            ] [
              ("Struct " last @processor block getMplType "'s DIE method is not a CODE") assembleString @processor block compilerError
            ] if
          ] when

          f: 0 dynamic;
          [
            f struct.fields.dataSize < [
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

  gnr: processor.failProcNameInfo @processor @block getName;
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
  indexOfAstNode: Int32;
  astNode: AstNode Cref;
} () {} [
  processor:;
  block:;
  indexOfAstNode:;
  astNode:;

  overload failProc: processor block FailProcForProcessor;

  processor.options.verboseIR [
    ("filename: " processor.positions.last.file.name
      ", line: " processor.positions.last.line ", column: " processor.positions.last.column ", token: " astNode.token) assembleString @block createComment
  ] when

  programSize: block.program.dataSize copy;

  (
    AstNodeType.Code            [drop indexOfAstNode processCodeNode]
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

  block.program.dataSize programSize > [
    @processor @block addDebugLocationForLastInstruction
  ] when
] "processNodeImpl" exportFunction

processNode: [
  token: tokenIndex: ;;
  token tokenIndex @block @processor processNodeImpl
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
  processor compilable [
    i: 0 dynamic;
    [
      i block.stack.dataSize < [
        curRef: i @block.@stack.at;

        newField: Field;
        processor.emptyNameInfo @newField.@nameInfo set

        curRef getVar.temporary [
          curRef @newField.@refToVar set
        ] [
          @curRef TRUE dynamic @processor @block createRef @newField.@refToVar set
        ] if

        newField @struct.@fields.pushBack
        i 1 + @i set processor compilable
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
      i block.stack.dataSize < [
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

    @block.@stack.clear
    refToStruct @block.@stack.pushBack
  ] when
];

finalizeObjectNode: [
  refToStruct: @block.@struct move owner VarStruct @processor @block createVariable;
  structInfo: VarStruct @refToStruct getVar.@data.get.get;

  i: 0 dynamic;
  [
    i structInfo.fields.dataSize < [
      dstFieldRef: i @structInfo.@fields.at.@refToVar;
      @dstFieldRef markAsUnableToDie
      i 1 + @i set TRUE
    ] &&
  ] loop

  refToStruct isVirtual ~ [
    @refToStruct @processor @block createAllocIR drop
    i: 0 dynamic;
    [
      i structInfo.fields.dataSize < [
        dstFieldRef: i @structInfo.@fields.at.@refToVar;

        [dstFieldRef staticityOfVar Weak = ~] "Field label is weak!" assert
        [dstFieldRef noMatterToCopy [dstFieldRef getVar.host block is] ||] "field host incorrect" assert
        dstFieldRef isVirtual ~ [
          [dstFieldRef getVar.allocationInstructionIndex block.program.dataSize <] "field is not allocated" assert
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

      nameWithOverloadAndRefToVar.nameInfo processor.selfNameInfo = [
        nameWithOverloadAndRefToVar.nameOverloadDepth nameWithOverloadAndRefToVar.refToVar getVar.mplSchemaId @whereNames.@selfNames unregInObjectTable
      ] [
        nameWithOverloadAndRefToVar.nameInfo processor.closureNameInfo = [
          nameWithOverloadAndRefToVar.nameOverloadDepth nameWithOverloadAndRefToVar.refToVar getVar.mplSchemaId @whereNames.@closureNames unregInObjectTable
        ] [
          whereOverloads: nameWithOverloadAndRefToVar.nameInfo @whereNames.@simpleNames.at;
          whereIds: nameWithOverloadAndRefToVar.nameOverloadDepth @whereOverloads.at;
          @whereIds unregInLine
        ] if
      ] if
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
  @block.@fieldCaptureNames @processor.@captureTable unregTable

  @block.@capturedVars [
    curVar: getVar;
    curVar.capturedPrev @curVar.@capturedHead getVar.@capturedTail set # head->prev of tail
  ] each

  @block.@capturedVars.release
];

addMatchingNode: [
  block:;
  copy addr:;

  addr @block.@indexArrayAddress set

  fr: addr @processor.@matchingNodes.find;
  fr.success [
    fr.value.unknownMplType.getSize @block.@matchingInfoIndex set
    fr.value.size 1 + @fr.@value.@size set
    block.id @fr.@value.@unknownMplType.pushBack
  ] [
    tableValue: MatchingNode;
    compilerPositionInfo @tableValue.@compilerPositionInfo set
    1 @tableValue.@size set
    0 @tableValue.@tries set
    0 @tableValue.@entries set
    0 @block.@matchingInfoIndex set
    block.id @tableValue.@unknownMplType.pushBack
    addr @tableValue move @processor.@matchingNodes.insert
  ] if
];

deleteMatchingNode: [
  block:;
  block.matchingInfoIndex 0 < ~ [
    addr: block.indexArrayAddress copy;
    info: addr @processor.@matchingNodes.find.@value;
    indexArray: @info.@unknownMplType;
    info.size 1 - @info.@size set

    [block.matchingInfoIndex indexArray.at block.id =] "Current block: matchingInfo table is incorrect!" assert
    indexArray.getSize 1 - block.matchingInfoIndex = ~ [
      [indexArray.last processor.blocks.at.get.matchingInfoIndex indexArray.getSize 1 - =] "Last node: matchingInfo table is incorrect!" assert

      block.matchingInfoIndex indexArray.last @processor.@blocks.at.get.@matchingInfoIndex set
      indexArray.last block.matchingInfoIndex @indexArray.at set
    ] when

    -1 @block.@matchingInfoIndex set
    @indexArray.popBack
  ] when
];

concreteMatchingNode: [
  block:;

  MatchingInfo @block.@buildingMatchingInfo set

  block.matchingInfo.inputs.getSize 0 = ~ [
    @block deleteMatchingNode

    addr: block.indexArrayAddress copy;
    info: addr @processor.@matchingNodes.find.@value;
    info.size 1 + @info.@size set #return it back

    byMplType: info.@byMplType;

    key: 0 block.matchingInfo.inputs.at.refToVar getVar.mplSchemaId copy;

    fr: key @info.@byMplType.find;
    fr.success [
      block.id @fr.@value.pushBack
    ] [
      newBranch: IndexArray;
      block.id @newBranch.pushBack
      key @newBranch move @info.@byMplType.insert
    ] if
  ] when
];

deleteNode: [
  processor:;
  copy nodeIndex:;
  node: nodeIndex @processor.@blocks.at.get;
  TRUE dynamic @node.@empty   set
  TRUE dynamic @node.@deleted set

  @node.@program.release

  @node deleteMatchingNode
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
          @branch.@refToVar eachEventVarAction
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
          #curToNested: RefToVarTable;
          #nestedToCur: RefToVarTable;
          comparingMessage: String;
          currentMatchingNodeIndex: block.id copy;
          currentMatchingNode: currentMatchingNodeIndex @processor.@blocks.at.get;

          compareShadows: [
            checkConstness:;
            refToVar2:;
            refToVar1:;
            refToVar1 refToVar2 checkConstness @comparingMessage currentMatchingNode @processor compareOnePair
          ];

          compareTopologyIndex: [
            refToVar: buildingRefToVar: ;;
            ti1: refToVar         noMatterToCopy [-1][refToVar getVar.topologyIndex copy] if;
            ti2: buildingRefToVar noMatterToCopy [-1][buildingRefToVar getVar.buildingTopologyIndex copy] if;
            ti1 ti2 =
          ];

          #compare shadow events
          result [
            block.matchingInfo.shadowEvents.getSize block.buildingMatchingInfo.shadowEvents.getSize = ~ [
              FALSE @result set
            ] when

            block.matchingInfo.shadowEvents.size [
              result [
                currentMatchingEvent:         i block.matchingInfo.shadowEvents.at;
                currentBuildingMatchingEvent: i block.buildingMatchingInfo.shadowEvents.at;

                currentMatchingEvent.getTag currentBuildingMatchingEvent.getTag = [
                  currentMatchingEvent.getTag (
                    ShadowReasonInput [
                      branch:         ShadowReasonInput currentMatchingEvent.get;
                      buildingBranch: ShadowReasonInput currentBuildingMatchingEvent.get;

                      branch.refToVar buildingBranch.refToVar compareTopologyIndex
                      [branch.refToVar buildingBranch.refToVar TRUE compareShadows] && ~ [FALSE !result] when
                    ]
                    ShadowReasonCapture [
                      branch:         ShadowReasonCapture currentMatchingEvent.get;
                      buildingBranch: ShadowReasonCapture currentBuildingMatchingEvent.get;

                      branch.refToVar buildingBranch.refToVar compareTopologyIndex
                      [branch.captureCase buildingBranch.captureCase =] &&
                      [branch.nameInfo buildingBranch.nameInfo =] &&
                      [branch.nameOverloadDepth buildingBranch.nameOverloadDepth =] &&
                      [branch.refToVar buildingBranch.refToVar TRUE compareShadows] && ~ [FALSE !result] when
                    ]
                    ShadowReasonFieldCapture [
                      branch:         ShadowReasonFieldCapture currentMatchingEvent.get;
                      buildingBranch: ShadowReasonFieldCapture currentBuildingMatchingEvent.get;

                      branch.captureCase buildingBranch.captureCase =
                      [branch.nameInfo buildingBranch.nameInfo =] &&
                      [branch.object buildingBranch.object compareTopologyIndex] &&
                      [branch.nameOverloadDepth buildingBranch.nameOverloadDepth =] && ~ [FALSE !result] when
                    ]
                    ShadowReasonPointee [
                      branch:         ShadowReasonPointee currentMatchingEvent.get;
                      buildingBranch: ShadowReasonPointee currentBuildingMatchingEvent.get;

                      branch.pointer buildingBranch.pointer compareTopologyIndex
                      [branch.pointee buildingBranch.pointee compareTopologyIndex] &&
                      [branch.pointee buildingBranch.pointee TRUE compareShadows] && ~ [FALSE !result] when
                    ]
                    ShadowReasonField [
                      branch:         ShadowReasonField currentMatchingEvent.get;
                      buildingBranch: ShadowReasonField currentBuildingMatchingEvent.get;

                      branch.object buildingBranch.object compareTopologyIndex
                      [branch.mplFieldIndex buildingBranch.mplFieldIndex =] &&
                      [branch.field buildingBranch.field compareTopologyIndex] &&
                      [branch.field buildingBranch.field FALSE compareShadows] && ~ [FALSE !result] when
                    ]
                    []
                  ) case
                ] [
                  FALSE !result
                ] if
              ] when
            ] times
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

makeCompilerPosition: [
  astNode: file: ;;
  result: CompilerPositionInfo;

  file                @result.@file.set
  astNode.line   copy @result.!line
  astNode.column copy @result.!column
  astNode.token  copy @result.!token

  result
];

{
  block: Block Ref;
  processor: Processor Ref;
  forcedSignature: CFunctionSignature Cref;
  compilerPositionInfo: CompilerPositionInfo Cref;
  functionName: StringView Cref;
} () {} [
  processor: block: ;;
  forcedSignature:;
  compilerPositionInfo:;
  functionName:;

  overload failProc: processor block FailProcForProcessor;

  block.nextLabelIsVirtual  ["unused virtual specifier"  @processor block compilerError] when
  block.nextLabelIsOverload ["unused overload specifier" @processor block compilerError] when
  block.nextLabelIsSchema   ["unused schema specifier"   @processor block compilerError] when

  block.nodeCase NodeCaseList   = [finalizeListNode] when
  block.nodeCase NodeCaseObject = [finalizeObjectNode] when

  processor.options.verboseIR ["return" @block createComment] when


  retType: String;
  argumentList: String;
  signature: String;
  hasEffect: FALSE;
  hasRet: FALSE;
  retRef: RefToVar;
  hasImport: FALSE;

  "void" makeStringView @retType.cat

  checkOutput: [
    refToVar:;
    var: refToVar getVar;

    var.usedInHeader [var.allocationInstructionIndex 0 <] || [
      refToVar isVirtual ~
      [isDeclaration ~] && [
        refForArg: refToVar makeRefBranch VarRef @processor @block createVariable;
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

    var: @refToVar getVar;
    regNameId 0 < [var.irNameId @regNameId set] when


    asCopy ~ [
      TRUE @var.@usedInHeader set

      aii: refToVar getVar.allocationInstructionIndex copy;
      aii 0 < ~ [
        FALSE aii @block.@program.at.@enabled set
      ] when # otherwise it was popped or captured
    ] when

    asCopy output and ~ [
      dii: refToVar getVar.getInstructionIndex copy;
      dii 0 < ~ [ #it was got by
        FALSE dii @block.@program.at.@enabled set
      ] when

      argumentList.chars.dataSize 0 > [", " makeStringView @argumentList.cat] when
      refToVar @processor getIrType @argumentList.cat
      asCopy ~ ["*"                 @argumentList.cat] when

      signature.chars.dataSize 0 > [", " makeStringView @signature.cat] when
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

  callDestructors: [
    block.parent 0 = [
      i: 0 dynamic;
      [
        i block.candidatesToDie.dataSize < [
          current: i @block.@candidatesToDie.at;
          current @processor.@globalDestructibleVars.pushBack
          i 1 + @i set TRUE
        ] &&
      ] loop

      block.candidatesToDie [
        refToVar:;
        refToVar isAutoStruct [
          refToVar compilerPositionInfo CFunctionSignature @processor createDtorForGlobalVar
        ] when
      ] each
    ] [
      retInstructionIndex: block.program.dataSize 1 -;
      i: block.candidatesToDie.dataSize copy dynamic;
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
    ("In signature there are " forcedSignature.inputs.getSize " inputs, but really here " block.buildingMatchingInfo.inputs.getSize " inputs") assembleString @processor block compilerError
  ];

  validInputCount: 0;
  block.buildingMatchingInfo.inputs [
    current:;
    current.refToVar getVar.data.getTag VarInvalid = ~ [
      validInputCount 1 + !validInputCount
    ] when
  ] each

  hasForcedSignature [
    validInputCount forcedSignature.inputs.getSize = ~ [
      validInputCount 1 + forcedSignature.inputs.getSize =
      [forcedSignature.outputs.getSize 0 >] &&
      [0 forcedSignature.outputs.at forcedSignature.inputs.last variablesAreSame] && [
        #todo for MPL signature check each
        @processor @block pop @block push
        validInputCount 1 + !validInputCount
      ] [
        inputCountMismatch
      ] if
    ] when

    forcedSignature @block.@csignature set
  ] when

  processor compilable [
    i: 0 dynamic;
    [
      i block.buildingMatchingInfo.inputs.dataSize < [
        # const to plain make copy
        current: i @block.@buildingMatchingInfo.@inputs.at;

        current.refToVar getVar.data.getTag VarInvalid = [
          ArgMeta @current.@argCase set
        ] [
          current.refToVar isVirtual [
            ArgVirtual @current.@argCase set
          ] [
            current.argCase ArgGlobal = [
              TRUE @hasEffect set
            ] [
              currentVar: current.refToVar getVar;
              needToCopy: hasForcedSignature [
                i forcedSignature.inputs.at getVar.data.getTag VarRef = ~
              ] [
                current.refToVar argRecommendedToCopy
              ] if;

              needToCopy [current.refToVar argAbleToCopy ~] && [isRealFunction copy] && [
                "getting huge agrument by copy; mpl's export function can not have this signature" @processor block compilerError
              ] when

              needToCopy [
                regNameId: @processor @block generateRegisterIRName;
                ArgCopy @current.@argCase set
                current.refToVar regNameId addCopyArg

                current.refToVar getVar.allocationInstructionIndex 0 < [
                  regNameId @current.@refToVar @processor @block createAllocIR @processor @block createStoreFromRegister
                  TRUE @block.@program.last.@alloca set #fake for good sotring
                ] when
              ] [
                ArgRef @current.@argCase set
                current.refToVar FALSE addRefArg
              ] if
            ] if
          ] if
        ] if

        i 1 + @i set processor compilable
      ] &&
    ] loop
  ] when

  block.parent 0 =
  [block.stack.dataSize 0 >] && [
    "module can not have inputs or outputs" @processor block compilerError
  ] when

  @block.@outputs.clear
  i: 0 dynamic;
  [
    i block.stack.dataSize < [
      current: i @block.@stack.at;
      newArg: Argument;

      current isVirtual [
        ArgVirtual @newArg.@argCase set
        current addVirtualOutput
        current @newArg.@refToVar set
      ] [
        @current checkOutput refDeref:; output:;

        passAsRet:
        isDeclaration [output isTinyArg [hasRet ~] &&] ||;

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

  hasRet [
    retRef @processor @block createRetValue
  ] [
    ("  ret void") @block appendInstruction
  ] if

  callDestructors
  processor.options.verboseIR ["called destructors" @block createComment] when

  i: 0 dynamic;
  [
    i block.buildingMatchingInfo.captures.dataSize < [
      current: i block.buildingMatchingInfo.captures.at;
      current.refToVar.assigned [
        current.argCase ArgRef = [
          isRealFunction [
            ("real function can not have local capture; name=" current.nameInfo processor.nameManager.getText "; type=" current.refToVar @processor block getMplType) assembleString @processor block compilerError
          ] when

          current.refToVar FALSE addRefArg
        ] [
          current.argCase ArgGlobal = [
            TRUE @hasEffect set
          ] when
        ] if

        current.refToVar getVar.data.getTag VarImport = [TRUE @hasImport set] when
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

  @block sortInstructions

  addNames: [
    s:;
    names:;
    i: 0 dynamic;
    [
      i names.dataSize < [
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
    [hasImport ~] &&
    [hasRet ~] &&
    [hasEffect ~] &&
    [block.parent 0 = ~] &&
  ] || @block.@empty set

  @processor @block addDebugLocationForLastInstruction

  processor.options.verboseIR [
    "shadow events: " @block createComment
    block.buildingMatchingInfo.shadowEvents.size [
      event: i block.buildingMatchingInfo.shadowEvents.at;

      (
        ShadowReasonInput [
          branch:;
          ("shadow event [" i "] input as " branch.refToVar getVar.buildingTopologyIndex) assembleString @block createComment
        ]
        ShadowReasonCapture [
          branch:;
          ("shadow event [" i "] capture " branch.nameInfo processor.nameManager.getText "(" branch.nameOverloadDepth "); staticity=" branch.refToVar getVar.staticity.begin " as " branch.refToVar getVar.buildingTopologyIndex " type " branch.refToVar @processor @block getMplType) assembleString @block createComment
        ]
        ShadowReasonFieldCapture [
          branch:;
          ("shadow event [" i "] fieldCapture " branch.nameInfo processor.nameManager.getText "(" branch.nameOverloadDepth ") [" branch.fieldIndex "] in " branch.object getVar.buildingTopologyIndex) assembleString @block createComment
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

  getTopNode: [
    topNode: @block;
    [topNode.parent 0 = ~] [
      topNode.parent @processor.@blocks.at.get !topNode
    ] while

    @topNode
  ];

  # fix declarations
  addFunctionVariableInfo: [
    declarationNodeIndex: block.id copy;
    declarationNode: @block;

    # we can call func as imported
    topNode: getTopNode;

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
      "null" toString @processor makeStringId @refToVar getVar.@irNameId set
      "null" toString @declarationNode.@irName set
      topNode.parent 0 = [
        (";declare func: " functionName) assembleString @processor addStrToProlog #fix global import var matching bug
        processor.prolog.dataSize 1 - @refToVar getVar.@globalDeclarationInstructionIndex set
      ] [
        (";declare func: " functionName) assembleString @topNode createComment #fix global import var matching bug
        topNode.program.dataSize 1 - @refToVar getVar.@allocationInstructionIndex set
      ] if
    ] [
      declarationNode.irName toString @processor makeStringId @refToVar getVar.@irNameId set
      (";declare func: " functionName) assembleString @processor addStrToProlog #fix global import var matching bug
      processor.prolog.dataSize 1 - @refToVar getVar.@globalDeclarationInstructionIndex set
    ] if

    nameInfo: functionName @processor findNameInfo;
    nameInfo @declarationNode.@varNameInfo set

    #it is not own local variable
    {
      nameInfo:      nameInfo copy;
      addNameCase:   NameCaseLocal;
      refToVar:      refToVar copy;
    } @processor @topNode addNameInfo
  ];

  #generate function header
  noname [processor.result.findModuleFail copy] || [
    block.nodeCase NodeCaseDtor = [
      "@"          @block.@irName.cat
      functionName @block.@irName.cat
    ] [
      block.parent 0 = [
        "@module." @block.@irName.cat
      ] [
        "@func."   @block.@irName.cat
      ] if

      block.id @block.@irName.cat
      # create name with only correct symbols
      block.nodeCase NodeCaseLambda = [
        ".lambda" @block.@irName.cat
      ] [
        wasDot: FALSE;
        functionName.size 0 > [
          splitted: functionName splitString;
          splitted.success [
            splitted.chars [
              symbol:;
              codePoint: symbol.data Nat8 addressToReference;
              codePoint 48n8 < ~ [codePoint 57n8 > ~] &&         #0..9
              [codePoint 65n8 < ~ [codePoint 90n8 > ~] &&] ||    #A..Z
              [codePoint 97n8 < ~ [codePoint 122n8 > ~] &&] || [ #a..z
                wasDot ~ [
                  "." @block.@irName.cat
                  TRUE @wasDot set
                ] when
                symbol @block.@irName.cat
              ] when
            ] each
          ] [
            ("Wrong function name encoding:" functionName) assembleString @processor block compilerError
          ] if
        ] when
      ] if
    ] if

    block.nodeCase NodeCaseLambda = [addFunctionVariableInfo] when

    "define internal " makeStringView @block.@header.cat
  ] [
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
      parentBlock: getTopNode;
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
                block.id @fr.@value set
              ] [
                "dublicated func implementation" @processor block compilerError
              ] if
            ] if
          ] if

          processor compilable [
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
        ] when
      ] [
        functionName toString block.id @processor.@namedFunctions.insert
        functionName toString block.id @parentBlock.@namedFunctions.insert
        addFunctionVariableInfo
      ] if
    ] if
  ] if

  (block.convention retType " " block.irName "(" argumentList ")") @block.@header.catMany
  signature @block.@argTypes set

  processor.options.debug [block.empty ~] && [isDeclaration ~] && [block.nodeCase NodeCaseEmpty = ~] && [
    compilerPositionInfo functionName makeStringView block.irName makeStringView block.funcDbgIndex @processor addFuncDebugInfo
    block.funcDbgIndex @processor moveLastDebugString
    " !dbg !"          @block.@header.cat
    block.funcDbgIndex @block.@header.cat
  ] when

  checkRecursionOfCodeNode

  processor compilable ~ [TRUE @block.@empty set] when
] "finalizeCodeNode" exportFunction

addIndexArrayToProcess: [
  indexArray: block: file: ;;;

  i: indexArray.dataSize copy dynamic;
  [
    i 0 > [
      i 1 - @i set
      indexOfAstNode: i indexArray.at;
      block.unprocessedAstNodes.size 1 + @block.@unprocessedAstNodes.enlarge
      unprocessedAstNode: @block.@unprocessedAstNodes.last;
      file @unprocessedAstNode.@file.set
      indexOfAstNode copy @unprocessedAstNode.!token
      TRUE
    ] &&
  ] loop
];

{
  processor: Processor Ref;
  signature: CFunctionSignature Cref;
  compilerPositionInfo: CompilerPositionInfo Cref;
  file: File Cref;
  indexArray: IndexArray Cref;
  nodeCase: NodeCaseCode;
  parentIndex: Int32;
  functionName: StringView Cref;
} Int32 {} [
  processor:;
  forcedSignature:;
  compilerPositionInfo:;
  file:;
  indexArray:;
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

  compilerPositionInfo @processor.@positions.pushBack

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
  indexArray storageAddress @block addMatchingNode

  block.parent 0 = [block.id 1 >] && [
    1 dynamic addNamesFromModule
  ] when

  recursionTries: 0 dynamic;
  [
    @block createLabel

    0 @block.@countOfUCall set
    @block.@labelNames.clear
    @block.@fromModuleNames.clear
    @block.@captureNames.clear
    @block.@fieldCaptureNames.clear
    @block.@unprocessedAstNodes.clear

    processor.options.debug [
      @processor addDebugReserve @block.@funcDbgIndex set
    ] when

    indexArray @block file addIndexArrayToProcess

    [
      block.unprocessedAstNodes.dataSize 0 > [
        tokenRef: block.unprocessedAstNodes.last copy;
        @block.@unprocessedAstNodes.popBack

        astNode: tokenRef.token processor.multiParserResult.memory.at;
        astNode tokenRef.file makeCompilerPosition @processor.@positions.last set

        astNode tokenRef.token processNode
        processor compilable [block.state NodeStateNoOutput = ~] &&
      ] &&
    ] loop

    processor compilable [
      functionName compilerPositionInfo forcedSignature @processor @block finalizeCodeNode
    ] [
      unregCodeNodeNames
      block.id @processor deleteNode
      clearRecursionStack

      NodeStateFailed @block.@state set
      TRUE @block.@uncompilable set
    ] if

    recursionTries 1 + @recursionTries set
    recursionTries 64 > ["recursion processing loop length too big" @processor block compilerError] when

    processor compilable [
      block.recursionState NodeRecursionStateNo > [block.state NodeStateCompiled = ~] &&
    ] &&
  ] loop

  processor compilable [block.state NodeStateCompiled =] && [
    @block concreteMatchingNode
  ] when

  processor.varCount codeNode.variableCountDelta - @codeNode.@variableCountDelta set

  processor.depthOfRecursion 1 - @processor.@depthOfRecursion set
  @processor.@positions.popBack

  block.id copy
] "astNodeToCodeNode" exportFunction
