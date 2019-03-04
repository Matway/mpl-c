"processor" module
"control" useModule

CompilerPositionInfo: [{
  column: -1 dynamic;
  line: -1 dynamic;
  offset: -1 dynamic;
  filename: 0 dynamic;
  token: String;
}] func;

StringArray: [String Array] func;

ProcessorOptions: [{
  mainPath:       String;
  fileNames:      StringArray;
  pointerSize:    64nx dynamic;
  staticLiterals: TRUE dynamic;
  debug:          TRUE dynamic;
  arrayChecks:    TRUE dynamic;
  autoRecursion:  FALSE dynamic;
  logs:           FALSE dynamic;
  verboseIR:      FALSE dynamic;
  linkerOptions:  String Array;
}] func;

ProcessorErrorInfo: [{
  message: String;
  missedModule: String;
  position: CompilerPositionInfo Array;
}] func;

ProcessorResult: [{
  success: TRUE dynamic;
  findModuleFail: FALSE dynamic;
  program: String;
  errorInfo: ProcessorErrorInfo;
  globalErrorInfo: ProcessorErrorInfo Array;
}] func;

makeInstruction: [{
  enabled: TRUE dynamic;
  alloca: FALSE dynamic;
  fakePointer: FALSE dynamic;
  code: copy;
}] func;

Instruction: [String makeInstruction] func;

ArgVirtual:       [0n8 dynamic] func;
ArgGlobal:        [1n8 dynamic] func;
ArgRef:           [2n8 dynamic] func;
ArgCopy:          [3n8 dynamic] func;
ArgReturn:        [4n8 dynamic] func;
ArgRefDeref:      [5n8 dynamic] func;
ArgReturnDeref:   [6n8 dynamic] func;

Argument: [{
  refToVar: RefToVar;
  argCase: ArgRef;
}] func;

Capture: [{
  refToVar: RefToVar;
  argCase: ArgRef;
  captureCase: NameCaseInvalid;
  nameInfo: -1 dynamic;
  nameOverload: -1 dynamic;
  cntNameOverload: -1 dynamic;
}] func;

FieldCapture: [{
  object: RefToVar;
  capturingPoint: -1 dynamic; #index of code node where it was
  captureCase: NameCaseInvalid;
  nameInfo: -1 dynamic;
  nameOverload: -1 dynamic;
  cntNameOverload: -1 dynamic;
}] func;

IndexInfo: [{
  overload: -1 dynamic;
  index: -1 dynamic;
}] func;

IndexInfoArray: [IndexInfo Array] func;

NodeCaseEmpty:                 [0n8 dynamic] func;
NodeCaseCode:                  [1n8 dynamic] func;
NodeCaseDtor:                  [2n8 dynamic] func;
NodeCaseDeclaration:           [3n8 dynamic] func;
NodeCaseDllDeclaration:        [4n8 dynamic] func;
NodeCaseCodeRefDeclaration:    [5n8 dynamic] func;
NodeCaseExport:                [6n8 dynamic] func;
NodeCaseLambda:                [7n8 dynamic] func;
NodeCaseList:                  [8n8 dynamic] func;
NodeCaseObject:                [9n8 dynamic] func;

NodeStateNew:         [0n8 dynamic] func;
NodeStateNoOutput:    [1n8 dynamic] func; #after calling NodeStateNew recursion with unknown output, node is uncompilable
NodeStateHasOutput:   [2n8 dynamic] func; #after merging "if" with output and without output, node can be compiled
NodeStateCompiled:    [3n8 dynamic] func; #node finished

NodeRecursionStateNo:       [0n8 dynamic] func;
NodeRecursionStateFail:     [1n8 dynamic] func;
NodeRecursionStateNew:      [2n8 dynamic] func;
NodeRecursionStateOld:      [3n8 dynamic] func;
NodeRecursionStateFailDone: [4n8 dynamic] func;

CaptureNameResult: [{
  refToVar: RefToVar;
  object: RefToVar;
}] func;

NameWithOverload: [{
  virtual NAME_WITH_OVERLOAD: ();
  nameInfo: -1 dynamic;
  nameOverload: -1 dynamic;
}] func;

NameWithOverloadAndRefToVar: [{
  virtual NAME_WITH_OVERLOAD_AND_REF_TO_VAR: ();
  nameInfo: -1 dynamic;
  nameOverload: -1 dynamic;
  refToVar: RefToVar;
  startPoint: -1 dynamic;
}] func;

=: ["NAME_WITH_OVERLOAD" has] [
  n1:; n2:;
  n1.nameInfo n2.nameInfo = n1.nameOverload n2.nameOverload = and
] pfunc;

hash: ["NAME_WITH_OVERLOAD" has] [
  nameWithOverload:;
  nameWithOverload.nameInfo 67n32 * nameWithOverload.nameOverload 17n32 * +
] pfunc;

RefToVarTable: [
  RefToVar RefToVar HashTable
] func;

NameTable:  [
  elementConstructor:;
  NameWithOverload @elementConstructor HashTable
] func;

IntTable: [Int32 Int32 HashTable] func;

MatchingInfo: [{
  inputs: Argument Array;
  preInputs: RefToVar Array;
  captures: Capture Array;
  fieldCaptures: FieldCapture Array;
}] func;

CFunctionSignature: [{
  inputs: RefToVar Array;
  outputs: RefToVar Array;
  variadic: FALSE dynamic;
  convention: String;
}] func;

UsedModuleInfo: [{
  used: FALSE dynamic;
  position: CompilerPositionInfo;
}] func;

CodeNode: [{
  root: FALSE dynamic;
  parent: 0 dynamic;
  nodeCase: NodeCaseCode;
  position: CompilerPositionInfo;
  stack: RefToVar Array; # we must compile node without touching parent
  minStackDepth: 0 dynamic;
  program: Instruction Array;
  aliases: String Array;
  variables: Variable Owner Array; # as unique_ptr...
  lastLambdaName: Int32;
  nextRecLambdaId: -1 dynamic;

  nodeIsRecursive: FALSE dynamic;
  nextLabelIsVirtual: FALSE dynamic;
  nextLabelIsSchema: FALSE dynamic;
  nextLabelIsConst: FALSE dynamic;
  recursionState: NodeRecursionStateNo;
  state: NodeStateNew;
  struct: Struct;
  irName: String;
  header: String;
  argTypes: String;
  csignature: CFunctionSignature;
  convention: String;
  mplConvention: String;
  signature: String;
  nodeCompileOnce: FALSE dynamic;
  empty: FALSE dynamic;
  deleted: FALSE dynamic;
  emptyDeclaration: FALSE dynamic;
  uncompilable: FALSE dynamic;
  variadic: FALSE dynamic;

  declarationRefs: Cond Array;
  buildingMatchingInfo: MatchingInfo;
  matchingInfo: MatchingInfo;
  outputs: Argument Array;

  fromModuleNames:   NameWithOverloadAndRefToVar Array;
  labelNames:        NameWithOverloadAndRefToVar Array;
  captureNames:      NameWithOverloadAndRefToVar Array;
  fieldCaptureNames: NameWithOverloadAndRefToVar Array;

  captureTable: RefToVar Cond HashTable;
  fieldCaptureTable: RefToVar Cond HashTable;

  candidatesToDie: RefToVar Array;
  unprocessedAstNodes: IndexArray;
  moduleName: String;
  includedModules: Int32 Array; #ids in order
  directlyIncludedModulesTable: Int32 Cond HashTable; # dont include twice plz
  includedModulesTable: Int32 UsedModuleInfo HashTable; # dont include twice plz
  usedModulesTable: Int32 UsedModuleInfo HashTable; # moduleID, hasUsedVars
  usedOrIncludedModulesTable: Int32 Cond HashTable; # moduleID, hasUsedVars

  refToVar: RefToVar; #refToVar of this node
  varNameInfo: -1 dynamic; #variable name of imported function
  moduleId: -1 dynamic;
  namedFunctions: String Int32 HashTable; # name -> node ID
  capturedVars: RefToVar Array;
  funcDbgIndex: -1 dynamic;
  lastVarName: 0 dynamic;
  lastBrLabelName: 0 dynamic;
  variableCountDelta: 0 dynamic;

  INIT: [];
  DIE: [];
}] func;

Processor: [{
  options: ProcessorOptions;

  nodes: CodeNode Owner Array;
  matchingNodes: Natx IndexArray HashTable;
  recursiveNodesStack: Int32 Array;
  nameInfos: NameInfo Array;
  modules: String Int32 HashTable; # -1 no module, or Id of codeNode
  nameToId: String Int32 HashTable; # id of nameInfo from parser

  emptyNameInfo:               -1 dynamic;
  callNameInfo:                -1 dynamic;
  preNameInfo:                 -1 dynamic;
  dieNameInfo:                 -1 dynamic;
  initNameInfo:                -1 dynamic;
  assignNameInfo:              -1 dynamic;
  selfNameInfo:                -1 dynamic;
  closureNameInfo:             -1 dynamic;
  inputsNameInfo:              -1 dynamic;
  outputsNameInfo:             -1 dynamic;
  capturesNameInfo:            -1 dynamic;
  variadicNameInfo:            -1 dynamic;
  failProcNameInfo:            -1 dynamic;
  conventionNameInfo:          -1 dynamic;

  funcAliasCount:     0 dynamic;
  globalVarCount:     0 dynamic;
  globalVarId:        0 dynamic;
  globalInitializer: -1 dynamic; # index of func for calling all initializers
  globalDestructibleVars: RefToVar Array;
  processingExport: 0 dynamic;

  stringNames: String String HashTable;        #for string constants
  typeNames: String Int32 HashTable;           #mplType->irAliasId

  nameBuffer: String Array;
  nameTable: StringView Int32 HashTable;       #strings->nameTag; strings from nameBuffer

  depthOfRecursion: 0 dynamic;
  maxDepthOfRecursion: 0 dynamic;
  depthOfPre: 0 dynamic;
  prolog: String Array;

  debugInfo: {
    strings: String Array;
    locationIds: IntTable;
    lastId: 0 dynamic;
    unit: -1 dynamic;
    unitStringNumber: -1 dynamic;
    cuStringNumber: -1 dynamic;
    fileNameIds: Int32 Array;
    typeIdToDbgId: IntTable;
    globals: Int32 Array;
  };

  lastStringId: 0 dynamic;
  lastTypeId: 0 dynamic;
  unitId: 0 dynamic; # number of compiling unit

  namedFunctions: String Int32 HashTable; # name -> node ID
  moduleFunctions: Int32 Array;
  dtorFunctions: Int32 Array;

  varCount: 0 dynamic;
  structureVarCount: 0 dynamic;
  fieldVarCount: 0 dynamic;
  nodeCount: 0 dynamic;
  deletedNodeCount: 0 dynamic;
  deletedVarCount: 0 dynamic;

  usedFloatBuiltins: FALSE dynamic;
  usedHeapBuiltins: FALSE dynamic;
  maxDepthExceeded: FALSE dynamic;

  INIT: [];
  DIE: [];
}] func;
