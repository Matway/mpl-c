"Array" useModule
"Owner" useModule
"String" useModule
"Variant" useModule
"control" useModule

"Mref" useModule

Dirty:   [0n8 dynamic];
Dynamic: [1n8 dynamic];
Weak:    [2n8 dynamic];
Static:  [3n8 dynamic];
Virtual: [4n8 dynamic];
Schema:  [5n8 dynamic];

ShadowReasonNo:      [0n8 dynamic];
ShadowReasonCapture: [1n8 dynamic];
ShadowReasonInput:   [2n8 dynamic];
ShadowReasonField:   [3n8 dynamic];
ShadowReasonPointee: [4n8 dynamic];

VarInvalid: [ 0 static];
VarCond:    [ 1 static];
VarNat8:    [ 2 static];
VarNat16:   [ 3 static];
VarNat32:   [ 4 static];
VarNat64:   [ 5 static];
VarNatX:    [ 6 static];
VarInt8:    [ 7 static];
VarInt16:   [ 8 static];
VarInt32:   [ 9 static];
VarInt64:   [10 static];
VarIntX:    [11 static];
VarReal32:  [12 static];
VarReal64:  [13 static];
VarCode:    [14 static];
VarBuiltin: [15 static];
VarImport:  [16 static];
VarString:  [17 static];
VarRef:     [18 static];
VarStruct:  [19 static];
VarEnd:     [20 static];

CodeNodeInfo: [{
  CODE_NODE_INFO: ();

  file:   [FileSchema] Mref;
  line:   Int32;
  column: Int32;
  index:  Int32;
}];

Field: [{
  nameInfo: -1 dynamic; # NameInfo id
  nameOverload: -1 dynamic;
  refToVar: RefToVar;
}];

FieldArray: [Field Array];

Struct: [{
  fullVirtual:   FALSE dynamic;
  homogeneous:   FALSE dynamic;
  hasPreField:   FALSE dynamic;
  unableToDie:   FALSE dynamic;
  hasDestructor: FALSE dynamic;
  forgotten:     TRUE  dynamic;
  realFieldIndexes: Int32 Array;
  fields: FieldArray;
  structStorageSize: 0nx dynamic;
  structAlignment: 0nx dynamic;
}]; #IDs of pointee vars

RefToVar: [{
  virtual REF_TO_VAR: ();
  var: [@VarSchema] Mref;
  hostId: -1 dynamic;
  mutable: TRUE dynamic;
}];

Variable: [{
  VARIABLE: ();

  mplNameId:                         -1 dynamic;
  irNameId:                          -1 dynamic;
  mplSchemaId:                       -1 dynamic;
  storageStaticity:                  Static;
  staticity:                         Static;
  global:                            FALSE dynamic;
  temporary:                         TRUE dynamic;
  usedInHeader:                      FALSE dynamic;
  capturedAsMutable:                 FALSE dynamic;
  capturedAsRealValue:               FALSE dynamic;
  tref:                              TRUE dynamic;
  shadowReason:                      ShadowReasonNo;
  globalId:                          -1 dynamic;
  shadowBegin:                       RefToVar;
  shadowEnd:                         RefToVar;
  capturedHead:                      RefToVar;
  capturedTail:                      RefToVar;
  capturedPrev:                      RefToVar;
  realValue:                         RefToVar;
  globalDeclarationInstructionIndex: -1 dynamic;
  allocationInstructionIndex:        -1 dynamic;
  getInstructionIndex:               -1 dynamic;

  data: (
    Nat8             #VarInvalid
    Cond             #VarCond
    Nat64            #VarNat8
    Nat64            #VarNat16
    Nat64            #VarNat32
    Nat64            #VarNat64
    Nat64            #VarNatX
    Int64            #VarInt8
    Int64            #VarInt16
    Int64            #VarInt32
    Int64            #VarInt64
    Int64            #VarIntX
    Real64           #VarReal32
    Real64           #VarReal64
    CodeNodeInfo     #VarCode; id of node
    Int32            #VarBuiltin
    Int32            #VarImport
    String           #VarString
    RefToVar         #VarRef
    Struct Owner     #VarStruct
  ) Variant;

  INIT: [];
  DIE: [];
}];

schema VarSchema: Variable;
