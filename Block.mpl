# Copyright (C) 2021 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"Array" use
"HashTable" use
"String" use
"Variant" use
"control" use

"Mref" use
"Var" use
"astNodeType" use

ArgVirtual:     [0n8 dynamic];
ArgGlobal:      [1n8 dynamic];
ArgRef:         [2n8 dynamic];
ArgCopy:        [3n8 dynamic];
ArgDerefCopy:   [4n8 dynamic];
ArgMeta:        [5n8 dynamic];
ArgAlreadyUsed: [6n8 dynamic];
ArgReturn:      [7n8 dynamic];
ArgRefDeref:    [8n8 dynamic];
ArgReturnDeref: [9n8 dynamic];

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
  stable:            Cond;
  mplFieldIndex:     -1 dynamic;
  nameInfo:          -1 dynamic;
  nameOverloadDepth: -1 dynamic;
  file:              ["MplFile.FileSchema" use FileSchema] Mref;
}];

CFunctionSignature: [{
  inputs: RefToVar Array;
  outputs: RefToVar Array;
  variadic: FALSE dynamic;
  convention: String;
}];

CompilerPositionInfo: [{
  file:   ["MplFile.FileSchema" use FileSchema] Mref;
  line:   -1 dynamic;
  column: -1 dynamic;
  token:  StringView;
}];

makeInstruction: [{
  enabled: TRUE dynamic;
  alloca: FALSE dynamic;
  fakePointer: FALSE dynamic;
  fakeAlloca: FALSE dynamic;
  irName1: -1 dynamic;
  irName2: -1 dynamic;
  irName3: -1 dynamic;
  codeOffset: new;
  codeSize: new;
}];

Instruction: [0 0 makeInstruction];

MatchingInfo: [{
  inputs: Argument Array; #for generating signatures
  captures: Capture Array; #for generating signatures, for finding 'self'
  shadowEvents: ShadowEvent Array;
  lastTopologyIndex: 0 dynamic;
  currentInputCount: 0 dynamic;
  maxInputCount: 0 dynamic;
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
  astNode: AstNode Cref;
}];

UsedModuleInfo: [{
  used: FALSE dynamic;
  position: CompilerPositionInfo;
}];

ShadowEventInput:        [Argument];

ShadowEventCapture:      [Capture];

ShadowEventField: [{
  object: RefToVar;
  field: RefToVar;
  mplFieldIndex: Int32;
}];

ShadowEventPointee: [{
  pointer: RefToVar;
  pointee: RefToVar;
}];

ShadowEvent: [(
  Cond                    #ShadowReasonNo
  ShadowEventCapture      #ShadowReasonCapture
  ShadowEventInput        #ShadowReasonInput
  ShadowEventField        #ShadowReasonField
  ShadowEventPointee      #ShadowReasonPointee
  Cond                    #ShadowReasonLambda
) Variant];

Block: [{
  id:               Int32;
  root:             FALSE dynamic;
  file:             ["MplFile.FileSchema" use FileSchema] Mref;
  topNode:          [@BlockSchema] Mref;
  capturedFiles:    Cond Array;
  beginPosition:    CompilerPositionInfo;
  parent:           0 dynamic;
  nodeCase:         NodeCaseCode;
  stack:            RefToVar Array; # we must compile node without touching parent
  minStackDepth:    0 dynamic;
  programTemplate:  String;
  program:          Instruction Array;
  aliases:          String Array;
  lastLambdaName:   Int32;
  nextRecLambdaId:  -1 dynamic;
  globalPriority:   Int32;

  instructionCountBeforeRet: Int32;
  hasCallImport:       FALSE dynamic;
  hasEmptyLambdas:     FALSE dynamic;
  nodeIsRecursive:     FALSE dynamic;
  nextLabelIsVirtual:  FALSE dynamic;
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
  hasCallTrace:        FALSE dynamic;
  changedStableName:   FALSE dynamic;

  countOfUCall:         0 dynamic;
  declarationRefs:      Cond Array;
  buildingMatchingInfo: MatchingInfo;
  matchingInfo:         MatchingInfo;
  outputs:              Argument Array;
  dependentPointers:    (RefToVar RefToVar FALSE dynamic) Array;
  captureErrors:        Int32 CompilerPositionInfo HashTable;

  fromModuleNames:   NameWithOverloadAndRefToVar Array;
  labelNames:        NameWithOverloadAndRefToVar Array;
  captureNames:      NameWithOverload Array;
  stableNames:       Int32 Array;

  candidatesToDie:     RefToVar Array;
  unprocessedAstNodes: TokenRef Array;
  globalVariableNames: Int32 RefToVar Array HashTable;

  refToVar:           RefToVar; #refToVar of function with compiled node
  varNameInfo:        -1 dynamic; #variable name of imported function
  astArrayIndex:      -1 dynamic;
  matchingChindIndex: -1 dynamic;
  exportDepth:        0 dynamic;
  namedFunctions:     String Int32 HashTable; # name -> node ID
  capturedVars:       RefToVar Array;
  fileLexicalBlocks:  Int32 Int32 HashTable;
  funcDbgIndex:      -1 dynamic;
  lastVarName:        0 dynamic;
  lastBrLabelName:    0 dynamic;
  variableCountDelta: 0 dynamic;

  nextStringAttribute: String;

  INIT: [];
  DIE: [];
}];

virtual BlockSchema: Block Ref;
