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
"Var.Dirty" use
"Var.Dynamic" use
"Var.RefToVar" use
"Var.Schema" use
"Var.Schema" use
"Var.Static" use
"Var.VarBuiltin" use
"Var.VarCode" use
"Var.VarCond" use
"Var.VarImport" use
"Var.VarInt16" use
"Var.VarInt32" use
"Var.VarInt64" use
"Var.VarInt8" use
"Var.VarIntX" use
"Var.VarInvalid" use
"Var.VarNat16" use
"Var.VarNat32" use
"Var.VarNat64" use
"Var.VarNat8" use
"Var.VarNatX" use
"Var.VarReal32" use
"Var.VarReal64" use
"Var.VarRef" use
"Var.VarString" use
"Var.VarStruct" use
"Var.Variable" use
"Var.Virtual" use
"Var.Virtual" use
"Var.Weak" use
"Var.getAlignment" use
"Var.getSingleDataStorageSize" use
"Var.getStorageSize" use
"Var.getStringImplementation" use
"Var.getStructStorageSize" use
"Var.getVar" use
"Var.getVirtualValue" use
"Var.isAutoStruct" use
"Var.isNonrecursiveType" use
"Var.isPlain" use
"Var.isSingle" use
"Var.isStruct" use
"Var.isVirtual" use
"Var.isVirtualType" use
"Var.makeStringId" use
"Var.staticityOfVar" use
"Var.variablesAreSame" use
"astNodeType.AstNode" use
"astNodeType.IndexArray" use
"debugWriter.getDbgType" use
"debugWriter.getTypeDebugDeclaration" use
"declarations.compilerError" use
"declarations.generateDebugTypeId" use
"declarations.generateIrTypeId" use
"declarations.getMplType" use
"defaultImpl.FailProcForProcessor" use
"irWriter.createTypeDeclaration" use
"irWriter.generateRegisterIRName" use
"irWriter.generateVariableIRNameWith" use
"irWriter.getIrType" use
"irWriter.getMplSchema" use
"irWriter.getNameById" use
"processor.Processor" use
"processor.ProcessorResult" use
"processor.RefToVarTable" use
"schemas.getVariableSchemaId" use
"schemas.makeVariableSchema" use

Overload: [NameInfoEntry Array];

makeNameInfo: [{
  name: copy;
  stack: Overload Array;
}];

NameInfo: [String makeNameInfo];

getMplName:  [getVar.mplNameId processor.nameManager.getText];
getMplTypeId: [@processor getMplType makeStringId];

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

markAsAbleToDie: [
  refToVar:;
  var: @refToVar getVar;
  var.data.getTag VarStruct = [FALSE VarStruct @var.@data.get.get.@unableToDie set] when
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

checkUnsizedData: [
  refToVar: processor: block: ;;;
  refToVar getVar.data.getTag (
    VarString [
      "strings dont have storageSize and alignment" @processor block compilerError
    ]
    VarImport [
      "functions dont have storageSize and alignment" @processor block compilerError
    ]
    []
  ) case
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
    var.data.getTag VarInvalid = [
      "INVALID" toString @result set
    ] [
      var.data.getTag VarString = [
        "i8" toString @result set
      ] [
        var.data.getTag VarImport = [
          VarImport var.data.get getFuncIrType toString @result set
        ] [
          var.data.getTag VarCode = [var.data.getTag VarBuiltin =] ||  [
            "ERROR" toString @result set
          ] [
            "Unknown nonrecursive struct" @processor block compilerError
          ] if
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
          var.data.getTag VarInvalid = [
            "I" toString @result set
          ] [
            var.data.getTag VarImport = [
              ("F" VarImport var.data.get block getFuncMplType) assembleString @result set
            ] [
              "ERROR" toString @result set #it is not user error
            ] if
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
      var.data.getTag VarInvalid = [
        "I" toString @result set
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
              "Unknown nonrecursive struct" @processor block compilerError
            ] if
          ] if
        ] if
      ] if
    ] if

    @result
  ] if
];

makeStructStorageSize: [
  refToVar: processor: ;;
  result: 0nx;
  var: @refToVar getVar;
  struct: VarStruct @var.@data.get.get;
  maxA: 1nx;
  j: 0;
  [
    j struct.fields.dataSize < [
      curField: j struct.fields.at;
      curField.refToVar isVirtual ~ [
        curS: curField.refToVar @processor getStorageSize;
        curA: curField.refToVar @processor getAlignment;
        result curA + 1nx - curA 1nx - ~ and curS + @result set
        curA maxA > [curA @maxA set] when
      ] when

      j 1 + @j set TRUE
    ] &&
  ] loop

  result maxA + 1nx - maxA 1nx - ~ and @result set
  result @struct.@structStorageSize set
];

makeStructAlignment: [
  refToVar: processor: ;;
  result: 0nx;
  var: @refToVar getVar;
  struct: VarStruct @var.@data.get.get;
  j: 0;
  [
    j struct.fields.dataSize < [
      curField: j struct.fields.at;
      curField.refToVar isVirtual ~ [
        curA: curField.refToVar @processor getAlignment;
        result curA < [curA @result set] when
      ] when
      j 1 + @j set TRUE
    ] &&
  ] loop

  result @struct.@structAlignment set
];

isGlobal: [
  refToVar:;
  var: refToVar getVar;
  var.global copy
];

unglobalize: [
  refToVar: processor: block:;;;
  var: @refToVar getVar;
  var.global [
    FALSE @var.@global set
    -1 dynamic @var.@globalId set
    @refToVar @processor block makeVariableIRName
  ] when
];

untemporize: [
  refToVar:;
  var: @refToVar getVar;
  FALSE @var.@temporary set
];

noMatterToCopy: [
  refToVar:;
  refToVar isVirtual [refToVar isAutoStruct ~] &&
];

makeTypeAliasId: [
  irTypeName:;

  irTypeName.size 0 > [

    fr: irTypeName makeStringView @processor.@typeNames.find;
    fr.success [
      fr.value copy
    ] [
      newTypeName: ("%type." processor.lastTypeId) assembleString;
      processor.lastTypeId 1 + @processor.@lastTypeId set

      newTypeName irTypeName @processor createTypeDeclaration
      result: @newTypeName @processor makeStringId;
      @irTypeName move result @processor.@typeNames.insert
      result
    ] if
  ] [
    @irTypeName @processor makeStringId
  ] if
];

getFuncIrType: [
  funcIndex:;
  node: funcIndex processor.blocks.at.get;
  resultId: node.signature toString @processor makeStringId;
  resultId processor getNameById
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
        current @processor block getMplType @result.cat
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
        current @processor getDbgType @result.cat
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

  resultId: @result @processor makeStringId;
  resultId @processor getNameById
];

makeDbgTypeId: [
  refToVar: processor: block: ;;;
  refToVar isVirtualType ~ [
    varSchema: refToVar @processor getMplSchema;
    varSchema.dbgTypeDeclarationId -1 = [
      refToVar @processor block getTypeDebugDeclaration @varSchema.@dbgTypeDeclarationId set
    ] when
  ] when
];

{
  block: Block Cref;
  processor: Processor Ref;

  refToVar: RefToVar Ref;
} () {} [
  refToVar: processor: block: ;;;
  overload failProc: processor block FailProcForProcessor;

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

    @refToVar @processor makeStructAlignment
    @refToVar @processor makeStructStorageSize
  ] when

  refToVar @processor makeVariableSchema @processor getVariableSchemaId @var.!mplSchemaId
  varSchema: refToVar @processor getMplSchema;
  varSchema.irTypeId -1 = [
    refToVar @processor block generateIrTypeId @varSchema.!irTypeId
  ] when

  processor.options.debug [varSchema.dbgTypeId -1 =] && [
    refToVar @processor block generateDebugTypeId @varSchema.!dbgTypeId
    refToVar @processor block makeDbgTypeId
  ] when
] "makeVariableType" exportFunction

{
  block: Block Cref;
  processor: Processor Ref;

  refToVar: RefToVar Cref;
} Int32 {} [
  refToVar: processor: block: ;;;
  overload failProc: processor block FailProcForProcessor;

  var: refToVar getVar;
  resultDBG: String;
  var.data.getTag (
    [drop refToVar isNonrecursiveType] [refToVar block getNonrecursiveDataDBGType @resultDBG set]
    [VarRef =] [
      branch: VarRef var.data.get;
      pointee: branch.refToVar getVar;
      branch.refToVar @processor getDbgType @resultDBG.cat
      "*" @resultDBG.cat
    ]
    [VarStruct =] [
      branch: VarStruct @var.@data.get.get;
      branch.fullVirtual ~ [
        "{" @resultDBG.cat
        branch.fields [
          curField:;
          curField.refToVar isVirtual ~ [
            (curField.nameInfo processor.nameManager.getText ":" curField.refToVar @processor getDbgType ";") @resultDBG.catMany
          ] [
            (curField.nameInfo processor.nameManager.getText ".") @resultDBG.catMany
          ] if
        ] each

        "}" @resultDBG.cat
      ] when
    ]
    [[FALSE] "Unknown variable for IR type" assert]
  ) cond

  @resultDBG @processor makeStringId
] "generateDebugTypeId" exportFunction

{
  block: Block Cref;
  processor: Processor Ref;

  refToVar: RefToVar Cref;
} Int32 {} [
  refToVar: processor: block: ;;;

  var: refToVar getVar;
  resultIR: String;

  var.data.getTag (
    [drop refToVar isNonrecursiveType] [refToVar block getNonrecursiveDataIRType @resultIR set]
    [VarRef =] [
      branch: VarRef var.data.get;
      pointee: branch.refToVar getVar;

      branch.refToVar processor getIrType @resultIR.cat
      "*"  @resultIR.cat
    ]
    [VarStruct =] [
      branch: VarStruct @var.@data.get.get;
      branch.fullVirtual ~ [
        branch.homogeneous [
          ("[" branch.fields.dataSize " x " 0 branch.fields.at.refToVar @processor getIrType "]") @resultIR.catMany
        ] [
          "{" @resultIR.cat
          firstGood: TRUE;
          branch.fields [
            field:;
            field.refToVar isVirtual ~ [
              firstGood ~ [
                ", " @resultIR.cat
              ] when

              field.refToVar @processor getIrType @resultIR.cat
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
    @resultIR @processor makeStringId @irTypeId set
  ] if

  irTypeId
] "generateIrTypeId" exportFunction

{
  block: Block Cref;
  processor: Processor Cref;

  resultMPL: String Ref;
  refToVar: RefToVar Cref;
} () {} [
  refToVar: resultMPL: processor: block: ;;;;
  overload failProc: processor block FailProcForProcessor;

  var: refToVar getVar;

  refToVar isNonrecursiveType [
    refToVar block getNonrecursiveDataMPLType @resultMPL set
  ] [
    var.data.getTag VarRef = [
      branch: VarRef var.data.get;
      pointee: branch.refToVar getVar;
      branch.refToVar @processor block getMplType @resultMPL.cat
      branch.refToVar.mutable [
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
              curField.nameInfo processor.nameManager.getText ":"
              curField.refToVar @processor block getMplType ";") @resultMPL.catMany
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
  processor:;

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
  processor: block: ;;
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
  ) case ["number constant overflow" @processor block compilerError] when
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

makeVariableIRName: [
  refToVar: processor: block: ;;;
  var: @refToVar getVar;
  @var.host refToVar isGlobal ~ @processor block generateVariableIRNameWith @var.@irNameId set
];

findFieldWithOverloadDepth: [
  fieldNameInfo: refToVar: overloadDepth: processor: block: ;; copy;;;

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
          overloadDepth 0 = [
            TRUE @result.@success set
            i @result.@index set
            FALSE
          ] [
            overloadDepth 1 - @overloadDepth set
            TRUE
          ] if
        ] [
          TRUE
        ] if
      ] &&
    ] loop
  ] [
    (refToVar @processor block getMplType " is not combined") assembleString @processor block compilerError
  ] if

  result
];

findField: [processor: block: ;; 0 dynamic @processor block findFieldWithOverloadDepth];
