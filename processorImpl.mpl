"processorImpl" module
"astNodeType" useModule
"variable" useModule
"codeNode" useModule
"pathUtils" useModule
"staticCall" useModule
"processSubNodes" useModule
"builtinImpl" useModule
"builtins" useModule
"debugWriter" useModule
"processor" useModule
"irWriter" useModule

failProcForProcessor: [
  failProc: [stringMemory printAddr " - fail while handling fail" stringMemory printAddr] func;
  copy message:;
  "ASSERTION FAILED!!!" print LF print
  message print LF print
  "While compiling:" print LF print
  mplBuiltinPrintStackTrace

  "Terminating..." print LF print
  2 exit
] func;

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
} 0 {convention: "cdecl";} "astNodeToCodeNode" importFunction

{
  signature: CFunctionSignature Cref;
  compilerPositionInfo: CompilerPositionInfo Cref;
  multiParserResult: MultiParserResult Cref;
  processor: Processor Ref;
  processorResult: ProcessorResult Ref;
  refToVar: RefToVar Cref;
} () {convention: "cdecl";} "createDtorForGlobalVar" importFunction

processImpl: [
  processorResult:;
  copy unitId:;
  options:;
  multiParserResult:;

  processor: Processor;

  unitId @processor.@unitId set
  multiParserResult.names @processor.@nameToId set
  @options @processor.@options set

  processor.nameToId.getSize @processor.@nameInfos.resize
  @processor.@nameToId [
    pair:;
    id: pair.value;
    key: pair.key;
    key id @processor.@nameInfos.at.@name set
  ] each

  ""           findNameInfo @processor.@emptyNameInfo set
  "CALL"       findNameInfo @processor.@callNameInfo set
  "PRE"        findNameInfo @processor.@preNameInfo set
  "DIE"        findNameInfo @processor.@dieNameInfo set
  "INIT"       findNameInfo @processor.@initNameInfo set
  "ASSIGN"     findNameInfo @processor.@assignNameInfo set
  "self"       findNameInfo @processor.@selfNameInfo set
  "closure"    findNameInfo @processor.@closureNameInfo set
  "inputs"     findNameInfo @processor.@inputsNameInfo set
  "outputs"    findNameInfo @processor.@outputsNameInfo set
  "captures"   findNameInfo @processor.@capturesNameInfo set
  "variadic"   findNameInfo @processor.@variadicNameInfo set
  "failProc"   findNameInfo @processor.@failProcNameInfo set
  "convention" findNameInfo @processor.@conventionNameInfo set

  addCodeNode
  TRUE dynamic @processor.@nodes.last.get.@root set

  @processorResult @processor initBuiltins

  s1: String;
  s2: String;
  processor.options.pointerSize 32nx = [
    "target datalayout = \"e-m:x-p:32:32-i64:64-f80:32-n8:16:32-a:0:32-S32\"" makeStringView addStrToProlog
    "target triple = \"i386-pc-windows-msvc18.0.0\"" makeStringView addStrToProlog
  ] [
    "target datalayout = \"e-m:w-i64:64-f80:128-n8:16:32:64-S128\"" makeStringView addStrToProlog
    "target triple = \"x86_64-pc-windows\"" makeStringView addStrToProlog
  ] if

  "" makeStringView addStrToProlog
  ("mainPath is \"" makeStringView processor.options.mainPath makeStringView "\"" makeStringView) addLog

  addLinkerOptionsDebugInfo

  processor.options.debug [
    @processor [processor:; addDebugProlog @processor.@debugInfo.@unit set] call

    i: 0 dynamic;
    [
      i processor.options.fileNames.dataSize < [
        id: i processor.options.fileNames.at makeStringView addFileDebugInfo;
        id @processor.@debugInfo.@fileNameIds.pushBack
        i 1 + @i set TRUE
      ] &&
    ] loop
  ] when

  #("compiled file " makeStringView n processor.options.fileNames.at makeStringView) addLog

  lastFile: 0 dynamic;

  multiParserResult.nodes.dataSize 0 > [

    dependedFiles: String IndexArray HashTable; # string -> array of indexes of dependent files

    clearProcessorResult: [
      ProcessorResult @processorResult set
    ] func;

    runFile: [
      copy n:;
      n @lastFile set
      fileNodes:  n multiParserResult.nodes.at;
      rootPositionInfo: CompilerPositionInfo;
      1 dynamic @rootPositionInfo.@column set
      1 dynamic @rootPositionInfo.@line set
      0 dynamic @rootPositionInfo.@offset set
      n dynamic @rootPositionInfo.@filename set

      topNodeIndex: StringView 0 NodeCaseCode @processorResult @processor fileNodes multiParserResult rootPositionInfo CFunctionSignature astNodeToCodeNode;

      processorResult.findModuleFail [
        # cant compile this file now, add him to queue
        fr: processorResult.errorInfo.missedModule makeStringView @dependedFiles.find;
        fr.success [
          n @fr.@value.pushBack
        ] [
          a: IndexArray;
          n @a.pushBack
          @processorResult.@errorInfo.@missedModule @a move @dependedFiles.insert
        ] if

        clearProcessorResult
      ] [
        ("compiled file " n processor.options.fileNames.at) addLog
        # call files which depends from this module
        moduleName: topNodeIndex processor.nodes.at.get.moduleName;
        moduleName.getTextSize 0 > [
          fr: moduleName @dependedFiles.find;
          fr.success [
            i: 0 dynamic;
            [
              i fr.value.dataSize < [
                numberOfDependent: fr.value.dataSize 1 - i - fr.value.at;
                numberOfDependent @unfinishedFiles.pushBack
                i 1 + @i set TRUE
              ] &&
            ] loop

            @fr.@value.clear
          ] when

        ] when
      ] if
    ] func;

    unfinishedFiles: IndexArray;
    n: 0 dynamic;
    [
      n multiParserResult.nodes.dataSize < [
        multiParserResult.nodes.dataSize 1 - n - @unfinishedFiles.pushBack
        n 1 + @n set TRUE
      ] &&
    ] loop

    [
      0 unfinishedFiles.dataSize < [
        n: unfinishedFiles.last copy;
        @unfinishedFiles.popBack
        n runFile
        processorResult.success copy
      ] &&
    ] loop

    processorResult.success [
      processor.options.debug [
        lastFile correctUnitInfo
      ] when

      clearProcessorResult

      dependedFiles.getSize 0 > [
        hasError: FALSE dynamic;
        hasErrorMessage: FALSE dynamic;
        dependedFiles [
          # queue is empty, but has uncompiled files
          pair:;
          pair.value.dataSize 0 > [
            fr: pair.key processor.modules.find;
            fr.success not [
              ("missed module: " @pair.@key "; used in file: " pair.value.last processor.options.fileNames.at LF) assembleString @processorResult.@errorInfo.@message set
              TRUE @hasErrorMessage set
            ] when
            TRUE @hasError set
            FALSE @processorResult.@success set
          ] when
        ] each

        hasError [hasErrorMessage not] && [
          String @processorResult.@errorInfo.@message set
          "problem with finding modules" @processorResult.@errorInfo.@message.cat
          LF @processorResult.@errorInfo.@message.cat
          dependedFiles [
            # queue is empty, but has uncompiled files
            pair:;
            pair.value.dataSize 0 > [
              ("need module: " @pair.@key "; used in file: " pair.value.last processor.options.fileNames.at LF) assembleString @processorResult.@errorInfo.@message.cat
            ] when
          ] each
        ] when
      ] when
    ] when
  ] when


  ("all nodes generated" makeStringView) addLog

  [processor.recursiveNodesStack.getSize 0 =] "Recursive stack is not empty!" assert

  processorResult.success [
    #("; total used="           memoryUsed
    # "; varCount="             processor.varCount
    # "; structureVarCount="    processor.structureVarCount
    # "; fieldVarCount="        processor.fieldVarCount
    # "; nodeCount="            processor.nodeCount
    # "; varSize="              Variable storageSize
    # "; fieldSize="            Field storageSize
    # "; structureSize="        Struct   storageSize
    # "; refToVarSize="         RefToVar storageSize
    # "; nodeSize="             CodeNode storageSize
    # "; used in nodes="        processor.nodes getHeapUsedSize
    # "; memoryCounterMalloc="  memoryCounterMalloc
    # "; memoryCounterFree="    memoryCounterFree
    # "; deletedVarCount="      processor.deletedVarCount
    # "; deletedNodeCount="     processor.deletedNodeCount) addLog

    ("nameCount=" processor.nameInfos.dataSize
      "; irNameCount=" processor.nameBuffer.dataSize) addLog

    ("max depth of recursion=" processor.maxDepthOfRecursion) addLog

    processor.usedFloatBuiltins [createFloatBuiltins] when
    processor.usedHeapBuiltins  [createHeapBuiltins] when
    createCtors
    createDtors
    clearUnusedDebugInfo

    i: 0 dynamic;
    [
      i processor.prolog.dataSize < [
        i @processor.@prolog.at @processorResult.@program.cat
        LF  @processorResult.@program.cat
        i 1 + @i set TRUE
      ] &&
    ] loop

    i: 1 dynamic; # 0th node is root fake node
    [
      i processor.nodes.dataSize < [
        currentNode: i @processor.@nodes.at.get;

        currentNode.emptyDeclaration not [currentNode.empty not] && [currentNode.deleted not] && [currentNode.nodeCase NodeCaseCodeRefDeclaration = not] && [
          LF makeStringView @processorResult.@program.cat

          currentNode.header makeStringView @processorResult.@program.cat

          currentNode.nodeCase NodeCaseDeclaration = [currentNode.nodeCase NodeCaseDllDeclaration =] || [
            # no body
          ] [
            " {" @processorResult.@program.cat
            LF   @processorResult.@program.cat

            currentNode.program [
              curInstruction: .value;
              curInstruction.enabled [
                curInstruction.code makeStringView @processorResult.@program.cat
                LF @processorResult.@program.cat
              ] [
                #" ; -> disabled: " makeStringView @processorResult.@program.cat
                #curInstruction.code makeStringView @processorResult.@program.cat
                #LF makeStringView @processorResult.@program.cat
              ] if
            ] each
            "}" @processorResult.@program.cat
          ] if
          LF @processorResult.@program.cat
        ] when
        i 1 + @i set TRUE
      ] &&
    ] loop

    LF @processorResult.@program.cat

    processor.debugInfo.strings [
      s: .value;
      s.getTextSize 0 = not [
        s @processorResult.@program.cat
        LF @processorResult.@program.cat
      ] when
    ] each
  ] when
] func;

{
  processorResult: ProcessorResult Ref;
  unitId: 0;
  options: ProcessorOptions Cref;
  multiParserResult: MultiParserResult Cref;
} () {convention: "cdecl";} [
  processorResult:;
  unitId:;
  options:;
  multiParserResult:;
  multiParserResult
  options
  unitId
  @processorResult processImpl
] "process" exportFunction

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
} 0 {convention: "cdecl";}  [
  signature:;
  compilerPositionInfo:;
  multiParserResult:;
  indexArray:;
  processor:;
  processorResult:;
  nodeCase:;
  parentIndex:;
  functionName:;

  functionName
  parentIndex
  nodeCase
  @processorResult
  @processor
  indexArray
  multiParserResult
  compilerPositionInfo
  signature astNodeToCodeNodeImpl
] "astNodeToCodeNode" exportFunction

createDtorForGlobalVarImpl: [
  forcedSignature:;
  compilerPositionInfo:;
  multiParserResult:;
  processor:;
  processorResult:;
  refToVar:;

  addCodeNode
  codeNode: @processor.@nodes.last.get;
  indexOfCodeNode: processor.nodes.dataSize 1 -;
  currentNode: @codeNode;
  indexOfNode: indexOfCodeNode copy;
  failProc: @failProcForProcessor;

  NodeCaseDtor @codeNode.@nodeCase set
  0 dynamic @codeNode.@parent set
  @compilerPositionInfo @codeNode.@position set

  processor.options.debug [
    addDebugReserve @codeNode.@funcDbgIndex set
  ] when

  begin: RefToVar;
  end: RefToVar;
  refToVar @begin @end ShadowReasonCapture makeShadows

  VarStruct refToVar getVar .data.get.get .unableToDie
  VarStruct      end getVar.@data.get.get.@unableToDie set # fake becouse it is fake shadow

  end killStruct
  dtorName: ("dtor." refToVar getVar.globalId) assembleString;
  dtorNameStringView: dtorName makeStringView;
  dtorNameStringView finalizeCodeNode
] func;

{
  signature: CFunctionSignature Cref;
  compilerPositionInfo: CompilerPositionInfo Cref;
  multiParserResult: MultiParserResult Cref;
  processor: Processor Ref;
  processorResult: ProcessorResult Ref;
  refToVar: RefToVar Cref;
} () {convention: "cdecl";} [
  forcedSignature:;
  compilerPositionInfo:;
  multiParserResult:;
  processor:;
  processorResult:;
  refToVar:;
  refToVar @processorResult @processor multiParserResult compilerPositionInfo forcedSignature createDtorForGlobalVarImpl
] "createDtorForGlobalVar" exportFunction
