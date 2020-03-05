"variable" module
"HashTable" includeModule
"String"    includeModule
"Variant"   includeModule
"Owner"     includeModule

"irWriter"    includeModule
"debugWriter" includeModule
"processor"   includeModule

Dirty:           [0n8 dynamic];
Dynamic:         [1n8 dynamic];
Weak:            [2n8 dynamic];
Static:          [3n8 dynamic];
Virtual:         [4n8 dynamic];
Schema:          [5n8 dynamic];

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

ShadowReasonNo:      [0n8 dynamic];
ShadowReasonCapture: [1n8 dynamic];
ShadowReasonInput:   [2n8 dynamic];
ShadowReasonField:   [3n8 dynamic];
ShadowReasonPointee: [4n8 dynamic];

RefToVar: [{
  virtual REF_TO_VAR: ();
  varId: -1 dynamic;
  hostId: -1 dynamic;
  mutable: TRUE dynamic;
}];

=: ["REF_TO_VAR" has] [
  refsAreEqual
] pfunc;

hash: ["REF_TO_VAR" has] [
  refToVar:;
  refToVar.hostId 0n32 cast 67n32 * refToVar.varId 0n32 cast 17n32 * +
] pfunc;

=: ["CODE_NODE_INFO" has] [
  l:r:;;
  l.index r.index =
] pfunc;

NameInfoEntry: [{
  refToVar: RefToVar;
  startPoint: -1 dynamic; # id of node
  nameCase: NameCaseInvalid;
  index: -1 dynamic; # for NameCaseSelfMember
}];

Overload: [NameInfoEntry Array];

makeNameInfo: [{
  name: copy;
  stack: Overload Array;
}];

NameInfo: [String makeNameInfo];

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

CodeNodeInfo: [{
  CODE_NODE_INFO: ();

  moduleId: Int32;
  offset: Int32;
  line: Int32;
  column: Int32;
  index: Int32;
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

compilable: [processorResult.success copy];

callBuiltin:           [multiParserResult @currentNode indexOfNode @processor @processorResult callBuiltinImpl];
processFuncPtr:        [multiParserResult @currentNode indexOfNode @processor @processorResult processFuncPtrImpl];
processPre:            [multiParserResult @currentNode indexOfNode @processor @processorResult processPreImpl];
processCall:           [multiParserResult @currentNode indexOfNode @processor @processorResult processCallImpl];
processExportFunction: [multiParserResult @currentNode indexOfNode @processor @processorResult processExportFunctionImpl];
processImportFunction: [multiParserResult @currentNode indexOfNode @processor @processorResult processImportFunctionImpl];
compareEntriesRec:     [currentMatchingNodeIndex @nestedToCur @curToNested @comparingMessage multiParserResult @currentNode indexOfNode @processor @processorResult compareEntriesRecImpl];
makeVariableType:      [multiParserResult @currentNode indexOfNode @processor @processorResult makeVariableTypeImpl];
compilerError:         [makeStringView multiParserResult @currentNode indexOfNode @processor @processorResult compilerErrorImpl];
generateDebugTypeId:   [multiParserResult @currentNode indexOfNode @processor @processorResult generateDebugTypeIdImpl];
generateIrTypeId:      [multiParserResult @currentNode indexOfNode @processor @processorResult generateIrTypeIdImpl];
getMplType: [
  result: String;
  @result multiParserResult @currentNode indexOfNode @processor @processorResult getMplTypeImpl
  @result
];

{
  signature: CFunctionSignature Cref;
  compilerPositionInfo: CompilerPositionInfo Cref;
  multiParserResult: MultiParserResult Cref;
  indexArray: IndexArray Cref;
  processor: Processor Ref;
  processorResult: ProcessorResult Ref;
  nodeCase: NodeCaseCode;
  parentIndex: 0;
  functionName: StringView Cref;
} 0 {convention: cdecl;} "astNodeToCodeNode" importFunction

{
  signature: CFunctionSignature Cref;
  compilerPositionInfo: CompilerPositionInfo Cref;
  multiParserResult: MultiParserResult Cref;
  processor: Processor Ref;
  processorResult: ProcessorResult Ref;
  refToVar: RefToVar Cref;
} () {convention: cdecl;} "createDtorForGlobalVar" importFunction

{
  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  indexOfNode: Int32;
  currentNode: CodeNode Ref;
  multiParserResult: MultiParserResult Cref;
  positionInfo: CompilerPositionInfo Cref;
  name: StringView Cref;
  nodeCase: NodeCaseCode;
  indexArray: IndexArray Cref;
} () {convention: cdecl;} "processCallByIndexArrayImpl" importFunction

{
  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  indexOfNode: Int32;
  currentNode: CodeNode Ref;
  multiParserResult: MultiParserResult Cref;
  index: Int32;
} () {convention: cdecl;} "callBuiltinImpl" importFunction

{
  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  indexOfNode: Int32;
  currentNode: CodeNode Ref;
  multiParserResult: MultiParserResult Cref;
  refToVar: RefToVar Cref;
} () {convention: cdecl;} "processFuncPtrImpl" importFunction

{
  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  indexOfNode: Int32;
  currentNode: CodeNode Ref;
  multiParserResult: MultiParserResult Cref;
  preAstNodeIndex: Int32;
} Cond {convention: cdecl;} "processPreImpl" importFunction

{
  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  indexOfNode: Int32;
  currentNode: CodeNode Ref;
  multiParserResult: MultiParserResult Cref;
  name: StringView Cref;
  callAstNodeIndex: Int32;
} () {convention: cdecl;} "processCallImpl" importFunction

{
  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  indexOfNode: Int32;
  currentNode: CodeNode Ref;
  multiParserResult: MultiParserResult Cref;
  asLambda: Cond;
  name: StringView Cref;
  astNode: AstNode Cref;
  signature: CFunctionSignature Cref;
} Int32 {convention: cdecl;} "processExportFunctionImpl" importFunction

{
  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  indexOfNode: Int32;
  currentNode: CodeNode Ref;
  multiParserResult: MultiParserResult Cref;
  asCodeRef: Cond;
  name: StringView Cref;
  signature: CFunctionSignature Cref;
} Int32 {convention: cdecl;} "processImportFunctionImpl" importFunction

{
  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  indexOfNode: Int32;
  currentNode: CodeNode Ref;
  multiParserResult: MultiParserResult Cref;

  comparingMessage: String Ref;
  curToNested: RefToVarTable Ref;
  nestedToCur: RefToVarTable Ref;
  currentMatchingNodeIndex: Int32;
  cacheEntry: RefToVar Cref;
  stackEntry: RefToVar Cref;
} Cond {convention: cdecl;} "compareEntriesRecImpl" importFunction

{
  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  indexOfNode: Int32;
  currentNode: CodeNode Ref;
  multiParserResult: MultiParserResult Cref;
  refToVar: RefToVar Cref;
} () {convention: cdecl;} "makeVariableTypeImpl" importFunction

{
  forMatching: Cond;
  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  indexOfNode: Int32;
  currentNode: CodeNode Ref;
  multiParserResult: MultiParserResult Cref;
  result: RefToVar Ref;
} () {convention: cdecl;} "popImpl" importFunction

{
  dynamicStoraged: Cond;

  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  indexOfNode: Int32;
  currentNode: CodeNode Ref;
  multiParserResult: MultiParserResult Cref;

  reason: Nat8;
  end: RefToVar Ref;
  begin: RefToVar Ref;
  refToVar: RefToVar Cref;
} () {convention: cdecl;} "makeShadowsImpl" importFunction

{
  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  indexOfNode: Int32;
  currentNode: CodeNode Ref;
  multiParserResult: MultiParserResult Cref;
  message: StringView Cref;
} () {convention: cdecl;} "compilerErrorImpl" importFunction

{
  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  indexOfNode: Int32;
  currentNode: CodeNode Ref;
  multiParserResult: MultiParserResult Cref;
  refToVar: RefToVar Cref;
} Int32 {} "generateDebugTypeIdImpl" importFunction

{
  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  indexOfNode: Int32;
  currentNode: CodeNode Ref;
  multiParserResult: MultiParserResult Cref;
  refToVar: RefToVar Cref;
} Int32 {} "generateIrTypeIdImpl" importFunction

{
  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  indexOfNode: Int32;
  currentNode: CodeNode Ref;
  multiParserResult: MultiParserResult Cref;
  resultMPL: String Ref;
  refToVar: RefToVar Cref;
} () {}  "getMplTypeImpl" importFunction


# these functions require capture "processor"
variableIsDeleted: [
  refToVar:;
  refToVar.varId refToVar.hostId @processor.@nodes.at.get.@variables.at.assigned not
];

getVar: [
  refToVar:;

  [
    refToVar.hostId 0 < not [refToVar.hostId processor.nodes.dataSize <] && [
      node: refToVar.hostId @processor.@nodes.at.get;
      sz: node.variables.dataSize copy;
      refToVar.varId 0  < not [refToVar.varId sz <] && [
        refToVar.varId node.variables.at.assigned [
          TRUE
        ] [
          ("deleted var data=" refToVar.hostId ":" refToVar.varId) addLog
          FALSE
        ] if
      ] [
        ("invalid var id=" refToVar.varId " of " sz) addLog
        FALSE
      ] if
    ] [
      ("invalid host id=" refToVar.hostId " of " processor.nodes.dataSize) addLog
      FALSE
    ] if
  ] "Wrong refToVar!" assert

  refToVar.varId refToVar.hostId @processor.@nodes.at.get.@variables.at.get
];

getNameById: [processor.nameBuffer.at makeStringView];
getMplName:  [getVar.mplNameId processor.nameInfos.at.name makeStringView];
getMplSchema: [getVar.mplSchemaId @processor.@schemaBuffer @];

getDbgType:  [getMplSchema.dbgTypeId getNameById];
getIrName:   [getVar.irNameId getNameById];
getIrType:   [getMplSchema.irTypeId getNameById];
getMplTypeId: [getMplType makeStringId];

getDebugType: [
  dbgType: getDbgType;
  splitted: dbgType.split;
  splitted.success [
    splitted.chars.getSize 1024 > [
      1024 @splitted.@chars.shrink
      "..." makeStringView @splitted.@chars.pushBack
    ] when
  ] [
    ("Wrong dbgType name encoding" splitted.chars assembleString) assembleString compilerError
  ] if
  result: (dbgType hash ".") assembleString;
  splitted.chars @result.catMany
  @result
];

staticityOfVar: [
  refToVar:;
  var: refToVar getVar;
  var.staticity copy
];

maxStaticity: [
  copy s1:;
  copy s2:;
  s1 s2 > [s1 copy][s2 copy] if
];

refsAreEqual: [
  refToVar1:;
  refToVar2:;
  refToVar1.hostId refToVar2.hostId = [refToVar1.varId refToVar2.varId =] &&
];

variablesAreSame: [
  refToVar1:;
  refToVar2:;
  refToVar1 getVar.mplSchemaId refToVar2 getVar.mplSchemaId = # id compare better than string compare!
];

isInt: [
  var: getVar;
  var.data.getTag VarInt8 =
  [var.data.getTag VarInt16 =] ||
  [var.data.getTag VarInt32 =] ||
  [var.data.getTag VarInt64 =] ||
  [var.data.getTag VarIntX =] ||
];

isNat: [
  var: getVar;
  var.data.getTag VarNat8 =
  [var.data.getTag VarNat16 =] ||
  [var.data.getTag VarNat32 =] ||
  [var.data.getTag VarNat64 =] ||
  [var.data.getTag VarNatX =] ||
];

isAnyInt: [
  refToVar:;
  refToVar isInt
  [refToVar isNat] ||
];

isReal: [
  var: getVar;
  var.data.getTag VarReal32 =
  [var.data.getTag VarReal64 =] ||
];

isNumber: [
  refToVar:;
  refToVar isReal
  [refToVar isAnyInt] ||
];

isPlain: [
  refToVar:;
  refToVar isNumber [
    var: refToVar getVar;
    var.data.getTag VarCond =
  ] ||
];

isTinyArg: [
  refToVar:;
  refToVar isPlain [
    var: refToVar getVar;
    var.data.getTag VarRef =
  ] ||
];

isUnallocable: [
  var: getVar;
  var.data.getTag VarString =
  [var.data.getTag VarImport =] ||
];

isStruct: [
  var: getVar;
  var.data.getTag VarStruct =
];

isAutoStruct: [
  refToVar:;
  var: refToVar getVar;
  var.data.getTag VarStruct =
  [VarStruct var.data.get.get.hasDestructor copy] &&
];

markAsUnableToDie: [
  refToVar:;
  var: refToVar getVar;
  var.data.getTag VarStruct = [TRUE VarStruct @var.@data.get.get.@unableToDie set] when
];

markAsAbleToDie: [
  refToVar:;
  var: refToVar getVar;
  var.data.getTag VarStruct = [FALSE VarStruct @var.@data.get.get.@unableToDie set] when
];

isSingle: [
  isStruct not
];

isStaticData: [
  refToVar:;
  var: refToVar getVar;
  refToVar isVirtual not [var.data.getTag VarStruct =] && [
    unfinished: RefToVar Array;
    refToVar @unfinished.pushBack
    result: TRUE dynamic;
    [
      result [unfinished.getSize 0 >] && [
        current: unfinished.last copy;
        @unfinished.popBack
        current isVirtual [
        ] [
          current isPlain [
            current staticityOfVar Weak < [
              FALSE dynamic @result set
            ] when
          ] [
            curVar: current getVar;
            curVar.data.getTag VarStruct = [
              struct: VarStruct curVar.data.get.get;
              struct.fields [.refToVar @unfinished.pushBack] each
            ] [
              FALSE dynamic @result set
            ] if
          ] if
        ] if
        TRUE
      ] &&
    ] loop
    result
  ] [
    FALSE
  ] if
];

getSingleDataStorageSize: [
  var: getVar;
  var.data.getTag (
    VarCond    [1nx]
    VarInt8    [1nx]
    VarInt16   [2nx]
    VarInt32   [4nx]
    VarInt64   [8nx]
    VarIntX    [processor.options.pointerSize 8nx /]
    VarNat8    [1nx]
    VarNat16   [2nx]
    VarNat32   [4nx]
    VarNat64   [8nx]
    VarNatX    [processor.options.pointerSize 8nx /]
    VarReal32  [4nx]
    VarReal64  [8nx]
    VarRef     [processor.options.pointerSize 8nx /]
    VarString  [
      "strings dont have storageSize and alignment" compilerError
      0nx
    ]
    VarImport  [
      "functions dont have storageSize and alignment" compilerError
      0nx
    ]
    [0nx]
  ) case
];

isNonrecursiveType: [
  refToVar:;
  refToVar isPlain [
    var: refToVar getVar;
    var.data.getTag VarString =
    [var.data.getTag VarCode =] ||
    [var.data.getTag VarBuiltin =] ||
    [var.data.getTag VarImport =] ||
  ] ||
];

isSemiplainNonrecursiveType: [
  refToVar:;
  refToVar isPlain [
    var: refToVar getVar;
    var.data.getTag VarCode =
    [var.data.getTag VarBuiltin =] ||
    [var.data.getTag VarImport =] ||
  ] ||
];

getPlainDataIRType: [
  var: getVar;
  result: String;
  var.data.getTag (
    VarCond  ["i1" toString @result set]
    VarInt8  ["i8" toString @result set]
    VarInt16 ["i16" toString @result set]
    VarInt32 ["i32" toString @result set]
    VarInt64 ["i64" toString @result set]
    VarIntX  [
      processor.options.pointerSize 64nx = [
        "i64" toString @result set
      ] [
        "i32" toString @result set
      ] if
    ]
    VarNat8  ["i8" toString @result set]
    VarNat16 ["i16" toString @result set]
    VarNat32 ["i32" toString @result set]
    VarNat64 ["i64" toString @result set]
    VarNatX  [
      processor.options.pointerSize 64nx = [
        "i64" toString @result set
      ] [
        "i32" toString @result set
      ] if
    ]
    VarReal32 ["float" toString @result set]
    VarReal64 ["double" toString @result set]
    [
      ("Tag = " var.data.getTag) addLog
      [FALSE] "Unknown plain struct while getting IR type" assert
    ]
  ) case

  @result
];

getPlainDataMPLType: [
  compileOnce
  var: getVar;
  result: String;
  var.data.getTag (
    VarCond   ["i1" toString @result set]
    VarInt8   ["i8" toString @result set]
    VarInt16  ["i16" toString @result set]
    VarInt32  ["i32" toString @result set]
    VarInt64  ["i64" toString @result set]
    VarIntX   ["ix" toString @result set]
    VarNat8   ["n8" toString @result set]
    VarNat16  ["n16" toString @result set]
    VarNat32  ["n32" toString @result set]
    VarNat64  ["n64" toString @result set]
    VarNatX   ["nx" toString @result set]
    VarReal32 ["r32" toString @result set]
    VarReal64 ["r64" toString @result set]
    [
      ("Tag = " var.data.getTag) addLog
      [FALSE] "Unknown plain struct MPL type" assert
    ]
  ) case

  @result
];

getNonrecursiveDataIRType: [
  compileOnce
  refToVar:;
  refToVar isPlain [
    refToVar getPlainDataIRType
  ] [
    result: String;
    var: refToVar getVar;
    var.data.getTag VarString = [
      "i8" toString @result set
    ] [
      var.data.getTag VarImport = [
        VarImport var.data.get getFuncIrType toString @result set
      ] [
        var.data.getTag VarCode = [var.data.getTag VarBuiltin =] ||  [
          "ERROR" toString @result set
        ] [
          "Unknown nonrecursive struct" makeStringView compilerError
        ] if
      ] if
    ] if
    @result
  ] if
];

getNonrecursiveDataMPLType: [
  compileOnce
  refToVar:;
  refToVar isPlain [
    refToVar getPlainDataMPLType
  ] [
    result: String;
    var: refToVar getVar;
    var.data.getTag VarString = [
      "s" toString @result set
    ] [
      var.data.getTag VarCode = [
        "c" toString @result set
      ] [
        var.data.getTag VarBuiltin = [
          "b" toString @result set
        ] [
          var.data.getTag VarImport = [
            ("F" VarImport var.data.get getFuncMplType) assembleString @result set
          ] [
            "Unknown nonrecursive struct" makeStringView compilerError
          ] if
        ] if
      ] if
    ] if
    @result
  ] if
];

getNonrecursiveDataDBGType: [
  compileOnce
  refToVar:;
  refToVar isPlain [
    refToVar getPlainDataMPLType
  ] [
    result: String;
    var: refToVar getVar;
    var.data.getTag VarString = [
      "s" toString @result set
    ] [
      var.data.getTag VarCode = [
        "c" toString @result set
      ] [
        var.data.getTag VarBuiltin = [
          "b" toString @result set
        ] [
          var.data.getTag VarImport = [
            ("F" VarImport var.data.get getFuncDbgType) assembleString @result set
          ] [
            "Unknown nonrecursive struct" makeStringView compilerError
          ] if
        ] if
      ] if
    ] if
    @result
  ] if
];

getStructStorageSize: [
  refToVar:;
  var: refToVar getVar;
  struct: VarStruct var.data.get.get;
  struct.structStorageSize copy
];

makeStructStorageSize: [
  refToVar:;
  result: 0nx;

  var: refToVar getVar;
  struct: VarStruct @var.@data.get.get;
  maxA: 1nx;
  j: 0;
  [
    j struct.fields.dataSize < [
      curField: j struct.fields.at;
      curField.refToVar isVirtual not [
        curS: curField.refToVar getStorageSize;
        curA: curField.refToVar getAlignment;
        result
        curA + 1nx - curA 1nx - not and
        curS +
        @result set

        curA maxA > [curA @maxA set] when
      ] when
      j 1 + @j set TRUE
    ] &&
  ] loop

  result
  maxA + 1nx - maxA 1nx - not and
  @result set

  result @struct.@structStorageSize set
];

getStorageSize: [
  refToVar:;
  refToVar isSingle [
    refToVar getSingleDataStorageSize
  ] [
    refToVar getStructStorageSize
  ] if
];

getStructAlignment: [
  refToVar:;
  var: refToVar getVar;
  struct: VarStruct var.data.get.get;
  struct.structAlignment copy
];

makeStructAlignment: [
  refToVar:;
  result: 0nx;

  var: refToVar getVar;
  struct: VarStruct @var.@data.get.get;
  j: 0;
  [
    j struct.fields.dataSize < [
      curField: j struct.fields.at;
      curField.refToVar isVirtual not [
        curA: curField.refToVar getAlignment;
        result curA < [curA @result set] when
      ] when
      j 1 + @j set TRUE
    ] &&
  ] loop
  result @struct.@structAlignment set
];

getAlignment: [
  refToVar:;
  refToVar isSingle [
    refToVar getSingleDataStorageSize
  ] [
    refToVar getStructAlignment
  ] if
];

isGlobal: [
  refToVar:;
  var: refToVar getVar;
  var.global copy
];

unglobalize: [
  refToVar:;
  var: refToVar getVar;
  var.global [
    FALSE @var.@global set
    -1 dynamic @var.@globalId set
    refToVar makeVariableIRName
  ] when
];

untemporize: [
  refToVar:;
  var: refToVar getVar;
  FALSE @var.@temporary set
];

fullUntemporize: [
  refToVar:;
  var: refToVar getVar;
  FALSE @var.@temporary set
  var.data.getTag VarStruct = [
    FALSE VarStruct @var.@data.get.get.@forgotten set
  ] when
];

isSchema: [
  refToVar:;
  var: refToVar getVar;
  var.data.getTag VarRef = [var.staticity Schema =] &&
];

isVirtualType: [
  refToVar:;

  var: refToVar getVar;
  var.data.getTag VarBuiltin =
  [var.data.getTag VarCode =] ||
  [var.data.getTag VarStruct = [VarStruct var.data.get.get.fullVirtual copy] &&] ||
  [refToVar isSchema] ||
];

isVirtual: [
  refToVar:;

  var: refToVar getVar;
  var.staticity Virtual < not
  [refToVar isVirtualType] ||
];

noMatterToCopy: [
  refToVar:;
  refToVar isVirtual [refToVar isAutoStruct not] &&
];

isForgotten: [
  refToVar:;
  var: refToVar getVar;
  var.data.getTag VarStruct = [
    VarStruct var.data.get.get.forgotten copy
  ] [
    FALSE
  ] if
];

getVirtualValue: [
  refToVar:;
  recursive
  var: refToVar getVar;
  result: String;

  var.data.getTag (
    VarStruct [
      "{" @result.cat
      struct: VarStruct var.data.get.get;

      struct.fields.getSize [
        i 0 > ["," @result.cat] when
        i struct.fields @ .refToVar isVirtual not [
          i struct.fields @ .refToVar getVirtualValue @result.cat
        ] when
      ] times
      "}" @result.cat
    ]
    VarCode    [
      info: VarCode    var.data.get;
      ("\"" info.moduleId processor.options.fileNames.at getStringImplementation "\"/" info.line ":" info.column) @result.catMany
    ]
    VarBuiltin [VarBuiltin var.data.get @result.cat]
    VarRef     [
      pointee: VarRef var.data.get;
      pointeeVar: pointee getVar;
      var.staticity Schema = [
        "." @result.cat
      ] [
        pointeeVar.data.getTag (
          VarString  [
            string: VarString pointeeVar.data.get;
            (string textSize "_" string getStringImplementation) @result.catMany
          ]
          VarImport  [VarImport  pointeeVar.data.get @result.cat]
          [[FALSE] "Wrong type for virtual reference!" assert]
        ) case
      ] if
    ]
    [
      refToVar isPlain [
        refToVar getPlainConstantIR @result.cat
      ] [
        ("Tag = " var.data.getTag) addLog
        [FALSE] "Wrong type for virtual value!" assert
      ] if
    ]
  ) case

  result
];

makeStringId: [
  string:;
  fr: string @processor.@nameTable.find;
  fr.success [
    fr.value copy
  ] [
    result: processor.nameBuffer.dataSize copy;
    string makeStringView result @processor.@nameTable.insert
    @string move @processor.@nameBuffer.pushBack
    result
  ] if
];

makeTypeAliasId: [
  irTypeName:;

  irTypeName.getTextSize 0 > [

    fr: irTypeName makeStringView @processor.@typeNames.find;
    fr.success [
      fr.value copy
    ] [
      newTypeName: ("%type." processor.lastTypeId) assembleString;
      processor.lastTypeId 1 + @processor.@lastTypeId set

      newTypeName irTypeName createTypeDeclaration
      result: @newTypeName makeStringId;
      @irTypeName move result @processor.@typeNames.insert
      result
    ] if
  ] [
    @irTypeName makeStringId
  ] if
];

getFuncIrType: [
  funcIndex:;
  node: funcIndex processor.nodes.at.get;
  resultId: node.signature toString makeStringId;
  resultId getNameById
];

getFuncMplType: [
  funcIndex:;
  result: String;
  node: funcIndex processor.nodes.at.get;

  catData: [
    args:;

    "[" @result.cat
    i: 0;
    [
      i args.getSize < [
        current: i args.at;
        current getMplType                                            @result.cat
        i 1 + args.getSize < [
          ","                                                         @result.cat
        ] when
        i 1 + @i set TRUE
      ] &&
    ] loop
    "]" @result.cat
  ];

  "-"                @result.cat
  node.mplConvention @result.cat
  node.csignature.inputs catData
  node.csignature.outputs catData

  @result
];

getFuncDbgType: [
  Index:;
  result: String;
  node:Index processor.nodes.at.get;

  catData: [
    args:;

    "[" @result.cat
    i: 0;
    [
      i args.getSize < [
        current: i args.at;
        current getDbgType                                            @result.cat
        i 1 + args.getSize < [
          ","                                                         @result.cat
        ] when
        i 1 + @i set TRUE
      ] &&
    ] loop
    "]" @result.cat
  ];

  "-"                @result.cat
  node.mplConvention @result.cat
  node.csignature.inputs catData
  node.csignature.outputs catData

  resultId: @result makeStringId;
  resultId getNameById
];

makeDbgTypeId: [
  refToVar:;
  refToVar isVirtualType not [
    varSchema: refToVar getMplSchema;
    varSchema.dbgTypeDeclarationId -1 = [
      refToVar getTypeDebugDeclaration @varSchema.@dbgTypeDeclarationId set
    ] when
  ] when
];

bitView: [
  copy f:;
  buffer: f storageAddress (0n8 0n8 0n8 0n8 0n8 0n8 0n8 0n8) addressToReference;
  result: String;
  "0x" @result.cat
  hexToStr: (
    "0" makeStringView "1" makeStringView "2" makeStringView "3" makeStringView "4" makeStringView
    "5" makeStringView "6" makeStringView "7" makeStringView "8" makeStringView "9" makeStringView
    "A" makeStringView "B" makeStringView "C" makeStringView "D" makeStringView "E" makeStringView "F" makeStringView);
  i: 0 dynamic;
  [
    i 0ix cast 0nx cast f storageSize < [
      d: f storageSize 0ix cast 0 cast i - 1 - buffer @ 0n32 cast;
      d 4n32 rshift 0 cast @hexToStr @ @result.cat
      d 15n32 and 0 cast @hexToStr @ @result.cat
      i 1 + @i set TRUE
    ] &&
  ] loop

  result
];

getPlainConstantIR: [
  var: getVar;
  result: String;
  var.data.getTag VarCond = [
    VarCond var.data.get ["true" toString] ["false" toString] if @result set
  ] [
    var.data.getTag VarInt8 = [VarInt8 var.data.get toString @result set] [
      var.data.getTag VarInt16 = [VarInt16 var.data.get toString @result set] [
        var.data.getTag VarInt32 = [VarInt32 var.data.get toString @result set] [
          var.data.getTag VarInt64 = [VarInt64 var.data.get toString @result set] [
            var.data.getTag VarIntX = [VarIntX var.data.get toString @result set] [
              var.data.getTag VarNat8 = [VarNat8 var.data.get toString @result set] [
                var.data.getTag VarNat16 = [VarNat16 var.data.get toString @result set] [
                  var.data.getTag VarNat32 = [VarNat32 var.data.get toString @result set] [
                    var.data.getTag VarNat64 = [VarNat64 var.data.get toString @result set] [
                      var.data.getTag VarNatX = [VarNatX var.data.get toString @result set] [
                        var.data.getTag VarReal32 = [VarReal32 var.data.get 0.0r32 cast 0.0r64 cast bitView @result set] [
                          var.data.getTag VarReal64 = [VarReal64 var.data.get bitView @result set] [
                            ("Tag = " makeStringView var.data.getTag 0 cast) addLog
                            [FALSE] "Unknown plain struct while getting IR value" assert
                          ] if
                        ] if
                      ] if
                    ] if
                  ] if
                ] if
              ] if
            ] if
          ] if
        ] if
      ] if
    ] if
  ] if

  result
];

{
  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  indexOfNode: Int32;
  currentNode: CodeNode Ref;
  multiParserResult: MultiParserResult Cref;
  refToVar: RefToVar Cref;
} () {} [
  processorResult:;
  processor:;
  copy indexOfNode:;
  currentNode:;
  multiParserResult:;
  failProc: @failProcForProcessor;
  refToVar:;

  #fill info:

  #struct.homogeneous
  #struct.fullVirtual
  #struct.hasPreField
  #struct.hasDestructor
  #struct.realFieldIndexes
  #struct.structAlignment
  #struct.structStorageSize
  #mplSchemaId

  var: refToVar getVar;
  var.data.getTag VarStruct = [
    branch: VarStruct @var.@data.get.get;
    realFieldCount: 0;

    @branch.@realFieldIndexes.clear
    TRUE @branch.@homogeneous set
    TRUE @branch.@fullVirtual set
    FALSE @branch.@hasPreField set
    FALSE @branch.@hasDestructor set

    i: 0 dynamic;
    branch.fields.dataSize [
      field0: 0 branch.fields.at;
      fieldi: i branch.fields.at;

      fieldi.nameInfo processor.preNameInfo = [
        TRUE @branch.@hasPreField set
      ] when

      fieldi.refToVar isVirtual [
        -1 @branch.@realFieldIndexes.pushBack
      ] [
        FALSE @branch.@fullVirtual set
        realFieldCount @branch.@realFieldIndexes.pushBack
        realFieldCount 1 + @realFieldCount set
      ] if

      field0.refToVar fieldi.refToVar variablesAreSame not [
        FALSE @branch.@homogeneous set
      ] when

      fieldi.nameInfo processor.dieNameInfo = [fieldi.refToVar isAutoStruct] || [
        TRUE @branch.@hasDestructor set
      ] when
    ] times

    refToVar makeStructAlignment
    refToVar makeStructStorageSize
  ] when

  var makeVariableSchema getVariableSchemaId @var.!mplSchemaId
  varSchema: refToVar getMplSchema;
  varSchema.irTypeId -1 = [
    refToVar generateIrTypeId @varSchema.!irTypeId
  ] when

  processor.options.debug [varSchema.dbgTypeId -1 =] && [
    refToVar generateDebugTypeId @varSchema.!dbgTypeId
    refToVar makeDbgTypeId
  ] when

] "makeVariableTypeImpl" exportFunction

{
  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  indexOfNode: Int32;
  currentNode: CodeNode Ref;
  multiParserResult: MultiParserResult Cref;
  refToVar: RefToVar Cref;
} Int32 {} [
  processorResult:;
  processor:;
  copy indexOfNode:;
  currentNode:;
  multiParserResult:;
  failProc: @failProcForProcessor;
  refToVar:;
  var: refToVar getVar;
  resultDBG: String;
  var.data.getTag (
    [drop refToVar isNonrecursiveType] [refToVar getNonrecursiveDataDBGType @resultDBG set]
    [VarRef =] [
      branch: VarRef var.data.get;
      pointee: branch getVar;
      branch getDbgType @resultDBG.cat
      "*" @resultDBG.cat
    ]
    [VarStruct =] [
      branch: VarStruct @var.@data.get.get;
      branch.fullVirtual ~ [
        "{" @resultDBG.cat
        branch.fields [
          curField:;
          curField.refToVar isVirtual ~ [
            (curField.nameInfo processor.nameInfos.at.name ":" curField.refToVar getDbgType ";") @resultDBG.catMany
          ] [
            (curField.nameInfo processor.nameInfos.at.name ".") @resultDBG.catMany
          ] if
        ] each

        "}" @resultDBG.cat
      ] when
    ]
    [[FALSE] "Unknown variable for IR type" assert]
  ) cond

  @resultDBG makeStringId
] "generateDebugTypeIdImpl" exportFunction

{
  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  indexOfNode: Int32;
  currentNode: CodeNode Ref;
  multiParserResult: MultiParserResult Cref;
  refToVar: RefToVar Cref;
} Int32 {} [
  processorResult:;
  processor:;
  copy indexOfNode:;
  currentNode:;
  multiParserResult:;
  failProc: @failProcForProcessor;
  refToVar:;
  var: refToVar getVar;
  resultIR: String;

  var.data.getTag (
    [drop refToVar isNonrecursiveType] [refToVar getNonrecursiveDataIRType @resultIR set]
    [VarRef =] [
      branch: VarRef var.data.get;
      pointee: branch getVar;

      branch getIrType @resultIR.cat
      "*"  @resultIR.cat
    ]
    [VarStruct =] [
      branch: VarStruct @var.@data.get.get;
      branch.fullVirtual ~ [
        branch.homogeneous [
          ("[" branch.fields.dataSize " x " 0 branch.fields.at.refToVar getIrType "]") @resultIR.catMany
        ] [
          "{" @resultIR.cat
          firstGood: TRUE;
          branch.fields [
            field:;
            field.refToVar isVirtual ~ [
              firstGood ~ [
                ", " @resultIR.cat
              ] when

              field.refToVar getIrType @resultIR.cat
              FALSE @firstGood set
            ] when
          ] each

          "}" @resultIR.cat
        ] if
      ] when
    ]
    [[FALSE] "Unknown variable for IR type" assert]
  ) cond

  irTypeId: Int32;
  var.data.getTag VarStruct = [var.data.getTag VarImport =] || [
    @resultIR makeTypeAliasId @irTypeId set
  ] [
    @resultIR makeStringId @irTypeId set
  ] if

  irTypeId
] "generateIrTypeIdImpl" exportFunction

{
  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  indexOfNode: Int32;
  currentNode: CodeNode Ref;
  multiParserResult: MultiParserResult Cref;
  resultMPL: String Ref;
  refToVar: RefToVar Cref;
} () {} [
  processorResult:;
  processor:;
  copy indexOfNode:;
  currentNode:;
  multiParserResult:;
  failProc: @failProcForProcessor;
  resultMPL:;

  refToVar:;
  var: refToVar getVar;

  refToVar isNonrecursiveType [
    refToVar getNonrecursiveDataMPLType @resultMPL set
  ] [
    var.data.getTag VarRef = [
      branch: VarRef var.data.get;
      pointee: branch getVar;
      branch getMplType @resultMPL.cat
      branch.mutable [
        "R" @resultMPL.cat
      ] [
        "C" @resultMPL.cat
      ] if
    ] [
      var.data.getTag VarStruct = [
        branch: VarStruct @var.@data.get.get;
        "{" @resultMPL.cat
        i: 0 dynamic;
        [
          i branch.fields.dataSize < [
            curField: i branch.fields.at;
            (
              curField.nameInfo processor.nameInfos.at.name ":"
              curField.refToVar getMplType ";") @resultMPL.catMany
            i 1 + @i set TRUE
          ] &&
        ] loop
        "}" @resultMPL.cat
      ] [
        [FALSE] "Unknown variable for IR type" assert
      ] if
    ] if
  ] if

  refToVar isVirtual [
    ir: refToVar getVirtualValue;
    "'" @resultMPL.cat
    ir @resultMPL.cat
  ] when

] "getMplTypeImpl" exportFunction

cutValue: [
  copy tag:;
  copy value:;
  tag (
    VarNat8  [value  0n8 cast 0n64 cast]
    VarNat16 [value 0n16 cast 0n64 cast]
    VarNat32 [value 0n32 cast 0n64 cast]
    VarNatX  [value processor.options.pointerSize 32nx = [0n32 cast 0n64 cast][copy] if]
    VarInt8  [value 0i8 cast 0i64 cast]
    VarInt16 [value 0i16 cast 0i64 cast]
    VarInt32 [value 0i32 cast 0i64 cast]
    VarIntX  [value processor.options.pointerSize 32nx = [0i32 cast 0i64 cast][copy] if]
    [@value copy]
  ) case
];

checkValue: [
  copy tag:;
  copy value:;
  tag (
    VarNat8  [value 0xFFn64 >]
    VarNat16 [value 0xFFFFn64 >]
    VarNat32 [value 0xFFFFFFFFn64 >]
    VarNatX  [processor.options.pointerSize 32nx = [value 0xFFFFFFFFn64 >] &&]
    VarInt8  [value 0x7Fi64 > [value 0x80i64 neg <] ||]
    VarInt16 [value 0x7FFFi64 > [value 0x8000i64 neg <] ||]
    VarInt32 [value 0x7FFFFFFFi64 > [value 0x80000000i64 neg <] ||]
    VarIntX  [processor.options.pointerSize 32nx = [value 0x7FFFFFFFi64 > [value 0x80000000i64 neg <] ||] &&]
    [FALSE]
  ) case ["number constant overflow" compilerError] when
  @value
];

zeroValue: [
  copy tag:;
  tag VarCond = [FALSE] [
    tag VarInt8 = [0i64] [
      tag VarInt16 = [0i64] [
        tag VarInt32 = [0i64] [
          tag VarInt64 = [0i64] [
            tag VarIntX = [0i64] [
              tag VarNat8 = [0n64] [
                tag VarNat16 = [0n64] [
                  tag VarNat32 = [0n64] [
                    tag VarNat64 = [0n64] [
                      tag VarNatX = [0n64] [
                        tag VarReal32 = [0.0r64] [
                          tag VarReal64 = [0.0r64] [
                            ("Tag = " makeStringView .getTag 0 cast) addLog
                            [FALSE] "Unknown plain struct while getting Zero value" assert
                          ] if
                        ] if
                      ] if
                    ] if
                  ] if
                ] if
              ] if
            ] if
          ] if
        ] if
      ] if
    ] if
  ] if
];

getStaticStructIR: [
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
          (current getIrType " " current getPlainConstantIR) @result.catMany
          [
            currentTerminator: unfinishedTerminators.last;
            currentTerminator @result.cat
            currentTerminator ", " = not
            @unfinishedTerminators.popBack
          ] loop
        ] [
          curVar: current getVar;
          curVar.data.getTag VarStruct = [
            (current getIrType " ") @result.catMany
            struct: VarStruct curVar.data.get.get;
            struct.homogeneous ["[" makeStringView] ["{" makeStringView] if @result.cat
            first: TRUE dynamic;
            struct.fields.getSize [
              current: struct.fields.getSize 1 - i - struct.fields.at.refToVar;
              current isVirtual not [
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

  result.getTextSize 2 - @result.@chars.shrink
  @result.makeZ
  result
];

# require captures "processor" and "codeNode"
generateVariableIRNameWith: [
  copy temporaryRegister:;
  copy hostId:;
  temporaryRegister not [currentNode.parent 0 =] && [
    ("@global." processor.globalVarCount) assembleString makeStringId
    processor.globalVarCount 1 + @processor.@globalVarCount set
  ] [
    hostNode: hostId @processor.@nodes.at.get;
    ("%var." hostNode.lastVarName) assembleString makeStringId
    hostNode.lastVarName 1 + @hostNode.@lastVarName set
  ] if
];

generateVariableIRName: [FALSE generateVariableIRNameWith];
generateRegisterIRName: [indexOfNode TRUE generateVariableIRNameWith];

makeVariableIRName: [
  refToVar:;
  var: refToVar getVar;

  refToVar.hostId refToVar isGlobal not generateVariableIRNameWith @var.@irNameId set
];

findFieldWithOverloadShift: [
  copy overloadShift:;
  refToVar:;
  copy fieldNameInfo:;

  var: refToVar getVar;

  result: {
    success: FALSE;
    index: -1;
  };

  var.data.getTag VarStruct = [
    struct: VarStruct var.data.get.get;
    i: struct.fields.dataSize copy dynamic;

    [
      i 0 > [
        i 1 - @i set

        i struct.fields.at .nameInfo fieldNameInfo = [
          overloadShift 0 = [
            TRUE @result.@success set
            i @result.@index set
            FALSE
          ] [
            overloadShift 1 - @overloadShift set
            TRUE
          ] if
        ] [
          TRUE
        ] if
      ] &&
    ] loop
  ] [
    (refToVar getMplType " is not combined") assembleString compilerError
  ] if

  result
];

findField: [0 dynamic findFieldWithOverloadShift];
