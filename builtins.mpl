"builtins" module
"control" useModule

virtual builtins: (
  ["!"                       ] [mplBuiltinExclamation             ]
  ["@"                       ] [mplBuiltinAt                      ]
  ["+"                       ] [mplBuiltinAdd                     ]
  ["-"                       ] [mplBuiltinSub                     ]
  ["*"                       ] [mplBuiltinMul                     ]
  ["/"                       ] [mplBuiltinDiv                     ]
  ["&"                       ] [mplBuiltinStrCat                  ]
  ["="                       ] [mplBuiltinEqual                   ]
  ["<"                       ] [mplBuiltinLess                    ]
  [">"                       ] [mplBuiltinGreater                 ]
  ["^"                       ] [mplBuiltinPow                     ]
  ["~"                       ] [mplBuiltinNot                     ]

  ["addressToReference"      ] [mplBuiltinAddressToReference      ]
  ["alignment"               ] [mplBuiltinAlignment               ]
  ["and"                     ] [mplBuiltinAnd                     ]
  ["array"                   ] [mplBuiltinArray                   ]
  ["call"                    ] [mplBuiltinCall                    ]
  ["cast"                    ] [mplBuiltinCast                    ]
  ["ceil"                    ] [mplBuiltinCeil                    ]
  ["codeRef"                 ] [mplBuiltinCodeRef                 ]
  ["cos"                     ] [mplBuiltinCos                     ]
  #["cref"                    ] [mplBuiltinCref                    ]
  ["compileOnce"             ] [mplBuiltinCompileOnce             ]
  ["COMPILER_VERSION"        ] [mplBuiltinCompilerVersion         ]
  ["const"                   ] [mplBuiltinConst                   ]
  ["copy"                    ] [mplBuiltinCopy                    ]
  ["DEBUG"                   ] [mplBuiltinDebug                   ]
  ["def"                     ] [mplBuiltinDef                     ]
  ["delete"                  ] [mplBuiltinDelete                  ]
  #["deref"                   ] [mplBuiltinDeref                   ]
  #["dirty"                   ] [mplBuiltinDirty                   ]
  ["dynamic"                 ] [mplBuiltinDirty                   ]
  ["exportFunction"          ] [mplBuiltinExportFunction          ]
  ["exportVariable"          ] [mplBuiltinExportVariable          ]
  ["FALSE"                   ] [mplBuiltinFalse                   ]
  ["failProc"                ] [mplBuiltinFailProc                ]
  ["fieldCount"              ] [mplBuiltinFieldCount              ]
  ["fieldIndex"              ] [mplBuiltinFieldIndex              ]
  ["fieldName"               ] [mplBuiltinFieldName               ]
  ["floor"                   ] [mplBuiltinFloor                   ]
  ["has"                     ] [mplBuiltinHas                     ]
  ["HAS_LOGS"                ] [mplBuiltinHasLogs                 ]
  ["if"                      ] [mplBuiltinIf                      ]
  ["is"                      ] [mplBuiltinIs                      ]
  ["isMoved"                 ] [mplBuiltinIsMoved                 ]
  ["importFunction"          ] [mplBuiltinImportFunction          ]
  ["importVariable"          ] [mplBuiltinImportVariable          ]
  ["includeModule"           ] [mplBuiltinIncludeModule           ]
  ["isConst"                 ] [mplBuiltinIsConst                 ]
  ["isCombined"              ] [mplBuiltinIsCombined              ]
  ["LF"                      ] [mplBuiltinLF                      ]
  ["log"                     ] [mplBuiltinLog                     ]
  ["log10"                   ] [mplBuiltinLog10                   ]
  ["loop"                    ] [mplBuiltinLoop                    ]
  ["lshift"                  ] [mplBuiltinLShift                  ]
  ["manuallyInitVariable"    ] [mplBuiltinManuallyInitVariable    ]
  ["manuallyDestroyVariable" ] [mplBuiltinManuallyDestroyVariable ]
  ["mod"                     ] [mplBuiltinMod                     ]
  ["module"                  ] [mplBuiltinModule                  ]
  ["move"                    ] [mplBuiltinMove                    ]
  ["moveIf"                  ] [mplBuiltinMoveIf                  ]
  ["neg"                     ] [mplBuiltinNeg                     ]
  ["new"                     ] [mplBuiltinNew                     ]
  ["newVarOfTheSameType"     ] [mplBuiltinNewVarOfTheSameType     ]
  ["not"                     ] [mplBuiltinNot                     ]
  ["or"                      ] [mplBuiltinOr                      ]
  ["printCompilerMessage"    ] [mplBuiltinPrintCompilerMessage    ]
  ["printStack"              ] [mplBuiltinPrintStack              ]
  ["printStackTrace"         ] [mplBuiltinPrintStackTrace         ]
  ["printVariableCount"      ] [mplBuiltinPrintVariableCount      ]
  ["recursive"               ] [mplBuiltinRecursive               ]
  #["ref"                     ] [mplBuiltinRef                     ]
  ["rshift"                  ] [mplBuiltinRShift                  ]
  ["same"                    ] [mplBuiltinSame                    ]
  ["schema"                  ] [mplBuiltinSchema                  ]
  ["set"                     ] [mplBuiltinSet                     ]
  ["sin"                     ] [mplBuiltinSin                     ]
  ["sqrt"                    ] [mplBuiltinSqrt                    ]
  ["static"                  ] [mplBuiltinStatic                  ]
  ["storageSize"             ] [mplBuiltinStorageSize             ]
  ["storageAddress"          ] [mplBuiltinStorageAddress          ]
  ["textSize"                ] [mplBuiltinTextSize                ]
  ["textSplit"               ] [mplBuiltinTextSplit               ]
  ["TRUE"                    ] [mplBuiltinTrue                    ]
  ["uif"                     ] [mplBuiltinUif                     ]
  ["ucall"                   ] [mplBuiltinUcall                   ]
  ["useModule"               ] [mplBuiltinUseModule               ]
  ["virtual"                 ] [mplBuiltinVirtual                 ]
  ["xor"                     ] [mplBuiltinXor                     ]
);

builtinFirst: [0 static] func;
builtinLast: [builtins fieldCount 0 cast 2 /] func;

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
] func;

initBuiltins: [
  processor:;
  processorResult:;
  indexOfNode: 0 dynamic;
  codeNode: indexOfNode @processor.@nodes.at.get;
  currentNode: @codeNode;
  failProc: @failProcForProcessor;

  initBuiltinsInRange: [
    first:last: copy; copy;
    i: first copy;
    [
      i last < [
        i 2 * builtins @ call makeStringView i addBuiltin
        i 1 + @i set
        TRUE static
      ] [
        FALSE static
      ] if
    ] loop
  ] func;

  builtinMiddle: builtinFirst builtinLast + 2 /;
  builtinFirst builtinMiddle initBuiltinsInRange
  builtinMiddle builtinLast initBuiltinsInRange
] func;

callBuiltin: [
  builtinFirst builtinLast [
    2 * 1 + builtins @ call
  ] staticCall
] func;
