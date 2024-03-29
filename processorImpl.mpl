# Copyright (C) 2021 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"Array"     use
"HashTable" use
"Owner"     use
"String"    use
"algorithm" use
"control"   use
"memory"    use

"Block"           use
"MplFile"         use
"NameManager"     use
"Var"             use
"astNodeType"     use
"astOptimizers"   use
"builtins"        use
"codeNode"        use
"debugWriter"     use
"declarations"    use
"defaultImpl"     use
"irWriter"        use
"logger"          use
"parser"          use
"pathUtils"       use
"processSubNodes" use
"processor"       use
"variable"        use

debugMemory [
  "memory.getMemoryMetrics" use
] [] uif

{
  nameManager: NameInfoEntry NameManager Ref;
  multiParserResult: MultiParserResult Ref;
  fileText: StringView Cref;
  fileName: StringView Cref;
  fileId: Int32;
  errorMessage: String Ref;
} () {} [
  errorMessage: fileId: fileName: fileText: multiParserResult: nameManager: ;;;;;;

  parserResult: ParserResult;
  @parserResult fileId fileText makeStringView parseString

  parserResult.success [
    @parserResult optimizeLabels
    @parserResult @nameManager optimizeNames
    @parserResult @multiParserResult concatParserResult
    String @errorMessage set
  ] [
    (fileName "(" parserResult.errorInfo.position.line "," makeStringView parserResult.errorInfo.position.column "): syntax error, "
      parserResult.errorInfo.message) assembleString @errorMessage set
  ] if
] "addToProcessImpl" exportFunction

{
  processor: Processor Ref;
  fileText: StringView Cref;
  fileName: StringView Cref;
  fromCmd: Cond;
} Int32 {} [
  fromCmd: fileName: fileText: processor:;;;;
  newFile: File;

  fileId: processor.files.size;
  fileName toString @newFile.@name set
  fromCmd           @newFile.@usedInParams set
  fileId            @newFile.@fileId set
  fileText toString @newFile.@text set
  fileName toString fileId @processor.@fileNameIds.insert

  processor.options.debug [
    newFile.name @processor addFileDebugInfo @newFile.!debugId
  ] when

  @newFile owner @processor.@files.append
  #here we can implement search in cmd
  fileId
] "addFileNameToProcessor" exportFunction

{
  program: String Ref;
  result: String Ref;
  unitId: 0;
  options: ProcessorOptions Cref;
  nameManager: NameInfoEntry NameManager Ref;
  multiParserResult: MultiParserResult Ref;
} () {} [
  program:;
  result:;
  unitId: new;
  options:;
  nameManager:;
  multiParserResult:;

  processor: Processor;

  unitId @processor.@unitId set
  @nameManager @processor.@nameManager set
  @options @processor.@options set
  @multiParserResult @processor.!multiParserResult

  ""            makeStringView @processor findNameInfo @processor.@specialNames.@emptyNameInfo set
  "CALL"        makeStringView @processor findNameInfo @processor.@specialNames.@callNameInfo set
  "PRE"         makeStringView @processor findNameInfo @processor.@specialNames.@preNameInfo set
  "DIE"         makeStringView @processor findNameInfo @processor.@specialNames.@dieNameInfo set
  "INIT"        makeStringView @processor findNameInfo @processor.@specialNames.@initNameInfo set
  "ASSIGN"      makeStringView @processor findNameInfo @processor.@specialNames.@assignNameInfo set
  "self"        makeStringView @processor findNameInfo @processor.@specialNames.@selfNameInfo set
  "closure"     makeStringView @processor findNameInfo @processor.@specialNames.@closureNameInfo set
  "inputs"      makeStringView @processor findNameInfo @processor.@specialNames.@inputsNameInfo set
  "outputs"     makeStringView @processor findNameInfo @processor.@specialNames.@outputsNameInfo set
  "captures"    makeStringView @processor findNameInfo @processor.@specialNames.@capturesNameInfo set
  "variadic"    makeStringView @processor findNameInfo @processor.@specialNames.@variadicNameInfo set
  "failProc"    makeStringView @processor findNameInfo @processor.@specialNames.@failProcNameInfo set
  "convention"  makeStringView @processor findNameInfo @processor.@specialNames.@conventionNameInfo set
  "SCHEMA_NAME" makeStringView @processor findNameInfo @processor.@specialNames.@schemaNameNameInfo set

  @processor addBlock
  TRUE dynamic @processor.@blocks.last.get.@root set

  errorInCmdNames: FALSE dynamic;
  processor.options.fileNames.size [
    errorInCmdNames ~ [
      #here set first parameter to TRUE to make cmd files visible
      TRUE i processor.options.fileNames @ makeStringView i processor.options.fileTexts @ makeStringView @processor addFileNameToProcessor 0 < [
        TRUE !errorInCmdNames
      ] when
    ] when
  ] times

  @processor.@blocks.last.get 0 @processor.@files.at.get.@rootBlock.set

  @processor initBuiltins

  [
    block: @processor.@blocks.last.get;
    0n8 VarInvalid @processor @block createVariable
    Dynamic @processor block makeStorageStaticity
    Dirty   @processor block makeStaticity
    @processor.@varForFails set
  ] call

  s1: String;
  s2: String;

  options.dataLayout "" = ~ [("target datalayout = \"" options.dataLayout "\"") assembleString @processor addStrToProlog] when
  options.triple "" = ~ [("target triple = \"" options.triple "\"") assembleString @processor addStrToProlog] when

  "" makeStringView @processor addStrToProlog
  ("mainPath is \"" makeStringView processor.options.mainPath makeStringView "\"" makeStringView) addLog

  @processor addLinkerOptionsDebugInfo

  processor.options.debug [
    @processor [processor:; @processor addDebugProlog @processor.@debugInfo.@unit set] call
  ] when

  lastFile: File Cref;

  multiParserResult.roots.size 0 > [
    dependedFiles: String Int32 Array HashTable; # string -> array of indexes of dependent files
    cachedGlobalErrorInfoSize: 0;

    runFile: [
      n:;
      file: n @processor.@files.at.get;
      file !lastFile
      astArrayIndex: n 1 - processor.multiParserResult.roots.at;

      processor.result.globalErrorInfo.size @cachedGlobalErrorInfoSize set

      compilerPositionInfo: CompilerPositionInfo;

      1    @compilerPositionInfo.@line set
      1    @compilerPositionInfo.@column set
      file @compilerPositionInfo.@file.set
      compilerPositionInfo @processor.@positions.append
      topNodeIndex: StringView 0 NodeCaseCode astArrayIndex CFunctionSignature @processor astNodeToCodeNode;
      @processor.@positions.popBack

      processor.result.findModuleFail [
        # cant compile this file now, add him to queue
        ("postpone compilation of \"" file.name "\" because \"" processor.result.errorInfo.missedModule "\" is not compiled yet") addLog
        fr: processor.result.errorInfo.missedModule makeStringView @dependedFiles.find;
        fr.success [
          n @fr.@value.append
        ] [
          a: Int32 Array;
          n @a.append
          @processor.result.@errorInfo.@missedModule @a @dependedFiles.insert
        ] if

        -1 @processor.@result clearProcessorResult
      ] [
        moduleName: file.name;
        ("compiled file " moduleName) addLog

        topNodeIndex @processor.@blocks.at.get @file.@rootBlock.set

        moduleName topNodeIndex @processor.@modules.insert

        # call files which depends from this module
        moduleName.size 0 > [
          fr: moduleName @dependedFiles.find;
          fr.success [
            i: 0 dynamic;
            [
              i fr.value.size < [
                numberOfDependent: fr.value.size 1 - i - fr.value.at;
                (numberOfDependent processor.files.at.get.name " is dependent from it, try to recompile") addLog
                numberOfDependent @processor.@unfinishedFiles.append
                i 1 + @i set TRUE
              ] &&
            ] loop

            @fr.@value.clear
          ] when

        ] when
      ] if
    ];

    n: 0 dynamic;
    [
      n processor.multiParserResult.roots.size < [
        processor.multiParserResult.roots.size n - @processor.@unfinishedFiles.append
        n 1 + @n set TRUE
      ] &&
    ] loop

    [
      0 processor.unfinishedFiles.size < [
        n: processor.unfinishedFiles.last new;
        @processor.@unfinishedFiles.popBack
        n runFile
        processor.result.success new
      ] &&
    ] loop

    processor.result.success [
      @processor checkBeginEndPoint
    ] when

    processor.result.success ~ [
      @processor.@result.@errorInfo @processor.@result.@globalErrorInfo.append
    ] when

    processor.result.globalErrorInfo.size 0 > [
      FALSE @processor.@result.@success set
    ] when

    processor.result.success [
      processor.options.debug [
        lastFile @processor correctUnitInfo
      ] when

      0 @processor.@result clearProcessorResult

      dependedFiles.size 0 > [
        hasError: FALSE dynamic;
        hasErrorMessage: FALSE dynamic;
        dependedFiles [
          # queue is empty, but has uncompiled files
          pair:;
          pair.value.size 0 > [
            fr: pair.key processor.modules.find;
            fr.success ~ [
              ("missing module \"" @pair.@key "\" used in file: \"" pair.value.last processor.options.fileNames.at "\"" LF) assembleString @processor.@result.@errorInfo.@message.cat
              TRUE @hasErrorMessage set
            ] when
            TRUE @hasError set
            FALSE @processor.@result.@success set
          ] when
        ] each

        hasError [hasErrorMessage ~] && [
          String @processor.@result.@errorInfo.@message set
          "problem with finding modules" @processor.@result.@errorInfo.@message.cat

          LF @processor.@result.@errorInfo.@message.cat
          dependedFiles [
            # queue is empty, but has uncompiled files
            pair:;
            pair.value.size 0 > [
              ("need module: " @pair.@key "; used in file: " pair.value.last processor.options.fileNames.at LF) assembleString @processor.@result.@errorInfo.@message.cat
            ] when
          ] each
        ] when

        processor.result.success ~ [
          @processor.@result.@errorInfo @processor.@result.@globalErrorInfo.append
        ] when
      ] when
    ] when
  ] when

  ("all nodes generated" makeStringView) addLog
  [processor compilable ~ [processor.recursiveNodesStack.size 0 =] ||] "Recursive stack is not empty!" assert

  getTreeSize: [
    result: 0nx dynamic;
    processor.matchingNodes [
      current:;
      current.valid? [
        current.get.treeMemory.@Item storageSize current.get.treeMemory.reserve Natx cast * result + !result
        current.get.treeMemory [
          current:;
          current.childIndices.@Item storageSize current.childIndices.reserve Natx cast * result + !result
        ] each
      ] when
    ] each

    result
  ];

  processor.result.success [
    ("nameCount=" processor.nameManager.names.size
      "; irNameCount=" processor.nameBuffer.size "; block count=" processor.blocks.size "; block size=" BlockSchema storageSize "; est var count=" processor.variables.size 4096 * "; var size=" VarSchema storageSize "; tree size=" getTreeSize) addLog

    ("max depth of recursion=" processor.maxDepthOfRecursion) addLog

    hasLogs [
      varHeadMemory: 0nx;
      varShadowMemory: 0nx;
      totalFieldCount: 0;

      varStaticStoragedMemory:  0nx;
      varDynamicStoragedHeadMemory:  0nx;
      varDynamicStoragedShadowMemory:  0nx;

      getCoordsMemory: [
        where:;

        result: 0nx;
        where.dataReserve Natx cast where.elementSize * result + !result
        where [
          where1:;
          where1.dataReserve Natx cast where1.elementSize * result + !result
          where1 [
            where2:;
            where2.dataReserve Natx cast where2.elementSize * result + !result
          ] each
        ] each

        result
      ];

      coordsMemory: processor.captureTable.simpleNames  getCoordsMemory;

      getVariableUsedMemory: [
        var:;

        var.data.getTag VarStruct = [
          struct: VarStruct var.data.get.get;
          struct storageSize struct.fields.size Natx cast Field storageSize * +
          var storageSize +
        ] [
          var storageSize
        ] if
      ];

      processor.variables [
        [
          var:;
          varSize: var getVariableUsedMemory;

          var.capturedHead getVar.host var.host is ~ [
            varSize varShadowMemory + !varShadowMemory
          ] [
            varSize varHeadMemory + !varHeadMemory
          ] if

          var.data.getTag VarStruct = [
            VarStruct var.data.get.get.fields.size totalFieldCount + !totalFieldCount
          ] when

          var.storageStaticity Dynamic = [
            var.topologyIndex 0 < ~ [
              varSize varDynamicStoragedShadowMemory + !varDynamicStoragedShadowMemory
            ] [
              varSize varDynamicStoragedHeadMemory + !varDynamicStoragedHeadMemory
            ] if
          ] [
            varSize varStaticStoragedMemory + !varStaticStoragedMemory
          ] if
        ] each
      ] each

      beventCount: 0;
      meventCount: 0;
      captureCount: 0;
      virtualCaptureCount: 0;
      stringCaptureCount: 0;
      failedCaptureCount: 0;
      dependentsSize: 0;
      failedCaptureNames: StringView Int32 HashTable;

      eventTagCount: Int32 ShadowEvent.typeList fieldCount array;

      processor.blocks [
        block: .get;
        block.buildingMatchingInfo.shadowEvents.size beventCount + !beventCount
        block.matchingInfo.shadowEvents.size meventCount + !meventCount
        block.matchingInfo.captures.size captureCount + !captureCount
        block.dependentPointers.size dependentsSize + !dependentsSize

        block.matchingInfo.shadowEvents [
          event:;
          src: event.getTag @eventTagCount @;
          src 1 + @src set

          event.getTag ShadowReasonCapture = [
            branch: ShadowReasonCapture event.get;
            branch.stable ~ [
              branch.refToVar getVar processor.varForFails getVar is [
                failedCaptureCount 1 + !failedCaptureCount
                name: branch.nameInfo processor.nameManager.getText;
                fr: name @failedCaptureNames.find;
                fr.success [
                  fr.value 1 + @fr.@value set
                ] [
                  name 1 @failedCaptureNames.insert
                ] if
              ] when

              branch.refToVar isGlobal [branch.refToVar isUnallocable] && [
                stringCaptureCount 1 + !stringCaptureCount
              ] when

              branch.refToVar isGlobal [branch.refToVar isVirtual] && [
                virtualCaptureCount 1 + !virtualCaptureCount
              ] when
            ] when
          ] when
        ] each
      ] each

      (
        debugMemory ["; currentAllocationSize=" getMemoryMetrics.memoryCurrentAllocationSize] [] uif
        "; coordsMemory=" coordsMemory
        "; varShadowMemory=" varShadowMemory "; varHeadMemory=" varHeadMemory
        "; varDynamicStoragedHeadMemory=" varDynamicStoragedHeadMemory
        "; varDynamicStoragedShadowMemory=" varDynamicStoragedShadowMemory
        "; varStaticStoragedMemory=" varStaticStoragedMemory
        "; totalFieldCount=" totalFieldCount "; fieldSize=" Field storageSize
        "; beventCount=" beventCount
        "; meventCount=" meventCount
        "; meventCountByTag=" 0 eventTagCount @ ":" 1 eventTagCount @ ":" 2 eventTagCount @ ":" 3 eventTagCount @ ":" 4 eventTagCount @
        "; eventSize=" ShadowEvent storageSize
      ) addLog

      (
        "; captureCount=" captureCount "; failedCaptureCount=" failedCaptureCount "; stringCaptureCount=" stringCaptureCount "; virtualCaptureCount=" virtualCaptureCount
        "; captureSize=" Capture storageSize
        "; dependentPointersCount=" dependentsSize "; dependentPointer size=" (RefToVar RefToVar FALSE dynamic) storageSize
      ) addLog

      ("failed captureNames:") addLog
      failedCaptureNames [
        pair:;
        ("name=" pair.key "; count=" pair.value) addLog
      ] each
    ] when

    processor.options.callTrace [@processor createCallTraceData] when
    processor.usedFloatBuiltins [@processor createFloatBuiltins] when

    @processor createCheckers
    @processor createDtors
    @processor addCtorsToBeginFunc
    @processor addDtorsToEndFunc
    @processor clearUnusedDebugInfo
    @processor addAliasesForUsedNodes

    i: 0 dynamic;
    [
      i processor.prolog.size < [
        i @processor.@prolog.at @processor.@result.@program.cat
        LF  @processor.@result.@program.cat
        i 1 + @i set TRUE
      ] &&
    ] loop

    i: 1 dynamic; # 0th node is root fake node
    [
      i processor.blocks.size < [
        block: i @processor.@blocks.at.get;
        block nodeHasCode [
          LF makeStringView @processor.@result.@program.cat

          block.header makeStringView @processor.@result.@program.cat

          block.nodeCase NodeCaseDeclaration = ~ [
            " {" @processor.@result.@program.cat
            LF   @processor.@result.@program.cat

            block.program [
              curInstruction:;
              curInstruction.enabled [
                block.programTemplate.getStringView curInstruction.codeOffset curInstruction.codeSize slice @processor.@result.@program.cat
                LF @processor.@result.@program.cat
              ] [
              ] if
            ] each
            "}" @processor.@result.@program.cat
          ] when
          LF @processor.@result.@program.cat
        ] when
        i 1 + @i set TRUE
      ] &&
    ] loop

    LF @processor.@result.@program.cat

    processor.debugInfo.strings [
      s:;
      s.size 0 = ~ [
        s @processor.@result.@program.cat
        LF @processor.@result.@program.cat
      ] when
    ] each
  ] [
    ("nameCount=" processor.nameManager.names.size
      "; irNameCount=" processor.nameBuffer.size "; block count=" processor.blocks.size "; block size=" BlockSchema storageSize "; est var count=" processor.variables.size 4096 * "; var size=" VarSchema storageSize "; tree size=" getTreeSize) addLog
  ] if

  processor.result.success ~ [
    processor.result.globalErrorInfo.size [
      current: i processor.result.globalErrorInfo @;
      i 0 > [LF @result.cat] when
      current.position.size 0 = [
        ("error, "  current.message LF) [@result.cat] each
      ] [
        first: TRUE;
        current.position.size [
          nodePosition: i current.position @;
          processor.options.hidePrefixes [nodePosition.file.name swap beginsWith ~] all [
            (nodePosition.file.name "(" nodePosition.line  ","  nodePosition.column "): ") [@result.cat] each

            first [
              ("error, [" nodePosition.token "], " current.message LF) [@result.cat] each
              FALSE !first
            ] [
              ("[" nodePosition.token "], called from here" LF) [@result.cat] each
            ] if
          ] when
        ] times
      ] if
    ] times
  ] [
    @processor.@result.@program @program set
  ] if
] "process" exportFunction

{
  processor: Processor Ref;
  refToVar: RefToVar Cref;
} () {} [
  processor:;
  refToVar:;

  @processor addBlock
  codeNode: @processor.@blocks.last.get;
  block: @codeNode;
  overload failProc: processor block FailProcForProcessor;

  NodeCaseDtor                    @codeNode.@nodeCase set
  0 dynamic                       @codeNode.@parent set
  @processor @codeNode getTopNode @codeNode.@topNode.set

  compilerPositionInfo: processor.positions.last new;

  compilerPositionInfo.file   @codeNode.@file.set
  compilerPositionInfo        @codeNode.@beginPosition set

  processor.options.debug [
    @processor addDebugReserve @codeNode.@funcDbgIndex set
  ] when

  shadow: RefToVar;
  @shadow refToVar ShadowReasonCapture @processor @block makeShadows

  VarStruct refToVar getVar.data .get.get .unableToDie
  VarStruct @shadow  getVar.@data.get.get.@unableToDie set # fake becouse it is fake shadow

  shadow @processor @block killStruct
  dtorName: ("dtor." refToVar getVar.globalId) assembleString;
  dtorNameStringView: dtorName makeStringView;
  dtorNameStringView CFunctionSignature @processor @block finalizeCodeNode
] "createDtorForGlobalVar" exportFunction
