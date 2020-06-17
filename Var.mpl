
"Array.Array" use
"Owner.Owner" use
"String.String" use
"String.StringView" use
"String.addLog" use
"String.assembleString" use
"String.makeStringView" use
"String.toString" use
"Variant.Variant" use
"control" use

"Mref.Mref" use
"staticCall.staticCall" use

Dirty:   [0n8 dynamic];
Dynamic: [1n8 dynamic];
Weak:    [2n8 dynamic];
Static:  [3n8 dynamic];
Virtual: [4n8 dynamic];

ShadowReasonNo:           [0];
ShadowReasonCapture:      [1];
ShadowReasonFieldCapture: [2];
ShadowReasonInput:        [3];
ShadowReasonField:        [4];
ShadowReasonPointee:      [5];

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
  file:   ["File.FileSchema" use FileSchema] Mref;
  line:   Int32;
  column: Int32;
  index:  Int32;

  equal: [other:; index other.index =];
}];

Field: [{
  usedHere: FALSE dynamic;
  nameInfo: -1 dynamic; # NameInfo id
  #nameOverload: -1 dynamic;
  refToVar: RefToVar;
}];

FieldArray: [Field Array];

Struct: [{
  fullVirtual:   FALSE dynamic;
  homogeneous:   FALSE dynamic;
  hasPreField:   FALSE dynamic;
  unableToDie:   FALSE dynamic;
  hasDestructor: FALSE dynamic;
  realFieldIndexes: Int32 Array;
  fields: FieldArray;
  structStorageSize: 0nx dynamic;
  structAlignment: 0nx dynamic;
}]; #IDs of pointee vars

makeRefBranch: [{
  refToVar: copy;
  usedHere: FALSE dynamic;
}];

RefBranch: [RefToVar makeRefBranch];

RefToVar: [{
  data: Natx;

  var: [
    data 3nx ~ and @VarSchema addressToReference
  ];

  mutable: [
    data 1nx and 1nx =
  ];

  moved: [
    data 2nx and 2nx =
  ];

  setVar: [
    newVar:;
    newVar VarSchema Ref same ~ ["variable expected" raiseStaticError] when
    newVar isConst ~ ["mutable variable expected" raiseStaticError] when
    address: newVar storageAddress;
    [address 3nx and 0nx =] "Address is not aligned!" assert
    address data 3nx and or !data
  ];

  setMutable: [
    copy newMutable:;
    newMutable [1nx] [0nx] if data 1nx ~ and or !data
  ];

  setMoved: [
    copy newMoved:;
    newMoved [2nx] [0nx] if data 2nx ~ and or !data
  ];

  assigned: [data 3nx ~ and 0nx = ~];
  equal: [other:; var other.var is];
  hash: [address: var storageAddress; address 32n32 rshift address + Nat32 cast];
} dynamic];

makeValuePair: [
  type:;
  {
    begin: type copy;
    end: type copy;
  }
];

Variable: [{
  VARIABLE: ();

  host:                              ["Block.BlockSchema" use @BlockSchema] Mref;
  mplNameId:                         -1 dynamic;
  irNameId:                          -1 dynamic;
  mplSchemaId:                       -1 dynamic;
  storageStaticity:                  Static;
  global:                            FALSE dynamic;
  usedInHeader:                      FALSE dynamic;
  capturedByPtr:                     FALSE dynamic;
  capturedAsRealValue:               FALSE dynamic;
  capturedForDeref:                  FALSE dynamic;
  globalId:                          -1 dynamic;
  buildingTopologyIndex:             -1 dynamic;
  topologyIndex:                     -1 dynamic;
  topologyIndexWhileMatching:        -1 dynamic;
  topologyIndexWhileMatching2:       -1 dynamic;

  capturedHead:                      RefToVar;
  capturedTail:                      RefToVar;
  capturedPrev:                      RefToVar;
  realValue:                         RefToVar;
  sourceOfValue:                     RefToVar;
  globalDeclarationInstructionIndex: -1 dynamic;
  allocationInstructionIndex:        -1 dynamic;
  getInstructionIndex:               -1 dynamic;

  staticity:                         Static makeValuePair;
  tref:                              TRUE dynamic;
  temporary:                         TRUE dynamic;

  data: (
    Nat8                   #VarInvalid
    Cond        makeValuePair  #VarCond
    Nat64       makeValuePair  #VarNat8
    Nat64       makeValuePair  #VarNat16
    Nat64       makeValuePair  #VarNat32
    Nat64       makeValuePair  #VarNat64
    Nat64       makeValuePair  #VarNatX
    Int64       makeValuePair  #VarInt8
    Int64       makeValuePair  #VarInt16
    Int64       makeValuePair  #VarInt32
    Int64       makeValuePair  #VarInt64
    Int64       makeValuePair  #VarIntX
    Real64      makeValuePair  #VarReal32
    Real64      makeValuePair  #VarReal64
    CodeNodeInfo               #VarCode; id of node
    Int32                      #VarBuiltin
    Int32                      #VarImport
    String                     #VarString
    RefBranch                  #VarRef
    Struct Owner               #VarStruct
  ) Variant;

  INIT: [];
  DIE: [];
}];

virtual VarSchema: Variable Ref;

getVar: [
  refToVar:;
  [refToVar.assigned] "Wrong refToVar!" assert
  @refToVar.var
];

isVirtual: [
  refToVar:;

  var: refToVar getVar;
  var.staticity.end Virtual < ~
  [refToVar isVirtualType] ||
];

isVirtualType: [
  refToVar:;

  var: refToVar getVar;
  var.data.getTag VarBuiltin =
  [var.data.getTag VarCode =] ||
  [var.data.getTag VarInvalid =] ||
  [var.data.getTag VarStruct = [VarStruct var.data.get.get.fullVirtual copy] &&] ||
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
  refToVar: processor: ;;
  #refToVar isPlain [
  #  var: refToVar getVar;
  #  var.data.getTag VarRef =
  #] ||

  refToVar isUnallocable ~
  [refToVar @processor getStorageSize processor.options.pointerSize 8nx / 2nx * > ~] &&
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

isSingle: [
  isStruct ~
];

isAutoStruct: [
  refToVar:;
  var: refToVar getVar;
  var.data.getTag VarStruct =
  [VarStruct var.data.get.get.hasDestructor copy] &&
];

getVirtualValue: [
  refToVar:;
  recursive
  var: refToVar getVar;
  result: String;

  var.data.getTag (
    VarInvalid ["INVALID" toString @result set]
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
      pointee: VarRef var.data.get.refToVar;
      pointeeVar: pointee getVar;
      pointeeVar.storageStaticity Virtual = [
        "." @result.cat
      ] [
        pointeeVar.data.getTag (
          VarString  [
            string: VarString pointeeVar.data.get.getStringView;
            (string.size "_" string getStringImplementation) @result.catMany
          ]
          VarImport  [VarImport  pointeeVar.data.get @result.cat]
          [
            [FALSE] "Wrong type for virtual reference!" assert
          ]
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

getStringImplementation: [
  stringView:;
  [
    result: String;
    i: 0 dynamic;
    [
      i stringView.size < [
        codeRef: stringView.data i Natx cast + Nat8 addressToReference;
        code: codeRef copy;
        code 32n8 < ~ [code 127n8 <] && [code 34n8 = ~] && [code 92n8 = ~] && [  # exclude " and \
          code 0n32 cast @result.catSymbolCode
        ] [
          "\\" @result.cat
          code 16n8 < ["0"   @result.cat] when
          code @result.catHex
        ] if
        i 1 + @i set TRUE
      ] &&
    ] loop
    result
  ] call
];

isNonrecursiveType: [
  refToVar:;
  refToVar isPlain [
    var: refToVar getVar;
    var.data.getTag VarString =
    [var.data.getTag VarInvalid =] ||
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

getPlainConstantIR: [
  var: getVar;
  result: String;
  var.data.getTag VarCond = [
    VarCond var.data.get.end ["true" toString] ["false" toString] if @result set
  ] [
    var.data.getTag VarInt8 = [VarInt8 var.data.get.end toString @result set] [
      var.data.getTag VarInt16 = [VarInt16 var.data.get.end toString @result set] [
        var.data.getTag VarInt32 = [VarInt32 var.data.get.end toString @result set] [
          var.data.getTag VarInt64 = [VarInt64 var.data.get.end toString @result set] [
            var.data.getTag VarIntX = [VarIntX var.data.get.end toString @result set] [
              var.data.getTag VarNat8 = [VarNat8 var.data.get.end toString @result set] [
                var.data.getTag VarNat16 = [VarNat16 var.data.get.end toString @result set] [
                  var.data.getTag VarNat32 = [VarNat32 var.data.get.end toString @result set] [
                    var.data.getTag VarNat64 = [VarNat64 var.data.get.end toString @result set] [
                      var.data.getTag VarNatX = [VarNatX var.data.get.end toString @result set] [
                        var.data.getTag VarReal32 = [VarReal32 var.data.get.end Real32 cast Real64 cast bitView @result set] [
                          var.data.getTag VarReal64 = [VarReal64 var.data.get.end bitView @result set] [
                            ("Tag = " makeStringView var.data.getTag Int32 cast) addLog
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

getPlainValueInformation: [
  var: getVar;
  result: String;

  var.staticity.end Weak < [
    " dynamic" toString !result
  ] [
    var.data.getTag  VarCond VarReal64 1 + [
      copy tag:;
      branch: tag var.data.get;
      (" static: " branch.end) assembleString !result
    ] staticCall
  ] if
  result
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
    i Natx cast f storageSize < [
      d: f storageSize Int32 cast i - 1 - buffer @ Nat32 cast;
      d 4n32 rshift Int32 cast @hexToStr @ @result.cat
      d 15n32 and Int32 cast @hexToStr @ @result.cat
      i 1 + @i set
      TRUE
    ] &&
  ] loop

  result
];

getSingleDataStorageSize: [
  refToVar: processor: ;;
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
      0nx
    ]
    VarImport  [
      0nx
    ]
    [0nx]
  ) case
];

getStructStorageSize: [
  refToVar: processor: ;;
  var: refToVar getVar;
  struct: VarStruct var.data.get.get;
  struct.structStorageSize copy
];

getStorageSize: [
  refToVar: processor: ;;
  refToVar isSingle [
    refToVar @processor getSingleDataStorageSize
  ] [
    refToVar @processor getStructStorageSize
  ] if
];

getStructAlignment: [
  refToVar: processor: ;;
  var: refToVar getVar;
  struct: VarStruct var.data.get.get;
  struct.structAlignment copy
];

getAlignment: [
  refToVar: processor: ;;
  refToVar isSingle [
    refToVar @processor getSingleDataStorageSize
  ] [
    refToVar @processor getStructAlignment
  ] if
];

makeStringId: [
  string: processor: ;;
  fr: string @processor.@nameTable.find;
  fr.success [
    fr.value copy
  ] [
    result: processor.nameBuffer.size;
    string makeStringView result @processor.@nameTable.insert
    @string move @processor.@nameBuffer.pushBack
    result
  ] if
];

markAsUnableToDie: [
  refToVar:;
  var: @refToVar getVar;
  var.data.getTag VarStruct = [TRUE VarStruct @var.@data.get.get.@unableToDie set] when
];

varIsMoved: [
  refToVar:;
  refToVar.moved
];

variablesAreSame: [
  refToVar1:;
  refToVar2:;
  refToVar1 getVar.mplSchemaId refToVar2 getVar.mplSchemaId = # id compare better than string compare!
];

staticityOfVar: [
  refToVar:;
  var: refToVar getVar;
  var.staticity.end copy
];

fullUntemporize: [
  refToVar:;
  var: @refToVar getVar;
  FALSE @var.@temporary set
  FALSE @refToVar.setMoved
];
