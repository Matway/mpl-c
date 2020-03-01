"builtins" module

"control" includeModule
"builtinImpl" useModule

builtins: (
  {name: "!"                       ; impl: @mplBuiltinExclamation             ;}
  {name: "@"                       ; impl: @mplBuiltinAt                      ;}
  {name: "+"                       ; impl: @mplBuiltinAdd                     ;}
  {name: "-"                       ; impl: @mplBuiltinSub                     ;}
  {name: "*"                       ; impl: @mplBuiltinMul                     ;}
  {name: "/"                       ; impl: @mplBuiltinDiv                     ;}
  {name: "&"                       ; impl: @mplBuiltinStrCat                  ;}
  {name: "="                       ; impl: @mplBuiltinEqual                   ;}
  {name: "<"                       ; impl: @mplBuiltinLess                    ;}
  {name: ">"                       ; impl: @mplBuiltinGreater                 ;}
  {name: "^"                       ; impl: @mplBuiltinPow                     ;}
  {name: "~"                       ; impl: @mplBuiltinNot                     ;}

  {name: "addressToReference"      ; impl: @mplBuiltinAddressToReference      ;}
  {name: "alignment"               ; impl: @mplBuiltinAlignment               ;}
  {name: "and"                     ; impl: @mplBuiltinAnd                     ;}
  {name: "array"                   ; impl: @mplBuiltinArray                   ;}
  {name: "call"                    ; impl: @mplBuiltinCall                    ;}
  {name: "callField"               ; impl: @mplBuiltinCallField               ;}
  {name: "cast"                    ; impl: @mplBuiltinCast                    ;}
  {name: "ceil"                    ; impl: @mplBuiltinCeil                    ;}
  {name: "codeRef"                 ; impl: @mplBuiltinCodeRef                 ;}
  {name: "cos"                     ; impl: @mplBuiltinCos                     ;}
  {name: "compileOnce"             ; impl: @mplBuiltinCompileOnce             ;}
  {name: "COMPILER_VERSION"        ; impl: @mplBuiltinCompilerVersion         ;}
  {name: "const"                   ; impl: @mplBuiltinConst                   ;}
  {name: "copy"                    ; impl: @mplBuiltinCopy                    ;}
  {name: "DEBUG"                   ; impl: @mplBuiltinDebug                   ;}
  {name: "def"                     ; impl: @mplBuiltinDef                     ;}
  {name: "dynamic"                 ; impl: @mplBuiltinDirty                   ;}
  {name: "exportFunction"          ; impl: @mplBuiltinExportFunction          ;}
  {name: "exportVariable"          ; impl: @mplBuiltinExportVariable          ;}
  {name: "FALSE"                   ; impl: @mplBuiltinFalse                   ;}
  {name: "failProc"                ; impl: @mplBuiltinFailProc                ;}
  {name: "fieldCount"              ; impl: @mplBuiltinFieldCount              ;}
  {name: "fieldIndex"              ; impl: @mplBuiltinFieldIndex              ;}
  {name: "fieldName"               ; impl: @mplBuiltinFieldName               ;}
  {name: "floor"                   ; impl: @mplBuiltinFloor                   ;}
  {name: "getCallTrace"            ; impl: @mplBuiltinGetCallTrace            ;}
  {name: "has"                     ; impl: @mplBuiltinHas                     ;}
  {name: "HAS_LOGS"                ; impl: @mplBuiltinHasLogs                 ;}
  {name: "if"                      ; impl: @mplBuiltinIf                      ;}
  {name: "is"                      ; impl: @mplBuiltinIs                      ;}
  {name: "isMoved"                 ; impl: @mplBuiltinIsMoved                 ;}
  {name: "importFunction"          ; impl: @mplBuiltinImportFunction          ;}
  {name: "importVariable"          ; impl: @mplBuiltinImportVariable          ;}
  {name: "includeModule"           ; impl: @mplBuiltinIncludeModule           ;}
  {name: "isConst"                 ; impl: @mplBuiltinIsConst                 ;}
  {name: "isCombined"              ; impl: @mplBuiltinIsCombined              ;}
  {name: "LF"                      ; impl: @mplBuiltinLF                      ;}
  {name: "log"                     ; impl: @mplBuiltinLog                     ;}
  {name: "log10"                   ; impl: @mplBuiltinLog10                   ;}
  {name: "loop"                    ; impl: @mplBuiltinLoop                    ;}
  {name: "lshift"                  ; impl: @mplBuiltinLShift                  ;}
  {name: "manuallyInitVariable"    ; impl: @mplBuiltinManuallyInitVariable    ;}
  {name: "manuallyDestroyVariable" ; impl: @mplBuiltinManuallyDestroyVariable ;}
  {name: "mod"                     ; impl: @mplBuiltinMod                     ;}
  {name: "module"                  ; impl: @mplBuiltinModule                  ;}
  {name: "move"                    ; impl: @mplBuiltinMove                    ;}
  {name: "moveIf"                  ; impl: @mplBuiltinMoveIf                  ;}
  {name: "neg"                     ; impl: @mplBuiltinNeg                     ;}
  {name: "newVarOfTheSameType"     ; impl: @mplBuiltinNewVarOfTheSameType     ;}
  {name: "not"                     ; impl: @mplBuiltinNot                     ;}
  {name: "or"                      ; impl: @mplBuiltinOr                      ;}
  {name: "printCompilerMessage"    ; impl: @mplBuiltinPrintCompilerMessage    ;}
  {name: "printStack"              ; impl: @mplBuiltinPrintStack              ;}
  {name: "printStackTrace"         ; impl: @mplBuiltinPrintStackTrace         ;}
  {name: "printVariableCount"      ; impl: @mplBuiltinPrintVariableCount      ;}
  {name: "recursive"               ; impl: @mplBuiltinRecursive               ;}
  {name: "rshift"                  ; impl: @mplBuiltinRShift                  ;}
  {name: "same"                    ; impl: @mplBuiltinSame                    ;}
  {name: "schema"                  ; impl: @mplBuiltinSchema                  ;}
  {name: "set"                     ; impl: @mplBuiltinSet                     ;}
  {name: "sin"                     ; impl: @mplBuiltinSin                     ;}
  {name: "sqrt"                    ; impl: @mplBuiltinSqrt                    ;}
  {name: "static"                  ; impl: @mplBuiltinStatic                  ;}
  {name: "storageSize"             ; impl: @mplBuiltinStorageSize             ;}
  {name: "storageAddress"          ; impl: @mplBuiltinStorageAddress          ;}
  {name: "textSize"                ; impl: @mplBuiltinTextSize                ;}
  {name: "textSplit"               ; impl: @mplBuiltinTextSplit               ;}
  {name: "TRUE"                    ; impl: @mplBuiltinTrue                    ;}
  {name: "uif"                     ; impl: @mplBuiltinUif                     ;}
  {name: "ucall"                   ; impl: @mplBuiltinUcall                   ;}
  {name: "useModule"               ; impl: @mplBuiltinUseModule               ;}
  {name: "virtual"                 ; impl: @mplBuiltinVirtual                 ;}
  {name: "xor"                     ; impl: @mplBuiltinXor                     ;}
);

builtinFirst: [0 static];
builtinLast: [builtins fieldCount 0 cast 2 /];

addBuiltin: [
  copy id:;
  name:;

  fr: @name @processor.@nameToId.find;
  fr.success [
    fr.value copy
  ] [
    s: @name toString;
    result: processor.nameInfos.getSize;
    s makeNameInfo @processor.@nameInfos.pushBack
    s result @processor.@nameToId.insert
    result
  ] if
  nameId:;

  bvar: @id VarBuiltin createVariable Virtual makeStaticness;
  nameId bvar NameCaseBuiltin addNameInfo
];

initBuiltins: [
  processor:;
  processorResult:;
  indexOfNode: 0 dynamic;
  codeNode: indexOfNode @processor.@nodes.at.get;
  currentNode: @codeNode;
  failProc: @failProcForProcessor;

  builtins makeArrayRange [
    p:;
    p.value.name makeStringView p.index addBuiltin
  ] each
];

{processorResult: ProcessorResult Ref; processor: Processor Ref; indexOfNode: Int32; currentNode: CodeNode Ref; multiParserResult: MultiParserResult Cref; index: Int32;} () {convention: cdecl;} [
  processorResult:;
  processor:;
  copy indexOfNode:;
  currentNode:;
  multiParserResult:;
  failProc: @failProcForProcessor;
  copy index:;

  builtinFunc: index builtins @ .@impl;
  multiParserResult @currentNode indexOfNode @processor @processorResult @builtinFunc call
] "callBuiltinImpl" exportFunction
