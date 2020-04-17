"control" includeModule
"astNodeType" includeModule
"Block" includeModule
"schemas" includeModule

CompilerPositionInfo: [{
  column:     -1 dynamic;
  line:       -1 dynamic;
  fileNumber: 0 dynamic;
  token:      String;
}];

StringArray: [String Array];

DEFAULT_STATIC_LOOP_LENGTH_LIMIT: [64];
DEFAULT_RECURSION_DEPTH_LIMIT: [256];
DEFAULT_PRE_RECURSION_DEPTH_LIMIT: [64];

ProcessorOptions: [{
  mainPath:               String;
  fileNames:              StringArray;
  pointerSize:            64nx dynamic;
  staticLiterals:         TRUE dynamic;
  debug:                  TRUE dynamic;
  debugMemory [
    debugMemory:            TRUE dynamic;
  ] [] uif
  arrayChecks:            TRUE dynamic;
  autoRecursion:          FALSE dynamic;
  logs:                   FALSE dynamic;
  verboseIR:              FALSE dynamic;
  callTrace:              FALSE dynamic;
  threadModel:            0 dynamic;
  staticLoopLengthLimit:  DEFAULT_STATIC_LOOP_LENGTH_LIMIT;
  recursionDepthLimit:    DEFAULT_RECURSION_DEPTH_LIMIT;
  preRecursionDepthLimit: DEFAULT_PRE_RECURSION_DEPTH_LIMIT;
  linkerOptions:          String Array;
}];

ProcessorErrorInfo: [{
  message: String;
  missedModule: String;
  position: CompilerPositionInfo Array;
}];

ProcessorResult: [{
  success: TRUE dynamic;
  findModuleFail: FALSE dynamic;
  passErrorThroughPRE: FALSE dynamic;
  program: String;
  errorInfo: ProcessorErrorInfo;
  globalErrorInfo: ProcessorErrorInfo Array;
}];

makeInstruction: [{
  enabled: TRUE dynamic;
  alloca: FALSE dynamic;
  fakePointer: FALSE dynamic;
  codeOffset: copy;
  codeSize: copy;
}];

Instruction: [0 0 makeInstruction];

ArgVirtual:       [0n8 dynamic];
ArgGlobal:        [1n8 dynamic];
ArgRef:           [2n8 dynamic];
ArgCopy:          [3n8 dynamic];
ArgReturn:        [4n8 dynamic];
ArgRefDeref:      [5n8 dynamic];
ArgReturnDeref:   [6n8 dynamic];

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

FieldCapture: [{
  object: RefToVar;
  capturingPoint: -1 dynamic; #index of code node where it was
  captureCase: NameCaseInvalid;
  nameInfo: -1 dynamic;
  nameOverload: -1 dynamic;
  cntNameOverload: -1 dynamic;
  cntNameOverloadParent: -1 dynamic;
}];

IndexInfo: [{
  overload: -1 dynamic;
  index: -1 dynamic;
}];

NodeCaseEmpty:                 [0n8 dynamic];
NodeCaseCode:                  [1n8 dynamic];
NodeCaseDtor:                  [2n8 dynamic];
NodeCaseDeclaration:           [3n8 dynamic];
NodeCaseCodeRefDeclaration:    [4n8 dynamic];
NodeCaseExport:                [5n8 dynamic];
NodeCaseLambda:                [6n8 dynamic];
NodeCaseList:                  [7n8 dynamic];
NodeCaseObject:                [8n8 dynamic];

NodeStateNew:         [0n8 dynamic];
NodeStateNoOutput:    [1n8 dynamic]; #after calling NodeStateNew recursion with unknown output, node is uncompilable
NodeStateHasOutput:   [2n8 dynamic]; #after merging "if" with output and without output, node can be compiled
NodeStateCompiled:    [3n8 dynamic]; #node finished
NodeStateFailed:      [4n8 dynamic]; #node finished

NodeRecursionStateNo:       [0n8 dynamic];
NodeRecursionStateFail:     [1n8 dynamic];
NodeRecursionStateNew:      [2n8 dynamic];
NodeRecursionStateOld:      [3n8 dynamic];
NodeRecursionStateFailDone: [4n8 dynamic];

NameWithOverload: [{
  virtual NAME_WITH_OVERLOAD: ();
  nameInfo: -1 dynamic;
  nameOverload: -1 dynamic;
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
];

MatchingInfo: [{
  inputs: Argument Array;
  preInputs: RefToVar Array;
  captures: Capture Array;
  fieldCaptures: FieldCapture Array;
  hasStackUnderflow: FALSE dynamic;
  unfoundedNames: Int32 Cond HashTable; #nameInfos
}];

CFunctionSignature: [{
  inputs: RefToVar Array;
  outputs: RefToVar Array;
  variadic: FALSE dynamic;
  convention: String;
}];

UsedModuleInfo: [{
  used: FALSE dynamic;
  position: CompilerPositionInfo;
}];

MatchingNode: [{
  unknownMplType: IndexArray;
  byMplType: Int32 IndexArray HashTable; #first input MPL type

  compilerPositionInfo: CompilerPositionInfo;
  entries: Int32;
  tries: Int32;
  size: Int32;
}];

makeWayInfo: [{
  copy currentName:;
  copy current:;
  copy prev:;
}];

WayInfo: [
  -1 dynamic -1 dynamic StringView makeWayInfo
];

Processor: [{
  options: ProcessorOptions;

  blocks:              Block Owner Array;
  matchingNodes:       Natx MatchingNode HashTable;
  recursiveNodesStack: Int32 Array;
  nameInfos:           NameInfo Array;
  modules:             String Int32 HashTable; # -1 no module, or Id of codeNode
  nameToId:            String Int32 HashTable; # id of nameInfo from parser

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

  funcAliasCount:         0 dynamic;
  globalVarCount:         0 dynamic;
  globalVarId:            0 dynamic;
  globalInitializer:      -1 dynamic; # index of func for calling all initializers
  globalDestructibleVars: RefToVar Array;
  exportDepth:            0 dynamic;

  stringNames: String RefToVar HashTable;        #for string constants
  typeNames:   String Int32 HashTable;           #mplType->irAliasId

  schemaBuffer: VariableSchema Array;
  schemaTable: VariableSchema Int32 HashTable;

  nameBuffer:  String Array;
  nameTable:   StringView Int32 HashTable;       #strings->nameTag; strings from nameBuffer

  depthOfRecursion:    0 dynamic;
  maxDepthOfRecursion: 0 dynamic;
  depthOfPre:          0 dynamic;

  condArray: Cond Array;
  irArgumentArray: IRArgument Array;

  varRefArrayCount: 0;
  varRefArrays: RefToVar Array Array;

  acquireVarRefArray: [
    varRefArrays.size 0 = [
      varRefArrayCount 11 = ["Too many varRef arrays requested\00" failProc] when
      varRefArrayCount 1 + !varRefArrayCount
      RefToVar Array
    ] [
      @varRefArrays.last move copy
      @varRefArrays.popBack
    ] if
  ];

  releaseVarRefArray: [
    move @varRefArrays.pushBack
    @varRefArrays.last.clear
  ];

  unfinishedWay: WayInfo Array;

  prolog: String Array;

  debugInfo: {
    strings:          String Array;
    locationIds:      Int32 Int32 HashTable;
    lastId:           0 dynamic;
    unit:             -1 dynamic;
    unitStringNumber: -1 dynamic;
    cuStringNumber:   -1 dynamic;
    fileNameIds:      Int32 Array;
    globals:          Int32 Array;
  };

  lastStringId: 0 dynamic;
  lastTypeId:   0 dynamic;
  unitId:       0 dynamic; # number of compiling unit

  namedFunctions:  String Int32 HashTable; # name -> node ID
  moduleFunctions: Int32 Array;
  dtorFunctions:   Int32 Array;

  varCount: 0 dynamic;

  usedFloatBuiltins: FALSE dynamic;

  INIT: [];
  DIE: [];
}];
