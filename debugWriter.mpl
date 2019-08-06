"debugWriter" module
"control" useModule

addDebugProlog: [
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

  t: addExpression;
  t: "cond" makeStringView 8 "DW_ATE_boolean" makeStringView addTypeInfo;
  t: "i8" makeStringView 8 "DW_ATE_signed" makeStringView addTypeInfo;
  t: "i16" makeStringView 16 "DW_ATE_signed" makeStringView addTypeInfo;
  t: "i32" makeStringView 32 "DW_ATE_signed" makeStringView addTypeInfo;
  t: "i64" makeStringView 64 "DW_ATE_signed" makeStringView addTypeInfo;
  t: "ix" makeStringView processor.options.pointerSize 0ix cast 0 cast "DW_ATE_signed" makeStringView addTypeInfo;
  t: "n8" makeStringView 8 "DW_ATE_unsigned" makeStringView addTypeInfo;
  t: "n16" makeStringView 16 "DW_ATE_unsigned" makeStringView addTypeInfo;
  t: "n32" makeStringView 32 "DW_ATE_unsigned" makeStringView addTypeInfo;
  t: "n64" makeStringView 64 "DW_ATE_unsigned" makeStringView addTypeInfo;
  t: "nx" makeStringView processor.options.pointerSize 0ix cast 0 cast "DW_ATE_unsigned" makeStringView addTypeInfo;
  t: "r32" makeStringView 32 "DW_ATE_float" makeStringView addTypeInfo;
  t: "r64" makeStringView 64 "DW_ATE_float" makeStringView addTypeInfo;
  t: "string element" makeStringView 8 "DW_ATE_signed_char" makeStringView addTypeInfo;
  t: "DW_TAG_pointer_type" makeStringView t processor.options.pointerSize 0ix cast 0 cast addDerivedTypeInfo;
];

addLinkerOptionsDebugInfo: [
  index: processor.debugInfo.lastId copy;
  processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set

  processor.options.linkerOptions.getSize 0 > [
    ("!llvm.linker.options = !{!" index "}") assembleString @processor.@debugInfo.@strings.pushBack
    optionsList: String;
    ("!" index " = !{") @optionsList.catMany
    processor.options.linkerOptions [
      pair:;
      pair.index 0 > [
        ", " @optionsList.cat
      ] when
      ("!\"" pair.value "\"") @optionsList.catMany
    ] each
    "}" @optionsList.cat
    @optionsList move @processor.@debugInfo.@strings.pushBack
  ] [
    String @processor.@debugInfo.@strings.pushBack
    String @processor.@debugInfo.@strings.pushBack
  ] if
];

getPlainTypeDebugDeclaration: [
  var: getVar;
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
                            var.data.getTag VarString = [processor.debugInfo.unit 16 +] [
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
  refToVar:;
  compileOnce
  var: refToVar getVar;
  fr: var.mplTypeId @processor.@debugInfo.@typeIdToDbgId.find;
  [fr.success copy] "Pointee has no type debug info!" assert
  "DW_TAG_pointer_type" makeStringView fr.value processor.options.pointerSize 0ix cast 0 cast addDerivedTypeInfo
];

addLinkedLib: [
  libName:;
  fr: libName makeStringView @processor.@libNames.find;
  fr.success not [
    @libName TRUE @processor.@libNames.insert
  ] when
];

addMemberInfo: [
  copy fieldNumber:;
  field:;
  offset:;

  fr: field.refToVar getVar.mplTypeId @processor.@debugInfo.@typeIdToDbgId.find;
  [fr.success copy] "Field has not debug info about type!" assert

  fsize: field.refToVar getStorageSize 0ix cast 0 cast;
  falignment: field.refToVar getAlignment 0ix cast 0 cast;
  offset falignment + 1 - 0n32 cast falignment 1 - 0n32 cast not and 0 cast @offset set

  index: processor.debugInfo.lastId copy;
  processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set

  name: field.nameInfo processor.nameInfos.at.name makeStringView;

  name "" = [
    ("!" index " = !DIDerivedType(tag: DW_TAG_member, name: \"f" fieldNumber "\", scope: !" currentNode.funcDbgIndex
      ", file: !" currentNode.position.fileNumber processor.debugInfo.fileNameIds.at
      ", line: " currentNode.position.line ", baseType: !" fr.value ", size: " fsize 8 * ", offset: " offset 8 * ")") assembleString
  ] [
    ("!" index " = !DIDerivedType(tag: DW_TAG_member, name: \"" name "\", scope: !" currentNode.funcDbgIndex
      ", file: !" currentNode.position.fileNumber processor.debugInfo.fileNameIds.at
      ", line: " currentNode.position.line ", baseType: !" fr.value ", size: " fsize 8 * ", offset: " offset 8 * ")") assembleString
  ] if

  @processor.@debugInfo.@strings.pushBack
  index currentNode.funcDbgIndex @processor.@debugInfo.@locationIds.insert

  offset fsize + @offset set
  index
];

getTypeDebugDeclaration: [
  refToVar:;
  var: refToVar getVar;
  refToVar isVirtualType [
    [FALSE] "virtual type has not debug declaration" assert
    -1
  ] [
    refToVar isPlain [var.data.getTag VarString =] || [
      refToVar getPlainTypeDebugDeclaration
    ] [
      var.data.getTag VarRef = [
        pointee: VarRef var.data.get;
        pointee getPointerTypeDebugDeclaration
      ] [
        var.data.getTag VarImport = [
          addFuncSubroutineInfo
        ] [
          var.data.getTag VarStruct = [
            struct: VarStruct var.data.get.get;
            members: Int32 Array;
            f: 0 dynamic;
            offset: 0 dynamic;
            [
              f struct.fields.dataSize < [
                field: f struct.fields.at;
                field.refToVar isVirtualField not [
                  memberInfo: @offset field f addMemberInfo;
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

            index currentNode.funcDbgIndex @processor.@debugInfo.@locationIds.insert

            index: processor.debugInfo.lastId copy;
            processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set

            ("!" index " = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !" currentNode.position.fileNumber processor.debugInfo.fileNameIds.at
              ", name: \"" refToVar getDebugType "\", line: " currentNode.position.line ", size: " refToVar getStorageSize 0ix cast 0 cast 8 * ", elements: !" index 1 -
              ")") assembleString @processor.@debugInfo.@strings.pushBack
            index currentNode.funcDbgIndex @processor.@debugInfo.@locationIds.insert
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

addVariableDebugInfo: [
  refToVar:;
  copy nameInfo:;

  refToVar isVirtualType not [
    fr: refToVar getVar.mplTypeId @processor.@debugInfo.@typeIdToDbgId.find;
    [fr.success copy] "There is no debug declaration for this type!" assert
    debugDeclarationIndex: fr.value copy;
    index: processor.debugInfo.lastId copy;
    processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set
    ("!" index " = !DILocalVariable(name: \"" nameInfo processor.nameInfos.at.name "\", scope: !" currentNode.funcDbgIndex
      ", file: !" currentNode.position.fileNumber processor.debugInfo.fileNameIds.at
      ", line: " currentNode.position.line ", type: !" debugDeclarationIndex ")") assembleString @processor.@debugInfo.@strings.pushBack
    index currentNode.funcDbgIndex @processor.@debugInfo.@locationIds.insert

    index
  ] [
    -1
  ] if
];

addGlobalVariableDebugInfo: [
  refToVar:;
  copy nameInfo:;

  refToVar isVirtualType not [
    fr: refToVar getVar.mplTypeId @processor.@debugInfo.@typeIdToDbgId.find;
    [fr.success copy] "There is no debug declaration for this type!" assert
    debugDeclarationIndex: fr.value copy;

    index: processor.debugInfo.lastId copy;
    processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set
    ("!" index " = !DIGlobalVariableExpression(var: !" index 1 + ", expr: !DIExpression())") assembleString @processor.@debugInfo.@strings.pushBack

    index: processor.debugInfo.lastId copy;
    processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set
    ("!" index " = !DIGlobalVariable(name: \"" nameInfo processor.nameInfos.at.name "\", linkageName: \"" refToVar getIrName
      "\", scope: !" processor.debugInfo.unit ", file: !" currentNode.position.fileNumber processor.debugInfo.fileNameIds.at
      ", line: " currentNode.position.line ", type: !" debugDeclarationIndex ", isLocal: false, isDefinition: true)") assembleString @processor.@debugInfo.@strings.pushBack

    result: index 1 -;
    result @processor.@debugInfo.@globals.pushBack
    result
  ] [
    -1
  ] if
];

addVariableMetadata: [
  refToVar:;
  copy nameInfo:;

  refToVar isVirtualType not [
    localVariableDebugIndex: nameInfo refToVar addVariableDebugInfo;
    ("  call void @llvm.dbg.declare(metadata " refToVar getIrType "* " refToVar getIrName ", metadata !" localVariableDebugIndex ", metadata !" processor.debugInfo.unit 1 + ")"
    ) assembleString makeInstruction @currentNode.@program.pushBack
  ] when
];

addExpression: [
  index: processor.debugInfo.lastId copy;
  processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set
  ("!" index " = !DIExpression()") assembleString @processor.@debugInfo.@strings.pushBack
  index
];

addTypeInfo: [
  encoding:;
  copy size:;
  name:;

  index: processor.debugInfo.lastId copy;
  processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set
  ("!" index " = !DIBasicType(name: \"" @name "\", size: " size ", encoding: " @encoding ")") assembleString @processor.@debugInfo.@strings.pushBack

  index
];

addDerivedTypeInfo: [
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
  copy funcDebugIndex:;
  funcIRName:;
  funcName:;
  position:;

  subroutineIndex: addFuncSubroutineInfo;
  funcImplementation: funcName makeStringView getStringImplementation;

  (
    "!" funcDebugIndex " = distinct !DISubprogram(name: \"" funcImplementation makeStringView "\", linkageName: \"" @funcIRName
    "\", scope: !" position.fileNumber processor.debugInfo.fileNameIds.at
    ", file: !" position.fileNumber processor.debugInfo.fileNameIds.at ", line: " position.line  ", type: !" subroutineIndex
    ", scopeLine: " position.line ", unit: !" processor.debugInfo.unit ")") assembleString @processor.@debugInfo.@strings.pushBack
];

addDebugLocation: [
  compileOnce
  copy funcDbgIndex:;
  position:;

  index: processor.debugInfo.lastId copy;
  processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set

  ("!" index " = !DILocation(line: " position.line ", column: " position.column ", scope: !" funcDbgIndex ")") assembleString @processor.@debugInfo.@strings.pushBack

  index funcDbgIndex @processor.@debugInfo.@locationIds.insert
  index
];

addDebugReserve: [
  index: processor.debugInfo.lastId copy;
  processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set
  String @processor.@debugInfo.@strings.pushBack
  index
];

moveLastDebugString: [
  copy index:;
  processor.debugInfo.strings.last
  index 4 + @processor.@debugInfo.@strings.at set
  @processor.@debugInfo.@strings.popBack
];

correctUnitInfo: [
  copy lastUnit:;

  index: processor.debugInfo.lastId copy;
  processor.debugInfo.lastId 1 + @processor.@debugInfo.@lastId set
  newDebugInfo: ("!" index " = !{" ) assembleString;
  processor.debugInfo.globals [
    pair:;
    i: pair.index copy;
    i 0 > [", "  @newDebugInfo.cat] when
    "!" @newDebugInfo.cat
    pair.value @newDebugInfo.cat
  ] each
  "}"                       @newDebugInfo.cat

  @newDebugInfo move @processor.@debugInfo.@strings.pushBack
  globals: index copy;

  ("!" processor.debugInfo.unit " = distinct !DICompileUnit(language: DW_LANG_C_plus_plus, file: !" lastUnit processor.debugInfo.fileNameIds.at
    ", producer: \"mpl compiler\", isOptimized: false, runtimeVersion: 2, emissionKind: FullDebug, globals: !" globals ")") assembleString
  processor.debugInfo.unitStringNumber @processor.@debugInfo.@strings.at set

  ("!llvm.dbg.cu = !{!" processor.debugInfo.unit "}") assembleString
  processor.debugInfo.cuStringNumber @processor.@debugInfo.@strings.at set
];

clearUnusedDebugInfo: [
  processor.debugInfo.locationIds [
    pair:;
    locId: pair.key;
    funcDbgId: pair.value;
    debugString: funcDbgId 4 + processor.debugInfo.strings.at;
    debugString.getTextSize 0 = [
      String locId 4 + @processor.@debugInfo.@strings.at set
    ] when
  ] each

];
