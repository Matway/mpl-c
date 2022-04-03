# Copyright (C) 2021 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"Array"       use
"String"      use
"algorithm"   use
"control"     use
"conventions" use

"Block"        use
"MplFile"      use
"Var"          use
"declarations" use
"defaultImpl"  use
"pathUtils"    use
"processor"    use

appendInstruction: [
  list: block:;;
  offset: block.programTemplate.size;
  list @block.@programTemplate.catMany
  block.programTemplate.size offset - offset makeInstruction @block.@program.append
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
  refToVar @unfinishedVars.append
  ", " makeStringView @unfinishedTerminators.append
  [
    unfinishedVars.getSize 0 > [
      current: unfinishedVars.last new;
      @unfinishedVars.popBack

      current isVirtual [
        "Virtual field cannot be processed in static array constant!" failProc
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
                current @unfinishedVars.append
                first [
                  struct.homogeneous ["]" makeStringView] ["}" makeStringView] if @unfinishedTerminators.append
                  FALSE dynamic @first set
                ] [
                  ", " makeStringView @unfinishedTerminators.append
                ] if
              ] when
            ] times
          ] [
            "Unknown type in static struct!" failProc
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
    processor.options.partial new [
      varBlock: block;
      [varBlock.file isNil ~] "Topnode in nil file!" assert
      varBlock.file.usedInParams ~
    ] && [
      "; global var from another file" toString @processor.@prolog.append
    ] [
      (refToVar @processor getIrName " = private local_unnamed_addr global " refToVar @processor getIrType " zeroinitializer") assembleString @processor.@prolog.append
    ] if

    processor.prolog.size 1 - @var.@globalDeclarationInstructionIndex set
  ] [
    refToVar getVar.irNameId refToVar @processor getMplSchema.irTypeId @processor @block createAllocIRByReg
    refToVar getVar.irNameId @block.@program.last.@irName1 set
    block.program.size 1 - @var.@allocationInstructionIndex set
  ] if

  refToVar new
];

createStaticInitIR: [
  refToVar: processor: block: ;;;
  var: @refToVar getVar;
  [block.parent 0 =] "Can be used only with global vars!" assert

  processor.options.partial new [
    varBlock: block;
    [varBlock.file isNil ~] "Topnode in nil file!" assert
    varBlock.file.usedInParams ~
  ] && [
    "; global var from another file" toString @processor.@prolog.append
  ] [
    (refToVar @processor getIrName " = private local_unnamed_addr global " refToVar @processor getStaticStructIR) assembleString @processor.@prolog.append
  ] if
  processor.prolog.size 1 - @var.@globalDeclarationInstructionIndex set
  refToVar new
];

createVarImportIR: [
  refToVar: processor: block: ;;;

  var: @refToVar getVar;

  (refToVar @processor getIrName " = external global " refToVar @processor getIrType) assembleString @processor.@prolog.append
  processor.prolog.size 1 - @var.@globalDeclarationInstructionIndex set

  refToVar new
];

createVarExportIR: [
  refToVar: processor: block: ;;;

  var: @refToVar getVar;

  (refToVar @processor getIrName " = dllexport global " refToVar @processor getIrType " zeroinitializer") assembleString @processor.@prolog.append
  processor.prolog.size 1 - @var.@globalDeclarationInstructionIndex set

  refToVar new
];

createGlobalAliasIR: [
  alias: aliasee: aliaseeType: processor: ;;;;
  (alias @processor getNameById " = alias " aliaseeType @processor getNameById ", " aliaseeType @processor getNameById "* " aliasee @processor getNameById) assembleString @processor.@prolog.append
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
  refToVar new
];

createStringIR: [
  processor:;
  refToVar:;
  string:;
  stringId: processor.lastStringId new;
  stringName: ("@string." processor.lastStringId) assembleString;

  processor.lastStringId 1 + @processor.@lastStringId set

  var: @refToVar getVar;
  stringName makeStringView @processor findNameInfo @var.@mplNameId set
  ("getelementptr inbounds ({i32, [" string.size " x i8]}, {i32, [" string.size " x i8]}* " stringName ", i32 0, i32 1, i32 0)") assembleString @processor makeStringId @var.@irNameId set

  valueImplementation: string getStringImplementation;

  (stringName " = private unnamed_addr constant {i32, [" string.size " x i8]} {i32 " string.size ", [" string.size " x i8] c\"" valueImplementation "\"}") assembleString @processor.@prolog.append
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
  (@alias " = type " @irType) assembleString @processor.@prolog.append
];

createStaticGEP: [
  resultRefToVar: index: structRefToVar: processor: block:;;;;;
  struct: structRefToVar getVar;
  realIndex: index VarStruct struct.data.get.get.realFieldIndexes.at;
  [realIndex 0 < ~] "Gep index must be non-negative!" assert
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
  regNameId: destRegNameId: regType: processor: block: ;;;;;
  ("  store " regType @processor getNameById " " @regNameId @processor getNameById ", " regType @processor getNameById "* " destRegNameId @processor getNameById) @block appendInstruction

  regNameId     @block.@program.last.@irName1 set
  destRegNameId @block.@program.last.@irName2 set
];

createStoreFromRegister: [
  regNameId: destRefToVar: processor: block: ;;;;
  regNameId destRefToVar getVar.irNameId destRefToVar @processor getMplSchema.irTypeId @processor @block createStoreFromRegisterToRegister
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
        prevTmp: dstRef getVar.temporary new;
        TRUE @dstRef.setMutable
        @dstRef fullUntemporize

        dstRef @processor @block callInit
        srcRef dstRef @processor @block callAssign

        prevMut @dstRef.setMutable
        prevMoved @dstRef.setMoved
        prevTmp @dstRef getVar.@temporary set
      ] if
    ] if
    doDie [dstRef @block.@candidatesToDie.append] when
  ] [
    srcRef isPlain [srcRef staticityOfVar Dynamic >] && [
      srcRef dstRef @processor @block createStoreConstant
    ] [
      @srcRef @processor @block makeVarRealCaptured
      loadReg: srcRef @processor @block createDerefToRegister;
      loadReg dstRef @processor @block createStoreFromRegister
    ] if

    @dstRef makeVarPtrCaptured
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
  refToRet: argList: conventionName: funcName: hasCallTrace: processor: block: ;;;;;;;
  haveRet: refToRet.var isNil ~;
  retName: 0;

  processor.options.hidePrefixes [processor.positions.last.file.name swap beginsWith ~] all [
    processor.options.callTrace hasCallTrace and [@processor @block createCallTraceProlog] when
  ] when

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

  block.programTemplate.size offset - offset makeInstruction @block.@program.append

  @processor @block addDebugLocationForLastInstruction

  processor.options.hidePrefixes [processor.positions.last.file.name swap beginsWith ~] all [
    processor.options.callTrace hasCallTrace and [@processor @block createCallTraceEpilog] when
  ] when

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
  what toString @processor.@prolog.append
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

getLLPriority: [
  processor:;

  priority: 0 dynamic;

  processor.moduleFunctions [
    currentBlock: processor.blocks.at.get;
    currentBlock.deleted ~ currentBlock.empty ~ and [
      currentBlock.globalPriority priority > [
        currentBlock.globalPriority @priority set
      ] when
    ] when
  ] each

  priority
];

createCheckers: [
  processor:;

  processor.files.getSize [
    i 1 > [
      currentFile:  i processor.files.at.get;
      currentName: currentFile.name stripExtension nameWithoutBadSymbols;
      processor.beginFuncIndex 0 < ~ [
        String @processor addStrToProlog
        ("define void @check." currentName "() { ret void }") assembleString @processor addStrToProlog
      ] [
        currentFile.usedInParams [
          String @processor addStrToProlog
          ("declare void @check." currentName "()") assembleString @processor addStrToProlog
          ("define void @check." currentName ".call() { call void @check." currentName "() ret void}") assembleString @processor addStrToProlog
        ] when
      ] if

      processor.options.partial [currentFile.usedInParams ~] && [
        String @processor addStrToProlog
        ("declare void @module." currentName ".ctor()") assembleString @processor addStrToProlog
      ] when
    ] when
  ] times
];

createDtors: [
  processor:;
  dtorByFile: Int32 Array Array;

  processor.files.getSize @dtorByFile.resize

  processor.dtorFunctions [
    blockId:;
    cur: blockId processor.blocks.at.get;
    processor.options.partial ~ [cur.file.usedInParams new] || [
      id: cur.file.fileId new;
      blockId id @dtorByFile.at.append
    ] when
  ] each

  processor.files.getSize [
    i 1 > [
      currentFile: i processor.files.at.get;
      currentName: currentFile.name stripExtension nameWithoutBadSymbols;
      String @processor addStrToProlog
      processor.options.partial ~ [currentFile.usedInParams new] || [
        ("define void @module." currentName ".dtor() {") assembleString @processor addStrToProlog
        i dtorByFile.at [
          cur: processor.blocks.at.get.irName new;
          ("  call void " cur "()") assembleString @processor addStrToProlog
        ] each
        "  ret void" @processor addStrToProlog
        "}" @processor addStrToProlog
      ] [
        ("declare void @module." currentName ".dtor()") assembleString @processor addStrToProlog
      ] if
    ] when
  ] times
];

addCtorsToBeginFunc: [
  processor:;

  processor.beginFuncIndex 0 < ~ [
    block: processor.beginFuncIndex @processor.@blocks.at.get;
    previousVersion: @block.@program new;
    @block.@program.clear

    0 @previousVersion.at @block.@program.append

    block.beginPosition @processor.@positions.append

    processor.moduleFunctions.getSize [
      i 0 > [ # skip definitions
        currentFunction: i processor.moduleFunctions.at processor.blocks.at.get;

        currentFile: currentFunction.file;
        currentName: currentFile.name stripExtension nameWithoutBadSymbols;
        ("  call void @module." currentName ".ctor()") @block appendInstruction

        processor.options.debug [
          @processor @block addDebugLocationForLastInstruction
        ] when
      ] when
    ] times

    previousVersion.getSize [
      i 0 >  [
        current: i @previousVersion.at;
        @current @block.@program.append
      ] when
    ] times

    @processor.@positions.popBack

    block.instructionCountBeforeRet previousVersion.size - block.program.size + @block.!instructionCountBeforeRet
  ] when
];

addDtorsToEndFunc: [
  processor:;

  processor.endFuncIndex 0 < ~ [
    block: processor.endFuncIndex @processor.@blocks.at.get;
    previousVersion: @block.@program new;
    @block.@program.clear

    block.beginPosition @processor.@positions.append

    previousVersion.getSize [
      i block.instructionCountBeforeRet < [
        current: i @previousVersion.at;
        @current @block.@program.append
      ] when
    ] times

    processor.moduleFunctions.getSize [
      i 0 > [ # skip definitions
        currentFunction: processor.moduleFunctions.getSize i - processor.moduleFunctions.at processor.blocks.at.get;

        currentFile: currentFunction.file;
        currentName: currentFile.name stripExtension nameWithoutBadSymbols;
        ("  call void @module." currentName ".dtor()") @block appendInstruction

        processor.options.debug [
          @processor @block addDebugLocationForLastInstruction
        ] when
      ] when
    ] times

    previousVersion.getSize block.instructionCountBeforeRet - [
      current: i block.instructionCountBeforeRet + @previousVersion.at;
      @current @block.@program.append
    ] times

    @processor.@positions.popBack
  ] when
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
      current.irName1 @bannedIds.append
      FALSE @current.!enabled
    ] when
  ] times

  [
    bannedIds.getSize 0 > [
      bannedId: bannedIds.last new;
      @bannedIds.popBack

      block.program.getSize [
        current: i @block.@program.at;
        current.enabled [
          current.irName1 bannedId = [
            current.irName2 0 < ~ [
              current.irName2 @bannedIds.append
            ] when

            FALSE @current.!enabled
          ] when

          current.irName2 bannedId = [
            FALSE @current.!enabled
          ] when
        ] when
      ] times

      TRUE
    ] &&
  ] loop

  block.program.getSize [
    current: i @block.@program.at;
    i 0 = [current.alloca new] || [
      current.fakePointer [
        @current @fakePointersAllocs.append
      ] [
        @current @allocs.append
      ] if
    ] [
      current.fakePointer [
        @current @fakePointers.append
      ] [
        @current @noallocs.append
      ] if
    ] if
  ] times

  @block.@program.clear
  @allocs             [@block.@program.append] each
  @fakePointersAllocs [@block.@program.append] each
  @fakePointers       [@block.@program.append] each
  @noallocs           [@block.@program.append] each
];

addAliasesForUsedNodes: [
  processor:;

  String @processor.@prolog.append
  "; Func aliases" toString @processor.@prolog.append
  @processor.@blocks [
    block0: .get;
    block0 nodeHasCode [
      @block0.@aliases [@processor.@prolog.append] each
    ] when
  ] each
];

checkBeginEndPoint: [
  processor:;
  result: TRUE;

  processor.beginFuncIndex 0 < processor.endFuncIndex 0 < and [
    # ok
  ] [
    processor.beginFuncIndex 0 < ~ processor.endFuncIndex 0 < ~ and [
      beginFuncFile: processor.beginFuncIndex processor.blocks.at.get.file;
      endFuncFile: processor.endFuncIndex processor.blocks.at.get.file;
      beginFuncFile endFuncFile is ~ [
        FALSE !result
      ] when
    ] [
      FALSE !result
    ] if
  ] if

  result ~ [
    ("beginFunc and endFunc must be in one module" LF) assembleString @processor.@result.@errorInfo.@message.cat
    FALSE @processor.@result.@success set
  ] when
];

createCallTraceData: [
  processor:;

  tlPrefix: processor.options.threadModel 1 = ["thread_local "] [""] if;

  "%type.callTraceInfo = type {%type.callTraceInfo*, i8*, i32, i32}" toString @processor.@prolog.append
  processor.beginFuncIndex 0 < ~ [
    ("@debug.callTracePtr = " tlPrefix "unnamed_addr global %type.callTraceInfo* null") assembleString @processor.@prolog.append
  ] [
    ("@debug.callTracePtr = external " tlPrefix "unnamed_addr global %type.callTraceInfo*") assembleString @processor.@prolog.append
  ] if
];

createCallTraceProlog: [
  processor: block: ;;

  ptrRegName: "%debug.oldCallTracePtr";
  ctRegName: "%debug.callTraceData";
  prevPtrRegName: "%debug.callTraceData.prev";
  namePtrRegName: "%debug.callTraceData.name";
  linePtrRegName: "%debug.callTraceData.line";
  colmPtrRegName: "%debug.callTraceData.column";

  block.hasNestedCall ~ [
    ("  " ctRegName " = alloca %type.callTraceInfo") @block appendInstruction
    TRUE @block.@program.last.@alloca set #fake for good sorting
    ("  " prevPtrRegName " = getelementptr inbounds %type.callTraceInfo, %type.callTraceInfo* " ctRegName ", i32 0, i32 0") @block appendInstruction
    TRUE @block.@program.last.@alloca set #fake for good sorting
    ("  " namePtrRegName " = getelementptr inbounds %type.callTraceInfo, %type.callTraceInfo* " ctRegName ", i32 0, i32 1") @block appendInstruction
    TRUE @block.@program.last.@alloca set #fake for good sorting
    ("  " linePtrRegName " = getelementptr inbounds %type.callTraceInfo, %type.callTraceInfo* " ctRegName ", i32 0, i32 2") @block appendInstruction
    TRUE @block.@program.last.@alloca set #fake for good sorting
    ("  " colmPtrRegName " = getelementptr inbounds %type.callTraceInfo, %type.callTraceInfo* " ctRegName ", i32 0, i32 3") @block appendInstruction
    TRUE @block.@program.last.@alloca set #fake for good sorting

    ("  " ptrRegName " = load %type.callTraceInfo*, %type.callTraceInfo** @debug.callTracePtr") @block appendInstruction
    TRUE @block.@program.last.@alloca set #fake for good sorting
    ("  store %type.callTraceInfo* " ptrRegName ", %type.callTraceInfo** " prevPtrRegName) @block appendInstruction
    TRUE @block.@program.last.@alloca set #fake for good sorting
    fileNameVar: (processor.positions.last.file.name "\00") assembleString @processor @block makeVarString;
    ("  store i8* " fileNameVar @processor getIrName ", i8** " namePtrRegName) @block appendInstruction
    TRUE @block.@program.last.@alloca set #fake for good sorting

    TRUE @block.@hasNestedCall set
  ] when

  ("  store i32 " processor.positions.last.line ", i32* " linePtrRegName) @block appendInstruction
  ("  store i32 " processor.positions.last.column ", i32* " colmPtrRegName) @block appendInstruction
  ("  store %type.callTraceInfo* " ctRegName ", %type.callTraceInfo** @debug.callTracePtr") @block appendInstruction
];

createCallTraceEpilog: [
  processor: block:;;
  ptrRegName: "%debug.oldCallTracePtr";
  ("  store %type.callTraceInfo* " ptrRegName ", %type.callTraceInfo** @debug.callTracePtr") @block appendInstruction
];

createGetCallTrace: [
  variable: processor: block: ;;;
  variableIrType: variable @processor getMplSchema.irTypeId;

  processor.options.callTrace [
    currentPtrRegName: @processor @block generateRegisterIRName;
    ("  " currentPtrRegName @processor getNameById " = load %type.callTraceInfo*, %type.callTraceInfo** @debug.callTracePtr") @block appendInstruction
    varPtrRegName: @processor @block generateRegisterIRName;
    ("  " varPtrRegName @processor getNameById " = bitcast %type.callTraceInfo* " currentPtrRegName @processor getNameById " to " variableIrType @processor getNameById) @block appendInstruction
    ("  store " variableIrType @processor getNameById " " varPtrRegName @processor getNameById ", " variableIrType @processor getNameById "* " variable @processor getIrName) @block appendInstruction
  ] [
    ("  store " variableIrType @processor getNameById " null, " variableIrType @processor getNameById "* " variable @processor getIrName) @block appendInstruction
  ] if
];

# require captures "processor" and "codeNode"
generateVariableIRNameWith: [
  hostOfVariable: temporaryRegister: processor: block: ;;;;

  temporaryRegister ~ [block.parent 0 =] && [
    ("@global." processor.globalVarCount) assembleString @processor makeStringId
    processor.globalVarCount 1 + @processor.@globalVarCount set
  ] [
    hostOfVariable.lastVarName @processor makeDefaultVarId
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
