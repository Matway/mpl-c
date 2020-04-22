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

"Block.ArgGlobal" use
"Block.ArgCopy" use
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
"Block.NameCaseBuiltin" use
"Block.NameCaseCapture" use
"Block.NameCaseFromModule" use
"Block.NameCaseInvalid" use
"Block.NameCaseLocal" use
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
"File.File" use
"Var.CodeNodeInfo" use
"Var.Dirty" use
"Var.Dynamic" use
"Var.Field" use
"Var.RefToVar" use
"Var.Schema" use
"Var.ShadowReasonCapture" use
"Var.ShadowReasonField" use
"Var.ShadowReasonInput" use
"Var.ShadowReasonPointee" use
"Var.Static" use
"Var.Struct" use
"Var.VarBuiltin" use
"Var.VarCode" use
"Var.VarEnd" use
"Var.VarImport" use
"Var.VarInt16" use
"Var.VarInt32" use
"Var.VarInt64" use
"Var.VarInt8" use
"Var.VarIntX" use
"Var.VarNat16" use
"Var.VarNat32" use
"Var.VarNat64" use
"Var.VarNat8" use
"Var.VarNatX" use
"Var.VarInvalid" use
"Var.VarReal32" use
"Var.VarReal64" use
"Var.VarRef" use
"Var.VarString" use
"Var.VarStruct" use
"Var.Variable" use
"Var.Virtual" use
"Var.Weak" use
"astNodeType.AstNode" use
"astNodeType.AstNodeType" use
"astNodeType.IndexArray" use
"astNodeType.MultiParserResult" use
"debugWriter.addDebugLocation" use
"debugWriter.addDebugReserve" use
"debugWriter.addFuncDebugInfo" use
"debugWriter.addGlobalVariableDebugInfo" use
"debugWriter.addVariableMetadata" use
"debugWriter.moveLastDebugString" use
"defaultImpl.defaultMakeConstWith" use
"defaultImpl.defaultRef" use
"defaultImpl.defaultSet" use
"defaultImpl.failProcForProcessor" use
"defaultImpl.findNameInfo" use
"defaultImpl.getStackDepth" use
"defaultImpl.getStackEntry" use
"irWriter.addStrToProlog" use
"irWriter.appendInstruction" use
"irWriter.createAllocIR" use
"irWriter.createComment" use
"irWriter.createCopyToNew" use
"irWriter.createDerefTo" use
"irWriter.createGEPInsteadOfAlloc" use
"irWriter.createLabel" use
"irWriter.createMemset" use
"irWriter.createPlainIR" use
"irWriter.createRefOperation" use
"irWriter.createRetValue" use
"irWriter.createStaticGEP" use
"irWriter.createStoreConstant" use
"irWriter.createStoreFromRegister" use
"irWriter.createStringIR" use
"irWriter.sortInstructions" use
"processor.MatchingNode" use
"processor.NameWithOverload" use
"processor.Processor" use
"processor.ProcessorResult" use
"processor.RefToVarTable" use
"staticCall.staticCall" use
"variable.MemberCaseToObjectCaptureCase" use
"variable.MemberCaseToObjectCase" use
"variable.NameCaseClosureMember" use
"variable.NameCaseClosureObject" use
"variable.NameCaseClosureObjectCapture" use
"variable.NameCaseSelfMember" use
"variable.NameCaseSelfObject" use
"variable.NameCaseSelfObjectCapture" use
"variable.NameInfo" use
"variable.NameInfoEntry" use
"variable.Overload" use
"variable.callBuiltin" use
"variable.checkValue" use
"variable.compareEntriesRec" use
"variable.compilable" use
"variable.compilerError" use
"variable.createDtorForGlobalVar" use
"variable.findField" use
"variable.findFieldWithOverloadShift" use
"variable.fullUntemporize" use
"variable.generateRegisterIRName" use
"variable.getIrName" use
"variable.getIrType" use
"variable.getMplSchema" use
"variable.getMplType" use
"variable.getMplTypeImpl" use
"variable.getNameById" use
"variable.getPlainConstantIR" use
"variable.getVar" use
"variable.isAutoStruct" use
"variable.isForgotten" use
"variable.isGlobal" use
"variable.isNonrecursiveType" use
"variable.isPlain" use
"variable.isSchema" use
"variable.isTinyArg" use
"variable.isUnallocable" use
"variable.isVirtual" use
"variable.isVirtualType" use
"variable.makeStringId" use
"variable.makeVariableIRName" use
"variable.makeVariableType" use
"variable.markAsUnableToDie" use
"variable.maxStaticity" use
"variable.noMatterToCopy" use
"variable.processCall" use
"variable.processCallByIndexArrayImpl" use
"variable.processExportFunction" use
"variable.processFuncPtr" use
"variable.processPre" use
"variable.staticityOfVar" use
"variable.unglobalize" use
"variable.untemporize" use
"variable.variablesAreSame" use

addOverload: [
  copy nameInfo:;

  nameInfo 0 < ~ [
    currentNameInfo: nameInfo @processor.@nameInfos.at;
    Overload @currentNameInfo.@stack.pushBack
    currentNameInfo.stack.dataSize 1 -
  ] [
    "bad overload index" block compilerError
    -1
  ] if
];

getOverloadCount: [
  copy nameInfo:;
  overloads: nameInfo processor.nameInfos.at.stack;
  overloads.getSize
];

addNameInfoWith: [
  block:;
  copy index:;
  copy reg:;
  copy overload:;
  copy startPoint:;
  copy addNameCase:;
  refToVar:;
  copy nameInfo:;

  [addNameCase NameCaseFromModule = [refToVar noMatterToCopy] || [refToVar getVar.host block is] ||] "addNameInfo block mismatch!" assert

  nameInfo 0 < ~ [
    currentNameInfo: nameInfo @processor.@nameInfos.at;
    currentNameInfo.stack.dataSize 0 = [
      Overload @currentNameInfo.@stack.pushBack # initialisation of nameInfo
    ] when

    overload 0 < [
      currentNameInfo.stack.dataSize 1 - @overload set
    ] when

    addInfo: TRUE;

    reg ~ [addNameCase NameCaseBuiltin =] || [
    ] [
      nameWithOverload: NameWithOverloadAndRefToVar;
      refToVar    @nameWithOverload.@refToVar     set
      overload    @nameWithOverload.@nameOverload set
      nameInfo    @nameWithOverload.@nameInfo     set
      startPoint  @nameWithOverload.@startPoint   set

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
            ] [
              addNameCase NameCaseSelfObject = [addNameCase NameCaseClosureObject =] || [
                # do nothing
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
      refToVar    @nameInfoEntry.@refToVar set
      addNameCase @nameInfoEntry.@nameCase set
      startPoint  @nameInfoEntry.@startPoint set
      index       @nameInfoEntry.@index set
      cur: overload @currentNameInfo.@stack.at;
      nameInfoEntry @cur.pushBack

      refToVar noMatterToCopy [
        refToVar @block.@captureTable.find.success ~ [
          refToVar TRUE @block.@captureTable.insert
        ] when
      ] when
    ] when
  ] [
    #we add "self" or "closure" but dont use them in program
  ] if
];

addNameInfo: [block.id -1 dynamic TRUE -1 dynamic @block addNameInfoWith];
addNameInfoOverloaded: [block:; TRUE -1 dynamic @block addNameInfoWith];
addNameInfoNoReg: [block.id -1 dynamic FALSE -1 dynamic @block addNameInfoWith];

addNameInfoFieldNoReg: [
  index: copy;
  block.id -1 dynamic FALSE index @block addNameInfoWith
];

getNameLastIndexInfo: [
  nameInfo:;
  currentNameInfo: nameInfo @processor.@nameInfos.at;

  result: IndexInfo;
  currentNameInfo.stack.dataSize 1 - @result.@overload set
  currentNameInfo.stack.last.dataSize 1 - @result.@index set
  result
];

deleteNameInfoWithOverload: [
  copy nameInfo:;
  copy overloadId:;

  currentNameInfo: nameInfo @processor.@nameInfos.at;
  overload: overloadId @currentNameInfo.@stack.at;

  @overload.popBack

  [
    currentNameInfo.stack.last.dataSize 0 = [currentNameInfo.stack.dataSize 1 >] && [
      @currentNameInfo.@stack.popBack
      TRUE
    ] &&
  ] loop
];

deleteNameInfo: [
  copy nameInfo:;

  currentNameInfo: nameInfo @processor.@nameInfos.at;
  currentNameInfo.stack.dataSize 1 - nameInfo deleteNameInfoWithOverload
];

makeStaticity: [
  refToVar: staticity: block:;;;
  refToVar isVirtual ~ [
    var: @refToVar getVar;
    staticity @var.@staticity set
    staticity Virtual < ~ [
      refToVar block makeVariableType
    ] when
  ] when

  refToVar copy
];

makeStorageStaticity: [
  copy staticity:;
  copy refToVar:;

  refToVar isVirtual ~ [
    staticity @refToVar getVar.@storageStaticity set
  ] when

  refToVar
];

createVariable: [
  block:;
  FALSE dynamic FALSE dynamic TRUE dynamic @block createVariableWithVirtual
];

createVariableWithVirtual: [
  block:;
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
  @block @result getVar.@host.set

  makeVirtual [
    makeSchema [Schema] [Virtual] if @result getVar.@staticity set
  ] [
    result isPlain [processor.options.staticLiterals ~] && [
      Weak @result getVar.@staticity set
    ] [
      Static @result getVar.@staticity set
    ] if
  ] if

  result @result getVar.@capturedHead set
  result @result getVar.@capturedTail set

  result isNonrecursiveType ~ [result isUnallocable ~] && @result.setMutable

  makeType [result block makeVariableType] when
  @result block makeVariableIRName

  processor.varCount 1 + @processor.@varCount set

  @result
];

push: [
  entry: block:;;
  entry @block.@stack.pushBack
];

getStackEntryForPreInput: [
  copy depth:;
  depth block getStackDepth < [
    entry: depth block getStackEntry;
    [entry getVar.host block is ~] "Pre input is just in inputs!" assert
    shadowBegin: RefToVar;
    shadowEnd: RefToVar;
    entry @shadowBegin @shadowEnd ShadowReasonInput @block makeShadows
    shadowEnd
  ] [
    RefToVar
  ] if
];

makeVarCode:   [VarCode   @block createVariable];
makeVarInt8:   [VarInt8   checkValue VarInt8   @block createVariable @block createPlainIR];
makeVarInt16:  [VarInt16  checkValue VarInt16  @block createVariable @block createPlainIR];
makeVarInt32:  [VarInt32  checkValue VarInt32  @block createVariable @block createPlainIR];
makeVarInt64:  [VarInt64  checkValue VarInt64  @block createVariable @block createPlainIR];
makeVarIntX:   [VarIntX   checkValue VarIntX   @block createVariable @block createPlainIR];
makeVarNat8:   [VarNat8   checkValue VarNat8   @block createVariable @block createPlainIR];
makeVarNat16:  [VarNat16  checkValue VarNat16  @block createVariable @block createPlainIR];
makeVarNat32:  [VarNat32  checkValue VarNat32  @block createVariable @block createPlainIR];
makeVarNat64:  [VarNat64  checkValue VarNat64  @block createVariable @block createPlainIR];
makeVarNatX:   [VarNatX   checkValue VarNatX   @block createVariable @block createPlainIR];
makeVarReal32: [VarReal32 checkValue VarReal32 @block createVariable @block createPlainIR];
makeVarReal64: [VarReal64 checkValue VarReal64 @block createVariable @block createPlainIR];

makeVarString: [
  string: block:;;
  refToVar: RefToVar;

  fr: string @processor.@stringNames.find;
  fr.success [
    fr.value @refToVar set
  ] [
    block: 0 @processor.@blocks.at.get;

    string VarString @block createVariable @refToVar set
    string.getStringView @refToVar createStringIR
    string refToVar @processor.@stringNames.insert

    @refToVar fullUntemporize
    refToVar getVar.mplNameId refToVar NameCaseLocal addNameInfo
  ] if

  gnr: refToVar getVar.mplNameId @block File Ref getName;
  cnr: @gnr @block captureName;

  cnr.refToVar copy
];

getPointeeForMatching: [
  refToVar:;
  var: refToVar getVar;
  [var.data.getTag VarRef =] "Not a reference!" assert
  pointee: VarRef @var.@data.get; # reference
  result: pointee copy;
  refToVar.mutable pointee.mutable and @result.setMutable # to deref is
  result
];

getPointeeWith: [
  refToVar: makeDerefIR: dynamize: block:;;;;
  var: @refToVar getVar;
  [var.data.getTag VarRef =] "Not a reference!" assert
  refToVar isVirtualType [
    refToVar copy
  ] [
    pointee: VarRef @var.@data.get; # reference

    fromParent: pointee getVar.host block is ~;
    pointeeIsGlobal: FALSE dynamic;
    needReallyDeref: FALSE dynamic;

    refToVar staticityOfVar Dynamic > ~ [

      # create new var of dynamic dereference
      fromParent [
        pointeeCopy: pointee @block copyOneVar;
        psBegin: RefToVar;
        psEnd:   RefToVar;
        pointeeCopy @psBegin @psEnd ShadowReasonPointee @block makeShadowsDynamic
        @psBegin block unglobalize
        @psEnd   block unglobalize
        dynamize ~ [psEnd @block makeVarTreeDynamicStoraged] when
        psEnd @pointee set
      ] [
        pointeeCopy: pointee @block copyVar; # lost info that pointee is from parent # noMatterToCopy
        @pointeeCopy block unglobalize
        dynamize ~ [pointeeCopy @block makeVarTreeDynamicStoraged] when
        pointeeCopy @pointee set
      ] if

      TRUE @needReallyDeref set
    ] [
      pointeeGDI: pointee getVar.globalDeclarationInstructionIndex;
      fromParent [ # capture or argument
        varShadow: refToVar copy;
        refToVar noMatterToCopy ~ [
          [var.shadowBegin.assigned] "Ref got from parent, but dont have shadow!" assert
          var.shadowBegin @varShadow set
        ] when
        pointeeOfShadow: VarRef @varShadow getVar.@data.get;

        pointeeOfShadow getVar.host block is [ # just made deref from another place
          pointeeOfShadowVar: pointeeOfShadow getVar;
          [pointeeOfShadowVar.shadowEnd.assigned] "Pointee of shadow is not a shadow!" assert
          pointeeOfShadowVar.shadowEnd @pointee set
        ] [
          psBegin: RefToVar;
          psEnd:   RefToVar;
          pointeeOfShadow pointee = [
            pointeeOfShadow @psBegin @psEnd ShadowReasonPointee @block makeShadows
            psBegin @pointeeOfShadow set
            psEnd @pointee set
          ] [
            #we changed ref, pointeeOFShadow is another pointer to another var!
            pointee @psBegin @psEnd ShadowReasonPointee @block makeShadows
            psEnd @pointee set
          ] if

          @psBegin fullUntemporize
          @psEnd   fullUntemporize

          TRUE @needReallyDeref set
        ] if
      ] when

      pointee isGlobal [
        TRUE @pointeeIsGlobal set
      ] when
    ] if

    pointeeVar: @pointee getVar;
    pointeeVar.getInstructionIndex 0 < [pointeeIsGlobal ~] && [
      pointeeVar.allocationInstructionIndex 0 < [
        TRUE @needReallyDeref set
      ] when
    ] [
      FALSE @needReallyDeref set
    ] if

    needReallyDeref makeDerefIR and [
      refToVar pointeeVar.irNameId @block createDerefTo
      block.program.dataSize 1 - @pointeeVar.@getInstructionIndex set
    ] when

    @pointee fullUntemporize

    result: pointee copy;
    refToVar.mutable pointee.mutable and @result.setMutable # to deref is
    result
  ] if
];

getPointee:              [block:; TRUE  FALSE @block getPointeeWith];
getPointeeNoDerefIR:     [FALSE FALSE @block getPointeeWith];
getPointeeWhileDynamize: [block:; FALSE TRUE  @block getPointeeWith];

getFieldForMatching: [
  mplFieldIndex: refToVar: block:;;;

  var: refToVar getVar;
  [var.data.getTag VarStruct =] "Not a combined!" assert
  struct: VarStruct @var.@data.get.get;

  mplFieldIndex 0 < ~ [
    fieldRefToVar: mplFieldIndex struct.fields.at.refToVar copy;
    refToVar.mutable @fieldRefToVar.setMutable
    @fieldRefToVar block unglobalize

    fieldVar: @fieldRefToVar getVar;
    fieldVar.data.getTag VarStruct = [
      fieldStruct: VarStruct @fieldVar.@data.get.get;
      struct.forgotten @fieldStruct.@forgotten set
    ] when

    fieldRefToVar
  ] [
    "index is out of bounds" block compilerError
    RefToVar
  ] if
];

getField: [
  mplFieldIndex: refToVar: block:;;;
  var: @refToVar getVar;
  [var.data.getTag VarStruct =] "Not a combined!" assert
  struct: VarStruct @var.@data.get.get;

  mplFieldIndex 0 < ~ [mplFieldIndex struct.fields.getSize <] && [
    fieldRefToVar: mplFieldIndex @struct.@fields.at.@refToVar;
    fieldVar: @fieldRefToVar getVar;
    fieldVar.data.getTag VarStruct = [
      fieldStruct: VarStruct @fieldVar.@data.get.get;
      struct.forgotten @fieldStruct.@forgotten set
    ] when

    fieldRefToVar noMatterToCopy [fieldVar.host block is] || ~ [ # capture or argument
      var.shadowBegin.assigned ~ [
        [refToVar noMatterToCopy] "Field got from parent, but dont have shadow!" assert
        fieldRefToVar @block copyVarFromChild @fieldRefToVar set
      ] [
        varShadow: @var.@shadowBegin getVar;
        [varShadow.data.getTag VarStruct =] "Shadow is not a combined!" assert
        structShadow: VarStruct @varShadow.@data.get.get;
        fieldShadow: mplFieldIndex @structShadow.@fields.at.@refToVar;
        @fieldShadow block unglobalize

        psBegin: RefToVar;
        psEnd: RefToVar;
        fieldShadow @psBegin @psEnd ShadowReasonField @block makeShadows

        psBegin @fieldShadow set
        psEnd @fieldRefToVar set
      ] if

      var.staticity fieldRefToVar getVar.staticity < [
        var.staticity @fieldRefToVar getVar.@staticity set
      ] when
    ] when

    refToVar.mutable @fieldRefToVar.setMutable

    @fieldRefToVar
  ] [
    "index is out of bounds" block compilerError
    failResult: RefToVar Ref;
    @failResult
  ] if
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
            f @current @block getField @unprocessed.pushBack
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
    srcVar.data.getTag VarInvalid VarRef 1 + [
      copy tag:;
      tag srcVar.data.get
      tag @dstVar.@data.get set
    ] staticCall
  ] when

  refDst staticityOfVar Dirty > [
    staticity: refSrc staticityOfVar;
    staticity Weak = [refDst staticityOfVar @staticity set] when
    @refDst staticity block makeStaticity drop
  ] [
    srcVar.data.getTag VarRef = [refSrc.mutable] && [VarRef srcVar.data.get.mutable] && [
      staticity: refSrc staticityOfVar;
      refSrc @block makeVarTreeDirty
      @refSrc staticity block makeStaticity drop
    ] when
  ] if
];

setVar: [
  copy refDst:;
  refSrc:;
  uncopiedSrc: RefToVar Array;
  uncopiedDst: RefToVar AsRef Array;
  compileOnce

  refSrc @uncopiedSrc.pushBack
  @refDst AsRef @uncopiedDst.pushBack

  i: 0 dynamic;
  [
    i uncopiedSrc.dataSize < [
      currentSrc: i uncopiedSrc.at copy;
      currentDst: i @uncopiedDst.at.@data;
      @currentSrc @currentDst i 0 = setOneVar

      currentSrcVar: currentSrc getVar;
      currentDstVar: currentDst getVar;
      currentSrcVar.data.getTag VarStruct = [
        branchSrc: VarStruct currentSrcVar.data.get.get;
        branchDst: VarStruct currentDstVar.data.get.get;
        f: 0 dynamic;
        [
          f branchSrc.fields.dataSize < [
            fieldSrc: f @currentSrc @block getField;
            fieldDst: f @currentDst @block getField;

            fieldSrc @uncopiedSrc.pushBack
            @fieldDst AsRef @uncopiedDst.pushBack

            f 1 + @f set TRUE
          ] &&
        ] loop
      ] when

      i 1 + @i set TRUE
    ] &&
  ] loop
];

createRefWith: [
  refToVar: mutable: createOperation: block:;;;;
  refToVar isVirtual [
    @refToVar untemporize
    refToVar copy #for dropping or getting callables for example
  ] [
    pointee: refToVar copy;
    var: @pointee getVar;
    pointee staticityOfVar Weak = [Dynamic @var.@staticity set] when
    @pointee fullUntemporize

    pointee.mutable [mutable copy] && @pointee.setMutable
    newRefToVar: pointee VarRef @block createVariable;
    createOperation [pointee @newRefToVar @block createRefOperation] when
    newRefToVar
  ] if
];

createRef: [block:; TRUE dynamic @block createRefWith];
createRefNoOp: [FALSE dynamic @block createRefWith];

createCheckedStaticGEP: [
  fieldRef: index: refToStruct: block:;;;;
  fieldVar: @fieldRef getVar;
  fieldVar.getInstructionIndex 0 < [fieldVar.allocationInstructionIndex 0 <] && [
    @fieldRef block unglobalize
    fieldRef index refToStruct @block createStaticGEP
    block.program.dataSize 1 - @fieldVar.@getInstructionIndex set
  ] when
];

makeVirtualVarReal: [
  refToVar:;

  refToVar isVirtualType [
    refToVar copy
  ] [
    processor.options.verboseIR [("made virtual var real, type: " refToVar block getMplType) assembleString @block createComment] when

    realValue: @refToVar getVar.@realValue;

    unfinishedSrc: RefToVar Array;
    unfinishedDst: RefToVar Array;

    result: refToVar @block copyOneVar;

    result isVirtualType ~ [
      Static @result getVar.@staticity set

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

          # noMatterToCopy
          lastSrc getVar.host block is ~ [varDst.shadowBegin.assigned ~] && [
            shadowBegin: lastDst @block copyOneVar;
            shadowBeginVar: @shadowBegin getVar;
            lastDst @shadowBeginVar.@shadowEnd set
            shadowBegin @varDst.@shadowBegin set
          ] when

          varSrc.data.getTag VarStruct = [
            struct: VarStruct varSrc.data.get.get;
            j: 0 dynamic;
            [
              j struct.fields.dataSize < [
                srcField: j struct.fields.at;
                srcField.refToVar isVirtual ~ [
                  srcField.refToVar @unfinishedSrc.pushBack
                  dstField: j @lastDst @block getField;
                  dstField @unfinishedDst.pushBack
                  @dstField block unglobalize
                ] [
                  dstField: j @lastDst @block getField;
                  @dstField Virtual block makeStaticity r:;
                  @dstField block unglobalize
                ] if

                j 1 + @j set TRUE
              ] &&
            ] loop
          ] when

          compilable
        ] &&
      ] loop

      # second pass: create IR code for variable
      @result block makeVariableType
      refToVar @unfinishedSrc.pushBack
      @result @block createAllocIR @unfinishedDst.pushBack

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
                  dstField: j @lastDst @block getField;
                  dstField @unfinishedDst.pushBack
                  @dstField block unglobalize
                  @dstField j lastDst @block createCheckedStaticGEP
                ] when

                j 1 + @j set TRUE
              ] &&
            ] loop
          ] [
            lastSrc isVirtualType ~ [
              varSrc.data.getTag VarRef = [
              ] [
                lastSrc isPlain [
                  lastSrc lastDst @block createStoreConstant
                ] when
              ] if
            ] when
          ] if

          compilable
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
  @refToVar Schema block makeStaticity drop
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
          "can not virtualize automatic struct" block compilerError
        ] [
          struct: VarStruct curVar.data.get.get;
          j: 0 dynamic;
          [
            j struct.fields.dataSize < [compilable] && [
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
          VarRef curVar.data.get isUnallocable [
          ] [
            "can not virtualize reference to local variable" block compilerError
          ] if
        ] [
          cur staticityOfVar Weak < [
            "can not virtualize dynamic value" block compilerError
          ] when
        ] if
      ] if
      compilable
    ] &&
  ] loop

  compilable [
    @refToVar Virtual block makeStaticity drop
  ] when
];

makeVarRealCaptured: [
  refToVar:;
  TRUE @refToVar getVar.@capturedAsRealValue set
];

makeVarTreeDirty: [
  refToVar: block:;;
  unfinishedVars: RefToVar Array;
  refToVar @unfinishedVars.pushBack

  [
    unfinishedVars.dataSize 0 > [
      lastRefToVar: unfinishedVars.last copy;
      @unfinishedVars.popBack

      var: lastRefToVar getVar;
      lastRefToVar staticityOfVar Virtual = ["can't dynamize virtual value" block compilerError] when
      lastRefToVar staticityOfVar Schema = ["can't dynamize schema" block compilerError] when

      compilable [
        var.data.getTag VarStruct = [
          struct: VarStruct var.data.get.get;
          j: 0 dynamic;
          [
            j struct.fields.dataSize < [
              j struct.fields.at.refToVar isVirtual ~ [
                j @lastRefToVar @block getField @unfinishedVars.pushBack
              ] when
              j 1 + @j set TRUE
            ] &&
          ] loop
        ] [
          var.data.getTag VarRef = [
            lastRefToVar staticityOfVar Static = [
              pointee: @lastRefToVar @block getPointeeWhileDynamize;
              pointee.mutable [pointee @unfinishedVars.pushBack] when
            ] [
              [lastRefToVar staticityOfVar Dynamic > ~] "Ref must be only Static or Dynamic!" assert
            ] if
          ] when
        ] if

        var.data.getTag VarImport = ~ var.data.getTag VarString = ~ and [
          @lastRefToVar Dirty block makeStaticity @lastRefToVar set
        ] when
      ] when

      compilable
    ] &&
  ] loop
];

makePointeeDirtyIfRef: [
  refToVar:;
  var: refToVar getVar;
  var.data.getTag VarRef = [var.staticity Static =] && [
    pointee: @refToVar @block getPointeeWhileDynamize;
    @pointee makeVarRealCaptured
    pointee.mutable [pointee @block makeVarTreeDirty] when
  ] when
];

makeVarDynamicOrDirty: [
  newStaticity:;
  refToVar:;
  refToVar staticityOfVar Virtual = ["can't dynamize virtual value" block compilerError] when

  @refToVar makePointeeDirtyIfRef
  msr: @refToVar newStaticity @block makeStaticity;
];

makeVarDynamic: [Dynamic makeVarDynamicOrDirty];
makeVarDirty:   [Dirty   makeVarDynamicOrDirty];

makeVarTreeDynamicWith: [
  refToVar: dynamicStoraged: block:;;;
  unfinishedVars: RefToVar Array;
  refToVar @unfinishedVars.pushBack

  [
    unfinishedVars.dataSize 0 > [
      lastRefToVar: unfinishedVars.last copy;
      @unfinishedVars.popBack

      var: lastRefToVar getVar;
      lastRefToVar staticityOfVar Virtual = ["can't dynamize virtual value" block compilerError] when

      var.data.getTag VarStruct = [
        struct: VarStruct var.data.get.get;
        j: 0 dynamic;
        [
          j struct.fields.dataSize < [
            j struct.fields.at.refToVar isVirtual ~ [
              j @lastRefToVar @block getField @unfinishedVars.pushBack
            ] when
            j 1 + @j set TRUE
          ] &&
        ] loop
      ] [
        var.data.getTag VarRef = [
          lastRefToVar staticityOfVar Static = [
            dynamicStoraged ~ [
              pointee: @lastRefToVar @block getPointeeWhileDynamize;
              pointee.mutable [pointee @block makeVarTreeDirty] when
            ] when # dynamic storaged data is not real
          ] [
            [lastRefToVar staticityOfVar Dynamic = lastRefToVar staticityOfVar Dirty = or] "Ref must be only Static or Dirty or Dynamic!" assert
          ] if
        ] when
      ] if

      dynamicStoraged [
        lastRefToVar  Dynamic makeStorageStaticity @lastRefToVar set
        @lastRefToVar Dirty   block makeStaticity  @lastRefToVar set
      ] [
        @lastRefToVar Dynamic block makeStaticity  @lastRefToVar set
      ] if
      compilable
    ] &&
  ] loop
];

makeVarTreeDynamic:         [FALSE dynamic @block makeVarTreeDynamicWith];
makeVarTreeDynamicStoraged: [block:; TRUE  dynamic @block makeVarTreeDynamicWith];

addOverloadForPre: [
  refToVar:;
  copy nameInfo:;

  var: refToVar getVar;
  var.data.getTag VarStruct = [
    struct: VarStruct @var.@data.get.get;
    struct.hasPreField [
      overload: nameInfo addOverload;
    ] when
  ] when
];

createNamedVariable: [
  nameInfo: refToVar: block:;;;
  compilable [
    newRefToVar: refToVar copy;
    staticity: refToVar staticityOfVar;
    var: @newRefToVar getVar;

    block.nextLabelIsVirtual [
      refToVar isVirtual ~ [
        staticity Dynamic > ~ ["value for virtual label must be static" block compilerError] when
        staticity Weak = [Static @var.@staticity set] when
      ] when
    ] when

    isGlobalLabel: [
      refToVar:;
      block.nextLabelIsVirtual ~ [refToVar isVirtual ~] && [refToVar isGlobal] &&
    ];

    var.temporary [refToVar isGlobalLabel] &&  [
      refToVar @block makeVarTreeDirty
      Dirty @staticity set
    ] when

    var.temporary block.nextLabelIsSchema ~ and [
      staticity @var.@staticity set
      staticity Weak = [Dynamic @var.@staticity set] when
    ] [
      newRefToVar noMatterToCopy block.nextLabelIsVirtual or newRefToVar isUnallocable ~ and [
        refToVar @block copyVarToNew @newRefToVar set
      ] [
        TRUE @var.@capturedAsMutable set #we need ref
        @refToVar TRUE block.nextLabelIsSchema ~ @block createRefWith @newRefToVar set
        newRefToVar isGlobalLabel [newRefToVar @block makeVarTreeDirty] when
      ] if
    ] if

    TRUE dynamic @newRefToVar.setMutable

    nameInfo newRefToVar addOverloadForPre
    @newRefToVar fullUntemporize
    FALSE @newRefToVar getVar.@tref set

    block.nextLabelIsVirtual block.nextLabelIsSchema or [
      newRefToVar block makeVariableType
      block.nextLabelIsSchema [@newRefToVar makeVarSchema][@newRefToVar makeVarVirtual] if
      FALSE @block.@nextLabelIsVirtual set
      FALSE @block.@nextLabelIsSchema set
    ] when

    nameInfo newRefToVar NameCaseLocal addNameInfo
    compilable [processor.options.debug copy] && [newRefToVar isVirtual ~] && [
      newRefToVar isGlobal [
        d: nameInfo newRefToVar block addGlobalVariableDebugInfo;
        globalInstruction: newRefToVar getVar.globalDeclarationInstructionIndex @processor.@prolog.at;
        ", !dbg !"   @globalInstruction.cat
        d            @globalInstruction.cat
      ] [
        nameInfo newRefToVar @block addVariableMetadata
      ] if
    ] when

    block.nodeCase NodeCaseObject = [
      newField: Field;
      nameInfo @newField.@nameInfo set
      newRefToVar @newField.@refToVar set

      newField @block.@struct.@fields.pushBack
    ] when

    nameInfo @newRefToVar getVar.@mplNameId set
  ] when
];

processLabelNode: [
  block:;
  .nameInfo @block pop @block createNamedVariable
];

processCodeNode: [
  indexOfAstNode: file:;;
  astNode: indexOfAstNode multiParserResult.memory.at; #we have info from parser anyway
  codeInfo: CodeNodeInfo;

  file                @codeInfo.@file.set
  astNode.line   copy @codeInfo.!line
  astNode.column copy @codeInfo.!column
  indexOfAstNode copy @codeInfo.!index

  @codeInfo move makeVarCode @block push
];

processCallByIndexArray: [
  indexArray: file: nodeCase: name: positionInfo:;;;;;
  indexArray file nodeCase name positionInfo multiParserResult @block @processor @processorResult processCallByIndexArrayImpl
];

processObjectNode: [
  data: file:;;
  position: block.position copy;
  name: "objectInitializer" makeStringView;
  data file NodeCaseObject dynamic name position processCallByIndexArray
];

processListNode: [
  data: file:;;
  position: block.position copy;
  name: "listInitializer" makeStringView;
  data file NodeCaseList dynamic name position processCallByIndexArray
];

{
  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  block: Block Cref;
  message: StringView Cref;
} () {convention: cdecl;} [
  processorResult:;
  processor:;
  block:;
  message:;
  failProc: @failProcForProcessor;
  [
    compileOnce
    processorResult.findModuleFail ~ [processor.depthOfPre 0 =] && [HAS_LOGS] && [
      ("COMPILER ERROR") addLog
      (message) addLog
      block defaultPrintStackTrace
    ] when

    compilable [
      FALSE dynamic @processorResult.@success set

      processor.depthOfPre 0 = [processorResult.passErrorThroughPRE copy] || [
        message toString @processorResult.@errorInfo.@message set
        [
          block.root [
            FALSE
          ] [
            block.position @processorResult.@errorInfo.@position.pushBack
            block.parent processor.blocks.at.get !block
            TRUE
          ] if
        ] loop
      ] when
    ] when
  ] call
] "compilerErrorImpl" exportFunction

findLocalObject: [
  refToVar: captureCase: block:;; copy;
  i: 0 dynamic;
  [
    i block.buildingMatchingInfo.captures.dataSize < [
      currentCapture: i block.buildingMatchingInfo.captures.at;
      currentCapture.captureCase captureCase = [
        currentCapture.refToVar refToVar variablesAreSame
      ] && [
        currentCapture.refToVar @refToVar set
        FALSE
      ] [
        i 1 + @i set
        TRUE
      ] if
    ] &&
  ] loop

  refToVar
];

findNameStackObject: [
  copy nameCase:;
  refToVar:;
  stack:;

  result: RefToVar;
  i: 0 dynamic;
  [
    i stack.dataSize < [
      current: stack.dataSize 1 - i - stack.at;
      nameCase current.nameCase = [refToVar current.refToVar variablesAreSame] && [
        current.refToVar @result set
        FALSE
      ] [
        i 1 + @i set TRUE
      ] if
    ] &&
  ] loop

  result
];

getNameAs: [
  block: file:;;
  copy overload:;
  copy forMatching:;
  matchingCapture:;
  copy nameInfo:;
  curNameInfo: nameInfo processor.nameInfos.at;
  [overload -1 = [overload curNameInfo.stack.size <] ||] "Invalid overload index" assert

  unknownName: [
    forMatching [
    ] [
      ("unknown name:" curNameInfo.name) assembleString block compilerError
    ] if
  ];

  result: {
    refToVar: RefToVar;
    startPoint: -1 dynamic;
    nameInfo: nameInfo copy;
    nameOverload: -1 dynamic;
    object: RefToVar;
    mplFieldIndex: -1 dynamic;
    nameCase: NameCaseInvalid;
  };

  overload -1 = [curNameInfo.stack.getSize 1 - !overload] when
  curNameInfo.stack.getSize 0 = [overload curNameInfo.stack.at.getSize 0 =] || [unknownName] [
    nameInfoEntry: overload curNameInfo.stack.at.last;
    overload @result.@nameOverload set
    nameInfoEntry.nameCase   @result.@nameCase   set
    nameInfoEntry.startPoint @result.@startPoint set

    nameCase: matchingCapture.captureCase NameCaseInvalid = [result.nameCase copy] [matchingCapture.captureCase copy] if;
    nameCase NameCaseSelfMember = [nameCase NameCaseClosureMember =] || [
      object: nameInfoEntry.refToVar;
      fields: VarStruct object getVar.data.get.get.fields;
      nameInfoEntry.index 0 < ~ [nameInfoEntry.index fields.getSize <] && [nameInfoEntry.index fields.at.nameInfo nameInfo =] && [
        object nameCase MemberCaseToObjectCase @block findLocalObject @result.@object set
        nameInfoEntry.index @result.@mplFieldIndex set
        nameInfoEntry.index fields.at.refToVar @result.@refToVar set
        object.mutable @result.@refToVar.setMutable
      ] [
        ("Internal error, mismatch structures for name:" curNameInfo.name) assembleString block compilerError
      ] if
    ] [
      nameCase NameCaseSelfObject = [nameCase NameCaseClosureObject =] || [
        forMatching [
          overload curNameInfo.stack.at matchingCapture.refToVar nameCase findNameStackObject @result.@refToVar set
        ] [
          nameInfoEntry.refToVar nameCase @block findLocalObject @result.@refToVar set
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

        block.parent 0 = [nameInfoEntry.startPoint block.id = ~] && [
          fr: nameInfoEntry.startPoint @block.@usedModulesTable.find;
          fr.success [TRUE @fr.@value.@used set] when
        ] when

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

getName: [block: file:;; Capture FALSE dynamic -1 dynamic @block file getNameAs];
getNameForMatching: [TRUE dynamic -1 dynamic @block File Ref getNameAs];

getNameWithOverload: [
  copy overload:;
  Capture FALSE dynamic overload @block File Ref getNameAs
];

getNameForMatchingWithOverload: [
  overload: block:;;
  TRUE dynamic overload @block File Ref getNameAs
];

captureName: [
  getNameResult: block:;;

  result: {
    refToVar: RefToVar;
    object: RefToVar;
  };

  compilable [
    captureError: FALSE dynamic;

    captureRefToVar: [
      copy captureCase:;
      refToVar:;
      copy nameInfo:;

      result: {
        refToVar: RefToVar;
        newVar: FALSE;
      };

      nameWithOverload: NameWithOverload;
      getNameResult.nameOverload @nameWithOverload.@nameOverload set
      getNameResult.nameInfo     @nameWithOverload.@nameInfo set

      head: refToVar getVar.capturedHead;
      needToCapture: refToVar getVar.host block is ~;
      needToCapture ~ [
        head getVar.host block is ~ [refToVar noMatterToCopy ~] && [
          var: refToVar getVar;

          var.allocationInstructionIndex 0 <
          var.getInstructionIndex 0 < and
          var.globalDeclarationInstructionIndex 0 < and

          [
            var.shadowReason ShadowReasonCapture = ~
            [
              captureCase NameCaseSelfObject =
              captureCase NameCaseClosureObject = or
              var.shadowReason ShadowReasonInput = and ~
            ] &&
          ] && [
            TRUE @needToCapture set
          ] when
        ] when
      ] when

      needToCapture ~ [
        TRUE @refToVar getVar.@capturedAsMutable set
        refToVar @result.@refToVar set
      ] [
        refToVar noMatterToCopy ~ [
          head block.captureTable.find.success ~ [
            head TRUE @block.@captureTable.insert
            TRUE
          ] &&

          refToVar @result.@refToVar set
        ] || [
          shadowBegin: RefToVar;
          shadowEnd: RefToVar;
          refToVar @shadowBegin @shadowEnd ShadowReasonCapture @block makeShadows

          newCapture: Capture;
          shadowEnd @newCapture.@refToVar set
          nameInfo @newCapture.@nameInfo set
          [getNameResult.nameOverload 0 < ~] "name overload not initialized!" assert

          nameOverload:
          getNameResult.nameCase NameCaseSelfMember =
          [getNameResult.nameCase NameCaseClosureMember =] ||
          [0]
          [getNameResult.nameOverload copy] if;

          nameOverload @newCapture.@nameOverload set
          captureCase  @newCapture.@captureCase set

          refToVar isVirtual [ArgVirtual] [refToVar isGlobal [ArgGlobal] [ArgRef] if ] if @newCapture.@argCase set
          realCapture: newCapture.argCase ArgRef =;

          realCapture [block.exportDepth refToVar getVar.host.exportDepth = ~] && [
            TRUE !captureError
          ] when

          newCapture @block.@buildingMatchingInfo.@captures.pushBack
          block.state NodeStateNew = [
            shadowBegin @newCapture.@refToVar set
            nameInfo getOverloadCount @newCapture.@cntNameOverload set
            nameInfo getOverloadCount @newCapture.@cntNameOverloadParent set
            newCapture @block.@matchingInfo.@captures.pushBack
          ] when

          processor.options.debug [shadowEnd isVirtual ~] && [shadowEnd isGlobal ~] && [
            fakePointer: shadowEnd VarRef @block createVariable;
            shadowEnd @fakePointer @block createRefOperation
            nameInfo fakePointer @block addVariableMetadata
            programSize: block.program.getSize;
            TRUE programSize 3 - @block.@program.at.@fakePointer set
            TRUE programSize 2 - @block.@program.at.@fakePointer set
            TRUE programSize 1 - @block.@program.at.@fakePointer set
            @block addDebugLocationForLastInstruction
          ] when

          shadowEnd @result.@refToVar set
          TRUE @result.@newVar set

          @shadowEnd fullUntemporize
          refToVar isForgotten ~ [
            @shadowBegin fullUntemporize
          ] when

          [shadowEnd getVar.temporary ~] "Captured var must not be temporary!" assert
        ] when
      ] if

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

      cro: nameInfo @getNameResult.@object getNameResult.nameCase MemberCaseToObjectCase captureRefToVar;

      cro.refToVar @result.@object set
      getNameResult.mplFieldIndex @cro.@refToVar @block processStaticAt @result.@refToVar set
      cro.newVar [
        nameInfo cro.refToVar getNameResult.nameCase MemberCaseToObjectCaptureCase getNameResult.startPoint getNameResult.nameOverload @block addNameInfoOverloaded
      ] when # add name info for "self"/"closure" as Object; result is object

      needToCapture: getNameResult.startPoint block.id = ~ [
        head: getNameResult.refToVar getVar.capturedHead;
        head block.fieldCaptureTable.find.success ~ [
          head TRUE @block.@fieldCaptureTable.insert
          TRUE
        ] &&
      ] &&;

      needToCapture [
        getNameResult.nameInfo result.refToVar NameCaseCapture getNameResult.startPoint getNameResult.nameOverload @block addNameInfoOverloaded # add name info for fieldName as Capture; result is member

        newFieldCapture: FieldCapture;
        getNameResult.nameInfo @newFieldCapture.@nameInfo set
        [getNameResult.nameOverload 0 < ~] "name overload not initialized!" assert
        getNameResult.nameOverload @newFieldCapture.@nameOverload set
        result.object @newFieldCapture.@object set
        getNameResult.nameCase @newFieldCapture.@captureCase set
        newFieldCapture @block.@buildingMatchingInfo.@fieldCaptures.pushBack

        block.state NodeStateNew = [
          getNameResult.nameInfo getOverloadCount @newFieldCapture.@cntNameOverload set
          getNameResult.nameInfo getOverloadCount @newFieldCapture.@cntNameOverloadParent set
          newFieldCapture @block.@matchingInfo.@fieldCaptures.pushBack
        ] when
      ] when
    ] [
      cr: getNameResult.nameInfo @getNameResult.@refToVar getNameResult.nameCase captureRefToVar;
      cr.refToVar @result.@refToVar set
      cr.newVar [
        getNameResult.nameInfo result.refToVar NameCaseCapture getNameResult.startPoint getNameResult.nameOverload @block addNameInfoOverloaded
      ] when
    ] if

    captureError [
      "real function can not have real local capture" block compilerError
    ] when
  ] [
    getNameResult.refToVar @result.@refToVar set
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
      processor.callNameInfo refToVar findField.success copy
    ] &&
  ] ||
];

addFieldsNameInfos: [
  copy addNameCase:;
  refToVar:;

  var: refToVar getVar;
  struct: VarStruct var.data.get.get;

  i: 0 dynamic;
  [
    i struct.fields.dataSize < [
      currentField: i struct.fields.at;
      [currentField.nameInfo processor.emptyNameInfo = ~] "Closured list!" assert
      currentField.nameInfo currentField.refToVar addOverloadForPre
      currentField.nameInfo refToVar addNameCase i addNameInfoFieldNoReg # name info pointing to the struct, not to a field!
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
  object:;
  object.assigned [
    processor.closureNameInfo object NameCaseClosureObject addNameInfoNoReg
    object NameCaseClosureMember addFieldsNameInfos
  ] when
];

regNamesSelf: [
  object:;
  object.assigned [
    processor.selfNameInfo object NameCaseSelfObject addNameInfoNoReg
    object NameCaseSelfMember addFieldsNameInfos
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

  var: refToVar getVar;
  nextIteration: FALSE;

  struct: VarStruct var.data.get.get;

  fr: processor.callNameInfo refToVar findField;
  [fr.success copy] "Struct is not callable!" assert

  codeField: fr.index struct.fields.at .refToVar;
  codeVar: codeField getVar;
  codeVar.data.getTag VarCode = [
    object regNamesSelf
    refToVar regNamesClosure
    VarCode codeVar.data.get.index VarCode codeVar.data.get.file name processCall
    refToVar unregNamesClosure
    object unregNamesSelf
  ] [
    "CALL field is not a code" block compilerError
  ] if
];

callCallableField: [
  name:;
  refToVar:;
  object:;
  compileOnce

  var: refToVar getVar;
  code: VarCode var.data.get.index;
  file: VarCode var.data.get.file;

  object regNamesClosure
  code file @name processCall
  object unregNamesClosure
];

callCallableStructWithPre: [
  nameInfo:;
  copy refToVar:;
  copy object:;
  overloadShift: 0 dynamic;
  findInside: object.assigned;

  [
    var: refToVar getVar;
    nextIteration: FALSE;

    struct: VarStruct var.data.get.get;

    fr: processor.callNameInfo refToVar findField;
    [fr.success copy] "Struct is not callable!" assert

    codeField: fr.index struct.fields.at .refToVar;
    codeVar: codeField getVar;
    codeVar.data.getTag VarCode = [

      needPre: FALSE;
      pfr: processor.preNameInfo refToVar findField;
      pfr.success [
        preField: pfr.index struct.fields.at .refToVar;
        preVar: preField getVar;
        preVar.data.getTag VarCode = [
          VarCode preVar.data.get.index VarCode preVar.data.get.file processPre ~ @needPre set
        ] [
          "PRE field must be a code" block compilerError
        ] if
      ] when

      needPre [
        overloadShift 1 + @overloadShift set

        findInside [
          fr: nameInfo object overloadShift findFieldWithOverloadShift;
          fr.success [
            fr.index @object @block processStaticAt @refToVar set
          ] [
            0 @overloadShift set
            FALSE @findInside set
          ] if
        ] when

        findInside ~ [
          overload: nameInfo getOverloadCount 1 - overloadShift -;
          overload 0 < [
            name: nameInfo processor.nameInfos.at.name makeStringView;
            ("cant call overload for name: " name) assembleString block compilerError
          ] when

          compilable [
            gnr: nameInfo overload getNameWithOverload;
            compilable [
              cnr: @gnr @block captureName;
              cnr.object @object set
              cnr.refToVar @refToVar set
            ] when
          ] when
        ] when

        compilable [
          object refToVar nameInfo [
            TRUE @nextIteration set # for builtin or import go out of loop
          ] callCallable
        ] when
      ] [
        # no need pre, just call it!
        object regNamesSelf
        refToVar regNamesClosure
        VarCode codeVar.data.get.index VarCode codeVar.data.get.file nameInfo processor.nameInfos.at.name makeStringView processCall
        refToVar unregNamesClosure
        object unregNamesSelf
      ] if
    ] [
      "CALL field is not a code" block compilerError
    ] if

    nextIteration [compilable] &&
  ] loop
];

callCallable: [
  predicate:;
  nameInfo:;
  refToVar:;
  object:;

  var: refToVar getVar;
  var.data.getTag VarBuiltin = [
    VarBuiltin var.data.get @block callBuiltin
  ] [
    var.data.getTag VarCode = [
      object regNamesSelf
      VarCode var.data.get.index VarCode var.data.get.file @nameInfo processor.nameInfos.at.name makeStringView processCall
      object unregNamesSelf
    ] [
      var.data.getTag VarImport = [
        refToVar processFuncPtr
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
  refToVar: block:;;
  refToVar getVar.data.getTag VarRef = [
    @refToVar @block getPointee
  ] [
    refToVar copy
  ] if
];

derefAndPush: [
  @block getPossiblePointee @block push
];

tryImplicitLambdaCast: [
  refToSrc: refToDst: block:;;;

  result: {
    success: FALSE dynamic;
    refToVar: RefToVar;
  };

  varSrc: refToSrc getVar;
  varSrc.data.getTag VarCode = [refToDst isVirtual ~] && [
    dstPointee: @refToDst @block getPossiblePointee;
    dstPointeeVar: dstPointee getVar;

    dstPointeeVar.data.getTag VarImport = [
      declarationIndex: VarImport dstPointeeVar.data.get;
      declarationNode: declarationIndex processor.blocks.at.get;
      csignature: declarationNode.csignature;
      implName: ("lambda." block.id "." block.lastLambdaName) assembleString;
      astNode: VarCode refToSrc getVar.data.get.index @multiParserResult.@memory.at;
      implIndex: csignature astNode VarCode refToSrc getVar.data.get.file implName makeStringView TRUE dynamic @block processExportFunction;

      compilable [
        implNode: implIndex processor.blocks.at.get;
        implNode.state NodeStateCompiled = ~ [
          block.state NodeStateHasOutput > [NodeStateHasOutput @block.@state set] when
          dstPointee @result.@refToVar set
          TRUE dynamic @result.@success set
        ] when

        implNode.varNameInfo 0 < ~ [
          gnr: implNode.varNameInfo @block File Ref getName;
          compilable ~ [
            [FALSE] "Name of new lambda is not visible!" assert
          ] [
            cnr: @gnr @block captureName;
            cnr.refToVar @result.@refToVar set
            TRUE dynamic @result.@success set
          ] if
        ] when
      ] when

      block.lastLambdaName 1 + @block.@lastLambdaName set
    ] when
  ] when

  result
];

setRef: [
  compileOnce
  refToVar:; # destination
  var: refToVar getVar;
  var.data.getTag VarRef = [
    refToVar isSchema [
      "can not write to virtual" block compilerError
    ] [
      pointee: VarRef var.data.get;
      pointee.mutable ~ [
        FALSE @block defaultMakeConstWith #source
      ] when

      compilable [
        src: @block pop;
        compilable [
          src pointee variablesAreSame [
            src @block push
            TRUE @block defaultRef #source
            refToVar @block push
            @block defaultSet
          ] [
            src @block push
            refToVar @block push
            @block defaultSet
          ] if
        ] when
      ] when
    ] if
  ] [
    #rewrite value case!
    src: @block pop;
    compilable [
      src getVar.temporary [
        src @block push
        refToVar @block push
        @block defaultSet
      ] [
        "rewrite value works only with temporary values" block compilerError
      ] if
    ] when
  ] if
];

copyOneVarWith: [
  src: toNew: block:;;;
  dst: RefToVar;
  srcVar: src getVar;

  checkedStaticityOfVar: [
    toNew [staticityOfVar Dynamic maxStaticity] [staticityOfVar] if
  ];

  srcVar.data.getTag VarStruct = [
    srcStruct: VarStruct srcVar.data.get.get;
    # manually copy only nececcary fields
    dstStruct: Struct;
    srcStruct.fields          @dstStruct.@fields set
    @dstStruct move owner VarStruct src isVirtual src isSchema FALSE dynamic @block createVariableWithVirtual
    src checkedStaticityOfVar block makeStaticity @dst set
    dstStructAc: VarStruct @dst getVar.@data.get.get;
    srcStruct.homogeneous       @dstStructAc.@homogeneous set
    srcStruct.fullVirtual       @dstStructAc.@fullVirtual set
    srcStruct.hasPreField       @dstStructAc.@hasPreField set
    srcStruct.hasDestructor     @dstStructAc.@hasDestructor set
    srcStruct.realFieldIndexes  @dstStructAc.@realFieldIndexes set
    srcStruct.structAlignment   @dstStructAc.@structAlignment set
    srcStruct.structStorageSize @dstStructAc.@structStorageSize set
  ] [
    srcVar.data.getTag VarInvalid VarEnd [
      copy tag:;
      tag VarStruct = ~ [
        tag srcVar.data.get tag src isVirtual src isSchema FALSE dynamic @block createVariableWithVirtual
        src checkedStaticityOfVar block makeStaticity
        @dst set
      ] when
    ] staticCall

    srcVar.data.getTag VarRef = [srcVar.shadowBegin @dst getVar.@shadowBegin set] when  #for ttest48
  ] if

  src.mutable @dst.setMutable
  dstVar: @dst getVar;
  srcVar.mplSchemaId @dstVar.@mplSchemaId set

  dst
];

copyVarImpl: [
  refToVar: fromChildToParent: toNew: block:;;;;
  fromChildToParent toNew or [refToVar noMatterToCopy refToVar isUnallocable or] && [
    refToVar copy
  ] [
    result: RefToVar;
    uncopiedSrc: RefToVar Array;
    uncopiedDst: RefToVar AsRef Array;

    refToVar @uncopiedSrc.pushBack
    @result AsRef @uncopiedDst.pushBack

    i: 0 dynamic;
    [
      i uncopiedSrc.dataSize < [
        currentSrc: i uncopiedSrc.at copy;
        currentDst: i @uncopiedDst.at.@data;

        fromChildToParent toNew or [currentSrc noMatterToCopy] && [
          currentSrc @currentDst set
        ] [
          currentSrc toNew @block copyOneVarWith @currentDst set

          currentSrcVar: currentSrc getVar;
          currentDstVar: @currentDst getVar;
          currentSrcVar.data.getTag VarStruct = [
            branchSrc: VarStruct currentSrcVar.data.get.get;
            branchDst: VarStruct @currentDstVar.@data.get.get;
            f: 0 dynamic;
            [
              f branchSrc.fields.dataSize < [
                fromChildToParent [
                  f branchSrc.fields.at.refToVar @uncopiedSrc.pushBack
                ] [
                  f @currentSrc @block getField @uncopiedSrc.pushBack
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

    @result
  ] if
];

copyOneVar: [block:; FALSE dynamic @block copyOneVarWith];

copyVar:           [block:; FALSE FALSE dynamic @block copyVarImpl]; #fromchild is static arg
copyVarFromChild:  [block:; TRUE  FALSE dynamic @block copyVarImpl];
copyVarToNew:      [block:; FALSE TRUE  dynamic @block copyVarImpl];
copyVarFromParent: [TRUE  FALSE dynamic @block copyVarImpl];

{
  dynamicStoraged: Cond;

  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  block: Block Ref;
  multiParserResult: MultiParserResult Cref;

  reason: Nat8;
  end: RefToVar Ref;
  begin: RefToVar Ref;
  refToVar: RefToVar Cref;
} () {convention: cdecl;} [
  copy dynamicStoraged:;

  processorResult:;
  processor:;
  block:;
  multiParserResult:;
  failProc: @failProcForProcessor;

  copy reason:;
  end:;
  begin:;
  refToVar:;

  compileOnce

  refToVar noMatterToCopy [
    refToVar @begin set
    refToVar @end set
  ] [
    var: refToVar getVar;
    head: var.capturedHead copy;
    headVar: @head getVar;

    reallyCreateShadows: [
      shadowSrc: headVar.capturedTail copy;
      refToVar.mutable @shadowSrc.setMutable

      shadowSrc @block copyOneVar @begin set
      shadowSrc @block copyOneVar @end set

      beginVar: @begin getVar;
      endVar: @end getVar;
      global: refToVar isGlobal;

      var.storageStaticity @beginVar.@storageStaticity set
      var.storageStaticity @endVar  .@storageStaticity set

      global [
        reason ShadowReasonField = ~ [
          var.irNameId @endVar.@irNameId set
        ] when

        TRUE @beginVar.@global set
        TRUE @endVar.@global set

      ] [
        @begin block unglobalize
        @end   block unglobalize
      ] if

      begin @endVar  .@shadowBegin set
      end   @beginVar.@shadowEnd   set

      var.globalId @beginVar.@globalId set
      var.globalId   @endVar.@globalId set
      var.globalDeclarationInstructionIndex @beginVar.@globalDeclarationInstructionIndex set
      var.globalDeclarationInstructionIndex   @endVar.@globalDeclarationInstructionIndex set

      reason @beginVar.@shadowReason set
      reason   @endVar.@shadowReason set

      # add info  to linked list, link to end (changed value)
      headVar.capturedTail @endVar.@capturedPrev set # newTail->oldTail
      end                 @headVar.@capturedTail set # head->newTail
      head                 @endVar.@capturedHead set # newTail->head
      head               @beginVar.@capturedHead set # newTail->head
      end @block.@capturedVars.pushBack       # remember
    ];

    dynamicStoraged [
      reallyCreateShadows
    ] [
      headVar.capturedTail getVar.host block is [
        headVar.capturedTail @end set
        end getVar.shadowBegin @begin set

        refToVar.mutable @begin.setMutable
        refToVar.mutable @end.setMutable

        beginVar: @begin getVar;
        endVar: @end getVar;
        reason beginVar.shadowReason < [
          reason @beginVar.@shadowReason set
          reason @endVar  .@shadowReason set
        ] when

        [begin getVar.host block is] "Begin hostId incorrect in makeShadows!" assert
        [end getVar.host block is] "End hostId incorrect in makeShadows!" assert
      ] [
        reallyCreateShadows
      ] if
    ] if
  ] if
] "makeShadowsImpl" exportFunction

makeShadows: [
  block:;
  multiParserResult @block @processor @processorResult
  FALSE makeShadowsImpl
];

makeShadowsDynamic: [
  block:;
  multiParserResult @block @processor @processorResult
  TRUE  makeShadowsImpl
];

addStackUnderflowInfo: [
  block:;
  TRUE @block.@buildingMatchingInfo.@hasStackUnderflow set
  block.state NodeStateNew = [
    TRUE @block.@matchingInfo.@hasStackUnderflow set
  ] when
];

{
  forMatching: Cond;
  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  block: Block Ref;
  multiParserResult: MultiParserResult Cref;
  result: RefToVar Ref;
} () {convention: cdecl;} [
  copy forMatching:;
  processorResult:;
  processor:;
  block:;
  multiParserResult:;
  failProc: @failProcForProcessor;
  result:;

  block.stack.dataSize 0 = [
    entryRef: 0 block getStackEntry;
    compilable [
      entry: entryRef copy;
      entry staticityOfVar Weak = [
        @entry Dynamic block makeStaticity @entry set
      ] when

      shadowBegin: RefToVar;
      shadowEnd:   RefToVar;

      entry @shadowBegin @shadowEnd ShadowReasonInput @block makeShadows

      shadowEnd @result set
      entry isForgotten [
        @shadowBegin untemporize
        @shadowEnd   untemporize
      ] [
        @shadowBegin fullUntemporize
        @shadowEnd   fullUntemporize
      ] if

      [result noMatterToCopy [result getVar.host block is] ||] "Shadow host incorrect!" assert
      result.mutable [TRUE @result getVar.@capturedAsMutable set] when

      result getVar.data.getTag VarRef = [
        # it is for exports only
        # we have immutable reference, becouse it is a rule of signature
        # after deref we must force mutability
        mutableOfPointee: VarRef result getVar.data.get.mutable;
        @result @block getPointee @result set
        mutableOfPointee @result.setMutable
      ] when

      newInput: Argument;

      result @newInput.@refToVar set
      ArgRef @newInput.@argCase set

      entry isGlobal [ArgGlobal @newInput.@argCase set] when

      #add input
      newInput @block.@buildingMatchingInfo.@inputs.pushBack
      block.state NodeStateNew = [
        result noMatterToCopy ~ [
          result getVar.shadowBegin @newInput.@refToVar set
        ] when
        newInput @block.@matchingInfo.@inputs.pushBack
      ] when
    ] [
      @block addStackUnderflowInfo
    ] if
  ] [
    block.stack.last @result set
    @block.@stack.popBack
  ] if
] "popImpl" exportFunction

pop: [
  block:;
  result: RefToVar;
  @result multiParserResult @block @processor @processorResult FALSE popImpl
  @result
];

popForMatching: [
  result: RefToVar;
  @result multiParserResult @block @processor @processorResult TRUE popImpl
  result
];

pushName: [
  copy nameInfo:;
  copy read:;
  copy refToVar:;
  object:;

  read -1 = [
    refToVar setRef
  ] [
    refToVar isVirtual [@refToVar makeVirtualVarReal @refToVar set] when

    read 1 = [
      @refToVar derefAndPush
    ] [
      possiblePointee: @refToVar @block getPossiblePointee;
      possiblePointee isCallable [
        object possiblePointee nameInfo [object possiblePointee @nameInfo callCallableStructWithPre] callCallable
      ] [
        FALSE dynamic @possiblePointee.setMutable
        possiblePointee @block push
      ] if
    ] if
  ] if
];

addUnfoundedName: [
  copy nameInfo:;
  fr: nameInfo block.matchingInfo.unfoundedNames.find;
  fr.success ~ [nameInfo TRUE @block.@matchingInfo.@unfoundedNames.insert] when
  block.state NodeStateNew = [
    fr: nameInfo block.buildingMatchingInfo.unfoundedNames.find;
    fr.success ~ [nameInfo TRUE @block.@buildingMatchingInfo.@unfoundedNames.insert] when
  ] when
];

checkFailedName: [
  gnr:;
  copy nameInfo:;

  gnr.refToVar.assigned ~ [
    nameInfo addUnfoundedName
  ] when
];

addNamesFromFile: [
  nameInfo: file:;;
  file isNil ~ [file.rootBlock isNil ~ [nameInfo.stack.getSize 0 = [nameInfo.stack.last.getSize 0 =] ||] &&] && [
    file.rootBlock.fromModuleNames [
      label:;
      label.nameInfo data.nameInfo = [
        label.refToVar isVirtual [
          label.nameInfo label.refToVar addOverloadForPre
          label.nameInfo label.refToVar NameCaseFromModule addNameInfo
        ] when

        label.refToVar getVar.data.getTag VarImport = [
          label.nameInfo VarImport label.refToVar getVar.data.get VarImport @block createVariable NameCaseLocal addNameInfo
        ] when
      ] when
    ] each

    file.rootBlock.labelNames [
      label:;
      label.nameInfo data.nameInfo = [
        label.refToVar isVirtual [
          label.nameInfo label.refToVar addOverloadForPre
          label.nameInfo label.refToVar NameCaseFromModule addNameInfo
        ] when

        label.refToVar getVar.data.getTag VarImport = [
          label.nameInfo VarImport label.refToVar getVar.data.get VarImport @block createVariable NameCaseLocal addNameInfo
        ] when
      ] when
    ] each
  ] when
];

processNameNode: [
  data: file:;;
  data.nameInfo processor.nameInfos.at file addNamesFromFile
  gnr: data.nameInfo @block file getName;
  data.nameInfo gnr checkFailedName
  cnr: @gnr @block captureName;
  refToVar: cnr.refToVar copy;

  compilable [
    cnr.object refToVar 0 data.nameInfo pushName
  ] when
];

processNameReadNode: [
  data: file:;;
  data.nameInfo processor.nameInfos.at file addNamesFromFile
  gnr: data.nameInfo @block File Ref getName;
  data.nameInfo gnr checkFailedName
  cnr: @gnr @block captureName;
  refToVar: cnr.refToVar;

  compilable [
    var: refToVar getVar;
    var.data.getTag VarBuiltin = [
      "can't use @name for builtins, use [name] instead" block compilerError
    ] [
      var.data.getTag VarImport = [
        RefToVar refToVar 1 data.nameInfo pushName
      ] [
        RefToVar refToVar 1 data.nameInfo pushName
      ] if
    ] if
  ] when
];

processNameWriteNode: [
  data: file:;;
  data.nameInfo processor.nameInfos.at file addNamesFromFile
  gnr: data.nameInfo @block File Ref getName;
  data.nameInfo gnr checkFailedName
  cnr: @gnr @block captureName;
  refToVar: cnr.refToVar;

  compilable [refToVar setRef] when
];

processStaticAt: [
  index: refToStruct: block:;;;
  fieldRef: index @refToStruct @block getField;

  compilable [
    fieldVar: fieldRef getVar;
    fieldRef isVirtual [
      @fieldRef block unglobalize
    ] [
      [refToStruct isVirtual ~] "fields of virtual struct must be virtual!" assert
      @fieldRef block unglobalize
      @fieldRef index refToStruct @block createCheckedStaticGEP
    ] if

    @fieldRef fullUntemporize
    fieldRef copy
  ] [
    RefToVar
  ] if
];

processMember: [
  copy read:;
  copy refToStruct:;
  nameInfo:;

  compilable [
    fieldError: [
      (refToStruct block getMplType " has no field " nameInfo processor.nameInfos.at.name) assembleString block compilerError
    ];

    refToStruct isSchema [
      read -1 = [
        "can not write to field of struct schema" block compilerError
      ] [
        structVar: refToStruct getVar;
        pointee: VarRef structVar.data.get;
        pointeeVar: pointee getVar;
        pointeeVar.data.getTag VarStruct = [
          fr: nameInfo pointee findField;
          fr.success [
            index: fr.index copy;
            field: index 0 cast VarStruct pointeeVar.data.get.get.fields.at.refToVar;
            result: field VarRef TRUE dynamic TRUE dynamic TRUE dynamic @block createVariableWithVirtual;
            @result fullUntemporize
            read 1 = result.mutable and @result.setMutable
            result @block push
          ] [
            fieldError
          ] if
        ] [
          "not a combined" block compilerError
        ] if
      ] if
    ] [
      refToStruct getVar.data.getTag VarStruct = [
        fr: nameInfo refToStruct findField;
        fr.success [
          index: fr.index copy;
          fieldRef: index @refToStruct @block processStaticAt;
          refToStruct fieldRef read nameInfo pushName # let it be marker about field
        ] [
          fieldError
        ] if
      ] [
        "not a combined" block compilerError
      ] if
    ] if
  ] when
];

processNameMemberNode: [.nameInfo @block pop 0 dynamic processMember];
processNameReadMemberNode: [.nameInfo @block pop 1 dynamic processMember];
processNameWriteMemberNode: [.nameInfo @block pop -1 dynamic processMember];

processStringNode: [@block makeVarString @block push];
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

addDebugLocationForLastInstruction: [
  block:;
  processor.options.debug [
    instruction: @block.@program.last;
    instruction.codeSize 0 >
    [instruction.codeOffset instruction.codeSize 1 - + block.programTemplate.chars.at 58n8 =  ~] && # label detector, code of ":"
    [block.position.line 0 < ~] &&
    [
      @block.@programTemplate.makeNZ
      offset: block.programTemplate.chars.getSize;

      offset instruction.codeSize + @block.@programTemplate.@chars.enlarge # Make sure the string can be copied without relocation
      offset @block.@programTemplate.@chars.shrink
      block.programTemplate.getStringView instruction.codeOffset instruction.codeSize view @block.@programTemplate.catStringNZ

      @block.@programTemplate.makeZ

      locationIndex: block.position block.funcDbgIndex addDebugLocation;
      (", !dbg !" locationIndex) @block.@programTemplate.catMany

      offset copy @instruction.!codeOffset
      block.programTemplate.getTextSize offset - @instruction.!codeSize
    ] when
  ] when
];

addBlock: [
  Block owner @processor.@blocks.pushBack
  processor.blocks.getSize 1 - @processor.@blocks.last.get.!id
];

argAbleToCopy: [
  arg:;
  arg isTinyArg
];

argRecommendedToCopy: [
  arg:;
  arg.mutable ~ [arg argAbleToCopy] && [arg getVar.capturedAsMutable ~] &&
];

callInit: [
  copy refToVar:;
  compilable [
    uninited: RefToVar Array;
    refToVar isVirtual ~ [refToVar makeVarTreeDynamic] when
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
                f @current @block processStaticAt @uninited.pushBack
              ] when
            ] &&
          ] loop
        ] when
        i 1 + @i set compilable
      ] &&
    ] loop

    i: uninited.dataSize copy dynamic;
    [
      i 0 > [
        i 1 - @i set
        current: i @uninited.at;
        current getVar.data.getTag VarStruct = [
          fr: processor.dieNameInfo current findField;
          fr.success [
            fr: processor.initNameInfo current findField;
            fr.success [
              index: fr.index copy;
              fieldRef: index @current @block processStaticAt;
              initName: processor.initNameInfo processor.nameInfos.at.name makeStringView;
              stackSize: block.stack.dataSize copy;
              fieldRef getVar.data.getTag VarCode = [
                current fieldRef @initName callCallableField
                compilable [block.state NodeStateNoOutput = ~] && [block.stack.dataSize stackSize = ~] && [
                  ("Struct " current block getMplType "'s INIT method dont save stack") assembleString block compilerError
                ] when
              ] [
                ("Struct " current block getMplType "'s INIT method is not a CODE") assembleString block compilerError
              ] if
            ] [
              ("Struct " current block getMplType " is automatic, but has not INIT field") assembleString block compilerError
            ] if
          ] when
        ] when
        compilable [block.state NodeStateNoOutput = ~] &&
      ] &&
    ] loop
  ] when
];

callAssign: [
  refToDst:;
  refToSrc:;
  compilable [
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
        curDst: @unfinishedDst.last copy;
        [curSrc curDst variablesAreSame] "Assign vars must have same type!" assert
        @unfinishedSrc.popBack
        @unfinishedDst.popBack
        curSrcVar: curSrc getVar;
        curDstVar: curDst getVar;

        curSrcVar.data.getTag VarStruct = [
          fr: processor.dieNameInfo curSrc findField;
          fr.success [
            fr: processor.assignNameInfo curSrc findField;
            fr.success [
              index: fr.index copy;
              fieldRef: index @curSrc @block processStaticAt;
              assignName: processor.assignNameInfo processor.nameInfos.at.name makeStringView;
              stackSize: block.stack.dataSize copy;

              fieldRef getVar.data.getTag VarCode = [
                curDst isVirtual [
                  "unable to copy virtual autostruct" block compilerError
                ] [
                  curSrc @block push
                  curDst fieldRef @assignName callCallableField
                  compilable [block.state NodeStateNoOutput = ~] && [block.stack.dataSize stackSize = ~] && [
                    ("Struct " curSrc block getMplType "'s ASSIGN method dont save stack") assembleString block compilerError
                  ] when
                ] if
              ] [
                ("Struct " curSrc block getMplType "'s ASSIGN method is not a CODE") assembleString block compilerError
              ] if
            ] [
              ("Struct " curSrc block getMplType " is automatic, but has not ASSIGN field") assembleString block compilerError
            ] if
          ] [
            structSrc: VarStruct curSrcVar.data.get.get;
            structDst: VarStruct curDstVar.data.get.get;
            f: 0 dynamic;
            [
              f structSrc.fields.dataSize < [
                srcField: f @curSrc @block processStaticAt;
                srcField @unfinishedSrc.pushBack
                f @curDst @block processStaticAt @unfinishedDst.pushBack
                f 1 + @f set TRUE
              ] &&
            ] loop
          ] if
        ] [
          curSrc curDst @block createMemset
        ] if
        compilable [block.state NodeStateNoOutput = ~] &&
      ] &&
    ] loop
  ] when
];

callDie: [
  copy refToVar:;
  compilable [
    unkilled: RefToVar Array;
    @refToVar fullUntemporize
    TRUE dynamic @refToVar.setMutable
    refToVar @unkilled.pushBack

    [
      unkilled.dataSize 0 > [
        last: unkilled.last copy;
        @unkilled.popBack
        last getVar.data.getTag VarStruct = [
          struct: VarStruct last getVar.data.get.get;
          fr: processor.dieNameInfo last findField;
          fr.success [
            index: fr.index copy;
            fieldRef: index @last @block processStaticAt;
            dieName: processor.dieNameInfo processor.nameInfos.at.name makeStringView;
            stackSize: block.stack.dataSize copy;

            fieldRef getVar.data.getTag VarCode = [
              last fieldRef @dieName callCallableField
              compilable [block.state NodeStateNoOutput = ~] && [block.stack.dataSize stackSize = ~] && [
                ("Struct " last block getMplType "'s DIE method dont save stack") assembleString block compilerError
              ] when
            ] [
              ("Struct " last block getMplType "'s DIE method is not a CODE") assembleString block compilerError
            ] if
          ] when

          f: 0 dynamic;
          [
            f struct.fields.dataSize < [
              f struct.fields.at.refToVar isAutoStruct [
                f @last @block processStaticAt @unkilled.pushBack
              ] when
              f 1 + @f set TRUE
            ] &&
          ] loop
        ] when
        compilable [block.state NodeStateNoOutput = ~] &&
      ] &&
    ] loop
  ] when
];

killStruct: [
  refToVar:;
  [refToVar getVar.data.getTag VarStruct =] "Destructors works only for structs!" assert
  VarStruct refToVar getVar.data.get.get.unableToDie ~ [
    refToVar callDie
  ] when
];

{
  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  block: Block Ref;
  multiParserResult: MultiParserResult Cref;
  file: File Cref;
  indexOfAstNode: Int32;
  astNode: AstNode Cref;
} () {} [
  processorResult:;
  processor:;
  block:;
  multiParserResult:;
  failProc: @failProcForProcessor;
  file:;
  indexOfAstNode:;
  astNode:;

  processor.options.verboseIR [
    ("filename: " block.position.file.name
      ", line: " block.position.line ", column: " block.position.column ", token: " astNode.token) assembleString @block createComment
  ] when

  programSize: block.program.dataSize copy;

  (
    AstNodeType.Code            [drop indexOfAstNode file processCodeNode]
    AstNodeType.Label           [@block processLabelNode]
    AstNodeType.List            [file processListNode]
    AstNodeType.Name            [file processNameNode]
    AstNodeType.NameMember      [processNameMemberNode]
    AstNodeType.NameRead        [file processNameReadNode]
    AstNodeType.NameReadMember  [processNameReadMemberNode]
    AstNodeType.NameWrite       [file processNameWriteNode]
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
    AstNodeType.Object          [file processObjectNode]
    AstNodeType.Real32          [processReal32Node]
    AstNodeType.Real64          [processReal64Node]
    AstNodeType.String          [processStringNode]
  ) astNode.data.visit

  block.program.dataSize programSize > [
    @block addDebugLocationForLastInstruction
  ] when
] "processNodeImpl" exportFunction

processNode: [
  token: tokenIndex: file:;;;
  token tokenIndex file multiParserResult @block @processor @processorResult processNodeImpl
];

addNamesFromModule: [
  copy moduleId:;

  fru: moduleId block.usedOrIncludedModulesTable.find;
  fru.success ~ [
    moduleId TRUE @block.@usedOrIncludedModulesTable.insert

    moduleNode: moduleId processor.blocks.at.get;
    moduleNode.labelNames [
      current:;
      current.nameInfo current.refToVar addOverloadForPre
      current.nameInfo current.refToVar NameCaseFromModule addNameInfo #it is not own local variable
    ] each
  ] when
];

processUseModule: [
  copy asUse:;
  copy moduleId:;

  currentModule: moduleId processor.blocks.at.get;
  moduleList: currentModule.includedModules copy;
  moduleId @moduleList.pushBack

  moduleList.getSize [
    current: i moduleList.at;
    last: i moduleList.getSize 1 - =;

    asUse [last copy] && [
      current {used: FALSE dynamic; position: block.position copy;} @block.@usedModulesTable.insert
      current TRUE @block.@directlyIncludedModulesTable.insert
      current addNamesFromModule
    ] [
      fr: current block.includedModulesTable.find;
      fr.success ~ [
        last [
          current TRUE @block.@directlyIncludedModulesTable.insert
        ] when
        current @block.@includedModules.pushBack
        current {used: FALSE dynamic; position: block.position copy;} @block.@includedModulesTable.insert
        current addNamesFromModule
      ] when
    ] if
  ] times
];

finalizeListNode: [
  struct: Struct;
  compilable [
    i: 0 dynamic;
    [
      i block.stack.dataSize < [
        curRef: i @block.@stack.at;

        newField: Field;
        processor.emptyNameInfo @newField.@nameInfo set

        curRef getVar.temporary [
          curRef @newField.@refToVar set
        ] [
          @curRef TRUE dynamic @block createRef @newField.@refToVar set
        ] if

        newField @struct.@fields.pushBack
        i 1 + @i set compilable
      ] &&
    ] loop
  ] when

  compilable [
    refToStruct: @struct move owner VarStruct @block createVariable;
    struct: VarStruct @refToStruct getVar.@data.get.get;

    refToStruct isVirtual ~ [
      @refToStruct @block createAllocIR @refToStruct set
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
          staticity Virtual = ~ [@curFieldRef staticity block makeStaticity drop] when
          @curFieldRef i refToStruct @block createGEPInsteadOfAlloc
        ] if

        i 1 + @i set compilable
      ] &&
    ] loop

    @block.@stack.clear
    refToStruct @block.@stack.pushBack
  ] when
];

finalizeObjectNode: [
  refToStruct: @block.@struct move owner VarStruct @block createVariable;
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
    @refToStruct @block createAllocIR drop
    i: 0 dynamic;
    [
      i structInfo.fields.dataSize < [
        dstFieldRef: i @structInfo.@fields.at.@refToVar;

        [dstFieldRef staticityOfVar Weak = ~] "Field label is weak!" assert
        [dstFieldRef noMatterToCopy [dstFieldRef getVar.host block is] ||] "field host incorrect" assert
        dstFieldRef isVirtual ~ [
          [dstFieldRef getVar.allocationInstructionIndex block.program.dataSize <] "field is not allocated" assert
          @dstFieldRef i refToStruct @block createGEPInsteadOfAlloc
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
      nameWithOverload.nameOverload nameWithOverload.nameInfo deleteNameInfoWithOverload
    ] each
  ];

  @block.@labelNames unregisterNamesIn
  @block.@fromModuleNames unregisterNamesIn
  @block.@fieldCaptureNames unregisterNamesIn

  @block.@fieldCaptureNames.release

  @block.@capturedVars [
    curVar: getVar;
    curVar.capturedPrev @curVar.@capturedHead getVar.@capturedTail set # head->prev of tail
  ] each

  @block.@capturedVars.release
  @block.@usedModulesTable.release
  @block.@includedModulesTable.release
  @block.@directlyIncludedModulesTable.release
  @block.@captureTable.release
  @block.@fieldCaptureTable.release
];

checkPreStackDepth: [
  newMinStackDepth: block getStackDepth block.stack.dataSize -;
  preCountedStackDepth: block.minStackDepth copy;
  i: preCountedStackDepth copy;
  [
    i newMinStackDepth < [
      preInputDepth: i preCountedStackDepth - block.stack.dataSize +;
      preInput: preInputDepth getStackEntryForPreInput;
      preInput.assigned [
        preInput noMatterToCopy ~ [preInput getVar.shadowBegin @preInput set] when
        [preInput.assigned] "Invalid preInput!" assert
      ] when
      preInput @block.@buildingMatchingInfo.@preInputs.pushBack
      i 1 + @i set TRUE
    ] &&
  ] loop
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
              i deleteNode
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
          curToNested: RefToVarTable;
          nestedToCur: RefToVarTable;
          comparingMessage: String;
          currentMatchingNodeIndex: block.id copy;
          currentMatchingNode: currentMatchingNodeIndex @processor.@blocks.at.get;

          compareShadows: [
            refToVar2:;
            refToVar1:;
            se1: refToVar1 noMatterToCopy [refToVar1][refToVar1 getVar.shadowEnd] if;
            se2: refToVar2 noMatterToCopy [refToVar2][refToVar2 getVar.shadowEnd] if;
            [se1.assigned [se2.assigned] &&] "variables has no shadowEnd!" assert
            se1 se2 compareEntriesRec
          ];

          #compare inputs
          result [
            block.matchingInfo.inputs.getSize block.buildingMatchingInfo.inputs.getSize = ~ [
              FALSE @result set
            ] when

            result [
              i: 0 dynamic;
              [
                i block.matchingInfo.inputs.getSize < [
                  current1: i block.matchingInfo.inputs.at.refToVar;
                  current2: i block.buildingMatchingInfo.inputs.at.refToVar;
                  current1 current2 compareShadows ~ [
                    FALSE @result set
                  ] when
                  i 1 + @i set
                  result copy
                ] &&
              ] loop
            ] when
          ] when

          #compare captures
          result [
            block.matchingInfo.captures.getSize block.buildingMatchingInfo.captures.getSize = ~ [
              FALSE @result set
            ] when

            result [
              i: 0 dynamic;
              [
                i block.matchingInfo.captures.getSize < [
                  capture1: i block.matchingInfo.captures.at;
                  capture2: i block.buildingMatchingInfo.captures.at;

                  capture1.captureCase capture2.captureCase =
                  [capture1.nameInfo capture2.nameInfo =] &&
                  [capture1.nameOverload capture2.nameOverload =] &&
                  [capture1.cntNameOverload capture2.cntNameOverload =] &&
                  [capture1.refToVar capture2.refToVar compareShadows] && ~ [
                    FALSE @result set
                  ] when
                  i 1 + @i set
                  result copy
                ] &&
              ] loop
            ] when
          ] when

          #compare fieldCaptures
          result [
            block.matchingInfo.fieldCaptures.getSize block.buildingMatchingInfo.fieldCaptures.getSize = ~ [
              FALSE @result set
            ] when

            result [
              i: 0 dynamic;
              [
                i block.matchingInfo.fieldCaptures.getSize < [
                  capture1: i block.matchingInfo.fieldCaptures.at;
                  capture2: i block.buildingMatchingInfo.fieldCaptures.at;

                  capture1.captureCase capture2.captureCase =
                  [capture1.nameInfo capture2.nameInfo =] &&
                  [capture1.nameOverload capture2.nameOverload =] &&
                  [capture1.cntNameOverload capture2.cntNameOverload =] &&
                  [capture1.cntNameOverloadParent capture2.cntNameOverloadParent =] && ~ [
                    FALSE @result set
                  ] when
                  i 1 + @i set
                  result copy
                ] &&
              ] loop
            ] when
          ] when

          #compareOutputs
          result [
            block.stack.getSize block.outputs.getSize = ~ [
              FALSE @result set
            ] when

            result [
              i: 0 dynamic;
              [
                i block.stack.getSize < [
                  current1: i block.stack.at;
                  current2: i block.outputs.at.refToVar;
                  current1 current2 compareEntriesRec ~ [
                    FALSE @result set
                  ] when
                  i 1 + @i set
                  result copy
                ] &&
              ] loop
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

  block.buildingMatchingInfo @block.@matchingInfo set
  clearBuildingMatchingInfo [
    MatchingInfo @block.@buildingMatchingInfo set
    0            @block.@lastLambdaName set
  ] when
];

makeCompilerPosition: [
  astNode: file:;;
  result: CompilerPositionInfo;

  file                @result.@file.set
  astNode.line   copy @result.!line
  astNode.column copy @result.!column
  astNode.token  copy @result.!token

  result
];

{
  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  block: Block Ref;
  multiParserResult: MultiParserResult Cref;
  forcedSignature: CFunctionSignature Cref;
  compilerPositionInfo: CompilerPositionInfo Cref;
  functionName: StringView Cref;
} () {convention: cdecl;} [
  processorResult:;
  processor:;
  block:;
  multiParserResult:;
  failProc: @failProcForProcessor;
  forcedSignature:;
  compilerPositionInfo:;
  functionName:;

  block.nextLabelIsVirtual ["unused virtual specifier" block compilerError] when
  block.nextLabelIsSchema["unused schema specifier" block compilerError] when

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
        refForArg: refToVar VarRef @block createVariable;
        refToVar @refForArg @block createRefOperation
        refForArg TRUE
      ] [
        copyForArg: refToVar @block copyVarToNew;
        TRUE dynamic @copyForArg.setMutable
        @refToVar @copyForArg @block createCopyToNew
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
    copy refToVar:;
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
        copyForArg: refToVar @block copyOneVar;
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
      refToVar getIrType        @argumentList.cat
      asCopy ~ ["*"           @argumentList.cat] when

      signature.chars.dataSize 0 > [", " makeStringView @signature.cat] when
      refToVar getIrType        @signature.cat
      asCopy ~ ["*"           @signature.cat] when

      isDeclaration ~ [
        " "        makeStringView @argumentList.cat
        regNameId getNameById     @argumentList.cat
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
        copyForArg: refToVar @block copyVarToNew;
        TRUE dynamic @copyForArg.setMutable
        @refToVar @copyForArg @block createCopyToNew
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
          refToVar @processorResult @processor multiParserResult compilerPositionInfo CFunctionSignature createDtorForGlobalVar
        ] when
      ] each
    ] [
      retInstructionIndex: block.program.dataSize 1 -;
      i: block.candidatesToDie.dataSize copy dynamic;
      [
        i 0 > [
          i 1 - @i set
          current: i @block.@candidatesToDie.at;
          current killStruct
          compilable
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
    ("In signature there are " forcedSignature.inputs.getSize " inputs, but really here " block.buildingMatchingInfo.inputs.getSize " inputs") assembleString block compilerError
  ];

  hasForcedSignature [
    block.buildingMatchingInfo.inputs.getSize forcedSignature.inputs.getSize = ~ [
      block.buildingMatchingInfo.inputs.getSize 1 + forcedSignature.inputs.getSize =
      [forcedSignature.outputs.getSize 0 >] &&
      [0 forcedSignature.outputs.at forcedSignature.inputs.last variablesAreSame] && [
        #todo for MPL signature check each
        @block pop @block push
      ] [
        inputCountMismatch
      ] if
    ] when

    forcedSignature @block.@csignature set
  ] when

  compilable [
    i: 0 dynamic;
    [
      i block.buildingMatchingInfo.inputs.dataSize < [
        # const to plain make copy
        current: i @block.@buildingMatchingInfo.@inputs.at;

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
              "getting huge agrument by copy; mpl's export function can not have this signature" block compilerError
            ] when

            needToCopy [
              regNameId: @block generateRegisterIRName;
              ArgCopy @current.@argCase set
              current.refToVar regNameId addCopyArg

              current.refToVar getVar.allocationInstructionIndex 0 < [
                regNameId @current.@refToVar @block createAllocIR @block createStoreFromRegister
                TRUE @block.@program.last.@alloca set #fake for good sotring
              ] when
            ] [
              ArgRef @current.@argCase set
              current.refToVar FALSE addRefArg
            ] if
          ] if
        ] if

        i 1 + @i set compilable
      ] &&
    ] loop
  ] when

  block.parent 0 =
  [block.stack.dataSize 0 >] && [
    "module can not have inputs or outputs" block compilerError
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
          "returning two arguments or non-primitive object; mpl's function can not have this signature" block compilerError
        ] when

        compilable [
          passAsRet [
            refDeref [ArgReturnDeref] [ArgReturn] if @newArg.@argCase set
            TRUE @hasRet set
            output addRetArg
            output @retRef set
            output getIrType toString @retType set
          ] [
            output captureEntireStruct

            output addOutputArg
            refDeref [ArgRefDeref] [ArgRef] if @newArg.@argCase set
          ] if
        ] when
        output @newArg.@refToVar set
      ] if

      newArg @block.@outputs.pushBack
      i 1 + @i set compilable
    ] &&
  ] loop

  hasRet [
    retRef @block createRetValue
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
            ("real function can not have local capture; name=" current.nameInfo processor.nameInfos.at.name "; type=" current.refToVar block getMplType) assembleString block compilerError
          ] when

          current.refToVar FALSE addRefArg
        ] [
          current.argCase ArgGlobal = [
            TRUE @hasEffect set
          ] when
        ] if

        current.refToVar getVar.data.getTag VarImport = [TRUE @hasImport set] when
      ] when
      i 1 + @i set compilable
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
      "export function cannot be variadic" block compilerError
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
        nameWithOverload.nameInfo processor.nameInfos.at.name @s.cat
        nameWithOverload.nameOverload 0 > [
          ("(" nameWithOverload.nameOverload ")") @s.catMany
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

  @block addDebugLocationForLastInstruction
  checkPreStackDepth

  fixArrShadows: [
    [
      current:;
      current.refToVar.assigned [current.refToVar noMatterToCopy ~] && [current.refToVar getVar.shadowBegin @current.@refToVar set] when
    ] each
  ];

  @block.@buildingMatchingInfo.@inputs fixArrShadows
  @block.@buildingMatchingInfo.@captures fixArrShadows

  processor.options.verboseIR [
    info: String;
    "labelNames: " @info.cat
    block.labelNames @info addNames
    info @block createComment

    info: String;
    "fromModuleNames: " @info.cat
    block.fromModuleNames @info addNames
    info @block createComment

    info: String;
    "captureNames: " @info.cat
    block.captureNames @info addNames
    info @block createComment

    info: String;
    "fieldCaptureNames: " @info.cat
    block.fieldCaptureNames @info addNames
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

  # count inner overload count
  (@block.@buildingMatchingInfo.@captures @block.@buildingMatchingInfo.@fieldCaptures @block.@labelNames) [
    [
      current:;
      current.nameInfo getOverloadCount @current.@cntNameOverload set
    ] each
  ] each

  unregCodeNodeNames

  (@block.@buildingMatchingInfo.@captures @block.@buildingMatchingInfo.@fieldCaptures @block.@labelNames) [
    [
      current:;
      current.nameInfo getOverloadCount @current.@cntNameOverloadParent set
    ] each
  ] each

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
    topNode: @block;
    [topNode.parent 0 = ~] [
      topNode.parent @processor.@blocks.at.get !topNode
    ] while

    block: @topNode;

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
      declarationNodeIndex VarImport @block createVariable @refToVar set
    ] when

    refToVar @declarationNode.@refToVar set
    FALSE @refToVar getVar.@temporary set

    declarationNode.nodeCase NodeCaseCodeRefDeclaration = [
      "null" toString makeStringId @refToVar getVar.@irNameId set
      "null" toString @declarationNode.@irName set
      block.parent 0 = [
        (";declare func: " functionName) assembleString addStrToProlog #fix global import var matching bug
        processor.prolog.dataSize 1 - @refToVar getVar.@globalDeclarationInstructionIndex set
      ] [
        (";declare func: " functionName) assembleString @block createComment #fix global import var matching bug
        block.program.dataSize 1 - @refToVar getVar.@allocationInstructionIndex set
      ] if
    ] [
      declarationNode.irName toString makeStringId @refToVar getVar.@irNameId set
      (";declare func: " functionName) assembleString addStrToProlog #fix global import var matching bug
      processor.prolog.dataSize 1 - @refToVar getVar.@globalDeclarationInstructionIndex set
    ] if

    topNode.id @declarationNode.@moduleId set
    nameInfo: functionName findNameInfo;
    nameInfo @declarationNode.@varNameInfo set
    nameInfo refToVar NameCaseLocal addNameInfo
  ];

  #generate function header
  noname [processorResult.findModuleFail copy] || [
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
            ("Wrong function name encoding:" functionName) assembleString block compilerError
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
      fr: @functionName @processor.@namedFunctions.find;
      fr.success [
        prevNode: fr.value @processor.@blocks.at.get;
        prevNode.state NodeStateCompiled = [
          prevNode.signature block.signature = ~ [
            ("node " functionName " was defined with another signature") assembleString block compilerError
          ] [
            prevNode.mplConvention block.mplConvention = ~ [
              ("node " functionName " was defined with another convention") assembleString block compilerError
            ] [
              block.nodeCase NodeCaseDeclaration = [
                TRUE @block.@emptyDeclaration set
              ] [
                prevNode.nodeCase NodeCaseDeclaration = [
                  TRUE @prevNode.@emptyDeclaration set
                  block.id @fr.@value set
                ] [
                  "dublicated func implementation" block compilerError
                ] if
              ] if
            ] if
          ] if

          compilable [
            fr: @functionName @block.@namedFunctions.find;
            fr.success ~ [
              functionName toString block.id @block.@namedFunctions.insert
              refToVar: @prevNode.@refToVar;

              nameInfo: functionName findNameInfo;
              block: @refToVar getVar.host; # suppress assert
              nameInfo refToVar NameCaseFromModule addNameInfo #it is not own local variable
            ] when
          ] when
        ] when
      ] [
        functionName toString block.id @processor.@namedFunctions.insert
        functionName toString block.id @block.@namedFunctions.insert
        addFunctionVariableInfo
      ] if
    ] if
  ] if

  (block.convention retType " " block.irName "(" argumentList ")") @block.@header.catMany
  signature @block.@argTypes set

  processor.options.debug [block.empty ~] && [isDeclaration ~] && [block.nodeCase NodeCaseEmpty = ~] && [
    compilerPositionInfo functionName makeStringView block.irName makeStringView block.funcDbgIndex addFuncDebugInfo
    block.funcDbgIndex moveLastDebugString
    " !dbg !"          @block.@header.cat
    block.funcDbgIndex @block.@header.cat
  ] when

  checkRecursionOfCodeNode

  compilable ~ [TRUE @block.@empty set] when
] "finalizeCodeNodeImpl" exportFunction

finalizeCodeNode: [
  compilerPositionInfo forcedSignature multiParserResult @block @processor @processorResult finalizeCodeNodeImpl
];

addIndexArrayToProcess: [
  indexArray: file:;;

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

nodeHasCode: [
  node:;
  node.emptyDeclaration ~ [node.uncompilable ~] && [node.empty ~] && [node.deleted ~] && [node.nodeCase NodeCaseCodeRefDeclaration = ~] &&
];

{
  signature: CFunctionSignature Cref;
  compilerPositionInfo: CompilerPositionInfo Cref;
  multiParserResult: MultiParserResult Cref;
  file: File Cref;
  indexArray: IndexArray Cref;
  processor: Processor Ref;
  processorResult: ProcessorResult Ref;
  nodeCase: NodeCaseCode;
  parentIndex: Int32;
  functionName: StringView Cref;
} Int32 {convention: cdecl;} [
  forcedSignature:;
  compilerPositionInfo:;
  multiParserResult:;
  file:;
  indexArray:;
  processor:;
  processorResult:;
  copy nodeCase:;
  copy parentIndex:;
  functionName:;
  compileOnce

  addBlock
  codeNode: @processor.@blocks.last.get;
  block: @codeNode;
  failProc: @failProcForProcessor;

  processor.options.autoRecursion @codeNode.@nodeIsRecursive set
  nodeCase                        @codeNode.@nodeCase set
  parentIndex                     @codeNode.@parent set
  @compilerPositionInfo           @codeNode.@position set
  block getStackDepth             @codeNode.@minStackDepth set
  processor.varCount              @codeNode.@variableCountDelta set
  processor.exportDepth           @codeNode.@exportDepth set

  processor.depthOfRecursion 1 + @processor.@depthOfRecursion set
  processor.depthOfRecursion processor.maxDepthOfRecursion > [
    processor.depthOfRecursion @processor.@maxDepthOfRecursion set
  ] when

  processor.depthOfRecursion processor.options.recursionDepthLimit > [
    TRUE dynamic @processorResult.@passErrorThroughPRE set
    ("Recursion depth limit (" processor.options.recursionDepthLimit ") exceeded. It can be changed using -recursion_depth_limit option.") assembleString block compilerError
  ] when

  processor.depthOfPre processor.options.preRecursionDepthLimit > [
    TRUE dynamic @processorResult.@passErrorThroughPRE set
    ("PRE recursion depth limit (" processor.options.preRecursionDepthLimit  ") exceeded. It can be changed using -pre_recursion_depth_limit option.") assembleString block compilerError
  ] when

  #add to match table
  indexArray storageAddress @block addMatchingNode

  block.parent 0 = [block.id 1 >] && [
    1 dynamic TRUE dynamic processUseModule #definitions
  ] when

  recursionTries: 0 dynamic;
  [
    @block createLabel

    0 @block.@countOfUCall set
    @block.@labelNames.clear
    @block.@fromModuleNames.clear
    @block.@captureNames.clear
    @block.@unprocessedAstNodes.clear

    processor.options.debug [
      addDebugReserve @block.@funcDbgIndex set
    ] when

    indexArray file addIndexArrayToProcess

    [
      block.unprocessedAstNodes.dataSize 0 > [
        tokenRef: block.unprocessedAstNodes.last copy;
        @block.@unprocessedAstNodes.popBack

        astNode: tokenRef.token multiParserResult.memory.at;
        astNode tokenRef.file makeCompilerPosition @block.@position set

        astNode tokenRef.token tokenRef.file processNode
        compilable [block.state NodeStateNoOutput = ~] &&
      ] &&
    ] loop

    compilable [
      functionName finalizeCodeNode
    ] [
      checkPreStackDepth
      unregCodeNodeNames
      block.id deleteNode
      clearRecursionStack
      NodeStateFailed @block.@state set
      TRUE @block.@uncompilable set
    ] if

    recursionTries 1 + @recursionTries set
    recursionTries 64 > ["recursion processing loop length too big" block compilerError] when

    compilable [
      block.recursionState NodeRecursionStateNo > [block.state NodeStateCompiled = ~] &&
    ] &&
  ] loop

  compilable [block.state NodeStateCompiled =] && [
    @block concreteMatchingNode
  ] when

  processor.varCount codeNode.variableCountDelta - @codeNode.@variableCountDelta set

  processorResult.findModuleFail [
    moduleName: block.moduleName;
    moduleName.getTextSize 0 > [
      fr: moduleName @processor.@modules.find;
      fr.success [
        -1 @fr.@value set
      ] [
        [FALSE] "Undef unexisting module!" assert
      ] if
    ] when
  ] when

  processor.depthOfRecursion 1 - @processor.@depthOfRecursion set

  HAS_LOGS [
    block.parent 0 = [
      block.includedModules [
        id:;
        ("node included module: " id processor.blocks.at.get.moduleName) addLog
      ] each
    ] when
  ] when

  block.id copy
] "astNodeToCodeNode" exportFunction
