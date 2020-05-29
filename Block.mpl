"control" use

"Array.Array" use
"HashTable.HashTable" use
"String.String" use
"Variant.Variant" use

"Mref.Mref" use
"Var.RefToVar" use
"Var.Struct" use

ArgVirtual:     [0n8 dynamic];
ArgGlobal:      [1n8 dynamic];
ArgRef:         [2n8 dynamic];
ArgCopy:        [3n8 dynamic];
ArgMeta:        [4n8 dynamic];
ArgReturn:      [5n8 dynamic];
ArgRefDeref:    [6n8 dynamic];
ArgReturnDeref: [7n8 dynamic];

NameCaseInvalid:               [ 0n8 dynamic];
NameCaseBuiltin:               [ 1n8 dynamic];
NameCaseLocal:                 [ 2n8 dynamic];
NameCaseFromModule:            [ 3n8 dynamic];
NameCaseCapture:               [ 4n8 dynamic];
NameCaseSelfMember:            [ 5n8 dynamic];
NameCaseClosureMember:         [ 6n8 dynamic];
NameCaseSelfObject:            [ 7n8 dynamic];
NameCaseClosureObject:         [ 8n8 dynamic];
NameCaseSelfObjectCapture:     [ 9n8 dynamic];
NameCaseClosureObjectCapture:  [10n8 dynamic];

MemberCaseToObjectCase:        [2n8 +];
MemberCaseToObjectCaptureCase: [4n8 +];

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
  refToVar:          RefToVar;
  argCase:           ArgRef;
  captureCase:       NameCaseInvalid;
  nameInfo:          -1 dynamic;
  nameOverloadDepth: -1 dynamic;
  file:              ["File.FileSchema" use FileSchema] Mref;
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
  object:            RefToVar;
  captureCase:       NameCaseInvalid;
  nameInfo:          -1 dynamic;
  nameOverloadDepth: -1 dynamic;
  fieldIndex:        -1 dynamic;
  file:              ["File.FileSchema" use FileSchema] Mref;
}];

makeInstruction: [{
  enabled: TRUE dynamic;
  alloca: FALSE dynamic;
  fakePointer: FALSE dynamic;
  codeOffset: copy;
  codeSize: copy;
}];

Instruction: [0 0 makeInstruction];

ShadowEvent: [(
  Cond                    #ShadowReasonNo
  ShadowEventCapture      #ShadowReasonCapture
  ShadowEventFieldCapture #ShadowReasonFieldCapture
  ShadowEventInput        #ShadowReasonInput
  ShadowEventField        #ShadowReasonField
  ShadowEventPointee      #ShadowReasonPointee
) Variant];

MatchingInfo: [{
  inputs: Argument Array; #for generating signatures
  captures: Capture Array; #for generating signatures, for finding 'self'
  shadowEvents: ShadowEvent Array;
  lastTopologyIndex: 0 dynamic;
}];

NameWithOverload: [{
  nameInfo: -1 dynamic;
  nameOverloadDepth: -1 dynamic;
}];

NameWithOverloadAndRefToVar: [{
  virtual NAME_WITH_OVERLOAD_AND_REF_TO_VAR: ();
  nameInfo: -1 dynamic;
  nameOverloadDepth:-1 dynamic;
  startPoint: -1 dynamic;
  hasOverloadWord: FALSE dynamic;
  refToVar: RefToVar;
}];

TokenRef: [{
  file: ["File.FileSchema" use FileSchema] Mref;
  token: Int32;
}];

UsedModuleInfo: [{
  used: FALSE dynamic;
  position: CompilerPositionInfo;
}];

ShadowEventInput:        [Argument];

ShadowEventCapture:      [Capture];

ShadowEventFieldCapture: [FieldCapture];

ShadowEventField: [{
  object: RefToVar;
  field: RefToVar;
  mplFieldIndex: Int32;
}];

ShadowEventPointee: [{
  pointer: RefToVar;
  pointee: RefToVar;
}];

Block: [{
  id:              Int32;
  root:            FALSE dynamic;
  parent:          0 dynamic;
  nodeCase:        NodeCaseCode;
  stack:           RefToVar Array; # we must compile node without touching parent
  minStackDepth:   0 dynamic;
  programTemplate: String;
  program:         Instruction Array;
  aliases:         String Array;
  lastLambdaName:  Int32;
  nextRecLambdaId: -1 dynamic;

  nodeIsRecursive:     FALSE dynamic;
  nextLabelIsVirtual:  FALSE dynamic;
  nextLabelIsSchema:   FALSE dynamic;
  nextLabelIsConst:    FALSE dynamic;
  nextLabelIsOverload: FALSE dynamic;
  recursionState:      NodeRecursionStateNo;
  state:               NodeStateNew;
  struct:              Struct;
  irName:              String;
  header:              String;
  argTypes:            String;
  csignature:          CFunctionSignature;
  convention:          String;
  mplConvention:       String;
  signature:           String;
  nodeCompileOnce:     FALSE dynamic;
  empty:               FALSE dynamic;
  deleted:             FALSE dynamic;
  emptyDeclaration:    FALSE dynamic;
  uncompilable:        FALSE dynamic;
  variadic:            FALSE dynamic;
  hasNestedCall:       FALSE dynamic;

  countOfUCall:         0 dynamic;
  declarationRefs:      Cond Array;
  buildingMatchingInfo: MatchingInfo;
  matchingInfo:         MatchingInfo;
  outputs:              Argument Array;

  fromModuleNames:   NameWithOverloadAndRefToVar Array;
  labelNames:        NameWithOverloadAndRefToVar Array;
  captureNames:      NameWithOverloadAndRefToVar Array;
  fieldCaptureNames: NameWithOverloadAndRefToVar Array;

  candidatesToDie:     RefToVar Array;
  unprocessedAstNodes: TokenRef Array;

  refToVar:           RefToVar; #refToVar of function with compiled node
  varNameInfo:        -1 dynamic; #variable name of imported function
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
