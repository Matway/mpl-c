"builtinImpl" module
"control" includeModule

"codeNode" includeModule
"processSubNodes" includeModule
"defaultImpl" includeModule

declareBuiltin: [
  virtual declareBuiltinName:;
  virtual declareBuiltinBody:;

  {processorResult: ProcessorResult Ref; processor: Processor Ref; indexOfNode: Int32; currentNode: CodeNode Ref; multiParserResult: MultiParserResult Cref;} () {} [
    processorResult:;
    processor:;
    copy indexOfNode:;
    currentNode:;
    multiParserResult:;
    failProc: @failProcForProcessor;
    @declareBuiltinBody ucall
  ] declareBuiltinName exportFunction
];

staticnessOfBinResult: [
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
    var1.data.getTag firstTag < [var1.data.getTag lastTag < not] || ["first argument invalid" makeStringView compilerError] [
      var2.data.getTag firstTag < [var2.data.getTag lastTag < not] || ["second argument invalid" makeStringView compilerError] [
        arg1 arg2 variablesAreSame not [
          ("arguments have different schemas, left is " arg1 getMplType ", right is " arg2 getMplType) assembleString compilerError
        ] when
      ] if
    ] if

    compilable [
      var1: arg1 getVar;
      var2: arg2 getVar;

      arg1 staticnessOfVar Dynamic > arg2 staticnessOfVar Dynamic > and [
        var1.data.getTag firstTag lastTag [
          copy tag:;
          value1: tag var1.data.get copy;
          value2: tag var2.data.get copy;
          resultType: tag @getResultType call;
          value1 value2 @exValidator call
          compilable [
            value1 value2 @opFunc call resultType cutValue resultType createVariable
            arg1 staticnessOfVar arg2 staticnessOfVar staticnessOfBinResult makeStaticness
            createPlainIR push
          ] when
        ] staticCall
      ] [
        opName: arg1 arg2 @getOpName call;
        var1.data.getTag firstTag lastTag [
          copy tag:;
          value1: tag var1.data.get copy;
          value2: tag var2.data.get copy;
          resultType: tag @getResultType call;
          result: resultType zeroValue resultType createVariable
          Dynamic makeStaticness
          createAllocIR;
          opName createBinaryOperation
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
    y y - y = ["division by zero" compilerError] when
  ] mplNumberBinaryOp
] "mplBuiltinDiv" @declareBuiltin ucall

[
  VarNat8 VarIntX 1 + [a2:; a1:; a2 isNat ["urem" makeStringView] ["srem" makeStringView] if] [mod] [copy] [
    y:; x:;
    y y - y = ["division by zero" compilerError] when
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

    arg1 comparable not [ "first argument is not comparable" compilerError ] [
      arg2 comparable not [ "second argument is not comparable" compilerError ] [
        arg1 arg2 variablesAreSame not [
          ("arguments have different schemas, left is " arg1 getMplType ", right is " arg2 getMplType) assembleString compilerError
        ] when
      ] if
    ] if

    compilable [

      arg1 staticnessOfVar Dynamic > arg2 staticnessOfVar Dynamic > and [
        var1.data.getTag VarString = [
          value1: VarString var1.data.get copy;
          value2: VarString var2.data.get copy;
          value1 value2 = VarCond createVariable
          arg1 staticnessOfVar arg2 staticnessOfVar staticnessOfBinResult makeStaticness
          createPlainIR push
        ] [
          var1.data.getTag VarCond VarReal64 1 + [
            copy tag:;
            value1: tag var1.data.get copy;
            value2: tag var2.data.get copy;
            value1 value2 = VarCond createVariable
            arg1 staticnessOfVar arg2 staticnessOfVar staticnessOfBinResult makeStaticness
            createPlainIR push
          ] staticCall
        ] if
      ] [
        var1.data.getTag VarString = [
          result: FALSE VarCond createVariable Dynamic makeStaticness createAllocIR;
          "icmp eq" makeStringView createBinaryOperation
          result push
        ] [
          arg1 isReal [
            var1.data.getTag VarReal32 VarReal64 1 + [
              copy tag:;
              result: FALSE VarCond createVariable Dynamic makeStaticness createAllocIR;
              "fcmp oeq" makeStringView createBinaryOperation
              result push
            ] staticCall
          ] [
            var1.data.getTag VarCond VarIntX 1 + [
              copy tag:;
              result: FALSE VarCond createVariable Dynamic makeStaticness createAllocIR;
              "icmp eq" makeStringView createBinaryOperation
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
    var.data.getTag firstTag < [var.data.getTag lastTag < not] || ["argument invalid" compilerError] when

    compilable [
      arg staticnessOfVar Dynamic > [
        var.data.getTag firstTag lastTag [
          copy tag:;
          value: tag var.data.get copy;
          resultType: tag copy;
          value @exValidator call
          compilable [
            value @opFunc call resultType cutValue resultType createVariable
            arg staticnessOfVar makeStaticness
            createPlainIR push
          ] when
        ] staticCall
      ] [
        opName: arg @getOpName call;
        mopName: arg @getMidOpName call;
        var.data.getTag firstTag lastTag [
          copy tag:;
          value: tag var.data.get copy;
          resultType: tag copy;
          result: resultType zeroValue resultType createVariable
          Dynamic makeStaticness
          createAllocIR;
          opName mopName createUnaryOperation
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
  TRUE VarCond createVariable createPlainIR push
] "mplBuiltinTrue" @declareBuiltin ucall

[
  FALSE VarCond createVariable createPlainIR push
] "mplBuiltinFalse" @declareBuiltin ucall

[
  s: LF toString;
  s VarString createVariable createStringIR push
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
    arg isReal not ["argument invalid" makeStringView compilerError] when

    compilable [
      arg staticnessOfVar Dynamic > [
        var.data.getTag VarReal32 VarReal64 1 + [
          copy tag:;
          value: tag var.data.get copy;
          resultType: tag copy;
          value @exValidator call
          compilable [
            value @opFunc call resultType cutValue resultType createVariable
            arg staticnessOfVar makeStaticness
            createPlainIR push
          ] when
        ] staticCall
      ] [
        opName: arg @getOpName call;
        var.data.getTag VarReal32 VarReal64 1 + [
          copy tag:;
          value: tag var.data.get copy;
          resultType: tag copy;
          result: resultType zeroValue resultType createVariable
          Dynamic makeStaticness
          createAllocIR;

          args: IRArgument Array;

          irarg: IRArgument;
          arg createDerefToRegister @irarg.@irNameId set
          var.irTypeId @irarg.@irTypeId set
          FALSE @irarg.@byRef set
          irarg @args.pushBack

          result args String @opName createCallIR retName:;

          retName result createStoreFromRegister

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
    arg1 isReal not ["first argument invalid" makeStringView compilerError] [
      arg2 isReal not ["second argument invalid" makeStringView compilerError] [
        arg1 arg2 variablesAreSame not [
          ("arguments have different schemas, left is " arg1 getMplType ", right is " arg2 getMplType) assembleString compilerError
        ] when
      ] if
    ] if

    compilable [
      var1: arg1 getVar;
      var2: arg2 getVar;

      arg1 staticnessOfVar Dynamic > arg2 staticnessOfVar Dynamic > and [
        var1.data.getTag VarReal32 VarReal64 1 + [
          copy tag:;
          value1: tag var1.data.get copy;
          value2: tag var2.data.get copy;
          resultType: tag copy;

          compilable [
            value1 value2 ^ resultType cutValue resultType createVariable
            arg1 staticnessOfVar arg2 staticnessOfVar staticnessOfBinResult makeStaticness
            createPlainIR push
          ] when
        ] staticCall
      ] [
        var1.data.getTag VarReal32 VarReal64 1 + [
          copy tag:;
          resultType: tag copy;
          result: resultType zeroValue resultType createVariable
          Dynamic makeStaticness
          createAllocIR;

          args: IRArgument Array;

          irarg: IRArgument;
          FALSE @irarg.@byRef set
          arg1 createDerefToRegister @irarg.@irNameId set
          var1.irTypeId @irarg.@irTypeId set
          irarg @args.pushBack
          arg2 createDerefToRegister @irarg.@irNameId set
          var2.irTypeId @irarg.@irTypeId set
          irarg @args.pushBack

          result args String tag VarReal32 = ["@llvm.pow.f32" makeStringView] ["@llvm.pow.f64" makeStringView] if createCallIR retName:;

          @retName result createStoreFromRegister

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
    arg1 isAnyInt not ["first argument invalid" makeStringView compilerError] [
      arg2 isNat not ["second argument invalid" makeStringView compilerError] when
    ] if

    compilable [
      var1: arg1 getVar;
      var2: arg2 getVar;

      arg1 staticnessOfVar Dynamic > arg2 staticnessOfVar Dynamic > and [
        var1.data.getTag VarNat8 VarIntX 1 + [
          copy tag1:;
          var2.data.getTag VarNat8 VarNatX 1 + [
            copy tag2:;
            value1: tag1 var1.data.get copy;
            value2: tag2 var2.data.get copy;
            resultType: tag1 copy;
            value2 63n64 > ["shift value must be less than 64" makeStringView compilerError] when

            compilable [
              value1 value2 @opFunc call resultType cutValue resultType createVariable
              arg1 staticnessOfVar arg2 staticnessOfVar staticnessOfBinResult makeStaticness
              createPlainIR push
            ] when
          ] staticCall
        ] staticCall
      ] [
        opName: arg1 arg2 @getOpName call;
        var1.data.getTag VarNat8 VarIntX 1 + [
          copy tag:;
          resultType: tag copy;
          result: resultType zeroValue resultType createVariable
          Dynamic makeStaticness
          createAllocIR;
          arg1 getStorageSize arg2 getStorageSize = [
            opName createBinaryOperation
          ] [
            opName createBinaryOperationDiffTypes
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

[TRUE defaultRef] "mplBuiltinRef" @declareBuiltin ucall
[FALSE defaultRef] "mplBuiltinCref" @declareBuiltin ucall
[TRUE defaultMakeConstWith] "mplBuiltinConst" @declareBuiltin ucall

[
  refToVar: pop;
  compilable [
    refToVar getVar.data.getTag VarRef = [
      refToVar isVirtualRef [
        "can not deref virtual-reference" makeStringView compilerError
      ] [
        refToVar getPointee push
      ] if
    ] [
      "not a reference" makeStringView compilerError
    ] if
  ] when
] "mplBuiltinDeref" @declareBuiltin ucall

[
  defaultCall
] "mplBuiltinCall" @declareBuiltin ucall

[
  code: pop;

  compilable [
    varCode: code getVar;

    varCode.data.getTag VarCode = not ["branch else must be a [CODE]" makeStringView compilerError] when

    compilable [
      codeIndex: VarCode varCode.data.get copy;
      astNode: codeIndex @multiParserResult.@memory.at;
      [astNode.data.getTag AstNodeType.Code =] "Not a code!" assert
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
    refToVar makeVarTreeDirty
    refToVar push
  ] when
] "mplBuiltinDirty" @declareBuiltin ucall

[
  refToVar: pop;
  compilable [
    refToVar staticnessOfVar Weak = [refToVar Static makeStaticness @refToVar set] when
    refToVar push
  ] when
] "mplBuiltinStatic" @declareBuiltin ucall

[defaultSet] "mplBuiltinSet" @declareBuiltin ucall

mplBuiltinProcessAtList: [
  refToStruct: pop;
  refToIndex: pop;
  compileOnce

  result: RefToVar;

  compilable [
    structVar: refToStruct getVar;
    indexVar: refToIndex getVar;

    refToStruct isVirtualRef [

      (
        [compilable]
        [
          pointee: VarRef structVar.data.get;
          pointeeVar: pointee getVar;
          pointeeVar.data.getTag VarStruct = not ["not a combined" compilerError] when
        ]
        [ indexVar.data.getTag VarInt32 = not ["index must be Int32" compilerError] when ]
        [refToIndex staticnessOfVar Weak < [ "index must be static" compilerError] when ]
        [
          index: VarInt32 indexVar.data.get 0 cast;
          struct: VarStruct pointeeVar.data.get.get;
          index 0 < [index struct.fields.getSize < not] || ["index is out of bounds" compilerError] when
        ] [
          field: index struct.fields.at.refToVar;
          field VarRef TRUE dynamic TRUE dynamic createVariableWithVirtual @result set
          refToStruct.mutable @result.@mutable set
          result fullUntemporize
        ]
      ) sequence
    ] [
      (
        [compilable]
        [structVar.data.getTag VarStruct = not [ "not a combined" compilerError] when]
        [indexVar.data.getTag VarInt32 = not ["index must be Int32" compilerError] when]
        [
          struct: VarStruct structVar.data.get.get;
          refToIndex staticnessOfVar Weak < [
            struct.homogeneous [
              struct.fields.dataSize 0 > [
                # create dynamic getIndex
                realRefToStruct: refToStruct;
                realStructVar: structVar;
                realStruct: struct;
                refToStruct staticnessOfVar Virtual = [
                  "can't get dynamic index in virtual struct" compilerError
                ] when

                fieldRef: 0 realStruct.fields.at.refToVar copy;
                fieldRef.hostId indexOfNode = not [
                  fBegin: RefToVar;
                  fEnd: RefToVar;
                  fieldRef @fBegin @fEnd ShadowReasonField makeShadowsDynamic
                  fEnd @fieldRef set
                ] when

                fieldRef copyVar @fieldRef set
                refToStruct.mutable @fieldRef.@mutable set
                fieldRef fullUntemporize
                fieldRef staticnessOfVar Virtual = [
                  "dynamic index is combined of virtuals" compilerError
                ] [
                  fieldRef makeVarTreeDynamicStoraged
                  fieldRef unglobalize
                  fieldRef refToIndex realRefToStruct createDynamicGEP
                  fieldVar: fieldRef getVar;
                  currentNode.program.dataSize 1 - @fieldVar.@getInstructionIndex set
                  fieldRef @result set
                ] if

                refToStruct.mutable [
                  refToStruct makeVarTreeDirty
                ] when
              ] [
                "struct is empty" compilerError
              ] if
            ] [
              "dynamic index in non-homogeneous combined" compilerError
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

    varElse.data.getTag VarCode = not ["branch else must be a [CODE]" compilerError] when
    varThen.data.getTag VarCode = not ["branch then must be a [CODE]" compilerError] when
    varCond.data.getTag VarCond = not [("condition has a wrong type " condition getMplType) assembleString compilerError] when

    compilable [
      condition staticnessOfVar Weak > [
        value: VarCond varCond.data.get copy;
        value [
          VarCode varThen.data.get "staticIfThen" makeStringView processCall
        ] [
          VarCode varElse.data.get "staticIfElse" makeStringView processCall
        ] if
      ] [
        condition
        VarCode varThen.data.get @multiParserResult.@memory.at
        VarCode varElse.data.get @multiParserResult.@memory.at
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

    varElse.data.getTag VarCode = not ["branch else must be a [CODE]" makeStringView compilerError] when
    varThen.data.getTag VarCode = not ["branch then must be a [CODE]" makeStringView compilerError] when
    varCond.data.getTag VarCond = not ["condition has a wrong type" makeStringView compilerError] when

    compilable [
      condition staticnessOfVar Weak > [
        value: VarCond varCond.data.get copy;
        codeIndex: value [VarCode varThen.data.get copy] [VarCode varElse.data.get copy] if;
        astNode: codeIndex @multiParserResult.@memory.at;
        [astNode.data.getTag AstNodeType.Code =] "Not a code!" assert
        indexArray: AstNodeType.Code astNode.data.get;
        indexArray addIndexArrayToProcess
      ] [
        "condition must be static" makeStringView compilerError
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
      varBody.data.getTag VarCode = not ["body must be [CODE]" compilerError] when
    ] [
      astNode: VarCode varBody.data.get @multiParserResult.@memory.at;
      astNode processLoop
    ]
  ) sequence
] "mplBuiltinLoop" @declareBuiltin ucall

parseFieldToSignatureCaptureArray: [
  refToStruct:;
  result: RefToVar Array;
  varStruct: refToStruct getVar;
  varStruct.data.getTag VarStruct = not ["argument list must be a struct" compilerError] when

  compilable [
    VarStruct varStruct.data.get.get.fields [
      refToVar: .value.refToVar;
      refToVar isVirtual ["input cannot be virtual" compilerError] when
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
      optionsVar.data.getTag VarStruct = not ["options must be a struct" compilerError] when
    ] [
      optionsStruct: VarStruct optionsVar.data.get.get;
      hasConvention: FALSE dynamic;
      optionsStruct.fields [
        f: .value;
        f.nameInfo (
          processor.variadicNameInfo [
            variadicRefToVar: f.refToVar;
            variadicVar: variadicRefToVar getVar;
            (
              [compilable]
              [variadicVar.data.getTag VarCond = not ["value must be Cond" compilerError] when]
              [variadicRefToVar staticnessOfVar Weak < ["value must be Static" compilerError] when]
              [VarCond variadicVar.data.get @result.@variadic set]
            ) sequence
          ]
          processor.conventionNameInfo [
            conventionRefToVar: f.refToVar;
            conventionVar: conventionRefToVar getVar;
            (
              [compilable]
              [conventionVar.data.getTag VarString = not ["value must be String" compilerError] when]
              [conventionRefToVar staticnessOfVar Weak < ["value must be Static" compilerError] when]
              [
                string: VarString conventionVar.data.get;
                string @result.@convention set
                TRUE @hasConvention set
              ]
            ) sequence
          ] [
            ("unknown option: " f.nameInfo processor.nameInfos.at.name) assembleString compilerError
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
          returnVar.data.getTag VarStruct = not [(return getMplType " can not be a return type") assembleString compilerError] when
        ] [
          #todo: detect temporality
          returnVar: return getVar;
          returnVar.temporary [
            return @result.@outputs.pushBack
          ] [
            return return.mutable createRef @result.@outputs.pushBack
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
    [currentNode.parent 0 = not ["export must be global" compilerError] when]
    [refToName: pop;]
    [refToName staticnessOfVar Weak < ["function name must be static string" compilerError] when]
    [
      varName: refToName getVar;
      varName.data.getTag VarString = not ["name must be static string" compilerError] when
    ]
    [refToBody: pop;]
    [
      varBody: refToBody getVar;
      varBody.data.getTag VarCode = not ["must be a code" compilerError] when
    ]
    [signature: parseSignature;]
    [
      astNode: VarCode varBody.data.get @multiParserResult.@memory.at;
      index: signature astNode VarString varName.data.get makeStringView FALSE dynamic processExportFunction;
    ]
  ) sequence
] "mplBuiltinExportFunction" @declareBuiltin ucall

[
  (
    [compilable]
    [currentNode.parent 0 = not ["export must be global" compilerError] when]
    [refToName: pop;]
    [refToVar: pop;]
    [refToName staticnessOfVar Weak < ["function name must be static string" compilerError] when]
    [
      varName: refToName getVar;
      varName.data.getTag VarString = not ["name must be static string" compilerError] when
    ] [
      refToVar isVirtual ["cannot export virtual var" compilerError] when
    ] [
      refToVar getVar.temporary not [
        refToVar refToVar.mutable createRef @refToVar set
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
      oldIrNameId var.irNameId var.irTypeId createGlobalAliasIR
      oldInstructionIndex @var.@globalDeclarationInstructionIndex set

      nameInfo: name findNameInfo;
      nameInfo refToVar addOverloadForPre
      nameInfo refToVar NameCaseLocal addNameInfo
      processor.options.debug [
        d: nameInfo refToVar addGlobalVariableDebugInfo;
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
    [currentNode.parent 0 = not ["import must be global" compilerError] when]
    [refToName: pop;]
    [refToName staticnessOfVar Weak < ["function name must be static string" compilerError] when]
    [
      varName: refToName getVar;
      varName.data.getTag VarString = not ["name must be static string" compilerError] when
    ]
    [signature: parseSignature;]
    [index: signature VarString varName.data.get makeStringView FALSE dynamic processImportFunction;]
  ) sequence
] "mplBuiltinImportFunction" @declareBuiltin ucall

[
  (
    [compilable]
    [signature: parseSignature;]
    [
      name: ("null." processor.nodes.getSize) assembleString;
      index: signature name makeStringView TRUE dynamic processImportFunction;
    ]
    [
      #refToVar: index processor.nodes.at.get.refToVar;
      nullNode: index processor.nodes.at.get;
      gnr: nullNode.varNameInfo getName;
      cnr: gnr captureName;
      refToVar: cnr.refToVar copy;
      #("coderef captured var=" refToVar.hostId ":" refToVar.varId " s=" refToVar staticnessOfVar) addLog

      refToVar push
    ]
  ) sequence
] "mplBuiltinCodeRef" @declareBuiltin ucall

[
  currentNode.parent 0 = not ["import must be global" compilerError] when
  compilable [
    refToName: pop;
    refToType: pop;
    compilable [
      refToName staticnessOfVar Weak < ["variable name must be static string" compilerError] when
      compilable [
        varName: refToName getVar;
        varName.data.getTag VarString = not ["variable name must be static string" compilerError] when
        compilable [
          varType: refToType getVar;
          refToType isVirtual [
            "variable cant be virtual" compilerError
          ] [
            varType.temporary not [
              refToType refToType.mutable createRef @refToType set
            ] when

            name: VarString varName.data.get;
            newRefToVar: refToType copyVar;
            newVar: newRefToVar getVar;
            TRUE @newRefToVar.@mutable set
            FALSE @newVar.@temporary set
            ("@" name) assembleString makeStringId @newVar.@irNameId set
            newRefToVar createVarImportIR makeVarTreeDynamic

            nameInfo: name findNameInfo;
            nameInfo newRefToVar addOverloadForPre
            nameInfo newRefToVar NameCaseLocal addNameInfo
            processor.options.debug [newRefToVar isVirtual not] && [
              d: nameInfo newRefToVar addGlobalVariableDebugInfo;
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
    refToVar getVar.temporary [
      "temporary objects cannot be copied" compilerError
    ] [
      refToVar getVar.data.getTag VarImport = [
        "functions cannot be copied" compilerError
      ] [
        result: refToVar copyVarToNew;
        result isVirtual [
          result isAutoStruct ["unable to copy virtual autostruct" compilerError] when
        ] [
          TRUE @result.@mutable set
          refToVar result createCopyToNew
        ] if

        result push
      ] if
    ] if
  ] when
] "mplBuiltinCopy" @declareBuiltin ucall

[
  refToVar: pop;
  compilable [
    result: refToVar copyVarToNew;
    result isVirtual not [
      TRUE @result.@mutable set
      result createAllocIR callInit
    ] when

    result push
  ] when
] "mplBuiltinNewVarOfTheSameType" @declareBuiltin ucall

[
  refToSchema: pop;
  refToVar: pop;

  compilable [
    refToVar isNumber refToSchema isNumber and [
      compilable [
        refToVar staticnessOfVar Dynamic > [
          varSrc: refToVar getVar;
          varSchema: refToSchema getVar;
          refToDst: RefToVar;

          varSrc.data.getTag VarNat8 VarReal64 1 + [
            copy tagSrc:;
            branchSrc: tagSrc varSrc.data.get;
            varSchema.data.getTag VarNat8 VarReal64 1 + [
              copy tagDst:;
              branchSchema: tagDst @varSchema.@data.get;
              branchSrc branchSchema cast tagDst cutValue tagDst createVariable createPlainIR @refToDst set
            ] staticCall
          ] staticCall

          refToVar staticnessOfVar refToDst getVar.@staticness set
          refToDst push
        ] [
          refToDst: RefToVar;
          varSchema: refToSchema getVar;
          varSchema.data.getTag VarNat8 VarReal64 1 + [
            copy tagDst:;
            branchSchema: tagDst @varSchema.@data.get;
            branchSchema tagDst createVariable @refToDst set
          ] staticCall

          Dynamic refToDst getVar.@staticness set

          # a lot of cases for different casts
          refToVar isReal refToSchema isReal or [
            refToVar isReal refToSchema isReal and [
              #Real to Real
              refToVar getStorageSize refToSchema getStorageSize = [
                refToVar refToDst createCopyToNew
              ] [
                refToVar getStorageSize refToSchema getStorageSize < [
                  refToVar refToDst "fpext" makeStringView createCastCopyToNew
                ] [
                  refToVar refToDst "fptrunc" makeStringView createCastCopyToNew
                ] if
              ] if
            ] [
              refToVar isAnyInt [
                #Int to Real
                refToVar isNat [
                  refToVar refToDst "uitofp" makeStringView createCastCopyToNew
                ] [
                  refToVar refToDst "sitofp" makeStringView createCastCopyToNew
                ] if
              ] [
                #Real to Int
                [refToSchema isAnyInt] "Wrong cast number case!" assert
                refToSchema isNat [
                  refToVar refToDst "fptoui" makeStringView createCastCopyToNew
                ] [
                  refToVar refToDst "fptosi" makeStringView createCastCopyToNew
                ] if
              ] if
            ] if
          ] [
            #Int to Int
            refToVar getStorageSize refToSchema getStorageSize = [
              refToVar refToDst createCopyToNew
            ] [
              refToVar getStorageSize refToSchema getStorageSize < [
                refToVar isNat [
                  refToVar refToDst "zext" makeStringView createCastCopyToNew
                ] [
                  refToVar refToDst "sext" makeStringView createCastCopyToNew
                ] if
              ] [
                refToVar refToDst "trunc" makeStringView createCastCopyToNew
              ] if
            ] if
          ] if
          # here ends cast case list

          refToDst push
        ] if
      ] when
    ] [
      "can cast only numbers" compilerError
    ] if
  ] when
] "mplBuiltinCast" @declareBuiltin ucall

[
  (
    [compilable]
    [refToVar: pop;]
    [refToVar isVirtual ["variable is virtual, cannot get address" compilerError] when]
    [
      TRUE refToVar getVar.@capturedAsMutable set #we need ref
      refToVar makeVarTreeDirty
      refToDst: 0n64 VarNatX createVariable;
      Dynamic @refToDst getVar.@staticness set
      var: refToVar getVar;
      var.data.getTag VarString = [
        refToVar refToDst "ptrtoint" makeStringView createCastCopyToNew
      ] [
        refToVar refToDst "ptrtoint" makeStringView createCastCopyPtrToNew
      ] if
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
      varSchema.data.getTag VarString = [
        refToDst: String VarString createVariable;
        Dynamic @refToDst getVar.@staticness set

        refToVar refToDst "inttoptr" makeStringView createCastCopyToNew
        refToDst push
      ] [
        varSchema.data.getTag VarImport = [
          refToDst: refToSchema VarRef createVariable;
          Dynamic @refToDst getVar.@staticness set
          refToVar refToDst "inttoptr" makeStringView createCastCopyToNew
          refToDst derefAndPush
        ] [
          schemaOfResult: RefToVar;
          varSchema.data.getTag VarRef = [
            refToSchema isVirtual [
              VarRef varSchema.data.get copyVarFromChild @schemaOfResult set
              refToSchema.mutable schemaOfResult.mutable and @schemaOfResult.@mutable set
            ] [
              [FALSE] "Unable in current semantic!" assert
            ] if
          ] [
            refToSchema @schemaOfResult set
          ] if

          schemaOfResult isVirtual [
            "pointee is virtual, cannot cast" compilerError
          ] [
            refToDst: schemaOfResult VarRef createVariable;
            Dynamic refToDst getVar.@staticness set
            refToVar refToDst "inttoptr" makeStringView createCastCopyToNew
            refToDst derefAndPush
          ] if
        ] if
      ] if
    ] [
      "address must be a NatX" compilerError
    ] if
  ] when
] "mplBuiltinAddressToReference" @declareBuiltin ucall

[
  currentNode.nextLabelIsConst ["duplicate virtual specifier" compilerError] when
  TRUE @currentNode.@nextLabelIsConst set
] "mplBuiltinConstVar" @declareBuiltin ucall

[
  currentNode.nextLabelIsVirtual ["duplicate virtual specifier" compilerError] when
  TRUE @currentNode.@nextLabelIsVirtual set
] "mplBuiltinVirtual" @declareBuiltin ucall

[
  currentNode.nextLabelIsSchema ["duplicate schema specifier" compilerError] when
  TRUE @currentNode.@nextLabelIsSchema set
] "mplBuiltinSchema" @declareBuiltin ucall

[
  currentNode.parent 0 = not [
    "module can be declared only in top node" makeStringView compilerError
  ] [
    refToName: pop;
    compilable [
      refToName staticnessOfVar Weak < ["name must be static string" compilerError] when
      compilable [
        varName: refToName getVar;
        varName.data.getTag VarString = not ["name must be static string" compilerError] when
        compilable [
          string: VarString varName.data.get;
          ("declare module " string) addLog
          fr: string makeStringView @processor.@modules.find;
          fr.success [fr.value 0 < not] && [
            ("duplicate declaration of module: " string) assembleString compilerError
          ] [
            fr.success [
              indexOfNode @fr.@value set
            ] [
              string indexOfNode @processor.@modules.insert
            ] if

            currentNode.moduleName.getTextSize 0 = [
              string @currentNode.@moduleName set
            ] [
              "duplicate named module" compilerError
            ] if
          ] if
        ] when
      ] when
    ] when
  ] if
] "mplBuiltinModule" @declareBuiltin ucall

[TRUE dynamic defaultUseOrIncludeModule] "mplBuiltinUseModule" @declareBuiltin ucall
[FALSE dynamic defaultUseOrIncludeModule] "mplBuiltinIncludeModule" @declareBuiltin ucall

[
  refToName: pop;
  compilable [
    refToName staticnessOfVar Weak < [
      #"name must be static" compilerError
      result: 0n64 VarNatX createVariable Dynamic makeStaticness createAllocIR;
      refToName result createGetTextSizeIR
      result push
    ] [
      varName: refToName getVar;
      varName.data.getTag VarString = not ["name must be string" compilerError] when
      compilable [
        string: VarString varName.data.get;
        string.getTextSize 0i64 cast 0n64 cast VarNatX createVariable Static makeStaticness createPlainIR push
      ] when
    ] if
  ] when
] "mplBuiltinTextSize" @declareBuiltin ucall

[
  (
    [compilable]
    [refToStr2: pop;]
    [refToStr2 staticnessOfVar Weak < ["must be static string" compilerError] when]
    [
      varStr2: refToStr2 getVar;
      varStr2.data.getTag VarString = not ["must be static string" compilerError] when
    ]
    [refToStr1: pop;]
    [refToStr1 staticnessOfVar Weak < ["must be static string" compilerError] when]
    [
      varStr1: refToStr1 getVar;
      varStr1.data.getTag VarString = not ["must be static string" compilerError] when
    ]
    [(VarString varStr1.data.get VarString varStr2.data.get) assembleString VarString createVariable createStringIR push]
  ) sequence
] "mplBuiltinStrCat" @declareBuiltin ucall

[
  refToName: pop;
  compilable [
    refToName staticnessOfVar Weak < ["name must be static string" makeStringView compilerError] when
    compilable [
      varName: refToName getVar;
      varName.data.getTag VarString = not ["name must be static string" makeStringView compilerError] when
      compilable [
        string: VarString varName.data.get;
        struct: Struct;

        fields: RefToVar Array;

        string.chars.dataSize 0 > [

          splitted: string makeStringView.split;
          splitted.success [
            splitted.chars [
              pair:;
              element: pair.value toString VarString createVariable;
              element @fields.pushBack
              field: Field;
              processor.emptyNameInfo @field.@nameInfo set
              element @field.@refToVar set
              field @struct.@fields.pushBack
            ] each

            result: @struct move owner VarStruct createVariable;
            result isVirtual not [result createAllocIR @result set] when
            resultStruct: VarStruct result getVar.data.get.get;

            i: 0 dynamic;
            [
              i resultStruct.fields.dataSize < [
                field: i resultStruct.fields.at;

                refToName isGlobal [
                  currentNode.program.dataSize field.refToVar getVar.@allocationInstructionIndex set
                  "no alloc..." makeStringView createComent # fake instruction

                  loadReg: field.refToVar createStringIR createDerefToRegister;
                  field.refToVar unglobalize
                  loadReg field.refToVar createStoreFromRegister

                  field.refToVar i result createGEPInsteadOfAlloc
                ] [
                  field.refToVar createStringIR i result createGEPInsteadOfAlloc
                ] if
                i 1 + @i set TRUE
              ] &&
            ] loop

            result push
          ] [
            "wrong encoding in ctring" compilerError
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
      refToName staticnessOfVar Weak < ["name must be static string" compilerError] when
    ]
    [
      varName: refToName getVar;
      varName.data.getTag VarString = not ["name must be static string" compilerError] when
    ]
    [
      refToStruct getVar.data.getTag VarStruct = [
        string: VarString varName.data.get;
        fr: string makeStringView findNameInfo refToStruct findField;
        compilable [
          fr.success VarCond createVariable Static makeStaticness createPlainIR push
        ] when
      ] [
        FALSE VarCond createVariable Static makeStaticness createPlainIR push
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
      refToName staticnessOfVar Weak < ["name must be static string" compilerError] when
    ]
    [
      varName: refToName getVar;
      varName.data.getTag VarString = not ["name must be static string" compilerError] when
    ]
    [
      refToStruct getVar.data.getTag VarStruct = not ["not a combined " compilerError] when
    ] [
      string: VarString varName.data.get;
      fr: string makeStringView findNameInfo refToStruct findField;
    ] [
      fr.success not [(refToStruct getMplType " has no field " string) assembleString compilerError] when
    ] [
      fr.index Int64 cast VarInt32 createVariable Static makeStaticness createPlainIR push
    ]
  ) sequence
] "mplBuiltinFieldIndex" @declareBuiltin ucall

[
  (
    [compilable]
    [refToName: pop;]
    [
      refToName staticnessOfVar Weak < ["name must be static string" compilerError] when
    ]
    [
      varName: refToName getVar;
      varName.data.getTag VarString = not ["name must be static string" compilerError] when
    ]
    [
      VarString varName.data.get findNameInfo pop createNamedVariable
    ]
  ) sequence
] "mplBuiltinDef" @declareBuiltin ucall

[
  refToVar: pop;
  compilable [
    refToVar isVirtual [
      refToVar isVirtualRef [
        pointee: VarRef refToVar getVar.data.get;
        pointee isVirtual [
          0nx
        ] [
          pointee getStorageSize
        ] if
      ] [
        0nx
      ] if
    ] [
      refToVar getStorageSize
    ] if

    0n64 cast VarNatX createVariable Static makeStaticness createPlainIR push
  ] when
] "mplBuiltinStorageSize" @declareBuiltin ucall

[
  refToVar: pop;
  compilable [
    refToVar isVirtual [
      refToVar isVirtualRef [
        pointee: VarRef refToVar getVar.data.get;
        pointee isVirtual [
          0nx
        ] [
          pointee getAlignment
        ] if
      ] [
        0nx
      ] if
    ] [
      refToVar getAlignment
    ] if

    0n64 cast VarNatX createVariable Static makeStaticness createPlainIR push
  ] when
] "mplBuiltinAlignment" @declareBuiltin ucall

[
  refToName: pop;
  compilable [
    refToName staticnessOfVar Weak < ["name must be static string" makeStringView compilerError] when
    compilable [
      varName: refToName getVar;
      varName.data.getTag VarString = not ["name must be static string" makeStringView compilerError] when
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
  defaultPrintStack
] "mplBuiltinPrintStack" @declareBuiltin ucall

[
  defaultPrintStackTrace
] "mplBuiltinPrintStackTrace" @declareBuiltin ucall

[
  refToVar1: pop;
  refToVar2: pop;
  compilable [
    refToVar1 refToVar2 variablesAreSame VarCond createVariable Static makeStaticness createPlainIR push
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
        refToVar1 getVar.storageStaticness Dynamic > not
        refToVar2 getVar.storageStaticness Dynamic > not or [
          0 @cmpResult set
        ] [
          -1 @cmpResult set
        ] if
      ] if

      cmpResult 0 = [
        result: FALSE VarCond createVariable Dynamic makeStaticness createAllocIR;
        refToVar1 refToVar2 result "icmp eq" makeStringView createDirectBinaryOperation
        result push
      ] [
        cmpResult 1 = VarCond createVariable Static makeStaticness createPlainIR push
      ] if
    ] [
      FALSE VarCond createVariable Static makeStaticness createPlainIR push
    ] if
  ] when
] "mplBuiltinIs" @declareBuiltin ucall

[
  refToVar: pop;
  compilable [
    refToVar.mutable not VarCond createVariable Static makeStaticness createPlainIR push
  ] when
] "mplBuiltinIsConst" @declareBuiltin ucall

[
  refToVar: pop;
  compilable [
    refToVar getVar.data.getTag VarStruct = VarCond createVariable Static makeStaticness createPlainIR push
  ] when
] "mplBuiltinIsCombined" @declareBuiltin ucall

[
  processor.options.debug VarCond createVariable Static makeStaticness createPlainIR push
] "mplBuiltinDebug" @declareBuiltin ucall

[
  processor.options.logs VarCond createVariable Static makeStaticness createPlainIR push
] "mplBuiltinHasLogs" @declareBuiltin ucall

[
  refToVar: pop;
  compilable [
    var: refToVar getVar;
    refToVar isVirtualRef [
      pointee: VarRef var.data.get;
      pointeeVar: pointee getVar;
      pointeeVar.data.getTag VarStruct = not ["not a combined" makeStringView compilerError] when
      compilable [
        VarStruct pointeeVar.data.get.get.fields.dataSize 0i64 cast VarInt32 createVariable Static makeStaticness createPlainIR push
      ] when
    ] [
      var.data.getTag VarStruct = not ["not a combined" makeStringView compilerError] when
      compilable [
        VarStruct var.data.get.get.fields.dataSize 0i64 cast VarInt32 createVariable Static makeStaticness createPlainIR push
      ] when
    ] if
  ] when
] "mplBuiltinFieldCount" @declareBuiltin ucall

[
  refToCount: pop;
  refToVar: pop;
  compilable [
    varCount: refToCount getVar;
    varCount.data.getTag VarInt32 = not ["count must be Int32" compilerError] when
    compilable [
      refToCount staticnessOfVar Dynamic > not ["count must be static" compilerError] when
      compilable [
        count: VarInt32 varCount.data.get 0 cast;
        var: refToVar getVar;
        refToVar isVirtualRef [
          pointee: VarRef var.data.get;
          pointeeVar: pointee getVar;
          pointeeVar.data.getTag VarStruct = not ["not a combined" compilerError] when
          compilable [
            count VarStruct pointeeVar.data.get.get.fields.at.nameInfo processor.nameInfos.at.name VarString createVariable createStringIR push
          ] when
        ] [
          var.data.getTag VarStruct = not ["not a combined" compilerError] when
          compilable [
            struct: VarStruct var.data.get.get;
            count 0 < [count struct.fields.getSize < not] || ["index is out of bounds" compilerError] when
            compilable [
              count struct.fields.at.nameInfo processor.nameInfos.at.name VarString createVariable createStringIR push
            ] when
          ] when
        ] if
      ] when
    ] when
  ] when
] "mplBuiltinFieldName" @declareBuiltin ucall

[
  COMPILER_SOURCE_VERSION 0i64 cast VarInt32 createVariable Static makeStaticness createPlainIR push
] "mplBuiltinCompilerVersion" @declareBuiltin ucall

[
  refToCount: pop;
  refToElement: pop;
  compilable [
    refToElement fullUntemporize
    varCount: refToCount getVar;
    varCount.data.getTag VarInt32 = not ["count must be Int32" makeStringView compilerError] when
    compilable [
      refToCount staticnessOfVar Dynamic > not ["count must be static" makeStringView compilerError] when
      compilable [
        count: VarInt32 varCount.data.get 0 cast;
        count 0 < [
          "count must not be negative" makeStringView compilerError
        ] when

        compilable [
          struct: Struct;
          staticness: refToElement staticnessOfVar;
          staticness Weak = [Dynamic @staticness set] when

          i: 0 dynamic;
          [
            i count < [
              element: refToElement copyVar staticness makeStaticness;
              field: Field;
              processor.emptyNameInfo @field.@nameInfo set
              element @field.@refToVar set
              field @struct.@fields.pushBack
              i 1 + @i set TRUE
            ] &&
          ] loop

          result: @struct move owner VarStruct createVariable;
          result isVirtual not [result createAllocIR @result set] when
          resultStruct: VarStruct result getVar.data.get.get;


          i: 0 dynamic;
          [
            i resultStruct.fields.dataSize < [
              field: i resultStruct.fields.at;
              field.refToVar isVirtualField [
                field.refToVar isAutoStruct ["unable to copy virtual autostruct" compilerError] when
              ] [
                field.refToVar unglobalize
                currentNode.program.dataSize field.refToVar getVar.@allocationInstructionIndex set
                "no alloc..." makeStringView createComent # fake instruction
                refToElement field.refToVar createCheckedCopyToNew
                field.refToVar markAsUnableToDie
                field.refToVar i result createGEPInsteadOfAlloc
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
      "moved can be only mutable variables" makeStringView compilerError
    ] if
  ] when
] "mplBuiltinMove" @declareBuiltin ucall

[
  refToCond: pop;
  compilable [
    condVar: refToCond getVar;
    condVar.data.getTag VarCond = not [refToCond staticnessOfVar Dynamic > not] || ["not a static Cond" makeStringView compilerError] when
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
            "moved can be only mutable variables" makeStringView compilerError
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
    VarCond createVariable Static makeStaticness createPlainIR push
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
