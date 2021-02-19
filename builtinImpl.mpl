# Copyright (C) 2021 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"Array"     use
"HashTable" use
"Owner"     use
"String"    use
"algorithm" use
"control"   use
"file"      use

"Block"           use
"Var"             use
"astNodeType"     use
"codeNode"        use
"debugWriter"     use
"declarations"    use
"defaultImpl"     use
"irWriter"        use
"memory"          use
"pathUtils"       use
"processSubNodes" use
"processor"       use
"staticCall"      use
"variable"        use

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

    (
      [processor compilable]
      [structVar.data.getTag VarStruct = ~ [ "not a combined" @processor block compilerError] when]
      [indexVar.data.getTag VarInt32 = ~ ["index must be Int32" @processor block compilerError] when]
      [
        struct: VarStruct structVar.data.get.get;
        refToIndex staticityOfVar Weak < [
          struct.homogeneous [
            struct.fields.size 0 > [
              # create dynamic getIndex
              realRefToStruct: refToStruct;
              realStructVar: structVar;
              realStruct: struct;
              refToStruct staticityOfVar Virtual < ~ [
                "can't get dynamic index in virtual struct" @processor block compilerError
              ] when

              @refToIndex @processor @block makeVarRealCaptured
              @refToStruct makeVarPtrCaptured

              firstField: 0 realStruct.fields.at.refToVar;
              fieldRef: firstField @processor @block copyOneVarFromType Dynamic @processor @block makeStorageStaticity;

              refToStruct.mutable @fieldRef.setMutable
              @fieldRef fullUntemporize
              fieldRef staticityOfVar Virtual < ~ [
                "dynamic index in combined of virtuals" @processor block compilerError
              ] [
                fieldRef @processor @block makeVarTreeDynamicStoraged
                @fieldRef @processor block unglobalize
                fieldRef refToIndex realRefToStruct @processor @block createDynamicGEP
                fieldVar: @fieldRef getVar;
                block.program.size 1 - @fieldVar.@getInstructionIndex set
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
  ] when

  result
];

mplNumberBinaryOp: [
  exValidator:;
  getResultType:;
  opFunc:;
  getOpName:;
  lastTag: new;
  firstTag: new;

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
          tag: new;
          value1: tag var1.data.get.end new;
          value2: tag var2.data.get.end new;
          resultType: tag @getResultType call;
          value1 value2 @exValidator call
          processor compilable [
            value1 value2 @opFunc call resultType @processor cutValue makeValuePair resultType @processor @block createVariable
            arg1 staticityOfVar arg2 staticityOfVar staticityOfBinResult @processor block makeStaticity
            @processor @block createPlainIR @block push
          ] when
        ] staticCall
      ] [
        opName: arg1 arg2 @getOpName call;
        var1.data.getTag firstTag lastTag [
          tag: new;
          value1: tag var1.data.get.end new;
          value2: tag var2.data.get.end new;
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
          tag: new;
          value: tag var.data.get.end new;
          resultType: tag new;
          value @exValidator call
          processor compilable [
            value @opFunc call resultType @processor cutValue makeValuePair resultType @processor @block createVariable
            arg staticityOfVar @processor block makeStaticity
            @processor @block createPlainIR @block push
          ] when
        ] staticCall
      ] [
        @arg @processor @block makeVarRealCaptured
        opName: arg @getOpName call;
        var.data.getTag VarReal32 VarReal64 1 + [
          tag: new;
          value: tag var.data.get.end new;
          resultType: tag new;
          result: resultType zeroValue makeValuePair resultType @processor @block createVariable
            Dynamic @processor block makeStaticity
            @processor @block createAllocIR;

          args: IRArgument Array;

          irarg: IRArgument;
          arg @processor @block createDerefToRegister @irarg.@irNameId set
          arg @processor getMplSchema.irTypeId @irarg.@irTypeId set
          FALSE @irarg.@byRef set
          irarg @args.pushBack

          result args String @opName FALSE dynamic @processor @block createCallIR retName:;

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
  lastTag: new;
  firstTag: new;

  arg: @processor @block pop;

  processor compilable [
    var: arg getVar;
    var.data.getTag firstTag < [var.data.getTag lastTag < ~] || ["argument invalid" @processor block compilerError] when

    processor compilable [
      arg staticityOfVar Dynamic > [
        var.data.getTag firstTag lastTag [
          tag: new;
          value: tag var.data.get.end new;
          resultType: tag new;
          value @exValidator call
          processor compilable [
            value @opFunc call resultType @processor cutValue makeValuePair resultType @processor @block createVariable
            arg staticityOfVar @processor block makeStaticity
            @processor @block createPlainIR @block push
          ] when
        ] staticCall
      ] [
        @arg @processor @block makeVarRealCaptured
        opName: arg @getOpName call;
        mopName: arg @getMidOpName call;
        var.data.getTag firstTag lastTag [
          tag: new;
          value: tag var.data.get.end new;
          resultType: tag new;
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
          tag1: new;
          var2.data.getTag VarNat8 VarNatX 1 + [
            tag2: new;
            value1: tag1 var1.data.get.end new;
            value2: tag2 var2.data.get.end new;
            resultType: tag1 new;
            value2 63n64 > ["shift value must be less than 64" @processor block compilerError] when

            processor compilable [
              value1 value2 @opFunc call resultType @processor cutValue makeValuePair resultType @processor @block createVariable
              arg1 staticityOfVar arg2 staticityOfVar staticityOfBinResult @processor @block makeStaticity
              @processor @block createPlainIR @block push
            ] when
          ] staticCall
        ] staticCall
      ] [
        opName: arg1 arg2 @getOpName call;
        var1.data.getTag VarNat8 VarIntX 1 + [
          tag: new;
          resultType: tag new;
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
          processor.specialNames.variadicNameInfo [
            variadicRefToVar: f.refToVar;
            variadicVar: variadicRefToVar getVar;
            (
              [processor compilable]
              [variadicVar.data.getTag VarCond = ~ ["value must be Cond" @processor block compilerError] when]
              [variadicRefToVar staticityOfVar Weak < ["value must be Static" @processor block compilerError] when]
              [VarCond variadicVar.data.get.end @result.@variadic set]
            ) sequence
          ]
          processor.specialNames.conventionNameInfo [
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
  VarNat8 VarReal64 1 + [a2:; a1:; a2 isReal ["fmul" makeStringView]["mul" makeStringView] if] [*] [new] [y:; x:;] mplNumberBinaryOp
] "mplBuiltinMul" @declareBuiltin ucall

[
  VarNat8 VarReal64 1 + [a2:; a1:; a2 isReal ["fadd" makeStringView]["add" makeStringView] if] [+] [new] [y:; x:;] mplNumberBinaryOp
] "mplBuiltinAdd" @declareBuiltin ucall

[
  VarNat8 VarReal64 1 + [a2:; a1:; a2 isReal ["fsub" makeStringView]["sub" makeStringView] if] [-] [new] [y:; x:;] mplNumberBinaryOp
] "mplBuiltinSub" @declareBuiltin ucall

[
  VarNat8 VarReal64 1 + [a2:; a1:; a2 isReal ["fdiv" makeStringView][a2 isNat ["udiv" makeStringView] ["sdiv" makeStringView] if] if] [/] [new] [
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
            tag: new;
            value1: tag var1.data.get.end new;
            value2: tag var2.data.get.end new;
            value1 value2 = makeValuePair VarCond @processor @block createVariable
            arg1 staticityOfVar arg2 staticityOfVar staticityOfBinResult @processor block makeStaticity
            @processor @block createPlainIR @block push
          ] staticCall
        ] if
      ] [
        var1.data.getTag VarString = [
          result: FALSE makeValuePair VarCond @processor @block createVariable Dynamic @processor @block makeStaticity @processor @block createAllocIR;
          arg1 arg2 @result "icmp eq" makeStringView @processor @block createStringCompare
          result @block push
        ] [
          arg1 isReal [
            var1.data.getTag VarReal32 VarReal64 1 + [
              tag: new;
              result: FALSE makeValuePair VarCond @processor @block createVariable Dynamic @processor @block makeStaticity @processor @block createAllocIR;
              arg1 arg2 @result "fcmp oeq" @processor @block createBinaryOperation
              result @block push
            ] staticCall
          ] [
            var1.data.getTag VarCond VarIntX 1 + [
              tag: new;
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
          tag: new;
          value1: tag var1.data.get.end new;
          value2: tag var2.data.get.end new;
          resultType: tag new;

          processor compilable [
            value1 value2 ^ resultType @processor cutValue makeValuePair resultType @processor @block createVariable
            arg1 staticityOfVar arg2 staticityOfVar staticityOfBinResult @processor @block makeStaticity
            @processor @block createPlainIR @block push
          ] when
        ] staticCall
      ] [
        @arg1 @processor @block makeVarRealCaptured
        @arg2 @processor @block makeVarRealCaptured

        var1.data.getTag VarReal32 VarReal64 1 + [
          tag: new;
          resultType: tag new;
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

          result args String tag VarReal32 = ["@llvm.pow.f32" makeStringView] ["@llvm.pow.f64" makeStringView] if FALSE dynamic @processor @block createCallIR retName:;

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
    @refToVar @processor @block makeVarRealCaptured

    var: refToVar getVar;
    varSchema: refToSchema getVar;
    var.data.getTag VarNatX = [
      var: refToVar getVar;
      varSchema: refToSchema getVar;
      schemaOfResult: RefToVar;
      varSchema.data.getTag VarRef = [
        "Unable in current semantic!" failProc
      ] [
        refToSchema @schemaOfResult set
      ] if

      schemaOfResult isVirtual [
        "pointee is virtual, cannot cast" @processor block compilerError
      ] [
        refToVar staticityOfVar Dynamic > [VarNatX var.data.get.end 0n64 =] && [
          result: schemaOfResult @processor @block getNilVar @processor @block getLastShadow;
          schemaOfResult.mutable @result.setMutable
          result @block push
        ] [
          refBranch: schemaOfResult makeRefBranch;
          FALSE @refBranch.@refToVar.setMoved

          refToDst: refBranch FALSE @processor @block createRefVariable;
          Dynamic makeValuePair @refToDst getVar.@staticity set
          refToVar @refToDst "inttoptr" @processor @block createCastCopyToNew
          @refToDst @processor @block derefAndPush
        ] if
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
      0nx
    ] [
      refToVar @processor block checkUnsizedData
      refToVar @processor getAlignment
    ] if

    0n64 cast makeValuePair VarNatX @processor @block createVariable Static @processor @block makeStaticity @processor @block createPlainIR @block push
  ] when
] "mplBuiltinAlignment" @declareBuiltin ucall

[
  VarCond VarNatX 1 + [a2:; a1:; "and" makeStringView] [and] [new] [y:; x:;] mplNumberBinaryOp
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
              processor.specialNames.emptyNameInfo @field.@nameInfo set
              element @field.@refToVar set
              field @struct.@fields.pushBack
              i 1 + @i set TRUE
            ] &&
          ] loop

          result: @struct owner VarStruct @processor @block createVariable;
          result isVirtual ~ [@result @processor @block createAllocIR @result set] when
          resultStruct: VarStruct @result getVar.@data.get.get;

          i: 0 dynamic;
          [
            i resultStruct.fields.size < [
              field: i @resultStruct.@fields.at;
              field.refToVar isVirtual [
                field.refToVar isAutoStruct ["unable to copy virtual autostruct" @processor block compilerError] when
              ] [
                @field.@refToVar @processor block unglobalize
                block.program.size @field.@refToVar getVar.@allocationInstructionIndex set
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
            tagSrc: new;
            branchSrc: tagSrc varSrc.data.get.end;
            varSchema.data.getTag VarNat8 VarReal64 1 + [
              tagDst: new;
              branchSchema: tagDst @varSchema.@data.get.end;
              branchSrc branchSchema cast tagDst @processor cutValue makeValuePair tagDst @processor @block createVariable @processor @block createPlainIR @refToDst set
            ] staticCall
          ] staticCall

          refToVar staticityOfVar makeValuePair @refToDst getVar.@staticity set
          refToDst @block push
        ] [
          refToVar @processor @block makeVarRealCaptured

          refToDst: RefToVar;
          varSchema: refToSchema getVar;
          varSchema.data.getTag VarNat8 VarReal64 1 + [
            tagDst: new;

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
      newBlock: signature name makeStringView TRUE dynamic @processor @block processImportFunction @processor.@blocks.at.get;
    ]
    [
      gnr: newBlock.varNameInfo @processor @block getName;
      cnr: @gnr 0 dynamic @processor @block processor.positions.last.file captureName;
      refToVar: cnr.refToVar new;
      refToVar @block push
    ]
  ) sequence
] "mplBuiltinCodeRef" @declareBuiltin ucall

[
  TRUE dynamic @block.@nodeCompileOnce set
] "mplBuiltinCompileOnce" @declareBuiltin ucall

[TRUE @processor @block defaultMakeConstWith] "mplBuiltinConst" @declareBuiltin ucall

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
    refToVar @processor @block makeVarTreeDynamic
    refToVar @block push
  ] when
] "mplBuiltinDynamic" @declareBuiltin ucall

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
      astArrayIndex: VarCode varBody.data.get.index;
      index: signature astArrayIndex VarString varName.data.get makeStringView FALSE dynamic @processor @block processExportFunction;
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
      refToVar @processor @block makeVarTreeDirty
    ] [
      name: VarString varName.data.get;
      nameInfo: name makeStringView @processor findNameInfo;
      fr: nameInfo processor.exportVarIds.find;
      fr.success ["export variable name used now" @processor block compilerError] when
    ] [
      oldIrNameId: var.irNameId new;
      nameInfo refToVar @processor.@exportVarIds.insert
      oldInstructionIndex: var.globalDeclarationInstructionIndex new;
      ("@" name) assembleString @processor makeStringId @var.@irNameId set

      processor.options.partial [
        [block.file isNil ~] "ExportVariable in nil file!" assert
        block.file.usedInParams ~
      ] && [
        @refToVar @processor @block createVarImportIR drop
      ] [
        @refToVar @processor @block createVarExportIR drop
        instruction: var.globalDeclarationInstructionIndex @processor.@prolog.at;
        @processor.@prolog.last @instruction set
        @processor.@prolog.popBack
        TRUE @refToVar.setMutable
        var.irNameId oldIrNameId refToVar @processor getMplSchema.irTypeId @processor createGlobalAliasIR
        oldInstructionIndex @var.@globalDeclarationInstructionIndex set
      ] if

      {
        addNameCase: NameCaseLocal;
        refToVar:    refToVar new;
        nameInfo:    nameInfo new;
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
    var.data.getTag VarStruct = ~ ["not a combined" @processor block compilerError] when
    processor compilable [
      VarStruct var.data.get.get.fields.size 0i64 cast makeValuePair VarInt32 @processor @block createVariable Static @processor @block makeStaticity @processor @block createPlainIR @block push
    ] when
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
        var.data.getTag VarStruct = ~ ["not a combined" @processor block compilerError] when
        processor compilable [
          struct: VarStruct var.data.get.get;
          count 0 < [count struct.fields.getSize < ~] || ["index is out of bounds" @processor block compilerError] when
          processor compilable [
            count struct.fields.at.nameInfo processor.nameManager.getText @processor @block makeVarString @block push
          ] when
        ] when
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
  processor.varForCallTrace.assigned ~ [
    varPrev:   0n64 makeValuePair VarNatX @processor @block createVariable;
    varName:   String @processor @block makeVarString TRUE dynamic @processor @block createRefNoOp;
    varLine:   0i64 makeValuePair VarInt32 @processor @block createVariable;
    varColumn: 0i64 makeValuePair VarInt32 @processor @block createVariable;

    struct: Struct;

    field: Field;
    varPrev @field.@refToVar set
    "prev" makeStringView @processor findNameInfo @field.@nameInfo set
    @field @struct.@fields.pushBack

    field: Field;
    varName @field.@refToVar set
    "name" makeStringView @processor findNameInfo @field.@nameInfo set
    @field @struct.@fields.pushBack

    field: Field;
    varLine @field.@refToVar set
    "line" makeStringView @processor findNameInfo @field.@nameInfo set
    @field @struct.@fields.pushBack

    field: Field;
    varColumn @field.@refToVar set
    "column" makeStringView @processor findNameInfo @field.@nameInfo set
    @field @struct.@fields.pushBack

    @struct owner VarStruct @processor @block createVariable @processor.@varForCallTrace set

    Dynamic @processor.@varForCallTrace getVar.@storageStaticity set
    @processor.@varForCallTrace @processor @block makeVarTreeDirty
  ] when

  result: @processor.@varForCallTrace FALSE dynamic @processor @block createRefNoOp @processor @block createAllocIR Dynamic @processor @block makeStaticity;
  result @processor @block createGetCallTrace
  result @processor @block derefAndPush

  TRUE @block.!hasCallTrace
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
        value: VarCond varCond.data.get.end new;
        value [
          VarCode varThen.data.get.index "staticIfThen" makeStringView @processor @block processCall
        ] [
          VarCode varElse.data.get.index "staticIfElse" makeStringView @processor @block processCall
        ] if
      ] [
        condition @processor @block makeVarRealCaptured

        condition
        VarCode varElse.data.get.index
        VarCode varThen.data.get.index
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
    [newBlockId: signature VarString varName.data.get makeStringView FALSE dynamic @processor @block processImportFunction;]
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
              refToVar:    newRefToVar new;
              nameInfo:    nameInfo new;
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
        @refToVar1 makeVarPtrCaptured
        @refToVar2 makeVarPtrCaptured
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
    refToVar staticityOfVar Dynamic = makeValuePair VarCond @processor @block createVariable Static @processor @block makeStaticity @processor @block createPlainIR @block push
  ] when
] "mplBuiltinIsDynamic" @declareBuiltin ucall

[
  refToVar: @processor @block pop;
  processor compilable [
    refToVar staticityOfVar Static = makeValuePair VarCond @processor @block createVariable Static @processor @block makeStaticity @processor @block createPlainIR @block push
  ] when
] "mplBuiltinIsStatic" @declareBuiltin ucall

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
      astArrayIndex: VarCode varBody.data.get.index;
      astArrayIndex @processor @block processLoop
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
  VarNat8 VarIntX 1 + [a2:; a1:; a2 isNat ["urem" makeStringView] ["srem" makeStringView] if] [mod] [new] [
    y:; x:;
    y y - y = ["division by zero" @processor block compilerError] when
  ] mplNumberBinaryOp
] "mplBuiltinMod" @declareBuiltin ucall

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
    refToVar getVar.temporary [
      "temporary objects cannot be copied" @processor block compilerError
    ] [
      refToVar getVar.data.getTag VarImport = [
        "functions cannot be copied" @processor block compilerError
      ] [
        refToVar getVar.data.getTag VarString = [
          "builtin-strings cannot be copied" @processor block compilerError
        ] [
          refToVar isPlain [
            refToVar staticityOfVar Dynamic > [
              result: refToVar @processor @block copyVarToNew @processor @block createPlainIR;
              TRUE @result.setMutable
              result @block push
            ] [
              refToVar isVirtual ~ [@refToVar @processor @block makeVarRealCaptured] when
              result: refToVar @processor @block copyVarToNew;
              TRUE @result.setMutable
              @refToVar @result @processor @block createCopyToNew
              result @block push
            ] if
          ] [
            refToVar isVirtual ~ [@refToVar @processor @block makeVarRealCaptured] when
            result: refToVar @processor @block copyVarToNew;
            result isVirtual [
              result isAutoStruct ["unable to copy virtual autostruct" @processor block compilerError] when
            ] [
              TRUE @result.setMutable
              refToVar.mutable [refToVar isVirtual ~ [refToVar getVar .data.getTag VarStruct =] &&] && [
                TRUE @refToVar.setMoved
              ] when

              @refToVar @result @processor @block createCopyToNew
            ] if

            result @block push
          ] if
        ] if
      ] if
    ] if
  ] when
] "mplBuiltinNew" @declareBuiltin ucall

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

        result isAutoStruct [
          result @block.@candidatesToDie.pushBack
        ] when
      ] when

      result @block push
    ] if
  ] when
] "mplBuiltinNewVarOfTheSameType" @declareBuiltin ucall

[
  VarCond VarNatX 1 + [a2:; a1:; "or" makeStringView] [or] [new] [y:; x:;] mplNumberBinaryOp
] "mplBuiltinOr" @declareBuiltin ucall

[
  block.nextLabelIsOverload ["duplicate overload specifier" @processor block compilerError] when
  TRUE @block.@nextLabelIsOverload set
] "mplBuiltinOverload" @declareBuiltin ucall

[
  debugMemory [
    ("compilerMaxAllocationSize=" getMemoryMetrics.memoryMaxAllocationSize LF) printList
  ] [
    ("compilerMaxAllocationSize is unknown, use -debugMemory flag" LF) printList
  ] uif
] "mplPrintCompilerMaxAllocationSize"  @declareBuiltin ucall

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
  block.astArrayIndex @processor @block printAstArrayTree
] "mplBuiltinPrintMatchingTree" @declareBuiltin ucall

[
  ("Print shadow events for block " block.id " in astNode " block.astArrayIndex LF) printList
  block.buildingMatchingInfo.shadowEvents.size [
    event: i block.buildingMatchingInfo.shadowEvents.at;
    event i TRUE @processor @block printShadowEvent
  ] times
] "mplBuiltinPrintShadowEvents" @declareBuiltin ucall

[
  @processor block defaultPrintStack
] "mplBuiltinPrintStack" @declareBuiltin ucall

[
  @processor block defaultPrintStackTrace
] "mplBuiltinPrintStackTrace" @declareBuiltin ucall

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
      refToVar getVar.storageStaticity Virtual = [
        0n64 makeValuePair VarNatX @processor @block createVariable @processor @block createPlainIR @block push
      ] [
        @refToVar makeVarPtrCaptured
        refToVar @processor @block makeVarTreeDirty
        refToDst: 0n64 makeValuePair VarNatX @processor @block createVariable;
        Dynamic makeValuePair @refToDst getVar.@staticity set
        var: refToVar getVar;
        refToVar @refToDst "ptrtoint" @processor @block createCastCopyPtrToNew
        refToDst @block push
      ] if
    ]
  ) sequence
] "mplBuiltinStorageAddress" @declareBuiltin ucall

[
  refToVar: @processor @block pop;
  processor compilable [
    refToVar isVirtual [
      0nx
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

        string.chars.size 0 < ~ [
          splitted: string splitString;
          splitted.success [
            splitted.chars [
              element: toString @processor @block makeVarString;
              field: Field;
              processor.specialNames.emptyNameInfo @field.@nameInfo set
              @element TRUE dynamic @processor @block createRef @field.@refToVar set
              field @struct.@fields.pushBack
            ] each

            result: @struct owner VarStruct @processor @block createVariable;
            result isVirtual ~ [@result @processor @block createAllocIR @result set] when
            resultStruct: VarStruct @result getVar.@data.get.get;

            i: 0 dynamic;
            [
              i resultStruct.fields.size < [
                field: i @resultStruct.@fields.at;

                result isGlobal [
                  block.program.size @field.@refToVar getVar.@allocationInstructionIndex set
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
      astArrayIndex: VarCode varCode.data.get.index new;
      block.countOfUCall 1 + @block.@countOfUCall set
      block.countOfUCall 65535 > ["ucall limit exceeded" @processor block compilerError] when
      indexArray: astArrayIndex processor.multiParserResult.memory.at;
      indexArray @block addIndexArrayToProcess
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
        value: VarCond varCond.data.get.end new;
        code: value [VarCode varThen.data.get] [VarCode varElse.data.get] if;
        astArrayIndex: code.index;
        block.countOfUCall 1 + @block.@countOfUCall set
        block.countOfUCall 65535 > ["ucall limit exceeded" @processor block compilerError] when
        indexArray: astArrayIndex processor.multiParserResult.memory.at;
        indexArray @block addIndexArrayToProcess
      ] [
        "condition must be static" @processor block compilerError
      ] if
    ] when
  ] when
] "mplBuiltinUif" @declareBuiltin ucall

FindInPathResult: {
  NO_FILE: [0];
  FILE_WITH_ERROR: [1];
  UNCOMPILED_FILE: [2];
  COMPILED_FILE: [3];
};

tryFindInPath: [
  moduleName: path: processor: block: ;;;;

  fullFileName: path "" = [(moduleName ".mpl") assembleString] [(path "/" moduleName ".mpl") assembleString] if;

  result: {
    success: FindInPathResult.NO_FILE;
    fullFileName: String;
    block: Block Cref;
  };

  checkLoadedFile: [
    fullFileName:;

    fr: fullFileName processor.fileNameIds.find;
    fr.success [
      fr: fullFileName processor.modules.find;
      fr.success [fr.value 0 < ~] && [
        fileBlock: fr.value processor.blocks.at.get;
        fileBlock @result.!block
        @fullFileName @result.@fullFileName set
        FindInPathResult.COMPILED_FILE @result.!success
      ] [
        @fullFileName @result.@fullFileName set
        FindInPathResult.UNCOMPILED_FILE @result.!success
      ] if

      TRUE
    ] &&
  ];

  @fullFileName checkLoadedFile ~ [
    loadStringResult: fullFileName loadString;
    loadStringResult.success [
      errorInfo: processor.files.getSize fullFileName makeStringView loadStringResult.data makeStringView @processor.@multiParserResult @processor.@nameManager addToProcess;
      errorInfo "" = [
        fileId: FALSE fullFileName makeStringView @processor addFileNameToProcessor;
        fullFileName @processor.@options.@fileNames.pushBack
        fileId @processor.@unfinishedFiles.pushBack
        @fullFileName @result.@fullFileName set
        FindInPathResult.UNCOMPILED_FILE @result.!success
      ] [
        errorInfo @processor @block compilerError
        @fullFileName @result.@fullFileName set
        FindInPathResult.FILE_WITH_ERROR @result.!success
      ] if
    ] [
      findInCmd: moduleName processor.cmdFileNameIds.find;
      findInCmd.success [
        findInCmd.value new checkLoadedFile ~ [
          FindInPathResult.NO_FILE @result.!success
        ] when
      ] [
        FindInPathResult.NO_FILE @result.!success
      ] if
    ] if
  ] when

  result
];

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
      fileName: string stripExtension;
      fileName "" = ["invalid fileName" @processor block compilerError] when
    ] [
      variableName: string extractExtension;
      useAll: variableName "" =;
      currentFile: processor.positions.last.file;
      currentFilePath: currentFile.name stripFilename;

      findResult: fileName currentFilePath @processor @block tryFindInPath;
      findResult.success FindInPathResult.NO_FILE = [
        processor.options.includePaths [
          currentPath:;
          findResult.success FindInPathResult.NO_FILE = [
            fileName currentPath @processor @block tryFindInPath !findResult
          ] when
        ] each
      ] when

      findResult.success (
        FindInPathResult.NO_FILE [
          oldSuccess: processor compilable;
          message: ("module not found: " fileName) assembleString;
          message @processor block compilerError
          oldSuccess [
            @processor.@result.@errorInfo @processor.@result.@globalErrorInfo.pushBack
            -1 @processor.@result clearProcessorResult
          ] when
        ]
        FindInPathResult.FILE_WITH_ERROR [
          #we has error yet
        ]
        FindInPathResult.UNCOMPILED_FILE [
          TRUE dynamic @processor.@result.@findModuleFail set
          @findResult.@fullFileName @processor.@result.@errorInfo.@missedModule set
          ("module not compiled yet: " fileName) assembleString @processor block compilerError
        ]
        FindInPathResult.COMPILED_FILE [
          fileBlock: findResult.block;
          file: fileBlock.file;

          block.exportDepth 0 = [
            topNode: @block.topNode;
            fileBlock.globalPriority topNode.globalPriority < ~ [
              fileBlock.globalPriority 1 + @topNode.!globalPriority
            ] when
          ] when

          nameInfo: variableName @processor findNameInfo;
          labelCount: 0;

          findLabelNames: [
            overloadCounter:;

            addNameData: @processor.@temporaryBuiltinUseData.@addNameData;

            fileBlock.labelNames.size [
              label: fileBlock.labelNames.size 1 - i - fileBlock.labelNames.at;

              useAll [label.nameInfo nameInfo =] || [
                index: depth: label.nameInfo overloadCounter;;

                gnr: label.nameInfo index @processor @block file getNameWithOverloadIndex;
                cnr: gnr depth @processor @block file captureName;

                {refToVar: cnr.refToVar new; nameInfo: label.nameInfo new; } @addNameData.pushBack

                labelCount 1 + !labelCount
              ] when
            ] times

            addNameData.size [
              current: addNameData.size 1 - i - addNameData.at;

              {
                addNameCase: NameCaseFromModule;
                refToVar:    current.refToVar new;
                nameInfo:    current.nameInfo new;
                overload:    block.nextLabelIsOverload;
              } @processor @block addNameInfo

              current.nameInfo @processor @block checkPossibleUnstables
            ] times

            @addNameData.clear
            @overloadCounter.clear
          ];

          useAll [
            FALSE @block.!nextLabelIsOverload

            {
              indexes: @processor.@temporaryBuiltinUseData.@indexes;
              CALL: [nameInfo:;
                fr: nameInfo @indexes.find;
                fr.success [
                  result: fr.value.index file nameInfo @processor.@nameManager.findItemStrong;
                  result @fr.@value.@index set
                  fr.value.depth 1 + @fr.@value.@depth set
                  fr.value.index new fr.value.depth new
                ] [
                  result: -1 file nameInfo @processor.@nameManager.findItem;
                  nameInfo {index: result new; depth: 0;} @indexes.insert
                  result 0
                ] if
              ];

              clear: [@indexes.clear];
            } findLabelNames
          ] [
            {
              depth: -1;
              index: -1;
              CALL: [
                nameInfo:;
                index file nameInfo @processor.@nameManager.findItemStrong !index
                depth 1 + !depth
                index depth
              ];

              clear: [];
            } findLabelNames
          ] if

          FALSE @block.!nextLabelIsOverload

          labelCount 0 = [
            oldSuccess: processor compilable;
            message: ("no names match \"" variableName "\"") assembleString;

            useAll ~ [
              @message nameInfo @processor catPossibleModulesList
            ] when

            message @processor block compilerError
            oldSuccess [
              @processor.@result.@errorInfo @processor.@result.@globalErrorInfo.pushBack
              -1 @processor.@result clearProcessorResult
            ] when
          ] when
        ]
        [
        ]
      ) case
    ]
  ) sequence
] "mplBuiltinUse" @declareBuiltin ucall

[
  block.nextLabelIsVirtual ["duplicate virtual specifier" @processor block compilerError] when
  TRUE @block.@nextLabelIsVirtual set
] "mplBuiltinVirtual" @declareBuiltin ucall

[
  VarCond VarNatX 1 + [a2:; a1:; "xor" makeStringView] [xor] [new] [y:; x:;] mplNumberBinaryOp
] "mplBuiltinXor" @declareBuiltin ucall

[
  VarCond VarNatX 1 + [a:; "xor" makeStringView] [
    a:; a getVar.data.getTag VarCond = ["true, " makeStringView]["-1, " makeStringView] if
  ] [~] [x:;] mplNumberUnaryOp
] "mplBuiltinNot" @declareBuiltin ucall
