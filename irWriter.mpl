"Array.Array" use
"String.String" use
"String.StringView" use
"String.assembleString" use
"String.makeStringView" use
"String.print" use
"String.toString" use
"control" use
"conventions.cdecl" use

"Block.Block" use
"Block.Instruction" use
"Block.makeInstruction" use
"File.File" use
"Var.Dynamic" use
"Var.RefToVar" use
"Var.VarBuiltin" use
"Var.VarStruct" use
"Var.fullUntemporize" use
"Var.getPlainConstantIR" use
"Var.getStorageSize" use
"Var.getStringImplementation" use
"Var.getVar" use
"Var.isAutoStruct" use
"Var.isNat" use
"Var.isPlain" use
"Var.isVirtual" use
"Var.makeStringId" use
"Var.markAsUnableToDie" use
"Var.staticityOfVar" use
"Var.varIsMoved" use
"declarations.addDebugLocationForLastInstruction" use
"declarations.callAssign" use
"declarations.callDie" use
"declarations.callInit" use
"declarations.compilerError" use
"declarations.createFailWithMessage" use
"declarations.makeVarString" use
"declarations.setVar" use
"defaultImpl.findNameInfo" use
"defaultImpl.makeVarPtrCaptured" use
"defaultImpl.makeVarRealCaptured" use
"defaultImpl.nodeHasCode" use
"pathUtils.nameWithoutBadSymbols" use
"pathUtils.stripExtension" use
"processor.Processor" use

appendInstruction: [
  list: block:;;
  offset: block.programTemplate.size;
  list @block.@programTemplate.catMany
  block.programTemplate.size offset - offset makeInstruction @block.@program.pushBack
];

getMplSchema: [refToVar: processor: ;; refToVar getVar.mplSchemaId @processor.@schemaBuffer.at];
getNameById:  [index: processor: ;; index @processor.nameBuffer.at makeStringView];
getIrName:    [refToVar: processor: ;; refToVar getVar.irNameId                  @processor getNameById];
getIrType:    [refToVar: processor: ;; refToVar @processor getMplSchema.irTypeId @processor getNameById];

getStaticStructIR: [
  processor:;

  refToVar:;
  result: String;
  unfinishedVars: RefToVar Array;
  unfinishedTerminators: StringView Array;
  refToVar @unfinishedVars.pushBack
  ", " makeStringView @unfinishedTerminators.pushBack
  [
    unfinishedVars.getSize 0 > [
      current: unfinishedVars.last copy;
      @unfinishedVars.popBack

      current isVirtual [
        [FALSE] "Virtual field cannot be processed in static array constant!" assert
      ] [
        current isPlain [
          (current @processor getIrType " " current getPlainConstantIR) @result.catMany
          [
            currentTerminator: unfinishedTerminators.last;
            currentTerminator @result.cat
            currentTerminator ", " = ~
            @unfinishedTerminators.popBack
          ] loop
        ] [
          curVar: current getVar;
          curVar.data.getTag VarStruct = [
            (current @processor getIrType " ") @result.catMany
            struct: VarStruct curVar.data.get.get;
            struct.homogeneous ["[" makeStringView] ["{" makeStringView] if @result.cat
            first: TRUE dynamic;
            struct.fields.getSize [
              current: struct.fields.getSize 1 - i - struct.fields.at.refToVar;
              current isVirtual ~ [
                current @unfinishedVars.pushBack
                first [
                  struct.homogeneous ["]" makeStringView] ["}" makeStringView] if @unfinishedTerminators.pushBack
                  FALSE dynamic @first set
                ] [
                  ", " makeStringView @unfinishedTerminators.pushBack
                ] if
              ] when
            ] times
          ] [
            [FALSE] "Unknown type in static struct!" assert
          ] if
        ] if
      ] if

      TRUE
    ] &&
  ] loop

  result.size 2 - @result.@chars.shrink
  @result.makeZ
  result
];

createDerefWith: [
  refNameId: refTypeId: derefNameId: processor: block: ;;;;;
  ("  " @derefNameId @processor getNameById " = load " refTypeId @processor getNameById ", " refTypeId @processor getNameById "* " refNameId @processor getNameById) @block appendInstruction

  refNameId   @block.@program.last.@irName1 set
  derefNameId @block.@program.last.@irName2 set
];

createDerefTo: [
  refToVar: derefNameId: processor: block: ;;;;
  refToVar getVar.irNameId refToVar @processor getMplSchema.irTypeId derefNameId @processor @block createDerefWith
];

createDerefToRegister: [
  srcRef: processor: block: ;;;
  derefNameId: @processor @block generateRegisterIRName;
  srcRef getVar.irNameId srcRef @processor getMplSchema.irTypeId derefNameId @processor @block createDerefWith
  derefNameId
];

createDerefFromRegisterToRegister: [
  srcNameId: srcTypeId: processor: block: ;;;;
  derefNameId: @processor @block generateRegisterIRName;
  srcNameId srcTypeId derefNameId @processor @block createDerefWith
  derefNameId
];

createAllocIRByReg: [
  regNameId: regTypeId: processor: block: ;;;;
  ("  " regNameId @processor getNameById " = alloca " regTypeId @processor getNameById) @block appendInstruction
  TRUE @block.@program.last.@alloca set
];

createAllocIR: [
  refToVar: processor: block: ;;;
  var: @refToVar getVar;
  block.parent 0 = [
    (refToVar @processor getIrName " = local_unnamed_addr global " refToVar @processor getIrType " zeroinitializer") assembleString @processor.@prolog.pushBack
    processor.prolog.size 1 - @var.@globalDeclarationInstructionIndex set
  ] [
    refToVar getVar.irNameId refToVar @processor getMplSchema.irTypeId @processor @block createAllocIRByReg
    refToVar getVar.irNameId @block.@program.last.@irName1 set
    block.program.size 1 - @var.@allocationInstructionIndex set
  ] if


  refToVar copy
];

createStaticInitIR: [
  refToVar: processor: block: ;;;
  var: @refToVar getVar;
  [block.parent 0 =] "Can be used only with global vars!" assert
  (refToVar @processor getIrName " = local_unnamed_addr global " refToVar @processor getStaticStructIR) assembleString @processor.@prolog.pushBack
  processor.prolog.size 1 - @var.@globalDeclarationInstructionIndex set
  refToVar copy
];

createVarImportIR: [
  refToVar: processor: block: ;;;

  var: @refToVar getVar;

  (refToVar @processor getIrName " = external global " refToVar @processor getIrType) assembleString @processor.@prolog.pushBack
  processor.prolog.size 1 - @var.@globalDeclarationInstructionIndex set

  refToVar copy
];

createVarExportIR: [
  refToVar: processor: block: ;;;

  var: @refToVar getVar;

  (refToVar @processor getIrName " = dllexport global " refToVar @processor getIrType " zeroinitializer") assembleString @processor.@prolog.pushBack
  processor.prolog.size 1 - @var.@globalDeclarationInstructionIndex set

  refToVar copy
];

createGlobalAliasIR: [
  alias: aliasee: aliaseeType: processor: ;;;;
  (alias @processor getNameById " = alias " aliaseeType @processor getNameById ", " aliaseeType @processor getNameById "* " aliasee @processor getNameById) assembleString @processor.@prolog.pushBack
];

createStoreConstant: [
  refWithValue: refToDst: processor: block: ;;;;
  s: refWithValue getPlainConstantIR;
  ("  store " refToDst @processor getIrType " " s ", " refToDst @processor getIrType "* " refToDst @processor getIrName) @block appendInstruction
];

createPlainIR: [
  refToVar: processor: block: ;;;
  [refToVar isPlain] "Var is not plain" assert
  refToVar @refToVar @processor @block createAllocIR @processor @block createStoreConstant
  refToVar copy
];

createStringIR: [
  processor:;
  refToVar:;
  string:;
  stringId: processor.lastStringId copy;
  stringName: ("@string." processor.lastStringId) assembleString;

  processor.lastStringId 1 + @processor.@lastStringId set

  var: @refToVar getVar;
  stringName makeStringView @processor findNameInfo @var.@mplNameId set
  ("getelementptr inbounds ({i32, [" string.size " x i8]}, {i32, [" string.size " x i8]}* " stringName ", i32 0, i32 1, i32 0)") assembleString @processor makeStringId @var.@irNameId set

  valueImplementation: string getStringImplementation;

  (stringName " = private unnamed_addr constant {i32, [" string.size " x i8]} {i32 " string.size ", [" string.size " x i8] c\"" valueImplementation "\"}") assembleString @processor.@prolog.pushBack
];

createGetTextSizeIR: [
  refToName: refToDst: processor: block:;;;;
  int32PtrRegister:  @processor @block generateRegisterIRName;
  ptrRegister:       @processor @block generateRegisterIRName;
  int32SizeRegister: @processor @block generateRegisterIRName;
  int64SizeRegister: @processor @block generateRegisterIRName;

  ("  " int32PtrRegister @processor getNameById " = bitcast i8* " refToName @processor getIrName " to i32*") @block appendInstruction
  ("  " ptrRegister @processor getNameById " = getelementptr i32, i32* " int32PtrRegister @processor getNameById ", i32 -1") @block appendInstruction
  ("  " int32SizeRegister @processor getNameById " = load i32, i32* " ptrRegister @processor getNameById) @block appendInstruction

  processor.options.pointerSize 64nx = [
    ("  " int64SizeRegister @processor getNameById " = zext i32 " int32SizeRegister @processor getNameById " to i64") @block appendInstruction
    int64SizeRegister refToDst @processor @block createStoreFromRegister
  ] [
    int32SizeRegister refToDst @processor @block createStoreFromRegister
  ] if
];

createTypeDeclaration: [
  alias: irType: processor: ;;;
  (@alias " = type " @irType) assembleString @processor.@prolog.pushBack
];

createStaticGEP: [
  resultRefToVar: index: structRefToVar: processor: block:;;;;;
  struct: structRefToVar getVar;
  realIndex: index VarStruct struct.data.get.get.realFieldIndexes.at;
  ("  " resultRefToVar @processor getIrName " = getelementptr " structRefToVar @processor getIrType ", " structRefToVar @processor getIrType "* " structRefToVar @processor getIrName ", i32 0, i32 " realIndex) @block appendInstruction

  structRefToVar getVar.irNameId @block.@program.last.@irName1 set
  resultRefToVar getVar.irNameId @block.@program.last.@irName2 set
];

createDynamicGEP: [
  resultRefToVar: indexRefToVar: structRefToVar: processor: block:;;;;;
  struct: structRefToVar getVar;
  indexRegister: indexRefToVar @processor @block createDerefToRegister;
  processor.options.arrayChecks [
    structSize: VarStruct struct.data.get.get.fields.getSize; #in homogenius struct it is = realFieldIndex
    checkRegister: @processor @block generateRegisterIRName;

    ("  " checkRegister @processor getNameById " = icmp ult i32 " indexRegister @processor getNameById ", " structSize) @block appendInstruction
    ("  br i1 " checkRegister @processor getNameById ", label %label" block.lastBrLabelName 1 + ", label %label" block.lastBrLabelName) @block appendInstruction

    @block createLabel
    "Index is out of bounds!" @processor @block createFailWithMessage
    1 @block createJump
    @block createLabel
  ] when

  ("  " resultRefToVar @processor getIrName " = getelementptr " structRefToVar @processor getIrType ", " structRefToVar @processor getIrType "* " structRefToVar @processor getIrName ", i32 0, i32 " indexRegister @processor getNameById) @block appendInstruction
];

createGEPInsteadOfAlloc: [
  dstRef: index: struct: processor: block: ;;;;;
  dstVar: @dstRef getVar;

  # create GEP instruction
  dstRef index struct @processor @block createStaticGEP
  # change allocation instruction
  [dstVar.allocationInstructionIndex block.program.size <] "Var is not allocated!" assert
  instruction: dstVar.allocationInstructionIndex @block.@program.at;
  block.program.last @instruction set
  FALSE @block.@program.last.@enabled set

  dstVar.allocationInstructionIndex @dstVar.@getInstructionIndex set
  -1 @dstVar.@allocationInstructionIndex set
];

createStoreFromRegisterToRegister: [
  regName: destRegName: regType: processor: block: ;;;;;
  ("  store " regType @processor getNameById " " @regName @processor getNameById ", " regType @processor getNameById "* " destRegName @processor getNameById) @block appendInstruction

  regName     @block.@program.last.@irName1 set
  destRegName @block.@program.last.@irName2 set
];

createStoreFromRegister: [
  regName: destRefToVar: processor: block: ;;;;
  regName destRefToVar getVar.irNameId destRefToVar @processor getMplSchema.irTypeId @processor @block createStoreFromRegisterToRegister
];

getValueOrDeref: [
  refToVar:;
  refToVar staticityOfVar Dynamic > [
    refToVar getPlainConstantIR
  ] [
    @refToVar @processor @block makeVarRealCaptured
    refToVar @processor @block createDerefToRegister @processor getNameById toString
  ] if
];

createStringCompare: [
  arg1: arg2: result: opName: processor: block: ;;;;;;

  @arg1 @processor @block makeVarRealCaptured
  @arg2 @processor @block makeVarRealCaptured

  var1name: @arg1 @processor getIrName toString;
  var2name: @arg2 @processor getIrName toString;

  resultReg: @processor @block generateRegisterIRName;
  ("  " resultReg @processor getNameById " = " @opName " " arg1 @processor getIrType "* " var1name ", " var2name) @block appendInstruction
  resultReg result @processor @block createStoreFromRegister
];

createBinaryOperation: [
  arg1: arg2: result: opName: processor: block: ;;;;;;

  var1name: @arg1 getValueOrDeref;
  var2name: @arg2 getValueOrDeref;

  resultReg: @processor @block generateRegisterIRName;
  ("  " resultReg @processor getNameById " = " @opName " " arg1 @processor getIrType " " var1name ", " var2name) @block appendInstruction
  resultReg result @processor @block createStoreFromRegister
];

createBinaryOperationDiffTypes: [
  arg1: arg2: result: opName: processor: block: ;;;;;;

  var1name: @arg1 getValueOrDeref;
  var2name: @arg2 getValueOrDeref;

  castedReg: @processor @block generateRegisterIRName;
  castName: arg1 @processor getStorageSize arg2 @processor getStorageSize > [
    arg1 isNat ["zext"] ["sext"] if
  ] [
    "trunc"
  ] if;

  ("  " castedReg @processor getNameById " = " castName " " arg2 @processor getIrType " " var2name " to " arg1 @processor getIrType) @block appendInstruction
  resultReg: @processor @block generateRegisterIRName;
  ("  " resultReg @processor getNameById " = " opName " " arg1 @processor getIrType " " var1name ", " castedReg @processor getNameById) @block appendInstruction
  resultReg result @processor @block createStoreFromRegister
];

createDirectBinaryOperation: [
  arg1: arg2: result: opName: processor: block: ;;;;;;
  resultReg: @processor @block generateRegisterIRName;
  ("  " resultReg @processor getNameById " = " opName " " arg1 @processor getIrType "* " arg1 @processor getIrName ", " arg2 @processor getIrName) @block appendInstruction
  resultReg result @processor @block createStoreFromRegister
];

createUnaryOperation: [
  arg: result: opName: mopName: processor: block: ;;;;;;
  varp: arg @processor @block createDerefToRegister;
  resultReg: @processor @block generateRegisterIRName;
  ("  " resultReg @processor getNameById " = " opName " " arg @processor getIrType " " mopName varp @processor getNameById) @block appendInstruction
  resultReg result @processor @block createStoreFromRegister
];

createMemset: [
  srcRef: dstRef: processor: block: ;;;;
  srcRef dstRef @processor @block setVar
  srcRef isVirtual ~ [
    loadReg: srcRef @processor @block createDerefToRegister;
    loadReg dstRef @processor @block createStoreFromRegister
  ] when
];

createCheckedCopyToNewWith: [
  srcRef: dstRef: doDie: ;;;
  srcRef isAutoStruct [
    srcRef getVar.temporary [
      loadReg: srcRef @processor @block createDerefToRegister;
      loadReg dstRef @processor @block createStoreFromRegister
      @srcRef markAsUnableToDie
    ] [
      srcRef varIsMoved [
        srcRef.mutable [
          loadReg: srcRef @processor @block createDerefToRegister;
          loadReg dstRef @processor @block createStoreFromRegister
          srcRef @processor @block callInit
          @srcRef fullUntemporize
        ] [
          "movable variable is not mutable" @processor block compilerError
        ] if
      ] [
        prevMut: dstRef.mutable;
        prevMoved: dstRef.moved;
        prevTmp: dstRef getVar.temporary copy;
        TRUE @dstRef.setMutable
        @dstRef fullUntemporize

        dstRef @processor @block callInit
        srcRef dstRef @processor @block callAssign

        prevMut @dstRef.setMutable
        prevMoved @dstRef.setMoved
        prevTmp @dstRef getVar.@temporary set
      ] if
    ] if
    doDie [dstRef @block.@candidatesToDie.pushBack] when
  ] [
    loadReg: srcRef @processor @block createDerefToRegister;
    loadReg dstRef @processor @block createStoreFromRegister
  ] if
];

createCheckedCopyToNew:      [processor: block:;;  TRUE dynamic createCheckedCopyToNewWith];
createCheckedCopyToNewNoDie: [processor: block:;; FALSE dynamic createCheckedCopyToNewWith];

createCopyToNew: [
  newRefToVar: processor: block: ;;;
  newRefToVar isVirtual [
    oldRefToVar:;
    "unable to copy virtual autostruct" @processor block compilerError
  ] [
    @newRefToVar @processor @block createAllocIR @processor @block createCheckedCopyToNew
  ] if
];

createCastCopyToNew: [
  srcRef: dstRef: castName: processor: block: ;;;;;
  @dstRef @processor @block createAllocIR !dstRef
  loadReg: srcRef @processor @block createDerefToRegister;
  castedReg: @processor @block generateRegisterIRName;
  ("  " castedReg @processor getNameById " = " @castName " " srcRef @processor getIrType " " loadReg @processor getNameById " to " dstRef @processor getIrType) @block appendInstruction
  castedReg dstRef @processor @block createStoreFromRegister
];

createCastCopyPtrToNew: [
  srcRef: dstRef: castName: processor: block: ;;;;;
  @dstRef @processor @block createAllocIR !dstRef
  castedReg: @processor @block generateRegisterIRName;
  ("  " castedReg @processor getNameById " = " @castName " " srcRef @processor getIrType "* " srcRef @processor getIrName " to " dstRef @processor getIrType) @block appendInstruction
  castedReg dstRef @processor @block createStoreFromRegister
];

createRefOperation: [
  srcRef: dstRef: processor: block: ;;;;
  @dstRef @processor @block createAllocIR !dstRef
  srcRef getVar.irNameId dstRef @processor @block createStoreFromRegister
];

createRetValue: [
  refToVar: processor: block: ;;;
  getReg: refToVar @processor @block createDerefToRegister;
  ("  ret " refToVar @processor getIrType " " getReg @processor getNameById) @block appendInstruction
];

createCallIR: [
  refToRet: argList: conventionName: funcName: processor: block: ;;;;;;
  haveRet: refToRet.var isNil ~;
  retName: 0;

  processor.options.callTrace [@processor @block createCallTraceProlog] when

  offset: block.programTemplate.size;

  haveRet [
    @processor @block generateRegisterIRName @retName set
    ("  " @retName @processor getNameById " = call " conventionName refToRet @processor getIrType " ") @block.@programTemplate.catMany
  ] [
    ("  call " conventionName "void ") @block.@programTemplate.catMany
  ] if

  @funcName @block.@programTemplate.cat
  "(" @block.@programTemplate.cat

  i: 0 dynamic;
  [
    i argList.size < [
      currentArg: i argList.at;
      i 0 > [", "  @block.@programTemplate.cat] when
      currentArg.irTypeId @processor getNameById @block.@programTemplate.cat
      currentArg.byRef ["*" @block.@programTemplate.cat] when
      " " @block.@programTemplate.cat
      currentArg.irNameId @processor getNameById @block.@programTemplate.cat

      i 1 + @i set TRUE
    ] &&
  ] loop

  ")" @block.@programTemplate.cat

  block.programTemplate.size offset - offset makeInstruction @block.@program.pushBack

  @processor @block addDebugLocationForLastInstruction

  processor.options.callTrace [@processor @block createCallTraceEpilog] when

  retName
];

createLabel: [
  block:;
  ("label" block.lastBrLabelName ":") @block appendInstruction
  block.lastBrLabelName 1 + @block.@lastBrLabelName set
];

createBranch: [
  timeShift: refToCond: processor: block: ;;;;
  condReg: refToCond @processor @block createDerefToRegister;
  ("  br i1 " condReg @processor getNameById ", label %label" block.lastBrLabelName timeShift - ", label %label" block.lastBrLabelName timeShift - 1 +) @block appendInstruction
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
  what: processor: ;;
  what toString @processor.@prolog.pushBack
];

createFloatBuiltins: [
  processor:;

  "declare float @llvm.sin.f32(float)"           @processor addStrToProlog
  "declare double @llvm.sin.f64(double)"         @processor addStrToProlog
  "declare float @llvm.cos.f32(float)"           @processor addStrToProlog
  "declare double @llvm.cos.f64(double)"         @processor addStrToProlog
  "declare float @llvm.floor.f32(float)"         @processor addStrToProlog
  "declare double @llvm.floor.f64(double)"       @processor addStrToProlog
  "declare float @llvm.ceil.f32(float)"          @processor addStrToProlog
  "declare double @llvm.ceil.f64(double)"        @processor addStrToProlog
  "declare float @llvm.sqrt.f32(float)"          @processor addStrToProlog
  "declare double @llvm.sqrt.f64(double)"        @processor addStrToProlog
  "declare float @llvm.log.f32(float)"           @processor addStrToProlog
  "declare double @llvm.log.f64(double)"         @processor addStrToProlog
  "declare float @llvm.log10.f32(float)"         @processor addStrToProlog
  "declare double @llvm.log10.f64(double)"       @processor addStrToProlog
  "declare float @llvm.pow.f32(float, float)"    @processor addStrToProlog
  "declare double @llvm.pow.f64(double, double)" @processor addStrToProlog
];

createCtors: [
  createTlsInit: processor: ; copy;

  "" @processor addStrToProlog
  "@llvm.global_ctors = appending global [1 x { i32, void ()*, i8* }] [{ i32, void ()*, i8* } { i32 65535, void ()* @global.ctors, i8* null }]" @processor addStrToProlog
  "" @processor addStrToProlog
  "define internal void @global.ctors() {" @processor addStrToProlog

  createTlsInit [
    "  call void @__tls_init()" toString @processor addStrToProlog
  ] when

  processor.moduleFunctions [
    cur: processor.blocks.at.get.irName copy;
    ("  call void " cur "()") assembleString @processor addStrToProlog
  ] each

  "  ret void" @processor addStrToProlog
  "}" @processor addStrToProlog
];

createDtors: [
  processor:;

  "" @processor addStrToProlog
  "@llvm.global_dtors = appending global [1 x { i32, void ()*, i8* }] [{ i32, void ()*, i8* } { i32 65535, void ()* @global.dtors, i8* null }]" @processor addStrToProlog
  "" @processor addStrToProlog
  "define internal void @global.dtors() {" @processor addStrToProlog
  processor.dtorFunctions [
    cur: processor.blocks.at.get.irName copy;
    ("  call void " cur "()") assembleString @processor addStrToProlog
  ] each
  "  ret void" @processor addStrToProlog
  "}" @processor addStrToProlog
];

sortInstructions: [
  block: processor: ;;
  allocs:             Instruction Array;
  fakePointersAllocs: Instruction Array;
  fakePointers:       Instruction Array;
  noallocs:           Instruction Array;

  bannedIds: Int32 Array;

  block.program.getSize [
    current: i @block.@program.at;
    current.fakeAlloca [
      current.irName1 @bannedIds.pushBack
      FALSE @current.!enabled
    ] when
  ] times

  [
    bannedIds.getSize 0 > [
      bannedId: bannedIds.last copy;
      @bannedIds.popBack

      block.program.getSize [
        current: i @block.@program.at;
        current.enabled [
          current.irName1 bannedId = [
            current.irName2 0 < ~ [
              current.irName2 @bannedIds.pushBack
            ] when

            FALSE @current.!enabled
          ] when
        ] when
      ] times

      TRUE
    ] &&
  ] loop

  block.program.getSize [
    current: i @block.@program.at;
    i 0 = [current.alloca copy] || [
      current.fakePointer [
        @current move @fakePointersAllocs.pushBack
      ] [
        @current move @allocs.pushBack
      ] if
    ] [
      current.fakePointer [
        @current move @fakePointers.pushBack
      ] [
        @current move @noallocs.pushBack
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
  processor:;

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
  processor:;

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
  processor: block: ;;
  ptr: @processor @block generateRegisterIRName;
  ptrNext: @processor @block generateRegisterIRName;

  ("  " ptr @processor getNameById " = load %type.callTraceInfo*, %type.callTraceInfo** @debug.callTracePtr") @block appendInstruction
  ("  " ptrNext @processor getNameById " = getelementptr inbounds %type.callTraceInfo, %type.callTraceInfo* " ptr @processor getNameById ", i32 1") @block appendInstruction
  ("  store %type.callTraceInfo* " ptrNext @processor getNameById ", %type.callTraceInfo** @debug.callTracePtr") @block appendInstruction

  block.hasNestedCall ~ [
    #ptr->next = ptrNext
    ptrDotNext: @processor @block generateRegisterIRName;
    ("  " ptrDotNext @processor getNameById " = getelementptr inbounds %type.callTraceInfo, %type.callTraceInfo* " ptr @processor getNameById ", i32 0, i32 1") @block appendInstruction
    ("  store %type.callTraceInfo* " ptrNext @processor getNameById ", %type.callTraceInfo** " ptrDotNext @processor getNameById) @block appendInstruction

    #ptrNext->prev = ptr
    ptrNextDotPrev: @processor @block generateRegisterIRName;
    ("  " ptrNextDotPrev @processor getNameById " = getelementptr inbounds %type.callTraceInfo, %type.callTraceInfo* " ptrNext @processor getNameById ", i32 0, i32 0") @block appendInstruction
    ("  store %type.callTraceInfo* " ptr @processor getNameById ", %type.callTraceInfo** " ptrNextDotPrev @processor getNameById) @block appendInstruction

    #ptrNext->fileName = fileName
    fileNameVar: processor.positions.last.file.name @processor @block makeVarString;
    ptrNextDotName: @processor @block generateRegisterIRName;
    ("  " ptrNextDotName @processor getNameById " = getelementptr inbounds %type.callTraceInfo, %type.callTraceInfo* " ptrNext @processor getNameById ", i32 0, i32 2") @block appendInstruction
    ("  store i8* " fileNameVar @processor getIrName ", i8** " ptrNextDotName @processor getNameById) @block appendInstruction

    TRUE @block.@hasNestedCall set
  ] when

  #ptrNext->line = line
  ptrNextDotLine: @processor @block generateRegisterIRName;
  ("  " ptrNextDotLine @processor getNameById " = getelementptr inbounds %type.callTraceInfo, %type.callTraceInfo* " ptrNext @processor getNameById ", i32 0, i32 3") @block appendInstruction
  ("  store i32 " processor.positions.last.line ", i32* " ptrNextDotLine @processor getNameById) @block appendInstruction

  #ptrNext->column = column
  ptrNextDotColumn: @processor @block generateRegisterIRName;
  ("  " ptrNextDotColumn @processor getNameById " = getelementptr inbounds %type.callTraceInfo, %type.callTraceInfo* " ptrNext @processor getNameById ", i32 0, i32 4") @block appendInstruction
  ("  store i32 " processor.positions.last.column ", i32* " ptrNextDotColumn @processor getNameById) @block appendInstruction
];

createCallTraceEpilog: [
  processor: block:;;
  ptr:     @processor @block generateRegisterIRName;
  ptrPrev: @processor @block generateRegisterIRName;
  ("  " ptr @processor getNameById " = load %type.callTraceInfo*, %type.callTraceInfo** @debug.callTracePtr") @block appendInstruction
  ("  " ptrPrev @processor getNameById " = getelementptr inbounds %type.callTraceInfo, %type.callTraceInfo* " ptr @processor getNameById ", i32 -1") @block appendInstruction
  ("  store %type.callTraceInfo* " ptrPrev @processor getNameById ", %type.callTraceInfo** @debug.callTracePtr") @block appendInstruction
];

createGetCallTrace: [
  infoIrType: variableIrType: variable: processor: block: ;;;;;
  processor.options.callTrace [
    callTraceDataType: "[65536 x %type.callTraceInfo]" toString;

    ptrFirstSrc:  @processor @block generateRegisterIRName;
    ptrFirstCast: @processor @block generateRegisterIRName;
    ptrFirstDst:  @processor @block generateRegisterIRName;
    ("  " ptrFirstSrc @processor getNameById " = getelementptr inbounds " callTraceDataType ", " callTraceDataType "* @debug.callTrace, i32 0, i32 0") @block appendInstruction
    ("  " ptrFirstDst @processor getNameById " = getelementptr inbounds " variableIrType ", " variableIrType "* " variable @processor getIrName ", i32 0, i32 0") @block appendInstruction
    ("  " ptrFirstCast @processor getNameById " = bitcast %type.callTraceInfo* " ptrFirstSrc @processor getNameById " to " infoIrType "*") @block appendInstruction
    ("  store " infoIrType "* " ptrFirstCast @processor getNameById ", " infoIrType "** " ptrFirstDst @processor getNameById) @block appendInstruction

    ptrLastSrc:  @processor @block generateRegisterIRName;
    ptrLastCast: @processor @block generateRegisterIRName;
    ptrLastDst:  @processor @block generateRegisterIRName;
    ("  " ptrLastSrc @processor getNameById " = load %type.callTraceInfo*, %type.callTraceInfo** @debug.callTracePtr") @block appendInstruction
    ("  " ptrLastDst @processor getNameById " = getelementptr inbounds " variableIrType ", " variableIrType "* " variable @processor getIrName ", i32 0, i32 1") @block appendInstruction
    ("  " ptrLastCast @processor getNameById " = bitcast %type.callTraceInfo* " ptrLastSrc @processor getNameById " to " infoIrType "*") @block appendInstruction
    ("  store " infoIrType "* " ptrLastCast @processor getNameById ", " infoIrType "** " ptrLastDst @processor getNameById) @block appendInstruction
  ] [
    ptrFirstDst: @processor @block generateRegisterIRName;
    ("  " ptrFirstDst @processor getNameById " = getelementptr inbounds " variableIrType ", " variableIrType "* " variable @processor getIrName ", i32 0, i32 0") @block appendInstruction
    ("  store " infoIrType "* null, " infoIrType "** " ptrFirstDst @processor getNameById) @block appendInstruction

    ptrLastDst: @processor @block generateRegisterIRName;
    ("  " ptrLastDst @processor getNameById " = getelementptr inbounds " variableIrType ", " variableIrType "* " variable @processor getIrName ", i32 0, i32 1") @block appendInstruction
    ("  store " infoIrType "* null, " infoIrType "** " ptrLastDst @processor getNameById) @block appendInstruction
  ] if
];

# require captures "processor" and "codeNode"
generateVariableIRNameWith: [
  hostOfVariable: temporaryRegister: processor: block: ;;;;

  temporaryRegister ~ [block.parent 0 =] && [
    ("@global." processor.globalVarCount) assembleString @processor makeStringId
    processor.globalVarCount 1 + @processor.@globalVarCount set
  ] [
    ("%var." hostOfVariable.lastVarName) assembleString @processor makeStringId
    hostOfVariable.lastVarName 1 + @hostOfVariable.@lastVarName set
  ] if
];

generateRegisterIRName: [processor: block: ;; @block TRUE @processor block generateVariableIRNameWith];

{
  block: Block Ref;
  processor: Processor Ref;
  refToDst: RefToVar Ref;
  refToSrc: RefToVar Ref;
} () {} [
  srcRef: dstRef: processor: block: ;;;;
  srcRef isAutoStruct [
    @srcRef @processor @block makeVarRealCaptured
    @dstRef @processor @block makeVarRealCaptured
    @dstRef makeVarPtrCaptured

    srcRef getVar.temporary [
      # die-bytemove is faster than assign-die, I think
      processor.options.verboseIR ["set from temporary" @block createComment] when
      dstRef @processor @block callDie
      srcRef dstRef @processor @block createMemset
      @srcRef markAsUnableToDie
    ] [
      srcRef varIsMoved [
        processor.options.verboseIR ["set from moved" @block createComment] when
        dstRef @processor @block callDie
        srcRef dstRef @processor @block createMemset
        srcRef @processor @block callInit
        @srcRef fullUntemporize
      ] [
        processor.options.verboseIR ["set; call ASSIGN" @block createComment] when
        srcRef isVirtual [
          "unable to copy virtual autostruct" @processor block compilerError
        ] [
          srcRef dstRef @processor @block callAssign
        ] if
      ] if
    ] if
  ] [
    srcRef isPlain [
      srcRef staticityOfVar Dynamic > [
        srcRef dstRef @processor @block setVar
        @dstRef @processor @block makeVarRealCaptured
        @dstRef makeVarPtrCaptured
        dstRef dstRef @processor @block createStoreConstant
      ] [
        @srcRef @processor @block makeVarRealCaptured
        @dstRef @processor @block makeVarRealCaptured
        @dstRef makeVarPtrCaptured
        srcRef dstRef @processor @block createMemset
      ] if
    ] [
      @srcRef @processor @block makeVarRealCaptured
      @dstRef @processor @block makeVarRealCaptured
      @dstRef makeVarPtrCaptured
      srcRef dstRef @processor @block createMemset
    ] if
  ] if
] "createCopyToExists" exportFunction
