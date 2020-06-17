"control" use
"Array.Array" use
"HashTable.hash" use
"String.assembleString" use
"String.makeStringView" use
"String.toString" use
"String.splitString" use
"String.String" use

"Var.VarBuiltin" use
"Var.VarCode" use
"Var.VarCond" use
"Var.VarEnd" use
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
"Var.getAlignment" use
"Var.getStorageSize" use
"Var.getStringImplementation" use
"Var.getVar" use
"Var.isPlain" use
"Var.isVirtual" use
"Var.isVirtualType" use
"declarations.compilerError" use
"irWriter.appendInstruction" use
"irWriter.getIrName" use
"irWriter.getIrType" use
"irWriter.getMplSchema" use
"irWriter.getNameById" use
"pathUtils.simplifyPath" use

addDebugProlog: [
  processor:;
  "declare void @llvm.dbg.declare(metadata, metadata, metadata)" toString @processor.@debugInfo.@strings.pushBack

  String @processor.@debugInfo.@strings.pushBack
  String @processor.@debugInfo.@strings.pushBack
  processor.debugInfo.strings.dataSize 1 - @processor.@debugInfo.@cuStringNumber set

  indexCodeView: processor.debugInfo.lastId copy;
  processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set

  ("!" indexCodeView " = !{i32 2, !\"CodeView\", i32 1}" ) assembleString @processor.@debugInfo.@strings.pushBack

  indexDebug: processor.debugInfo.lastId copy;
  processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set

  ("!" indexDebug " = !{i32 2, !\"Debug Info Version\", i32 3}") assembleString @processor.@debugInfo.@strings.pushBack

  indexPIC: processor.debugInfo.lastId copy;
  processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set

  ("!" indexPIC " = !{i32 1, !\"PIC Level\", i32 2}") assembleString @processor.@debugInfo.@strings.pushBack

  ("!llvm.module.flags = !{!" indexCodeView ", !" indexDebug ", !" indexPIC "}") assembleString processor.debugInfo.strings.dataSize 5 - @processor.@debugInfo.@strings.at set

  index: processor.debugInfo.lastId copy;
  processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set
  String @processor.@debugInfo.@strings.pushBack
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

  index: processor.debugInfo.lastId copy;
  processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set

  processor.options.linkerOptions.getSize 0 > [
    ("!llvm.linker.options = !{!" index "}") assembleString @processor.@debugInfo.@strings.pushBack
    optionsList: String;
    ("!" index " = !{") @optionsList.catMany
    processor.options.linkerOptions.getSize [
      i 0 > [
        ", " @optionsList.cat
      ] when
      ("!\"" i processor.options.linkerOptions.at "\"") @optionsList.catMany
    ] times
    "}" @optionsList.cat
    @optionsList move @processor.@debugInfo.@strings.pushBack
  ] [
    String @processor.@debugInfo.@strings.pushBack
    String @processor.@debugInfo.@strings.pushBack
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
                              [FALSE] "Unknown plain struct while getting debug declaration index" assert
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
  debugDeclarationIndex: refToVar @processor getMplSchema.dbgTypeDeclarationId copy;
  [debugDeclarationIndex -1 = ~] "Pointee has no type debug info!" assert
  "DW_TAG_pointer_type" makeStringView debugDeclarationIndex processor.options.pointerSize 0ix cast 0 cast @processor addDerivedTypeInfo
];

addMemberInfo: [
  offset: field: fieldNumber: processor: block: ;;;;;

  debugDeclarationIndex: field.refToVar @processor getMplSchema.dbgTypeDeclarationId copy;
  [debugDeclarationIndex -1 = ~] "Field has not debug info about type!" assert

  fsize: field.refToVar @processor getStorageSize 0ix cast 0 cast;
  falignment: field.refToVar @processor getAlignment 0ix cast 0 cast;
  offset falignment + 1 - 0n32 cast falignment 1 - 0n32 cast ~ and 0 cast @offset set

  index: processor.debugInfo.lastId copy;
  processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set

  name: field.nameInfo processor.nameManager.getText;

  name "" = [
    ("!" index " = !DIDerivedType(tag: DW_TAG_member, name: \"f" fieldNumber "\", scope: !" block.funcDbgIndex
      ", file: !" processor.positions.last.file.debugId
      ", line: " processor.positions.last.line ", baseType: !" debugDeclarationIndex ", size: " fsize 8 * ", offset: " offset 8 * ")") assembleString
  ] [
    ("!" index " = !DIDerivedType(tag: DW_TAG_member, name: \"" name "\", scope: !" block.funcDbgIndex
      ", file: !" processor.positions.last.file.debugId
      ", line: " processor.positions.last.line ", baseType: !" debugDeclarationIndex ", size: " fsize 8 * ", offset: " offset 8 * ")") assembleString
  ] if

  @processor.@debugInfo.@strings.pushBack
  index block.funcDbgIndex @processor.@debugInfo.@locationIds.insert

  offset fsize + @offset set
  index
];

getTypeDebugDeclaration: [
  refToVar: processor: block: ;;;
  compileOnce
  var: refToVar getVar;
  refToVar isVirtualType [
    [FALSE] "virtual type has not debug declaration" assert
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
                  memberInfo @members.pushBack
                ] when
                f 1 + @f set TRUE
              ] &&
            ] loop

            index: processor.debugInfo.lastId copy;
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
            @newDebugInfo move @processor.@debugInfo.@strings.pushBack

            index block.funcDbgIndex @processor.@debugInfo.@locationIds.insert

            index: processor.debugInfo.lastId copy;
            processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set

            ("!" index " = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !" processor.positions.last.file.debugId
              ", name: \"" refToVar @processor block getDebugType "\", line: " processor.positions.last.line ", size: " refToVar @processor getStorageSize 0ix cast 0 cast 8 * ", elements: !" index 1 -
              ")") assembleString @processor.@debugInfo.@strings.pushBack
            index block.funcDbgIndex @processor.@debugInfo.@locationIds.insert
            index
          ] [
            [FALSE] "Unknown type in getTypeDebugDeclaration!" assert
            -1
          ] if
        ] if
      ] if
    ] if
  ] if
];

getDebugType: [
  refToVar: processor: block:;;;
  dbgType: refToVar @processor getDbgType;
  splitted: dbgType splitString;
  splitted.success [
    splitted.chars.getSize 1024 > [
      1024 @splitted.@chars.shrink
      "..." makeStringView @splitted.@chars.pushBack
    ] when
  ] [
    ("Wrong dbgType name encoding" splitted.chars assembleString) assembleString @processor block compilerError
  ] if

  result: (refToVar getVar.mplSchemaId ".") assembleString;
  splitted.chars @result.catMany
  @result
];

getDbgType:  [
  refToVar: processor:;;
  refToVar @processor getMplSchema.dbgTypeId @processor getNameById
];

addVariableDebugInfo: [
  nameInfo: refToVar: processor: block: ;;;;
  refToVar isVirtualType ~ [
    debugDeclarationIndex: refToVar @processor getMplSchema.dbgTypeDeclarationId copy;
    [debugDeclarationIndex -1 = ~] "There is no debug declaration for this type!" assert
    index: processor.debugInfo.lastId copy;
    processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set
    ("!" index " = !DILocalVariable(name: \"" nameInfo processor.nameManager.getText "\", scope: !" block.funcDbgIndex
      ", file: !" processor.positions.last.file.debugId
      ", line: " processor.positions.last.line ", type: !" debugDeclarationIndex ")") assembleString @processor.@debugInfo.@strings.pushBack
    index block.funcDbgIndex @processor.@debugInfo.@locationIds.insert

    index
  ] [
    -1
  ] if
];

addGlobalVariableDebugInfo: [
  nameInfo: refToVar: processor: block:;;;;
  refToVar isVirtualType ~ [
    debugDeclarationIndex: refToVar @processor getMplSchema.dbgTypeDeclarationId copy;
    [debugDeclarationIndex -1 = ~] "There is no debug declaration for this type!" assert

    index: processor.debugInfo.lastId copy;
    processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set
    ("!" index " = !DIGlobalVariableExpression(var: !" index 1 + ", expr: !DIExpression())") assembleString @processor.@debugInfo.@strings.pushBack

    index: processor.debugInfo.lastId copy;
    processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set
    ("!" index " = !DIGlobalVariable(name: \"" nameInfo processor.nameManager.getText "\", linkageName: \"" refToVar @processor getIrName
      "\", scope: !" processor.debugInfo.unit ", file: !" processor.positions.last.file.debugId
      ", line: " processor.positions.last.line ", type: !" debugDeclarationIndex ", isLocal: false, isDefinition: true)") assembleString @processor.@debugInfo.@strings.pushBack

    result: index 1 -;
    result @processor.@debugInfo.@globals.pushBack
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

  index: processor.debugInfo.lastId copy;
  processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set
  ("!" index " = !DIExpression()") assembleString @processor.@debugInfo.@strings.pushBack
  index
];

addTypeInfo: [
  processor: ;

  encoding:;
  copy size:;
  name:;

  index: processor.debugInfo.lastId copy;
  processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set
  ("!" index " = !DIBasicType(name: \"" @name "\", size: " size ", encoding: " @encoding ")") assembleString @processor.@debugInfo.@strings.pushBack

  index
];

addDerivedTypeInfo: [
  processor: ;

  copy size:;
  copy base:;
  tag:;
  index: processor.debugInfo.lastId copy;
  processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set
  ("!" index " = !DIDerivedType(tag: " @tag ", baseType: !" base ", size: " @size ")") assembleString @processor.@debugInfo.@strings.pushBack

  index
];

addFileDebugInfo: [
  compileOnce
  processor: ;

  fileName:;
  index: processor.debugInfo.lastId copy;
  processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set

  fullPath: (processor.options.mainPath fileName) assembleString;
  onlyPath: onlyFileName: fullPath simplifyPath;;
  ("!" index " = !DIFile(filename: \"" onlyFileName "\", directory: \"" onlyPath makeStringView getStringImplementation "\")" ) assembleString @processor.@debugInfo.@strings.pushBack
  index
];

addFuncSubroutineInfo: [
  compileOnce
  processor: ;

  index: processor.debugInfo.lastId copy;
  processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set
  ("!" index " = !{null}") assembleString @processor.@debugInfo.@strings.pushBack
  types: index copy;

  index: processor.debugInfo.lastId copy;
  processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set

  ("!" index " = !DISubroutineType(types: !" types ")") assembleString @processor.@debugInfo.@strings.pushBack

  index
];

addFuncDebugInfo: [
  compileOnce
  position: funcName: funcIRName: funcDebugIndex: processor: ;;;;;

  subroutineIndex: @processor addFuncSubroutineInfo;
  funcImplementation: funcName makeStringView getStringImplementation;

  (
    "!" funcDebugIndex " = distinct !DISubprogram(name: \"" funcImplementation ".dbgId" funcDebugIndex "\", linkageName: \"" @funcIRName
    "\", scope: !" position.file.debugId
    ", file: !" position.file.debugId ", line: " position.line  ", type: !" subroutineIndex
    ", scopeLine: " position.line ", unit: !" processor.debugInfo.unit ")") assembleString @processor.@debugInfo.@strings.pushBack
];

addDebugLocation: [
  compileOnce
  position: funcDbgIndex: processor: ;;;

  index: processor.debugInfo.lastId copy;
  processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set

  ("!" index " = !DILocation(line: " position.line ", column: " position.column ", scope: !" funcDbgIndex ")") assembleString @processor.@debugInfo.@strings.pushBack

  index funcDbgIndex @processor.@debugInfo.@locationIds.insert
  index
];

addDebugReserve: [
  processor:;

  index: processor.debugInfo.lastId copy;
  processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set
  String @processor.@debugInfo.@strings.pushBack
  index
];

moveLastDebugString: [
  processor:;

  copy index:;
  processor.debugInfo.strings.last
  index 4 + @processor.@debugInfo.@strings.at set
  @processor.@debugInfo.@strings.popBack
];

correctUnitInfo: [
  processor:;

  file:;

  index: processor.debugInfo.lastId copy;
  processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set
  newDebugInfo: ("!" index " = !{" ) assembleString;
  processor.debugInfo.globals.getSize [
    i 0 > [", "  @newDebugInfo.cat] when
    "!" @newDebugInfo.cat
    i processor.debugInfo.globals.at @newDebugInfo.cat
  ] times
  "}"                       @newDebugInfo.cat

  @newDebugInfo move @processor.@debugInfo.@strings.pushBack
  globals: index copy;

  ("!" processor.debugInfo.unit " = distinct !DICompileUnit(language: DW_LANG_C_plus_plus, file: !" file.debugId
    ", producer: \"mpl compiler\", isOptimized: false, runtimeVersion: 2, emissionKind: FullDebug, globals: !" globals ")") assembleString
  processor.debugInfo.unitStringNumber @processor.@debugInfo.@strings.at set

  ("!llvm.dbg.cu = !{!" processor.debugInfo.unit "}") assembleString
  processor.debugInfo.cuStringNumber @processor.@debugInfo.@strings.at set
];

clearUnusedDebugInfo: [
  processor:;

  processor.debugInfo.locationIds [
    pair:;
    locId: pair.key;
    funcDbgId: pair.value;
    debugString: funcDbgId 4 + processor.debugInfo.strings.at;
    debugString.size 0 = [
      String locId 4 + @processor.@debugInfo.@strings.at set
    ] when
  ] each

];
