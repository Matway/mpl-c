"Array" includeModule
"HashTable" includeModule
"Owner" includeModule
"String" includeModule
"control" includeModule

"Block" includeModule
"File" includeModule
"Var" includeModule
"astNodeType" includeModule
"codeNode" includeModule
"debugWriter" includeModule
"defaultImpl" includeModule
"irWriter" includeModule
"pathUtils" includeModule
"processSubNodes" includeModule
"processor" includeModule
"staticCall" includeModule
"variable" includeModule

declareBuiltin: [
  virtual declareBuiltinName:;
  virtual declareBuiltinBody:;

  {processorResult: ProcessorResult Ref; processor: Processor Ref; block: Block Ref; multiParserResult: MultiParserResult Cref;} () {} [
    processorResult:;
    processor:;
    block:;
    multiParserResult:;
    failProc: @failProcForProcessor;
    @declareBuiltinBody ucall
  ] declareBuiltinName exportFunction
];

mplBuiltinProcessAtList: [
  refToStruct: @block pop;
  refToIndex: @block pop;
  compileOnce

  result: RefToVar;

  compilable [
    structVar: refToStruct getVar;
    indexVar: refToIndex getVar;

    refToStruct isSchema [

      (
        [compilable]
        [
          pointee: VarRef structVar.data.get;
          pointeeVar: pointee getVar;
          pointeeVar.data.getTag VarStruct = ~ ["not a combined" block compilerError] when
        ]
        [indexVar.data.getTag VarInt32 = ~ ["index must be Int32" block compilerError] when ]
        [refToIndex staticityOfVar Weak < [ "index must be static" block compilerError] when ]
        [
          index: VarInt32 indexVar.data.get 0 cast;
          struct: VarStruct pointeeVar.data.get.get;
          index 0 < [index struct.fields.getSize < ~] || ["index is out of bounds" block compilerError] when
        ] [
          field: index struct.fields.at.refToVar;
          field VarRef TRUE dynamic TRUE dynamic TRUE dynamic @block createVariableWithVirtual @result set
          refToStruct.mutable @result.setMutable
          @result fullUntemporize
        ]
      ) sequence
    ] [
      (
        [compilable]
        [structVar.data.getTag VarStruct = ~ [ "not a combined" block compilerError] when]
        [indexVar.data.getTag VarInt32 = ~ ["index must be Int32" block compilerError] when]
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
                  "can't get dynamic index in virtual struct" block compilerError
                ] when

                @refToIndex makeVarRealCaptured
                firstField: 0 realStruct.fields.at.refToVar;
                fieldRef: firstField copyVarFromParent;
                firstField getVar.host block is ~ [
                  fBegin: RefToVar;
                  fEnd: RefToVar;
                  fieldRef @fBegin @fEnd ShadowReasonField @block makeShadowsDynamic
                  fEnd @fieldRef set
                ] when

                refToStruct.mutable @fieldRef.setMutable
                @fieldRef fullUntemporize
                fieldRef staticityOfVar Virtual < ~ [
                  "dynamic index in combined of virtuals" block compilerError
                ] [
                  fieldRef @block makeVarTreeDynamicStoraged
                  @fieldRef block unglobalize
                  fieldRef refToIndex realRefToStruct @block createDynamicGEP
                  fieldVar: @fieldRef getVar;
                  block.program.dataSize 1 - @fieldVar.@getInstructionIndex set
                  fieldRef @result set
                ] if

                refToStruct.mutable [
                  refToStruct @block makeVarTreeDirty
                ] when
              ] [
                "struct is empty" block compilerError
              ] if
            ] [
              "dynamic index in non-homogeneous combined" block compilerError
            ] if
          ] [
            index: VarInt32 indexVar.data.get 0 cast;
            index @refToStruct @block processStaticAt @result set
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

  arg2: @block pop;
  arg1: @block pop;

  compilable [
    var1: arg1 getVar;
    var2: arg2 getVar;
    var1.data.getTag firstTag < [var1.data.getTag lastTag < ~] || ["first argument invalid" block compilerError] [
      var2.data.getTag firstTag < [var2.data.getTag lastTag < ~] || ["second argument invalid" block compilerError] [
        arg1 arg2 variablesAreSame ~ [
          ("arguments have different schemas, left is " arg1 block getMplType ", right is " arg2 block getMplType) assembleString block compilerError
        ] when
      ] if
    ] if

    compilable [
      var1: arg1 getVar;
      var2: arg2 getVar;

      arg1 staticityOfVar Dynamic > arg2 staticityOfVar Dynamic > and [
        var1.data.getTag firstTag lastTag [
          copy tag:;
          value1: tag var1.data.get copy;
          value2: tag var2.data.get copy;
          resultType: tag @getResultType call;
          value1 value2 @exValidator call
          compilable [
            value1 value2 @opFunc call resultType cutValue resultType @block createVariable
            arg1 staticityOfVar arg2 staticityOfVar staticityOfBinResult block makeStaticity
            @block createPlainIR @block push
          ] when
        ] staticCall
      ] [
        @arg1 makeVarRealCaptured
        @arg2 makeVarRealCaptured
        opName: arg1 arg2 @getOpName call;
        var1.data.getTag firstTag lastTag [
          copy tag:;
          value1: tag var1.data.get copy;
          value2: tag var2.data.get copy;
          resultType: tag @getResultType call;
          result: resultType zeroValue resultType @block createVariable
          Dynamic block makeStaticity
          @block createAllocIR;
          opName @block createBinaryOperation
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

  arg: @block pop;

  compilable [
    var: arg getVar;
    arg isReal ~ ["argument invalid" block compilerError] when

    compilable [
      arg staticityOfVar Dynamic > [
        var.data.getTag VarReal32 VarReal64 1 + [
          copy tag:;
          value: tag var.data.get copy;
          resultType: tag copy;
          value @exValidator call
          compilable [
            value @opFunc call resultType cutValue resultType @block createVariable
            arg staticityOfVar block makeStaticity
            @block createPlainIR @block push
          ] when
        ] staticCall
      ] [
        @arg makeVarRealCaptured
        opName: arg @getOpName call;
        var.data.getTag VarReal32 VarReal64 1 + [
          copy tag:;
          value: tag var.data.get copy;
          resultType: tag copy;
          result: resultType zeroValue resultType @block createVariable
          Dynamic block makeStaticity
          @block createAllocIR;

          args: IRArgument Array;

          irarg: IRArgument;
          arg @block createDerefToRegister @irarg.@irNameId set
          arg getMplSchema.irTypeId @irarg.@irTypeId set
          FALSE @irarg.@byRef set
          irarg @args.pushBack

          result args String @opName @block createCallIR retName:;

          retName result @block createStoreFromRegister

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

  arg: @block pop;

  compilable [
    var: arg getVar;
    var.data.getTag firstTag < [var.data.getTag lastTag < ~] || ["argument invalid" block compilerError] when

    compilable [
      arg staticityOfVar Dynamic > [
        var.data.getTag firstTag lastTag [
          copy tag:;
          value: tag var.data.get copy;
          resultType: tag copy;
          value @exValidator call
          compilable [
            value @opFunc call resultType cutValue resultType @block createVariable
            arg staticityOfVar block makeStaticity
            @block createPlainIR @block push
          ] when
        ] staticCall
      ] [
        @arg makeVarRealCaptured
        opName: arg @getOpName call;
        mopName: arg @getMidOpName call;
        var.data.getTag firstTag lastTag [
          copy tag:;
          value: tag var.data.get copy;
          resultType: tag copy;
          result: resultType zeroValue resultType @block createVariable
          Dynamic block makeStaticity
          @block createAllocIR;
          opName mopName @block createUnaryOperation
          result @block push
        ] staticCall
      ] if
    ] when
  ] when
];

mplShiftBinaryOp: [
  opFunc:;
  getOpName:;

  arg2: @block pop;
  arg1: @block pop;

  compilable [
    var1: arg1 getVar;
    var2: arg2 getVar;
    arg1 isAnyInt ~ ["first argument invalid" block compilerError] [
      arg2 isNat ~ ["second argument invalid" block compilerError] when
    ] if

    compilable [
      var1: arg1 getVar;
      var2: arg2 getVar;

      arg1 staticityOfVar Dynamic > arg2 staticityOfVar Dynamic > and [
        var1.data.getTag VarNat8 VarIntX 1 + [
          copy tag1:;
          var2.data.getTag VarNat8 VarNatX 1 + [
            copy tag2:;
            value1: tag1 var1.data.get copy;
            value2: tag2 var2.data.get copy;
            resultType: tag1 copy;
            value2 63n64 > ["shift value must be less than 64" block compilerError] when

            compilable [
              value1 value2 @opFunc call resultType cutValue resultType @block createVariable
              arg1 staticityOfVar arg2 staticityOfVar staticityOfBinResult @block makeStaticity
              @block createPlainIR @block push
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
          result: resultType zeroValue resultType @block createVariable
          Dynamic @block makeStaticity
          @block createAllocIR;
          arg1 block getStorageSize arg2 block getStorageSize = [
            opName @block createBinaryOperation
          ] [
            opName @block createBinaryOperationDiffTypes
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
  varStruct.data.getTag VarStruct = ~ ["argument list must be a struct" block compilerError] when

  compilable [
    VarStruct varStruct.data.get.get.fields [
      refToVar: .refToVar;
      refToVar isVirtual ["input cannot be virtual" block compilerError] when
      refToVar @result.pushBack
    ] each
  ] when

  result
];

parseSignature: [
  result: CFunctionSignature;
  (
    [compilable]
    [options: @block pop;]
    [
      optionsVar: options getVar;
      optionsVar.data.getTag VarStruct = ~ ["options must be a struct" block compilerError] when
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
              [compilable]
              [variadicVar.data.getTag VarCond = ~ ["value must be Cond" block compilerError] when]
              [variadicRefToVar staticityOfVar Weak < ["value must be Static" block compilerError] when]
              [VarCond variadicVar.data.get @result.@variadic set]
            ) sequence
          ]
          processor.conventionNameInfo [
            conventionRefToVarRef: f.refToVar;
            conventionVarRef: conventionRefToVarRef getVar;
            (
              [compilable]
              [conventionVarRef.data.getTag VarRef = ~ ["value must be String Ref" block compilerError] when]
              [conventionRefToVarRef staticityOfVar Weak < ["value must be Static" block compilerError] when]
              [
                conventionRefToVar: VarRef conventionVarRef.data.get;
                conventionVar: conventionRefToVar getVar;
                conventionVar.data.getTag VarString = ~ ["value must be String Ref" block compilerError] when
              ]
              [conventionRefToVar staticityOfVar Weak < ["value must be Static" block compilerError] when]
              [
                string: VarString conventionVar.data.get;
                string @result.@convention set
                TRUE @hasConvention set
              ]
            ) sequence
          ] [
            ("unknown option: " f.nameInfo processor.nameInfos.at.name) assembleString block compilerError
          ]
        ) case
      ] each
    ]
    [
      hasConvention ~ [
        String @result.@convention set
      ] when

      return: @block pop;
      compilable [
        return isVirtual [
          returnVar: return getVar;
          returnVar.data.getTag VarStruct = ~ [(return block getMplType " can not be a return type") assembleString block compilerError] when
        ] [
          #todo: detect temporality
          returnVar: return getVar;
          returnVar.temporary [
            return @result.@outputs.pushBack
          ] [
            @return TRUE dynamic @block createRef @result.@outputs.pushBack
          ] if
        ] if
      ] when
    ]
    [arguments: @block pop;]
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
  compilable [
    field setRef
  ] when
] "mplBuiltinExclamation" @declareBuiltin ucall

[
  (
    [compilable]
    [refToStr2: @block pop;]
    [refToStr2 staticityOfVar Weak < ["must be static string" block compilerError] when]
    [
      varStr2: refToStr2 getVar;
      varStr2.data.getTag VarString = ~ ["must be static string" block compilerError] when
    ]
    [refToStr1: @block pop;]
    [refToStr1 staticityOfVar Weak < ["must be static string" block compilerError] when]
    [
      varStr1: refToStr1 getVar;
      varStr1.data.getTag VarString = ~ ["must be static string" block compilerError] when
    ]
    [(VarString varStr1.data.get VarString varStr2.data.get) assembleString @block makeVarString @block push]
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
    y y - y = ["division by zero" block compilerError] when
  ] mplNumberBinaryOp
] "mplBuiltinDiv" @declareBuiltin ucall

[
  VarNat8 VarReal64 1 + [
    a2:; a1:; a2 isReal ["fcmp olt" makeStringView][a2 isNat ["icmp ult" makeStringView] ["icmp slt" makeStringView] if] if
  ] [<] [t:; VarCond] [y:; x:;] mplNumberBinaryOp
] "mplBuiltinLess" @declareBuiltin ucall

[
  arg2: @block pop;
  arg1: @block pop;

  compilable [
    comparable: [
      arg:;
      arg isPlain [arg getVar.data.getTag VarString =] ||
    ];

    var1: arg1 getVar;
    var2: arg2 getVar;

    arg1 comparable ~ [ "first argument is not comparable" block compilerError ] [
      arg2 comparable ~ [ "second argument is not comparable" block compilerError ] [
        arg1 arg2 variablesAreSame ~ [
          ("arguments have different schemas, left is " arg1 block getMplType ", right is " arg2 block getMplType) assembleString block compilerError
        ] when
      ] if
    ] if

    compilable [
      arg1 staticityOfVar Dynamic > arg2 staticityOfVar Dynamic > and [
        var1.data.getTag VarString = [
          value1: VarString var1.data.get copy;
          value2: VarString var2.data.get copy;
          value1 value2 = VarCond @block createVariable
          arg1 staticityOfVar arg2 staticityOfVar staticityOfBinResult block makeStaticity
          @block createPlainIR @block push
        ] [
          var1.data.getTag VarCond VarReal64 1 + [
            copy tag:;
            value1: tag var1.data.get copy;
            value2: tag var2.data.get copy;
            value1 value2 = VarCond @block createVariable
            arg1 staticityOfVar arg2 staticityOfVar staticityOfBinResult block makeStaticity
            @block createPlainIR @block push
          ] staticCall
        ] if
      ] [
        @arg1 makeVarRealCaptured
        @arg2 makeVarRealCaptured

        var1.data.getTag VarString = [
          result: FALSE VarCond @block createVariable Dynamic @block makeStaticity @block createAllocIR;
          "icmp eq" makeStringView @block createBinaryOperation
          result @block push
        ] [
          arg1 isReal [
            var1.data.getTag VarReal32 VarReal64 1 + [
              copy tag:;
              result: FALSE VarCond @block createVariable Dynamic @block makeStaticity @block createAllocIR;
              "fcmp oeq" @block createBinaryOperation
              result @block push
            ] staticCall
          ] [
            var1.data.getTag VarCond VarIntX 1 + [
              copy tag:;
              result: FALSE VarCond @block createVariable Dynamic @block makeStaticity @block createAllocIR;
              "icmp eq" @block createBinaryOperation
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
  compilable [
    field isVirtual [@field makeVirtualVarReal @field set] when
    @field derefAndPush
  ] when
] "mplBuiltinAt" @declareBuiltin ucall

[
  COMPILER_SOURCE_VERSION 0i64 cast VarInt32 @block createVariable Static @block makeStaticity @block createPlainIR @block push
] "mplBuiltinCompilerVersion" @declareBuiltin ucall

[
  processor.options.debug VarCond @block createVariable Static @block makeStaticity @block createPlainIR @block push
] "mplBuiltinDebug" @declareBuiltin ucall

[
  FALSE VarCond @block createVariable @block createPlainIR @block push
] "mplBuiltinFalse" @declareBuiltin ucall

[
  processor.options.logs VarCond @block createVariable Static @block makeStaticity @block createPlainIR @block push
] "mplBuiltinHasLogs" @declareBuiltin ucall

[
  LF toString @block makeVarString @block push
] "mplBuiltinLF" @declareBuiltin ucall

[
  TRUE VarCond @block createVariable @block createPlainIR @block push
] "mplBuiltinTrue" @declareBuiltin ucall

[
  TRUE dynamic @processor.@usedFloatBuiltins set
  arg2: @block pop;
  arg1: @block pop;

  compilable [
    var1: arg1 getVar;
    var2: arg2 getVar;
    arg1 isReal ~ ["first argument invalid" block compilerError] [
      arg2 isReal ~ ["second argument invalid" block compilerError] [
        arg1 arg2 variablesAreSame ~ [
          ("arguments have different schemas, left is " arg1 block getMplType ", right is " arg2 block getMplType) assembleString block compilerError
        ] when
      ] if
    ] if

    compilable [
      var1: arg1 getVar;
      var2: arg2 getVar;

      arg1 staticityOfVar Dynamic > arg2 staticityOfVar Dynamic > and [
        var1.data.getTag VarReal32 VarReal64 1 + [
          copy tag:;
          value1: tag var1.data.get copy;
          value2: tag var2.data.get copy;
          resultType: tag copy;

          compilable [
            value1 value2 ^ resultType cutValue resultType @block createVariable
            arg1 staticityOfVar arg2 staticityOfVar staticityOfBinResult @block makeStaticity
            @block createPlainIR @block push
          ] when
        ] staticCall
      ] [
        @arg1 makeVarRealCaptured
        @arg2 makeVarRealCaptured

        var1.data.getTag VarReal32 VarReal64 1 + [
          copy tag:;
          resultType: tag copy;
          result: resultType zeroValue resultType @block createVariable
          Dynamic @block makeStaticity
          @block createAllocIR;

          args: IRArgument Array;

          irarg: IRArgument;
          FALSE @irarg.@byRef set
          arg1 @block createDerefToRegister @irarg.@irNameId set
          arg1 getMplSchema.irTypeId @irarg.@irTypeId set
          irarg @args.pushBack
          arg2 @block createDerefToRegister @irarg.@irNameId set
          arg2 getMplSchema.irTypeId @irarg.@irTypeId set
          irarg @args.pushBack

          result args String tag VarReal32 = ["@llvm.pow.f32" makeStringView] ["@llvm.pow.f64" makeStringView] if @block createCallIR retName:;

          @retName result @block createStoreFromRegister

          result @block push
        ] staticCall
      ] if
    ] when
  ] when
] "mplBuiltinPow" @declareBuiltin ucall

[
  refToSchema: @block pop;
  refToVar: @block pop;

  compilable [
    var: refToVar getVar;
    varSchema: refToSchema getVar;
    var.data.getTag VarNatX = [
      var: refToVar getVar;
      varSchema: refToSchema getVar;
      schemaOfResult: RefToVar;
      varSchema.data.getTag VarRef = [
        refToSchema isSchema [
          VarRef varSchema.data.get @block copyVarFromChild @schemaOfResult set
          refToSchema.mutable schemaOfResult.mutable and @schemaOfResult.setMutable
        ] [
          [FALSE] "Unable in current semantic!" assert
        ] if
      ] [
        refToSchema @schemaOfResult set
      ] if

      schemaOfResult isVirtual [
        "pointee is virtual, cannot cast" block compilerError
      ] [
        refToDst: schemaOfResult VarRef @block createVariable;
        Dirty @refToDst getVar.@staticity set
        refToVar @refToDst "inttoptr" @block createCastCopyToNew
        @refToDst derefAndPush
      ] if
    ] [
      "address must be a NatX" block compilerError
    ] if
  ] when
] "mplBuiltinAddressToReference" @declareBuiltin ucall

[
  refToVar: @block pop;
  compilable [
    refToVar isVirtual [
      refToVar isSchema [
        pointee: VarRef refToVar getVar.data.get;
        pointee isVirtual [
          0nx
        ] [
          pointee block getAlignment
        ] if
      ] [
        0nx
      ] if
    ] [
      refToVar block getAlignment
    ] if

    0n64 cast VarNatX @block createVariable Static @block makeStaticity @block createPlainIR @block push
  ] when
] "mplBuiltinAlignment" @declareBuiltin ucall

[
  VarCond VarNatX 1 + [a2:; a1:; "and" makeStringView] [and] [copy] [y:; x:;] mplNumberBinaryOp
] "mplBuiltinAnd" @declareBuiltin ucall

[
  refToCount: @block pop;
  refToElement: @block pop;
  compilable [
    @refToElement fullUntemporize
    varCount: refToCount getVar;
    varCount.data.getTag VarInt32 = ~ ["count must be Int32" block compilerError] when
    compilable [
      refToCount staticityOfVar Dynamic > ~ ["count must be static" block compilerError] when
      compilable [
        count: VarInt32 varCount.data.get 0 cast;
        count 0 < [
          "count must not be negative" block compilerError
        ] when

        compilable [
          struct: Struct;
          staticity: refToElement staticityOfVar;
          staticity Weak = [Dynamic @staticity set] when

          i: 0 dynamic;
          [
            i count < [
              element: refToElement @block copyVar staticity @block makeStaticity;
              field: Field;
              processor.emptyNameInfo @field.@nameInfo set
              element @field.@refToVar set
              field @struct.@fields.pushBack
              i 1 + @i set TRUE
            ] &&
          ] loop

          result: @struct move owner VarStruct @block createVariable;
          result isVirtual ~ [@result @block createAllocIR @result set] when
          resultStruct: VarStruct @result getVar.@data.get.get;

          i: 0 dynamic;
          [
            i resultStruct.fields.dataSize < [
              field: i @resultStruct.@fields.at;
              field.refToVar isVirtual [
                field.refToVar isAutoStruct ["unable to copy virtual autostruct" block compilerError] when
              ] [
                @field.@refToVar block unglobalize
                block.program.dataSize @field.@refToVar getVar.@allocationInstructionIndex set
                "no alloc..." @block createComment # fake instruction
                @refToElement field.refToVar @block createCheckedCopyToNew
                @field.@refToVar markAsUnableToDie
                @field.@refToVar i result @block createGEPInsteadOfAlloc
              ] if
              i 1 + @i set compilable
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
  @block defaultCall
] "mplBuiltinCall" @declareBuiltin ucall

[
  (
    [compilable]
    [refToName: @block pop;]
    [
      refToName staticityOfVar Weak < ["method name must be a static string" block compilerError] when
    ]
    [
      varName: refToName getVar;
      varName.data.getTag VarString = ~ ["method name must be a static string" block compilerError] when
    ]
    [
      fieldNameInfo: VarString varName.data.get findNameInfo;
      fieldNameInfo @block pop 0 processMember
    ]
  ) sequence
] "mplBuiltinCallField" @declareBuiltin ucall

[
  refToSchema: @block pop;
  refToVar: @block pop;

  compilable [
    varSrc: refToVar getVar;
    varSchema: refToSchema getVar;
    varSchema.data.getTag VarRef = [refToSchema isVirtual] && [
      VarRef varSchema.data.get @block copyVarFromChild @refToSchema set
      refToSchema getVar !varSchema
    ] when

    refToVar isNumber refToSchema isNumber and [
      compilable [
        refToVar staticityOfVar Dynamic > [
          refToDst: RefToVar;

          varSrc.data.getTag VarNat8 VarReal64 1 + [
            copy tagSrc:;
            branchSrc: tagSrc varSrc.data.get;
            varSchema.data.getTag VarNat8 VarReal64 1 + [
              copy tagDst:;
              branchSchema: tagDst @varSchema.@data.get;
              branchSrc branchSchema cast tagDst cutValue tagDst @block createVariable @block createPlainIR @refToDst set
            ] staticCall
          ] staticCall

          refToVar staticityOfVar @refToDst getVar.@staticity set
          refToDst @block push
        ] [
          refToDst: RefToVar;
          varSchema: refToSchema getVar;
          varSchema.data.getTag VarNat8 VarReal64 1 + [
            copy tagDst:;
            branchSchema: tagDst @varSchema.@data.get;
            branchSchema tagDst @block createVariable @refToDst set
          ] staticCall

          Dynamic @refToDst getVar.@staticity set

          # a lot of cases for different casts
          refToVar isReal refToSchema isReal or [
            refToVar isReal refToSchema isReal and [
              #Real to Real
              refToVar block getStorageSize refToSchema block getStorageSize = [
                @refToVar @refToDst @block createCopyToNew
              ] [
                refToVar block getStorageSize refToSchema block getStorageSize < [
                  refToVar @refToDst "fpext" @block createCastCopyToNew
                ] [
                  refToVar @refToDst "fptrunc" @block createCastCopyToNew
                ] if
              ] if
            ] [
              refToVar isAnyInt [
                #Int to Real
                refToVar isNat [
                  refToVar @refToDst "uitofp" @block createCastCopyToNew
                ] [
                  refToVar @refToDst "sitofp" @block createCastCopyToNew
                ] if
              ] [
                #Real to Int
                [refToSchema isAnyInt] "Wrong cast number case!" assert
                refToSchema isNat [
                  refToVar @refToDst "fptoui" @block createCastCopyToNew
                ] [
                  refToVar @refToDst "fptosi" @block createCastCopyToNew
                ] if
              ] if
            ] if
          ] [
            #Int to Int
            refToVar block getStorageSize refToSchema block getStorageSize = [
              @refToVar @refToDst @block createCopyToNew
            ] [
              refToVar block getStorageSize refToSchema block getStorageSize < [
                refToVar isNat [
                  refToVar @refToDst "zext" @block createCastCopyToNew
                ] [
                  refToVar @refToDst "sext" @block createCastCopyToNew
                ] if
              ] [
                refToVar @refToDst "trunc" @block createCastCopyToNew
              ] if
            ] if
          ] if
          # here ends cast case list

          refToDst @block push
        ] if
      ] when
    ] [
      "can cast only numbers" block compilerError
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
    [compilable]
    [signature: parseSignature;]
    [
      name: ("null." processor.blocks.getSize) assembleString;
      newBlock: signature name makeStringView TRUE dynamic processImportFunction Block addressToReference;
    ]
    [
      gnr: newBlock.varNameInfo @block File Ref getName;
      cnr: @gnr @block captureName;
      refToVar: cnr.refToVar copy;

      refToVar @block push
    ]
  ) sequence
] "mplBuiltinCodeRef" @declareBuiltin ucall

[
  TRUE dynamic @block.@nodeCompileOnce set
] "mplBuiltinCompileOnce" @declareBuiltin ucall

[TRUE @block defaultMakeConstWith] "mplBuiltinConst" @declareBuiltin ucall

[
  refToVar: @block pop;
  compilable [
    refToVar isVirtual ~ [@refToVar makeVarRealCaptured] when

    refToVar getVar.temporary [
      "temporary objects cannot be copied" block compilerError
    ] [
      refToVar getVar.data.getTag VarImport = [
        "functions cannot be copied" block compilerError
      ] [
        refToVar getVar.data.getTag VarString = [
          "builtin-strings cannot be copied" block compilerError
        ] [
          result: refToVar @block copyVarToNew;
          result isVirtual [
            result isAutoStruct ["unable to copy virtual autostruct" block compilerError] when
          ] [
            TRUE @result.setMutable
            @refToVar @result @block createCopyToNew
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
    [compilable]
    [refToName: @block pop;]
    [
      refToName staticityOfVar Weak < ["name must be static string" block compilerError] when
    ]
    [
      varName: refToName getVar;
      varName.data.getTag VarString = ~ ["name must be static string" block compilerError] when
    ]
    [
      VarString varName.data.get findNameInfo @block pop @block createNamedVariable
    ]
  ) sequence
] "mplBuiltinDef" @declareBuiltin ucall

[
  refToVar: @block pop;
  compilable [
    refToVar @block makeVarTreeDirty
    refToVar @block push
  ] when
] "mplBuiltinDirty" @declareBuiltin ucall

[
  (
    [compilable]
    [block.parent 0 = ~ ["export must be global" block compilerError] when]
    [refToName: @block pop;]
    [refToName staticityOfVar Weak < ["function name must be static string" block compilerError] when]
    [
      varName: refToName getVar;
      varName.data.getTag VarString = ~ ["function name must be static string" block compilerError] when
    ]
    [refToBody: @block pop;]
    [
      varBody: refToBody getVar;
      varBody.data.getTag VarCode = ~ ["must be a code" block compilerError] when
    ]
    [signature: parseSignature;]
    [
      astNode: VarCode varBody.data.get.index @multiParserResult.@memory.at;
      index: signature astNode VarCode varBody.data.get.file VarString varName.data.get makeStringView FALSE dynamic @block processExportFunction;
    ]
  ) sequence
] "mplBuiltinExportFunction" @declareBuiltin ucall

[
  (
    [compilable]
    [block.parent 0 = ~ ["export must be global" block compilerError] when]
    [refToName: @block pop;]
    [refToVar: @block pop;]
    [refToName staticityOfVar Weak < ["variable name must be static string" block compilerError] when]
    [
      varName: refToName getVar;
      varName.data.getTag VarString = ~ ["variable name must be static string" block compilerError] when
    ] [
      refToVar isVirtual ["cannot export virtual var" block compilerError] when
    ] [
      refToVar getVar.temporary ~ [
        @refToVar TRUE dynamic @block createRef @refToVar set
      ] when
      var: @refToVar getVar;
      FALSE @var.@temporary set
    ] [
      name: VarString varName.data.get;
      oldIrNameId: var.irNameId copy;
      oldInstructionIndex: var.globalDeclarationInstructionIndex copy;
      ("@" name) assembleString makeStringId @var.@irNameId set
      instruction: var.globalDeclarationInstructionIndex @processor.@prolog.at;
      @refToVar createVarExportIR drop
      @processor.@prolog.last move @instruction set
      @processor.@prolog.popBack
      TRUE @refToVar.setMutable
      oldIrNameId var.irNameId refToVar getMplSchema.irTypeId createGlobalAliasIR
      oldInstructionIndex @var.@globalDeclarationInstructionIndex set

      nameInfo: name findNameInfo;
      nameInfo refToVar addOverloadForPre
      nameInfo refToVar NameCaseLocal addNameInfo
      processor.options.debug [
        d: nameInfo refToVar block addGlobalVariableDebugInfo;
        globalInstruction: var.globalDeclarationInstructionIndex @processor.@prolog.at;
        ", !dbg !"   @globalInstruction.cat
        d            @globalInstruction.cat
      ] when
    ]
  ) sequence
] "mplBuiltinExportVariable" @declareBuiltin ucall

[
  defaultFailProc
] "mplBuiltinFailProc" @declareBuiltin ucall

[
  refToVar: @block pop;
  compilable [
    var: refToVar getVar;
    refToVar isSchema [
      pointee: VarRef var.data.get;
      pointeeVar: pointee getVar;
      pointeeVar.data.getTag VarStruct = ~ ["not a combined" block compilerError] when
      compilable [
        VarStruct pointeeVar.data.get.get.fields.dataSize 0i64 cast VarInt32 @block createVariable Static @block makeStaticity @block createPlainIR @block push
      ] when
    ] [
      var.data.getTag VarStruct = ~ ["not a combined" block compilerError] when
      compilable [
        VarStruct var.data.get.get.fields.dataSize 0i64 cast VarInt32 @block createVariable Static @block makeStaticity @block createPlainIR @block push
      ] when
    ] if
  ] when
] "mplBuiltinFieldCount" @declareBuiltin ucall

[
  (
    [compilable]
    [refToName: @block pop;]
    [refToStruct: @block pop;]
    [
      refToName staticityOfVar Weak < ["name must be static string" block compilerError] when
    ]
    [
      varName: refToName getVar;
      varName.data.getTag VarString = ~ ["name must be static string" block compilerError] when
    ]
    [
      refToStruct getVar.data.getTag VarStruct = ~ ["not a combined " block compilerError] when
    ] [
      string: VarString varName.data.get;
      fr: string makeStringView findNameInfo refToStruct findField;
    ] [
      fr.success ~ [(refToStruct block getMplType " has no field " string) assembleString block compilerError] when
    ] [
      fr.index Int64 cast VarInt32 @block createVariable Static @block makeStaticity @block createPlainIR @block push
    ]
  ) sequence
] "mplBuiltinFieldIndex" @declareBuiltin ucall

[
  refToCount: @block pop;
  refToVar: @block pop;
  compilable [
    varCount: refToCount getVar;
    varCount.data.getTag VarInt32 = ~ ["index must be Int32" block compilerError] when
    compilable [
      refToCount staticityOfVar Dynamic > ~ ["index must be static" block compilerError] when
      compilable [
        count: VarInt32 varCount.data.get 0 cast;
        var: refToVar getVar;
        refToVar isSchema [
          pointee: VarRef var.data.get;
          pointeeVar: pointee getVar;
          pointeeVar.data.getTag VarStruct = ~ ["not a combined" block compilerError] when
          compilable [
            count VarStruct pointeeVar.data.get.get.fields.at.nameInfo processor.nameInfos.at.name @block makeVarString @block push
          ] when
        ] [
          var.data.getTag VarStruct = ~ ["not a combined" block compilerError] when
          compilable [
            struct: VarStruct var.data.get.get;
            count 0 < [count struct.fields.getSize < ~] || ["index is out of bounds" block compilerError] when
            compilable [
              count struct.fields.at.nameInfo processor.nameInfos.at.name @block makeVarString @block push
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
  varPrev:   0n64 VarNatX @block createVariable;
  varNext:   0n64 VarNatX @block createVariable;
  varName:   String @block makeVarString TRUE dynamic createRefNoOp;
  varLine:   0i64 VarInt32 @block createVariable;
  varColumn: 0i64 VarInt32 @block createVariable;

  @varPrev   makeVarDirty
  @varNext   makeVarDirty
  @varName   makeVarDirty
  @varLine   makeVarDirty
  @varColumn makeVarDirty

  struct: Struct;
  5 @struct.@fields.resize

  varPrev             0 @struct.@fields.at.@refToVar set
  "prev" findNameInfo 0 @struct.@fields.at.@nameInfo set

  varNext             1 @struct.@fields.at.@refToVar set
  "next" findNameInfo 1 @struct.@fields.at.@nameInfo set

  varName             2 @struct.@fields.at.@refToVar set
  "name" findNameInfo 2 @struct.@fields.at.@nameInfo set

  varLine             3 @struct.@fields.at.@refToVar set
  "line" findNameInfo 3 @struct.@fields.at.@nameInfo set

  varColumn             4 @struct.@fields.at.@refToVar set
  "column" findNameInfo 4 @struct.@fields.at.@nameInfo set

  first: @struct move owner VarStruct @block createVariable;
  last: first @block copyVar;

  firstRef: @first FALSE dynamic createRefNoOp;
  lastRef:  @last  FALSE dynamic createRefNoOp;

  @firstRef makeVarDirty
  @lastRef  makeVarDirty

  resultStruct: Struct;
  2 @resultStruct.@fields.resize

  firstRef             0 @resultStruct.@fields.at.@refToVar set
  "first" findNameInfo 0 @resultStruct.@fields.at.@nameInfo set

  lastRef             1 @resultStruct.@fields.at.@refToVar set
  "last" findNameInfo 1 @resultStruct.@fields.at.@nameInfo set

  result: @resultStruct move owner VarStruct @block createVariable @block createAllocIR;
  first getIrType result getIrType result @block createGetCallTrace
  result @block push
] "mplBuiltinGetCallTrace" @declareBuiltin ucall

[
  (
    [compilable]
    [refToName: @block pop;]
    [refToStruct: @block pop;]
    [
      refToName staticityOfVar Weak < ["name must be static string" block compilerError] when
    ]
    [
      varName: refToName getVar;
      varName.data.getTag VarString = ~ ["name must be static string" block compilerError] when
    ]
    [
      refToStruct getVar.data.getTag VarStruct = [
        string: VarString varName.data.get;
        fr: string makeStringView findNameInfo refToStruct findField;
        compilable [
          fr.success VarCond @block createVariable Static @block makeStaticity @block createPlainIR @block push
        ] when
      ] [
        FALSE VarCond @block createVariable Static @block makeStaticity @block createPlainIR @block push
      ] if
    ]
  ) sequence
] "mplBuiltinHas" @declareBuiltin ucall

[
  else: @block pop;
  then: @block pop;
  condition: @block pop;

  compilable [
    varElse: else getVar;
    varThen: then getVar;
    varCond: condition getVar;

    varElse.data.getTag VarCode = ~ ["branch else must be a [CODE]" block compilerError] when
    varThen.data.getTag VarCode = ~ ["branch then must be a [CODE]" block compilerError] when
    varCond.data.getTag VarCond = ~ [("condition has a wrong type " condition block getMplType) assembleString block compilerError] when

    compilable [
      condition staticityOfVar Weak > [
        value: VarCond varCond.data.get copy;
        value [
          VarCode varThen.data.get.index VarCode varThen.data.get.file "staticIfThen" makeStringView processCall
        ] [
          VarCode varElse.data.get.index VarCode varElse.data.get.file "staticIfElse" makeStringView processCall
        ] if
      ] [
        condition
        VarCode varThen.data.get.index @multiParserResult.@memory.at
        VarCode varThen.data.get.file
        VarCode varElse.data.get.index @multiParserResult.@memory.at
        VarCode varElse.data.get.file
        processIf
      ] if
    ] when
  ] when
] "mplBuiltinIf" @declareBuiltin ucall

[
  (
    [compilable]
    [block.parent 0 = ~ ["import must be global" block compilerError] when]
    [refToName: @block pop;]
    [refToName staticityOfVar Weak < ["function name must be static string" block compilerError] when]
    [
      varName: refToName getVar;
      varName.data.getTag VarString = ~ ["function name must be static string" block compilerError] when
    ]
    [signature: parseSignature;]
    [newBlock: signature VarString varName.data.get makeStringView FALSE dynamic processImportFunction Block addressToReference;]
  ) sequence
] "mplBuiltinImportFunction" @declareBuiltin ucall

[
  block.parent 0 = ~ ["import must be global" block compilerError] when
  compilable [
    refToName: @block pop;
    refToType: @block pop;
    compilable [
      refToName staticityOfVar Weak < ["variable name must be static string" block compilerError] when
      compilable [
        varName: refToName getVar;
        varName.data.getTag VarString = ~ ["variable name must be static string" block compilerError] when
        compilable [
          varType: refToType getVar;
          refToType isVirtual [
            "variable cant be virtual" block compilerError
          ] [
            varType.temporary ~ [
              @refToType TRUE dynamic @block createRef @refToType set
            ] when

            name: VarString varName.data.get;
            newRefToVar: refToType @block copyVar;
            newVar: @newRefToVar getVar;
            TRUE @newRefToVar.setMutable
            FALSE @newVar.@temporary set
            ("@" name) assembleString makeStringId @newVar.@irNameId set
            @newRefToVar createVarImportIR makeVarTreeDynamic

            nameInfo: name findNameInfo;
            nameInfo newRefToVar addOverloadForPre
            nameInfo newRefToVar NameCaseLocal addNameInfo
            processor.options.debug [newRefToVar isVirtual ~] && [
              d: nameInfo newRefToVar block addGlobalVariableDebugInfo;
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

[FALSE dynamic @block defaultUseOrIncludeModule] "mplBuiltinIncludeModule" @declareBuiltin ucall

[
  refToVar1: @block pop;
  refToVar2: @block pop;
  compilable [
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
        result: FALSE VarCond @block createVariable Dynamic @block makeStaticity @block createAllocIR;
        refToVar1 refToVar2 result "icmp eq" @block createDirectBinaryOperation
        result @block push
      ] [
        cmpResult 1 = VarCond @block createVariable Static @block makeStaticity @block createPlainIR @block push
      ] if
    ] [
      ("different arguments, left: " refToVar1 block getMplType ", right: " refToVar2 block getMplType) assembleString block compilerError
    ] if
  ] when
] "mplBuiltinIs" @declareBuiltin ucall

[
  refToVar: @block pop;
  compilable [
    refToVar getVar.data.getTag VarStruct = VarCond @block createVariable Static @block makeStaticity @block createPlainIR @block push
  ] when
] "mplBuiltinIsCombined" @declareBuiltin ucall

[
  refToVar: @block pop;
  compilable [
    refToVar.mutable ~ VarCond @block createVariable Static @block makeStaticity @block createPlainIR @block push
  ] when
] "mplBuiltinIsConst" @declareBuiltin ucall

[
  refToVar: @block pop;
  compilable [
    refToVar @block push
    refToVar isForgotten
    VarCond @block createVariable Static @block makeStaticity @block createPlainIR @block push
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
  body: @block pop;

  (
    [compilable]
    [
      varBody: body getVar;
      varBody.data.getTag VarCode = ~ ["body must be [CODE]" block compilerError] when
    ] [
      astNode: VarCode varBody.data.get.index @multiParserResult.@memory.at;
      astNode VarCode varBody.data.get.file processLoop
    ]
  ) sequence
] "mplBuiltinLoop" @declareBuiltin ucall

[
  [t2:; t1:; "shl" makeStringView][lshift] mplShiftBinaryOp
] "mplBuiltinLShift" @declareBuiltin ucall

[
  refToVar: @block pop;
  compilable [
    refToVar isAutoStruct [refToVar callDie] when
  ] when
] "mplBuiltinManuallyDestroyVariable" @declareBuiltin ucall

[
  refToVar: @block pop;
  compilable [
    refToVar isAutoStruct [refToVar callInit] when
  ] when
] "mplBuiltinManuallyInitVariable" @declareBuiltin ucall

[
  VarNat8 VarIntX 1 + [a2:; a1:; a2 isNat ["urem" makeStringView] ["srem" makeStringView] if] [mod] [copy] [
    y:; x:;
    y y - y = ["division by zero" block compilerError] when
  ] mplNumberBinaryOp
] "mplBuiltinMod" @declareBuiltin ucall

[
  refToVar: @block pop;
  compilable [
    refToVar.mutable [
      refToVar isVirtual [
        refToVar @block push
      ] [
        var: @refToVar getVar;
        var.data.getTag VarStruct = [
          TRUE VarStruct @var.@data.get.get.@forgotten set
        ] when

        refToVar @block push
      ] if
    ] [
      "moved can be only mutable variables" block compilerError
    ] if
  ] when
] "mplBuiltinMove" @declareBuiltin ucall

[
  refToCond: @block pop;
  compilable [
    condVar: refToCond getVar;
    condVar.data.getTag VarCond = ~ [refToCond staticityOfVar Dynamic > ~] || ["not a static Cond" block compilerError] when
    compilable [
      refToVar: @block pop;
      compilable [
        VarCond condVar.data.get [
          refToVar.mutable [
            refToVar isVirtual [
              refToVar @block push
            ] [
              var: @refToVar getVar;
              var.data.getTag VarStruct = [
                TRUE VarStruct @var.@data.get.get.@forgotten set
              ] when

              refToVar @block push
            ] if
          ] [
            "moved can be only mutable variables" block compilerError
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
  refToVar: @block pop;
  compilable [
    result: refToVar @block copyVarToNew;
    result isVirtual ~ [result isUnallocable ~] && [
      TRUE @result.setMutable
      @result @block createAllocIR callInit
    ] when

    result @block push
  ] when
] "mplBuiltinNewVarOfTheSameType" @declareBuiltin ucall

[
  VarCond VarNatX 1 + [a2:; a1:; "or" makeStringView] [or] [copy] [y:; x:;] mplNumberBinaryOp
] "mplBuiltinOr" @declareBuiltin ucall

[
  refToName: @block pop;
  compilable [
    refToName staticityOfVar Weak < ["name must be static string" block compilerError] when
    compilable [
      varName: refToName getVar;
      varName.data.getTag VarString = ~ ["name must be static string" block compilerError] when
      compilable [
        VarString varName.data.get print LF print
      ] when
    ] when
  ] when
] "mplBuiltinPrintCompilerMessage" @declareBuiltin ucall

[
  block defaultPrintStack
] "mplBuiltinPrintStack" @declareBuiltin ucall

[
  block defaultPrintStackTrace
] "mplBuiltinPrintStackTrace" @declareBuiltin ucall

[
  compilable [
    ("var count=" processor.varCount LF) printList
  ] when
] "mplBuiltinPrintVariableCount" @declareBuiltin ucall

[
  refToName: @block pop;
  compilable [
    refToName staticityOfVar Weak < ["name must be static string" block compilerError] when
    compilable [
      varName: refToName getVar;
      varName.data.getTag VarString = ~ ["name must be static string" block compilerError] when
      compilable [
        VarString varName.data.get block compilerError
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
  refToVar1: @block pop;
  refToVar2: @block pop;
  compilable [
    refToVar1 refToVar2 variablesAreSame VarCond @block createVariable Static @block makeStaticity @block createPlainIR @block push
  ] when
] "mplBuiltinSame" @declareBuiltin ucall

[
  block.nextLabelIsSchema ["duplicate schema specifier" block compilerError] when
  TRUE @block.@nextLabelIsSchema set
] "mplBuiltinSchema" @declareBuiltin ucall

[@block defaultSet] "mplBuiltinSet" @declareBuiltin ucall

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
  refToVar: @block pop;
  compilable [
    refToVar staticityOfVar Weak = [@refToVar Static block makeStaticity @refToVar set] when
    refToVar @block push
  ] when
] "mplBuiltinStatic" @declareBuiltin ucall

[
  (
    [compilable]
    [refToVar: @block pop;]
    [refToVar isVirtual ["variable is virtual, cannot get address" block compilerError] when]
    [
      TRUE @refToVar getVar.@capturedAsMutable set #we need ref
      @refToVar makeVarRealCaptured
      refToVar @block makeVarTreeDirty
      refToDst: 0n64 VarNatX @block createVariable;
      Dynamic @refToDst getVar.@staticity set
      var: refToVar getVar;
      refToVar @refToDst "ptrtoint" @block createCastCopyPtrToNew
      refToDst @block push
    ]
  ) sequence
] "mplBuiltinStorageAddress" @declareBuiltin ucall

[
  refToVar: @block pop;
  compilable [
    refToVar isVirtual [
      refToVar isSchema [
        pointee: VarRef refToVar getVar.data.get;
        pointee isVirtual [
          0nx
        ] [
          pointee block getStorageSize
        ] if
      ] [
        0nx
      ] if
    ] [
      refToVar block getStorageSize
    ] if

    0n64 cast VarNatX @block createVariable Static @block makeStaticity @block createPlainIR @block push
  ] when
] "mplBuiltinStorageSize" @declareBuiltin ucall

[
  refToName: @block pop;
  (
    [compilable]
    [
      varName: refToName getVar;
      varName.data.getTag VarString = ~ ["argument must be string" block compilerError] when
    ]
    [
      refToName staticityOfVar Weak < [
        result: 0n64 VarNatX @block createVariable Dynamic @block makeStaticity @block createAllocIR;
        refToName result @block createGetTextSizeIR
        result @block push
      ] [
        string: VarString varName.data.get;
        string.getTextSize 0i64 cast 0n64 cast VarNatX @block createVariable Static @block makeStaticity @block createPlainIR @block push
      ] if
    ]
  ) sequence
] "mplBuiltinTextSize" @declareBuiltin ucall

[
  refToName: @block pop;
  compilable [
    refToName staticityOfVar Weak < ["name must be static string" block compilerError] when
    compilable [
      varName: refToName getVar;
      varName.data.getTag VarString = ~ ["name must be static string" block compilerError] when
      compilable [
        string: VarString varName.data.get;
        struct: Struct;

        string.chars.dataSize 0 < ~ [
          splitted: string splitString;
          splitted.success [
            splitted.chars [
              element: toString @block makeVarString;
              field: Field;
              processor.emptyNameInfo @field.@nameInfo set
              @element TRUE dynamic @block createRef @field.@refToVar set
              field @struct.@fields.pushBack
            ] each

            result: @struct move owner VarStruct @block createVariable;
            result isVirtual ~ [@result @block createAllocIR @result set] when
            resultStruct: VarStruct @result getVar.@data.get.get;

            i: 0 dynamic;
            [
              i resultStruct.fields.dataSize < [
                field: i @resultStruct.@fields.at;

                result isGlobal [
                  block.program.dataSize @field.@refToVar getVar.@allocationInstructionIndex set
                  "no alloc..." @block createComment # fake instruction

                  loadReg: field.refToVar @block createDerefToRegister;
                  @field.@refToVar block unglobalize
                  loadReg field.refToVar @block createStoreFromRegister

                  @field.@refToVar i result @block createGEPInsteadOfAlloc
                ] [
                  @field.@refToVar i result @block createGEPInsteadOfAlloc
                ] if
                i 1 + @i set TRUE
              ] &&
            ] loop

            result @block push
          ] [
            "wrong encoding in ctring" block compilerError
          ] if
        ] when
      ] when
    ] when
  ] when
] "mplBuiltinTextSplit" @declareBuiltin ucall

[
  code: @block pop;

  compilable [
    varCode: code getVar;

    varCode.data.getTag VarCode = ~ ["branch else must be a [CODE]" block compilerError] when

    compilable [
      codeIndex: VarCode varCode.data.get.index copy;
      astNode: codeIndex @multiParserResult.@memory.at;
      [astNode.data.getTag AstNodeType.Code =] "Not a code!" assert
      block.countOfUCall 1 + @block.@countOfUCall set
      block.countOfUCall 65535 > ["ucall limit exceeded" block compilerError] when
      indexArray: AstNodeType.Code astNode.data.get;
      indexArray VarCode varCode.data.get.file addIndexArrayToProcess
    ] when
  ] when
] "mplBuiltinUcall" @declareBuiltin ucall

[
  else: @block pop;
  then: @block pop;
  condition: @block pop;

  compilable [
    varElse: else getVar;
    varThen: then getVar;
    varCond: condition getVar;

    varElse.data.getTag VarCode = ~ ["branch else must be a [CODE]" block compilerError] when
    varThen.data.getTag VarCode = ~ ["branch then must be a [CODE]" block compilerError] when
    varCond.data.getTag VarCond = ~ ["condition has a wrong type" block compilerError] when

    compilable [
      condition staticityOfVar Weak > [
        value: VarCond varCond.data.get copy;
        code: value [VarCode varThen.data.get] [VarCode varElse.data.get] if;
        astNode: code.index @multiParserResult.@memory.at;
        [astNode.data.getTag AstNodeType.Code =] "Not a code!" assert
        block.countOfUCall 1 + @block.@countOfUCall set
        block.countOfUCall 65535 > ["ucall limit exceeded" block compilerError] when
        indexArray: AstNodeType.Code astNode.data.get;
        indexArray code.file addIndexArrayToProcess
      ] [
        "condition must be static" block compilerError
      ] if
    ] when
  ] when
] "mplBuiltinUif" @declareBuiltin ucall

[
  (
    [compilable]
    [refToName: @block pop;]
    [refToName staticityOfVar Weak < ["path must be static string" block compilerError] when]
    [
      varName: refToName getVar;
      varName.data.getTag VarString = ~ ["path must be static string" block compilerError] when
    ] [
      string: VarString varName.data.get;
      filename: string stripExtension;
      filename "" = ["invalid filename" block compilerError] when
    ] [
      name: string extractExtension;
      fr: filename processor.modules.find;
      fr.success [fr.value 0 < ~] && [
        fileBlock: fr.value processor.blocks.at.get;
        nameInfo: name findNameInfo;
        labelCount: 0;
        fileBlock.labelNames [
          label:;
          name "" = [label.nameInfo nameInfo =] || [label.refToVar isVirtual [label.refToVar getVar.data.getTag VarImport =] ||] && [
            label.nameInfo label.refToVar addOverloadForPre
            label.nameInfo label.refToVar NameCaseFromModule addNameInfo
            labelCount 1 + !labelCount
          ] when
        ] each

        labelCount 0 = [("no names match \"" name "\"") assembleString block compilerError] when
      ] [
        TRUE dynamic @processorResult.@findModuleFail set
        filename toString @processorResult.@errorInfo.@missedModule set
        ("module not found: " filename) assembleString block compilerError
      ] if
    ]
  ) sequence
] "mplBuiltinUse" @declareBuiltin ucall

[TRUE dynamic @block defaultUseOrIncludeModule] "mplBuiltinUseModule" @declareBuiltin ucall

[
  block.nextLabelIsVirtual ["duplicate virtual specifier" block compilerError] when
  TRUE @block.@nextLabelIsVirtual set
] "mplBuiltinVirtual" @declareBuiltin ucall

[
  VarCond VarNatX 1 + [a2:; a1:; "xor" makeStringView] [xor] [copy] [y:; x:;] mplNumberBinaryOp
] "mplBuiltinXor" @declareBuiltin ucall

[
  VarCond VarNatX 1 + [a:; "xor" makeStringView] [
    a:; a getVar.data.getTag VarCond = ["true, " makeStringView]["-1, " makeStringView] if
  ] [~] [x:;] mplNumberUnaryOp
] "mplBuiltinNot" @declareBuiltin ucall
