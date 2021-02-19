# Copyright (C) 2021 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"String" use
"control" use
"conventions" use

"Block" use
"MplFile" use
"Var" use
"builtinImpl" use
"codeNode" use
"declarations" use
"defaultImpl" use
"processor" use
"variable" use

builtins: (
  {name: "!"                             ; impl: @mplBuiltinExclamation             ;}
  {name: "&"                             ; impl: @mplBuiltinStrCat                  ;}
  {name: "*"                             ; impl: @mplBuiltinMul                     ;}
  {name: "+"                             ; impl: @mplBuiltinAdd                     ;}
  {name: "-"                             ; impl: @mplBuiltinSub                     ;}
  {name: "/"                             ; impl: @mplBuiltinDiv                     ;}
  {name: "<"                             ; impl: @mplBuiltinLess                    ;}
  {name: "="                             ; impl: @mplBuiltinEqual                   ;}
  {name: ">"                             ; impl: @mplBuiltinGreater                 ;}
  {name: "@"                             ; impl: @mplBuiltinAt                      ;}
  {name: "COMPILER_VERSION"              ; impl: @mplBuiltinCompilerVersion         ;}
  {name: "DEBUG"                         ; impl: @mplBuiltinDebug                   ;}
  {name: "FALSE"                         ; impl: @mplBuiltinFalse                   ;}
  {name: "LF"                            ; impl: @mplBuiltinLF                      ;}
  {name: "TRUE"                          ; impl: @mplBuiltinTrue                    ;}
  {name: "^"                             ; impl: @mplBuiltinPow                     ;}
  {name: "addressToReference"            ; impl: @mplBuiltinAddressToReference      ;}
  {name: "alignment"                     ; impl: @mplBuiltinAlignment               ;}
  {name: "and"                           ; impl: @mplBuiltinAnd                     ;}
  {name: "array"                         ; impl: @mplBuiltinArray                   ;}
  {name: "call"                          ; impl: @mplBuiltinCall                    ;}
  {name: "callField"                     ; impl: @mplBuiltinCallField               ;}
  {name: "cast"                          ; impl: @mplBuiltinCast                    ;}
  {name: "ceil"                          ; impl: @mplBuiltinCeil                    ;}
  {name: "codeRef"                       ; impl: @mplBuiltinCodeRef                 ;}
  {name: "compileOnce"                   ; impl: @mplBuiltinCompileOnce             ;}
  {name: "const"                         ; impl: @mplBuiltinConst                   ;}
  {name: "cos"                           ; impl: @mplBuiltinCos                     ;}
  {name: "def"                           ; impl: @mplBuiltinDef                     ;}
  {name: "dynamic"                       ; impl: @mplBuiltinDynamic                 ;}
  {name: "exportFunction"                ; impl: @mplBuiltinExportFunction          ;}
  {name: "exportVariable"                ; impl: @mplBuiltinExportVariable          ;}
  {name: "failProc"                      ; impl: @mplBuiltinFailProc                ;}
  {name: "fieldCount"                    ; impl: @mplBuiltinFieldCount              ;}
  {name: "fieldIndex"                    ; impl: @mplBuiltinFieldIndex              ;}
  {name: "fieldName"                     ; impl: @mplBuiltinFieldName               ;}
  {name: "floor"                         ; impl: @mplBuiltinFloor                   ;}
  {name: "getCallTrace"                  ; impl: @mplBuiltinGetCallTrace            ;}
  {name: "has"                           ; impl: @mplBuiltinHas                     ;}
  {name: "if"                            ; impl: @mplBuiltinIf                      ;}
  {name: "importFunction"                ; impl: @mplBuiltinImportFunction          ;}
  {name: "importVariable"                ; impl: @mplBuiltinImportVariable          ;}
  {name: "is"                            ; impl: @mplBuiltinIs                      ;}
  {name: "isCombined"                    ; impl: @mplBuiltinIsCombined              ;}
  {name: "isConst"                       ; impl: @mplBuiltinIsConst                 ;}
  {name: "isDynamic"                     ; impl: @mplBuiltinIsDynamic               ;}
  {name: "isStatic"                      ; impl: @mplBuiltinIsStatic                ;}
  {name: "log"                           ; impl: @mplBuiltinLog                     ;}
  {name: "log10"                         ; impl: @mplBuiltinLog10                   ;}
  {name: "loop"                          ; impl: @mplBuiltinLoop                    ;}
  {name: "lshift"                        ; impl: @mplBuiltinLShift                  ;}
  {name: "manuallyDestroyVariable"       ; impl: @mplBuiltinManuallyDestroyVariable ;}
  {name: "manuallyInitVariable"          ; impl: @mplBuiltinManuallyInitVariable    ;}
  {name: "mod"                           ; impl: @mplBuiltinMod                     ;}
  {name: "neg"                           ; impl: @mplBuiltinNeg                     ;}
  {name: "new"                           ; impl: @mplBuiltinNew                     ;}
  {name: "newVarOfTheSameType"           ; impl: @mplBuiltinNewVarOfTheSameType     ;}
  {name: "or"                            ; impl: @mplBuiltinOr                      ;}
  {name: "overload"                      ; impl: @mplBuiltinOverload                ;}
  {name: "printCompilerMaxAllocationSize"; impl: @mplPrintCompilerMaxAllocationSize ;}
  {name: "printCompilerMessage"          ; impl: @mplBuiltinPrintCompilerMessage    ;}
  {name: "printMatchingTree"             ; impl: @mplBuiltinPrintMatchingTree       ;}
  {name: "printShadowEvents"             ; impl: @mplBuiltinPrintShadowEvents       ;}
  {name: "printStack"                    ; impl: @mplBuiltinPrintStack              ;}
  {name: "printStackTrace"               ; impl: @mplBuiltinPrintStackTrace         ;}
  {name: "raiseStaticError"              ; impl: @mplBuiltinRaiseStaticError        ;}
  {name: "recursive"                     ; impl: @mplBuiltinRecursive               ;}
  {name: "rshift"                        ; impl: @mplBuiltinRShift                  ;}
  {name: "same"                          ; impl: @mplBuiltinSame                    ;}
  {name: "set"                           ; impl: @mplBuiltinSet                     ;}
  {name: "sin"                           ; impl: @mplBuiltinSin                     ;}
  {name: "sqrt"                          ; impl: @mplBuiltinSqrt                    ;}
  {name: "static"                        ; impl: @mplBuiltinStatic                  ;}
  {name: "storageAddress"                ; impl: @mplBuiltinStorageAddress          ;}
  {name: "storageSize"                   ; impl: @mplBuiltinStorageSize             ;}
  {name: "textSize"                      ; impl: @mplBuiltinTextSize                ;}
  {name: "textSplit"                     ; impl: @mplBuiltinTextSplit               ;}
  {name: "ucall"                         ; impl: @mplBuiltinUcall                   ;}
  {name: "uif"                           ; impl: @mplBuiltinUif                     ;}
  {name: "use"                           ; impl: @mplBuiltinUse                     ;}
  {name: "virtual"                       ; impl: @mplBuiltinVirtual                 ;}
  {name: "xor"                           ; impl: @mplBuiltinXor                     ;}
  {name: "~"                             ; impl: @mplBuiltinNot                     ;}
);

builtinFirst: [0 static];
builtinLast: [builtins fieldCount 0 cast 2 /];

addBuiltin: [
  id: new;
  name:;

  nameId: @name makeStringView @processor.@nameManager.createName;
  bvar: @id VarBuiltin @processor @block createVariable Virtual @processor @block makeStaticity;

  {
    addNameCase: NameCaseLocal;
    refToVar:    bvar new;
    nameInfo:    nameId new;
    file:        0 processor.files.at.get;
  } @processor @block addNameInfo
];

initBuiltins: [
  processor:;
  codeNode: 0 @processor.@blocks.at.get;
  block: @codeNode;
  overload failProc: processor block FailProcForProcessor;

  builtins fieldCount dynamic [
    i builtins @ .name makeStringView i addBuiltin
  ] times
];

{block: Block Ref; processor: Processor Ref; index: Int32;} () {} [
  block:;
  processor:;
  overload failProc: processor block FailProcForProcessor;
  index: new;

  builtinFunc: index builtins @ .@impl;
  @block @processor @builtinFunc call
] "callBuiltin" exportFunction
