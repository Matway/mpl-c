"control" includeModule

"codeNode" includeModule
"processSubNodes" includeModule
"defaultImpl" includeModule

declareBuiltin: [
  virtual declareBuiltinName:;
  virtual declareBuiltinBody:;

  {processorResult: ProcessorResult Ref; processor: Processor Ref; currentNode: Block Ref; multiParserResult: MultiParserResult Cref;} () {} [
    processorResult:;
    processor:;
    currentNode:;
    multiParserResult:;
    failProc: @failProcForProcessor;
    @declareBuiltinBody ucall
  ] declareBuiltinName exportFunction
];

staticityOfBinResult: [
  s1:; s2:;
  s1 Dynamic > not s2 Dynamic > not or [
    Dynamic
  ] [
    s1 Weak = s2 Weak = and [
      Weak
    ] [
      Static
    ] if
  ] if
];

mplNumberBinaryOp: [
  exValidator:;
  getResultType:;
  opFunc:;
  getOpName:;
  copy lastTag:;
  copy firstTag:;

  arg2: pop;
  arg1: pop;

  compilable [
    var1: arg1 getVar;
    var2: arg2 getVar;
    var1.data.getTag firstTag < [var1.data.getTag lastTag < not] || ["first argument invalid" currentNode compilerError] [
      var2.data.getTag firstTag < [var2.data.getTag lastTag < not] || ["second argument invalid" currentNode compilerError] [
        arg1 arg2 variablesAreSame not [
          ("arguments have different schemas, left is " arg1 currentNode getMplType ", right is " arg2 currentNode getMplType) assembleString currentNode compilerError
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
            value1 value2 @opFunc call resultType cutValue resultType @currentNode createVariable
            arg1 staticityOfVar arg2 staticityOfVar staticityOfBinResult currentNode makeStaticity
            @currentNode createPlainIR push
          ] when
        ] staticCall
      ] [
        arg1 makeVarRealCaptured
        arg2 makeVarRealCaptured
        opName: arg1 arg2 @getOpName call;
        var1.data.getTag firstTag lastTag [
          copy tag:;
          value1: tag var1.data.get copy;
          value2: tag var2.data.get copy;
          resultType: tag @getResultType call;
          result: resultType zeroValue resultType @currentNode createVariable
          Dynamic currentNode makeStaticity
          @currentNode createAllocIR;
          opName @currentNode createBinaryOperation
          result push
        ] staticCall
      ] if
    ] when
  ] when
];

[
  VarNat8 VarReal64 1 + [a2:; a1:; a2 isReal ["fadd" makeStringView]["add" makeStringView] if] [+] [copy] [y:; x:;] mplNumberBinaryOp
] "mplBuiltinAdd" @declareBuiltin ucall

[
  VarNat8 VarReal64 1 + [a2:; a1:; a2 isReal ["fsub" makeStringView]["sub" makeStringView] if] [-] [copy] [y:; x:;] mplNumberBinaryOp
] "mplBuiltinSub" @declareBuiltin ucall

[
  VarNat8 VarReal64 1 + [a2:; a1:; a2 isReal ["fmul" makeStringView]["mul" makeStringView] if] [*] [copy] [y:; x:;] mplNumberBinaryOp
] "mplBuiltinMul" @declareBuiltin ucall

[
  VarNat8 VarReal64 1 + [a2:; a1:; a2 isReal ["fdiv" makeStringView][a2 isNat ["udiv" makeStringView] ["sdiv" makeStringView] if] if] [/] [copy] [
    y:; x:;
    y y - y = ["division by zero" currentNode compilerError] when
  ] mplNumberBinaryOp
] "mplBuiltinDiv" @declareBuiltin ucall

[
  VarNat8 VarIntX 1 + [a2:; a1:; a2 isNat ["urem" makeStringView] ["srem" makeStringView] if] [mod] [copy] [
    y:; x:;
    y y - y = ["division by zero" currentNode compilerError] when
  ] mplNumberBinaryOp
] "mplBuiltinMod" @declareBuiltin ucall

[
  arg2: pop;
  arg1: pop;

  compilable [
    comparable: [
      arg:;
      arg isPlain [arg getVar.data.getTag VarString =] ||
    ];

    var1: arg1 getVar;
    var2: arg2 getVar;

    arg1 comparable not [ "first argument is not comparable" currentNode compilerError ] [
      arg2 comparable not [ "second argument is not comparable" currentNode compilerError ] [
        arg1 arg2 variablesAreSame not [
          ("arguments have different schemas, left is " arg1 currentNode getMplType ", right is " arg2 currentNode getMplType) assembleString currentNode compilerError
        ] when
      ] if
    ] if

    compilable [
      arg1 staticityOfVar Dynamic > arg2 staticityOfVar Dynamic > and [
        var1.data.getTag VarString = [
          value1: VarString var1.data.get copy;
          value2: VarString var2.data.get copy;
          value1 value2 = VarCond @currentNode createVariable
          arg1 staticityOfVar arg2 staticityOfVar staticityOfBinResult currentNode makeStaticity
          @currentNode createPlainIR push
        ] [
          var1.data.getTag VarCond VarReal64 1 + [
            copy tag:;
            value1: tag var1.data.get copy;
            value2: tag var2.data.get copy;
            value1 value2 = VarCond @currentNode createVariable
            arg1 staticityOfVar arg2 staticityOfVar staticityOfBinResult currentNode makeStaticity
            @currentNode createPlainIR push
          ] staticCall
        ] if
      ] [
        arg1 makeVarRealCaptured
        arg2 makeVarRealCaptured

        var1.data.getTag VarString = [
          result: FALSE VarCond @currentNode createVariable Dynamic @currentNode makeStaticity @currentNode createAllocIR;
          "icmp eq" makeStringView @currentNode createBinaryOperation
          result push
        ] [
          arg1 isReal [
            var1.data.getTag VarReal32 VarReal64 1 + [
              copy tag:;
              result: FALSE VarCond @currentNode createVariable Dynamic @currentNode makeStaticity @currentNode createAllocIR;
              "fcmp oeq" @currentNode createBinaryOperation
              result push
            ] staticCall
          ] [
            var1.data.getTag VarCond VarIntX 1 + [
              copy tag:;
              result: FALSE VarCond @currentNode createVariable Dynamic @currentNode makeStaticity @currentNode createAllocIR;
              "icmp eq" @currentNode createBinaryOperation
              result push
            ] staticCall
          ] if
        ] if
      ] if
    ] when
  ] when
] "mplBuiltinEqual" @declareBuiltin ucall

[
  VarNat8 VarReal64 1 + [
    a2:; a1:; a2 isReal ["fcmp olt" makeStringView][a2 isNat ["icmp ult" makeStringView] ["icmp slt" makeStringView] if] if
  ] [<] [t:; VarCond] [y:; x:;] mplNumberBinaryOp
] "mplBuiltinLess" @declareBuiltin ucall

[
  VarNat8 VarReal64 1 + [
    a2:; a1:; a2 isReal ["fcmp ogt" makeStringView][a2 isNat ["icmp ugt" makeStringView] ["icmp sgt" makeStringView] if] if
  ] [>] [t:; VarCond] [y:; x:;] mplNumberBinaryOp
] "mplBuiltinGreater" @declareBuiltin ucall

mplNumberUnaryOp: [
  exValidator:;
  opFunc:;
  getMidOpName:;
  getOpName:;
  copy lastTag:;
  copy firstTag:;

  arg: pop;

  compilable [
    var: arg getVar;
    var.data.getTag firstTag < [var.data.getTag lastTag < not] || ["argument invalid" currentNode compilerError] when

    compilable [
      arg staticityOfVar Dynamic > [
        var.data.getTag firstTag lastTag [
          copy tag:;
          value: tag var.data.get copy;
          resultType: tag copy;
          value @exValidator call
          compilable [
            value @opFunc call resultType cutValue resultType @currentNode createVariable
            arg staticityOfVar currentNode makeStaticity
            @currentNode createPlainIR push
          ] when
        ] staticCall
      ] [
        arg makeVarRealCaptured
        opName: arg @getOpName call;
        mopName: arg @getMidOpName call;
        var.data.getTag firstTag lastTag [
          copy tag:;
          value: tag var.data.get copy;
          resultType: tag copy;
          result: resultType zeroValue resultType @currentNode createVariable
          Dynamic currentNode makeStaticity
          @currentNode createAllocIR;
          opName mopName @currentNode createUnaryOperation
          result push
        ] staticCall
      ] if
    ] when
  ] when
];

[
  VarCond VarNatX 1 + [a:; "xor" makeStringView] [
    a:; a getVar.data.getTag VarCond = ["true, " makeStringView]["-1, " makeStringView] if
  ] [not] [x:;] mplNumberUnaryOp
] "mplBuiltinNot" @declareBuiltin ucall

[
  VarCond VarNatX 1 + [a2:; a1:; "xor" makeStringView] [xor] [copy] [y:; x:;] mplNumberBinaryOp
] "mplBuiltinXor" @declareBuiltin ucall

[
  VarCond VarNatX 1 + [a2:; a1:; "and" makeStringView] [and] [copy] [y:; x:;] mplNumberBinaryOp
] "mplBuiltinAnd" @declareBuiltin ucall

[
  VarCond VarNatX 1 + [a2:; a1:; "or" makeStringView] [or] [copy] [y:; x:;] mplNumberBinaryOp
] "mplBuiltinOr" @declareBuiltin ucall

[
  TRUE VarCond @currentNode createVariable @currentNode createPlainIR push
] "mplBuiltinTrue" @declareBuiltin ucall

[
  FALSE VarCond @currentNode createVariable @currentNode createPlainIR push
] "mplBuiltinFalse" @declareBuiltin ucall

[
  LF toString makeVarString push
] "mplBuiltinLF" @declareBuiltin ucall

[
  VarInt8 VarReal64 1 + [
    a:; a isAnyInt ["sub" makeStringView]["fsub" makeStringView] if
  ] [
    a:; a isAnyInt ["0, " makeStringView]["0x0000000000000000, " makeStringView] if
  ] [neg] [x:;] mplNumberUnaryOp
] "mplBuiltinNeg" @declareBuiltin ucall

mplNumberBuiltinOp: [
  exValidator:;
  opFunc:;
  getOpName:;

  arg: pop;

  compilable [
    var: arg getVar;
    arg isReal not ["argument invalid" currentNode compilerError] when

    compilable [
      arg staticityOfVar Dynamic > [
        var.data.getTag VarReal32 VarReal64 1 + [
          copy tag:;
          value: tag var.data.get copy;
          resultType: tag copy;
          value @exValidator call
          compilable [
            value @opFunc call resultType cutValue resultType @currentNode createVariable
            arg staticityOfVar currentNode makeStaticity
            @currentNode createPlainIR push
          ] when
        ] staticCall
      ] [
        arg makeVarRealCaptured
        opName: arg @getOpName call;
        var.data.getTag VarReal32 VarReal64 1 + [
          copy tag:;
          value: tag var.data.get copy;
          resultType: tag copy;
          result: resultType zeroValue resultType @currentNode createVariable
          Dynamic currentNode makeStaticity
          @currentNode createAllocIR;

          args: IRArgument Array;

          irarg: IRArgument;
          arg @currentNode createDerefToRegister @irarg.@irNameId set
          arg getMplSchema.irTypeId @irarg.@irTypeId set
          FALSE @irarg.@byRef set
          irarg @args.pushBack

          result args String @opName @currentNode createCallIR retName:;

          retName result @currentNode createStoreFromRegister

          result push
        ] staticCall
      ] if
    ] when
  ] when
];

[
  TRUE dynamic @processor.@usedFloatBuiltins set
  [a:; a getVar.data.getTag VarReal32 = ["@llvm.sin.f32" makeStringView]["@llvm.sin.f64" makeStringView] if
  ] [sin] [x:;] mplNumberBuiltinOp
] "mplBuiltinSin" @declareBuiltin ucall

[
  TRUE dynamic @processor.@usedFloatBuiltins set
  [a:; a getVar.data.getTag VarReal32 = ["@llvm.cos.f32" makeStringView]["@llvm.cos.f64" makeStringView] if
  ] [cos] [x:;] mplNumberBuiltinOp
] "mplBuiltinCos" @declareBuiltin ucall

[
  TRUE dynamic @processor.@usedFloatBuiltins set
  [a:; a getVar.data.getTag VarReal32 = ["@llvm.sqrt.f32" makeStringView]["@llvm.sqrt.f64" makeStringView] if
  ] [sqrt] [x:;] mplNumberBuiltinOp
] "mplBuiltinSqrt" @declareBuiltin ucall

[
  TRUE dynamic @processor.@usedFloatBuiltins set
  [a:; a getVar.data.getTag VarReal32 = ["@llvm.ceil.f32" makeStringView]["@llvm.ceil.f64" makeStringView] if
  ] [ceil] [x:;] mplNumberBuiltinOp
] "mplBuiltinCeil" @declareBuiltin ucall

[
  TRUE dynamic @processor.@usedFloatBuiltins set
  [a:; a getVar.data.getTag VarReal32 = ["@llvm.floor.f32" makeStringView]["@llvm.floor.f64" makeStringView] if
  ] [floor] [x:;] mplNumberBuiltinOp
] "mplBuiltinFloor" @declareBuiltin ucall

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
  TRUE dynamic @processor.@usedFloatBuiltins set
  arg2: pop;
  arg1: pop;

  compilable [
    var1: arg1 getVar;
    var2: arg2 getVar;
    arg1 isReal not ["first argument invalid" currentNode compilerError] [
      arg2 isReal not ["second argument invalid" currentNode compilerError] [
        arg1 arg2 variablesAreSame not [
          ("arguments have different schemas, left is " arg1 currentNode getMplType ", right is " arg2 currentNode getMplType) assembleString currentNode compilerError
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
            value1 value2 ^ resultType cutValue resultType @currentNode createVariable
            arg1 staticityOfVar arg2 staticityOfVar staticityOfBinResult @currentNode makeStaticity
            @currentNode createPlainIR push
          ] when
        ] staticCall
      ] [
        arg1 makeVarRealCaptured
        arg2 makeVarRealCaptured

        var1.data.getTag VarReal32 VarReal64 1 + [
          copy tag:;
          resultType: tag copy;
          result: resultType zeroValue resultType @currentNode createVariable
          Dynamic @currentNode makeStaticity
          @currentNode createAllocIR;

          args: IRArgument Array;

          irarg: IRArgument;
          FALSE @irarg.@byRef set
          arg1 @currentNode createDerefToRegister @irarg.@irNameId set
          arg1 getMplSchema.irTypeId @irarg.@irTypeId set
          irarg @args.pushBack
          arg2 @currentNode createDerefToRegister @irarg.@irNameId set
          arg2 getMplSchema.irTypeId @irarg.@irTypeId set
          irarg @args.pushBack

          result args String tag VarReal32 = ["@llvm.pow.f32" makeStringView] ["@llvm.pow.f64" makeStringView] if @currentNode createCallIR retName:;

          @retName result @currentNode createStoreFromRegister

          result push
        ] staticCall
      ] if
    ] when
  ] when
] "mplBuiltinPow" @declareBuiltin ucall

mplShiftBinaryOp: [
  opFunc:;
  getOpName:;

  arg2: pop;
  arg1: pop;

  compilable [
    var1: arg1 getVar;
    var2: arg2 getVar;
    arg1 isAnyInt not ["first argument invalid" currentNode compilerError] [
      arg2 isNat not ["second argument invalid" currentNode compilerError] when
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
            value2 63n64 > ["shift value must be less than 64" currentNode compilerError] when

            compilable [
              value1 value2 @opFunc call resultType cutValue resultType @currentNode createVariable
              arg1 staticityOfVar arg2 staticityOfVar staticityOfBinResult @currentNode makeStaticity
              @currentNode createPlainIR push
            ] when
          ] staticCall
        ] staticCall
      ] [
        arg1 makeVarRealCaptured
        arg2 makeVarRealCaptured

        opName: arg1 arg2 @getOpName call;
        var1.data.getTag VarNat8 VarIntX 1 + [
          copy tag:;
          resultType: tag copy;
          result: resultType zeroValue resultType @currentNode createVariable
          Dynamic @currentNode makeStaticity
          @currentNode createAllocIR;
          arg1 currentNode getStorageSize arg2 currentNode getStorageSize = [
            opName @currentNode createBinaryOperation
          ] [
            opName @currentNode createBinaryOperationDiffTypes
          ] if

          result push
        ] staticCall
      ] if
    ] when
  ] when
];

[
  [t2:; t1:; "shl" makeStringView][lshift] mplShiftBinaryOp
] "mplBuiltinLShift" @declareBuiltin ucall

[
  [t2:; t1:; t1 isNat ["lshr" makeStringView]["ashr" makeStringView] if][rshift] mplShiftBinaryOp
] "mplBuiltinRShift" @declareBuiltin ucall

[TRUE currentNode defaultMakeConstWith] "mplBuiltinConst" @declareBuiltin ucall

[
  currentNode defaultCall
] "mplBuiltinCall" @declareBuiltin ucall

[
  (
    [compilable]
    [refToName: pop;]
    [
      refToName staticityOfVar Weak < ["method name must be a static string" currentNode compilerError] when
    ]
    [
      varName: refToName getVar;
      varName.data.getTag VarString = not ["method name must be a static string" currentNode compilerError] when
    ]
    [
      fieldNameInfo: VarString varName.data.get findNameInfo;
      fieldNameInfo pop 0 processMember
    ]
  ) sequence
] "mplBuiltinCallField" @declareBuiltin ucall

[
  code: pop;

  compilable [
    varCode: code getVar;

    varCode.data.getTag VarCode = not ["branch else must be a [CODE]" currentNode compilerError] when

    compilable [
      codeIndex: VarCode varCode.data.get.index copy;
      astNode: codeIndex @multiParserResult.@memory.at;
      [astNode.data.getTag AstNodeType.Code =] "Not a code!" assert
      currentNode.countOfUCall 1 + @currentNode.@countOfUCall set
      currentNode.countOfUCall 65535 > ["ucall limit exceeded" currentNode compilerError] when
      indexArray: AstNodeType.Code astNode.data.get;
      indexArray addIndexArrayToProcess
    ] when
  ] when
] "mplBuiltinUcall" @declareBuiltin ucall

[
  refToVar: pop;
  compilable [
    refToVar makeVarTreeDynamic
    refToVar push
  ] when
] "mplBuiltinDynamic" @declareBuiltin ucall

[
  refToVar: pop;
  compilable [
    refToVar @currentNode makeVarTreeDirty
    refToVar push
  ] when
] "mplBuiltinDirty" @declareBuiltin ucall

[
  refToVar: pop;
  compilable [
    refToVar staticityOfVar Weak = [refToVar Static currentNode makeStaticity @refToVar set] when
    refToVar push
  ] when
] "mplBuiltinStatic" @declareBuiltin ucall

[@currentNode defaultSet] "mplBuiltinSet" @declareBuiltin ucall

mplBuiltinProcessAtList: [
  refToStruct: pop;
  refToIndex: pop;
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
          pointeeVar.data.getTag VarStruct = not ["not a combined" currentNode compilerError] when
        ]
        [indexVar.data.getTag VarInt32 = not ["index must be Int32" currentNode compilerError] when ]
        [refToIndex staticityOfVar Weak < [ "index must be static" currentNode compilerError] when ]
        [
          index: VarInt32 indexVar.data.get 0 cast;
          struct: VarStruct pointeeVar.data.get.get;
          index 0 < [index struct.fields.getSize < not] || ["index is out of bounds" currentNode compilerError] when
        ] [
          field: index struct.fields.at.refToVar;
          field VarRef TRUE dynamic TRUE dynamic TRUE dynamic @currentNode createVariableWithVirtual @result set
          refToStruct.mutable @result.@mutable set
          result fullUntemporize
        ]
      ) sequence
    ] [
      (
        [compilable]
        [structVar.data.getTag VarStruct = not [ "not a combined" currentNode compilerError] when]
        [indexVar.data.getTag VarInt32 = not ["index must be Int32" currentNode compilerError] when]
        [
          struct: VarStruct structVar.data.get.get;
          refToIndex staticityOfVar Weak < [
            struct.homogeneous [
              struct.fields.dataSize 0 > [
                # create dynamic getIndex
                realRefToStruct: refToStruct;
                realStructVar: structVar;
                realStruct: struct;
                refToStruct staticityOfVar Virtual < not [
                  "can't get dynamic index in virtual struct" currentNode compilerError
                ] when

                refToIndex makeVarRealCaptured
                firstField: 0 realStruct.fields.at.refToVar;
                fieldRef: firstField copyVarFromParent;
                firstField.hostId currentNode.id = not [
                  fBegin: RefToVar;
                  fEnd: RefToVar;
                  fieldRef @fBegin @fEnd ShadowReasonField @currentNode makeShadowsDynamic
                  fEnd @fieldRef set
                ] when

                refToStruct.mutable @fieldRef.@mutable set
                fieldRef fullUntemporize
                fieldRef staticityOfVar Virtual < not [
                  "dynamic index is combined of virtuals" currentNode compilerError
                ] [
                  fieldRef @currentNode makeVarTreeDynamicStoraged
                  fieldRef currentNode unglobalize
                  fieldRef refToIndex realRefToStruct @currentNode createDynamicGEP
                  fieldVar: fieldRef getVar;
                  currentNode.program.dataSize 1 - @fieldVar.@getInstructionIndex set
                  fieldRef @result set
                ] if

                refToStruct.mutable [
                  refToStruct @currentNode makeVarTreeDirty
                ] when
              ] [
                "struct is empty" currentNode compilerError
              ] if
            ] [
              "dynamic index in non-homogeneous combined" currentNode compilerError
            ] if
          ] [
            index: VarInt32 indexVar.data.get 0 cast;
            index refToStruct processStaticAt @result set
          ] if
        ]
      ) sequence
    ] if
  ] when

  result
];

[
  field: mplBuiltinProcessAtList;
  compilable [
    field isVirtual [field makeVirtualVarReal @field set] when
    field derefAndPush
  ] when
] "mplBuiltinAt" @declareBuiltin ucall

[
  field: mplBuiltinProcessAtList;
  compilable [
    field setRef
  ] when
] "mplBuiltinExclamation" @declareBuiltin ucall

[
  else: pop;
  then: pop;
  condition: pop;

  compilable [
    varElse: else getVar;
    varThen: then getVar;
    varCond: condition getVar;

    varElse.data.getTag VarCode = not ["branch else must be a [CODE]" currentNode compilerError] when
    varThen.data.getTag VarCode = not ["branch then must be a [CODE]" currentNode compilerError] when
    varCond.data.getTag VarCond = not [("condition has a wrong type " condition currentNode getMplType) assembleString currentNode compilerError] when

    compilable [
      condition staticityOfVar Weak > [
        value: VarCond varCond.data.get copy;
        value [
          VarCode varThen.data.get.index "staticIfThen" makeStringView processCall
        ] [
          VarCode varElse.data.get.index "staticIfElse" makeStringView processCall
        ] if
      ] [
        condition
        VarCode varThen.data.get.index @multiParserResult.@memory.at
        VarCode varElse.data.get.index @multiParserResult.@memory.at
        processIf
      ] if
    ] when
  ] when
] "mplBuiltinIf" @declareBuiltin ucall

[
  else: pop;
  then: pop;
  condition: pop;

  compilable [
    varElse: else getVar;
    varThen: then getVar;
    varCond: condition getVar;

    varElse.data.getTag VarCode = not ["branch else must be a [CODE]" currentNode compilerError] when
    varThen.data.getTag VarCode = not ["branch then must be a [CODE]" currentNode compilerError] when
    varCond.data.getTag VarCond = not ["condition has a wrong type" currentNode compilerError] when

    compilable [
      condition staticityOfVar Weak > [
        value: VarCond varCond.data.get copy;
        codeIndex: value [VarCode varThen.data.get.index copy] [VarCode varElse.data.get.index copy] if;
        astNode: codeIndex @multiParserResult.@memory.at;
        [astNode.data.getTag AstNodeType.Code =] "Not a code!" assert
        currentNode.countOfUCall 1 + @currentNode.@countOfUCall set
        currentNode.countOfUCall 65535 > ["ucall limit exceeded" currentNode compilerError] when
        indexArray: AstNodeType.Code astNode.data.get;
        indexArray addIndexArrayToProcess
      ] [
        "condition must be static" currentNode compilerError
      ] if
    ] when
  ] when
] "mplBuiltinUif" @declareBuiltin ucall

[
  body: pop;

  (
    [compilable]
    [
      varBody: body getVar;
      varBody.data.getTag VarCode = not ["body must be [CODE]" currentNode compilerError] when
    ] [
      astNode: VarCode varBody.data.get.index @multiParserResult.@memory.at;
      astNode processLoop
    ]
  ) sequence
] "mplBuiltinLoop" @declareBuiltin ucall

parseFieldToSignatureCaptureArray: [
  refToStruct:;
  result: RefToVar Array;
  varStruct: refToStruct getVar;
  varStruct.data.getTag VarStruct = not ["argument list must be a struct" currentNode compilerError] when

  compilable [
    VarStruct varStruct.data.get.get.fields [
      refToVar: .refToVar;
      refToVar isVirtual ["input cannot be virtual" currentNode compilerError] when
      refToVar @result.pushBack
    ] each
  ] when

  result
];

parseSignature: [
  result: CFunctionSignature;
  (
    [compilable]
    [options: pop;]
    [
      optionsVar: options getVar;
      optionsVar.data.getTag VarStruct = not ["options must be a struct" currentNode compilerError] when
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
              [variadicVar.data.getTag VarCond = not ["value must be Cond" currentNode compilerError] when]
              [variadicRefToVar staticityOfVar Weak < ["value must be Static" currentNode compilerError] when]
              [VarCond variadicVar.data.get @result.@variadic set]
            ) sequence
          ]
          processor.conventionNameInfo [
            conventionRefToVarRef: f.refToVar;
            conventionVarRef: conventionRefToVarRef getVar;
            (
              [compilable]
              [conventionVarRef.data.getTag VarRef = not ["value must be String Ref" currentNode compilerError] when]
              [conventionRefToVarRef staticityOfVar Weak < ["value must be Static" currentNode compilerError] when]
              [
                conventionRefToVar: VarRef conventionVarRef.data.get;
                conventionVar: conventionRefToVar getVar;
                conventionVar.data.getTag VarString = not ["value must be String Ref" currentNode compilerError] when
              ]
              [conventionRefToVar staticityOfVar Weak < ["value must be Static" currentNode compilerError] when]
              [
                string: VarString conventionVar.data.get;
                string @result.@convention set
                TRUE @hasConvention set
              ]
            ) sequence
          ] [
            ("unknown option: " f.nameInfo processor.nameInfos.at.name) assembleString currentNode compilerError
          ]
        ) case
      ] each
    ]
    [
      hasConvention not [
        String @result.@convention set
      ] when

      return: pop;
      compilable [
        return isVirtual [
          returnVar: return getVar;
          returnVar.data.getTag VarStruct = not [(return currentNode getMplType " can not be a return type") assembleString currentNode compilerError] when
        ] [
          #todo: detect temporality
          returnVar: return getVar;
          returnVar.temporary [
            return @result.@outputs.pushBack
          ] [
            return TRUE dynamic @currentNode createRef @result.@outputs.pushBack
          ] if
        ] if
      ] when
    ]
    [arguments: pop;]
    [
      arguments parseFieldToSignatureCaptureArray @result.@inputs set
    ]
  ) sequence
  result
];

[
  (
    [compilable]
    [currentNode.parent 0 = not ["export must be global" currentNode compilerError] when]
    [refToName: pop;]
    [refToName staticityOfVar Weak < ["function name must be static string" currentNode compilerError] when]
    [
      varName: refToName getVar;
      varName.data.getTag VarString = not ["function name must be static string" currentNode compilerError] when
    ]
    [refToBody: pop;]
    [
      varBody: refToBody getVar;
      varBody.data.getTag VarCode = not ["must be a code" currentNode compilerError] when
    ]
    [signature: parseSignature;]
    [
      astNode: VarCode varBody.data.get.index @multiParserResult.@memory.at;
      index: signature astNode VarString varName.data.get makeStringView FALSE dynamic processExportFunction;
    ]
  ) sequence
] "mplBuiltinExportFunction" @declareBuiltin ucall

[
  (
    [compilable]
    [currentNode.parent 0 = not ["export must be global" currentNode compilerError] when]
    [refToName: pop;]
    [refToVar: pop;]
    [refToName staticityOfVar Weak < ["variable name must be static string" currentNode compilerError] when]
    [
      varName: refToName getVar;
      varName.data.getTag VarString = not ["variable name must be static string" currentNode compilerError] when
    ] [
      refToVar isVirtual ["cannot export virtual var" currentNode compilerError] when
    ] [
      refToVar getVar.temporary not [
        refToVar TRUE dynamic @currentNode createRef @refToVar set
      ] when
      var: refToVar getVar;
      FALSE @var.@temporary set
    ] [
      name: VarString varName.data.get;
      oldIrNameId: var.irNameId copy;
      oldInstructionIndex: var.globalDeclarationInstructionIndex copy;
      ("@" name) assembleString makeStringId @var.@irNameId set
      instruction: var.globalDeclarationInstructionIndex @processor.@prolog.at;
      refToVar createVarExportIR drop
      @processor.@prolog.last move @instruction set
      @processor.@prolog.popBack
      TRUE @refToVar.@mutable set
      oldIrNameId var.irNameId refToVar getMplSchema.irTypeId createGlobalAliasIR
      oldInstructionIndex @var.@globalDeclarationInstructionIndex set

      nameInfo: name findNameInfo;
      nameInfo refToVar addOverloadForPre
      nameInfo refToVar NameCaseLocal addNameInfo
      processor.options.debug [
        d: nameInfo refToVar currentNode addGlobalVariableDebugInfo;
        globalInstruction: var.globalDeclarationInstructionIndex @processor.@prolog.at;
        ", !dbg !"   @globalInstruction.cat
        d            @globalInstruction.cat
      ] when
    ]
  ) sequence
] "mplBuiltinExportVariable" @declareBuiltin ucall

[
  (
    [compilable]
    [currentNode.parent 0 = not ["import must be global" currentNode compilerError] when]
    [refToName: pop;]
    [refToName staticityOfVar Weak < ["function name must be static string" currentNode compilerError] when]
    [
      varName: refToName getVar;
      varName.data.getTag VarString = not ["function name must be static string" currentNode compilerError] when
    ]
    [signature: parseSignature;]
    [block: signature VarString varName.data.get makeStringView FALSE dynamic processImportFunction Block addressToReference;]
  ) sequence
] "mplBuiltinImportFunction" @declareBuiltin ucall

[
  (
    [compilable]
    [signature: parseSignature;]
    [
      name: ("null." processor.blocks.getSize) assembleString;
      block: signature name makeStringView TRUE dynamic processImportFunction Block addressToReference;
    ]
    [
      gnr: block.varNameInfo getName;
      cnr: gnr captureName;
      refToVar: cnr.refToVar copy;

      refToVar push
    ]
  ) sequence
] "mplBuiltinCodeRef" @declareBuiltin ucall

[
  currentNode.parent 0 = not ["import must be global" currentNode compilerError] when
  compilable [
    refToName: pop;
    refToType: pop;
    compilable [
      refToName staticityOfVar Weak < ["variable name must be static string" currentNode compilerError] when
      compilable [
        varName: refToName getVar;
        varName.data.getTag VarString = not ["variable name must be static string" currentNode compilerError] when
        compilable [
          varType: refToType getVar;
          refToType isVirtual [
            "variable cant be virtual" currentNode compilerError
          ] [
            varType.temporary not [
              refToType TRUE dynamic @currentNode createRef @refToType set
            ] when

            name: VarString varName.data.get;
            newRefToVar: refToType @currentNode copyVar;
            newVar: newRefToVar getVar;
            TRUE @newRefToVar.@mutable set
            FALSE @newVar.@temporary set
            ("@" name) assembleString makeStringId @newVar.@irNameId set
            newRefToVar createVarImportIR makeVarTreeDynamic

            nameInfo: name findNameInfo;
            nameInfo newRefToVar addOverloadForPre
            nameInfo newRefToVar NameCaseLocal addNameInfo
            processor.options.debug [newRefToVar isVirtual not] && [
              d: nameInfo newRefToVar currentNode addGlobalVariableDebugInfo;
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
  refToVar: pop;
  compilable [
    refToVar isVirtual not [refToVar makeVarRealCaptured] when

    refToVar getVar.temporary [
      "temporary objects cannot be copied" currentNode compilerError
    ] [
      refToVar getVar.data.getTag VarImport = [
        "functions cannot be copied" currentNode compilerError
      ] [
        refToVar getVar.data.getTag VarString = [
          "builtin-strings cannot be copied" currentNode compilerError
        ] [
          result: refToVar @currentNode copyVarToNew;
          result isVirtual [
            result isAutoStruct ["unable to copy virtual autostruct" currentNode compilerError] when
          ] [
            TRUE @result.@mutable set
            refToVar result @currentNode createCopyToNew
          ] if

          result push
        ] if
      ] if
    ] if
  ] when
] "mplBuiltinCopy" @declareBuiltin ucall

[
  refToVar: pop;
  compilable [
    result: refToVar @currentNode copyVarToNew;
    result isVirtual not [result isUnallocable not] && [
      TRUE @result.@mutable set
      result @currentNode createAllocIR callInit
    ] when

    result push
  ] when
] "mplBuiltinNewVarOfTheSameType" @declareBuiltin ucall

[
  refToSchema: pop;
  refToVar: pop;

  compilable [
    varSrc: refToVar getVar;
    varSchema: refToSchema getVar;
    varSchema.data.getTag VarRef = [refToSchema isVirtual] && [
      VarRef varSchema.data.get @currentNode copyVarFromChild @refToSchema set
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
              branchSrc branchSchema cast tagDst cutValue tagDst @currentNode createVariable @currentNode createPlainIR @refToDst set
            ] staticCall
          ] staticCall

          refToVar staticityOfVar refToDst getVar.@staticity set
          refToDst push
        ] [
          refToDst: RefToVar;
          varSchema: refToSchema getVar;
          varSchema.data.getTag VarNat8 VarReal64 1 + [
            copy tagDst:;
            branchSchema: tagDst @varSchema.@data.get;
            branchSchema tagDst @currentNode createVariable @refToDst set
          ] staticCall

          Dynamic refToDst getVar.@staticity set

          # a lot of cases for different casts
          refToVar isReal refToSchema isReal or [
            refToVar isReal refToSchema isReal and [
              #Real to Real
              refToVar currentNode getStorageSize refToSchema currentNode getStorageSize = [
                refToVar refToDst @currentNode createCopyToNew
              ] [
                refToVar currentNode getStorageSize refToSchema currentNode getStorageSize < [
                  refToVar refToDst "fpext" @currentNode createCastCopyToNew
                ] [
                  refToVar refToDst "fptrunc" @currentNode createCastCopyToNew
                ] if
              ] if
            ] [
              refToVar isAnyInt [
                #Int to Real
                refToVar isNat [
                  refToVar refToDst "uitofp" @currentNode createCastCopyToNew
                ] [
                  refToVar refToDst "sitofp" @currentNode createCastCopyToNew
                ] if
              ] [
                #Real to Int
                [refToSchema isAnyInt] "Wrong cast number case!" assert
                refToSchema isNat [
                  refToVar refToDst "fptoui" @currentNode createCastCopyToNew
                ] [
                  refToVar refToDst "fptosi" @currentNode createCastCopyToNew
                ] if
              ] if
            ] if
          ] [
            #Int to Int
            refToVar currentNode getStorageSize refToSchema currentNode getStorageSize = [
              refToVar refToDst @currentNode createCopyToNew
            ] [
              refToVar currentNode getStorageSize refToSchema currentNode getStorageSize < [
                refToVar isNat [
                  refToVar refToDst "zext" @currentNode createCastCopyToNew
                ] [
                  refToVar refToDst "sext" @currentNode createCastCopyToNew
                ] if
              ] [
                refToVar refToDst "trunc" @currentNode createCastCopyToNew
              ] if
            ] if
          ] if
          # here ends cast case list

          refToDst push
        ] if
      ] when
    ] [
      "can cast only numbers" currentNode compilerError
    ] if
  ] when
] "mplBuiltinCast" @declareBuiltin ucall

[
  (
    [compilable]
    [refToVar: pop;]
    [refToVar isVirtual ["variable is virtual, cannot get address" currentNode compilerError] when]
    [
      TRUE refToVar getVar.@capturedAsMutable set #we need ref
      refToVar makeVarRealCaptured
      refToVar @currentNode makeVarTreeDirty
      refToDst: 0n64 VarNatX @currentNode createVariable;
      Dynamic @refToDst getVar.@staticity set
      var: refToVar getVar;
      refToVar refToDst "ptrtoint" @currentNode createCastCopyPtrToNew
      refToDst push
    ]
  ) sequence
] "mplBuiltinStorageAddress" @declareBuiltin ucall

[
  refToSchema: pop;
  refToVar: pop;

  compilable [
    var: refToVar getVar;
    varSchema: refToSchema getVar;
    var.data.getTag VarNatX = [
      var: refToVar getVar;
      varSchema: refToSchema getVar;
      schemaOfResult: RefToVar;
      varSchema.data.getTag VarRef = [
        refToSchema isSchema [
          VarRef varSchema.data.get @currentNode copyVarFromChild @schemaOfResult set
          refToSchema.mutable schemaOfResult.mutable and @schemaOfResult.@mutable set
        ] [
          [FALSE] "Unable in current semantic!" assert
        ] if
      ] [
        refToSchema @schemaOfResult set
      ] if

      schemaOfResult isVirtual [
        "pointee is virtual, cannot cast" currentNode compilerError
      ] [
        refToDst: schemaOfResult VarRef @currentNode createVariable;
        Dirty refToDst getVar.@staticity set
        refToVar refToDst "inttoptr" @currentNode createCastCopyToNew
        refToDst derefAndPush
      ] if
    ] [
      "address must be a NatX" currentNode compilerError
    ] if
  ] when
] "mplBuiltinAddressToReference" @declareBuiltin ucall

[
  currentNode.nextLabelIsConst ["duplicate virtual specifier" currentNode compilerError] when
  TRUE @currentNode.@nextLabelIsConst set
] "mplBuiltinConstVar" @declareBuiltin ucall

[
  currentNode.nextLabelIsVirtual ["duplicate virtual specifier" currentNode compilerError] when
  TRUE @currentNode.@nextLabelIsVirtual set
] "mplBuiltinVirtual" @declareBuiltin ucall

[
  currentNode.nextLabelIsSchema ["duplicate schema specifier" currentNode compilerError] when
  TRUE @currentNode.@nextLabelIsSchema set
] "mplBuiltinSchema" @declareBuiltin ucall

[TRUE dynamic currentNode defaultUseOrIncludeModule] "mplBuiltinUseModule" @declareBuiltin ucall
[FALSE dynamic currentNode defaultUseOrIncludeModule] "mplBuiltinIncludeModule" @declareBuiltin ucall

[
  refToName: pop;
  (
    [compilable]
    [
      varName: refToName getVar;
      varName.data.getTag VarString = not ["argument must be string" currentNode compilerError] when
    ]
    [
      refToName staticityOfVar Weak < [
        result: 0n64 VarNatX @currentNode createVariable Dynamic @currentNode makeStaticity @currentNode createAllocIR;
        refToName result @currentNode createGetTextSizeIR
        result push
      ] [
        string: VarString varName.data.get;
        string.getTextSize 0i64 cast 0n64 cast VarNatX @currentNode createVariable Static @currentNode makeStaticity @currentNode createPlainIR push
      ] if
    ]
  ) sequence
] "mplBuiltinTextSize" @declareBuiltin ucall

[
  (
    [compilable]
    [refToStr2: pop;]
    [refToStr2 staticityOfVar Weak < ["must be static string" currentNode compilerError] when]
    [
      varStr2: refToStr2 getVar;
      varStr2.data.getTag VarString = not ["must be static string" currentNode compilerError] when
    ]
    [refToStr1: pop;]
    [refToStr1 staticityOfVar Weak < ["must be static string" currentNode compilerError] when]
    [
      varStr1: refToStr1 getVar;
      varStr1.data.getTag VarString = not ["must be static string" currentNode compilerError] when
    ]
    [(VarString varStr1.data.get VarString varStr2.data.get) assembleString makeVarString push]
  ) sequence
] "mplBuiltinStrCat" @declareBuiltin ucall

[
  refToName: pop;
  compilable [
    refToName staticityOfVar Weak < ["name must be static string" currentNode compilerError] when
    compilable [
      varName: refToName getVar;
      varName.data.getTag VarString = not ["name must be static string" currentNode compilerError] when
      compilable [
        string: VarString varName.data.get;
        struct: Struct;

        string.chars.dataSize 0 < not [
          splitted: string makeStringView.split;
          splitted.success [
            splitted.chars [
              element: toString makeVarString;
              field: Field;
              processor.emptyNameInfo @field.@nameInfo set
              element TRUE dynamic @currentNode createRef @field.@refToVar set
              field @struct.@fields.pushBack
            ] each

            result: @struct move owner VarStruct @currentNode createVariable;
            result isVirtual not [result @currentNode createAllocIR @result set] when
            resultStruct: VarStruct result getVar.data.get.get;

            i: 0 dynamic;
            [
              i resultStruct.fields.dataSize < [
                field: i resultStruct.fields.at;

                result isGlobal [
                  currentNode.program.dataSize field.refToVar getVar.@allocationInstructionIndex set
                  "no alloc..." @currentNode createComment # fake instruction

                  loadReg: field.refToVar @currentNode createDerefToRegister;
                  field.refToVar currentNode unglobalize
                  loadReg field.refToVar @currentNode createStoreFromRegister

                  field.refToVar i result @currentNode createGEPInsteadOfAlloc
                ] [
                  field.refToVar i result @currentNode createGEPInsteadOfAlloc
                ] if
                i 1 + @i set TRUE
              ] &&
            ] loop

            result push
          ] [
            "wrong encoding in ctring" currentNode compilerError
          ] if
        ] when
      ] when
    ] when
  ] when
] "mplBuiltinTextSplit" @declareBuiltin ucall

[
  (
    [compilable]
    [refToName: pop;]
    [refToStruct: pop;]
    [
      refToName staticityOfVar Weak < ["name must be static string" currentNode compilerError] when
    ]
    [
      varName: refToName getVar;
      varName.data.getTag VarString = not ["name must be static string" currentNode compilerError] when
    ]
    [
      refToStruct getVar.data.getTag VarStruct = [
        string: VarString varName.data.get;
        fr: string makeStringView findNameInfo refToStruct findField;
        compilable [
          fr.success VarCond @currentNode createVariable Static @currentNode makeStaticity @currentNode createPlainIR push
        ] when
      ] [
        FALSE VarCond @currentNode createVariable Static @currentNode makeStaticity @currentNode createPlainIR push
      ] if
    ]
  ) sequence
] "mplBuiltinHas" @declareBuiltin ucall

[
  (
    [compilable]
    [refToName: pop;]
    [refToStruct: pop;]
    [
      refToName staticityOfVar Weak < ["name must be static string" currentNode compilerError] when
    ]
    [
      varName: refToName getVar;
      varName.data.getTag VarString = not ["name must be static string" currentNode compilerError] when
    ]
    [
      refToStruct getVar.data.getTag VarStruct = not ["not a combined " currentNode compilerError] when
    ] [
      string: VarString varName.data.get;
      fr: string makeStringView findNameInfo refToStruct findField;
    ] [
      fr.success not [(refToStruct currentNode getMplType " has no field " string) assembleString currentNode compilerError] when
    ] [
      fr.index Int64 cast VarInt32 @currentNode createVariable Static @currentNode makeStaticity @currentNode createPlainIR push
    ]
  ) sequence
] "mplBuiltinFieldIndex" @declareBuiltin ucall

[
  (
    [compilable]
    [refToName: pop;]
    [
      refToName staticityOfVar Weak < ["name must be static string" currentNode compilerError] when
    ]
    [
      varName: refToName getVar;
      varName.data.getTag VarString = not ["name must be static string" currentNode compilerError] when
    ]
    [
      VarString varName.data.get findNameInfo pop @currentNode createNamedVariable
    ]
  ) sequence
] "mplBuiltinDef" @declareBuiltin ucall

[
  refToVar: pop;
  compilable [
    refToVar isVirtual [
      refToVar isSchema [
        pointee: VarRef refToVar getVar.data.get;
        pointee isVirtual [
          0nx
        ] [
          pointee currentNode getStorageSize
        ] if
      ] [
        0nx
      ] if
    ] [
      refToVar currentNode getStorageSize
    ] if

    0n64 cast VarNatX @currentNode createVariable Static @currentNode makeStaticity @currentNode createPlainIR push
  ] when
] "mplBuiltinStorageSize" @declareBuiltin ucall

[
  refToVar: pop;
  compilable [
    refToVar isVirtual [
      refToVar isSchema [
        pointee: VarRef refToVar getVar.data.get;
        pointee isVirtual [
          0nx
        ] [
          pointee currentNode getAlignment
        ] if
      ] [
        0nx
      ] if
    ] [
      refToVar currentNode getAlignment
    ] if

    0n64 cast VarNatX @currentNode createVariable Static @currentNode makeStaticity @currentNode createPlainIR push
  ] when
] "mplBuiltinAlignment" @declareBuiltin ucall

[
  refToName: pop;
  compilable [
    refToName staticityOfVar Weak < ["name must be static string" currentNode compilerError] when
    compilable [
      varName: refToName getVar;
      varName.data.getTag VarString = not ["name must be static string" currentNode compilerError] when
      compilable [
        VarString varName.data.get print LF print
      ] when
    ] when
  ] when
] "mplBuiltinPrintCompilerMessage" @declareBuiltin ucall

[
  compilable [
    ("var count=" processor.varCount LF) printList
  ] when
] "mplBuiltinPrintVariableCount" @declareBuiltin ucall

[
  currentNode defaultPrintStack
] "mplBuiltinPrintStack" @declareBuiltin ucall

[
  currentNode defaultPrintStackTrace
] "mplBuiltinPrintStackTrace" @declareBuiltin ucall

[
  refToVar1: pop;
  refToVar2: pop;
  compilable [
    refToVar1 refToVar2 variablesAreSame VarCond @currentNode createVariable Static @currentNode makeStaticity @currentNode createPlainIR push
  ] when
] "mplBuiltinSame" @declareBuiltin ucall

[
  refToVar1: pop;
  refToVar2: pop;
  compilable [
    refToVar1 refToVar2 variablesAreSame [
      cmpResult: 0 dynamic; # -1 false, 1 true, 0 need to check
      refToVar1 refToVar2 refsAreEqual [
        1 @cmpResult set
      ] [
        refToVar1 getVar.storageStaticity Dynamic > not
        refToVar2 getVar.storageStaticity Dynamic > not or [
          0 @cmpResult set
        ] [
          -1 @cmpResult set
        ] if
      ] if

      cmpResult 0 = [
        result: FALSE VarCond @currentNode createVariable Dynamic @currentNode makeStaticity @currentNode createAllocIR;
        refToVar1 refToVar2 result "icmp eq" @currentNode createDirectBinaryOperation
        result push
      ] [
        cmpResult 1 = VarCond @currentNode createVariable Static @currentNode makeStaticity @currentNode createPlainIR push
      ] if
    ] [
      ("different arguments, left: " refToVar1 currentNode getMplType ", right: " refToVar2 currentNode getMplType) assembleString currentNode compilerError
    ] if
  ] when
] "mplBuiltinIs" @declareBuiltin ucall

[
  refToVar: pop;
  compilable [
    refToVar.mutable not VarCond @currentNode createVariable Static @currentNode makeStaticity @currentNode createPlainIR push
  ] when
] "mplBuiltinIsConst" @declareBuiltin ucall

[
  refToVar: pop;
  compilable [
    refToVar getVar.data.getTag VarStruct = VarCond @currentNode createVariable Static @currentNode makeStaticity @currentNode createPlainIR push
  ] when
] "mplBuiltinIsCombined" @declareBuiltin ucall

[
  processor.options.debug VarCond @currentNode createVariable Static @currentNode makeStaticity @currentNode createPlainIR push
] "mplBuiltinDebug" @declareBuiltin ucall

[
  processor.options.logs VarCond @currentNode createVariable Static @currentNode makeStaticity @currentNode createPlainIR push
] "mplBuiltinHasLogs" @declareBuiltin ucall

[
  refToVar: pop;
  compilable [
    var: refToVar getVar;
    refToVar isSchema [
      pointee: VarRef var.data.get;
      pointeeVar: pointee getVar;
      pointeeVar.data.getTag VarStruct = not ["not a combined" currentNode compilerError] when
      compilable [
        VarStruct pointeeVar.data.get.get.fields.dataSize 0i64 cast VarInt32 @currentNode createVariable Static @currentNode makeStaticity @currentNode createPlainIR push
      ] when
    ] [
      var.data.getTag VarStruct = not ["not a combined" currentNode compilerError] when
      compilable [
        VarStruct var.data.get.get.fields.dataSize 0i64 cast VarInt32 @currentNode createVariable Static @currentNode makeStaticity @currentNode createPlainIR push
      ] when
    ] if
  ] when
] "mplBuiltinFieldCount" @declareBuiltin ucall

[
  refToCount: pop;
  refToVar: pop;
  compilable [
    varCount: refToCount getVar;
    varCount.data.getTag VarInt32 = not ["index must be Int32" currentNode compilerError] when
    compilable [
      refToCount staticityOfVar Dynamic > not ["index must be static" currentNode compilerError] when
      compilable [
        count: VarInt32 varCount.data.get 0 cast;
        var: refToVar getVar;
        refToVar isSchema [
          pointee: VarRef var.data.get;
          pointeeVar: pointee getVar;
          pointeeVar.data.getTag VarStruct = not ["not a combined" currentNode compilerError] when
          compilable [
            count VarStruct pointeeVar.data.get.get.fields.at.nameInfo processor.nameInfos.at.name makeVarString push
          ] when
        ] [
          var.data.getTag VarStruct = not ["not a combined" currentNode compilerError] when
          compilable [
            struct: VarStruct var.data.get.get;
            count 0 < [count struct.fields.getSize < not] || ["index is out of bounds" currentNode compilerError] when
            compilable [
              count struct.fields.at.nameInfo processor.nameInfos.at.name makeVarString push
            ] when
          ] when
        ] if
      ] when
    ] when
  ] when
] "mplBuiltinFieldName" @declareBuiltin ucall

[
  COMPILER_SOURCE_VERSION 0i64 cast VarInt32 @currentNode createVariable Static @currentNode makeStaticity @currentNode createPlainIR push
] "mplBuiltinCompilerVersion" @declareBuiltin ucall

[
  refToCount: pop;
  refToElement: pop;
  compilable [
    refToElement fullUntemporize
    varCount: refToCount getVar;
    varCount.data.getTag VarInt32 = not ["count must be Int32" currentNode compilerError] when
    compilable [
      refToCount staticityOfVar Dynamic > not ["count must be static" currentNode compilerError] when
      compilable [
        count: VarInt32 varCount.data.get 0 cast;
        count 0 < [
          "count must not be negative" currentNode compilerError
        ] when

        compilable [
          struct: Struct;
          staticity: refToElement staticityOfVar;
          staticity Weak = [Dynamic @staticity set] when

          i: 0 dynamic;
          [
            i count < [
              element: refToElement @currentNode copyVar staticity @currentNode makeStaticity;
              field: Field;
              processor.emptyNameInfo @field.@nameInfo set
              element @field.@refToVar set
              field @struct.@fields.pushBack
              i 1 + @i set TRUE
            ] &&
          ] loop

          result: @struct move owner VarStruct @currentNode createVariable;
          result isVirtual not [result @currentNode createAllocIR @result set] when
          resultStruct: VarStruct result getVar.data.get.get;


          i: 0 dynamic;
          [
            i resultStruct.fields.dataSize < [
              field: i resultStruct.fields.at;
              field.refToVar isVirtual [
                field.refToVar isAutoStruct ["unable to copy virtual autostruct" currentNode compilerError] when
              ] [
                field.refToVar currentNode unglobalize
                currentNode.program.dataSize field.refToVar getVar.@allocationInstructionIndex set
                "no alloc..." @currentNode createComment # fake instruction
                refToElement field.refToVar @currentNode createCheckedCopyToNew
                field.refToVar markAsUnableToDie
                field.refToVar i result @currentNode createGEPInsteadOfAlloc
              ] if
              i 1 + @i set compilable
            ] &&
          ] loop

          result @currentNode.@candidatesToDie.pushBack
          result push
        ] when
      ] when
    ] when
  ] when
] "mplBuiltinArray" @declareBuiltin ucall

[
  varPrev:   0n64 VarNatX @currentNode createVariable;
  varNext:   0n64 VarNatX @currentNode createVariable;
  varName:   String makeVarString TRUE dynamic createRefNoOp;
  varLine:   0i64 VarInt32 @currentNode createVariable;
  varColumn: 0i64 VarInt32 @currentNode createVariable;

  varPrev   makeVarDirty
  varNext   makeVarDirty
  varName   makeVarDirty
  varLine   makeVarDirty
  varColumn makeVarDirty

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

  first: @struct move owner VarStruct @currentNode createVariable;
  last: first @currentNode copyVar;

  firstRef: first FALSE dynamic createRefNoOp;
  lastRef:  last  FALSE dynamic createRefNoOp;

  firstRef makeVarDirty
  lastRef  makeVarDirty

  resultStruct: Struct;
  2 @resultStruct.@fields.resize

  firstRef             0 @resultStruct.@fields.at.@refToVar set
  "first" findNameInfo 0 @resultStruct.@fields.at.@nameInfo set

  lastRef             1 @resultStruct.@fields.at.@refToVar set
  "last" findNameInfo 1 @resultStruct.@fields.at.@nameInfo set

  result: @resultStruct move owner VarStruct @currentNode createVariable @currentNode createAllocIR;
  first getIrType result getIrType result @currentNode createGetCallTrace
  result push
] "mplBuiltinGetCallTrace" @declareBuiltin ucall

[
  refToVar: pop;
  compilable [
    refToVar.mutable [
      refToVar isVirtual [
        refToVar push
      ] [
        var: refToVar getVar;
        var.data.getTag VarStruct = [
          TRUE VarStruct @var.@data.get.get.@forgotten set
        ] when

        refToVar push
      ] if
    ] [
      "moved can be only mutable variables" currentNode compilerError
    ] if
  ] when
] "mplBuiltinMove" @declareBuiltin ucall

[
  refToCond: pop;
  compilable [
    condVar: refToCond getVar;
    condVar.data.getTag VarCond = not [refToCond staticityOfVar Dynamic > not] || ["not a static Cond" currentNode compilerError] when
    compilable [
      refToVar: pop;
      compilable [
        VarCond condVar.data.get [
          refToVar.mutable [
            refToVar isVirtual [
              refToVar push
            ] [
              var: refToVar getVar;
              var.data.getTag VarStruct = [
                TRUE VarStruct @var.@data.get.get.@forgotten set
              ] when

              refToVar push
            ] if
          ] [
            "moved can be only mutable variables" currentNode compilerError
          ] if
        ] [
          refToVar push
        ] if
      ] when
    ] when
  ] when
] "mplBuiltinMoveIf" @declareBuiltin ucall

[
  refToVar: pop;
  compilable [
    refToVar push
    refToVar isForgotten
    VarCond @currentNode createVariable Static @currentNode makeStaticity @currentNode createPlainIR push
  ] when
] "mplBuiltinIsMoved" @declareBuiltin ucall

[
  refToVar: pop;
  compilable [
    refToVar isAutoStruct [refToVar callInit] when
  ] when
] "mplBuiltinManuallyInitVariable" @declareBuiltin ucall

[
  refToVar: pop;
  compilable [
    refToVar isAutoStruct [refToVar callDie] when
  ] when
] "mplBuiltinManuallyDestroyVariable" @declareBuiltin ucall

[
  TRUE dynamic @currentNode.@nodeCompileOnce set
] "mplBuiltinCompileOnce" @declareBuiltin ucall

[
  TRUE dynamic @currentNode.@nodeIsRecursive set
] "mplBuiltinRecursive" @declareBuiltin ucall

[
  defaultFailProc
] "mplBuiltinFailProc" @declareBuiltin ucall
