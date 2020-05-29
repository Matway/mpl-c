"Array.Array" use
"Owner.owner" use
"String.String" use
"String.assembleString" use
"String.makeStringView" use
"String.print" use
"String.printList" use
"String.splitString" use
"String.toString" use
"control" use

"Block.Block" use
"Block.CFunctionSignature" use
"Block.NameCaseFromModule" use
"Block.NameCaseLocal" use
"Var.Dirty" use
"Var.Dynamic" use
"Var.Field" use
"Var.RefToVar" use
"Var.Schema" use
"Var.ShadowReasonField" use
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
"Var.Virtual" use
"Var.Weak" use
"Var.fullUntemporize" use
"Var.getAlignment" use
"Var.getStorageSize" use
"Var.getVar" use
"Var.isAnyInt" use
"Var.isAutoStruct" use
"Var.isNat" use
"Var.isNumber" use
"Var.isPlain" use
"Var.isReal" use
"Var.isSchema" use
"Var.isUnallocable" use
"Var.isVirtual" use
"Var.makeRefBranch" use
"Var.makeStringId" use
"Var.makeValuePair" use
"Var.markAsUnableToDie" use
"Var.staticityOfVar" use
"Var.varIsMoved" use
"Var.variablesAreSame" use
"astNodeType.AstNodeType" use
"codeNode.addIndexArrayToProcess" use
"codeNode.addNameInfo" use
"codeNode.captureName" use
"codeNode.catPossibleModulesList" use
"codeNode.createNamedVariable" use
"codeNode.createVariable" use
"codeNode.createVariableWithVirtual" use
"codeNode.derefAndPush" use
"codeNode.getName" use
"codeNode.makeStaticity" use
"codeNode.makeVarDirty" use
"codeNode.makeVarTreeDirty" use
"codeNode.makeVarTreeDynamic" use
"codeNode.makeVarTreeDynamicStoraged" use
"codeNode.makeVirtualVarReal" use
"codeNode.processMember" use
"codeNode.processStaticAt" use
"codeNode.push" use
"codeNode.setRef" use
"debugWriter.addGlobalVariableDebugInfo" use
"declarations.callAssign" use
"declarations.callDie" use
"declarations.callInit" use
"declarations.compilerError" use
"declarations.copyVar" use
"declarations.copyVarFromChild" use
"declarations.copyVarFromType" use
"declarations.copyVarToNew" use
"declarations.defaultCall" use
"declarations.defaultPrintStack" use
"declarations.defaultPrintStackTrace" use
"declarations.getMplType" use
"declarations.makeShadowsDynamic" use
"declarations.makeVarString" use
"declarations.processCall" use
"defaultImpl.FailProcForProcessor" use
"defaultImpl.compilable" use
"defaultImpl.createRef" use
"defaultImpl.createRefNoOp" use
"defaultImpl.defaultFailProc" use
"defaultImpl.defaultMakeConstWith" use
"defaultImpl.defaultSet" use
"defaultImpl.findNameInfo" use
"defaultImpl.makeVarRealCaptured" use
"defaultImpl.pop" use
"irWriter.createAllocIR" use
"irWriter.createBinaryOperation" use
"irWriter.createBinaryOperationDiffTypes" use
"irWriter.createCallIR" use
"irWriter.createCastCopyPtrToNew" use
"irWriter.createCastCopyToNew" use
"irWriter.createCheckedCopyToNew" use
"irWriter.createComment" use
"irWriter.createCopyToNew" use
"irWriter.createDerefToRegister" use
"irWriter.createDirectBinaryOperation" use
"irWriter.createDynamicGEP" use
"irWriter.createGEPInsteadOfAlloc" use
"irWriter.createGetCallTrace" use
"irWriter.createGetTextSizeIR" use
"irWriter.createGlobalAliasIR" use
"irWriter.createPlainIR" use
"irWriter.createStoreFromRegister" use
"irWriter.createUnaryOperation" use
"irWriter.createVarExportIR" use
"irWriter.createVarImportIR" use
"irWriter.getIrType" use
"irWriter.getMplSchema" use
"memory.debugMemory" use
"pathUtils.extractExtension" use
"pathUtils.stripExtension" use
"processSubNodes.clearProcessorResult" use
"processSubNodes.processExportFunction" use
"processSubNodes.processIf" use
"processSubNodes.processImportFunction" use
"processSubNodes.processLoop" use
"processor.IRArgument" use
"processor.Processor" use
"staticCall.staticCall" use
"variable.checkUnsizedData" use
"variable.cutValue" use
"variable.findField" use
"variable.isGlobal" use
"variable.refsAreEqual" use
"variable.unglobalize" use
"variable.zeroValue" use

debugMemory [
  "memory.getMemoryMetrics" use
] [] uif

declareBuiltin: [
  virtual declareBuiltinName:;
  virtual declareBuiltinBody:;

  {processor: Processor Ref; block: Block Ref;} () {} [
    processor:;
    block:;
    overload failProc: processor block FailProcForProcessor;
    @declareBuiltinBody ucall
  ] declareBuiltinName exportFunction
];

mplBuiltinProcessAtList: [
  refToStruct: @processor @block pop;
  refToIndex: @processor @block pop;
  compileOnce

  result: RefToVar;

  processor compilable [
    structVar: refToStruct getVar;
    indexVar: refToIndex getVar;

    refToStruct isSchema [

      (
        [processor compilable]
        [
          pointee: VarRef structVar.data.get.refToVar;
          pointeeVar: pointee getVar;
          pointeeVar.data.getTag VarStruct = ~ ["not a combined" @processor block compilerError] when
        ]
        [indexVar.data.getTag VarInt32 = ~ ["index must be Int32" @processor block compilerError] when ]
        [refToIndex staticityOfVar Weak < [ "index must be static" @processor block compilerError] when ]
        [
          index: VarInt32 indexVar.data.get.end 0 cast;
          struct: VarStruct pointeeVar.data.get.get;
          index 0 < [index struct.fields.getSize < ~] || ["index is out of bounds" @processor block compilerError] when
        ] [
          field: index struct.fields.at.refToVar;
          field makeRefBranch VarRef TRUE dynamic TRUE dynamic TRUE dynamic @processor @block createVariableWithVirtual @result set
          refToStruct.mutable @result.setMutable
          @result fullUntemporize
        ]
      ) sequence
    ] [
      (
        [processor compilable]
        [structVar.data.getTag VarStruct = ~ [ "not a combined" @processor block compilerError] when]
        [indexVar.data.getTag VarInt32 = ~ ["index must be Int32" @processor block compilerError] when]
        [
          struct: VarStruct structVar.data.get.get;
          refToIndex staticityOfVar Weak < [
            struct.homogeneous [
              struct.fields.dataSize 0 > [
                # create dynamic getIndex
                realRefToStruct: refToStruct;
                realStructVar: structVar;
                realStruct: struct;
                refToStruct staticityOfVar Virtual < ~ [
                  "can't get dynamic index in virtual struct" @processor block compilerError
                ] when

                @refToIndex makeVarRealCaptured
                firstField: 0 realStruct.fields.at.refToVar;
                fieldRef: firstField @processor @block copyVarFromType;
                firstField getVar.host block is ~ [
                  shadow: RefToVar;
                  @shadow fieldRef ShadowReasonField @processor @block makeShadowsDynamic
                  shadow @fieldRef set
                ] when

                refToStruct.mutable @fieldRef.setMutable
                @fieldRef fullUntemporize
                fieldRef staticityOfVar Virtual < ~ [
                  "dynamic index in combined of virtuals" @processor block compilerError
                ] [
                  fieldRef @processor @block makeVarTreeDynamicStoraged
                  @fieldRef @processor block unglobalize
                  fieldRef refToIndex realRefToStruct @processor @block createDynamicGEP
                  fieldVar: @fieldRef getVar;
                  block.program.dataSize 1 - @fieldVar.@getInstructionIndex set
                  fieldRef @result set
                ] if

                refToStruct.mutable [
                  refToStruct @processor @block makeVarTreeDirty
                ] when
              ] [
                "struct is empty" @processor block compilerError
              ] if
            ] [
              "dynamic index in non-homogeneous combined" @processor block compilerError
            ] if
          ] [
            index: VarInt32 indexVar.data.get.end 0 cast;
            index @refToStruct @processor @block processStaticAt @result set
          ] if
        ]
      ) sequence
    ] if
  ] when

  result
];

mplNumberBinaryOp: [
  exValidator:;
  getResultType:;
  opFunc:;
  getOpName:;
  copy lastTag:;
  copy firstTag:;

  arg2: @processor @block pop;
  arg1: @processor @block pop;

  processor compilable [
    var1: arg1 getVar;
    var2: arg2 getVar;
    var1.data.getTag firstTag < [var1.data.getTag lastTag < ~] || ["first argument invalid" @processor block compilerError] [
      var2.data.getTag firstTag < [var2.data.getTag lastTag < ~] || ["second argument invalid" @processor block compilerError] [
        arg1 arg2 variablesAreSame ~ [
          ("arguments have different schemas, left is " arg1 @processor block getMplType ", right is " arg2 @processor block getMplType) assembleString @processor block compilerError
        ] when
      ] if
    ] if

    processor compilable [
      var1: arg1 getVar;
      var2: arg2 getVar;

      arg1 staticityOfVar Dynamic > arg2 staticityOfVar Dynamic > and [
        var1.data.getTag firstTag lastTag [
          copy tag:;
          value1: tag var1.data.get.end copy;
          value2: tag var2.data.get.end copy;
          resultType: tag @getResultType call;
          value1 value2 @exValidator call
          processor compilable [
            value1 value2 @opFunc call resultType @processor cutValue makeValuePair resultType @processor @block createVariable
            arg1 staticityOfVar arg2 staticityOfVar staticityOfBinResult @processor block makeStaticity
            @processor @block createPlainIR @block push
          ] when
        ] staticCall
      ] [
        @arg1 makeVarRealCaptured
        @arg2 makeVarRealCaptured
        opName: arg1 arg2 @getOpName call;
        var1.data.getTag firstTag lastTag [
          copy tag:;
          value1: tag var1.data.get.end copy;
          value2: tag var2.data.get.end copy;
          resultType: tag @getResultType call;
          result: resultType zeroValue makeValuePair resultType @processor @block createVariable
          Dynamic @processor block makeStaticity
          @processor @block createAllocIR;
          arg1 arg2 @result opName @processor @block createBinaryOperation
          result @block push
        ] staticCall
      ] if
    ] when
  ] when
];

mplNumberBuiltinOp: [
  exValidator:;
  opFunc:;
  getOpName:;

  arg: @processor @block pop;

  processor compilable [
    var: arg getVar;
    arg isReal ~ ["argument invalid" @processor block compilerError] when

    processor compilable [
      arg staticityOfVar Dynamic > [
        var.data.getTag VarReal32 VarReal64 1 + [
          copy tag:;
          value: tag var.data.get.end copy;
          resultType: tag copy;
          value @exValidator call
          processor compilable [
            value @opFunc call resultType @processor cutValue makeValuePair resultType @processor @block createVariable
            arg staticityOfVar @processor block makeStaticity
            @processor @block createPlainIR @block push
          ] when
        ] staticCall
      ] [
        @arg makeVarRealCaptured
        opName: arg @getOpName call;
        var.data.getTag VarReal32 VarReal64 1 + [
          copy tag:;
          value: tag var.data.get.end copy;
          resultType: tag copy;
          result: resultType zeroValue makeValuePair resultType @processor @block createVariable
          Dynamic @processor block makeStaticity
          @processor @block createAllocIR;

          args: IRArgument Array;

          irarg: IRArgument;
          arg @processor @block createDerefToRegister @irarg.@irNameId set
          arg @processor getMplSchema.irTypeId @irarg.@irTypeId set
          FALSE @irarg.@byRef set
          irarg @args.pushBack

          result args String @opName @processor @block createCallIR retName:;

          retName result @processor @block createStoreFromRegister

          result @block push
        ] staticCall
      ] if
    ] when
  ] when
];

mplNumberUnaryOp: [
  exValidator:;
  opFunc:;
  getMidOpName:;
  getOpName:;
  copy lastTag:;
  copy firstTag:;

  arg: @processor @block pop;

  processor compilable [
    var: arg getVar;
    var.data.getTag firstTag < [var.data.getTag lastTag < ~] || ["argument invalid" @processor block compilerError] when

    processor compilable [
      arg staticityOfVar Dynamic > [
        var.data.getTag firstTag lastTag [
          copy tag:;
          value: tag var.data.get.end copy;
          resultType: tag copy;
          value @exValidator call
          processor compilable [
            value @opFunc call resultType @processor cutValue makeValuePair resultType @processor @block createVariable
            arg staticityOfVar @processor block makeStaticity
            @processor @block createPlainIR @block push
          ] when
        ] staticCall
      ] [
        @arg makeVarRealCaptured
        opName: arg @getOpName call;
        mopName: arg @getMidOpName call;
        var.data.getTag firstTag lastTag [
          copy tag:;
          value: tag var.data.get.end copy;
          resultType: tag copy;
          result: resultType zeroValue makeValuePair resultType @processor @block createVariable
          Dynamic @processor block makeStaticity
          @processor @block createAllocIR;
          arg @result opName mopName @processor @block createUnaryOperation
          result @block push
        ] staticCall
      ] if
    ] when
  ] when
];

mplShiftBinaryOp: [
  opFunc:;
  getOpName:;

  arg2: @processor @block pop;
  arg1: @processor @block pop;

  processor compilable [
    var1: arg1 getVar;
    var2: arg2 getVar;
    arg1 isAnyInt ~ ["first argument invalid" @processor block compilerError] [
      arg2 isNat ~ ["second argument invalid" @processor block compilerError] when
    ] if

    processor compilable [
      var1: arg1 getVar;
      var2: arg2 getVar;

      arg1 staticityOfVar Dynamic > arg2 staticityOfVar Dynamic > and [
        var1.data.getTag VarNat8 VarIntX 1 + [
          copy tag1:;
          var2.data.getTag VarNat8 VarNatX 1 + [
            copy tag2:;
            value1: tag1 var1.data.get.end copy;
            value2: tag2 var2.data.get.end copy;
            resultType: tag1 copy;
            value2 63n64 > ["shift value must be less than 64" @processor block compilerError] when

            processor compilable [
              value1 value2 @opFunc call resultType @processor cutValue makeValuePair resultType @processor @block createVariable
              arg1 staticityOfVar arg2 staticityOfVar staticityOfBinResult @processor @block makeStaticity
              @processor @block createPlainIR @block push
            ] when
          ] staticCall
        ] staticCall
      ] [
        @arg1 makeVarRealCaptured
        @arg2 makeVarRealCaptured

        opName: arg1 arg2 @getOpName call;
        var1.data.getTag VarNat8 VarIntX 1 + [
          copy tag:;
          resultType: tag copy;
          result: resultType zeroValue makeValuePair resultType @processor @block createVariable
          Dynamic @processor @block makeStaticity
          @processor @block createAllocIR;
          arg1 @processor getStorageSize arg2 @processor getStorageSize = [
            arg1 arg2 @result opName @processor @block createBinaryOperation
          ] [
            arg1 arg2 @result opName @processor @block createBinaryOperationDiffTypes
          ] if

          result @block push
        ] staticCall
      ] if
    ] when
  ] when
];

parseFieldToSignatureCaptureArray: [
  refToStruct:;
  result: RefToVar Array;
  varStruct: refToStruct getVar;
  varStruct.data.getTag VarStruct = ~ ["argument list must be a struct" @processor block compilerError] when

  processor compilable [
    VarStruct varStruct.data.get.get.fields [
      refToVar: .refToVar;
      refToVar isVirtual ["input cannot be virtual" @processor block compilerError] when
      refToVar @result.pushBack
    ] each
  ] when

  result
];

parseSignature: [
  result: CFunctionSignature;
  (
    [processor compilable]
    [options: @processor @block pop;]
    [
      optionsVar: options getVar;
      optionsVar.data.getTag VarStruct = ~ ["options must be a struct" @processor block compilerError] when
    ] [
      optionsStruct: VarStruct optionsVar.data.get.get;
      hasConvention: FALSE dynamic;
      optionsStruct.fields [
        f:;
        f.nameInfo (
          processor.variadicNameInfo [
            variadicRefToVar: f.refToVar;
            variadicVar: variadicRefToVar getVar;
            (
              [processor compilable]
              [variadicVar.data.getTag VarCond = ~ ["value must be Cond" @processor block compilerError] when]
              [variadicRefToVar staticityOfVar Weak < ["value must be Static" @processor block compilerError] when]
              [VarCond variadicVar.data.get.end @result.@variadic set]
            ) sequence
          ]
          processor.conventionNameInfo [
            conventionRefToVarRef: f.refToVar;
            conventionVarRef: conventionRefToVarRef getVar;
            (
              [processor compilable]
              [conventionVarRef.data.getTag VarRef = ~ ["value must be String Ref" @processor block compilerError] when]
              [conventionRefToVarRef staticityOfVar Weak < ["value must be Static" @processor block compilerError] when]
              [
                conventionRefToVar: VarRef conventionVarRef.data.get.refToVar;
                conventionVar: conventionRefToVar getVar;
                conventionVar.data.getTag VarString = ~ ["value must be String Ref" @processor block compilerError] when
              ]
              [conventionRefToVar staticityOfVar Weak < ["value must be Static" @processor block compilerError] when]
              [
                string: VarString conventionVar.data.get;
                string @result.@convention set
                TRUE @hasConvention set
              ]
            ) sequence
          ] [
            ("unknown option: " f.nameInfo processor.nameManager.getText) assembleString @processor block compilerError
          ]
        ) case
      ] each
    ]
    [
      hasConvention ~ [
        String @result.@convention set
      ] when

      return: @processor @block pop;
      processor compilable [
        return isVirtual [
          returnVar: return getVar;
          returnVar.data.getTag VarStruct = ~ [(return @processor block getMplType " can not be a return type") assembleString @processor block compilerError] when
        ] [
          #todo: detect temporality
          returnVar: return getVar;
          returnVar.temporary [
            return @result.@outputs.pushBack
          ] [
            @return TRUE dynamic @processor @block createRef @result.@outputs.pushBack
          ] if
        ] if
      ] when
    ]
    [arguments: @processor @block pop;]
    [
      arguments parseFieldToSignatureCaptureArray @result.@inputs set
    ]
  ) sequence
  result
];

staticityOfBinResult: [
  s1:; s2:;
  s1 Dynamic > ~ s2 Dynamic > ~ or [
    Dynamic
  ] [
    s1 Weak = s2 Weak = and [
      Weak
    ] [
      Static
    ] if
  ] if
];

[
  field: mplBuiltinProcessAtList;
  processor compilable [
    field @processor @block setRef
  ] when
] "mplBuiltinExclamation" @declareBuiltin ucall

[
  (
    [processor compilable]
    [refToStr2: @processor @block pop;]
    [refToStr2 staticityOfVar Weak < ["must be static string" @processor block compilerError] when]
    [
      varStr2: refToStr2 getVar;
      varStr2.data.getTag VarString = ~ ["must be static string" @processor block compilerError] when
    ]
    [refToStr1: @processor @block pop;]
    [refToStr1 staticityOfVar Weak < ["must be static string" @processor block compilerError] when]
    [
      varStr1: refToStr1 getVar;
      varStr1.data.getTag VarString = ~ ["must be static string" @processor block compilerError] when
    ]
    [(VarString varStr1.data.get VarString varStr2.data.get) assembleString @processor @block makeVarString @block push]
  ) sequence
] "mplBuiltinStrCat" @declareBuiltin ucall

[
  VarNat8 VarReal64 1 + [a2:; a1:; a2 isReal ["fmul" makeStringView]["mul" makeStringView] if] [*] [copy] [y:; x:;] mplNumberBinaryOp
] "mplBuiltinMul" @declareBuiltin ucall

[
  VarNat8 VarReal64 1 + [a2:; a1:; a2 isReal ["fadd" makeStringView]["add" makeStringView] if] [+] [copy] [y:; x:;] mplNumberBinaryOp
] "mplBuiltinAdd" @declareBuiltin ucall

[
  VarNat8 VarReal64 1 + [a2:; a1:; a2 isReal ["fsub" makeStringView]["sub" makeStringView] if] [-] [copy] [y:; x:;] mplNumberBinaryOp
] "mplBuiltinSub" @declareBuiltin ucall

[
  VarNat8 VarReal64 1 + [a2:; a1:; a2 isReal ["fdiv" makeStringView][a2 isNat ["udiv" makeStringView] ["sdiv" makeStringView] if] if] [/] [copy] [
    y:; x:;
    y y - y = ["division by zero" @processor block compilerError] when
  ] mplNumberBinaryOp
] "mplBuiltinDiv" @declareBuiltin ucall

[
  VarNat8 VarReal64 1 + [
    a2:; a1:; a2 isReal ["fcmp olt" makeStringView][a2 isNat ["icmp ult" makeStringView] ["icmp slt" makeStringView] if] if
  ] [<] [t:; VarCond] [y:; x:;] mplNumberBinaryOp
] "mplBuiltinLess" @declareBuiltin ucall

[
  arg2: @processor @block pop;
  arg1: @processor @block pop;

  processor compilable [
    comparable: [
      arg:;
      arg isPlain [arg getVar.data.getTag VarString =] ||
    ];

    var1: arg1 getVar;
    var2: arg2 getVar;

    arg1 comparable ~ [ "first argument is not comparable" @processor block compilerError ] [
      arg2 comparable ~ [ "second argument is not comparable" @processor block compilerError ] [
        arg1 arg2 variablesAreSame ~ [
          ("arguments have different schemas, left is " arg1 @processor block getMplType ", right is " arg2 @processor block getMplType) assembleString @processor block compilerError
        ] when
      ] if
    ] if

    processor compilable [
      arg1 staticityOfVar Dynamic > arg2 staticityOfVar Dynamic > and [
        var1.data.getTag VarString = [
          value1: VarString var1.data.get;
          value2: VarString var2.data.get;
          value1 value2 = makeValuePair VarCond @processor @block createVariable
          arg1 staticityOfVar arg2 staticityOfVar staticityOfBinResult @processor block makeStaticity
          @processor @block createPlainIR @block push
        ] [
          var1.data.getTag VarCond VarReal64 1 + [
            copy tag:;
            value1: tag var1.data.get.end copy;
            value2: tag var2.data.get.end copy;
            value1 value2 = makeValuePair VarCond @processor @block createVariable
            arg1 staticityOfVar arg2 staticityOfVar staticityOfBinResult @processor block makeStaticity
            @processor @block createPlainIR @block push
          ] staticCall
        ] if
      ] [
        @arg1 makeVarRealCaptured
        @arg2 makeVarRealCaptured

        var1.data.getTag VarString = [
          result: FALSE makeValuePair VarCond @processor @block createVariable Dynamic @processor @block makeStaticity @processor @block createAllocIR;
          arg1 arg2 @result "icmp eq" makeStringView @processor @block createBinaryOperation
          result @block push
        ] [
          arg1 isReal [
            var1.data.getTag VarReal32 VarReal64 1 + [
              copy tag:;
              result: FALSE makeValuePair VarCond @processor @block createVariable Dynamic @processor @block makeStaticity @processor @block createAllocIR;
              arg1 arg2 @result "fcmp oeq" @processor @block createBinaryOperation
              result @block push
            ] staticCall
          ] [
            var1.data.getTag VarCond VarIntX 1 + [
              copy tag:;
              result: FALSE makeValuePair VarCond @processor @block createVariable Dynamic @processor @block makeStaticity @processor @block createAllocIR;
              arg1 arg2 @result "icmp eq" @processor @block createBinaryOperation
              result @block push
            ] staticCall
          ] if
        ] if
      ] if
    ] when
  ] when
] "mplBuiltinEqual" @declareBuiltin ucall

[
  VarNat8 VarReal64 1 + [
    a2:; a1:; a2 isReal ["fcmp ogt" makeStringView][a2 isNat ["icmp ugt" makeStringView] ["icmp sgt" makeStringView] if] if
  ] [>] [t:; VarCond] [y:; x:;] mplNumberBinaryOp
] "mplBuiltinGreater" @declareBuiltin ucall

[
  field: mplBuiltinProcessAtList;
  processor compilable [
    field isVirtual [@field @processor @block makeVirtualVarReal @field set] when
    @field @processor @block derefAndPush
  ] when
] "mplBuiltinAt" @declareBuiltin ucall

[
  COMPILER_SOURCE_VERSION 0i64 cast makeValuePair VarInt32 @processor @block createVariable Static @processor @block makeStaticity @processor @block createPlainIR @block push
] "mplBuiltinCompilerVersion" @declareBuiltin ucall

[
  processor.options.debug makeValuePair VarCond @processor @block createVariable Static @processor @block makeStaticity @processor @block createPlainIR @block push
] "mplBuiltinDebug" @declareBuiltin ucall

[
  FALSE makeValuePair VarCond @processor @block createVariable @processor @block createPlainIR @block push
] "mplBuiltinFalse" @declareBuiltin ucall

[
  processor.options.logs makeValuePair VarCond @processor @block createVariable Static @processor @block makeStaticity @processor @block createPlainIR @block push
] "mplBuiltinHasLogs" @declareBuiltin ucall

[
  LF toString @processor @block makeVarString @block push
] "mplBuiltinLF" @declareBuiltin ucall

[
  TRUE makeValuePair VarCond @processor @block createVariable @processor @block createPlainIR @block push
] "mplBuiltinTrue" @declareBuiltin ucall

[
  TRUE dynamic @processor.@usedFloatBuiltins set
  arg2: @processor @block pop;
  arg1: @processor @block pop;

  processor compilable [
    var1: arg1 getVar;
    var2: arg2 getVar;
    arg1 isReal ~ ["first argument invalid" @processor block compilerError] [
      arg2 isReal ~ ["second argument invalid" @processor block compilerError] [
        arg1 arg2 variablesAreSame ~ [
          ("arguments have different schemas, left is " arg1 @processor block getMplType ", right is " arg2 @processor block getMplType) assembleString @processor block compilerError
        ] when
      ] if
    ] if

    processor compilable [
      var1: arg1 getVar;
      var2: arg2 getVar;

      arg1 staticityOfVar Dynamic > arg2 staticityOfVar Dynamic > and [
        var1.data.getTag VarReal32 VarReal64 1 + [
          copy tag:;
          value1: tag var1.data.get.end copy;
          value2: tag var2.data.get.end copy;
          resultType: tag copy;

          processor compilable [
            value1 value2 ^ resultType @processor cutValue makeValuePair resultType @processor @block createVariable
            arg1 staticityOfVar arg2 staticityOfVar staticityOfBinResult @processor @block makeStaticity
            @processor @block createPlainIR @block push
          ] when
        ] staticCall
      ] [
        @arg1 makeVarRealCaptured
        @arg2 makeVarRealCaptured

        var1.data.getTag VarReal32 VarReal64 1 + [
          copy tag:;
          resultType: tag copy;
          result: resultType zeroValue makeValuePair resultType @processor @block createVariable
          Dynamic @processor @block makeStaticity
          @processor @block createAllocIR;

          args: IRArgument Array;

          irarg: IRArgument;
          FALSE @irarg.@byRef set
          arg1 @processor @block createDerefToRegister @irarg.@irNameId set
          arg1 @processor getMplSchema.irTypeId @irarg.@irTypeId set
          irarg @args.pushBack
          arg2 @processor @block createDerefToRegister @irarg.@irNameId set
          arg2 @processor getMplSchema.irTypeId @irarg.@irTypeId set
          irarg @args.pushBack

          result args String tag VarReal32 = ["@llvm.pow.f32" makeStringView] ["@llvm.pow.f64" makeStringView] if @processor @block createCallIR retName:;

          @retName result @processor @block createStoreFromRegister

          result @block push
        ] staticCall
      ] if
    ] when
  ] when
] "mplBuiltinPow" @declareBuiltin ucall

[
  refToSchema: @processor @block pop;
  refToVar: @processor @block pop;

  processor compilable [
    var: refToVar getVar;
    varSchema: refToSchema getVar;
    var.data.getTag VarNatX = [
      var: refToVar getVar;
      varSchema: refToSchema getVar;
      schemaOfResult: RefToVar;
      varSchema.data.getTag VarRef = [
        refToSchema isSchema [
          VarRef varSchema.data.get.refToVar @processor @block copyVarFromChild @schemaOfResult set
          refToSchema.mutable schemaOfResult.mutable and @schemaOfResult.setMutable
        ] [
          [FALSE] "Unable in current semantic!" assert
        ] if
      ] [
        refToSchema @schemaOfResult set
      ] if

      schemaOfResult isVirtual [
        "pointee is virtual, cannot cast" @processor block compilerError
      ] [
        refBranch: schemaOfResult makeRefBranch;
        FALSE @refBranch.@refToVar.setMoved

        refToDst: refBranch VarRef @processor @block createVariable;
        Dirty makeValuePair @refToDst getVar.@staticity set
        refToVar @refToDst "inttoptr" @processor @block createCastCopyToNew
        @refToDst @processor @block derefAndPush
      ] if
    ] [
      "address must be a NatX" @processor block compilerError
    ] if
  ] when
] "mplBuiltinAddressToReference" @declareBuiltin ucall

[
  refToVar: @processor @block pop;
  processor compilable [
    refToVar isVirtual [
      refToVar isSchema [
        pointee: VarRef refToVar getVar.data.get.refToVar;
        pointee isVirtual [
          0nx
        ] [
          pointee @processor block checkUnsizedData
          pointee @processor getAlignment
        ] if
      ] [
        0nx
      ] if
    ] [
      refToVar @processor block checkUnsizedData
      refToVar @processor getAlignment
    ] if

    0n64 cast makeValuePair VarNatX @processor @block createVariable Static @processor @block makeStaticity @processor @block createPlainIR @block push
  ] when
] "mplBuiltinAlignment" @declareBuiltin ucall

[
  VarCond VarNatX 1 + [a2:; a1:; "and" makeStringView] [and] [copy] [y:; x:;] mplNumberBinaryOp
] "mplBuiltinAnd" @declareBuiltin ucall

[
  refToCount:   @processor @block pop;
  refToElement: @processor @block pop;
  processor compilable [
    @refToElement fullUntemporize
    varCount: refToCount getVar;
    varCount.data.getTag VarInt32 = ~ ["count must be Int32" @processor block compilerError] when
    processor compilable [
      refToCount staticityOfVar Dynamic > ~ ["count must be static" @processor block compilerError] when
      processor compilable [
        count: VarInt32 varCount.data.get.end 0 cast;
        count 0 < [
          "count must not be negative" @processor block compilerError
        ] when

        processor compilable [
          struct: Struct;
          staticity: refToElement staticityOfVar;
          staticity Weak = [Dynamic @staticity set] when

          i: 0 dynamic;
          [
            i count < [
              element: refToElement @processor @block copyVar staticity @processor @block makeStaticity;
              field: Field;
              processor.emptyNameInfo @field.@nameInfo set
              element @field.@refToVar set
              field @struct.@fields.pushBack
              i 1 + @i set TRUE
            ] &&
          ] loop

          result: @struct move owner VarStruct @processor @block createVariable;
          result isVirtual ~ [@result @processor @block createAllocIR @result set] when
          resultStruct: VarStruct @result getVar.@data.get.get;

          i: 0 dynamic;
          [
            i resultStruct.fields.dataSize < [
              field: i @resultStruct.@fields.at;
              field.refToVar isVirtual [
                field.refToVar isAutoStruct ["unable to copy virtual autostruct" @processor block compilerError] when
              ] [
                @field.@refToVar @processor block unglobalize
                block.program.dataSize @field.@refToVar getVar.@allocationInstructionIndex set
                "no alloc..." @block createComment # fake instruction
                @refToElement @field.@refToVar @processor @block createCheckedCopyToNew
                @field.@refToVar markAsUnableToDie
                @field.@refToVar i result @processor @block createGEPInsteadOfAlloc
              ] if
              i 1 + @i set processor compilable
            ] &&
          ] loop

          result @block.@candidatesToDie.pushBack
          result @block push
        ] when
      ] when
    ] when
  ] when
] "mplBuiltinArray" @declareBuiltin ucall

[
  @processor @block defaultCall
] "mplBuiltinCall" @declareBuiltin ucall

[
  (
    [processor compilable]
    [refToName: @processor @block pop;]
    [
      refToName staticityOfVar Weak < ["method name must be a static string" @processor block compilerError] when
    ]
    [
      varName: refToName getVar;
      varName.data.getTag VarString = ~ ["method name must be a static string" @processor block compilerError] when
    ]
    [
      fieldNameInfo: VarString varName.data.get makeStringView @processor findNameInfo;
      fieldNameInfo @processor @block pop 0 dynamic @processor @block processMember
    ]
  ) sequence
] "mplBuiltinCallField" @declareBuiltin ucall

[
  refToSchema: @processor @block pop;
  refToVar:    @processor @block pop;

  processor compilable [
    varSrc: refToVar getVar;
    varSchema: refToSchema getVar;
    varSchema.data.getTag VarRef = [refToSchema isVirtual] && [
      VarRef varSchema.data.get.refToVar @processor @block copyVarFromChild @refToSchema set
      refToSchema getVar !varSchema
    ] when

    refToVar isNumber refToSchema isNumber and [
      processor compilable [
        refToVar staticityOfVar Dynamic > [
          refToDst: RefToVar;

          varSrc.data.getTag VarNat8 VarReal64 1 + [
            copy tagSrc:;
            branchSrc: tagSrc varSrc.data.get.end;
            varSchema.data.getTag VarNat8 VarReal64 1 + [
              copy tagDst:;
              branchSchema: tagDst @varSchema.@data.get.end;
              branchSrc branchSchema cast tagDst @processor cutValue makeValuePair tagDst @processor @block createVariable @processor @block createPlainIR @refToDst set
            ] staticCall
          ] staticCall

          refToVar staticityOfVar makeValuePair @refToDst getVar.@staticity set
          refToDst @block push
        ] [
          refToDst: RefToVar;
          varSchema: refToSchema getVar;
          varSchema.data.getTag VarNat8 VarReal64 1 + [
            copy tagDst:;
            branchSchema: tagDst @varSchema.@data.get.end;
            branchSchema makeValuePair tagDst @processor @block createVariable @refToDst set
          ] staticCall

          Dynamic makeValuePair @refToDst getVar.@staticity set

          # a lot of cases for different casts
          refToVar isReal refToSchema isReal or [
            refToVar isReal refToSchema isReal and [
              #Real to Real
              refToVar @processor getStorageSize refToSchema @processor getStorageSize = [
                @refToVar @refToDst @processor @block createCopyToNew
              ] [
                refToVar @processor getStorageSize refToSchema @processor getStorageSize < [
                  refToVar @refToDst "fpext" @processor @block createCastCopyToNew
                ] [
                  refToVar @refToDst "fptrunc" @processor @block createCastCopyToNew
                ] if
              ] if
            ] [
              refToVar isAnyInt [
                #Int to Real
                refToVar isNat [
                  refToVar @refToDst "uitofp" @processor @block createCastCopyToNew
                ] [
                  refToVar @refToDst "sitofp" @processor @block createCastCopyToNew
                ] if
              ] [
                #Real to Int
                [refToSchema isAnyInt] "Wrong cast number case!" assert
                refToSchema isNat [
                  refToVar @refToDst "fptoui" @processor @block createCastCopyToNew
                ] [
                  refToVar @refToDst "fptosi" @processor @block createCastCopyToNew
                ] if
              ] if
            ] if
          ] [
            #Int to Int
            refToVar @processor getStorageSize refToSchema @processor getStorageSize = [
              @refToVar @refToDst @processor @block createCopyToNew
            ] [
              refToVar @processor getStorageSize refToSchema @processor getStorageSize < [
                refToVar isNat [
                  refToVar @refToDst "zext" @processor @block createCastCopyToNew
                ] [
                  refToVar @refToDst "sext" @processor @block createCastCopyToNew
                ] if
              ] [
                refToVar @refToDst "trunc" @processor @block createCastCopyToNew
              ] if
            ] if
          ] if
          # here ends cast case list

          refToDst @block push
        ] if
      ] when
    ] [
      "can cast only numbers" @processor block compilerError
    ] if
  ] when
] "mplBuiltinCast" @declareBuiltin ucall

[
  TRUE dynamic @processor.@usedFloatBuiltins set
  [a:; a getVar.data.getTag VarReal32 = ["@llvm.ceil.f32" makeStringView]["@llvm.ceil.f64" makeStringView] if
  ] [ceil] [x:;] mplNumberBuiltinOp
] "mplBuiltinCeil" @declareBuiltin ucall

[
  (
    [processor compilable]
    [signature: parseSignature;]
    [
      name: ("null." processor.blocks.getSize) assembleString;
      newBlock: signature name makeStringView TRUE dynamic @processor @block processImportFunction Block addressToReference;
    ]
    [
      gnr: newBlock.varNameInfo @processor @block getName;
      cnr: @gnr 0 dynamic @processor @block processor.positions.last.file captureName;
      refToVar: cnr.refToVar copy;

      refToVar @block push
    ]
  ) sequence
] "mplBuiltinCodeRef" @declareBuiltin ucall

[
  TRUE dynamic @block.@nodeCompileOnce set
] "mplBuiltinCompileOnce" @declareBuiltin ucall

[TRUE @processor @block defaultMakeConstWith] "mplBuiltinConst" @declareBuiltin ucall

[
  refToVar: @processor @block pop;
  processor compilable [
    refToVar isVirtual ~ [@refToVar makeVarRealCaptured] when

    refToVar getVar.temporary [
      "temporary objects cannot be copied" @processor block compilerError
    ] [
      refToVar getVar.data.getTag VarImport = [
        "functions cannot be copied" @processor block compilerError
      ] [
        refToVar getVar.data.getTag VarString = [
          "builtin-strings cannot be copied" @processor block compilerError
        ] [
          result: refToVar @processor @block copyVarToNew;
          result isVirtual [
            result isAutoStruct ["unable to copy virtual autostruct" @processor block compilerError] when
          ] [
            TRUE @result.setMutable
            @refToVar @result @processor @block createCopyToNew
          ] if

          result @block push
        ] if
      ] if
    ] if
  ] when
] "mplBuiltinCopy" @declareBuiltin ucall

[
  TRUE dynamic @processor.@usedFloatBuiltins set
  [a:; a getVar.data.getTag VarReal32 = ["@llvm.cos.f32" makeStringView]["@llvm.cos.f64" makeStringView] if
  ] [cos] [x:;] mplNumberBuiltinOp
] "mplBuiltinCos" @declareBuiltin ucall

[
  (
    [processor compilable]
    [refToName: @processor @block pop;]
    [
      refToName staticityOfVar Weak < ["name must be static string" @processor block compilerError] when
    ]
    [
      varName: refToName getVar;
      varName.data.getTag VarString = ~ ["name must be static string" @processor block compilerError] when
    ]
    [
      VarString varName.data.get makeStringView @processor findNameInfo @processor @block pop @processor @block createNamedVariable
    ]
  ) sequence
] "mplBuiltinDef" @declareBuiltin ucall

[
  refToVar: @processor @block pop;
  processor compilable [
    refToVar @processor @block makeVarTreeDirty
    refToVar @block push
  ] when
] "mplBuiltinDirty" @declareBuiltin ucall

[
  (
    [processor compilable]
    [block.parent 0 = ~ ["export must be global" @processor block compilerError] when]
    [refToName: @processor @block pop;]
    [refToName staticityOfVar Weak < ["function name must be static string" @processor block compilerError] when]
    [
      varName: refToName getVar;
      varName.data.getTag VarString = ~ ["function name must be static string" @processor block compilerError] when
    ]
    [refToBody: @processor @block pop;]
    [
      varBody: refToBody getVar;
      varBody.data.getTag VarCode = ~ ["must be a code" @processor block compilerError] when
    ]
    [signature: parseSignature;]
    [
      astNode: VarCode varBody.data.get.index processor.multiParserResult.memory.at;
      index: signature astNode VarCode varBody.data.get.file VarString varName.data.get makeStringView FALSE dynamic @processor @block processExportFunction;
    ]
  ) sequence
] "mplBuiltinExportFunction" @declareBuiltin ucall

[
  (
    [processor compilable]
    [block.parent 0 = ~ ["export must be global" @processor block compilerError] when]
    [refToName: @processor @block pop;]
    [refToVar: @processor @block pop;]
    [refToName staticityOfVar Weak < ["variable name must be static string" @processor block compilerError] when]
    [
      varName: refToName getVar;
      varName.data.getTag VarString = ~ ["variable name must be static string" @processor block compilerError] when
    ] [
      refToVar isVirtual ["cannot export virtual var" @processor block compilerError] when
    ] [
      refToVar getVar.temporary ~ [
        @refToVar TRUE dynamic @processor @block createRef @refToVar set
      ] when
      var: @refToVar getVar;
      FALSE @var.@temporary set
    ] [
      name: VarString varName.data.get;
      oldIrNameId: var.irNameId copy;
      oldInstructionIndex: var.globalDeclarationInstructionIndex copy;
      ("@" name) assembleString @processor makeStringId @var.@irNameId set
      instruction: var.globalDeclarationInstructionIndex @processor.@prolog.at;
      @refToVar @processor @block createVarExportIR drop
      @processor.@prolog.last move @instruction set
      @processor.@prolog.popBack
      TRUE @refToVar.setMutable
      oldIrNameId var.irNameId refToVar @processor getMplSchema.irTypeId @processor createGlobalAliasIR
      oldInstructionIndex @var.@globalDeclarationInstructionIndex set

      nameInfo: name makeStringView @processor findNameInfo;

      {
        addNameCase: NameCaseLocal;
        refToVar:    refToVar copy;
        nameInfo:    nameInfo copy;
      } @processor @block addNameInfo

      processor.options.debug [
        d: nameInfo refToVar @processor block addGlobalVariableDebugInfo;
        globalInstruction: var.globalDeclarationInstructionIndex @processor.@prolog.at;
        ", !dbg !"   @globalInstruction.cat
        d            @globalInstruction.cat
      ] when
    ]
  ) sequence
] "mplBuiltinExportVariable" @declareBuiltin ucall

[
  @processor @block defaultFailProc
] "mplBuiltinFailProc" @declareBuiltin ucall

[
  refToVar: @processor @block pop;
  processor compilable [
    var: refToVar getVar;
    refToVar isSchema [
      pointee: VarRef var.data.get.refToVar;
      pointeeVar: pointee getVar;
      pointeeVar.data.getTag VarStruct = ~ ["not a combined" @processor block compilerError] when
      processor compilable [
        VarStruct pointeeVar.data.get.get.fields.dataSize 0i64 cast makeValuePair VarInt32 @processor @block createVariable Static @processor @block makeStaticity @processor @block createPlainIR @block push
      ] when
    ] [
      var.data.getTag VarStruct = ~ ["not a combined" @processor block compilerError] when
      processor compilable [
        VarStruct var.data.get.get.fields.dataSize 0i64 cast makeValuePair VarInt32 @processor @block createVariable Static @processor @block makeStaticity @processor @block createPlainIR @block push
      ] when
    ] if
  ] when
] "mplBuiltinFieldCount" @declareBuiltin ucall

[
  (
    [processor compilable]
    [refToName: @processor @block pop;]
    [refToStruct: @processor @block pop;]
    [
      refToName staticityOfVar Weak < ["name must be static string" @processor block compilerError] when
    ]
    [
      varName: refToName getVar;
      varName.data.getTag VarString = ~ ["name must be static string" @processor block compilerError] when
    ]
    [
      refToStruct getVar.data.getTag VarStruct = ~ ["not a combined " @processor block compilerError] when
    ] [
      string: VarString varName.data.get;
      fr: string makeStringView @processor findNameInfo refToStruct @processor block findField;
    ] [
      fr.success ~ [(refToStruct @processor block getMplType " has no field " string) assembleString @processor block compilerError] when
    ] [
      fr.index Int64 cast makeValuePair VarInt32 @processor @block createVariable Static @processor @block makeStaticity @processor @block createPlainIR @block push
    ]
  ) sequence
] "mplBuiltinFieldIndex" @declareBuiltin ucall

[
  refToCount: @processor @block pop;
  refToVar:   @processor @block pop;
  processor compilable [
    varCount: refToCount getVar;
    varCount.data.getTag VarInt32 = ~ ["index must be Int32" @processor block compilerError] when
    processor compilable [
      refToCount staticityOfVar Dynamic > ~ ["index must be static" @processor block compilerError] when
      processor compilable [
        count: VarInt32 varCount.data.get.end 0 cast;
        var: refToVar getVar;
        refToVar isSchema [
          pointee: VarRef var.data.get.refToVar;
          pointeeVar: pointee getVar;
          pointeeVar.data.getTag VarStruct = ~ ["not a combined" @processor block compilerError] when
          processor compilable [
            count VarStruct pointeeVar.data.get.get.fields.at.nameInfo processor.nameManager.getText @processor @block makeVarString @block push
          ] when
        ] [
          var.data.getTag VarStruct = ~ ["not a combined" @processor block compilerError] when
          processor compilable [
            struct: VarStruct var.data.get.get;
            count 0 < [count struct.fields.getSize < ~] || ["index is out of bounds" @processor block compilerError] when
            processor compilable [
              count struct.fields.at.nameInfo processor.nameManager.getText @processor @block makeVarString @block push
            ] when
          ] when
        ] if
      ] when
    ] when
  ] when
] "mplBuiltinFieldName" @declareBuiltin ucall

[
  TRUE dynamic @processor.@usedFloatBuiltins set
  [a:; a getVar.data.getTag VarReal32 = ["@llvm.floor.f32" makeStringView]["@llvm.floor.f64" makeStringView] if
  ] [floor] [x:;] mplNumberBuiltinOp
] "mplBuiltinFloor" @declareBuiltin ucall

[
  varPrev:   0n64 makeValuePair VarNatX @processor @block createVariable;
  varNext:   0n64 makeValuePair VarNatX @processor @block createVariable;
  varName:   String @processor @block makeVarString TRUE dynamic @processor @block createRefNoOp;
  varLine:   0i64 makeValuePair VarInt32 @processor @block createVariable;
  varColumn: 0i64 makeValuePair VarInt32 @processor @block createVariable;

  @varPrev   @processor @block makeVarDirty
  @varNext   @processor @block makeVarDirty
  @varName   @processor @block makeVarDirty
  @varLine   @processor @block makeVarDirty
  @varColumn @processor @block makeVarDirty

  struct: Struct;
  5 @struct.@fields.resize

  varPrev 0 @struct.@fields.at.@refToVar set
  "prev" makeStringView @processor findNameInfo 0 @struct.@fields.at.@nameInfo set

  varNext 1 @struct.@fields.at.@refToVar set
  "next" makeStringView @processor findNameInfo 1 @struct.@fields.at.@nameInfo set

  varName 2 @struct.@fields.at.@refToVar set
  "name" makeStringView @processor findNameInfo 2 @struct.@fields.at.@nameInfo set

  varLine 3 @struct.@fields.at.@refToVar set
  "line" makeStringView @processor findNameInfo 3 @struct.@fields.at.@nameInfo set

  varColumn 4 @struct.@fields.at.@refToVar set
  "column" makeStringView @processor findNameInfo 4 @struct.@fields.at.@nameInfo set

  first: @struct move owner VarStruct @processor @block createVariable;
  last: first @processor @block copyVar;

  firstRef: @first FALSE dynamic @processor @block createRefNoOp;
  lastRef:  @last  FALSE dynamic @processor @block createRefNoOp;

  @firstRef @processor @block makeVarDirty
  @lastRef  @processor @block makeVarDirty

  resultStruct: Struct;
  2 @resultStruct.@fields.resize

  firstRef             0 @resultStruct.@fields.at.@refToVar set
  "first" makeStringView @processor findNameInfo 0 @resultStruct.@fields.at.@nameInfo set

  lastRef             1 @resultStruct.@fields.at.@refToVar set
  "last" makeStringView @processor findNameInfo 1 @resultStruct.@fields.at.@nameInfo set

  result: @resultStruct move owner VarStruct @processor @block createVariable @processor @block createAllocIR;
  first @processor getIrType result @processor getIrType result @processor @block createGetCallTrace
  result @block push
] "mplBuiltinGetCallTrace" @declareBuiltin ucall

[
  (
    [processor compilable]
    [refToName:   @processor @block pop;]
    [refToStruct: @processor @block pop;]
    [
      refToName staticityOfVar Weak < ["name must be static string" @processor block compilerError] when
    ]
    [
      varName: refToName getVar;
      varName.data.getTag VarString = ~ ["name must be static string" @processor block compilerError] when
    ]
    [
      refToStruct getVar.data.getTag VarStruct = [
        string: VarString varName.data.get;
        fr: string makeStringView @processor findNameInfo refToStruct @processor block findField;
        processor compilable [
          fr.success makeValuePair VarCond @processor @block createVariable Static @processor @block makeStaticity @processor @block createPlainIR @block push
        ] when
      ] [
        FALSE makeValuePair VarCond @processor @block createVariable Static @processor @block makeStaticity @processor @block createPlainIR @block push
      ] if
    ]
  ) sequence
] "mplBuiltinHas" @declareBuiltin ucall

[
  else: @processor @block pop;
  then: @processor @block pop;
  condition: @processor @block pop;

  processor compilable [
    varElse: else getVar;
    varThen: then getVar;
    varCond: condition getVar;

    varElse.data.getTag VarCode = ~ ["branch else must be a [CODE]" @processor block compilerError] when
    varThen.data.getTag VarCode = ~ ["branch then must be a [CODE]" @processor block compilerError] when
    varCond.data.getTag VarCond = ~ [("condition has a wrong type " condition @processor block getMplType) assembleString @processor block compilerError] when

    processor compilable [
      condition staticityOfVar Weak > [
        value: VarCond varCond.data.get.end copy;
        value [
          VarCode varThen.data.get.index VarCode varThen.data.get.file "staticIfThen" makeStringView @processor @block processCall
        ] [
          VarCode varElse.data.get.index VarCode varElse.data.get.file "staticIfElse" makeStringView @processor @block processCall
        ] if
      ] [
        condition
        VarCode varThen.data.get.index processor.multiParserResult.memory.at
        VarCode varThen.data.get.file
        VarCode varElse.data.get.index processor.multiParserResult.memory.at
        VarCode varElse.data.get.file
        @processor @block processIf
      ] if
    ] when
  ] when
] "mplBuiltinIf" @declareBuiltin ucall

[
  (
    [processor compilable]
    [block.parent 0 = ~ ["import must be global" @processor block compilerError] when]
    [refToName: @processor @block pop;]
    [refToName staticityOfVar Weak < ["function name must be static string" @processor block compilerError] when]
    [
      varName: refToName getVar;
      varName.data.getTag VarString = ~ ["function name must be static string" @processor block compilerError] when
    ]
    [signature: parseSignature;]
    [newBlock: signature VarString varName.data.get makeStringView FALSE dynamic @processor @block processImportFunction Block addressToReference;]
  ) sequence
] "mplBuiltinImportFunction" @declareBuiltin ucall

[
  block.parent 0 = ~ ["import must be global" @processor block compilerError] when
  processor compilable [
    refToName: @processor @block pop;
    refToType: @processor @block pop;
    processor compilable [
      refToName staticityOfVar Weak < ["variable name must be static string" @processor block compilerError] when
      processor compilable [
        varName: refToName getVar;
        varName.data.getTag VarString = ~ ["variable name must be static string" @processor block compilerError] when
        processor compilable [
          varType: refToType getVar;
          refToType isVirtual [
            "variable cant be virtual" @processor block compilerError
          ] [
            varType.temporary ~ [
              @refToType TRUE dynamic @processor @block createRef @refToType set
            ] when

            name: VarString varName.data.get;
            newRefToVar: refToType @processor @block copyVar;
            newVar: @newRefToVar getVar;
            TRUE @newRefToVar.setMutable
            FALSE @newVar.@temporary set
            ("@" name) assembleString @processor makeStringId @newVar.@irNameId set
            @newRefToVar @processor @block createVarImportIR @processor @block makeVarTreeDynamic

            nameInfo: name makeStringView @processor findNameInfo;

            {
              addNameCase: NameCaseLocal;
              refToVar:    newRefToVar copy;
              nameInfo:    nameInfo copy;
            } @processor @block addNameInfo

            processor.options.debug [newRefToVar isVirtual ~] && [
              d: nameInfo newRefToVar @processor block addGlobalVariableDebugInfo;
              globalInstruction: newRefToVar getVar.globalDeclarationInstructionIndex @processor.@prolog.at;
              ", !dbg !"   @globalInstruction.cat
              d            @globalInstruction.cat
            ] when
          ] if
        ] when
      ] when
    ] when
  ] when
] "mplBuiltinImportVariable" @declareBuiltin ucall

[
  refToVar1: @processor @block pop;
  refToVar2: @processor @block pop;
  processor compilable [
    refToVar1 refToVar2 variablesAreSame [
      cmpResult: 0 dynamic; # -1 false, 1 true, 0 need to check
      refToVar1 refToVar2 refsAreEqual [
        1 @cmpResult set
      ] [
        refToVar1 getVar.storageStaticity Dynamic > ~
        refToVar2 getVar.storageStaticity Dynamic > ~ or [
          0 @cmpResult set
        ] [
          -1 @cmpResult set
        ] if
      ] if

      cmpResult 0 = [
        result: FALSE makeValuePair VarCond @processor @block createVariable Dynamic @processor @block makeStaticity @processor @block createAllocIR;
        refToVar1 refToVar2 result "icmp eq" @processor @block createDirectBinaryOperation
        result @block push
      ] [
        cmpResult 1 = makeValuePair VarCond @processor @block createVariable Static @processor @block makeStaticity @processor @block createPlainIR @block push
      ] if
    ] [
      ("different arguments, left: " refToVar1 @processor block getMplType ", right: " refToVar2 @processor block getMplType) assembleString @processor block compilerError
    ] if
  ] when
] "mplBuiltinIs" @declareBuiltin ucall

[
  refToVar: @processor @block pop;
  processor compilable [
    refToVar getVar.data.getTag VarStruct = makeValuePair VarCond @processor @block createVariable Static @processor @block makeStaticity @processor @block createPlainIR @block push
  ] when
] "mplBuiltinIsCombined" @declareBuiltin ucall

[
  refToVar: @processor @block pop;
  processor compilable [
    refToVar.mutable ~ makeValuePair VarCond @processor @block createVariable Static @processor @block makeStaticity @processor @block createPlainIR @block push
  ] when
] "mplBuiltinIsConst" @declareBuiltin ucall

[
  refToVar: @processor @block pop;
  processor compilable [
    refToVar @block push
    refToVar isAutoStruct [refToVar varIsMoved] && makeValuePair
    VarCond @processor @block createVariable Static @processor @block makeStaticity @processor @block createPlainIR @block push
  ] when
] "mplBuiltinIsMoved" @declareBuiltin ucall

[
  TRUE dynamic @processor.@usedFloatBuiltins set
  [a:; a getVar.data.getTag VarReal32 = ["@llvm.log.f32" makeStringView]["@llvm.log.f64" makeStringView] if
  ] [log] [x:;] mplNumberBuiltinOp
] "mplBuiltinLog" @declareBuiltin ucall

[
  TRUE dynamic @processor.@usedFloatBuiltins set
  [a:; a getVar.data.getTag VarReal32 = ["@llvm.log10.f32" makeStringView]["@llvm.log10.f64" makeStringView] if
  ] [log10] [x:;] mplNumberBuiltinOp
] "mplBuiltinLog10" @declareBuiltin ucall

[
  body: @processor @block pop;

  (
    [processor compilable]
    [
      varBody: body getVar;
      varBody.data.getTag VarCode = ~ ["body must be [CODE]" @processor block compilerError] when
    ] [
      astNode: VarCode varBody.data.get.index processor.multiParserResult.memory.at;
      astNode @processor @block VarCode varBody.data.get.file processLoop
    ]
  ) sequence
] "mplBuiltinLoop" @declareBuiltin ucall

[
  [t2:; t1:; "shl" makeStringView][lshift] mplShiftBinaryOp
] "mplBuiltinLShift" @declareBuiltin ucall

[
  refToVar: @processor @block pop;
  processor compilable [
    refToVar isAutoStruct [refToVar @processor @block callDie] when
  ] when
] "mplBuiltinManuallyDestroyVariable" @declareBuiltin ucall

[
  refToVar: @processor @block pop;
  processor compilable [
    refToVar isAutoStruct [refToVar @processor @block callInit] when
  ] when
] "mplBuiltinManuallyInitVariable" @declareBuiltin ucall

[
  VarNat8 VarIntX 1 + [a2:; a1:; a2 isNat ["urem" makeStringView] ["srem" makeStringView] if] [mod] [copy] [
    y:; x:;
    y y - y = ["division by zero" @processor block compilerError] when
  ] mplNumberBinaryOp
] "mplBuiltinMod" @declareBuiltin ucall

[
  refToVar: @processor @block pop;
  processor compilable [
    refToVar.mutable [
      refToVar isVirtual [
        refToVar @block push
      ] [
        var: @refToVar getVar;
        var.data.getTag VarStruct = [
          TRUE @refToVar.setMoved
        ] when

        refToVar @block push
      ] if
    ] [
      "moved can be only mutable variables" @processor block compilerError
    ] if
  ] when
] "mplBuiltinMove" @declareBuiltin ucall

[
  refToCond: @processor @block pop;
  processor compilable [
    condVar: refToCond getVar;
    condVar.data.getTag VarCond = ~ [refToCond staticityOfVar Dynamic > ~] || ["not a static Cond" @processor block compilerError] when
    processor compilable [
      refToVar: @processor @block pop;
      processor compilable [
        VarCond condVar.data.get.end [
          refToVar.mutable [
            refToVar isVirtual [
              refToVar @block push
            ] [
              var: @refToVar getVar;
              var.data.getTag VarStruct = [
                TRUE @refToVar.setMoved
              ] when

              refToVar @block push
            ] if
          ] [
            "moved can be only mutable variables" @processor block compilerError
          ] if
        ] [
          refToVar @block push
        ] if
      ] when
    ] when
  ] when
] "mplBuiltinMoveIf" @declareBuiltin ucall

[
  VarInt8 VarReal64 1 + [
    a:; a isAnyInt ["sub" makeStringView]["fsub" makeStringView] if
  ] [
    a:; a isAnyInt ["0, " makeStringView]["0x0000000000000000, " makeStringView] if
  ] [neg] [x:;] mplNumberUnaryOp
] "mplBuiltinNeg" @declareBuiltin ucall

[
  refToVar: @processor @block pop;
  processor compilable [
    refToVar isUnallocable [
      "cannot create newVar of string or func" @processor @block compilerError
    ] [
      result: refToVar @processor @block copyVarFromType;

      result isVirtual ~ [
        TRUE @result.setMutable
        @result @processor @block createAllocIR @processor @block callInit
      ] when

      result @block push
    ] if
  ] when
] "mplBuiltinNewVarOfTheSameType" @declareBuiltin ucall

[
  VarCond VarNatX 1 + [a2:; a1:; "or" makeStringView] [or] [copy] [y:; x:;] mplNumberBinaryOp
] "mplBuiltinOr" @declareBuiltin ucall

[
  refToName: @processor @block pop;
  processor compilable [
    refToName staticityOfVar Weak < ["name must be static string" @processor block compilerError] when
    processor compilable [
      varName: refToName getVar;
      varName.data.getTag VarString = ~ ["name must be static string" @processor block compilerError] when
      processor compilable [
        VarString varName.data.get print LF print
      ] when
    ] when
  ] when
] "mplBuiltinPrintCompilerMessage" @declareBuiltin ucall

[
  @processor block defaultPrintStack
] "mplBuiltinPrintStack" @declareBuiltin ucall

[
  @processor block defaultPrintStackTrace
] "mplBuiltinPrintStackTrace" @declareBuiltin ucall

[
  debugMemory [
    ("compilerMaxAllocationSize=" getMemoryMetrics.memoryMaxAllocationSize LF) printList
  ] [
    ("compilerMaxAllocationSize is unknown, use -debugMemory flag" LF) printList
  ] uif
] "mplPrintCompilerMaxAllocationSize"  @declareBuiltin ucall

[
  processor compilable [
    ("var count=" processor.varCount LF) printList
  ] when
] "mplBuiltinPrintVariableCount" @declareBuiltin ucall

[
  refToName: @processor @block pop;
  processor compilable [
    refToName staticityOfVar Weak < ["name must be static string" @processor block compilerError] when
    processor compilable [
      varName: refToName getVar;
      varName.data.getTag VarString = ~ ["name must be static string" @processor block compilerError] when
      processor compilable [
        VarString varName.data.get @processor block compilerError
      ] when
    ] when
  ] when
] "mplBuiltinRaiseStaticError" @declareBuiltin ucall

[
  TRUE dynamic @block.@nodeIsRecursive set
] "mplBuiltinRecursive" @declareBuiltin ucall

[
  [t2:; t1:; t1 isNat ["lshr" makeStringView]["ashr" makeStringView] if][rshift] mplShiftBinaryOp
] "mplBuiltinRShift" @declareBuiltin ucall

[
  refToVar1: @processor @block pop;
  refToVar2: @processor @block pop;
  processor compilable [
    refToVar1 refToVar2 variablesAreSame makeValuePair VarCond @processor @block createVariable Static @processor @block makeStaticity @processor @block createPlainIR @block push
  ] when
] "mplBuiltinSame" @declareBuiltin ucall

[
  block.nextLabelIsSchema ["duplicate schema specifier" @processor block compilerError] when
  TRUE @block.@nextLabelIsSchema set
] "mplBuiltinSchema" @declareBuiltin ucall

[
  @processor @block defaultSet
] "mplBuiltinSet" @declareBuiltin ucall

[
  TRUE dynamic @processor.@usedFloatBuiltins set
  [a:; a getVar.data.getTag VarReal32 = ["@llvm.sin.f32" makeStringView]["@llvm.sin.f64" makeStringView] if
  ] [sin] [x:;] mplNumberBuiltinOp
] "mplBuiltinSin" @declareBuiltin ucall

[
  TRUE dynamic @processor.@usedFloatBuiltins set
  [a:; a getVar.data.getTag VarReal32 = ["@llvm.sqrt.f32" makeStringView]["@llvm.sqrt.f64" makeStringView] if
  ] [sqrt] [x:;] mplNumberBuiltinOp
] "mplBuiltinSqrt" @declareBuiltin ucall

[
  refToVar: @processor @block pop;
  processor compilable [
    refToVar staticityOfVar Weak = [@refToVar Static @processor block makeStaticity @refToVar set] when
    refToVar @block push
  ] when
] "mplBuiltinStatic" @declareBuiltin ucall

[
  (
    [processor compilable]
    [refToVar: @processor @block pop;]
    [refToVar isVirtual ["variable is virtual, cannot get address" @processor block compilerError] when]
    [
      TRUE @refToVar getVar.@capturedAsMutable set #we need ref
      @refToVar makeVarRealCaptured
      refToVar @processor @block makeVarTreeDirty
      refToDst: 0n64 makeValuePair VarNatX @processor @block createVariable;
      Dynamic makeValuePair @refToDst getVar.@staticity set
      var: refToVar getVar;
      refToVar @refToDst "ptrtoint" @processor @block createCastCopyPtrToNew
      refToDst @block push
    ]
  ) sequence
] "mplBuiltinStorageAddress" @declareBuiltin ucall

[
  refToVar: @processor @block pop;
  processor compilable [
    refToVar isVirtual [
      refToVar isSchema [
        pointee: VarRef refToVar getVar.data.get.refToVar;
        pointee isVirtual [
          0nx
        ] [
          pointee @processor block checkUnsizedData
          pointee @processor getStorageSize
        ] if
      ] [
        0nx
      ] if
    ] [
      refToVar @processor block checkUnsizedData
      refToVar @processor getStorageSize
    ] if

    0n64 cast makeValuePair VarNatX @processor @block createVariable Static @processor @block makeStaticity @processor @block createPlainIR @block push
  ] when
] "mplBuiltinStorageSize" @declareBuiltin ucall

[
  refToName: @processor @block pop;
  (
    [processor compilable]
    [
      varName: refToName getVar;
      varName.data.getTag VarString = ~ ["argument must be string" @processor block compilerError] when
    ]
    [
      refToName staticityOfVar Weak < [
        result: 0n64 makeValuePair VarNatX @processor @block createVariable Dynamic @processor @block makeStaticity @processor @block createAllocIR;
        refToName result @processor @block createGetTextSizeIR
        result @block push
      ] [
        string: VarString varName.data.get;
        string.size 0i64 cast 0n64 cast makeValuePair VarNatX @processor @block createVariable Static @processor @block makeStaticity @processor @block createPlainIR @block push
      ] if
    ]
  ) sequence
] "mplBuiltinTextSize" @declareBuiltin ucall

[
  refToName: @processor @block pop;
  processor compilable [
    refToName staticityOfVar Weak < ["name must be static string" @processor block compilerError] when
    processor compilable [
      varName: refToName getVar;
      varName.data.getTag VarString = ~ ["name must be static string" @processor block compilerError] when
      processor compilable [
        string: VarString varName.data.get;
        struct: Struct;

        string.chars.dataSize 0 < ~ [
          splitted: string splitString;
          splitted.success [
            splitted.chars [
              element: toString @processor @block makeVarString;
              field: Field;
              processor.emptyNameInfo @field.@nameInfo set
              @element TRUE dynamic @processor @block createRef @field.@refToVar set
              field @struct.@fields.pushBack
            ] each

            result: @struct move owner VarStruct @processor @block createVariable;
            result isVirtual ~ [@result @processor @block createAllocIR @result set] when
            resultStruct: VarStruct @result getVar.@data.get.get;

            i: 0 dynamic;
            [
              i resultStruct.fields.dataSize < [
                field: i @resultStruct.@fields.at;

                result isGlobal [
                  block.program.dataSize @field.@refToVar getVar.@allocationInstructionIndex set
                  "no alloc..." @block createComment # fake instruction

                  loadReg: field.refToVar @processor @block createDerefToRegister;
                  @field.@refToVar @processor block unglobalize
                  loadReg field.refToVar @processor @block createStoreFromRegister

                  @field.@refToVar i result @processor @block createGEPInsteadOfAlloc
                ] [
                  @field.@refToVar i result @processor @block createGEPInsteadOfAlloc
                ] if
                i 1 + @i set TRUE
              ] &&
            ] loop

            result @block push
          ] [
            "wrong encoding in ctring" @processor block compilerError
          ] if
        ] when
      ] when
    ] when
  ] when
] "mplBuiltinTextSplit" @declareBuiltin ucall

[
  code: @processor @block pop;

  processor compilable [
    varCode: code getVar;

    varCode.data.getTag VarCode = ~ ["branch else must be a [CODE]" @processor block compilerError] when

    processor compilable [
      codeIndex: VarCode varCode.data.get.index copy;
      codeFile: VarCode varCode.data.get.file;
      astNode: codeIndex processor.multiParserResult.memory.at;
      [astNode.data.getTag AstNodeType.Code =] "Not a code!" assert
      block.countOfUCall 1 + @block.@countOfUCall set
      block.countOfUCall 65535 > ["ucall limit exceeded" @processor block compilerError] when
      indexArray: AstNodeType.Code astNode.data.get;
      indexArray @block codeFile addIndexArrayToProcess
    ] when
  ] when
] "mplBuiltinUcall" @declareBuiltin ucall

[
  else: @processor @block pop;
  then: @processor @block pop;
  condition: @processor @block pop;

  processor compilable [
    varElse: else getVar;
    varThen: then getVar;
    varCond: condition getVar;

    varElse.data.getTag VarCode = ~ ["branch else must be a [CODE]" @processor block compilerError] when
    varThen.data.getTag VarCode = ~ ["branch then must be a [CODE]" @processor block compilerError] when
    varCond.data.getTag VarCond = ~ ["condition has a wrong type" @processor block compilerError] when

    processor compilable [
      condition staticityOfVar Weak > [
        value: VarCond varCond.data.get.end copy;
        code: value [VarCode varThen.data.get] [VarCode varElse.data.get] if;
        astNode: code.index processor.multiParserResult.memory.at;
        [astNode.data.getTag AstNodeType.Code =] "Not a code!" assert
        block.countOfUCall 1 + @block.@countOfUCall set
        block.countOfUCall 65535 > ["ucall limit exceeded" @processor block compilerError] when
        indexArray: AstNodeType.Code astNode.data.get;
        indexArray @block code.file addIndexArrayToProcess
      ] [
        "condition must be static" @processor block compilerError
      ] if
    ] when
  ] when
] "mplBuiltinUif" @declareBuiltin ucall

[
  (
    [processor compilable]
    [refToName: @processor @block pop;]
    [refToName staticityOfVar Weak < ["path must be static string" @processor block compilerError] when]
    [
      varName: refToName getVar;
      varName.data.getTag VarString = ~ ["path must be static string" @processor block compilerError] when
    ] [
      string: VarString varName.data.get;
      filename: string stripExtension;
      filename "" = ["invalid filename" @processor block compilerError] when
    ] [
      name: string extractExtension;
      fr: filename processor.modules.find;
      fr.success [fr.value 0 < ~] && [
        fileBlock: fr.value processor.blocks.at.get;
        nameInfo: name @processor findNameInfo;
        labelCount: 0;

        fileBlock.labelNames [
          label:;
          name "" = [label.nameInfo nameInfo =] || [label.refToVar isVirtual [label.refToVar getVar.data.getTag VarImport =] ||] && [
            {
              addNameCase: NameCaseFromModule;
              refToVar:    label.refToVar copy;
              nameInfo:    label.nameInfo copy;
              overload:    block.nextLabelIsOverload;
            } @processor @block addNameInfo

            labelCount 1 + !labelCount
          ] when
        ] each

        FALSE @block.!nextLabelIsOverload

        labelCount 0 = [
          oldSuccess: processor compilable;
          message: ("no names match \"" name "\"") assembleString; 

          name "" = ~ [
            @message nameInfo @processor catPossibleModulesList
          ] when

          message @processor block compilerError
          oldSuccess [
            @processor.@result.@errorInfo move @processor.@result.@globalErrorInfo.pushBack
            -1 @processor.@result clearProcessorResult
          ] when
        ] when
      ] [
        TRUE dynamic @processor.@result.@findModuleFail set
        filename toString @processor.@result.@errorInfo.@missedModule set
        ("module not found: " filename) assembleString @processor block compilerError
      ] if
    ]
  ) sequence
] "mplBuiltinUse" @declareBuiltin ucall

[
  block.nextLabelIsVirtual ["duplicate virtual specifier" @processor block compilerError] when
  TRUE @block.@nextLabelIsVirtual set
] "mplBuiltinVirtual" @declareBuiltin ucall

[
  block.nextLabelIsOverload ["duplicate overload specifier" @processor block compilerError] when
  TRUE @block.@nextLabelIsOverload set
] "mplBuiltinOverload" @declareBuiltin ucall

[
  VarCond VarNatX 1 + [a2:; a1:; "xor" makeStringView] [xor] [copy] [y:; x:;] mplNumberBinaryOp
] "mplBuiltinXor" @declareBuiltin ucall

[
  VarCond VarNatX 1 + [a:; "xor" makeStringView] [
    a:; a getVar.data.getTag VarCond = ["true, " makeStringView]["-1, " makeStringView] if
  ] [~] [x:;] mplNumberUnaryOp
] "mplBuiltinNot" @declareBuiltin ucall
