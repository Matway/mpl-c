"Array.Array" use
"HashTable.HashTable" use
"String.String" use
"control.Cond" use
"control.Int32" use

"Mref.Mref" use
"Var.RefToVar" use
"Var.Struct" use

ArgVirtual:     [0n8 dynamic];
ArgGlobal:      [1n8 dynamic];
ArgRef:         [2n8 dynamic];
ArgCopy:        [3n8 dynamic];
ArgReturn:      [4n8 dynamic];
ArgRefDeref:    [5n8 dynamic];
ArgReturnDeref: [6n8 dynamic];

NameCaseInvalid:    [0n8 dynamic];
NameCaseBuiltin:    [1n8 dynamic];
NameCaseLocal:      [2n8 dynamic];
NameCaseFromModule: [3n8 dynamic];
NameCaseCapture:    [4n8 dynamic];

NodeCaseEmpty:              [0n8 dynamic];
NodeCaseCode:               [1n8 dynamic];
NodeCaseDtor:               [2n8 dynamic];
NodeCaseDeclaration:        [3n8 dynamic];
NodeCaseCodeRefDeclaration: [4n8 dynamic];
NodeCaseExport:             [5n8 dynamic];
NodeCaseLambda:             [6n8 dynamic];
NodeCaseList:               [7n8 dynamic];
NodeCaseObject:             [8n8 dynamic];

NodeRecursionStateNo:       [0n8 dynamic];
NodeRecursionStateFail:     [1n8 dynamic];
NodeRecursionStateNew:      [2n8 dynamic];
NodeRecursionStateOld:      [3n8 dynamic];
NodeRecursionStateFailDone: [4n8 dynamic];

NodeStateNew:       [0n8 dynamic];
NodeStateNoOutput:  [1n8 dynamic]; #after calling NodeStateNew recursion with unknown output, node is uncompilable
NodeStateHasOutput: [2n8 dynamic]; #after merging "if" with output and without output, node can be compiled
NodeStateCompiled:  [3n8 dynamic]; #node finished
NodeStateFailed:    [4n8 dynamic]; #node finished

Argument: [{
  refToVar: RefToVar;
  argCase: ArgRef;
}];

Capture: [{
  refToVar: RefToVar;
  argCase: ArgRef;
  captureCase: NameCaseInvalid;
  nameInfo: -1 dynamic;
  nameOverload: -1 dynamic;
  cntNameOverload: -1 dynamic;
  cntNameOverloadParent: -1 dynamic;
}];

CFunctionSignature: [{
  inputs: RefToVar Array;
  outputs: RefToVar Array;
  variadic: FALSE dynamic;
  convention: String;
}];

CompilerPositionInfo: [{
  file:   ["File.FileSchema" use FileSchema] Mref;
  line:   -1;
  column: -1;
  token:  String;
}];

FieldCapture: [{
  object: RefToVar;
  capturingPoint: -1 dynamic; #index of code node where it was
  captureCase: NameCaseInvalid;
  nameInfo: -1 dynamic;
  nameOverload: -1 dynamic;
  cntNameOverload: -1 dynamic;
  cntNameOverloadParent: -1 dynamic;
}];

makeInstruction: [{
  enabled: TRUE dynamic;
  alloca: FALSE dynamic;
  fakePointer: FALSE dynamic;
  codeOffset: copy;
  codeSize: copy;
}];

Instruction: [0 0 makeInstruction];

MatchingInfo: [{
  inputs: Argument Array;
  preInputs: RefToVar Array;
  captures: Capture Array;
  fieldCaptures: FieldCapture Array;
  hasStackUnderflow: FALSE dynamic;
  unfoundedNames: Int32 Cond HashTable; #nameInfos
}];

NameWithOverloadAndRefToVar: [{
  virtual NAME_WITH_OVERLOAD_AND_REF_TO_VAR: ();
  nameInfo: -1 dynamic;
  nameOverload: -1 dynamic;
  cntNameOverload: -1 dynamic;
  cntNameOverloadParent: -1 dynamic;
  refToVar: RefToVar;
  startPoint: -1 dynamic;
}];

TokenRef: [{
  file: ["File.FileSchema" use FileSchema] Mref;
  token: Int32;
}];

UsedModuleInfo: [{
  used: FALSE dynamic;
  position: CompilerPositionInfo;
}];

Block: [{
  id:              Int32;
  root:            FALSE dynamic;
  parent:          0 dynamic;
  nodeCase:        NodeCaseCode;
  position:        CompilerPositionInfo;
  stack:           RefToVar Array; # we must compile node without touching parent
  minStackDepth:   0 dynamic;
  programTemplate: String;
  program:         Instruction Array;
  aliases:         String Array;
  lastLambdaName:  Int32;
  nextRecLambdaId: -1 dynamic;

  nodeIsRecursive:    FALSE dynamic;
  nextLabelIsVirtual: FALSE dynamic;
  nextLabelIsSchema:  FALSE dynamic;
  nextLabelIsConst:   FALSE dynamic;
  recursionState:     NodeRecursionStateNo;
  state:              NodeStateNew;
  struct:             Struct;
  irName:             String;
  header:             String;
  argTypes:           String;
  csignature:         CFunctionSignature;
  convention:         String;
  mplConvention:      String;
  signature:          String;
  nodeCompileOnce:    FALSE dynamic;
  empty:              FALSE dynamic;
  deleted:            FALSE dynamic;
  emptyDeclaration:   FALSE dynamic;
  uncompilable:       FALSE dynamic;
  variadic:           FALSE dynamic;
  hasNestedCall:      FALSE dynamic;

  countOfUCall:         0 dynamic;
  declarationRefs:      Cond Array;
  buildingMatchingInfo: MatchingInfo;
  matchingInfo:         MatchingInfo;
  outputs:              Argument Array;

  fromModuleNames:   NameWithOverloadAndRefToVar Array;
  labelNames:        NameWithOverloadAndRefToVar Array;
  captureNames:      NameWithOverloadAndRefToVar Array;
  fieldCaptureNames: NameWithOverloadAndRefToVar Array;

  captureTable:      RefToVar Cond HashTable;
  fieldCaptureTable: RefToVar Cond HashTable;

  candidatesToDie:     RefToVar Array;
  unprocessedAstNodes: TokenRef Array;
  moduleName:          String;
  includedModules:     Int32 Array; #ids in order
  directlyIncludedModulesTable: Int32 Cond HashTable; # dont include twice plz
  includedModulesTable:         Int32 UsedModuleInfo HashTable; # dont include twice plz
  usedModulesTable:             Int32 UsedModuleInfo HashTable; # moduleID, hasUsedVars
  usedOrIncludedModulesTable:   Int32 Cond HashTable; # moduleID, hasUsedVars

  refToVar:           RefToVar; #refToVar of function with compiled node
  varNameInfo:        -1 dynamic; #variable name of imported function
  moduleId:           -1 dynamic;
  indexArrayAddress:  0nx dynamic;
  matchingInfoIndex:  -1 dynamic;
  exportDepth:        0 dynamic;
  namedFunctions:     String Int32 HashTable; # name -> node ID
  capturedVars:       RefToVar Array;
  funcDbgIndex:      -1 dynamic;
  lastVarName:        0 dynamic;
  lastBrLabelName:    0 dynamic;
  variableCountDelta: 0 dynamic;

  INIT: [];
  DIE: [];
}];

schema BlockSchema: Block;
