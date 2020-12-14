"Array" use
"HashTable" use
"Owner" use
"String" use
"control" use
"file" use

"Block" use
"Var" use
"astNodeType" use
"codeNode" use
"debugWriter" use
"declarations" use
"defaultImpl" use
"irWriter" use
"memory" use
"pathUtils" use
"processSubNodes" use
"processor" use
"staticCall" use
"variable" use

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

    checkVar: [checkedVar drop];
    checkVarBy: [checkedVarBy drop];
    checkedVar: [
      refToVar: type: msg:;;;
      @refToVar [getVar.data.getTag type =] msg checkedVarBy
    ];
    checkedVarBy: [
      checkedVarBy-refToVar: checkedVarBy-f: checkedVarBy-msg:;;;
      @checkedVarBy-refToVar checkedVarBy-f ~ [checkedVarBy-refToVar checkedVarBy-msg illegalRef] when
      @checkedVarBy-refToVar getVar
    ];
    illegalRef: [
      refToVar: msg:;;
      (msg " <" refToVar @processor block getMplType ">") assembleString @processor block compilerError
    ];

    @declareBuiltinBody ucall
  ] declareBuiltinName exportFunction
];

mplBuiltinProcessAtList: [
  refToStruct: @processor @block pop;
  refToIndex: @processor @block pop;
  compileOnce

  result: RefToVar;

  (
    [processor compilable]
    [structVar: refToStruct VarStruct "the right-hand argument \"object\" is not a list:" checkedVar;]
    [indexVar: refToIndex VarInt32 "the left-hand argument \"index\" is not an Int32:" checkedVar;]
    [
      struct: VarStruct structVar.data.get.get;
      refToIndex staticityOfVar Weak < [
        struct.homogeneous [
          struct.fields.size 0 > [
            refToStruct staticityOfVar Virtual < ~ [refToStruct "virtual list can't be indexed by dynamic value; the list is:" illegalRef] when

            @refToIndex @processor @block makeVarRealCaptured
            @refToStruct makeVarPtrCaptured

            firstField: 0 struct.fields.at.refToVar;
            fieldRef: firstField @processor @block copyOneVarFromType Dynamic @processor @block makeStorageStaticity;

            refToStruct.mutable @fieldRef.setMutable
            @fieldRef fullUntemporize
            fieldRef staticityOfVar Virtual < ~ [
              fieldRef "list of virtual items can't be indexed by dynamic value; the list is:" illegalRef
            ] [
              fieldRef @processor @block makeVarTreeDynamicStoraged
              @fieldRef @processor block unglobalize
              fieldRef refToIndex refToStruct @processor @block createDynamicGEP
              fieldVar: @fieldRef getVar;
              block.program.size 1 - @fieldVar.@getInstructionIndex set
              fieldRef @result set
            ] if

            refToStruct.mutable [
              refToStruct @processor @block makeVarTreeDirty
            ] when
          ] [
            "the function can't be applied to empty list" @processor block compilerError
          ] if
        ] [
          refToStruct "non-homogeneous list can't be indexed by dynamic value; the list is:" illegalRef
        ] if
      ] [
        index: VarInt32 indexVar.data.get.end 0 cast;
        index @refToStruct @processor @block processStaticAt @result set
      ] if
    ]
  ) sequence

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
    var1.data.getTag firstTag < [var1.data.getTag lastTag < ~] || [arg1 "the left-hand argument is invalid:" illegalRef] [
      var2.data.getTag firstTag < [var2.data.getTag lastTag < ~] || [arg2 "the right-hand argument is invalid:" illegalRef] [
        arg1 arg2 variablesAreSame ~ [
          ("schema mismatch - the left-hand argument is <" arg1 @processor block getMplType ">, the right-hand argument is <" arg2 @processor block getMplType ">") assembleString @processor block compilerError
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
    arg isReal ~ [arg "the argument is invalid:" illegalRef] when

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
        @arg @processor @block makeVarRealCaptured
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
  copy lastTag:;
  copy firstTag:;

  arg: @processor @block pop;

  processor compilable [
    var: arg getVar;
    var.data.getTag firstTag < [var.data.getTag lastTag < ~] || [arg "the argument is invalid:" illegalRef] when

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
        @arg @processor @block makeVarRealCaptured
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
    arg1 isAnyInt ~ [arg1 "the left-hand argument is invalid:" illegalRef] [
      arg2 isNat ~ [arg2 "the right-hand argument is invalid:" illegalRef] when
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
            value2 63n64 > [("the right-hand argument \"count\" is greater than 63, it is equal: " value2) assembleString @processor block compilerError] when

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
  varStruct: refToStruct VarStruct "the argument \"parameters\" is not a list:" checkedVar;

  processor compilable [
    VarStruct varStruct.data.get.get.fields enumerate [
      field:;
      refToVar: field.value.refToVar;
      refToVar [isVirtual ~] ("non-mpl function can't take virtual value as a parameter; the zero-based parameter #" field.key " is:") assembleString checkVarBy # FIXME: Do not allocate memory for the message without the need.
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
    [optionsVar: options VarStruct "the argument \"options\" is not a list with names:" checkedVar;]
    [
      optionsStruct: VarStruct optionsVar.data.get.get;
      hasConvention: FALSE dynamic;
      optionsStruct.fields [
        f:;
        f.nameInfo (
          # FIXME: Should we use "nameManager.getText" here instead of the hard-coded names of the signature options?

          processor.specialNames.variadicNameInfo [
            variadicRefToVar: f.refToVar;
            (
              [processor compilable]
              [variadicVar: variadicRefToVar VarCond "the option \"variadic\" is not a static Cond:" checkedVar;]
              [variadicRefToVar staticityOfVar Weak < ["the value of option \"variadic\" is not static" @processor block compilerError] when]
              [VarCond variadicVar.data.get.end @result.@variadic set]
            ) sequence
          ]
          processor.specialNames.conventionNameInfo [
            conventionRefToVarRef: f.refToVar;
            (
              [processor compilable]
              [conventionVarRef: conventionRefToVarRef VarRef "the option \"convention\" is not a reference to static string:" checkedVar;]
              [conventionRefToVarRef staticityOfVar Weak < ["the option \"convention\" is not static" @processor block compilerError] when]
              [
                conventionRefToVar: VarRef conventionVarRef.data.get.refToVar;
                conventionVar: conventionRefToVar VarString "the option \"convention\" is not a string:" checkedVar;
              ]
              [conventionRefToVar staticityOfVar Weak < ["the option \"convention\" is not static" @processor block compilerError] when]
              [
                string: VarString conventionVar.data.get;
                string @result.@convention set
                TRUE @hasConvention set
              ]
            ) sequence
          ]

          [
            ("unknown option name: \"" f.nameInfo processor.nameManager.getText "\"") assembleString @processor block compilerError
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
          return VarStruct "non-mpl function can't return virtual value:" checkVar # FIXME: `()([])()`.
        ] [
          #todo: detect temporality
          return getVar.temporary [
            return @result.@outputs.pushBack
          ] [
            @return TRUE dynamic @processor @block createRef @result.@outputs.pushBack
          ] if
        ] if
      ] when
    ]
    [arguments: @processor @block pop;]
    [arguments parseFieldToSignatureCaptureArray @result.@inputs set]
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
  refToStr2: @processor @block pop;
  refToStr1: @processor @block pop;
  (
    [processor compilable]
    [varStr2: refToStr2 VarString "the right-hand argument is not a static string:" checkedVar;]
    [refToStr2 staticityOfVar Weak < ["the right-hand argument is not static" @processor block compilerError] when]
    [varStr1: refToStr1 VarString "the left-hand argument is not a static string:" checkedVar;]
    [refToStr1 staticityOfVar Weak < ["the left-hand argument is not static" @processor block compilerError] when]
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
    y y - y = [("division by zero; dividend: " x) assembleString @processor block compilerError] when
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

    (
      [processor compilable]
      [arg1 @comparable "the left-hand argument is not comparable:" checkVarBy]
      [arg2 @comparable "the right-hand argument is not comparable:" checkVarBy]
      [
        arg1 arg2 variablesAreSame ~ [
          ("schema mismatch - the left-hand argument is <" arg1 @processor block getMplType ">, the right-hand argument is <" arg2 @processor block getMplType ">") assembleString @processor block compilerError
        ] when
      ]
    ) sequence

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
        var1.data.getTag VarString = [
          result: FALSE makeValuePair VarCond @processor @block createVariable Dynamic @processor @block makeStaticity @processor @block createAllocIR;
          arg1 arg2 @result "icmp eq" makeStringView @processor @block createStringCompare
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
    arg1 isReal ~ [arg1 "the left-hand argument neither a Real32 nor Real64:" illegalRef] [
      arg2 isReal ~ [arg2 "the right-hand argument neither a Real32 nor Real64:" illegalRef] [
        arg1 arg2 variablesAreSame ~ [
          ("schema mismatch - the left-hand argument is <" arg1 @processor block getMplType ">, the right-hand argument is <" arg2 @processor block getMplType ">") assembleString @processor block compilerError
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
        @arg1 @processor @block makeVarRealCaptured
        @arg2 @processor @block makeVarRealCaptured

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
        [FALSE] "Unable in current semantic!" assert
      ] [
        refToSchema @schemaOfResult set
      ] if

      schemaOfResult isVirtual [
        schemaOfResult "can't obtain reference to virtual value from any address; the right-hand argument \"valueType\" is:" illegalRef
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
      refToVar "the right-hand argument \"address\" is not a Natx:" illegalRef
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
  VarCond VarNatX 1 + [a2:; a1:; "and" makeStringView] [and] [copy] [y:; x:;] mplNumberBinaryOp
] "mplBuiltinAnd" @declareBuiltin ucall

[
  refToCount:   @processor @block pop;
  refToElement: @processor @block pop;
  processor compilable [
    @refToElement fullUntemporize
    varCount: refToCount VarInt32 "the right-hand argument \"count\" is not an Int32:" checkedVar;
    processor compilable [
      refToCount staticityOfVar Dynamic > ~ ["the right-hand argument \"count\" is not static" @processor block compilerError] when
      processor compilable [
        count: VarInt32 varCount.data.get.end 0 cast;
        count 0 < [
          ("the right-hand argument \"count\" is negative: " count) assembleString @processor block compilerError
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

          result: @struct move owner VarStruct @processor @block createVariable;
          result isVirtual ~ [@result @processor @block createAllocIR @result set] when
          resultStruct: VarStruct @result getVar.@data.get.get;

          i: 0 dynamic;
          [
            i resultStruct.fields.size < [
              field: i @resultStruct.@fields.at;
              field.refToVar isVirtual [
                field.refToVar isAutoStruct [field.refToVar "scoped item that is virtual can't be copied; the item is:" illegalRef] when
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
    [varName: refToName VarString "the right-hand argument \"fieldName\" is not a static string:" checkedVar;]
    [
      refToName staticityOfVar Weak < ["the right-hand argument \"fieldName\" is not static" @processor block compilerError] when
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

  (
    [processor compilable]
    [
      varSrc: refToVar getVar;
      varSchema: refToSchema getVar;
      varSchema.data.getTag VarRef = [refToSchema isVirtual] && [
        VarRef varSchema.data.get.refToVar @processor @block copyVarFromChild @refToSchema set
        refToSchema getVar !varSchema
      ] when

      refToVar @isNumber "the left-hand argument \"from\" is not a number:" checkVarBy
    ]
    [
      refToSchema @isNumber "the right-hand argument \"to\" is not a number:" checkVarBy
    ]
    [
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
        refToVar @processor @block makeVarRealCaptured

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
    ]
  ) sequence
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
    refToVar getVar.temporary [
      refToVar "temporary object is not copyable item:" illegalRef
    ] [
      refToVar getVar.data.getTag VarImport = [
        refToVar "non-mpl function is not copyable item:" illegalRef
      ] [
        refToVar getVar.data.getTag VarString = [
          "built-in string is not copyable item" @processor block compilerError
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
              result isAutoStruct [refToVar "scoped item that is virtual can't be copied: the item is:" illegalRef] when
            ] [
              TRUE @result.setMutable
              @refToVar @result @processor @block createCopyToNew
            ] if

            result @block push
          ] if
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
    [varName: refToName VarString "the right-hand argument \"name\" is not a static string:" checkedVar;]
    [
      refToName staticityOfVar Weak < ["the right-hand argument \"name\" is not static" @processor block compilerError] when
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
  (
    [processor compilable]
    [block.parent 0 = ~ ["can't export item from non-global scope" @processor block compilerError] when]
    [refToName: @processor @block pop;]
    [varName: refToName VarString "the right-hand argument \"functionName\" is not a static string:" checkedVar;]
    [refToName staticityOfVar Weak < ["the right-hand argument \"functionName\" is not static" @processor block compilerError] when]
    [refToBody: @processor @block pop;]
    [varBody: refToBody VarCode "the argument \"functionBody\" is not a [CODE]:" checkedVar;]
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
    [block.parent 0 = ~ ["can't export item from non-global scope" @processor block compilerError] when]
    [refToName: @processor @block pop;]
    [refToVar: @processor @block pop;]
    [varName: refToName VarString "the right-hand argument \"variableName\" is not a static string:" checkedVar;]
    [refToName staticityOfVar Weak < ["the right-hand argument \"variableName\" is not static" @processor block compilerError] when]
    [refToVar [getVar.data.getTag VarCode = ~] "can't export [CODE]; for the (all) purposes, you can use either the built-in exportFunction or codeRef; the code is:" checkVarBy]
    [refToVar [isVirtual ~] "can't export virtual item:" checkVarBy]
    [
      refToVar getVar.temporary ~ [
        @refToVar TRUE dynamic @processor @block createRef @refToVar set
      ] when
      var: @refToVar getVar;
      FALSE @var.@temporary set
    ]
    [
      refToVar @processor @block makeVarTreeDirty
    ]
    [
      name: VarString varName.data.get;
      nameInfo: name makeStringView @processor findNameInfo;
      fr: nameInfo processor.exportVarIds.find;
      fr.success [("can't export item by already exported name; the name is: \"" name "\"") assembleString @processor block compilerError] when # FIXME: The message says "can't bla bla bla" - but instead of export, we can IMPORT item by the name - and get invalid llvm-ir. Also we can export item by name that is already exported by the built-in exportFunction - and also get the invalid IR.
    ]
    [
      oldIrNameId: var.irNameId copy;
      nameInfo refToVar @processor.@exportVarIds.insert
      oldInstructionIndex: var.globalDeclarationInstructionIndex copy;
      ("@" name) assembleString @processor makeStringId @var.@irNameId set

      processor.options.partial [
        [block.file isNil ~] "Attempt to export variable from compiler-internal-file which is represented by null pointer." assert # FIXME: ??? Seems like "-part" did not set the file to null pointer.
        block.file.usedInParams ~
      ] && [
        @refToVar @processor @block createVarImportIR drop
      ] [
        @refToVar @processor @block createVarExportIR drop
        instruction: var.globalDeclarationInstructionIndex @processor.@prolog.at;
        @processor.@prolog.last move @instruction set
        @processor.@prolog.popBack
        TRUE @refToVar.setMutable
        var.irNameId oldIrNameId refToVar @processor getMplSchema.irTypeId @processor createGlobalAliasIR
        oldInstructionIndex @var.@globalDeclarationInstructionIndex set
      ] if

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
    var: refToVar VarStruct "the argument is not a list:" checkedVar;
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
    [varName: refToName VarString "the right-hand argument \"fieldName\" is not a static string:" checkedVar;]
    [refToName staticityOfVar Weak < ["the right-hand argument \"fieldName\" is not static" @processor block compilerError] when]
    [refToStruct VarStruct "the left-hand argument \"item\" is not a list:" checkVar]
    [
      string: VarString varName.data.get;
      fr: string makeStringView @processor findNameInfo refToStruct @processor block findField;
    ]
    [
      fr.success ~ [(refToStruct @processor block getMplType " has no field \"" string "\"") assembleString @processor block compilerError] when
    ]
    [
      fr.index Int64 cast makeValuePair VarInt32 @processor @block createVariable Static @processor @block makeStaticity @processor @block createPlainIR @block push
    ]
  ) sequence
] "mplBuiltinFieldIndex" @declareBuiltin ucall

[
  refToCount: @processor @block pop;
  refToVar:   @processor @block pop;
  processor compilable [
    varCount: refToCount VarInt32 "the right-hand argument \"fieldIndex\" is not a static Int32:" checkedVar;
    processor compilable [
      refToCount staticityOfVar Dynamic > ~ ["the right-hand argument \"fieldIndex\" is not static" @processor block compilerError] when
      processor compilable [
        count: VarInt32 varCount.data.get.end 0 cast;
        var: refToVar VarStruct "the left-hand argument \"item\" is not a list:" checkedVar;
        processor compilable [
          struct: VarStruct var.data.get.get;
          count 0 < [count struct.fields.getSize < ~] || [
            (
              "the index is out of bounds; field count: " struct.fields.getSize
              ", provided index: " count
              ", provided item: <" refToVar @processor block getMplType ">"
            ) assembleString @processor block compilerError
          ] when

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
    @field move @struct.@fields.pushBack

    field: Field;
    varName @field.@refToVar set
    "name" makeStringView @processor findNameInfo @field.@nameInfo set
    @field move @struct.@fields.pushBack

    field: Field;
    varLine @field.@refToVar set
    "line" makeStringView @processor findNameInfo @field.@nameInfo set
    @field move @struct.@fields.pushBack

    field: Field;
    varColumn @field.@refToVar set
    "column" makeStringView @processor findNameInfo @field.@nameInfo set
    @field move @struct.@fields.pushBack

    @struct move owner VarStruct @processor @block createVariable @processor.@varForCallTrace set

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
    [varName: refToName VarString "the right-hand argument \"fieldName\" is not a static string:" checkedVar;]
    [refToName staticityOfVar Weak < ["the right-hand argument \"fieldName\" is not static" @processor block compilerError] when]
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
  onFalse: @processor @block pop;
  onTrue: @processor @block pop;
  determiner: @processor @block pop;

  processor compilable [
    varOnFalse: onFalse VarCode "the branch \"onFalse\" is not a [CODE]:" checkedVar;
    varOnTrue: onTrue VarCode "the branch \"onTrue\" is not a [CODE]:" checkedVar;
    varCond: determiner VarCond "the branch determiner is not a Cond:" checkedVar;

    processor compilable [
      determiner staticityOfVar Weak > [
        value: VarCond varCond.data.get.end copy;
        value [
          VarCode varOnTrue.data.get.index "staticOnTrue" makeStringView @processor @block processCall
        ] [
          VarCode varOnFalse.data.get.index "staticOnFalse" makeStringView @processor @block processCall
        ] if
      ] [
        determiner @processor @block makeVarRealCaptured

        determiner
        VarCode varOnFalse.data.get.index
        VarCode varOnTrue.data.get.index
        @processor @block processIf
      ] if
    ] when
  ] when
] "mplBuiltinIf" @declareBuiltin ucall

[
  (
    [processor compilable]
    [block.parent 0 = ~ ["can't import item into non-global scope" @processor block compilerError] when]
    [refToName: @processor @block pop;]
    [varName: refToName VarString "the right-hand argument \"name\" is not a static string:" checkedVar;]
    [refToName staticityOfVar Weak < ["the right-hand argument \"name\" is not static" @processor block compilerError] when]
    [signature: parseSignature;]
    [newBlockId: signature VarString varName.data.get makeStringView FALSE dynamic @processor @block processImportFunction;]
  ) sequence
] "mplBuiltinImportFunction" @declareBuiltin ucall

[
  block.parent 0 = ~ ["can't import item into non-global scope" @processor block compilerError] when
  processor compilable [
    refToName: @processor @block pop;
    refToType: @processor @block pop;
    processor compilable [
      varName: refToName VarString "the right-hand argument \"name\" is not a static string:" checkedVar;
      processor compilable [
        refToName staticityOfVar Weak < ["the right-hand argument \"name\" is not static" @processor block compilerError] when
        processor compilable [
          varType: refToType getVar;
          refToType isVirtual [
            refToType [getVar.data.getTag VarCode = ~] "can't import [CODE]; for the (all) purposes, you can use either the built-in importFunction or codeRef; the code is:" checkVarBy
            processor compilable [refToType "can't import virtual item:" illegalRef] when
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
        @refToVar1 makeVarPtrCaptured
        @refToVar2 makeVarPtrCaptured
        result: FALSE makeValuePair VarCond @processor @block createVariable Dynamic @processor @block makeStaticity @processor @block createAllocIR;
        refToVar1 refToVar2 result "icmp eq" @processor @block createDirectBinaryOperation
        result @block push
      ] [
        cmpResult 1 = makeValuePair VarCond @processor @block createVariable Static @processor @block makeStaticity @processor @block createPlainIR @block push
      ] if
    ] [
      ("schema mismatch - the left-hand argument is <" refToVar1 @processor block getMplType ">" ", the right-hand argument is <" refToVar2 @processor block getMplType ">") assembleString @processor block compilerError
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
    [varBody: body VarCode "the argument is not a [CODE]:" checkedVar;]
    [
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
  VarNat8 VarIntX 1 + [a2:; a1:; a2 isNat ["urem" makeStringView] ["srem" makeStringView] if] [mod] [copy] [
    y:; x:;
    y y - y = [("division by zero; dividend: " x) assembleString @processor block compilerError] when
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
      refToVar "can't move immutable item; the argument is:" illegalRef
    ] if
  ] when
] "mplBuiltinMove" @declareBuiltin ucall

[
  refToCond: @processor @block pop;

  (
    [processor compilable]
    [condVar: refToCond VarCond "the right-hand argument \"determiner\" is not a static Cond:" checkedVar;]
    [refToCond staticityOfVar Dynamic > ~ ["the right-hand argument \"determiner\" is not static" @processor block compilerError] when]
    [refToVar: @processor @block pop;]
    [
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
          refToVar "can't move immutable item; the left-hand argument is:" illegalRef
        ] if
      ] [
        refToVar @block push
      ] if
    ]
  ) sequence
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
      refToVar "can't create instance of string/non-mpl function; the argument is:" illegalRef
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
  VarCond VarNatX 1 + [a2:; a1:; "or" makeStringView] [or] [copy] [y:; x:;] mplNumberBinaryOp
] "mplBuiltinOr" @declareBuiltin ucall

[
  refToStr: @processor @block pop;
  processor compilable [
    varStr: refToStr VarString "the argument is not a static string:" checkedVar;
    processor compilable [
      refToStr staticityOfVar Weak < ["the argument is not static" @processor block compilerError] when
      processor compilable [
        VarString varStr.data.get print LF print
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
  ("The shadow events of the block " block.id " in astNode " block.astArrayIndex ":" LF) printList
  block.buildingMatchingInfo.shadowEvents.size [
    event: i block.buildingMatchingInfo.shadowEvents.at;
    event i TRUE @processor @block printShadowEvent
  ] times
] "mplBuiltinPrintShadowEvents" @declareBuiltin ucall

[
  block.astArrayIndex @processor @block printAstArrayTree
] "mplBuiltinPrintMatchingTree" @declareBuiltin ucall

[
  debugMemory [
    ("compilerMaxAllocationSize=" getMemoryMetrics.memoryMaxAllocationSize LF) printList
  ] [
    ("compilerMaxAllocationSize is unknown, use -debugMemory flag" LF) printList
  ] uif
] "mplPrintCompilerMaxAllocationSize" @declareBuiltin ucall

[
  refToStr: @processor @block pop;
  processor compilable [
    varStr: refToStr VarString "the argument is not a static string:" checkedVar;
    processor compilable [
      refToStr staticityOfVar Weak < ["the argument is not static" @processor block compilerError] when
      processor compilable [
        VarString varStr.data.get @processor block compilerError
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
    [refToVar [isVirtual ~] "virtual item has no address; the argument is:" checkVarBy]
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
  refToStr: @processor @block pop;
  (
    [processor compilable]
    [varStr: refToStr VarString "argument is not a string:" checkedVar;]
    [
      refToStr staticityOfVar Weak < [
        result: 0n64 makeValuePair VarNatX @processor @block createVariable Dynamic @processor @block makeStaticity @processor @block createAllocIR;
        refToStr result @processor @block createGetTextSizeIR
        result @block push
      ] [
        string: VarString varStr.data.get;
        string.size 0i64 cast 0n64 cast makeValuePair VarNatX @processor @block createVariable Static @processor @block makeStaticity @processor @block createPlainIR @block push
      ] if
    ]
  ) sequence
] "mplBuiltinTextSize" @declareBuiltin ucall

[
  refToStr: @processor @block pop;
  processor compilable [
    varStr: refToStr VarString "the argument is not a static string:" checkedVar;
    processor compilable [
      refToStr staticityOfVar Weak < ["the argument is not static" @processor block compilerError] when
      processor compilable [
        string: VarString varStr.data.get;
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

            result: @struct move owner VarStruct @processor @block createVariable;
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
            "the string has invalid encoding" @processor block compilerError
          ] if
        ] when
      ] when
    ] when
  ] when
] "mplBuiltinTextSplit" @declareBuiltin ucall

[
  code: @processor @block pop;

  processor compilable [
    varCode: code VarCode "the argument is not a [CODE]:" checkedVar;

    processor compilable [
      astArrayIndex: VarCode varCode.data.get.index copy;
      block.countOfUCall 1 + @block.@countOfUCall set
      block.countOfUCall 65535 > ["the compiler-internal ucall limit exceeded" @processor block compilerError] when
      indexArray: astArrayIndex processor.multiParserResult.memory.at;
      indexArray @block addIndexArrayToProcess
    ] when
  ] when
] "mplBuiltinUcall" @declareBuiltin ucall

[
  onFalse: @processor @block pop;
  onTrue: @processor @block pop;
  condition: @processor @block pop;

  processor compilable [
    varOnTrue: onTrue VarCode "the branch \"onTrue\" is not a [CODE]:" checkedVar;
    varOnFalse: onFalse VarCode "the branch \"onFalse\" is not a [CODE]:" checkedVar;
    varCond: condition VarCond "the branch determiner is not a Cond:" checkedVar;

    processor compilable [
      condition staticityOfVar Weak > [
        value: VarCond varCond.data.get.end copy;
        code: value [VarCode varOnTrue.data.get] [VarCode varOnFalse.data.get] if;
        astArrayIndex: code.index;
        block.countOfUCall 1 + @block.@countOfUCall set
        block.countOfUCall 65535 > ["the compiler-internal ucall limit exceeded" @processor block compilerError] when
        indexArray: astArrayIndex processor.multiParserResult.memory.at;
        indexArray @block addIndexArrayToProcess
      ] [
        "the branch determiner is not static" @processor block compilerError
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
        @fullFileName move @result.@fullFileName set
        FindInPathResult.COMPILED_FILE @result.!success
      ] [
        @fullFileName move @result.@fullFileName set
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
        @fullFileName move @result.@fullFileName set
        FindInPathResult.UNCOMPILED_FILE @result.!success
      ] [
        errorInfo @processor @block compilerError
        @fullFileName move @result.@fullFileName set
        FindInPathResult.FILE_WITH_ERROR @result.!success
      ] if
    ] [
      findInCmd: moduleName processor.cmdFileNameIds.find;
      findInCmd.success [
        findInCmd.value copy checkLoadedFile ~ [
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
    [varName: refToName VarString "the argument is not a static string:" checkedVar;]
    [refToName staticityOfVar Weak < ["the argument is not static" @processor block compilerError] when]
    [
      string: VarString varName.data.get;
      fileName: string stripExtension;
      fileName "" = ["the filename is empty" @processor block compilerError] when
    ]
    [
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
            @processor.@result.@errorInfo move @processor.@result.@globalErrorInfo.pushBack
            -1 @processor.@result clearProcessorResult
          ] when
        ]
        FindInPathResult.FILE_WITH_ERROR [
          #we has error yet
        ]
        FindInPathResult.UNCOMPILED_FILE [
          TRUE dynamic @processor.@result.@findModuleFail set
          @findResult.@fullFileName move @processor.@result.@errorInfo.@missedModule set
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

                {refToVar: cnr.refToVar copy; nameInfo: label.nameInfo copy; } @addNameData.pushBack

                labelCount 1 + !labelCount
              ] when
            ] times

            addNameData.size [
              current: addNameData.size 1 - i - addNameData.at;

              {
                addNameCase: NameCaseFromModule;
                refToVar:    current.refToVar copy;
                nameInfo:    current.nameInfo copy;
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
                  fr.value.index copy fr.value.depth copy
                ] [
                  result: -1 file nameInfo @processor.@nameManager.findItem;
                  nameInfo {index: result copy; depth: 0;} @indexes.insert
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
              @processor.@result.@errorInfo move @processor.@result.@globalErrorInfo.pushBack
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
  block.nextLabelIsVirtual ["can't apply the virtual to the same item twice" @processor block compilerError] when
  TRUE @block.@nextLabelIsVirtual set
] "mplBuiltinVirtual" @declareBuiltin ucall

[
  block.nextLabelIsOverload ["can't apply the overload to the same item twice" @processor block compilerError] when
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
