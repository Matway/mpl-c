"Array.Array" use
"HashTable.HashTable" use
"Owner.Owner" use
"String.String" use
"String.StringView" use
"control" use
"memory.debugMemory" use

"Block.Block" use
"Block.CompilerPositionInfo" use
"Block.NameCaseInvalid" use
"File.File" use
"Mref.Mref" use
"NameManager.NameManager" use
"Var.RefToVar" use
"Var.Variable" use
"astNodeType.IndexArray" use
"astNodeType.MultiParserResult" use
"schemas.VariableSchema" use

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

IndexInfo: [{
  overload: -1 dynamic;
  index: -1 dynamic;
}];

RefToVarTable: [
  RefToVar RefToVar HashTable
];

NameInfoEntry: [{
  file: File Cref;
  refToVar: RefToVar;
  startPoint: -1 dynamic; # id of node
  nameCase: NameCaseInvalid;
  mplFieldIndex: -1 dynamic; # for NameCaseSelfMember
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

IRArgument: [{
  irTypeId: 0;
  irNameId: 0;
  byRef: TRUE;
}];

NameInfoCoord: [{
  block: ["Block.BlockSchema" use BlockSchema] Mref;
  file: ["File.FileSchema" use FileSchema] Mref;
}];

Processor: [{
  options: ProcessorOptions;
  multiParserResult: MultiParserResult Cref;
  result: ProcessorResult;
  positions: CompilerPositionInfo Array;

  files: File Owner Array;
  #fileStack: File AsRef Array;
  #file: [@fileStack.last.data]; # Currently processed File
  fileNameIds: String Int32 HashTable;

  blocks: Block Owner Array;
  variables: Variable Array Array;

  matchingNodes:       Natx MatchingNode HashTable;
  recursiveNodesStack: Int32 Array;
  nameManager:         NameInfoEntry NameManager;
  modules:             String Int32 HashTable; # -1 no module, or Id of codeNode

  captureTable: {
    simpleNames:  NameInfoCoord Array Array Array; #name; overload; vector of blocks
    selfNames:    NameInfoCoord Array Array Array; #overload; mplTypeId; vector of blocks
    closureNames: NameInfoCoord Array Array Array; #overload; mplTypeId; vector of blocks
  };

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
  varForFails:            RefToVar;
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
      varRefArrayCount 15 = ["Too many varRef arrays requested\00" failProc] when
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

  temporaryBuiltinUseData: {
    indexes: Int32 {index: Int32; depth: Int32;} HashTable;
    addNameData: {refToVar: RefToVar; nameInfo: Int32; } Array;
  };

  unfinishedWay: WayInfo Array;

  prolog: String Array;

  debugInfo: {
    strings:          String Array;
    locationIds:      Int32 Int32 HashTable;
    lastId:           0 dynamic;
    unit:             -1 dynamic;
    unitStringNumber: -1 dynamic;
    cuStringNumber:   -1 dynamic;
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
