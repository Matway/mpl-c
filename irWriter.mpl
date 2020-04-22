"String.String" use
"String.toString" use
"control.&&" use
"control.Nat8" use
"control.Natx" use
"control.assert" use
"control.isNil" use

"Block.Instruction" use
"Block.makeInstruction" use
"File.File" use
"Var.VarBuiltin" use

appendInstruction: [
  list: block:;;
  offset: block.programTemplate.getTextSize;
  list @block.@programTemplate.catMany
  block.programTemplate.getTextSize offset - offset makeInstruction @block.@program.pushBack
];

IRArgument: [{
  irTypeId: 0;
  irNameId: 0;
  byRef: TRUE;
}];

createDerefTo: [
  refToVar: derefNameId: block:;;;
  ("  " @derefNameId getNameById " = load " refToVar getIrType ", " refToVar getIrType "* " refToVar getIrName) @block appendInstruction
];

createDerefToRegister: [
  block:;
  derefName: @block generateRegisterIRName;
  derefName @block createDerefTo
  derefName
];

createAllocIR: [
  refToVar: block:;;
  var: @refToVar getVar;
  block.parent 0 = [
    (refToVar getIrName " = local_unnamed_addr global " refToVar getIrType " zeroinitializer") assembleString @processor.@prolog.pushBack
    processor.prolog.dataSize 1 - @var.@globalDeclarationInstructionIndex set
  ] [
    ("  " refToVar getIrName " = alloca " refToVar getIrType) @block appendInstruction
    TRUE @block.@program.last.@alloca set
    block.program.dataSize 1 - @var.@allocationInstructionIndex set
  ] if

  refToVar copy
];

createStaticInitIR: [
  refToVar: block:;;
  var: @refToVar getVar;
  [block.parent 0 =] "Can be used only with global vars!" assert
  (refToVar getIrName " = local_unnamed_addr global " refToVar getStaticStructIR) assembleString @processor.@prolog.pushBack
  processor.prolog.dataSize 1 - @var.@globalDeclarationInstructionIndex set
  refToVar copy
];

createVarImportIR: [
  refToVar:;

  var: @refToVar getVar;

  (refToVar getIrName " = external global " refToVar getIrType) assembleString @processor.@prolog.pushBack
  processor.prolog.dataSize 1 - @var.@globalDeclarationInstructionIndex set

  refToVar copy
];

createVarExportIR: [
  refToVar:;

  var: @refToVar getVar;

  (refToVar getIrName " = dllexport global " refToVar getIrType " zeroinitializer") assembleString @processor.@prolog.pushBack
  processor.prolog.dataSize 1 - @var.@globalDeclarationInstructionIndex set

  refToVar copy
];

createGlobalAliasIR: [
  alias: aliasee: aliaseeType:;;;
  (alias getNameById " = alias " aliaseeType getNameById ", " aliaseeType getNameById "* " aliasee getNameById) assembleString @processor.@prolog.pushBack
];

createStoreConstant: [
  refWithValue: refToDst: block:;;;
  s: refWithValue getPlainConstantIR;
  ("  store " refToDst getIrType " " s ", " refToDst getIrType "* " refToDst getIrName) @block appendInstruction
];

createPlainIR: [
  refToVar: block:;;
  [refToVar isPlain] "Var is not plain" assert
  refToVar @refToVar @block createAllocIR @block createStoreConstant
  refToVar copy
];

getStringImplementation: [
  stringView:;
  [
    result: String;
    i: 0 dynamic;
    [
      i stringView.size < [
        codeRef: stringView.data i Natx cast + Nat8 addressToReference;
        code: codeRef copy;
        code 32n8 < ~ [code 127n8 <] && [code 34n8 = ~] && [code 92n8 = ~] && [  # exclude " and \
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

createStringIR: [
  refToVar:;
  string:;
  stringId: processor.lastStringId copy;
  stringName: ("@string." processor.lastStringId) assembleString;

  processor.lastStringId 1 + @processor.@lastStringId set

  var: @refToVar getVar;
  @stringName findNameInfo @var.@mplNameId set
  ("getelementptr inbounds ({i32, [" string.size " x i8]}, {i32, [" string.size " x i8]}* " stringName ", i32 0, i32 1, i32 0)") assembleString makeStringId @var.@irNameId set

  valueImplementation: string getStringImplementation;

  (stringName " = private unnamed_addr constant {i32, [" string.size " x i8]} {i32 " string.size ", [" string.size " x i8] c\"" valueImplementation "\"}") assembleString @processor.@prolog.pushBack
];

createGetTextSizeIR: [
  refToName: refToDst: block:;;;
  int32PtrRegister:  block generateRegisterIRName;
  ptrRegister:       block generateRegisterIRName;
  int32SizeRegister: block generateRegisterIRName;
  int64SizeRegister: block generateRegisterIRName;

  ("  " int32PtrRegister getNameById " = bitcast i8* " refToName getIrName " to i32*") @block appendInstruction
  ("  " ptrRegister getNameById " = getelementptr i32, i32* " int32PtrRegister getNameById ", i32 -1") @block appendInstruction
  ("  " int32SizeRegister getNameById " = load i32, i32* " ptrRegister getNameById) @block appendInstruction

  processor.options.pointerSize 64nx = [
    ("  " int64SizeRegister getNameById " = zext i32 " int32SizeRegister getNameById " to i64") @block appendInstruction
    int64SizeRegister refToDst @block createStoreFromRegister
  ] [
    int32SizeRegister refToDst @block createStoreFromRegister
  ] if
];

createTypeDeclaration: [
  irType:;
  alias:;
  (@alias " = type " @irType) assembleString @processor.@prolog.pushBack
];

createStaticGEP: [
  resultRefToVar: index: structRefToVar: block:;;;;
  struct: structRefToVar getVar;
  realIndex: index VarStruct struct.data.get.get.realFieldIndexes.at;
  ("  " resultRefToVar getIrName " = getelementptr " structRefToVar getIrType ", " structRefToVar getIrType "* " structRefToVar getIrName ", i32 0, i32 " realIndex) @block appendInstruction
];

createFailWithMessage: [
  message: block:;;
  gnr: processor.failProcNameInfo @block File Ref getName;
  cnr: @gnr @block captureName;
  failProcRefToVar: cnr.refToVar copy;
  message toString @block makeVarString @block push

  failProcRefToVar getVar.data.getTag VarBuiltin = [
    #no overload
    defaultFailProc
  ] [
    @failProcRefToVar derefAndPush
    @block defaultCall
  ] if
];

createDynamicGEP: [
  resultRefToVar: indexRefToVar: structRefToVar: block:;;;;
  struct: structRefToVar getVar;
  indexRegister: indexRefToVar @block createDerefToRegister;
  processor.options.arrayChecks [
    structSize: VarStruct struct.data.get.get.fields.getSize; #in homogenius struct it is = realFieldIndex
    checkRegister: block generateRegisterIRName;

    ("  " checkRegister getNameById " = icmp ult i32 " indexRegister getNameById ", " structSize) @block appendInstruction
    ("  br i1 " checkRegister getNameById ", label %label" block.lastBrLabelName 1 + ", label %label" block.lastBrLabelName) @block appendInstruction

    @block createLabel
    "Index is out of bounds!" @block createFailWithMessage
    1 @block createJump
    @block createLabel
  ] when

  ("  " resultRefToVar getIrName " = getelementptr " structRefToVar getIrType ", " structRefToVar getIrType "* " structRefToVar  getIrName ", i32 0, i32 " indexRegister getNameById) @block appendInstruction
];

createGEPInsteadOfAlloc: [
  dstRef: index: struct: block:;;;;
  dstVar: @dstRef getVar;

  # create GEP instruction
  dstRef index struct @block createStaticGEP
  # change allocation instruction
  [dstVar.allocationInstructionIndex block.program.dataSize <] "Var is not allocated!" assert
  instruction: dstVar.allocationInstructionIndex @block.@program.at;
  block.program.last @instruction set
  FALSE @block.@program.last.@enabled set

  dstVar.allocationInstructionIndex @dstVar.@getInstructionIndex set
  -1 @dstVar.@allocationInstructionIndex set
];

createStoreFromRegister: [
  regName: destRefToVar: block:;;;
  resultVar: destRefToVar getVar;
  ("  store " destRefToVar getIrType " " @regName getNameById ", " destRefToVar getIrType "* " destRefToVar getIrName) @block appendInstruction
];

createBinaryOperation: [
  opName: block:;;
  var1p: arg1 @block createDerefToRegister;
  var2p: arg2 @block createDerefToRegister;
  resultReg: block generateRegisterIRName;
  ("  " resultReg getNameById " = " @opName " " arg1 getIrType " " var1p getNameById ", " var2p getNameById) @block appendInstruction
  resultReg result @block createStoreFromRegister
];

createBinaryOperationDiffTypes: [
  opName: block:;;
  var1p: arg1 @block createDerefToRegister;
  var2p: arg2 @block createDerefToRegister;
  castedReg: block generateRegisterIRName;
  castName: arg1 block getStorageSize arg2 block getStorageSize > [
    arg1 isNat ["zext"] ["sext"] if
  ] [
    "trunc"
  ] if;

  ("  " castedReg getNameById " = " castName " " arg2 getIrType " " var2p getNameById " to " arg1 getIrType) @block appendInstruction
  resultReg: block generateRegisterIRName;
  ("  " resultReg getNameById " = " opName " " arg1 getIrType " " var1p getNameById ", " castedReg getNameById) @block appendInstruction
  resultReg result @block createStoreFromRegister
];

createDirectBinaryOperation: [
  arg1: arg2: result: opName: block:;;;;;
  resultReg: block generateRegisterIRName;
  ("  " resultReg getNameById " = " opName " " arg1 getIrType "* " arg1 getIrName ", " arg2 getIrName) @block appendInstruction
  resultReg result @block createStoreFromRegister
];

createUnaryOperation: [
  opName: mopName: block:;;;
  varp: arg @block createDerefToRegister;
  resultReg: block generateRegisterIRName;
  ("  " resultReg getNameById " = " opName " " arg getIrType " " mopName varp getNameById) @block appendInstruction
  resultReg result @block createStoreFromRegister
];

createMemset: [
  srcRef: dstRef: block:;;;
  srcRef dstRef setVar
  srcRef isVirtual ~ [
    loadReg: srcRef @block createDerefToRegister;
    loadReg dstRef @block createStoreFromRegister
  ] when
];

createCheckedCopyToNewWith: [
  srcRef: dstRef: doDie: block:;; copy;;
  srcRef isAutoStruct [
    srcRef getVar.temporary [
      loadReg: srcRef @block createDerefToRegister;
      loadReg dstRef @block createStoreFromRegister
      @srcRef markAsUnableToDie
    ] [
      srcRef isForgotten [
        srcRef.mutable [
          loadReg: srcRef @block createDerefToRegister;
          loadReg dstRef @block createStoreFromRegister
          srcRef callInit
          @srcRef fullUntemporize
        ] [
          "movable variable is not mutable" block compilerError
        ] if
      ] [
        prevMut: dstRef.mutable;
        TRUE @dstRef.setMutable
        dstRef callInit
        srcRef dstRef callAssign
        prevMut @dstRef.setMutable
      ] if
    ] if
    doDie [dstRef @block.@candidatesToDie.pushBack] when
  ] [
    loadReg: srcRef @block createDerefToRegister;
    loadReg dstRef @block createStoreFromRegister
  ] if
];

createCheckedCopyToNew: [block:; TRUE dynamic @block createCheckedCopyToNewWith];
createCheckedCopyToNewNoDie: [block:; FALSE dynamic @block createCheckedCopyToNewWith];

createCopyToNew: [
  newRefToVar: block:;;
  newRefToVar isVirtual [
    oldRefToVar:;
    "unable to copy virtual autostruct" block compilerError
  ] [
    @newRefToVar @block createAllocIR @block createCheckedCopyToNew
  ] if
];

createCastCopyToNew: [
  srcRef: dstRef: castName: block:;;;;
  @dstRef @block createAllocIR !dstRef
  loadReg: srcRef @block createDerefToRegister;
  castedReg: block generateRegisterIRName;
  ("  " castedReg getNameById " = " @castName " " srcRef getIrType " " loadReg getNameById " to " dstRef getIrType) @block appendInstruction
  castedReg dstRef @block createStoreFromRegister
];

createCastCopyPtrToNew: [
  srcRef: dstRef: castName: block:;;;;
  @dstRef @block createAllocIR !dstRef
  castedReg: block generateRegisterIRName;
  ("  " castedReg getNameById " = " @castName " " srcRef getIrType "* " srcRef getIrName " to " dstRef getIrType) @block appendInstruction
  castedReg dstRef @block createStoreFromRegister
];

createCopyToExists: [
  srcRef: dstRef: block:;;;
  srcRef isAutoStruct [
    srcRef getVar.temporary [
      # die-bytemove is faster than assign-die, I think
      processor.options.verboseIR ["set from temporary" @block createComment] when
      dstRef callDie
      srcRef dstRef @block createMemset
      @srcRef markAsUnableToDie
    ] [
      srcRef isForgotten [
        processor.options.verboseIR ["set from moved" @block createComment] when
        dstRef callDie
        srcRef dstRef @block createMemset
        srcRef callInit
        @srcRef fullUntemporize
      ] [
        processor.options.verboseIR ["set; call ASSIGN" @block createComment] when
        srcRef isVirtual [
          "unable to copy virtual autostruct" block compilerError
        ] [
          srcRef dstRef callAssign
        ] if
      ] if
    ] if
  ] [
    srcRef dstRef @block createMemset
  ] if
];

createRefOperation: [
  srcRef: dstRef: block:;;;
  @dstRef @block createAllocIR !dstRef
  srcRef getVar.irNameId dstRef @block createStoreFromRegister
];

createRetValue: [
  refToVar: block:;;
  getReg: refToVar @block createDerefToRegister;
  ("  ret " refToVar getIrType " " getReg getNameById) @block appendInstruction
];

createCallIR: [
  refToRet: argList: conventionName: funcName: block:;;;;;
  haveRet: refToRet.var isNil ~;
  retName: 0;

  processor.options.callTrace [@block createCallTraceProlog] when

  offset: block.programTemplate.getTextSize;

  haveRet [
    block generateRegisterIRName @retName set
    ("  " @retName getNameById " = call " conventionName refToRet getIrType " ") @block.@programTemplate.catMany
  ] [
    ("  call " conventionName "void ") @block.@programTemplate.catMany
  ] if

  @funcName @block.@programTemplate.cat
  "(" @block.@programTemplate.cat

  i: 0 dynamic;
  [
    i argList.dataSize < [
      currentArg: i argList.at;
      i 0 > [", "  @block.@programTemplate.cat] when
      currentArg.irTypeId getNameById @block.@programTemplate.cat
      currentArg.byRef ["*" @block.@programTemplate.cat] when
      " " @block.@programTemplate.cat
      currentArg.irNameId getNameById @block.@programTemplate.cat

      i 1 + @i set TRUE
    ] &&
  ] loop

  ")" @block.@programTemplate.cat

  block.programTemplate.getTextSize offset - offset makeInstruction @block.@program.pushBack

  @block addDebugLocationForLastInstruction

  processor.options.callTrace [@block createCallTraceEpilog] when

  retName
];

createLabel: [
  block:;
  ("label" block.lastBrLabelName ":") @block appendInstruction
  block.lastBrLabelName 1 + @block.@lastBrLabelName set
];

createBranch: [
  timeShift: refToCond: block:;;;
  condReg: refToCond @block createDerefToRegister;
  ("  br i1 " condReg getNameById ", label %label" block.lastBrLabelName timeShift - ", label %label" block.lastBrLabelName timeShift - 1 +) @block appendInstruction
];

createJump: [
  timeShift: block:;;
  ("  br label %label" block.lastBrLabelName timeShift - 1 +) @block appendInstruction
];

createPhiNode: [
  varType: varName: thenName: elseName: shift: block:;;;;;;
  ("  " @varName " = phi " @varType " [ " @thenName ", %label" block.lastBrLabelName 3 - shift + " ], [ " @elseName ", %label" block.lastBrLabelName 2 - shift + " ]") @block appendInstruction
];

createComment: [
  comment: block:;;
  (" ;" comment) @block appendInstruction
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
    cur: processor.blocks.at.get.irName copy;
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
    cur: processor.blocks.at.get.irName copy;
    ("  call void " cur "()") assembleString addStrToProlog
  ] each
  "  ret void" addStrToProlog
  "}" addStrToProlog
];

sortInstructions: [
  block:;
  allocs:             Instruction Array;
  fakePointersAllocs: Instruction Array;
  fakePointers:       Instruction Array;
  noallocs:           Instruction Array;
  block.program.getSize [
    program: i @block.@program.at;
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

  @block.@program.clear
  @allocs             [move @block.@program.pushBack] each
  @fakePointersAllocs [move @block.@program.pushBack] each
  @fakePointers       [move @block.@program.pushBack] each
  @noallocs           [move @block.@program.pushBack] each
];

addAliasesForUsedNodes: [
  String @processor.@prolog.pushBack
  "; Func aliases" toString @processor.@prolog.pushBack
  @processor.@blocks [
    block0: .get;
    block0 nodeHasCode [
      @block0.@aliases [move @processor.@prolog.pushBack] each
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
  block:;
  ptr: block generateRegisterIRName;
  ptrNext: block generateRegisterIRName;

  ("  " ptr getNameById " = load %type.callTraceInfo*, %type.callTraceInfo** @debug.callTracePtr") @block appendInstruction
  ("  " ptrNext getNameById " = getelementptr inbounds %type.callTraceInfo, %type.callTraceInfo* " ptr getNameById ", i32 1") @block appendInstruction
  ("  store %type.callTraceInfo* " ptrNext getNameById ", %type.callTraceInfo** @debug.callTracePtr") @block appendInstruction

  block.hasNestedCall ~ [
    #ptr->next = ptrNext
    ptrDotNext: block generateRegisterIRName;
    ("  " ptrDotNext getNameById " = getelementptr inbounds %type.callTraceInfo, %type.callTraceInfo* " ptr getNameById ", i32 0, i32 1") @block appendInstruction
    ("  store %type.callTraceInfo* " ptrNext getNameById ", %type.callTraceInfo** " ptrDotNext getNameById) @block appendInstruction

    #ptrNext->prev = ptr
    ptrNextDotPrev: block generateRegisterIRName;
    ("  " ptrNextDotPrev getNameById " = getelementptr inbounds %type.callTraceInfo, %type.callTraceInfo* " ptrNext getNameById ", i32 0, i32 0") @block appendInstruction
    ("  store %type.callTraceInfo* " ptr getNameById ", %type.callTraceInfo** " ptrNextDotPrev getNameById) @block appendInstruction

    #ptrNext->fileName = fileName
    fileNameVar: block.position.file.name @block makeVarString;
    ptrNextDotName: block generateRegisterIRName;
    ("  " ptrNextDotName getNameById " = getelementptr inbounds %type.callTraceInfo, %type.callTraceInfo* " ptrNext getNameById ", i32 0, i32 2") @block appendInstruction
    ("  store i8* " fileNameVar getIrName ", i8** " ptrNextDotName getNameById) @block appendInstruction

    TRUE @block.@hasNestedCall set
  ] when

  #ptrNext->line = line
  ptrNextDotLine: block generateRegisterIRName;
  ("  " ptrNextDotLine getNameById " = getelementptr inbounds %type.callTraceInfo, %type.callTraceInfo* " ptrNext getNameById ", i32 0, i32 3") @block appendInstruction
  ("  store i32 " block.position.line ", i32* " ptrNextDotLine getNameById) @block appendInstruction

  #ptrNext->column = column
  ptrNextDotColumn: block generateRegisterIRName;
  ("  " ptrNextDotColumn getNameById " = getelementptr inbounds %type.callTraceInfo, %type.callTraceInfo* " ptrNext getNameById ", i32 0, i32 4") @block appendInstruction
  ("  store i32 " block.position.column ", i32* " ptrNextDotColumn getNameById) @block appendInstruction
];

createCallTraceEpilog: [
  block:;
  ptr: block generateRegisterIRName;
  ptrPrev: block generateRegisterIRName;
  ("  " ptr getNameById " = load %type.callTraceInfo*, %type.callTraceInfo** @debug.callTracePtr") @block appendInstruction
  ("  " ptrPrev getNameById " = getelementptr inbounds %type.callTraceInfo, %type.callTraceInfo* " ptr getNameById ", i32 -1") @block appendInstruction
  ("  store %type.callTraceInfo* " ptrPrev getNameById ", %type.callTraceInfo** @debug.callTracePtr") @block appendInstruction
];

createGetCallTrace: [
  infoIrType: variableIrType: variable: block:;;;;
  processor.options.callTrace [
    callTraceDataType: "[65536 x %type.callTraceInfo]" toString;

    ptrFirstSrc: block generateRegisterIRName;
    ptrFirstCast: block generateRegisterIRName;
    ptrFirstDst: block generateRegisterIRName;
    ("  " ptrFirstSrc getNameById " = getelementptr inbounds " callTraceDataType ", " callTraceDataType "* @debug.callTrace, i32 0, i32 0") @block appendInstruction
    ("  " ptrFirstDst getNameById " = getelementptr inbounds " variableIrType ", " variableIrType "* " variable getIrName ", i32 0, i32 0") @block appendInstruction
    ("  " ptrFirstCast getNameById " = bitcast %type.callTraceInfo* " ptrFirstSrc getNameById " to " infoIrType "*") @block appendInstruction
    ("  store " infoIrType "* " ptrFirstCast getNameById ", " infoIrType "** " ptrFirstDst getNameById) @block appendInstruction

    ptrLastSrc: block generateRegisterIRName;
    ptrLastCast: block generateRegisterIRName;
    ptrLastDst: block generateRegisterIRName;
    ("  " ptrLastSrc getNameById " = load %type.callTraceInfo*, %type.callTraceInfo** @debug.callTracePtr") @block appendInstruction
    ("  " ptrLastDst getNameById " = getelementptr inbounds " variableIrType ", " variableIrType "* " variable getIrName ", i32 0, i32 1") @block appendInstruction
    ("  " ptrLastCast getNameById " = bitcast %type.callTraceInfo* " ptrLastSrc getNameById " to " infoIrType "*") @block appendInstruction
    ("  store " infoIrType "* " ptrLastCast getNameById ", " infoIrType "** " ptrLastDst getNameById) @block appendInstruction
  ] [
    ptrFirstDst: block generateRegisterIRName;
    ("  " ptrFirstDst getNameById " = getelementptr inbounds " variableIrType ", " variableIrType "* " variable getIrName ", i32 0, i32 0") @block appendInstruction
    ("  store " infoIrType "* null, " infoIrType "** " ptrFirstDst getNameById) @block appendInstruction

    ptrLastDst: block generateRegisterIRName;
    ("  " ptrLastDst getNameById " = getelementptr inbounds " variableIrType ", " variableIrType "* " variable getIrName ", i32 0, i32 1") @block appendInstruction
    ("  store " infoIrType "* null, " infoIrType "** " ptrLastDst getNameById) @block appendInstruction
  ] if
];
