# Copyright (C) 2021 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"Array"     use
"HashTable" use
"String"    use
"algorithm" use
"control"   use

"Var"          use
"declarations" use
"defaultImpl"  use
"irWriter"     use
"pathUtils"    use

addDebugString: [
  @processor.@debugInfo.@strings.append
];

addDebugProlog: [
  processor:;
  "declare void @llvm.dbg.declare(metadata, metadata, metadata)" toString addDebugString

  String addDebugString
  String addDebugString
  processor.debugInfo.strings.dataSize 1 - @processor.@debugInfo.@cuStringNumber set

  indexCodeView: processor.debugInfo.lastId new;
  processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set

  ("!" indexCodeView " = !{i32 2, !\"CodeView\", i32 1}" ) assembleString addDebugString

  indexDebug: processor.debugInfo.lastId new;
  processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set

  ("!" indexDebug " = !{i32 2, !\"Debug Info Version\", i32 3}") assembleString addDebugString

  indexPIC: processor.debugInfo.lastId new;
  processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set

  ("!" indexPIC " = !{i32 1, !\"PIC Level\", i32 2}") assembleString addDebugString

  ("!llvm.module.flags = !{!" indexCodeView ", !" indexDebug ", !" indexPIC "}") assembleString processor.debugInfo.strings.dataSize 5 - @processor.@debugInfo.@strings.at set

  index: processor.debugInfo.lastId new;
  processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set
  String addDebugString
  processor.debugInfo.strings.dataSize 1 - @processor.@debugInfo.@unitStringNumber set
  index #for unit

  t: @processor addExpression;
  t: "cond" makeStringView 8 "DW_ATE_boolean" makeStringView @processor addTypeInfo;
  t: "i8" makeStringView 8 "DW_ATE_signed" makeStringView @processor addTypeInfo;
  t: "i16" makeStringView 16 "DW_ATE_signed" makeStringView @processor addTypeInfo;
  t: "i32" makeStringView 32 "DW_ATE_signed" makeStringView @processor addTypeInfo;
  t: "i64" makeStringView 64 "DW_ATE_signed" makeStringView @processor addTypeInfo;
  t: "ix" makeStringView processor.options.pointerSize 0ix cast 0 cast "DW_ATE_signed" makeStringView @processor addTypeInfo;
  t: "n8" makeStringView 8 "DW_ATE_unsigned" makeStringView @processor addTypeInfo;
  t: "n16" makeStringView 16 "DW_ATE_unsigned" makeStringView @processor addTypeInfo;
  t: "n32" makeStringView 32 "DW_ATE_unsigned" makeStringView @processor addTypeInfo;
  t: "n64" makeStringView 64 "DW_ATE_unsigned" makeStringView @processor addTypeInfo;
  t: "nx" makeStringView processor.options.pointerSize 0ix cast 0 cast "DW_ATE_unsigned" makeStringView @processor addTypeInfo;
  t: "r32" makeStringView 32 "DW_ATE_float" makeStringView @processor addTypeInfo;
  t: "r64" makeStringView 64 "DW_ATE_float" makeStringView @processor addTypeInfo;
  t: "string element" makeStringView 8 "DW_ATE_signed_char" makeStringView @processor addTypeInfo;
  t: "DW_TAG_pointer_type" makeStringView t processor.options.pointerSize 0ix cast 0 cast @processor addDerivedTypeInfo;
];

addLinkerOptionsDebugInfo: [
  processor:;

  index: processor.debugInfo.lastId new;
  processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set

  processor.options.linkerOptions.getSize 0 > [
    ("!llvm.linker.options = !{!" index "}") assembleString addDebugString
    optionsList: String;
    ("!" index " = !{") @optionsList.catMany
    processor.options.linkerOptions.getSize [
      i 0 > [
        ", " @optionsList.cat
      ] when
      ("!\"" i processor.options.linkerOptions.at "\"") @optionsList.catMany
    ] times
    "}" @optionsList.cat
    @optionsList addDebugString
  ] [
    String addDebugString
    String addDebugString
  ] if
];

getPlainTypeDebugDeclaration: [
  refToVar: processor: ;;
  var: refToVar getVar;
  var.data.getTag VarCond = [processor.debugInfo.unit 2 +] [
    var.data.getTag VarInt8 = [processor.debugInfo.unit 3 +] [
      var.data.getTag VarInt16 = [processor.debugInfo.unit 4 +] [
        var.data.getTag VarInt32 = [processor.debugInfo.unit 5 +] [
          var.data.getTag VarInt64 = [processor.debugInfo.unit 6 +] [
            var.data.getTag VarIntX = [processor.debugInfo.unit 7 +] [
              var.data.getTag VarNat8 = [processor.debugInfo.unit 8 +] [
                var.data.getTag VarNat16 = [processor.debugInfo.unit 9 +] [
                  var.data.getTag VarNat32 = [processor.debugInfo.unit 10 +] [
                    var.data.getTag VarNat64 = [processor.debugInfo.unit 11 +] [
                      var.data.getTag VarNatX = [processor.debugInfo.unit 12 +] [
                        var.data.getTag VarReal32 = [processor.debugInfo.unit 13 +] [
                          var.data.getTag VarReal64 = [processor.debugInfo.unit 14 +] [
                            var.data.getTag VarString = [processor.debugInfo.unit 15 +] [
                              "Unknown plain struct while getting debug declaration index" failProc
                              -1
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
  ] if
];

getPointerTypeDebugDeclaration: [
  processor: ;
  refToVar:;
  compileOnce
  var: refToVar getVar;
  debugDeclarationIndex: refToVar @processor getMplSchema.dbgTypeDeclarationId new;
  [debugDeclarationIndex -1 = ~] "Pointee has no type debug info!" assert
  index: "DW_TAG_pointer_type" makeStringView debugDeclarationIndex processor.options.pointerSize 0ix cast 0 cast @processor addDerivedTypeInfo;

  index
];

addMemberInfo: [
  offset: field: fieldNumber: processor: block: ;;;;;

  debugDeclarationIndex: field.refToVar @processor getMplSchema.dbgTypeDeclarationId new;
  [debugDeclarationIndex -1 = ~] "Field has not debug info about type!" assert

  fsize: field.refToVar @processor getStorageSize 0ix cast 0 cast;
  falignment: field.refToVar @processor getAlignment 0ix cast 0 cast;
  offset falignment + 1 - 0n32 cast falignment 1 - 0n32 cast ~ and 0 cast @offset set

  index: processor.debugInfo.lastId new;
  processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set

  name: field.nameInfo processor.nameManager.getText;

  name "" = [
    ("!" index " = !DIDerivedType(tag: DW_TAG_member, name: \"f" fieldNumber "\""
      ", file: !" processor.positions.last.file.debugId
      ", line: " processor.positions.last.line ", baseType: !" debugDeclarationIndex ", size: " fsize 8 * ", offset: " offset 8 * ")") assembleString
  ] [
    ("!" index " = !DIDerivedType(tag: DW_TAG_member, name: \"" name "\""
      ", file: !" processor.positions.last.file.debugId
      ", line: " processor.positions.last.line ", baseType: !" debugDeclarationIndex ", size: " fsize 8 * ", offset: " offset 8 * ")") assembleString
  ] if

  addDebugString

  offset fsize + @offset set
  index
];

getTypeDebugDeclaration: [
  refToVar: processor: block: ;;;
  compileOnce
  var: refToVar getVar;
  refToVar isVirtualType [
    "virtual type has not debug declaration" failProc
    -1
  ] [
    refToVar isPlain [var.data.getTag VarString =] || [
      refToVar @processor getPlainTypeDebugDeclaration
    ] [
      var.data.getTag VarRef = [
        pointee: VarRef var.data.get.refToVar;
        pointee @processor getPointerTypeDebugDeclaration
      ] [
        var.data.getTag VarImport = [
          @processor addFuncSubroutineInfo
        ] [
          var.data.getTag VarStruct = [
            struct: VarStruct var.data.get.get;
            members: Int32 Array;
            f: 0 dynamic;
            offset: 0 dynamic;
            [
              f struct.fields.dataSize < [
                field: f struct.fields.at;
                field.refToVar isVirtual ~ [
                  memberInfo: @offset field f @processor block addMemberInfo;
                  memberInfo @members.append
                ] when
                f 1 + @f set TRUE
              ] &&
            ] loop

            index: processor.debugInfo.lastId new;
            processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set
            newDebugInfo: String;
            ("!" index " = !{")   @newDebugInfo.catMany
            f: 0 dynamic;
            [
              f members.dataSize < [
                f 0 > [", "     @newDebugInfo.cat] when
                "!"                @newDebugInfo.cat
                f members.at @newDebugInfo.cat
                f 1 + @f set TRUE
              ] &&
            ] loop
            "}" @newDebugInfo.cat
            @newDebugInfo addDebugString


            index: processor.debugInfo.lastId new;
            processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set

            ("!" index " = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !" processor.positions.last.file.debugId
              ", name: \"" refToVar @processor block getDebugType "\", size: " refToVar @processor getStorageSize 0ix cast 0 cast 8 * ", elements: !" index 1 -
              ")") assembleString addDebugString
            index
          ] [
            "Unknown type in getTypeDebugDeclaration!" failProc
            -1
          ] if
        ] if
      ] if
    ] if
  ] if
];

getDbgSchemaNameType: [
  refToVar: processor: ;;
  var: refToVar getVar;
  resultDBG: String;
  hasSchemaName: FALSE;
  var.data.getTag VarStruct = [
    mplStruct: VarStruct var.data.get.get;
    mplStruct.fields [
      field:;
      resultDBG "" = [
        field.nameInfo processor.specialNames.schemaNameNameInfo = [
          fieldVar: field.refToVar getVar;
          fieldVar.staticity.end Dynamic > [fieldVar.data.getTag VarRef =] && [
            fieldDerefVar: VarRef fieldVar.data.get.refToVar getVar;
            fieldDerefVar.staticity.end Dynamic > [fieldDerefVar.data.getTag VarString =] && [
              VarString fieldDerefVar.data.get @resultDBG set
            ] when
          ] when

          TRUE !hasSchemaName
        ] when
      ] when
    ] each

    resultDBG "" = [
      mplStruct.fields.size 0 > [0 mplStruct.fields.at.nameInfo processor.specialNames.emptyNameInfo = ~] && [
        "object" toString @resultDBG set
      ] [
        "list" toString @resultDBG set
      ] if
    ] when
  ] when

  resultDBG hasSchemaName
];

getDebugType: [
  refToVar: processor: block:;;;
  result: hasSchemaName: refToVar @processor getDbgSchemaNameType;;
  hasSchemaName ~ [
    result.size 0 = ~ [
      "." @result.cat
    ] when

    refToVar getVar.mplSchemaId new @result.cat
    "." @result.cat

    dbgType: refToVar @processor getDbgType;
    splitted: dbgType splitString;
    splitted.success [
      splitted.chars.getSize 1024 > [
        1024 @splitted.@chars.shrink
        "..." makeStringView @splitted.@chars.append
      ] when
    ] [
      ("Wrong dbgType name encoding" splitted.chars assembleString) assembleString @processor block compilerError
    ] if

    splitted.chars @result.catMany
  ] when

  @result
];

getDbgType:  [
  refToVar: processor:;;
  refToVar @processor getMplSchema.dbgTypeId @processor getNameById
];

addVariableDebugInfo: [
  nameInfo: refToVar: processor: block: ;;;;
  refToVar isVirtualType ~ [
    debugDeclarationIndex: refToVar @processor getMplSchema.dbgTypeDeclarationId new;
    [debugDeclarationIndex -1 = ~] "There is no debug declaration for this type!" assert
    index: processor.debugInfo.lastId new;
    processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set
    ("!" index " = !DILocalVariable(name: \"" nameInfo processor.nameManager.getText "\", scope: !" block.funcDbgIndex
      ", file: !" processor.positions.last.file.debugId
      ", line: " processor.positions.last.line ", type: !" debugDeclarationIndex ")") assembleString addDebugString
    index block.funcDbgIndex @processor.@debugInfo.@locationIds.insert

    index
  ] [
    -1
  ] if
];

addGlobalVariableDebugInfo: [
  nameInfo: refToVar: processor: block:;;;;
  refToVar isVirtualType ~ [
    debugDeclarationIndex: refToVar @processor getMplSchema.dbgTypeDeclarationId new;
    [debugDeclarationIndex -1 = ~] "There is no debug declaration for this type!" assert

    index: processor.debugInfo.lastId new;
    processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set
    ("!" index " = !DIGlobalVariableExpression(var: !" index 1 + ", expr: !DIExpression())") assembleString addDebugString

    index: processor.debugInfo.lastId new;
    processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set
    ("!" index " = !DIGlobalVariable(name: \"" nameInfo processor.nameManager.getText "\", linkageName: \"" refToVar @processor getIrName
      "\", scope: !" processor.debugInfo.unit ", file: !" processor.positions.last.file.debugId
      ", line: " processor.positions.last.line ", type: !" debugDeclarationIndex ", isLocal: false, isDefinition: true)") assembleString addDebugString

    result: index 1 -;
    result @processor.@debugInfo.@globals.append
    result
  ] [
    -1
  ] if
];

addVariableMetadata: [
  nameInfo: refToVar: processor: block: ;;;;
  refToVar isVirtualType ~ [
    localVariableDebugIndex: nameInfo refToVar @processor block addVariableDebugInfo;
    ("  call void @llvm.dbg.declare(metadata " refToVar @processor getIrType "* " refToVar @processor getIrName ", metadata !" localVariableDebugIndex ", metadata !" processor.debugInfo.unit 1 + ")") @block appendInstruction
    refToVar getVar.irNameId @block.@program.last.@irName1 set
  ] when
];

addExpression: [
  processor:;

  index: processor.debugInfo.lastId new;
  processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set
  ("!" index " = !DIExpression()") assembleString addDebugString
  index
];

addTypeInfo: [
  processor: ;

  encoding:;
  size: new;
  name:;

  index: processor.debugInfo.lastId new;
  processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set
  ("!" index " = !DIBasicType(name: \"" @name "\", size: " size ", encoding: " @encoding ")") assembleString addDebugString

  index
];

addDerivedTypeInfo: [
  processor: ;

  size: new;
  base: new;
  tag:;
  index: processor.debugInfo.lastId new;
  processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set
  ("!" index " = !DIDerivedType(tag: " @tag ", baseType: !" base ", size: " @size ")") assembleString addDebugString

  index
];

addFileDebugInfo: [
  compileOnce
  processor: ;

  fileName:;
  index: processor.debugInfo.lastId new;
  processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set

  fullPath: (processor.options.mainPath fileName) assembleString;
  onlyPath: onlyFileName: fullPath simplifyPath;;
  ("!" index " = !DIFile(filename: \"" onlyFileName "\", directory: \"" onlyPath makeStringView getStringImplementation "\")" ) assembleString addDebugString
  index
];

addFuncSubroutineInfo: [
  compileOnce
  processor: ;

  index: processor.debugInfo.lastId new;
  processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set
  ("!" index " = !{null}") assembleString addDebugString
  types: index new;

  index: processor.debugInfo.lastId new;
  processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set

  ("!" index " = !DISubroutineType(types: !" types ")") assembleString addDebugString

  index
];

addFuncDebugInfo: [
  compileOnce
  position: funcName: funcIRName: funcDebugIndex: processor: ;;;;;
  subroutineIndex: @processor addFuncSubroutineInfo;
  funcImplementation: (position.file.name dup ".mpl" makeStringView endsWith [4] [0] if untail " " funcName) assembleString getStringImplementation;
  (
    "!" funcDebugIndex " = distinct !DISubprogram("
    "name: \"" funcImplementation "\", "
    "linkageName: \"" @funcIRName "\", "
    "scope: !" position.file.debugId ", "
    "file: !" position.file.debugId ", "
    "line: " position.line ", "
    "type: !" subroutineIndex ", "
    "scopeLine: " position.line ", "
    "unit: !" processor.debugInfo.unit
    ")"
  ) assembleString addDebugString
];

addDebugLocation: [
  compileOnce
  position: scopeDbgIndex: funcDbgIndex: processor: ;;;;

  index: processor.debugInfo.lastId new;
  processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set

  ("!" index " = !DILocation(line: " position.line ", column: " position.column ", scope: !" scopeDbgIndex ")") assembleString addDebugString

  index funcDbgIndex @processor.@debugInfo.@locationIds.insert
  index
];

addLexicalBlockLocation: [
  fileDbgIndex: funcDbgIndex: processor: ;;;

  index: processor.debugInfo.lastId copy;
  processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set

  ("!" index " = !DILexicalBlockFile(scope: !" funcDbgIndex ", file: !" fileDbgIndex ", discriminator: 0)")  assembleString addDebugString
  index funcDbgIndex @processor.@debugInfo.@locationIds.insert
  index
];

addLexicalBlockLocation: [
  fileDbgIndex: funcDbgIndex: processor: ;;;

  index: processor.debugInfo.lastId new;
  processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set

  ("!" index " = !DILexicalBlockFile(scope: !" funcDbgIndex ", file: !" fileDbgIndex ", discriminator: 0)")  assembleString @processor.@debugInfo.@strings.append
  index funcDbgIndex @processor.@debugInfo.@locationIds.insert
  index
];

addDebugReserve: [
  processor:;

  index: processor.debugInfo.lastId new;
  processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set
  String addDebugString
  index
];

moveLastDebugString: [
  processor:;

  index: new;
  processor.debugInfo.strings.last
  index 4 + @processor.@debugInfo.@strings.at set
  @processor.@debugInfo.@strings.popBack
];

correctUnitInfo: [
  processor:;

  file:;

  index: processor.debugInfo.lastId new;
  processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set
  newDebugInfo: ("!" index " = !{" ) assembleString;
  processor.debugInfo.globals.getSize [
    i 0 > [", "  @newDebugInfo.cat] when
    "!" @newDebugInfo.cat
    i processor.debugInfo.globals.at @newDebugInfo.cat
  ] times
  "}"                       @newDebugInfo.cat

  @newDebugInfo addDebugString
  globals: index new;

  ("!" processor.debugInfo.unit " = distinct !DICompileUnit(language: DW_LANG_C_plus_plus, file: !" file.debugId
    ", producer: \"mpl compiler\", isOptimized: false, runtimeVersion: 2, emissionKind: FullDebug, globals: !" globals ")") assembleString
  processor.debugInfo.unitStringNumber @processor.@debugInfo.@strings.at set

  ("!llvm.dbg.cu = !{!" processor.debugInfo.unit "}") assembleString
  processor.debugInfo.cuStringNumber @processor.@debugInfo.@strings.at set
];

clearUnusedDebugInfo: [
  processor:;

  clearString: [
    s:;
    String @s set
  ];

  processor.debugInfo.locationIds [
    pair:;
    locId: pair.key;
    funcDbgId: pair.value;
    debugString: funcDbgId 4 + processor.debugInfo.strings.at;
    debugString.size 0 = [
      locId 4 + @processor.@debugInfo.@strings.at clearString
    ] when
  ] each

];
