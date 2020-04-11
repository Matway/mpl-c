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
  variables:       Variable Owner Array; # as unique_ptr...
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
  unprocessedAstNodes: IndexArray;
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
