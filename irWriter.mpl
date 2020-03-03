"irWriter" module

"control" includeModule
"defaultImpl" includeModule

IRArgument: [{
  irTypeId: 0;
  irNameId: 0;
  byRef: TRUE;
}];

createDerefTo: [
  derefNameId:;
  refToVar:;
  ("  " @derefNameId getNameById " = load " refToVar getIrType ", " refToVar getIrType "* " refToVar getIrName) assembleString makeInstruction @currentNode.@program.pushBack
];

createDerefToRegister: [
  derefName: generateRegisterIRName;
  derefName createDerefTo
  derefName
];

createAllocIR: [
  refToVar:;
  var: refToVar getVar;

  currentNode.parent 0 = [
    (refToVar getIrName " = local_unnamed_addr global " refToVar getIrType " zeroinitializer") assembleString @processor.@prolog.pushBack
    processor.prolog.dataSize 1 - @var.@globalDeclarationInstructionIndex set
  ] [
    ("  " refToVar getIrName " = alloca " refToVar getIrType) assembleString makeInstruction @currentNode.@program.pushBack
    TRUE @currentNode.@program.last.@alloca set
    currentNode.program.dataSize 1 - @var.@allocationInstructionIndex set
  ] if

  refToVar copy
];

createStaticInitIR: [
  refToVar:;
  var: refToVar getVar;
  [currentNode.parent 0 =] "Can be used only with global vars!" assert
  (refToVar getIrName " = local_unnamed_addr global " refToVar getStaticStructIR) assembleString @processor.@prolog.pushBack
  processor.prolog.dataSize 1 - @var.@globalDeclarationInstructionIndex set
  refToVar copy
];

createVarImportIR: [
  refToVar:;

  var: refToVar getVar;

  (refToVar getIrName " = external global " refToVar getIrType) assembleString @processor.@prolog.pushBack
  processor.prolog.dataSize 1 - @var.@globalDeclarationInstructionIndex set

  refToVar copy
];

createVarExportIR: [
  refToVar:;

  var: refToVar getVar;

  (refToVar getIrName " = dllexport global " refToVar getIrType " zeroinitializer") assembleString @processor.@prolog.pushBack
  processor.prolog.dataSize 1 - @var.@globalDeclarationInstructionIndex set

  refToVar copy
];

createGlobalAliasIR: [
  aliaseeType:;
  aliasee:;
  alias:;
  (alias getNameById " = alias " aliaseeType getNameById ", " aliaseeType getNameById "* " aliasee getNameById) assembleString @processor.@prolog.pushBack
];

createStoreConstant: [
  refToDst:;
  refWithValue:;

  s: refWithValue getPlainConstantIR;
  ("  store " refToDst getIrType " " s ", " refToDst getIrType "* " refToDst getIrName) assembleString makeInstruction @currentNode.@program.pushBack
];

createPlainIR: [
  refToVar:;
  [refToVar isPlain] "Var is not plain" assert
  refToVar refToVar createAllocIR createStoreConstant
  refToVar copy
];

getStringImplementation: [
  stringView: makeStringView;
  [
    result: String;
    i: 0 dynamic;
    [
      i stringView.dataSize < [
        codeRef: stringView.dataBegin storageAddress i Natx cast + Nat8 addressToReference;
        code: codeRef copy;
        code 32n8 < not [code 127n8 <] && [code 34n8 = not] && [code 92n8 = not] && [  # exclude " and \
          code 0n32 cast @result.catSymbolCode
        ] [
          "\\" @result.cat
          code 16n8 < ["0"   @result.cat] when
          code @result.catHex
        ] if
        i 1 + @i set TRUE
      ] &&
    ] loop
    result
  ] call
];

createStringTypeByStringName: [
  stringName: makeStringView;
  stringNameNoFirst: stringName.getTextSize 1 - stringName.dataBegin storageAddress 1nx + Nat8 addressToReference makeStringViewRaw;
  ("%type." stringNameNoFirst) assembleString
];

createStringIR: [
  refToVar:;
  string:;

  stringId: processor.lastStringId copy;
  stringName: ("@string." processor.lastStringId) assembleString;
  stringType: stringName createStringTypeByStringName;

  processor.lastStringId 1 + @processor.@lastStringId set

  var: refToVar getVar;
  @stringName findNameInfo @var.@mplNameId set
  ("getelementptr inbounds (" stringType ", " stringType "* " stringName ", i32 0, i32 2, i32 0)") assembleString makeStringId @var.@irNameId set

  valueImplementation: string makeStringView getStringImplementation;

  stringSizeWithZero: string.chars.getSize 0 = [1][string.chars.getSize 0 cast] if;
  stringSize: stringSizeWithZero 1 -;
  stringSizeCheck: stringSize Nat32 cast 0xDEADBEEFn32 xor;

  (stringType " = type {i32, i32, [" stringSizeWithZero " x i8]}"
  ) assembleString @processor.@prolog.pushBack
  (stringName " = private unnamed_addr constant " stringType " {i32 " stringSizeCheck ", i32 " stringSize ", [" stringSizeWithZero " x i8] c\"" valueImplementation "\\00\"}"
  ) assembleString @processor.@prolog.pushBack
];

createGetTextSizeIR: [
  refToDst:;
  refToName:;
  int32PtrRegister:  generateRegisterIRName;
  ptrRegister:       generateRegisterIRName;
  int32SizeRegister: generateRegisterIRName;
  int64SizeRegister: generateRegisterIRName;

  ("  " int32PtrRegister getNameById " = bitcast i8* " refToName getIrName " to i32*") assembleString makeInstruction @currentNode.@program.pushBack
  ("  " ptrRegister getNameById " = getelementptr i32, i32* " int32PtrRegister getNameById ", i32 -1") assembleString makeInstruction @currentNode.@program.pushBack
  ("  " int32SizeRegister getNameById " = load i32, i32* " ptrRegister getNameById) assembleString makeInstruction @currentNode.@program.pushBack

  processor.options.pointerSize 64nx = [
    ("  " int64SizeRegister getNameById " = zext i32 " int32SizeRegister getNameById " to i64") assembleString makeInstruction @currentNode.@program.pushBack
    int64SizeRegister refToDst createStoreFromRegister
  ] [
    int32SizeRegister refToDst createStoreFromRegister
  ] if

  processor.options.debug [
    checkPtrRegister:       generateRegisterIRName;
    checkInt32SizeRegister: generateRegisterIRName;
    xorRegister:            generateRegisterIRName;
    checkRegister:          generateRegisterIRName;
    ("  " checkPtrRegister getNameById " = getelementptr i32, i32* " int32PtrRegister getNameById ", i32 -2") assembleString makeInstruction @currentNode.@program.pushBack
    ("  " checkInt32SizeRegister getNameById " = load i32, i32* " checkPtrRegister getNameById) assembleString makeInstruction @currentNode.@program.pushBack
    ("  " xorRegister getNameById " = xor i32 " checkInt32SizeRegister getNameById ", " int32SizeRegister getNameById) assembleString makeInstruction @currentNode.@program.pushBack
    ("  " checkRegister getNameById " = icmp eq i32 " xorRegister getNameById ", " 0xDEADBEEFn32) assembleString makeInstruction @currentNode.@program.pushBack
    ("  br i1 " checkRegister getNameById ", label %label" currentNode.lastBrLabelName 1 + ", label %label" currentNode.lastBrLabelName) assembleString makeInstruction @currentNode.@program.pushBack

    createLabel
    "Pointer is not a builtin Text!" createFailWithMessage
    1 createJump
    createLabel
  ] when
];

createTypeDeclaration: [
  irType:;
  alias:;
  (@alias " = type " @irType) assembleString @processor.@prolog.pushBack
];

createStaticGEP: [
  structRefToVar:;
  struct: structRefToVar getVar;
  copy index:;
  resultRefToVar:;

  realIndex: index VarStruct struct.data.get.get.realFieldIndexes.at;
  ("  " resultRefToVar getIrName " = getelementptr " structRefToVar getIrType ", " structRefToVar getIrType "* " structRefToVar getIrName ", i32 0, i32 " realIndex
  ) assembleString makeInstruction @currentNode.@program.pushBack
];

createFailWithMessage: [
  message:;

  gnr: processor.failProcNameInfo getName;
  cnr: gnr captureName;
  failProcRefToVar: cnr.refToVar copy;
  message toString makeVarString push

  failProcRefToVar getVar.data.getTag VarBuiltin = [
    #no overload
    defaultFailProc
  ] [
    failProcRefToVar derefAndPush
    defaultCall
  ] if
];

createDynamicGEP: [
  structRefToVar:;
  struct: structRefToVar getVar;
  indexRefToVar:;
  resultRefToVar:;

  indexRegister: indexRefToVar createDerefToRegister;

  processor.options.arrayChecks [
    structSize: VarStruct struct.data.get.get.fields.getSize; #in homogenius struct it is = realFieldIndex
    checkRegister: generateRegisterIRName;

    ("  " checkRegister getNameById " = icmp ult i32 " indexRegister getNameById ", " structSize) assembleString makeInstruction @currentNode.@program.pushBack
    ("  br i1 " checkRegister getNameById ", label %label" currentNode.lastBrLabelName 1 + ", label %label" currentNode.lastBrLabelName) assembleString makeInstruction @currentNode.@program.pushBack

    createLabel
    "Index is out of bounds!" createFailWithMessage
    1 createJump
    createLabel
  ] when

  ("  " resultRefToVar getIrName " = getelementptr " structRefToVar getIrType ", " structRefToVar getIrType "* " structRefToVar  getIrName ", i32 0, i32 " indexRegister getNameById
  ) assembleString makeInstruction @currentNode.@program.pushBack

];

createGEPInsteadOfAlloc: [
  struct:;
  copy index:;
  dstRef:;

  dstVar: dstRef getVar;

  # create GEP instruction
  dstRef index struct createStaticGEP
  # change allocation instruction
  [dstVar.allocationInstructionIndex currentNode.program.dataSize <] "Var is not allocated!" assert
  instruction: dstVar.allocationInstructionIndex @currentNode.@program.at;
  currentNode.program.last @instruction set
  FALSE @currentNode.@program.last.@enabled set

  dstVar.allocationInstructionIndex @dstVar.@getInstructionIndex set
  -1 @dstVar.@allocationInstructionIndex set
];

createStoreFromRegister: [
  destRefToVar:;
  regName:;

  resultVar: destRefToVar getVar;
  ("  store " destRefToVar getIrType " " @regName getNameById ", " destRefToVar getIrType "* " destRefToVar getIrName) assembleString makeInstruction @currentNode.@program.pushBack
];

createBinaryOperation: [
  opName:;

  var1p: arg1 createDerefToRegister;
  var2p: arg2 createDerefToRegister;
  resultReg: generateRegisterIRName;
  ("  " resultReg getNameById " = " @opName " " arg1 getIrType " " var1p getNameById ", " var2p getNameById) assembleString makeInstruction @currentNode.@program.pushBack
  resultReg result createStoreFromRegister
];

createBinaryOperationDiffTypes: [
  opName:;

  var1p: arg1 createDerefToRegister;
  var2p: arg2 createDerefToRegister;
  castedReg: generateRegisterIRName;

  castName: arg1 getStorageSize arg2 getStorageSize > [
    arg1 isNat ["zext" makeStringView]["sext" makeStringView] if
  ] [
    "trunc" makeStringView
  ] if;

  ("  " castedReg getNameById " = " castName " " arg2 getIrType " " var2p getNameById " to " arg1 getIrType) assembleString makeInstruction @currentNode.@program.pushBack
  resultReg: generateRegisterIRName;
  ("  " resultReg getNameById " = " opName " " arg1 getIrType " " var1p getNameById ", " castedReg getNameById) assembleString makeInstruction @currentNode.@program.pushBack
  resultReg result createStoreFromRegister
];

createDirectBinaryOperation: [
  opName:;
  result:;
  arg2:;
  arg1:;
  resultReg: generateRegisterIRName;
  ("  " resultReg getNameById " = " opName " " arg1 getIrType "* " arg1 getIrName ", " arg2 getIrName) assembleString makeInstruction @currentNode.@program.pushBack
  resultReg result createStoreFromRegister
];

createUnaryOperation: [
  mopName:;
  opName:;

  varp: arg createDerefToRegister;
  resultReg: generateRegisterIRName;
  ("  " resultReg getNameById " = " opName " " arg getIrType " " mopName varp getNameById) assembleString makeInstruction @currentNode.@program.pushBack
  resultReg result createStoreFromRegister
];

createMemset: [
  dstRef:;
  srcRef:;
  srcRef dstRef setVar
  srcRef isVirtual not [
    loadReg: srcRef createDerefToRegister;
    loadReg dstRef createStoreFromRegister
  ] when
];

createCheckedCopyToNewWith: [
  copy doDie:;
  copy dstRef:;
  srcRef:;


  srcRef isAutoStruct [
    srcRef getVar.temporary [
      loadReg: srcRef createDerefToRegister;
      loadReg dstRef createStoreFromRegister
      srcRef markAsUnableToDie
    ] [
      srcRef isForgotten [
        srcRef.mutable [
          loadReg: srcRef createDerefToRegister;
          loadReg dstRef createStoreFromRegister
          srcRef callInit
          srcRef fullUntemporize
        ] [
          "movable variable is not mutable" makeStringView compilerError
        ] if
      ] [
        prevMut: dstRef.mutable copy;
        TRUE @dstRef.@mutable set
        dstRef callInit
        srcRef dstRef callAssign
        prevMut @dstRef.@mutable set
      ] if
    ] if
    doDie [dstRef @currentNode.@candidatesToDie.pushBack] when
  ] [
    loadReg: srcRef createDerefToRegister;
    loadReg dstRef createStoreFromRegister
  ] if
];

createCheckedCopyToNew: [TRUE dynamic createCheckedCopyToNewWith];
createCheckedCopyToNewNoDie: [FALSE dynamic createCheckedCopyToNewWith];

createCopyToNew: [
  newRefToVar:;
  newRefToVar isVirtual [
    oldRefToVar:;
    "unable to copy virtual autostruct" compilerError
  ] [
    newRefToVar createAllocIR createCheckedCopyToNew
  ] if
];

createCastCopyToNew: [
  castName:;
  dstRef: createAllocIR;
  srcRef:;

  loadReg: srcRef createDerefToRegister;
  castedReg: generateRegisterIRName;
  ("  " castedReg getNameById " = " @castName " " srcRef getIrType " " loadReg getNameById " to " dstRef getIrType) assembleString makeInstruction @currentNode.@program.pushBack

  castedReg dstRef createStoreFromRegister
];

createCastCopyPtrToNew: [
  castName:;
  dstRef: createAllocIR;
  srcRef:;

  castedReg: generateRegisterIRName;
  ("  " castedReg getNameById " = " @castName " " srcRef getIrType "* " srcRef getIrName " to " dstRef getIrType) assembleString makeInstruction @currentNode.@program.pushBack

  castedReg dstRef createStoreFromRegister
];

createCopyToExists: [
  dstRef:;
  srcRef:;

  srcRef isAutoStruct [
    srcRef getVar.temporary [
      # die-bytemove is faster than assign-die, I think
      processor.options.verboseIR ["set from temporary" createComent] when
      dstRef callDie
      srcRef dstRef createMemset
      srcRef markAsUnableToDie
    ] [
      srcRef isForgotten [
        processor.options.verboseIR ["set from moved" createComent] when
        dstRef callDie
        srcRef dstRef createMemset
        srcRef callInit
        srcRef fullUntemporize
      ] [
        processor.options.verboseIR ["set; call ASSIGN" createComent] when
        srcRef isVirtual [
          "unable to copy virtual autostruct" compilerError
        ] [
          srcRef dstRef callAssign
        ] if
      ] if
    ] if
  ] [
    srcRef dstRef createMemset
  ] if
];

createRefOperation: [
  dstRef: createAllocIR;
  srcRef:;
  srcRef getVar.irNameId dstRef createStoreFromRegister
];

createRetValue: [
  refToVar:;
  getReg: refToVar createDerefToRegister;
  ("  ret " refToVar getIrType " " getReg getNameById) assembleString makeInstruction @currentNode.@program.pushBack
];

createCallIR: [
  funcName:;
  conventionName:;
  argList:;
  refToRet:;

  haveRet: refToRet.varId 0 < not;

  operation: String;
  retName: 0;

  processor.options.callTrace [createCallTraceProlog] when

  haveRet [
    generateRegisterIRName @retName set
    ("  " @retName getNameById " = call " conventionName refToRet getIrType " ") @operation.catMany
  ] [
    ("  call " conventionName "void ") @operation.catMany
  ] if

  @funcName @operation.cat
  "(" @operation.cat

  i: 0 dynamic;
  [
    i argList.dataSize < [
      currentArg: i argList.at;
      i 0 > [", "  @operation.cat] when
      currentArg.irTypeId getNameById @operation.cat
      currentArg.byRef ["*" @operation.cat] when
      " " @operation.cat
      currentArg.irNameId getNameById  @operation.cat

      i 1 + @i set TRUE
    ] &&
  ] loop

  ")" @operation.cat

  operation makeInstruction @currentNode.@program.pushBack
  addDebugLocationForLastInstruction

  processor.options.callTrace [createCallTraceEpilog] when

  retName
];

createLabel: [
  ("label" currentNode.lastBrLabelName ":") assembleString makeInstruction @currentNode.@program.pushBack
  currentNode.lastBrLabelName 1 + @currentNode.@lastBrLabelName set
];

createBranch: [
  refToCond:;
  copy timeShift:;

  condReg: refToCond createDerefToRegister;
  ("  br i1 " condReg getNameById ", label %label" currentNode.lastBrLabelName timeShift - ", label %label" currentNode.lastBrLabelName timeShift - 1 +
  ) assembleString makeInstruction @currentNode.@program.pushBack
];

createJump: [
  copy timeShift:;

  ("  br label %label" currentNode.lastBrLabelName timeShift - 1 +) assembleString makeInstruction @currentNode.@program.pushBack
];

createPhiNode: [
  copy shift:;
  elseName:;
  thenName:;
  varName:;
  varType:;

  ("  " @varName " = phi " @varType " [ " @thenName ", %label" currentNode.lastBrLabelName 3 - shift + " ], [ " @elseName ", %label" currentNode.lastBrLabelName 2 - shift + " ]"
  ) assembleString makeInstruction @currentNode.@program.pushBack
];

createComent: [
  coment: makeStringView;
  [
    compileOnce
    (" ;" coment) assembleString makeInstruction @currentNode.@program.pushBack
  ] call
];

addStrToProlog: [
  toString @processor.@prolog.pushBack
];

createFloatBuiltins: [
  "declare float @llvm.sin.f32(float)"           addStrToProlog
  "declare double @llvm.sin.f64(double)"         addStrToProlog
  "declare float @llvm.cos.f32(float)"           addStrToProlog
  "declare double @llvm.cos.f64(double)"         addStrToProlog
  "declare float @llvm.floor.f32(float)"         addStrToProlog
  "declare double @llvm.floor.f64(double)"       addStrToProlog
  "declare float @llvm.ceil.f32(float)"          addStrToProlog
  "declare double @llvm.ceil.f64(double)"        addStrToProlog
  "declare float @llvm.sqrt.f32(float)"          addStrToProlog
  "declare double @llvm.sqrt.f64(double)"        addStrToProlog
  "declare float @llvm.log.f32(float)"           addStrToProlog
  "declare double @llvm.log.f64(double)"         addStrToProlog
  "declare float @llvm.log10.f32(float)"         addStrToProlog
  "declare double @llvm.log10.f64(double)"       addStrToProlog
  "declare float @llvm.pow.f32(float, float)"    addStrToProlog
  "declare double @llvm.pow.f64(double, double)" addStrToProlog
];

createCtors: [
  copy createTlsInit:;

  "" addStrToProlog
  "@llvm.global_ctors = appending global [1 x { i32, void ()*, i8* }] [{ i32, void ()*, i8* } { i32 65535, void ()* @global.ctors, i8* null }]" addStrToProlog
  "" addStrToProlog
  "define internal void @global.ctors() {" addStrToProlog

  createTlsInit [
    "  call void @__tls_init()" toString addStrToProlog
  ] when

  processor.moduleFunctions [
    cur: processor.nodes.at.get.irName copy;
    ("  call void " cur "()") assembleString addStrToProlog
  ] each

  "  ret void" addStrToProlog
  "}" addStrToProlog
];

createDtors: [
  "" addStrToProlog
  "@llvm.global_dtors = appending global [1 x { i32, void ()*, i8* }] [{ i32, void ()*, i8* } { i32 65535, void ()* @global.dtors, i8* null }]" addStrToProlog
  "" addStrToProlog
  "define internal void @global.dtors() {" addStrToProlog
  processor.dtorFunctions [
    cur: processor.nodes.at.get.irName copy;
    ("  call void " cur "()") assembleString addStrToProlog
  ] each
  "  ret void" addStrToProlog
  "}" addStrToProlog
];

sortInstructions: [
  allocs:             Instruction Array;
  fakePointersAllocs: Instruction Array;
  fakePointers:       Instruction Array;
  noallocs:           Instruction Array;
  currentNode.program.getSize [
    program: i @currentNode.@program @;
    i 0 = [program.alloca copy] || [
      program.fakePointer [
        @program move @fakePointersAllocs.pushBack
      ] [
        @program move @allocs.pushBack
      ] if
    ] [
      program.fakePointer [
        @program move @fakePointers.pushBack
      ] [
        @program move @noallocs.pushBack
      ] if
    ] if
  ] times

  @currentNode.@program.clear
  @allocs             [move @currentNode.@program.pushBack] each
  @fakePointersAllocs [move @currentNode.@program.pushBack] each
  @fakePointers       [move @currentNode.@program.pushBack] each
  @noallocs           [move @currentNode.@program.pushBack] each
];

addAliasesForUsedNodes: [
  String @processor.@prolog.pushBack
  "; Func aliases" toString @processor.@prolog.pushBack
  @processor.@nodes [
    currentNode: .get;
    currentNode nodeHasCode [
      @currentNode.@aliases [move @processor.@prolog.pushBack] each
    ] when
  ] each
];

createCallTraceData: [
  tlPrefix: processor.options.threadModel 1 = ["thread_local "] [""] if;

  callTraceDataType: "[65536 x %type.callTraceInfo]" toString;
  "%type.callTraceInfo = type {%type.callTraceInfo*, %type.callTraceInfo*, i8*, i32, i32}" toString @processor.@prolog.pushBack
  ("@debug.callTrace = " tlPrefix "unnamed_addr global " callTraceDataType " zeroinitializer") assembleString @processor.@prolog.pushBack
  ("@debug.callTracePtr = " tlPrefix "unnamed_addr global %type.callTraceInfo* getelementptr inbounds (" callTraceDataType ", " callTraceDataType "* @debug.callTrace, i32 0, i32 0)") assembleString @processor.@prolog.pushBack

  processor.options.threadModel 1 = [
    String @processor.@prolog.pushBack
    "@\"__tls_init$initializer$\" = internal constant void ()* @__tls_init, section \".CRT$XDU\"" toString @processor.@prolog.pushBack
    "@llvm.used = appending global [1 x i8*] [i8* bitcast (void ()** @\"__tls_init$initializer$\" to i8*)], section \"llvm.metadata\"" toString @processor.@prolog.pushBack
    String @processor.@prolog.pushBack
    "define internal void @__tls_init() {" toString @processor.@prolog.pushBack
    ("  store %type.callTraceInfo* getelementptr inbounds (" callTraceDataType ", " callTraceDataType "* @debug.callTrace, i32 0, i32 0), %type.callTraceInfo** @debug.callTracePtr") assembleString @processor.@prolog.pushBack
    "  ret void" toString @processor.@prolog.pushBack
    "}" toString @processor.@prolog.pushBack
    String @processor.@prolog.pushBack

    processor.options.pointerSize 64nx = [
      "/include:__dyn_tls_init" toString @processor.@options.@linkerOptions.pushBack
    ] [
      "/include:___dyn_tls_init@12" toString @processor.@options.@linkerOptions.pushBack
    ] if
  ] when
];

createCallTraceProlog: [

  ptr: generateRegisterIRName;
  ptrNext: generateRegisterIRName;

  ("  " ptr getNameById " = load %type.callTraceInfo*, %type.callTraceInfo** @debug.callTracePtr") assembleString makeInstruction @currentNode.@program.pushBack
  ("  " ptrNext getNameById " = getelementptr inbounds %type.callTraceInfo, %type.callTraceInfo* " ptr getNameById ", i32 1") assembleString makeInstruction @currentNode.@program.pushBack
  ("  store %type.callTraceInfo* " ptrNext getNameById ", %type.callTraceInfo** @debug.callTracePtr") assembleString makeInstruction @currentNode.@program.pushBack

  currentNode.hasNestedCall not [
    #ptr->next = ptrNext
    ptrDotNext: generateRegisterIRName;
    ("  " ptrDotNext getNameById " = getelementptr inbounds %type.callTraceInfo, %type.callTraceInfo* " ptr getNameById ", i32 0, i32 1") assembleString makeInstruction @currentNode.@program.pushBack
    ("  store %type.callTraceInfo* " ptrNext getNameById ", %type.callTraceInfo** " ptrDotNext getNameById) assembleString makeInstruction @currentNode.@program.pushBack

    #ptrNext->prev = ptr
    ptrNextDotPrev: generateRegisterIRName;
    ("  " ptrNextDotPrev getNameById " = getelementptr inbounds %type.callTraceInfo, %type.callTraceInfo* " ptrNext getNameById ", i32 0, i32 0") assembleString makeInstruction @currentNode.@program.pushBack
    ("  store %type.callTraceInfo* " ptr getNameById ", %type.callTraceInfo** " ptrNextDotPrev getNameById) assembleString makeInstruction @currentNode.@program.pushBack

    #ptrNext->fileName = fileName
    fileNameVar: currentNode.position.fileNumber processor.options.fileNames.at makeVarString;
    ptrNextDotName: generateRegisterIRName;
    ("  " ptrNextDotName getNameById " = getelementptr inbounds %type.callTraceInfo, %type.callTraceInfo* " ptrNext getNameById ", i32 0, i32 2") assembleString makeInstruction @currentNode.@program.pushBack
    ("  store i8* " fileNameVar getIrName ", i8** " ptrNextDotName getNameById) assembleString makeInstruction @currentNode.@program.pushBack

    TRUE @currentNode.@hasNestedCall set
  ] when

  #ptrNext->line = line
  ptrNextDotLine: generateRegisterIRName;
  ("  " ptrNextDotLine getNameById " = getelementptr inbounds %type.callTraceInfo, %type.callTraceInfo* " ptrNext getNameById ", i32 0, i32 3") assembleString makeInstruction @currentNode.@program.pushBack
  ("  store i32 " currentNode.position.line ", i32* " ptrNextDotLine getNameById) assembleString makeInstruction @currentNode.@program.pushBack

  #ptrNext->column = column
  ptrNextDotColumn: generateRegisterIRName;
  ("  " ptrNextDotColumn getNameById " = getelementptr inbounds %type.callTraceInfo, %type.callTraceInfo* " ptrNext getNameById ", i32 0, i32 4") assembleString makeInstruction @currentNode.@program.pushBack
  ("  store i32 " currentNode.position.column ", i32* " ptrNextDotColumn getNameById) assembleString makeInstruction @currentNode.@program.pushBack
];

createCallTraceEpilog: [
  ptr: generateRegisterIRName;
  ptrPrev: generateRegisterIRName;

  ("  " ptr getNameById " = load %type.callTraceInfo*, %type.callTraceInfo** @debug.callTracePtr") assembleString makeInstruction @currentNode.@program.pushBack
  ("  " ptrPrev getNameById " = getelementptr inbounds %type.callTraceInfo, %type.callTraceInfo* " ptr getNameById ", i32 -1") assembleString makeInstruction @currentNode.@program.pushBack
  ("  store %type.callTraceInfo* " ptrPrev getNameById ", %type.callTraceInfo** @debug.callTracePtr") assembleString makeInstruction @currentNode.@program.pushBack
];

createGetCallTrace: [
  variable:;
  copy variableIrType:;
  copy infoIrType:;

  processor.options.callTrace [
    callTraceDataType: "[65536 x %type.callTraceInfo]" toString;

    ptrFirstSrc: generateRegisterIRName;
    ptrFirstCast: generateRegisterIRName;
    ptrFirstDst: generateRegisterIRName;
    ("  " ptrFirstSrc getNameById " = getelementptr inbounds " callTraceDataType ", " callTraceDataType "* @debug.callTrace, i32 0, i32 0") assembleString makeInstruction @currentNode.@program.pushBack
    ("  " ptrFirstDst getNameById " = getelementptr inbounds " variableIrType ", " variableIrType "* " variable getIrName ", i32 0, i32 0") assembleString makeInstruction @currentNode.@program.pushBack
    ("  " ptrFirstCast getNameById " = bitcast %type.callTraceInfo* " ptrFirstSrc getNameById " to " infoIrType "*") assembleString makeInstruction @currentNode.@program.pushBack
    ("  store " infoIrType "* " ptrFirstCast getNameById ", " infoIrType "** " ptrFirstDst getNameById) assembleString makeInstruction @currentNode.@program.pushBack

    ptrLastSrc: generateRegisterIRName;
    ptrLastCast: generateRegisterIRName;
    ptrLastDst: generateRegisterIRName;
    ("  " ptrLastSrc getNameById " = load %type.callTraceInfo*, %type.callTraceInfo** @debug.callTracePtr") assembleString makeInstruction @currentNode.@program.pushBack
    ("  " ptrLastDst getNameById " = getelementptr inbounds " variableIrType ", " variableIrType "* " variable getIrName ", i32 0, i32 1") assembleString makeInstruction @currentNode.@program.pushBack
    ("  " ptrLastCast getNameById " = bitcast %type.callTraceInfo* " ptrLastSrc getNameById " to " infoIrType "*") assembleString makeInstruction @currentNode.@program.pushBack
    ("  store " infoIrType "* " ptrLastCast getNameById ", " infoIrType "** " ptrLastDst getNameById) assembleString makeInstruction @currentNode.@program.pushBack
  ] [
    ptrFirstDst: generateRegisterIRName;
    ("  " ptrFirstDst getNameById " = getelementptr inbounds " variableIrType ", " variableIrType "* " variable getIrName ", i32 0, i32 0") assembleString makeInstruction @currentNode.@program.pushBack
    ("  store " infoIrType "* null, " infoIrType "** " ptrFirstDst getNameById) assembleString makeInstruction @currentNode.@program.pushBack

    ptrLastDst: generateRegisterIRName;
    ("  " ptrLastDst getNameById " = getelementptr inbounds " variableIrType ", " variableIrType "* " variable getIrName ", i32 0, i32 1") assembleString makeInstruction @currentNode.@program.pushBack
    ("  store " infoIrType "* null, " infoIrType "** " ptrLastDst getNameById) assembleString makeInstruction @currentNode.@program.pushBack
  ] if
];
