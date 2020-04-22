"Array.Array" use
"HashTable.hash" use
"String.String" use
"String.StringView" use
"String.addLog" use
"String.asView" use
"String.assembleString" use
"String.hash" use
"String.makeStringView" use
"String.print" use
"String.splitString" use
"String.toString" use
"control" use
"conventions.cdecl" use

"Block.Block" use
"Block.CFunctionSignature" use
"Block.CompilerPositionInfo" use
"Block.NameCaseInvalid" use
"Block.NodeCaseCode" use
"File.File" use
"Var.RefToVar" use
"Var.Schema" use
"Var.VarBuiltin" use
"Var.VarCode" use
"Var.VarCond" use
"Var.VarImport" use
"Var.VarInt8" use
"Var.VarInt16" use
"Var.VarInt32" use
"Var.VarInt64" use
"Var.VarIntX" use
"Var.VarNat8" use
"Var.VarNat16" use
"Var.VarNat32" use
"Var.VarNat64" use
"Var.VarNatX" use
"Var.VarReal32" use
"Var.VarReal64" use
"Var.VarRef" use
"Var.VarString" use
"Var.VarStruct" use
"Var.Variable" use
"Var.Virtual" use
"astNodeType.AstNode" use
"astNodeType.IndexArray" use
"astNodeType.MultiParserResult" use
"debugWriter.getTypeDebugDeclaration" use
"defaultImpl.failProcForProcessor" use
"irWriter.createTypeDeclaration" use
"irWriter.getStringImplementation" use
"processor.Processor" use
"processor.ProcessorResult" use
"processor.RefToVarTable" use
"schemas.getVariableSchemaId" use
"schemas.hash" use
"schemas.makeVariableSchema" use

NameCaseSelfMember:            [ 5n8 dynamic];
NameCaseClosureMember:         [ 6n8 dynamic];
NameCaseSelfObject:            [ 7n8 dynamic];
NameCaseClosureObject:         [ 8n8 dynamic];
NameCaseSelfObjectCapture:     [ 9n8 dynamic];
NameCaseClosureObjectCapture:  [10n8 dynamic];

MemberCaseToObjectCase:        [2n8 +];
MemberCaseToObjectCaptureCase: [4n8 +];

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

compilable: [processorResult.success copy];

callBuiltin:           [block:; multiParserResult @block @processor @processorResult callBuiltinImpl];
processFuncPtr:        [multiParserResult @block @processor @processorResult processFuncPtrImpl];

processPre: [
  preAstNodeIndex: file:;;
  preAstNodeIndex file multiParserResult @block @processor @processorResult processPreImpl
];

processCall: [
  callAstNodeIndex: file: name:;;;
  callAstNodeIndex file name multiParserResult @block @processor @processorResult processCallImpl
];

processExportFunction: [
  signature: astNode: file: name: asLambda: block:;;;;;;
  signature astNode file name asLambda multiParserResult @block @processor @processorResult processExportFunctionImpl
];

processImportFunction: [multiParserResult @block @processor @processorResult processImportFunctionImpl];
compareEntriesRec:     [currentMatchingNode @nestedToCur @curToNested @comparingMessage multiParserResult block @processor @processorResult compareEntriesRecImpl];
makeVariableType:      [block:; block @processor @processorResult makeVariableTypeImpl];
compilerError:         [block:; makeStringView block @processor @processorResult compilerErrorImpl];
generateDebugTypeId:   [block:; block @processor @processorResult generateDebugTypeIdImpl];
generateIrTypeId:      [block:; block @processor @processorResult generateIrTypeIdImpl];
getMplType: [
  block:;
  result: String;
  @result block @processor @processorResult getMplTypeImpl
  @result
];

{
  signature: CFunctionSignature Cref;
  compilerPositionInfo: CompilerPositionInfo Cref;
  multiParserResult: MultiParserResult Cref;
  file: File Cref;
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
  block: Block Ref;
  multiParserResult: MultiParserResult Cref;
  positionInfo: CompilerPositionInfo Cref;
  name: StringView Cref;
  nodeCase: NodeCaseCode;
  file: File Cref;
  indexArray: IndexArray Cref;
} () {convention: cdecl;} "processCallByIndexArrayImpl" importFunction

{
  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  block: Block Ref;
  multiParserResult: MultiParserResult Cref;
  index: Int32;
} () {convention: cdecl;} "callBuiltinImpl" importFunction

{
  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  block: Block Ref;
  multiParserResult: MultiParserResult Cref;
  refToVar: RefToVar Cref;
} () {convention: cdecl;} "processFuncPtrImpl" importFunction

{
  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  block: Block Ref;
  multiParserResult: MultiParserResult Cref;
  file: File Cref;
  preAstNodeIndex: Int32;
} Cond {convention: cdecl;} "processPreImpl" importFunction

{
  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  block: Block Ref;
  multiParserResult: MultiParserResult Cref;
  name: StringView Cref;
  file: File Cref;
  callAstNodeIndex: Int32;
} () {convention: cdecl;} "processCallImpl" importFunction

{
  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  block: Block Ref;
  multiParserResult: MultiParserResult Cref;
  asLambda: Cond;
  name: StringView Cref;
  file: File Cref;
  astNode: AstNode Cref;
  signature: CFunctionSignature Cref;
} Int32 {convention: cdecl;} "processExportFunctionImpl" importFunction

{
  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  block: Block Ref;
  multiParserResult: MultiParserResult Cref;
  asCodeRef: Cond;
  name: StringView Cref;
  signature: CFunctionSignature Cref;
} Natx {convention: cdecl;} "processImportFunctionImpl" importFunction

{
  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  block: Block Cref;
  multiParserResult: MultiParserResult Cref;

  comparingMessage: String Ref;
  curToNested: RefToVarTable Ref;
  nestedToCur: RefToVarTable Ref;
  currentMatchingNode: Block Cref;
  cacheEntry: RefToVar Cref;
  stackEntry: RefToVar Cref;
} Cond {convention: cdecl;} "compareEntriesRecImpl" importFunction

{
  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  block: Block Cref;
  refToVar: RefToVar Cref;
} () {convention: cdecl;} "makeVariableTypeImpl" importFunction

{
  forMatching: Cond;
  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  block: Block Ref;
  multiParserResult: MultiParserResult Cref;
  result: RefToVar Ref;
} () {convention: cdecl;} "popImpl" importFunction

{
  dynamicStoraged: Cond;

  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  block: Block Ref;
  multiParserResult: MultiParserResult Cref;

  reason: Nat8;
  end: RefToVar Ref;
  begin: RefToVar Ref;
  refToVar: RefToVar Cref;
} () {convention: cdecl;} "makeShadowsImpl" importFunction

{
  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  block: Block Cref;
  message: StringView Cref;
} () {convention: cdecl;} "compilerErrorImpl" importFunction

{
  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  block: Block Cref;
  refToVar: RefToVar Cref;
} Int32 {} "generateDebugTypeIdImpl" importFunction

{
  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  block: Block Cref;
  refToVar: RefToVar Cref;
} Int32 {} "generateIrTypeIdImpl" importFunction

{
  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  block: Block Cref;
  resultMPL: String Ref;
  refToVar: RefToVar Cref;
} () {}  "getMplTypeImpl" importFunction

# these functions require capture "processor"
getVar: [
  refToVar:;
  [refToVar.assigned] "Wrong refToVar!" assert
  @refToVar.var
];

getNameById: [processor.nameBuffer.at makeStringView];
getMplName:  [getVar.mplNameId processor.nameInfos.at.name makeStringView];
getMplSchema: [getVar.mplSchemaId @processor.@schemaBuffer.at];

getDbgType:  [getMplSchema.dbgTypeId getNameById];
getIrName:   [getVar.irNameId getNameById];
getIrType:   [getMplSchema.irTypeId getNameById];
getMplTypeId: [getMplType makeStringId];

getDebugType: [
  refToVar: block:;;
  dbgType: refToVar getDbgType;
  splitted: dbgType splitString;
  splitted.success [
    splitted.chars.getSize 1024 > [
      1024 @splitted.@chars.shrink
      "..." makeStringView @splitted.@chars.pushBack
    ] when
  ] [
    ("Wrong dbgType name encoding" splitted.chars assembleString) assembleString block compilerError
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
  refToVar1.var refToVar2.var is
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
  var: @refToVar getVar;
  var.data.getTag VarStruct = [TRUE VarStruct @var.@data.get.get.@unableToDie set] when
];

markAsAbleToDie: [
  refToVar:;
  var: @refToVar getVar;
  var.data.getTag VarStruct = [FALSE VarStruct @var.@data.get.get.@unableToDie set] when
];

isSingle: [
  isStruct ~
];

isStaticData: [
  refToVar:;
  var: refToVar getVar;
  refToVar isVirtual ~ [var.data.getTag VarStruct =] && [
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
  refToVar: block:;;
  var: refToVar getVar;
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
      "strings dont have storageSize and alignment" block compilerError
      0nx
    ]
    VarImport  [
      "functions dont have storageSize and alignment" block compilerError
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
  refToVar: block:;;
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
          "Unknown nonrecursive struct" block compilerError
        ] if
      ] if
    ] if

    @result
  ] if
];

getNonrecursiveDataMPLType: [
  refToVar: block:;;
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
            ("F" VarImport var.data.get block getFuncMplType) assembleString @result set
          ] [
            "Unknown nonrecursive struct" block compilerError
          ] if
        ] if
      ] if
    ] if

    @result
  ] if
];

getNonrecursiveDataDBGType: [
  refToVar: block:;;
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
            "Unknown nonrecursive struct" block compilerError
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
  refToVar: block:;;
  result: 0nx;
  var: @refToVar getVar;
  struct: VarStruct @var.@data.get.get;
  maxA: 1nx;
  j: 0;
  [
    j struct.fields.dataSize < [
      curField: j struct.fields.at;
      curField.refToVar isVirtual ~ [
        curS: curField.refToVar block getStorageSize;
        curA: curField.refToVar block getAlignment;
        result curA + 1nx - curA 1nx - ~ and curS + @result set
        curA maxA > [curA @maxA set] when
      ] when

      j 1 + @j set TRUE
    ] &&
  ] loop

  result maxA + 1nx - maxA 1nx - ~ and @result set
  result @struct.@structStorageSize set
];

getStorageSize: [
  refToVar: block:;;
  refToVar isSingle [
    refToVar block getSingleDataStorageSize
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
  refToVar: block:;;
  result: 0nx;
  var: @refToVar getVar;
  struct: VarStruct @var.@data.get.get;
  j: 0;
  [
    j struct.fields.dataSize < [
      curField: j struct.fields.at;
      curField.refToVar isVirtual ~ [
        curA: curField.refToVar block getAlignment;
        result curA < [curA @result set] when
      ] when
      j 1 + @j set TRUE
    ] &&
  ] loop

  result @struct.@structAlignment set
];

getAlignment: [
  refToVar: block:;;
  refToVar isSingle [
    refToVar block getSingleDataStorageSize
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
  refToVar: block:;;
  var: @refToVar getVar;
  var.global [
    FALSE @var.@global set
    -1 dynamic @var.@globalId set
    @refToVar block makeVariableIRName
  ] when
];

untemporize: [
  refToVar:;
  var: @refToVar getVar;
  FALSE @var.@temporary set
];

fullUntemporize: [
  refToVar:;
  var: @refToVar getVar;
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
  var.staticity Virtual < ~
  [refToVar isVirtualType] ||
];

noMatterToCopy: [
  refToVar:;
  refToVar isVirtual [refToVar isAutoStruct ~] &&
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
        i struct.fields.at .refToVar isVirtual ~ [
          i struct.fields.at .refToVar getVirtualValue @result.cat
        ] when
      ] times
      "}" @result.cat
    ]
    VarCode    [
      info: VarCode    var.data.get;
      ("\"" info.file.name getStringImplementation "\"/" info.line ":" info.column) @result.catMany
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
            string: VarString pointeeVar.data.get.getStringView;
            (string.size "_" string getStringImplementation) @result.catMany
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
  node: funcIndex processor.blocks.at.get;
  resultId: node.signature toString makeStringId;
  resultId getNameById
];

getFuncMplType: [
  funcIndex: block:;;
  result: String;
  node: funcIndex processor.blocks.at.get;

  catData: [
    args:;

    "[" @result.cat
    i: 0;
    [
      i args.getSize < [
        current: i args.at;
        current block getMplType @result.cat
        i 1 + args.getSize < [
          "," @result.cat
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
  node: Index processor.blocks.at.get;

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
  refToVar: block:;;
  refToVar isVirtualType ~ [
    varSchema: refToVar getMplSchema;
    varSchema.dbgTypeDeclarationId -1 = [
      refToVar block getTypeDebugDeclaration @varSchema.@dbgTypeDeclarationId set
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
  block: Block Cref;
  refToVar: RefToVar Ref;
} () {} [
  processorResult:;
  processor:;
  block:;
  refToVar:;
  failProc: @failProcForProcessor;

  #fill info:

  #struct.homogeneous
  #struct.fullVirtual
  #struct.hasPreField
  #struct.hasDestructor
  #struct.realFieldIndexes
  #struct.structAlignment
  #struct.structStorageSize
  #mplSchemaId

  var: @refToVar getVar;
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

      field0.refToVar fieldi.refToVar variablesAreSame ~ [
        FALSE @branch.@homogeneous set
      ] when

      fieldi.nameInfo processor.dieNameInfo = [fieldi.refToVar isAutoStruct] || [
        TRUE @branch.@hasDestructor set
      ] when
    ] times

    @refToVar block makeStructAlignment
    @refToVar block makeStructStorageSize
  ] when

  var makeVariableSchema getVariableSchemaId @var.!mplSchemaId
  varSchema: refToVar getMplSchema;
  varSchema.irTypeId -1 = [
    refToVar block generateIrTypeId @varSchema.!irTypeId
  ] when

  processor.options.debug [varSchema.dbgTypeId -1 =] && [
    refToVar block generateDebugTypeId @varSchema.!dbgTypeId
    refToVar block makeDbgTypeId
  ] when
] "makeVariableTypeImpl" exportFunction

{
  processorResult: ProcessorResult Ref;
  processor: Processor Ref;
  block: Block Cref;
  refToVar: RefToVar Cref;
} Int32 {} [
  processorResult:;
  processor:;
  block:;
  refToVar:;
  failProc: @failProcForProcessor;
  var: refToVar getVar;
  resultDBG: String;
  var.data.getTag (
    [drop refToVar isNonrecursiveType] [refToVar block getNonrecursiveDataDBGType @resultDBG set]
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
  block: Block Cref;
  refToVar: RefToVar Cref;
} Int32 {} [
  processorResult:;
  processor:;
  block:;
  refToVar:;
  failProc: @failProcForProcessor;
  var: refToVar getVar;
  resultIR: String;

  var.data.getTag (
    [drop refToVar isNonrecursiveType] [refToVar block getNonrecursiveDataIRType @resultIR set]
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
  block: Block Cref;
  resultMPL: String Ref;
  refToVar: RefToVar Cref;
} () {} [
  processorResult:;
  processor:;
  block:;
  resultMPL:;
  failProc: @failProcForProcessor;

  refToVar:;
  var: refToVar getVar;

  refToVar isNonrecursiveType [
    refToVar block getNonrecursiveDataMPLType @resultMPL set
  ] [
    var.data.getTag VarRef = [
      branch: VarRef var.data.get;
      pointee: branch getVar;
      branch block getMplType @resultMPL.cat
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
              curField.refToVar block getMplType ";") @resultMPL.catMany
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
  ) case ["number constant overflow" block compilerError] when
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
            currentTerminator ", " = ~
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
              current isVirtual ~ [
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
  hostOfVariable: temporaryRegister: block:;;;
  temporaryRegister ~ [block.parent 0 =] && [
    ("@global." processor.globalVarCount) assembleString makeStringId
    processor.globalVarCount 1 + @processor.@globalVarCount set
  ] [
    ("%var." hostOfVariable.lastVarName) assembleString makeStringId
    hostOfVariable.lastVarName 1 + @hostOfVariable.@lastVarName set
  ] if
];

generateVariableIRName: [FALSE generateVariableIRNameWith];
generateRegisterIRName: [block:; @block TRUE block generateVariableIRNameWith];

makeVariableIRName: [
  refToVar: block:;;
  var: @refToVar getVar;
  @var.host refToVar isGlobal ~ block generateVariableIRNameWith @var.@irNameId set
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
    (refToVar block getMplType " is not combined") assembleString block compilerError
  ] if

  result
];

findField: [0 dynamic findFieldWithOverloadShift];
