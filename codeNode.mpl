"codeNode" module
"control" useModule

"staticCall" includeModule
"variable" includeModule
"processor" includeModule

addOverload: [
  copy nameInfo:;

  nameInfo 0 < not [
    currentNameInfo: nameInfo @processor.@nameInfos.at;
    Overload @currentNameInfo.@stack.pushBack
    currentNameInfo.stack.dataSize 1 -
  ] [
    "bad overload index" makeStringView compilerError
    -1
  ] if
];

getOverloadCount: [
  copy nameInfo:;
  overloads: nameInfo processor.nameInfos.at.stack;
  overloads.getSize
];

addNameInfoWith: [
  copy index:;
  copy reg:;
  copy overload:;
  copy startPoint:;
  copy addNameCase:;
  refToVar:;
  copy nameInfo:;

  [addNameCase NameCaseFromModule = [refToVar noMatterToCopy] || [refToVar.hostId indexOfNode =] ||] "addNameInfo indexOfNode mismatch!" assert

  nameInfo 0 < not [
    currentNameInfo: nameInfo @processor.@nameInfos.at;
    currentNameInfo.stack.dataSize 0 = [
      Overload @currentNameInfo.@stack.pushBack # initialisation of nameInfo
    ] when

    overload 0 < [
      currentNameInfo.stack.dataSize 1 - @overload set
    ] when

    addInfo: TRUE;

    reg not [addNameCase NameCaseBuiltin =] || [
    ] [
      nameWithOverload: NameWithOverloadAndRefToVar;
      refToVar    @nameWithOverload.@refToVar     set
      overload    @nameWithOverload.@nameOverload set
      nameInfo    @nameWithOverload.@nameInfo     set
      startPoint  @nameWithOverload.@startPoint   set

      addNameCase NameCaseLocal = [
        nameWithOverload @currentNode.@labelNames.pushBack
      ] [
        addNameCase NameCaseFromModule = [
          nameWithOverload @currentNode.@fromModuleNames.pushBack
        ] [
          addNameCase NameCaseCapture = [addNameCase NameCaseSelfObjectCapture =] || [addNameCase NameCaseClosureObjectCapture =] || [
            nameWithOverload @currentNode.@captureNames.pushBack
            FALSE @addInfo set
          ] [
            addNameCase NameCaseSelfMember = [addNameCase NameCaseClosureMember =] || [
              nameWithOverload @currentNode.@fieldCaptureNames.pushBack
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
        refToVar @currentNode.@captureTable.find.success not [
          refToVar TRUE @currentNode.@captureTable.insert
        ] when
      ] when
    ] when
  ] [
    #we add "self" or "closure" but dont use them in program
  ] if
];

addNameInfo: [indexOfNode copy -1 dynamic TRUE -1 dynamic addNameInfoWith];
addNameInfoOverloaded: [TRUE -1 dynamic addNameInfoWith];
addNameInfoNoReg: [indexOfNode copy -1 dynamic FALSE -1 dynamic addNameInfoWith];

addNameInfoFieldNoReg: [
  index: copy;
  indexOfNode copy -1 dynamic FALSE index addNameInfoWith
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

makeStaticness: [
  copy staticness:;
  refToVar:;

  refToVar isVirtual not [
    var: refToVar getVar;
    staticness @var.@staticness set

    staticness Virtual < not [
      refToVar makeVariableType
    ] when
  ] when

  refToVar copy
];

makeStorageStaticness: [
  copy staticness:;
  copy refToVar:;

  refToVar isVirtual not [
    staticness refToVar getVar.@storageStaticness set
  ] when

  refToVar
];

createVariable: [
  FALSE dynamic FALSE dynamic TRUE dynamic createVariableWithVirtual
];

createVariableWithVirtual: [
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
  currentNode.parent 0 = @v.@global set

  v.global [
    processor.globalVarId @v.@globalId set
    processor.globalVarId 1 + @processor.@globalVarId set
  ] when

  @v move owner @currentNode.@variables.pushBack
  # now forget about v

  result: RefToVar;

  currentNode.variables.dataSize 1 - @result.@varId set
  indexOfNode @result.@hostId set

  makeVirtual [
    makeSchema [Schema][Virtual] if result getVar.@staticness set
  ] [
    result isPlain [processor.options.staticLiterals not] && [
      Weak result getVar.@staticness set
    ] [
      Static result getVar.@staticness set
    ] if
  ] if

  result result getVar.@capturedHead set
  result result getVar.@capturedTail set

  result isNonrecursiveType not [result isUnallocable not] && @result.@mutable set

  makeType [result makeVariableType] when
  result makeVariableIRName

  processor.varCount 1 + @processor.@varCount set
  tag VarStruct = [
    processor.structureVarCount 1 + @processor.@structureVarCount set
    processor.fieldVarCount VarStruct result getVar.data.get.get.fields.getSize + @processor.@fieldVarCount set
  ] when

  result
];

push: [
  entry:;
  entry @currentNode.@stack.pushBack
];

getStackEntryForPreInput: [
  copy depth:;
  entry: depth getStackEntry;
  [entry.hostId indexOfNode = not] "Pre input is just in inputs!" assert
  shadowBegin: RefToVar;
  shadowEnd: RefToVar;
  entry @shadowBegin @shadowEnd ShadowReasonInput makeShadows
  shadowEnd
];

makeVarCode:   [VarCode   createVariable];
makeVarInt8:   [VarInt8   checkValue VarInt8   createVariable createPlainIR];
makeVarInt16:  [VarInt16  checkValue VarInt16  createVariable createPlainIR];
makeVarInt32:  [VarInt32  checkValue VarInt32  createVariable createPlainIR];
makeVarInt64:  [VarInt64  checkValue VarInt64  createVariable createPlainIR];
makeVarIntX:   [VarIntX   checkValue VarIntX   createVariable createPlainIR];
makeVarNat8:   [VarNat8   checkValue VarNat8   createVariable createPlainIR];
makeVarNat16:  [VarNat16  checkValue VarNat16  createVariable createPlainIR];
makeVarNat32:  [VarNat32  checkValue VarNat32  createVariable createPlainIR];
makeVarNat64:  [VarNat64  checkValue VarNat64  createVariable createPlainIR];
makeVarNatX:   [VarNatX   checkValue VarNatX   createVariable createPlainIR];
makeVarReal32: [VarReal32 checkValue VarReal32 createVariable createPlainIR];
makeVarReal64: [VarReal64 checkValue VarReal64 createVariable createPlainIR];

makeVarString: [
  string:;

  refToVar: RefToVar;

  fr: string @processor.@stringNames.find;
  fr.success [
    fr.value @refToVar set
  ] [
    topIndex: indexOfNode copy;
    topNode: @currentNode;
    [topIndex 0 = not] [
      topNode.parent @topIndex set
      topIndex @processor.@nodes.at.get !topNode
    ] while

    indexOfNode: topIndex copy;
    currentNode: @topNode;

    string VarString createVariable @refToVar set
    string refToVar createStringIR
    string refToVar @processor.@stringNames.insert

    refToVar fullUntemporize
    refToVar getVar.mplNameId refToVar NameCaseLocal addNameInfo
  ] if

  gnr: refToVar getVar.mplNameId getName;
  cnr: gnr captureName;

  cnr.refToVar copy
];

makeConst: [
  var:;
  FALSE dynamic @var.@mutable set
];

getPointeeForMatching: [
  refToVar:;
  var: refToVar getVar;
  [var.data.getTag VarRef =] "Not a reference!" assert
  pointee: VarRef @var.@data.get; # reference
  result: pointee copy;
  refToVar.mutable pointee.mutable and @result.@mutable set # to deref is
  result
];

getPointeeWith: [
  copy dynamize:;
  copy makeDerefIR:;
  refToVar:;
  var: refToVar getVar;
  [var.data.getTag VarRef =] "Not a reference!" assert
  refToVar isVirtualType [
    refToVar copy
  ] [
    pointee: VarRef @var.@data.get; # reference

    fromParent: pointee.hostId indexOfNode = not;
    pointeeIsGlobal: FALSE dynamic;
    needReallyDeref: FALSE dynamic;

    refToVar staticnessOfVar Dynamic > not [

      # create new var of dynamic dereference
      fromParent [
        pointeeCopy: pointee copyOneVar;
        psBegin: RefToVar;
        psEnd:   RefToVar;
        pointeeCopy @psBegin @psEnd ShadowReasonPointee makeShadowsDynamic
        psBegin unglobalize
        psEnd unglobalize
        dynamize not [psEnd   makeVarTreeDynamicStoraged] when
        psEnd @pointee set
      ] [
        pointeeCopy: pointee copyVar; # lost info that pointee is from parent # noMatterToCopy
        pointeeCopy unglobalize
        dynamize not [pointeeCopy makeVarTreeDynamicStoraged] when
        pointeeCopy @pointee set
      ] if

      TRUE @needReallyDeref set
    ] [
      pointeeGDI: pointee getVar.globalDeclarationInstructionIndex;
      fromParent [ # capture or argument
        varShadow: refToVar copy;
        refToVar noMatterToCopy not [
          [var.shadowBegin.hostId 0 < not] "Ref got from parent, but dont have shadow!" assert
          var.shadowBegin @varShadow set
        ] when
        pointeeOfShadow: VarRef @varShadow getVar.@data.get;

        pointeeOfShadow.hostId indexOfNode = [ # just made deref from another place
          pointeeOfShadowVar: pointeeOfShadow getVar;
          [pointeeOfShadowVar.shadowEnd.hostId 0 < not] "Pointee of shadow is not a shadow!" assert
          pointeeOfShadowVar.shadowEnd @pointee set
        ] [
          psBegin: RefToVar;
          psEnd:   RefToVar;
          pointeeOfShadow pointee = [
            pointeeOfShadow @psBegin @psEnd ShadowReasonPointee makeShadows
            psBegin @pointeeOfShadow set
            psEnd @pointee set
          ] [
            #we changed ref, pointeeOFShadow is another pointer to another var!
            pointee @psBegin @psEnd ShadowReasonPointee makeShadows
            psEnd @pointee set
          ] if

          psBegin fullUntemporize
          psEnd fullUntemporize

          TRUE @needReallyDeref set
        ] if
      ] when

      pointee isGlobal [
        TRUE @pointeeIsGlobal set
      ] when
    ] if

    pointeeVar: pointee getVar;
    pointeeVar.getInstructionIndex 0 < [pointeeIsGlobal not] && [
      pointeeVar.allocationInstructionIndex 0 < [
        TRUE @needReallyDeref set
      ] when
    ] [
      FALSE @needReallyDeref set
    ] if

    needReallyDeref makeDerefIR and [
      refToVar pointeeVar.irNameId createDerefTo
      currentNode.program.dataSize 1 - @pointeeVar.@getInstructionIndex set
    ] when

    pointee fullUntemporize

    result: pointee copy;
    refToVar.mutable pointee.mutable and @result.@mutable set # to deref is
    result
  ] if
];

getPointee:              [TRUE  FALSE getPointeeWith];
getPointeeNoDerefIR:     [FALSE FALSE getPointeeWith];
getPointeeWhileDynamize: [FALSE TRUE  getPointeeWith];

getFieldForMatching: [
  refToVar:;
  copy mplFieldIndex:;

  var: refToVar getVar;
  [var.data.getTag VarStruct =] "Not a combined!" assert
  struct: VarStruct @var.@data.get.get;

  mplFieldIndex 0 < not [
    fieldRefToVar: mplFieldIndex struct.fields.at.refToVar copy;
    refToVar.mutable @fieldRefToVar.@mutable set
    fieldRefToVar variableIsDeleted not [
      fieldRefToVar unglobalize

      fieldVar: fieldRefToVar getVar;
      fieldVar.data.getTag VarStruct = [
        fieldStruct: VarStruct @fieldVar.@data.get.get;
        struct.forgotten @fieldStruct.@forgotten set
      ] when
    ] when

    fieldRefToVar
  ] [
    "index is out of bounds" makeStringView compilerError
    RefToVar
  ] if
];

getField: [
  refToVar:;
  copy mplFieldIndex:;
  compileOnce

  var: refToVar getVar;
  [var.data.getTag VarStruct =] "Not a combined!" assert
  struct: VarStruct @var.@data.get.get;

  mplFieldIndex 0 < not [mplFieldIndex struct.fields.getSize <] && [
    fieldRefToVar: mplFieldIndex @struct.@fields.at.@refToVar;
    fieldVar: fieldRefToVar getVar;
    fieldVar.data.getTag VarStruct = [
      fieldStruct: VarStruct @fieldVar.@data.get.get;
      struct.forgotten @fieldStruct.@forgotten set
    ] when

    fieldRefToVar noMatterToCopy [fieldRefToVar.hostId indexOfNode =] || not [ # capture or argument
      var.shadowBegin.hostId 0 < [
        [refToVar noMatterToCopy] "Field got from parent, but dont have shadow!" assert
        fieldRefToVar copyVarFromChild @fieldRefToVar set
      ] [
        varShadow: var.shadowBegin getVar;
        [varShadow.data.getTag VarStruct =] "Shadow is not a combined!" assert
        structShadow: VarStruct @varShadow.@data.get.get;
        fieldShadow: mplFieldIndex @structShadow.@fields.at.@refToVar;
        fieldShadow unglobalize

        psBegin: RefToVar;
        psEnd: RefToVar;
        fieldShadow @psBegin @psEnd ShadowReasonField makeShadows

        psBegin @fieldShadow set
        psEnd @fieldRefToVar set
      ] if

      var.staticness fieldRefToVar getVar.staticness < [
        var.staticness fieldRefToVar getVar.@staticness set
      ] when
    ] when

    refToVar.mutable @fieldRefToVar.@mutable set

    @fieldRefToVar
  ] [
    "index is out of bounds" makeStringView compilerError
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
      currentVar.data.getTag VarStruct = [current noMatterToCopy not] && [
        branch: VarStruct currentVar.data.get.get;
        f: 0 dynamic;
        [
          f branch.fields.dataSize < [
            f current getField @unprocessed.pushBack
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

  srcVar: refSrc getVar;
  dstVar: refDst getVar;

  [srcVar.data.getTag dstVar.data.getTag =] "Variable types mismatch!" assert
  [refSrc isVirtual refDst isVirtual =] "Virtualness mismatch!" assert
  [refDst.mutable copy] "Constness mismatch!" assert

  srcVar.data.getTag VarStruct = not [
    srcVar.data.getTag VarInvalid VarRef 1 + [
      copy tag:;
      tag srcVar.data.get
      tag @dstVar.@data.get set
    ] staticCall
  ] when

  refDst staticnessOfVar Dirty > [
    staticness: refSrc staticnessOfVar;
    staticness Weak = [refDst staticnessOfVar @staticness set] when
    refDst staticness makeStaticness drop:;
  ] [
    srcVar.data.getTag VarRef = [refSrc.mutable copy] && [VarRef srcVar.data.get.mutable copy] && [
      staticness: refSrc staticnessOfVar;
      refSrc makeVarTreeDirty
      refSrc staticness makeStaticness drop:;
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
      currentSrc @currentDst i 0 = setOneVar

      currentSrcVar: currentSrc getVar;
      currentDstVar: currentDst getVar;
      currentSrcVar.data.getTag VarStruct = [
        branchSrc: VarStruct currentSrcVar.data.get.get;
        branchDst: VarStruct currentDstVar.data.get.get;
        f: 0 dynamic;
        [
          f branchSrc.fields.dataSize < [
            fieldSrc: f currentSrc getField;
            fieldDst: f currentDst getField;

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
  copy createOperation:;
  copy mutable:;
  refToVar:;

  refToVar isVirtual [
    refToVar untemporize
    refToVar copy #for dropping or getting callables for example
  ] [
    pointee: refToVar copy;
    var: pointee getVar;
    pointee staticnessOfVar Weak = [Dynamic @var.@staticness set] when
    pointee fullUntemporize

    pointee.mutable [mutable copy] && @pointee.@mutable set
    newRefToVar: pointee VarRef createVariable;
    createOperation [pointee newRefToVar createRefOperation] when
    newRefToVar
  ] if
];

createRef: [TRUE dynamic createRefWith];
createRefNoOp: [FALSE dynamic createRefWith];

createCheckedStaticGEP: [
  refToStruct:;
  copy index:;
  fieldRef:;

  fieldVar: fieldRef getVar;

  fieldVar.getInstructionIndex 0 < [fieldVar.allocationInstructionIndex 0 <] && [
    fieldRef unglobalize
    fieldRef index refToStruct createStaticGEP
    currentNode.program.dataSize 1 - @fieldVar.@getInstructionIndex set
  ] when
];

makeVirtualVarReal: [
  refToVar:;

  refToVar isVirtualType [
    refToVar copy
  ] [
    processor.options.verboseIR [("made virtual var real, type: " refToVar getMplType) assembleString createComent] when

    realValue: refToVar getVar.@realValue;

    unfinishedSrc: RefToVar Array;
    unfinishedDst: RefToVar Array;

    result: refToVar copyOneVar;

    result isVirtualType not [
      Static result getVar.@staticness set

      refToVar @unfinishedSrc.pushBack
      result @unfinishedDst.pushBack

      # first pass: make new variable type
      [
        unfinishedSrc.dataSize 0 > [
          lastSrc: unfinishedSrc.last copy;
          lastDst: unfinishedDst.last copy;
          @unfinishedSrc.popBack
          @unfinishedDst.popBack

          varSrc: lastSrc getVar;
          varDst: lastDst getVar;

          # noMatterToCopy
          lastSrc.hostId indexOfNode = not [varDst.shadowBegin.hostId 0 <] && [
            shadowBegin: lastDst copyOneVar;
            shadowBeginVar: shadowBegin getVar;
            lastDst @shadowBeginVar.@shadowEnd set
            shadowBegin @varDst.@shadowBegin set
          ] when

          varSrc.data.getTag VarStruct = [
            struct: VarStruct varSrc.data.get.get;
            j: 0 dynamic;
            [
              j struct.fields.dataSize < [
                srcField: j struct.fields.at;
                srcField.refToVar isVirtualField not [
                  srcField.refToVar @unfinishedSrc.pushBack
                  dstField: j lastDst getField;
                  dstField @unfinishedDst.pushBack
                  dstField unglobalize
                ] [
                  dstField: j lastDst getField;
                  dstField Virtual makeStaticness r:;
                  dstField unglobalize
                ] if

                j 1 + @j set TRUE
              ] &&
            ] loop
          ] when

          compilable
        ] &&
      ] loop

      # second pass: create IR code for variable
      @result makeVariableType
      refToVar @unfinishedSrc.pushBack
      result createAllocIR @unfinishedDst.pushBack

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
                srcField.refToVar isVirtualField not [
                  srcField.refToVar @unfinishedSrc.pushBack
                  dstField: j lastDst getField;
                  dstField @unfinishedDst.pushBack
                  dstField unglobalize
                  dstField j lastDst createCheckedStaticGEP
                ] when

                j 1 + @j set TRUE
              ] &&
            ] loop
          ] [
            lastSrc isVirtualType not [
              varSrc.data.getTag VarRef = [
              ] [
                lastSrc isPlain [
                  lastSrc lastDst createStoreConstant
                ] when
              ] if
            ] when
          ] if

          compilable
        ] &&
      ] loop
    ] when

    FALSE @result.@mutable set
    result @realValue set

    realValue copy
  ] if
];

makeVarSchema: [
  refToVar:;
  refToVar Schema makeStaticness drop
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
          "can not virtualize automatic struct" makeStringView compilerError
        ] [
          struct: VarStruct curVar.data.get.get;
          j: 0 dynamic;
          [
            j struct.fields.dataSize < [compilable] && [
              curField: j struct.fields.at;
              curField.refToVar isVirtualField not [
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
            "can not virtualize reference to local variable" makeStringView compilerError
          ] if
        ] [
          cur staticnessOfVar Weak < [
            "can not virtualize dynamic value" makeStringView compilerError
          ] when
        ] if
      ] if
      compilable
    ] &&
  ] loop

  compilable [
    refToVar Virtual makeStaticness drop
  ] when
];

makeVarRealCaptured: [
  refToVar:;
  TRUE refToVar getVar.@capturedAsRealValue set
];

makeVarTreeDirty: [
  refToVar:;
  unfinishedVars: RefToVar Array;
  refToVar @unfinishedVars.pushBack

  [
    unfinishedVars.dataSize 0 > [
      lastRefToVar: unfinishedVars.last copy;
      @unfinishedVars.popBack

      var: lastRefToVar getVar;
      lastRefToVar staticnessOfVar Virtual = ["can't dynamize virtual value" makeStringView compilerError] when
      lastRefToVar staticnessOfVar Schema = ["can't dynamize schema" makeStringView compilerError] when

      compilable [
        var.data.getTag VarStruct = [
          struct: VarStruct var.data.get.get;
          j: 0 dynamic;
          [
            j struct.fields.dataSize < [
              j struct.fields.at.refToVar isVirtualField not [
                j lastRefToVar getField @unfinishedVars.pushBack
              ] when
              j 1 + @j set TRUE
            ] &&
          ] loop
        ] [
          var.data.getTag VarRef = [
            lastRefToVar staticnessOfVar Static = [
              pointee: lastRefToVar getPointeeWhileDynamize;
              pointee.mutable [pointee @unfinishedVars.pushBack] when
            ] [
              [lastRefToVar staticnessOfVar Dynamic > not] "Ref must be only Static or Dynamic!" assert
            ] if
          ] when
        ] if

        var.data.getTag VarImport = not var.data.getTag VarString = not and [
          lastRefToVar Dirty makeStaticness @lastRefToVar set
        ] when
      ] when

      compilable
    ] &&
  ] loop
];

makePointeeDirtyIfRef: [
  refToVar:;
  var: refToVar getVar;
  var.data.getTag VarRef = [var.staticness Static =] && [
    pointee: refToVar getPointeeWhileDynamize;
    pointee makeVarRealCaptured
    pointee.mutable [pointee makeVarTreeDirty] when
  ] when
];

makeVarDynamicOrDirty: [
  newStaticness:;
  refToVar:;
  refToVar staticnessOfVar Virtual = ["can't dynamize virtual value" makeStringView compilerError] when

  refToVar makePointeeDirtyIfRef
  msr: refToVar newStaticness makeStaticness;
];

makeVarDynamic: [Dynamic makeVarDynamicOrDirty];
makeVarDirty:   [Dirty   makeVarDynamicOrDirty];

makeVarTreeDynamicWith: [
  copy dynamicStoraged:;
  refToVar:;
  unfinishedVars: RefToVar Array;
  refToVar @unfinishedVars.pushBack

  [
    unfinishedVars.dataSize 0 > [
      lastRefToVar: unfinishedVars.last copy;
      @unfinishedVars.popBack

      var: lastRefToVar getVar;
      lastRefToVar staticnessOfVar Virtual = ["can't dynamize virtual value" makeStringView compilerError] when

      var.data.getTag VarStruct = [
        struct: VarStruct var.data.get.get;
        j: 0 dynamic;
        [
          j struct.fields.dataSize < [
            j struct.fields.at.refToVar isVirtualField not [
              j lastRefToVar getField @unfinishedVars.pushBack
            ] when
            j 1 + @j set TRUE
          ] &&
        ] loop
      ] [
        var.data.getTag VarRef = [
          lastRefToVar staticnessOfVar Static = [
            dynamicStoraged not [
              pointee: lastRefToVar getPointeeWhileDynamize;
              pointee.mutable [pointee makeVarTreeDirty] when
            ] when # dynamic storaged data is not real
          ] [
            [lastRefToVar staticnessOfVar Dynamic = lastRefToVar staticnessOfVar Dirty = or] "Ref must be only Static or Dirty or Dynamic!" assert
          ] if
        ] when
      ] if

      dynamicStoraged [
        lastRefToVar Dynamic makeStorageStaticness @lastRefToVar set
        lastRefToVar Dirty   makeStaticness @lastRefToVar set
      ] [
        lastRefToVar Dynamic makeStaticness @lastRefToVar set
      ] if
      compilable
    ] &&
  ] loop
];

makeVarTreeDynamic:         [FALSE dynamic makeVarTreeDynamicWith];
makeVarTreeDynamicStoraged: [TRUE  dynamic makeVarTreeDynamicWith];

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
  refToVar:;
  copy nameInfo:;

  compilable [
    newRefToVar: refToVar copy;
    staticness: refToVar staticnessOfVar;
    var: newRefToVar getVar;

    currentNode.nextLabelIsVirtual [
      refToVar isVirtual not [
        staticness Dynamic > not ["value for virtual label must be static" makeStringView compilerError] when
        staticness Weak    =     [Static @var.@staticness set] when
      ] when
    ] when

    isGlobalLabel: [
      refToVar:;
      currentNode.nextLabelIsVirtual not [refToVar isVirtual not] && [refToVar isGlobal] &&
    ];

    var.temporary [refToVar isGlobalLabel] &&  [
      refToVar makeVarTreeDirty
      Dirty @staticness set
    ] when

    var.temporary currentNode.nextLabelIsSchema not and [
      staticness @var.@staticness set
      staticness Weak    = [Dynamic @var.@staticness set] when
    ] [
      newRefToVar noMatterToCopy currentNode.nextLabelIsVirtual or newRefToVar isUnallocable not and [
        refToVar copyVarToNew @newRefToVar set
      ] [
        TRUE @var.@capturedAsMutable set #we need ref
        refToVar TRUE currentNode.nextLabelIsSchema not createRefWith @newRefToVar set
        newRefToVar isGlobalLabel [newRefToVar makeVarTreeDirty] when
      ] if
    ] if

    TRUE dynamic @newRefToVar.@mutable set

    nameInfo newRefToVar addOverloadForPre
    newRefToVar fullUntemporize
    FALSE newRefToVar getVar.@tref set

    currentNode.nextLabelIsVirtual currentNode.nextLabelIsSchema or [
      newRefToVar makeVariableType
      currentNode.nextLabelIsSchema [newRefToVar makeVarSchema][newRefToVar makeVarVirtual] if
      FALSE @currentNode.@nextLabelIsVirtual set
      FALSE @currentNode.@nextLabelIsSchema set
    ] when

    nameInfo newRefToVar NameCaseLocal addNameInfo
    compilable [processor.options.debug copy] && [newRefToVar isVirtual not] && [
      newRefToVar isGlobal [
        d: nameInfo newRefToVar addGlobalVariableDebugInfo;
        globalInstruction: newRefToVar getVar.globalDeclarationInstructionIndex @processor.@prolog.at;
        ", !dbg !"   @globalInstruction.cat
        d            @globalInstruction.cat
      ] [
        nameInfo newRefToVar addVariableMetadata
      ] if
    ] when

    currentNode.nodeCase NodeCaseObject = [
      newField: Field;
      nameInfo @newField.@nameInfo set
      newRefToVar @newField.@refToVar set

      newField @currentNode.@struct.@fields.pushBack
    ] when

    nameInfo newRefToVar getVar.@mplNameId set
  ] when
];

processLabelNode: [
  .nameInfo pop createNamedVariable
];

createVarCode: [
  indexOfAstNode:;
  astNode: indexOfAstNode multiParserResult.memory.at; #we have info from parser anyway
  codeInfo: CodeNodeInfo;

  astNode.column     @codeInfo.@column set
  astNode.line       @codeInfo.@line set
  astNode.offset     @codeInfo.@offset set
  astNode.fileNumber @codeInfo.@moduleId set
  indexOfAstNode     @codeInfo.@index set

  @codeInfo move makeVarCode
];

processCodeNode: [createVarCode push];

processCallByIndexArray: [
  multiParserResult @currentNode indexOfNode @processor @processorResult processCallByIndexArrayImpl
];

processObjectNode: [
  data:;
  position: currentNode.position copy;
  name: "objectInitializer" makeStringView;
  data NodeCaseObject dynamic name position processCallByIndexArray
];

processListNode: [
  data:;
  position: currentNode.position copy;
  name: "listInitializer" makeStringView;
  data NodeCaseList dynamic name position processCallByIndexArray
];

{
  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  indexOfNode: Int32;
  currentNode: CodeNode Ref;
  multiParserResult: MultiParserResult Cref;
  message: StringView Cref;
} () {convention: cdecl;} [
  processorResult:;
  processor:;
  copy indexOfNode:;
  currentNode:;
  multiParserResult:;
  failProc: @failProcForProcessor;
  message:;
  [
    compileOnce
    processorResult.findModuleFail not [processor.depthOfPre 0 =] && [HAS_LOGS] && [
      ("COMPILER ERROR") addLog
      (message) addLog
      defaultPrintStackTrace
    ] when

    compilable [
      FALSE dynamic @processorResult.@success set

      processor.depthOfPre 0 = [
        message toString @processorResult.@errorInfo.@message set
        nodeIndex: indexOfNode copy;

        [
          node: nodeIndex processor.nodes.at.get;
          node.root [
            FALSE
          ] [
            node.position @processorResult.@errorInfo.@position.pushBack
            node.parent @nodeIndex set
            TRUE
          ] if
        ] loop
      ] when
    ] when
  ] call
] "compilerErrorImpl" exportFunction

findLocalObject: [
  copy captureCase:;
  copy refToVar:;

  i: 0 dynamic;
  [
    i currentNode.buildingMatchingInfo.captures.dataSize < [
      currentCapture: i currentNode.buildingMatchingInfo.captures.at;
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
  copy overload:;
  copy forMatching:;
  matchingCapture:;
  copy nameInfo:;
  name: nameInfo processor.nameInfos.at.name;

  unknownName: [
    forMatching [
    ] [
      ("unknown name:" name) assembleString compilerError
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

  nameInfo 0 < not [
    curNameInfo: nameInfo processor.nameInfos.at;
    curNameInfo.name name = [
      overload 0 < [curNameInfo.stack.getSize 1 - @overload set] when

      curNameInfo.stack.getSize 0 > [overload curNameInfo.stack.at.getSize 0 >] && [
        [curNameInfo.stack.getSize 0 >] "Name info data not initialised!" assert
        nameInfoEntry: overload curNameInfo.stack.at.last;
        overload @result.@nameOverload set
        nameInfoEntry.nameCase   @result.@nameCase set
        nameInfoEntry.startPoint @result.@startPoint set

        nameCase: matchingCapture.captureCase NameCaseInvalid = [result.nameCase copy] [matchingCapture.captureCase copy] if;
        nameCase NameCaseSelfMember = [nameCase NameCaseClosureMember =] || [
          object: nameInfoEntry.refToVar;
          overloadShift: curNameInfo.stack.dataSize 1 - overload -;
          fields: VarStruct object getVar.data.get.get.fields;
          nameInfoEntry.index 0 < not [nameInfoEntry.index fields.getSize <] && [nameInfoEntry.index fields.at.nameInfo nameInfo =] && [
            object nameCase MemberCaseToObjectCase findLocalObject @result.@object set
            nameInfoEntry.index @result.@mplFieldIndex set
            nameInfoEntry.index fields.at.refToVar @result.@refToVar set
            object.mutable @result.@refToVar.@mutable set
          ] [
            ("Internal error, mismatch structures for name:" name) assembleString compilerError
          ] if
        ] [
          nameCase NameCaseSelfObject = [nameCase NameCaseClosureObject =] || [
            forMatching [
              overload curNameInfo.stack.at matchingCapture.refToVar nameCase findNameStackObject @result.@refToVar set
            ] [
              nameInfoEntry.refToVar nameCase findLocalObject @result.@refToVar set
            ] if
          ] [
            nameInfoEntry.refToVar @result.@refToVar set
          ] if
        ] if

        moveToTail: [
          refToVar:;
          refToVar.hostId 0 < not [
            # if var was captured somewhere, we must use it
            head: refToVar getVar.capturedHead;
            result: head getVar.capturedTail copy;
            refToVar.mutable @result.@mutable set # tail cant keep correct staticness in some cases

            currentNode.parent 0 = [nameInfoEntry.startPoint indexOfNode = not] && [
              fr: nameInfoEntry.startPoint @currentNode.@usedModulesTable.find;
              fr.success [TRUE @fr.@value.@used set] when
            ] when

            result
          ] [
            refToVar copy
          ] if
        ];

        result.refToVar moveToTail @result.@refToVar set
        result.object moveToTail @result.@object set
      ] [
        unknownName
      ] if
    ] [
      ("Internal error, mismatch structures for name:" name) assembleString compilerError
    ] if
  ] [
    unknownName
  ] if
  result
];

getName: [Capture FALSE dynamic -1 dynamic getNameAs];
getNameForMatching: [TRUE dynamic -1 dynamic getNameAs];

getNameWithOverload: [
  copy overload:;
  Capture FALSE dynamic overload getNameAs
];

getNameForMatchingWithOverload: [
  copy overload:;
  TRUE dynamic overload getNameAs
];

captureName: [
  getNameResult:;
  compileOnce

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
      needToCapture: refToVar.hostId indexOfNode = not;
      needToCapture not [
        head.hostId indexOfNode = not [refToVar noMatterToCopy not] && [
          var: refToVar getVar;

          var.allocationInstructionIndex 0 <
          var.getInstructionIndex 0 < and
          var.globalDeclarationInstructionIndex 0 < and

          [
            var.shadowReason ShadowReasonCapture = not
            [
              captureCase NameCaseSelfObject =
              captureCase NameCaseClosureObject = or
              var.shadowReason ShadowReasonInput = and not
            ] &&
          ] && [
            TRUE @needToCapture set
          ] when
        ] when
      ] when

      needToCapture not [
        TRUE refToVar getVar.@capturedAsMutable set
        refToVar @result.@refToVar set
      ] [
        refToVar noMatterToCopy not [
          head currentNode.captureTable.find.success not [
            head TRUE @currentNode.@captureTable.insert
            TRUE
          ] &&

          refToVar @result.@refToVar set
        ] || [
          shadowBegin: RefToVar;
          shadowEnd: RefToVar;
          refToVar @shadowBegin @shadowEnd ShadowReasonCapture makeShadows

          newCapture: Capture;
          shadowEnd @newCapture.@refToVar set
          nameInfo @newCapture.@nameInfo set
          [getNameResult.nameOverload 0 < not] "name overload not initialized!" assert

          nameOverload:
          getNameResult.nameCase NameCaseSelfMember =
          [getNameResult.nameCase NameCaseClosureMember =] ||
          [0]
          [getNameResult.nameOverload copy] if;

          nameOverload @newCapture.@nameOverload set
          captureCase  @newCapture.@captureCase set

          refToVar isVirtual [ArgVirtual] [refToVar isGlobal [ArgGlobal] [ArgRef] if ] if @newCapture.@argCase set
          realCapture: newCapture.argCase ArgRef =;

          realCapture [currentNode.exportDepth refToVar.hostId processor.nodes.at.get.exportDepth = not] && [
            TRUE !captureError
          ] when

          newCapture @currentNode.@buildingMatchingInfo.@captures.pushBack
          currentNode.state NodeStateNew = [
            shadowBegin @newCapture.@refToVar set
            nameInfo getOverloadCount @newCapture.@cntNameOverload set
            nameInfo getOverloadCount @newCapture.@cntNameOverloadParent set
            newCapture @currentNode.@matchingInfo.@captures.pushBack
          ] when

          processor.options.debug [shadowEnd isVirtual not] && [shadowEnd isGlobal not] && [
            fakePointer: shadowEnd VarRef createVariable;
            shadowEnd fakePointer createRefOperation
            nameInfo fakePointer addVariableMetadata
            programSize: currentNode.program.getSize;
            TRUE programSize 3 - @currentNode.@program.at.@fakePointer set
            TRUE programSize 2 - @currentNode.@program.at.@fakePointer set
            TRUE programSize 1 - @currentNode.@program.at.@fakePointer set
            addDebugLocationForLastInstruction
          ] when

          shadowEnd @result.@refToVar set
          TRUE @result.@newVar set

          shadowEnd fullUntemporize
          refToVar isForgotten not [
            shadowBegin fullUntemporize
          ] when

          [shadowEnd getVar.temporary not] "Captured var must not be temporary!" assert
        ] when
      ] if

      result
    ];

    # now we must capture and create GEP instruction
    getNameResult.mplFieldIndex 0 < not [
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

      cro: nameInfo getNameResult.object getNameResult.nameCase MemberCaseToObjectCase captureRefToVar;

      cro.refToVar @result.@object set
      getNameResult.mplFieldIndex cro.refToVar processStaticAt @result.@refToVar set
      cro.newVar [
        nameInfo cro.refToVar getNameResult.nameCase MemberCaseToObjectCaptureCase getNameResult.startPoint getNameResult.nameOverload addNameInfoOverloaded
      ] when # add name info for "self"/"closure" as Object; result is object

      needToCapture: getNameResult.startPoint indexOfNode = not [
        head: getNameResult.refToVar getVar.capturedHead;
        head currentNode.fieldCaptureTable.find.success not [
          head TRUE @currentNode.@fieldCaptureTable.insert
          TRUE
        ] &&
      ] &&;

      needToCapture [
        getNameResult.nameInfo result.refToVar NameCaseCapture getNameResult.startPoint getNameResult.nameOverload addNameInfoOverloaded # add name info for fieldName as Capture; result is member

        newFieldCapture: FieldCapture;
        getNameResult.nameInfo @newFieldCapture.@nameInfo set
        [getNameResult.nameOverload 0 < not] "name overload not initialized!" assert
        getNameResult.nameOverload @newFieldCapture.@nameOverload set
        result.object @newFieldCapture.@object set
        getNameResult.nameCase @newFieldCapture.@captureCase set
        newFieldCapture @currentNode.@buildingMatchingInfo.@fieldCaptures.pushBack

        currentNode.state NodeStateNew = [
          getNameResult.nameInfo getOverloadCount @newFieldCapture.@cntNameOverload set
          getNameResult.nameInfo getOverloadCount @newFieldCapture.@cntNameOverloadParent set
          newFieldCapture @currentNode.@matchingInfo.@fieldCaptures.pushBack
        ] when
      ] when
    ] [
      cr: getNameResult.nameInfo getNameResult.refToVar getNameResult.nameCase captureRefToVar;
      cr.refToVar @result.@refToVar set
      cr.newVar [
        getNameResult.nameInfo result.refToVar NameCaseCapture getNameResult.startPoint getNameResult.nameOverload addNameInfoOverloaded
      ] when
    ] if

    captureError [
      "real function can not have real local capture" compilerError
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
      [currentField.nameInfo processor.emptyNameInfo = not] "Closured list!" assert
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
      [currentField.nameInfo processor.emptyNameInfo = not] "Closured list!" assert
      currentField.nameInfo deleteNameInfo # name info pointing to the struct, not to a field!
    ] &&
  ] loop
];

regNamesClosure: [
  object:;
  object.hostId 0 < not [
    processor.closureNameInfo object NameCaseClosureObject addNameInfoNoReg
    object NameCaseClosureMember addFieldsNameInfos
  ] when
];

regNamesSelf: [
  object:;
  object.hostId 0 < not [
    processor.selfNameInfo object NameCaseSelfObject addNameInfoNoReg
    object NameCaseSelfMember addFieldsNameInfos
  ] when
];

unregNamesClosure: [
  object:;
  object.hostId 0 < not [
    object deleteFieldsNameInfos
    processor.closureNameInfo deleteNameInfo
  ] when
];

unregNamesSelf: [
  object:;
  object.hostId 0 < not [
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
    VarCode codeVar.data.get.index name processCall
    refToVar unregNamesClosure
    object unregNamesSelf
  ] [
    "CALL field is not a code" compilerError
  ] if
];

callCallableField: [
  name:;
  refToVar:;
  object:;
  compileOnce

  var: refToVar getVar;
  code: VarCode var.data.get.index;

  object regNamesClosure
  code @name processCall
  object unregNamesClosure
];

callCallableStructWithPre: [
  nameInfo:;
  copy refToVar:;
  copy object:;
  overloadShift: 0 dynamic;
  findInside: object.hostId 0 < not;

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
          VarCode preVar.data.get.index processPre not @needPre set
        ] [
          "PRE field must be a code" compilerError
        ] if
      ] when

      needPre [
        overloadShift 1 + @overloadShift set

        findInside [
          fr: nameInfo object overloadShift findFieldWithOverloadShift;
          fr.success [
            fr.index object processStaticAt @refToVar set
          ] [
            0 @overloadShift set
            FALSE @findInside set
          ] if
        ] when

        findInside not [
          overload: nameInfo getOverloadCount 1 - overloadShift -;
          overload 0 < [
            name: nameInfo processor.nameInfos.at.name makeStringView;
            ("cant call overload for name: " name) assembleString compilerError
          ] when

          compilable [
            gnr: nameInfo overload getNameWithOverload;
            compilable [
              cnr: gnr captureName;
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
        VarCode codeVar.data.get.index nameInfo processor.nameInfos.at.name makeStringView processCall
        refToVar unregNamesClosure
        object unregNamesSelf
      ] if
    ] [
      "CALL field is not a code" compilerError
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
    VarBuiltin var.data.get callBuiltin
  ] [
    var.data.getTag VarCode = [
      object regNamesSelf
      VarCode var.data.get.index @nameInfo processor.nameInfos.at.name makeStringView processCall
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
  refToVar:;
  refToVar getVar.data.getTag VarRef = [
    refToVar getPointee
  ] [
    refToVar copy
  ] if

];

derefAndPush: [
  getPossiblePointee push
];

tryImplicitLambdaCast: [
  refToDst:;
  refToSrc:;

  result: {
    success: FALSE dynamic;
    refToVar: RefToVar;
  };

  varSrc: refToSrc getVar;
  varSrc.data.getTag VarCode = [refToDst isVirtual not] && [
    dstPointee: refToDst getPossiblePointee;
    dstPointeeVar: dstPointee getVar;

    dstPointeeVar.data.getTag VarImport = [
      declarationIndex: VarImport dstPointeeVar.data.get;
      declarationNode: declarationIndex processor.nodes.at.get;
      csignature: declarationNode.csignature;
      implName: ("lambda." indexOfNode "." currentNode.lastLambdaName) assembleString;
      astNode: VarCode refToSrc getVar.data.get.index @multiParserResult.@memory.at;
      implIndex: csignature astNode implName makeStringView TRUE dynamic processExportFunction;

      compilable [
        implNode: implIndex processor.nodes.at.get;
        implNode.state NodeStateCompiled = not [
          currentNode.state NodeStateHasOutput > [NodeStateHasOutput @currentNode.@state set] when
          dstPointee @result.@refToVar set
          TRUE dynamic @result.@success set
        ] when

        implNode.varNameInfo 0 < not [
          gnr: implNode.varNameInfo getName;
          compilable not [
            [FALSE] "Name of new lambda is not visible!" assert
          ] [
            cnr: gnr captureName;
            cnr.refToVar @result.@refToVar set
            TRUE dynamic @result.@success set
          ] if
        ] when
      ] when

      currentNode.lastLambdaName 1 + @currentNode.@lastLambdaName set
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
      "can not write to virtual" makeStringView compilerError
    ] [
      pointee: VarRef var.data.get;
      pointee.mutable not [
        FALSE defaultMakeConstWith #source
      ] when

      compilable [
        src: pop;
        compilable [
          src pointee variablesAreSame [
            src push
            TRUE defaultRef #source
            refToVar push
            defaultSet
          ] [
            src push
            refToVar push
            defaultSet
          ] if
        ] when
      ] when
    ] if
  ] [
    #rewrite value case!
    src: pop;
    compilable [
      src getVar.temporary [
        src push
        refToVar push
        defaultSet
      ] [
        "rewrite value works only with temporary values" compilerError
      ] if
    ] when
  ] if
];

copyOneVarWith: [
  copy toNew:;
  src:;
  compileOnce

  dst: RefToVar;
  srcVar: src getVar;

  checkedStaticnessOfVar: [
    toNew [staticnessOfVar Dynamic maxStaticness] [staticnessOfVar] if
  ];

  srcVar.data.getTag VarStruct = [
    srcStruct: VarStruct srcVar.data.get.get;
    # manually copy only nececcary fields
    dstStruct: Struct;
    srcStruct.fields          @dstStruct.@fields set
    @dstStruct move owner VarStruct src isVirtualField src isSchema FALSE dynamic createVariableWithVirtual
    src checkedStaticnessOfVar makeStaticness @dst set
    dstStructAc: VarStruct dst getVar.@data.get.get;
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
      tag VarStruct = not [
        tag srcVar.data.get tag src isVirtualField src isSchema FALSE dynamic createVariableWithVirtual
        src checkedStaticnessOfVar makeStaticness
        @dst set
      ] when
    ] staticCall

    srcVar.data.getTag VarRef = [srcVar.shadowBegin dst getVar.@shadowBegin set] when  #for ttest48
  ] if

  src.mutable @dst.@mutable set
  dstVar: dst getVar;
  srcVar.irTypeId  @dstVar.@irTypeId set
  srcVar.mplTypeId @dstVar.@mplTypeId set
  srcVar.dbgTypeId @dstVar.@dbgTypeId set

  dst
];

copyVarImpl: [
  copy toNew:;
  copy fromChildToParent:;
  refToVar:;

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
          currentSrc toNew copyOneVarWith @currentDst set

          currentSrcVar: currentSrc getVar;
          currentDstVar: currentDst getVar;
          currentSrcVar.data.getTag VarStruct = [
            branchSrc: VarStruct currentSrcVar.data.get.get;
            branchDst: VarStruct @currentDstVar.@data.get.get;
            f: 0 dynamic;
            [
              f branchSrc.fields.dataSize < [
                fromChildToParent [
                  f branchSrc.fields.at.refToVar @uncopiedSrc.pushBack
                ] [
                  f currentSrc getField @uncopiedSrc.pushBack
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
    result
  ] if
];

copyOneVar: [FALSE dynamic copyOneVarWith];

copyVar:           [FALSE FALSE dynamic copyVarImpl]; #fromchild is static arg
copyVarFromChild:  [TRUE  FALSE dynamic copyVarImpl];
copyVarToNew:      [FALSE TRUE  dynamic copyVarImpl];
copyVarFromParent: [TRUE  FALSE dynamic copyVarImpl];

{
  dynamicStoraged: Cond;

  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  indexOfNode: Int32;
  currentNode: CodeNode Ref;
  multiParserResult: MultiParserResult Cref;

  reason: Nat8;
  end: RefToVar Ref;
  begin: RefToVar Ref;
  refToVar: RefToVar Cref;
} () {convention: cdecl;} [
  copy dynamicStoraged:;

  processorResult:;
  processor:;
  copy indexOfNode:;
  currentNode:;
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
    headVar: head getVar;

    reallyCreateShadows: [
      shadowSrc: headVar.capturedTail copy;
      refToVar.mutable @shadowSrc.@mutable set

      shadowSrc copyOneVar @begin set
      shadowSrc copyOneVar @end set

      beginVar: begin getVar;
      endVar: end getVar;
      global: refToVar isGlobal;

      var.storageStaticness @beginVar.@storageStaticness set
      var.storageStaticness   @endVar.@storageStaticness set

      global [
        reason ShadowReasonField = not [
          var.irNameId @endVar.@irNameId set
        ] when

        TRUE @beginVar.@global set
        TRUE @endVar.@global set

      ] [
        begin unglobalize
        end unglobalize
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
      end @currentNode.@capturedVars.pushBack       # remember
    ];

    dynamicStoraged [
      reallyCreateShadows
    ] [
      headVar.capturedTail.hostId indexOfNode = [
        headVar.capturedTail @end set
        end getVar.shadowBegin @begin set

        refToVar.mutable @begin.@mutable set
        refToVar.mutable @end.@mutable set

        beginVar: begin getVar;
        endVar: end getVar;
        reason beginVar.shadowReason < [
          reason @beginVar.@shadowReason set
          reason   @endVar.@shadowReason set
        ] when

        [begin.hostId indexOfNode =] "Begin hostId incorrect in makeShadows!" assert
        [end.hostId indexOfNode =] "End hostId incorrect in makeShadows!" assert
      ] [
        reallyCreateShadows
      ] if
    ] if
  ] if
] "makeShadowsImpl" exportFunction

makeShadows:        [
  multiParserResult @currentNode indexOfNode @processor @processorResult
  FALSE makeShadowsImpl
];

makeShadowsDynamic: [
  multiParserResult @currentNode indexOfNode @processor @processorResult
  TRUE  makeShadowsImpl
];

addStackUnderflowInfo: [
  TRUE @currentNode.@buildingMatchingInfo.@hasStackUnderflow set
  currentNode.state NodeStateNew = [
    TRUE @currentNode.@matchingInfo.@hasStackUnderflow set
  ] when
];

{
  forMatching: Cond;
  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  indexOfNode: Int32;
  currentNode: CodeNode Ref;
  multiParserResult: MultiParserResult Cref;
  result: RefToVar Ref;
} () {convention: cdecl;} [
  copy forMatching:;
  processorResult:;
  processor:;
  copy indexOfNode:;
  currentNode:;
  multiParserResult:;
  failProc: @failProcForProcessor;
  result:;

  currentNode.stack.dataSize 0 = [
    entryRef: 0 dynamic getStackEntry;
    compilable [
      entry: entryRef copy;
      entry staticnessOfVar Weak = [
        entry Dynamic makeStaticness @entry set
      ] when

      shadowBegin: RefToVar;
      shadowEnd: RefToVar;

      entry @shadowBegin @shadowEnd ShadowReasonInput makeShadows

      shadowEnd @result set
      entry isForgotten [
        shadowBegin untemporize
        shadowEnd   untemporize
      ] [
        shadowBegin fullUntemporize
        shadowEnd   fullUntemporize
      ] if

      [result noMatterToCopy [result.hostId indexOfNode =] ||] "Shadow host incorrect!" assert
      result.mutable [TRUE result getVar.@capturedAsMutable set] when

      result getVar.data.getTag VarRef = [
        # it is for exports only
        # we have immutable reference, becouse it is a rule of signature
        # after deref we must force mutability
        mutableOfPointee: VarRef result getVar.data.get.mutable copy;
        result getPointee @result set
        mutableOfPointee @result.@mutable set
      ] when

      newInput: Argument;

      result @newInput.@refToVar set
      ArgRef @newInput.@argCase set

      entry isGlobal [ArgGlobal @newInput.@argCase set] when

      #add input
      newInput @currentNode.@buildingMatchingInfo.@inputs.pushBack
      currentNode.state NodeStateNew = [
        result noMatterToCopy not [
          result getVar.shadowBegin @newInput.@refToVar set
        ] when
        newInput @currentNode.@matchingInfo.@inputs.pushBack
      ] when
    ] [
      addStackUnderflowInfo
    ] if
  ] [
    currentNode.stack.last @result set
    @currentNode.@stack.popBack
  ] if
] "popImpl" exportFunction

pop:            [
  result: RefToVar;
  @result multiParserResult @currentNode indexOfNode @processor @processorResult FALSE popImpl
  result
];

popForMatching: [
  result: RefToVar;
  @result multiParserResult @currentNode indexOfNode @processor @processorResult TRUE popImpl
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
    refToVar isVirtual [refToVar makeVirtualVarReal @refToVar set] when

    read 1 = [
      refToVar derefAndPush
    ] [
      possiblePointee: refToVar getPossiblePointee;
      possiblePointee isCallable [
        object possiblePointee nameInfo [object possiblePointee @nameInfo callCallableStructWithPre] callCallable
      ] [
        FALSE dynamic @possiblePointee.@mutable set
        possiblePointee push
      ] if
    ] if
  ] if
];

processNameNode: [
  data:;
  gnr: data.nameInfo getName;
  cnr: gnr captureName;
  refToVar: cnr.refToVar copy;

  compilable [
    cnr.object refToVar 0 data.nameInfo pushName
  ] when
];

processNameReadNode: [
  data:;
  gnr: data.nameInfo getName;
  cnr: gnr captureName;
  refToVar: cnr.refToVar;

  compilable [
    var: refToVar getVar;
    var.data.getTag VarBuiltin = [
      "can't use @name for builtins, use [name] instead" makeStringView compilerError
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
  data:;

  cnr: data.nameInfo getName captureName;
  refToVar: cnr.refToVar;

  compilable [refToVar setRef] when
];

processStaticAt: [
  refToStruct:;
  copy index:;

  fieldRef: index refToStruct getField;

  compilable [
    fieldVar: fieldRef getVar;
    fieldRef isVirtual [
      fieldRef unglobalize
    ] [
      [refToStruct isVirtual not] "fields of virtual struct must be virtual!" assert
      fieldRef unglobalize
      fieldRef index refToStruct createCheckedStaticGEP
    ] if

    fieldRef fullUntemporize
    fieldRef copy
  ] [
    RefToVar
  ] if
];

processMember: [
  copy read:;
  copy refToStruct:;
  data:;

  compilable [
    fieldError: [
      (refToStruct getMplType " has no field " data.name) assembleString compilerError
    ];

    refToStruct isSchema [
      read -1 = [
        "can not write to field of struct schema" makeStringView compilerError
      ] [
        structVar: refToStruct getVar;
        pointee: VarRef structVar.data.get;
        pointeeVar: pointee getVar;
        pointeeVar.data.getTag VarStruct = [
          fr: data.nameInfo pointee findField;
          fr.success [
            index: fr.index copy;
            field: index 0 cast VarStruct pointeeVar.data.get.get.fields.at.refToVar;
            result: field VarRef TRUE dynamic TRUE dynamic TRUE dynamic createVariableWithVirtual;
            result fullUntemporize
            read 1 = result.mutable and @result.@mutable set
            result push
          ] [
            fieldError
          ] if
        ] [
          "not a combined" makeStringView compilerError
        ] if
      ] if
    ] [
      refToStruct getVar.data.getTag VarStruct = [
        fr: data.nameInfo refToStruct findField;
        fr.success [
          index: fr.index copy;
          fieldRef: index refToStruct processStaticAt;
          refToStruct fieldRef read data.nameInfo pushName # let it be marker about field
        ] [
          fieldError
        ] if
      ] [
        "not a combined" makeStringView compilerError
      ] if
    ] if
  ] when
];

processNameMemberNode: [pop 0 dynamic processMember];
processNameReadMemberNode: [pop 1 dynamic processMember];
processNameWriteMemberNode: [pop -1 dynamic processMember];

processStringNode: [makeVarString push];
processInt8Node:   [makeVarInt8   push];
processInt16Node:  [makeVarInt16  push];
processInt32Node:  [makeVarInt32  push];
processInt64Node:  [makeVarInt64  push];
processIntXNode:   [makeVarIntX   push];
processNat8Node:   [makeVarNat8   push];
processNat16Node:  [makeVarNat16  push];
processNat32Node:  [makeVarNat32  push];
processNat64Node:  [makeVarNat64  push];
processNatXNode:   [makeVarNatX   push];
processReal32Node: [makeVarReal32 push];
processReal64Node: [makeVarReal64 push];

addDebugLocationForLastInstruction: [
  processor.options.debug [
    operation: @currentNode.@program.last.@code;
    operation.chars.dataSize 1 >
    [operation.chars.dataSize 2 - operation.chars.at 58n8 =  not] && # label detector, code of ":"
    [currentNode.position.line 0 < not] &&
    [
      ", !dbg !" makeStringView @operation.cat
      locationIndex: currentNode.position currentNode.funcDbgIndex addDebugLocation;
      locationIndex @operation.cat
    ] when
  ] when
];

addCodeNode: [
  CodeNode owner @processor.@nodes.pushBack
  processor.nodeCount 1 + @processor.@nodeCount set
];

argAbleToCopy: [
  arg:;
  arg isTinyArg
];

argRecommendedToCopy: [
  arg:;
  arg.mutable not [arg argAbleToCopy] && [arg getVar.capturedAsMutable not] &&
];

callInit: [
  copy refToVar:;
  compilable [
    uninited: RefToVar Array;
    refToVar isVirtual not [refToVar makeVarTreeDynamic] when
    TRUE dynamic @refToVar.@mutable set
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
                f current processStaticAt @uninited.pushBack
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
        current: i uninited.at;
        current getVar.data.getTag VarStruct = [
          fr: processor.dieNameInfo current findField;
          fr.success [
            fr: processor.initNameInfo current findField;
            fr.success [
              index: fr.index copy;
              fieldRef: index current processStaticAt;
              initName: processor.initNameInfo processor.nameInfos.at.name makeStringView;
              stackSize: currentNode.stack.dataSize copy;
              fieldRef getVar.data.getTag VarCode = [
                current fieldRef @initName callCallableField
                compilable [currentNode.state NodeStateNoOutput = not] && [currentNode.stack.dataSize stackSize = not] && [
                  ("Struct " current getMplType "'s INIT method dont save stack") assembleString compilerError
                ] when
              ] [
                ("Struct " current getMplType "'s INIT method is not a CODE") assembleString compilerError
              ] if
            ] [
              ("Struct " current getMplType " is automatic, but has not INIT field") assembleString compilerError
            ] if
          ] when
        ] when
        compilable [currentNode.state NodeStateNoOutput = not] &&
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
              fieldRef: index curSrc processStaticAt;
              assignName: processor.assignNameInfo processor.nameInfos.at.name makeStringView;
              stackSize: currentNode.stack.dataSize copy;

              fieldRef getVar.data.getTag VarCode = [
                curDst isVirtualField [
                  "unable to copy virtual autostruct" compilerError
                ] [
                  curSrc push
                  curDst fieldRef @assignName callCallableField
                  compilable [currentNode.state NodeStateNoOutput = not] && [currentNode.stack.dataSize stackSize = not] && [
                    ("Struct " curSrc getMplType "'s ASSIGN method dont save stack") assembleString compilerError
                  ] when
                ] if
              ] [
                ("Struct " curSrc getMplType "'s ASSIGN method is not a CODE") assembleString compilerError
              ] if
            ] [
              ("Struct " curSrc getMplType " is automatic, but has not ASSIGN field") assembleString compilerError
            ] if
          ] [
            structSrc: VarStruct curSrcVar.data.get.get;
            structDst: VarStruct curDstVar.data.get.get;
            f: 0 dynamic;
            [
              f structSrc.fields.dataSize < [
                srcField: f curSrc processStaticAt;
                srcField                 @unfinishedSrc.pushBack
                f curDst processStaticAt @unfinishedDst.pushBack
                f 1 + @f set TRUE
              ] &&
            ] loop
          ] if
        ] [
          curSrc curDst createMemset
        ] if
        compilable [currentNode.state NodeStateNoOutput = not] &&
      ] &&
    ] loop
  ] when
];

callDie: [
  copy refToVar:;
  compilable [
    unkilled: RefToVar Array;
    refToVar fullUntemporize
    TRUE dynamic @refToVar.@mutable set
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
            fieldRef: index last processStaticAt;
            dieName: processor.dieNameInfo processor.nameInfos.at.name makeStringView;
            stackSize: currentNode.stack.dataSize copy;

            fieldRef getVar.data.getTag VarCode = [
              last fieldRef @dieName callCallableField
              compilable [currentNode.state NodeStateNoOutput = not] && [currentNode.stack.dataSize stackSize = not] && [
                ("Struct " last getMplType "'s DIE method dont save stack") assembleString compilerError
              ] when
            ] [
              ("Struct " last getMplType "'s DIE method is not a CODE") assembleString compilerError
            ] if
          ] when

          f: 0 dynamic;
          [
            f struct.fields.dataSize < [
              f struct.fields.at.refToVar isAutoStruct [
                f last processStaticAt @unkilled.pushBack
              ] when
              f 1 + @f set TRUE
            ] &&
          ] loop
        ] when
        compilable [currentNode.state NodeStateNoOutput = not] &&
      ] &&
    ] loop
  ] when
];

killStruct: [
  refToVar:;
  [refToVar getVar.data.getTag VarStruct =] "Destructors works only for structs!" assert
  VarStruct refToVar getVar.data.get.get.unableToDie not [
    refToVar callDie
  ] when
];

{
  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  indexOfNode: Int32;
  currentNode: CodeNode Ref;
  multiParserResult: MultiParserResult Cref;
  indexOfAstNode: Int32;
  astNode: AstNode Cref;
} () {} [
  processorResult:;
  processor:;
  copy indexOfNode:;
  currentNode:;
  multiParserResult:;
  failProc: @failProcForProcessor;
  copy indexOfAstNode:;
  astNode:;

  processor.options.verboseIR [
    ("filename: " currentNode.position.fileNumber processor.options.fileNames.at
      ", line: " currentNode.position.line ", column: " currentNode.position.column ", token: " astNode.token) assembleString createComent
  ] when

  programSize: currentNode.program.dataSize copy;

  astNode.data.getTag (
    AstNodeType.Label           [AstNodeType.Label astNode.data.get processLabelNode]
    AstNodeType.Code            [indexOfAstNode processCodeNode]
    AstNodeType.Object          [AstNodeType.Object astNode.data.get processObjectNode]
    AstNodeType.List            [AstNodeType.List astNode.data.get processListNode]
    AstNodeType.Name            [AstNodeType.Name astNode.data.get processNameNode]
    AstNodeType.NameRead        [AstNodeType.NameRead astNode.data.get processNameReadNode]
    AstNodeType.NameWrite       [AstNodeType.NameWrite astNode.data.get processNameWriteNode]
    AstNodeType.NameMember      [AstNodeType.NameMember astNode.data.get processNameMemberNode]
    AstNodeType.NameReadMember  [AstNodeType.NameReadMember astNode.data.get processNameReadMemberNode]
    AstNodeType.NameWriteMember [AstNodeType.NameWriteMember astNode.data.get processNameWriteMemberNode]
    AstNodeType.String          [AstNodeType.String @astNode.@data.get processStringNode]
    AstNodeType.Numberi8        [AstNodeType.Numberi8 @astNode.@data.get processInt8Node]
    AstNodeType.Numberi16       [AstNodeType.Numberi16 @astNode.@data.get processInt16Node]
    AstNodeType.Numberi32       [AstNodeType.Numberi32 @astNode.@data.get processInt32Node]
    AstNodeType.Numberi64       [AstNodeType.Numberi64 @astNode.@data.get processInt64Node]
    AstNodeType.Numberix        [AstNodeType.Numberix @astNode.@data.get processIntXNode]
    AstNodeType.Numbern8        [AstNodeType.Numbern8 @astNode.@data.get processNat8Node]
    AstNodeType.Numbern16       [AstNodeType.Numbern16 @astNode.@data.get processNat16Node]
    AstNodeType.Numbern32       [AstNodeType.Numbern32 @astNode.@data.get processNat32Node]
    AstNodeType.Numbern64       [AstNodeType.Numbern64 @astNode.@data.get processNat64Node]
    AstNodeType.Numbernx        [AstNodeType.Numbernx @astNode.@data.get processNatXNode]
    AstNodeType.Real32          [AstNodeType.Real32 @astNode.@data.get processReal32Node]
    AstNodeType.Real64          [AstNodeType.Real64 @astNode.@data.get processReal64Node]
    [[FALSE] "Unknown type!" assert]
  ) case

  currentNode.program.dataSize programSize > [
    addDebugLocationForLastInstruction
  ] when
] "processNodeImpl" exportFunction

processNode: [
  astNode indexOfAstNode multiParserResult @currentNode indexOfNode @processor @processorResult processNodeImpl
];

addNamesFromModule: [
  copy moduleId:;

  fru: moduleId currentNode.usedOrIncludedModulesTable.find;
  fru.success not [
    moduleId TRUE @currentNode.@usedOrIncludedModulesTable.insert

    moduleNode: moduleId processor.nodes.at.get;
    moduleNode.labelNames [
      current: .value;
      current.nameInfo current.refToVar addOverloadForPre
      current.nameInfo current.refToVar NameCaseFromModule addNameInfo #it is not own local variable
    ] each
  ] when
];

processUseModule: [
  copy asUse:;
  copy moduleId:;

  currentModule: moduleId processor.nodes.at.get;
  moduleList: currentModule.includedModules copy;
  moduleId @moduleList.pushBack

  moduleList [
    pair:;
    current: pair.value;
    last: pair.index moduleList.getSize 1 - =;

    asUse [last copy] && [
      current {used: FALSE dynamic; position: currentNode.position copy;} @currentNode.@usedModulesTable.insert
      current TRUE @currentNode.@directlyIncludedModulesTable.insert
      current addNamesFromModule
    ] [
      fr: current currentNode.includedModulesTable.find;
      fr.success not [
        last [
          current TRUE @currentNode.@directlyIncludedModulesTable.insert
        ] when
        current @currentNode.@includedModules.pushBack
        current {used: FALSE dynamic; position: currentNode.position copy;} @currentNode.@includedModulesTable.insert
        current addNamesFromModule
      ] when
    ] if
  ] each
];

finalizeListNode: [
  struct: Struct;
  compilable [
    i: 0 dynamic;
    [
      i currentNode.stack.dataSize < [
        curRef: i @currentNode.@stack.at;

        newField: Field;
        processor.emptyNameInfo @newField.@nameInfo set

        curRef getVar.temporary [
          curRef @newField.@refToVar set
        ] [
          curRef TRUE dynamic createRef @newField.@refToVar set
        ] if

        newField @struct.@fields.pushBack
        i 1 + @i set compilable
      ] &&
    ] loop
  ] when

  compilable [
    refToStruct: @struct move owner VarStruct createVariable;
    struct: VarStruct refToStruct getVar.data.get.get;

    refToStruct isVirtual not [
      refToStruct createAllocIR @refToStruct set
    ] when

    i: 0 dynamic;
    [
      i currentNode.stack.dataSize < [
        curFieldRef: i struct.fields.at.refToVar;

        curFieldRef isVirtual [
          curFieldRef markAsUnableToDie
        ] [
          curFieldRef markAsUnableToDie
          staticness: curFieldRef staticnessOfVar;
          staticness Weak = [Dynamic @staticness set] when
          staticness Virtual = not [curFieldRef staticness makeStaticness drop:;] when
          curFieldRef i refToStruct createGEPInsteadOfAlloc
        ] if

        i 1 + @i set compilable
      ] &&
    ] loop

    @currentNode.@stack.clear
    refToStruct @currentNode.@stack.pushBack
  ] when
];

finalizeObjectNode: [
  refToStruct: @currentNode.@struct move owner VarStruct createVariable;
  structInfo: VarStruct refToStruct getVar.data.get.get;

  i: 0 dynamic;
  [
    i structInfo.fields.dataSize < [
      dstFieldRef: i structInfo.fields.at.refToVar;
      dstFieldRef markAsUnableToDie
      i 1 + @i set TRUE
    ] &&
  ] loop

  refToStruct isVirtual not [
    refToStruct createAllocIR drop
    i: 0 dynamic;
    [
      i structInfo.fields.dataSize < [
        dstFieldRef: i structInfo.fields.at.refToVar;

        [dstFieldRef staticnessOfVar Weak = not] "Field label is weak!" assert
        [dstFieldRef noMatterToCopy [dstFieldRef.hostId indexOfNode =] ||] "field host incorrect" assert
        dstFieldRef isVirtual not [
          [dstFieldRef getVar.allocationInstructionIndex currentNode.program.dataSize <] "field is not allocated" assert
          dstFieldRef i refToStruct createGEPInsteadOfAlloc
        ] when

        i 1 + @i set TRUE
      ] &&
    ] loop
  ] when

  refToStruct @currentNode.@stack.pushBack
];

unregCodeNodeNames: [
  unregisterNamesIn: [
    [
      nameWithOverload: .value;
      nameWithOverload.nameOverload nameWithOverload.nameInfo deleteNameInfoWithOverload
    ] each
  ];

  @currentNode.@labelNames unregisterNamesIn
  @currentNode.@fromModuleNames unregisterNamesIn
  @currentNode.@fieldCaptureNames unregisterNamesIn

  @currentNode.@fromModuleNames.release
  @currentNode.@fieldCaptureNames.release

  currentNode.capturedVars [
    curVar: .value getVar;
    curVar.capturedPrev curVar.capturedHead getVar.@capturedTail set # head->prev of tail
  ] each

  @currentNode.@capturedVars.release
  @currentNode.@usedModulesTable.release
  @currentNode.@includedModulesTable.release
  @currentNode.@directlyIncludedModulesTable.release
  @currentNode.@captureTable.release
  @currentNode.@fieldCaptureTable.release
];

checkPreStackDepth: [
  newMinStackDepth: getStackDepth currentNode.stack.dataSize -;
  preCountedStackDepth: currentNode.minStackDepth copy;
  i: preCountedStackDepth copy;
  [
    i newMinStackDepth < [
      preInputDepth: i preCountedStackDepth - currentNode.stack.dataSize +;
      preInput: preInputDepth getStackEntryForPreInput;
      preInput noMatterToCopy not [preInput getVar.shadowBegin @preInput set] when
      [preInput.hostId 0 < not] "Invalid preInput!" assert
      preInput @currentNode.@buildingMatchingInfo.@preInputs.pushBack
      i 1 + @i set TRUE
    ] &&
  ] loop
];

addMatchingNode: [
  copy indexOfNode:;
  copy addr:;

  node: indexOfNode @processor.@nodes.at.get;
  addr @node.@indexArrayAddress set

  fr: addr @processor.@matchingNodes.find;
  fr.success [
    fr.value.unknownMplType.getSize @currentNode.@matchingInfoIndex set
    fr.value.size 1 + @fr.@value.@size set
    indexOfNode @fr.@value.@unknownMplType.pushBack
  ] [
    tableValue: MatchingNode;
    compilerPositionInfo @tableValue.@compilerPositionInfo set
    1 @tableValue.@size set
    0 @tableValue.@tries set
    0 @tableValue.@entries set
    0 @currentNode.@matchingInfoIndex set
    indexOfNode @tableValue.@unknownMplType.pushBack
    addr @tableValue move @processor.@matchingNodes.insert
  ] if
];

deleteMatchingNode: [
  copy indexOfNode:;

  node: indexOfNode @processor.@nodes.at.get;
  node.matchingInfoIndex 0 < not [
    addr: node.indexArrayAddress copy;
    info: addr @processor.@matchingNodes.find.@value;
    indexArray: @info.@unknownMplType;
    info.size 1 - @info.@size set

    [node.matchingInfoIndex indexArray.at indexOfNode =] "Current node: matchingInfo table is incorrect!" assert
    indexArray.getSize 1 - node.matchingInfoIndex = not [
      [indexArray.last processor.nodes.at.get.matchingInfoIndex indexArray.getSize 1 - =] "Last node: matchingInfo table is incorrect!" assert

      node.matchingInfoIndex indexArray.last @processor.@nodes.at.get.@matchingInfoIndex set
      indexArray.last node.matchingInfoIndex @indexArray.at set
    ] when

    -1 @node.@matchingInfoIndex set
    @indexArray.popBack
  ] when
];

concreteMatchingNode: [
  copy indexOfNode:;
  node: indexOfNode @processor.@nodes.at.get;

  node.matchingInfo.inputs.getSize 0 = not [
    indexOfNode deleteMatchingNode

    addr: node.indexArrayAddress copy;
    info: addr @processor.@matchingNodes.find.@value;
    info.size 1 + @info.@size set #return it back

    byMplType: info.@byMplType;

    key: 0 node.matchingInfo.inputs.at.refToVar getVar.mplTypeId copy;

    fr: key @info.@byMplType.find;
    fr.success [
      indexOfNode @fr.@value.pushBack
    ] [
      newBranch: IndexArray;
      indexOfNode @newBranch.pushBack
      key @newBranch move @info.@byMplType.insert
    ] if
  ] when
];

deleteNode: [
  copy nodeIndex:;
  node: nodeIndex @processor.@nodes.at.get;
  TRUE dynamic @node.@empty   set
  TRUE dynamic @node.@deleted set
  @node.@program.release

  nodeIndex deleteMatchingNode

  processor.deletedNodeCount 1 + @processor.@deletedNodeCount set
];

clearRecursionStack: [
  processor.recursiveNodesStack.getSize 0 > [processor.recursiveNodesStack.last indexOfNode =] && [
    @processor.@recursiveNodesStack.popBack
  ] when
];

checkRecursionOfCodeNode: [
  clearBuildingMatchingInfo: FALSE dynamic;

  removePrevNodes: [
    #go back from end of   nodes to current node, delete "hasOutput" and "noOutput" nodes
    i: processor.nodes.getSize 1 -;
    processed: FALSE dynamic;
    [
      i 0 < not [
        current: i @processor.@nodes.at.get;
        current.deleted not [
          current.recursionState NodeRecursionStateFail > [
            [i indexOfNode =] "Another recursive node!" assert
            TRUE @processed set
            NodeRecursionStateOld @current.@recursionState set
          ] [
            [i indexOfNode = not] "Current node no more recursive!" assert
            [current.state NodeStateCompiled = [current.state NodeStateNoOutput =] || [current.state NodeStateHasOutput =] ||] "Invalid node state in resursion backward deleter!" assert
            current.state NodeStateNoOutput = [current.state NodeStateHasOutput =] || [
              i deleteNode
            ] when
          ] if
        ] when
        i 1 - @i set
        processed not
      ] &&
    ] loop
    #recursion need more iterations
    @currentNode.@program.clear
    @currentNode.@stack.clear
    TRUE @clearBuildingMatchingInfo set
  ];

  approvePrevNodes: [
    [processor.recursiveNodesStack.getSize 0 >] "recursiveNodesStack is empty!" assert
    [
      processor.recursiveNodesStack.last indexOfNode = [
        ("processor.recursiveNodesStack.last=" processor.recursiveNodesStack.last "; but indexOfNode=" indexOfNode copy) addLog
        FALSE
      ] ||
    ] "Processor.recursionStack mismatch!" assert
    @processor.@recursiveNodesStack.popBack
    #go back from end of   nodes to current node, mark "hasOutput" nodes as "Compiled"; "noOutput" nodes - logic error, assert
    i: processor.nodes.getSize 1 -;
    processed: FALSE dynamic;
    [
      i 0  < not [
        current: i @processor.@nodes.at.get;
        current.deleted not [
          current.recursionState NodeRecursionStateFail > [
            [i indexOfNode =] "Another recursive node!" assert
            NodeRecursionStateNo @currentNode.@recursionState set
            TRUE @processed set
          ] [
            [i indexOfNode = not] "Current node no more recursive!" assert
            [
              current.state NodeStateCompiled = [current.state NodeStateHasOutput =] || [
                ("failed state " current.state " in node " i " while " indexOfNode copy) addLog
                FALSE
              ] ||
            ] "Invalid node state in resursion backward approver!" assert
            current.state NodeStateHasOutput = [
              NodeStateCompiled @current.@state set
            ] when
          ] if
        ] when
        i 1 - @i set
        processed not
      ] &&
    ] loop
    #recursion successful
  ];


  currentNode.state NodeStateNew = [
    NodeStateCompiled @currentNode.@state set
  ] [
    currentNode.recursionState NodeRecursionStateFail > not [
      NodeRecursionStateNo @currentNode.@recursionState set #node will die anyway
    ] [
      result: currentNode.recursionState NodeRecursionStateOld =;
      [currentNode.state NodeStateNew = not] "Recursion logic failed!" assert
      currentNode.state NodeStateNoOutput = [
        #it is NOT a recursion
        removePrevNodes
        NodeStateNew @currentNode.@state set
        MatchingInfo @currentNode.@matchingInfo set
        NodeRecursionStateFail @currentNode.@recursionState set
        [processor.recursiveNodesStack.last indexOfNode =] "Processor.recursionStack mismatch!" assert
        @processor.@recursiveNodesStack.popBack
      ] [
        currentNode.state NodeStateHasOutput = [
          curToNested: RefToVarTable;
          nestedToCur: RefToVarTable;
          comparingMessage: String;
          currentMatchingNodeIndex: indexOfNode copy;
          currentMatchingNode: currentMatchingNodeIndex @processor.@nodes.at.get;

          compareShadows: [
            refToVar2:;
            refToVar1:;
            se1: refToVar1 noMatterToCopy [refToVar1][refToVar1 getVar.shadowEnd] if;
            se2: refToVar2 noMatterToCopy [refToVar2][refToVar2 getVar.shadowEnd] if;
            [se1.hostId 0 < not [se2.hostId 0 < not] &&] "variables has no shadowEnd!" assert
            se1 se2 compareEntriesRec
          ];

          #compare inputs
          result [
            currentNode.matchingInfo.inputs.getSize currentNode.buildingMatchingInfo.inputs.getSize = not [
              FALSE @result set
            ] when

            result [
              i: 0 dynamic;
              [
                i currentNode.matchingInfo.inputs.getSize < [
                  current1: i currentNode.matchingInfo.inputs.at.refToVar;
                  current2: i currentNode.buildingMatchingInfo.inputs.at.refToVar;
                  current1 current2 compareShadows not [
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
            currentNode.matchingInfo.captures.getSize currentNode.buildingMatchingInfo.captures.getSize = not [
              FALSE @result set
            ] when

            result [
              i: 0 dynamic;
              [
                i currentNode.matchingInfo.captures.getSize < [
                  capture1: i currentNode.matchingInfo.captures.at;
                  capture2: i currentNode.buildingMatchingInfo.captures.at;

                  capture1.captureCase capture2.captureCase =
                  [capture1.nameInfo capture2.nameInfo =] &&
                  [capture1.nameOverload capture2.nameOverload =] &&
                  [capture1.cntNameOverload capture2.cntNameOverload =] &&
                  [capture1.refToVar capture2.refToVar compareShadows] && not [
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
            currentNode.matchingInfo.fieldCaptures.getSize currentNode.buildingMatchingInfo.fieldCaptures.getSize = not [
              FALSE @result set
            ] when

            result [
              i: 0 dynamic;
              [
                i currentNode.matchingInfo.fieldCaptures.getSize < [
                  capture1: i currentNode.matchingInfo.fieldCaptures.at;
                  capture2: i currentNode.buildingMatchingInfo.fieldCaptures.at;

                  capture1.captureCase capture2.captureCase =
                  [capture1.nameInfo capture2.nameInfo =] &&
                  [capture1.nameOverload capture2.nameOverload =] &&
                  [capture1.cntNameOverload capture2.cntNameOverload =] &&
                  [capture1.cntNameOverloadParent capture2.cntNameOverloadParent =] && not [
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
            currentNode.stack.getSize currentNode.outputs.getSize = not [
              FALSE @result set
            ] when

            result [
              i: 0 dynamic;
              [
                i currentNode.stack.getSize < [
                  current1: i currentNode.stack.at;
                  current2: i currentNode.outputs.at.refToVar;
                  current1 current2 compareEntriesRec not [
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

        result [NodeStateCompiled] [NodeStateHasOutput] if @currentNode.@state set
      ] if
    ] if
  ] if

  currentNode.buildingMatchingInfo @currentNode.@matchingInfo set
  clearBuildingMatchingInfo [
    MatchingInfo @currentNode.@buildingMatchingInfo set
    0            @currentNode.@lastLambdaName set
  ] when
];

makeCompilerPosition: [
  astNode:;
  result: CompilerPositionInfo;

  astNode.line       @result.@line set
  astNode.column     @result.@column set
  astNode.offset     @result.@offset set
  astNode.fileNumber @result.@fileNumber set
  astNode.token      @result.@token set

  result
];

{
  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  indexOfNode: Int32;
  currentNode: CodeNode Ref;
  multiParserResult: MultiParserResult Cref;
  forcedSignature: CFunctionSignature Cref;
  compilerPositionInfo: CompilerPositionInfo Cref;
  functionName: StringView Cref;
} () {convention: cdecl;} [
  processorResult:;
  processor:;
  copy indexOfNode:;
  currentNode:;
  multiParserResult:;
  failProc: @failProcForProcessor;
  forcedSignature:;
  compilerPositionInfo:;
  functionName:;

  currentNode.nextLabelIsVirtual ["unused virtual specifier" makeStringView compilerError] when
  currentNode.nextLabelIsSchema["unused schema specifier" makeStringView compilerError] when

  currentNode.nodeCase NodeCaseList   = [finalizeListNode] when
  currentNode.nodeCase NodeCaseObject = [finalizeObjectNode] when

  processor.options.verboseIR ["return" makeStringView createComent] when


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
      refToVar isVirtual not
      [isDeclaration not] && [
        refForArg: refToVar VarRef createVariable;
        refToVar refForArg createRefOperation
        refForArg TRUE
      ] [
        copyForArg: refToVar copyVarToNew;
        TRUE dynamic @copyForArg.@mutable set
        refToVar copyForArg createCopyToNew
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
      [var.usedInHeader not [var.allocationInstructionIndex 0 < not] &&] "Cannot use simple return!" assert

      [
        refToVar getVar.data.getTag VarStruct = not [
          struct: VarStruct refToVar getVar.@data.get.get;
          struct.unableToDie not
        ] ||
      ] "Double returning same struct!" assert

      refToVar markAsUnableToDie
    ] [
      var.usedInHeader [
        copyForArg: refToVar copyOneVar;
        copyForArg @refToVar set
      ] when
    ] if

    var: refToVar getVar;
    regNameId 0 < [var.irNameId @regNameId set] when


    asCopy not [
      TRUE @var.@usedInHeader set

      aii: refToVar getVar.allocationInstructionIndex copy;
      aii 0 < not [
        FALSE aii @currentNode.@program.at.@enabled set
      ] when # otherwise it was popped or captured
    ] when

    asCopy output and not [
      dii: refToVar getVar.getInstructionIndex copy;
      dii 0 < not [ #it was got by
        FALSE dii @currentNode.@program.at.@enabled set
      ] when

      argumentList.chars.dataSize 0 > [", " makeStringView @argumentList.cat] when
      refToVar getIrType        @argumentList.cat
      asCopy not ["*"           @argumentList.cat] when

      signature.chars.dataSize 0 > [", " makeStringView @signature.cat] when
      refToVar getIrType        @signature.cat
      asCopy not ["*"           @signature.cat] when

      isDeclaration not [
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

    var: refToVar getVar;
    refToVar isAutoStruct [
      var.usedInHeader [
        copyForArg: refToVar copyVarToNew;
        TRUE dynamic @copyForArg.@mutable set
        refToVar copyForArg createCopyToNew
        copyForArg @refToVar set
      ] when

      [
        refToVar getVar.data.getTag VarStruct = not [
          struct: VarStruct refToVar getVar.@data.get.get;
          struct.unableToDie not
        ] ||
      ] "Double returning same struct!" assert

      TRUE @var.@usedInHeader set
      refToVar markAsUnableToDie
    ] when
  ];

  callDestructors: [
    currentNode.parent 0 = [
      i: 0 dynamic;
      [
        i currentNode.candidatesToDie.dataSize < [
          current: i @currentNode.@candidatesToDie.at;
          current @processor.@globalDestructibleVars.pushBack
          i 1 + @i set TRUE
        ] &&
      ] loop

      currentNode.candidatesToDie [
        refToVar: .value;
        refToVar isAutoStruct [
          refToVar @processorResult @processor multiParserResult compilerPositionInfo CFunctionSignature createDtorForGlobalVar
        ] when
      ] each
    ] [
      retInstructionIndex: currentNode.program.dataSize 1 -;
      i: currentNode.candidatesToDie.dataSize copy dynamic;
      [
        i 0 > [
          i 1 - @i set
          current: i @currentNode.@candidatesToDie.at;
          current killStruct
          compilable
        ] &&
      ] loop

      retInstruction: retInstructionIndex @currentNode.@program.at copy;
      @retInstruction move @currentNode.@program.pushBack
      FALSE retInstructionIndex @currentNode.@program.at.@enabled set
    ] if
  ];

  isDeclaration:
  currentNode.nodeCase NodeCaseDeclaration =
  [currentNode.nodeCase NodeCaseDllDeclaration =] ||
  [currentNode.nodeCase NodeCaseCodeRefDeclaration =] ||;

  isRealFunction:
  currentNode.nodeCase NodeCaseExport =
  [currentNode.nodeCase NodeCaseLambda =] ||;

  hasForcedSignature: isDeclaration isRealFunction or;

  currentNode.state NodeStateNoOutput = [@currentNode.@stack.clear] when
  String @currentNode.@header set
  String @currentNode.@signature set

  inputCountMismatch: [
    ("In signature there are " forcedSignature.inputs.getSize " inputs, but really here " currentNode.buildingMatchingInfo.inputs.getSize " inputs") assembleString compilerError
  ];

  hasForcedSignature [
    currentNode.buildingMatchingInfo.inputs.getSize forcedSignature.inputs.getSize = not [
      currentNode.buildingMatchingInfo.inputs.getSize 1 + forcedSignature.inputs.getSize =
      [forcedSignature.outputs.getSize 0 >] &&
      [0 forcedSignature.outputs.at forcedSignature.inputs.last variablesAreSame] && [
        #todo for MPL signature check each
        pop push
      ] [
        inputCountMismatch
      ] if
    ] when

    forcedSignature @currentNode.@csignature set
  ] when

  compilable [
    i: 0 dynamic;
    [
      i currentNode.buildingMatchingInfo.inputs.dataSize < [
        # const to plain make copy
        current: i @currentNode.@buildingMatchingInfo.@inputs.at;

        current.refToVar isVirtual [
          ArgVirtual @current.@argCase set
        ] [
          current.argCase ArgGlobal = [
            TRUE @hasEffect set
          ] [
            currentVar: current.refToVar getVar;
            needToCopy: hasForcedSignature [
              i forcedSignature.inputs.at getVar.data.getTag VarRef = not
            ] [
              current.refToVar argRecommendedToCopy
            ] if;

            needToCopy [current.refToVar argAbleToCopy not] && [isRealFunction copy] && [
              "getting huge agrument by copy; mpl's export function can not have this signature" compilerError
            ] when

            needToCopy [
              regNameId: generateRegisterIRName;
              ArgCopy @current.@argCase set
              current.refToVar regNameId addCopyArg

              current.refToVar getVar.allocationInstructionIndex 0 < [
                regNameId current.refToVar createAllocIR createStoreFromRegister
                TRUE @currentNode.@program.last.@alloca set #fake for good sotring
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

  currentNode.parent 0 =
  [currentNode.stack.dataSize 0 >] && [
    "module can not have inputs or outputs" compilerError
  ] when

  @currentNode.@outputs.clear
  i: 0 dynamic;
  [
    i currentNode.stack.dataSize < [
      current: i currentNode.stack.at;
      newArg: Argument;

      current isVirtual [
        ArgVirtual @newArg.@argCase set
        current addVirtualOutput
        current @newArg.@refToVar set
      ] [
        current checkOutput refDeref:; output:;

        passAsRet:
        isDeclaration [output isTinyArg [hasRet not] &&] ||;

        passAsRet not [isRealFunction copy] && [
          "returning two arguments or non-primitive object; mpl's function can not have this signature" compilerError
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

      newArg @currentNode.@outputs.pushBack
      i 1 + @i set compilable
    ] &&
  ] loop

  hasRet [
    retRef createRetValue
  ] [
    s: "  ret void" toString;
    @s move makeInstruction @currentNode.@program.pushBack
  ] if

  callDestructors
  processor.options.verboseIR ["called destructors" createComent] when

  i: 0 dynamic;
  [
    i currentNode.buildingMatchingInfo.captures.dataSize < [
      current: i currentNode.buildingMatchingInfo.captures.at;
      current.argCase ArgRef = [
        isRealFunction [
          ("real function can not have local capture; name=" current.nameInfo processor.nameInfos.at.name "; type=" current.refToVar getMplType) assembleString compilerError
        ] when

        current.refToVar FALSE addRefArg
      ] [
        current.argCase ArgGlobal = [
          TRUE @hasEffect set
        ] when
      ] if

      current.refToVar getVar.data.getTag VarImport = [TRUE @hasImport set] when
      i 1 + @i set compilable
    ] &&
  ] loop

  currentNode.variadic [
    isDeclaration [
      currentNode.buildingMatchingInfo.inputs.getSize 0 = [
        "..." @signature.cat
        "..." @argumentList.cat
      ] [
        ", ..." @signature.cat
        ", ..." @argumentList.cat
      ] if
    ] [
      "export function cannot be variadic" compilerError
    ] if
  ] when

  sortInstructions

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

  noname: hasForcedSignature not;

  currentNode.nodeCase NodeCaseEmpty = [
    noname
    [currentNode.nodeCase NodeCaseLambda = not] &&
    [currentNode.recursionState NodeRecursionStateNo =] &&
    [hasImport not] &&
    [hasRet not] &&
    [hasEffect not] &&
    [currentNode.parent 0 = not] &&
  ] || @currentNode.@empty set

  addDebugLocationForLastInstruction
  checkPreStackDepth

  fixArrShadows: [
    [
      current: .@value;
      current.refToVar noMatterToCopy not [current.refToVar getVar.shadowBegin @current.@refToVar set] when
    ] each
  ];

  @currentNode.@buildingMatchingInfo.@inputs fixArrShadows
  @currentNode.@buildingMatchingInfo.@captures fixArrShadows

  processor.options.verboseIR [
    info: String;
    "labelNames: " @info.cat
    currentNode.labelNames @info addNames
    info createComent

    info: String;
    "fromModuleNames: " @info.cat
    currentNode.fromModuleNames @info addNames
    info createComent

    info: String;
    "captureNames: " @info.cat
    currentNode.captureNames @info addNames
    info createComent

    info: String;
    "fieldCaptureNames: " @info.cat
    currentNode.fieldCaptureNames @info addNames
    info createComent
  ] when

  currentNode.parent 0 = [
    [currentNode.nodeCase NodeCaseCode = [currentNode.nodeCase NodeCaseDtor =] ||] "Root node bust be simple code node or dtor node!" assert
    currentNode.nodeCase NodeCaseCode = [
      indexOfNode @processor.@moduleFunctions.pushBack
    ] [
      indexOfNode @processor.@dtorFunctions.pushBack
    ] if
  ] when

  # count inner overload count
  (@currentNode.@buildingMatchingInfo.@captures @currentNode.@buildingMatchingInfo.@fieldCaptures @currentNode.@labelNames) [
    .@value [
      current: .@value;
      current.nameInfo getOverloadCount @current.@cntNameOverload set
    ] each
  ] each

  unregCodeNodeNames

  (@currentNode.@buildingMatchingInfo.@captures @currentNode.@buildingMatchingInfo.@fieldCaptures @currentNode.@labelNames) [
    .@value [
      current: .@value;
      current.nameInfo getOverloadCount @current.@cntNameOverloadParent set
    ] each
  ] each

  String @currentNode.@irName set
  hasForcedSignature [forcedSignature.convention "" = not] && [
    (forcedSignature.convention " ") assembleString @currentNode.@convention set
    forcedSignature.convention @currentNode.@mplConvention set
  ] [
    String @currentNode.@convention set
    "" toString @currentNode.@mplConvention set
  ] if

  (retType "(" signature ")") assembleString @currentNode.@signature set

  # fix declarations
  addFunctionVariableInfo: [
    declarationNodeIndex: indexOfNode copy;
    declarationNode: @currentNode;

    # we can call func as imported
    topIndex: indexOfNode copy;
    topNode: @currentNode;
    [topNode.parent 0 = not] [
      topNode.parent @topIndex set
      topIndex @processor.@nodes.at.get !topNode
    ] while

    indexOfNode: topIndex copy;
    currentNode: @topNode;

    refToVar: RefToVar;
    fr: @functionName @processor.@namedFunctions.find;
    fr.success [
      prev: fr.value @processor.@nodes.at.get;
      prev.refToVar @refToVar set
      refToVar.hostId 0 < not [
        declarationNodeIndex @prev.@nextRecLambdaId set
      ] when
    ] [
      functionName toString declarationNodeIndex @processor.@namedFunctions.insert
    ] if

    refToVar.hostId 0 < [
      declarationNodeIndex VarImport createVariable @refToVar set
    ] when

    refToVar @declarationNode.@refToVar set
    FALSE refToVar getVar.@temporary set

    declarationNode.nodeCase NodeCaseCodeRefDeclaration = [
      "null" toString makeStringId refToVar getVar.@irNameId set
      "null" toString @declarationNode.@irName set
      currentNode.parent 0 = [
        (";declare func: " functionName) assembleString addStrToProlog #fix global import var matching bug
        processor.prolog.dataSize 1 - refToVar getVar.@globalDeclarationInstructionIndex set
      ] [
        (";declare func: " functionName) assembleString createComent #fix global import var matching bug
        currentNode.program.dataSize 1 - refToVar getVar.@allocationInstructionIndex set
      ] if
    ] [
      declarationNode.irName toString makeStringId refToVar getVar.@irNameId set
      (";declare func: " functionName) assembleString addStrToProlog #fix global import var matching bug
      processor.prolog.dataSize 1 - refToVar getVar.@globalDeclarationInstructionIndex set
    ] if

    topIndex @declarationNode.@moduleId set
    nameInfo: functionName findNameInfo;
    nameInfo @declarationNode.@varNameInfo set
    nameInfo refToVar NameCaseLocal addNameInfo
  ];

  #generate function header
  noname [processorResult.findModuleFail copy] || [
    currentNode.nodeCase NodeCaseDtor = [
      "@"          @currentNode.@irName.cat
      functionName @currentNode.@irName.cat
    ] [
      currentNode.parent 0 = [
        "@module." @currentNode.@irName.cat
      ] [
        "@func."   @currentNode.@irName.cat
      ] if

      indexOfNode @currentNode.@irName.cat
      # create name with only correct symbols
      currentNode.nodeCase NodeCaseLambda = [
        ".lambda" @currentNode.@irName.cat
      ] [
        wasDot: FALSE;
        functionName.getTextSize 0 > [
          splitted: functionName.split;
          splitted.success [
            splitted.chars [
              symbol: .value;
              codePoint: symbol stringMemory Nat8 addressToReference;
              codePoint 48n8 < not [codePoint 57n8 > not] &&         #0..9
              [codePoint 65n8 < not [codePoint 90n8 > not] &&] ||    #A..Z
              [codePoint 97n8 < not [codePoint 122n8 > not] &&] || [ #a..z
                wasDot not [
                  "." @currentNode.@irName.cat
                  TRUE @wasDot set
                ] when
                symbol @currentNode.@irName.cat
              ] when
            ] each
          ] [
            ("Wrong function name encoding:" functionName) assembleString compilerError
          ] if
        ] when
      ] if
    ] if

    currentNode.nodeCase NodeCaseLambda = [addFunctionVariableInfo] when

    "define internal " makeStringView @currentNode.@header.cat
  ] [
    # export func!!!
    "@" makeStringView         @currentNode.@irName.cat
    @functionName              @currentNode.@irName.cat

    currentNode.nodeCase NodeCaseDllDeclaration = [
      "declare dllimport " makeStringView   @currentNode.@header.cat
    ] [
      currentNode.nodeCase NodeCaseDeclaration = [currentNode.nodeCase NodeCaseCodeRefDeclaration =] || [
        "declare " makeStringView   @currentNode.@header.cat
      ] [
        currentNode.nodeCase NodeCaseExport = [
          "define " makeStringView   @currentNode.@header.cat
        ] [
          "define internal " makeStringView @currentNode.@header.cat
        ] if
      ] if
    ] if

    currentNode.nodeCase NodeCaseCodeRefDeclaration = [currentNode.nodeCase NodeCaseLambda =] || [
      addFunctionVariableInfo
    ] [
      fr: @functionName @processor.@namedFunctions.find;
      fr.success [
        prevNode: fr.value @processor.@nodes.at.get;
        prevNode.state NodeStateCompiled = [
          prevNode.signature currentNode.signature = not [
            ("node " functionName " was defined with another signature") assembleString compilerError
          ] [
            prevNode.mplConvention currentNode.mplConvention = not [
              ("node " functionName " was defined with another convention") assembleString compilerError
            ] [
              currentNode.nodeCase NodeCaseDllDeclaration = [
                prevNode.nodeCase NodeCaseDllDeclaration = not [
                  "dublicated dllimport func declaration" compilerError
                ] when
              ] [
                currentNode.nodeCase NodeCaseDeclaration = [
                  TRUE @currentNode.@emptyDeclaration set
                ] [
                  prevNode.nodeCase NodeCaseDeclaration = [
                    TRUE @prevNode.@emptyDeclaration set
                    indexOfNode @fr.@value set
                  ] [
                    "dublicated func implementation" compilerError
                  ] if
                ] if
              ] if
            ] if
          ] if

          compilable [
            fr: @functionName @currentNode.@namedFunctions.find;
            fr.success not [
              functionName toString indexOfNode @currentNode.@namedFunctions.insert
              refToVar: prevNode.refToVar;

              nameInfo: functionName findNameInfo;
              indexOfNode: refToVar.hostId copy; # suppress assert
              nameInfo refToVar NameCaseFromModule addNameInfo #it is not own local variable
            ] when
          ] when
        ] when
      ] [
        functionName toString indexOfNode @processor.@namedFunctions.insert
        functionName toString indexOfNode @currentNode.@namedFunctions.insert
        addFunctionVariableInfo
      ] if
    ] if
  ] if

  (currentNode.convention retType " " currentNode.irName "(" argumentList ")") @currentNode.@header.catMany
  signature @currentNode.@argTypes set

  processor.options.debug [currentNode.empty not] && [isDeclaration not] && [currentNode.nodeCase NodeCaseEmpty = not] && [
    compilerPositionInfo functionName makeStringView currentNode.irName makeStringView currentNode.funcDbgIndex addFuncDebugInfo
    currentNode.funcDbgIndex moveLastDebugString
    " !dbg !"                @currentNode.@header.cat
    currentNode.funcDbgIndex @currentNode.@header.cat
  ] when

  checkRecursionOfCodeNode

  compilable not [TRUE @currentNode.@empty set] when
] "finalizeCodeNodeImpl" exportFunction

finalizeCodeNode: [
  compilerPositionInfo forcedSignature multiParserResult @currentNode indexOfNode @processor @processorResult finalizeCodeNodeImpl
];

addIndexArrayToProcess: [
  indexArray:;

  i: indexArray.dataSize copy dynamic;
  [
    i 0 > [
      i 1 - @i set
      indexOfAstNode: i indexArray.at;
      indexOfAstNode @currentNode.@unprocessedAstNodes.pushBack
      TRUE
    ] &&
  ] loop
];

nodeHasCode: [
  node:;
  node.emptyDeclaration not [node.uncompilable not] && [node.empty not] && [node.deleted not] && [node.nodeCase NodeCaseCodeRefDeclaration = not] &&
];

{
  signature: CFunctionSignature Cref;
  compilerPositionInfo: CompilerPositionInfo Cref;
  multiParserResult: MultiParserResult Cref;
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
  indexArray:;
  processor:;
  processorResult:;
  copy nodeCase:;
  copy parentIndex:;
  functionName:;
  compileOnce

  addCodeNode
  codeNode: @processor.@nodes.last.get;
  indexOfCodeNode: processor.nodes.dataSize 1 -;
  currentNode: @codeNode;
  indexOfNode: indexOfCodeNode copy;
  failProc: @failProcForProcessor;

  processor.options.autoRecursion @codeNode.@nodeIsRecursive set
  nodeCase                        @codeNode.@nodeCase set
  parentIndex                     @codeNode.@parent set
  @compilerPositionInfo           @codeNode.@position set
  getStackDepth                   @codeNode.@minStackDepth set
  processor.varCount              @codeNode.@variableCountDelta set
  processor.exportDepth           @codeNode.@exportDepth set

  processor.depthOfRecursion 1 + @processor.@depthOfRecursion set
  processor.depthOfRecursion processor.maxDepthOfRecursion > [
    processor.depthOfRecursion @processor.@maxDepthOfRecursion set
  ] when

  maxDepthOfRecursion: 256;
  maxDepthOfPre:       64;

  processor.depthOfRecursion maxDepthOfRecursion > [
    ("max depth of recursion (" maxDepthOfRecursion ") exceeded") assembleString compilerError
    TRUE dynamic @processorResult.@maxDepthExceeded set
  ] when

  processor.depthOfPre maxDepthOfPre > [
    ("max depth of PRE recursion (" maxDepthOfPre ") exceeded") assembleString compilerError
    TRUE dynamic @processorResult.@maxDepthExceeded set
  ] when
  
  #add to match table
  indexArray storageAddress indexOfNode addMatchingNode

  currentNode.parent 0 = [indexOfNode 1 >] && [
    1 dynamic TRUE dynamic processUseModule #definitions
  ] when

  recursionTries: 0 dynamic;
  [
    createLabel

    0 @currentNode.@countOfUCall set
    @currentNode.@labelNames.clear
    @currentNode.@fromModuleNames.clear
    @currentNode.@captureNames.clear
    @currentNode.@unprocessedAstNodes.clear

    processor.options.debug [
      addDebugReserve @currentNode.@funcDbgIndex set
    ] when

    indexArray addIndexArrayToProcess

    [
      currentNode.unprocessedAstNodes.dataSize 0 > [
        indexOfAstNode: currentNode.unprocessedAstNodes.last copy;
        @currentNode.@unprocessedAstNodes.popBack

        astNode: indexOfAstNode multiParserResult.memory.at;
        astNode makeCompilerPosition @currentNode.@position set

        processNode
        compilable [currentNode.state NodeStateNoOutput = not] &&
      ] &&
    ] loop

    compilable [
      functionName finalizeCodeNode
    ] [
      checkPreStackDepth
      unregCodeNodeNames
      indexOfNode deleteNode
      clearRecursionStack
      NodeStateFailed @currentNode.@state set
      TRUE @currentNode.@uncompilable set
    ] if

    recursionTries 1 + @recursionTries set
    recursionTries 64 > ["recursion processing loop length too big" compilerError] when

    compilable [
      currentNode.recursionState NodeRecursionStateNo > [currentNode.state NodeStateCompiled = not] &&
    ] &&
  ] loop

  compilable [currentNode.state NodeStateCompiled =] && [
    indexOfNode concreteMatchingNode
  ] when

  processor.varCount codeNode.variableCountDelta - @codeNode.@variableCountDelta set

  processorResult.findModuleFail [
    moduleName: currentNode.moduleName;
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
    currentNode.parent 0 = [
      currentNode.includedModules [
        id: .value;
        ("node included module: " id processor.nodes.at.get.moduleName) addLog
      ] each
    ] when
  ] when

  indexOfCodeNode
] "astNodeToCodeNode" exportFunction
