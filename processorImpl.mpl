"HashTable.HashTable" use
"Owner.owner" use
"String.String" use
"String.StringView" use
"String.addLog" use
"String.assembleString" use
"String.makeStringView" use
"String.toString" use
"control" use
"memory.debugMemory" use

"Block.BlockSchema" use
"Block.Capture" use
"Block.CFunctionSignature" use
"Block.CompilerPositionInfo" use
"Block.NodeCaseCode" use
"Block.NodeCaseDeclaration" use
"Block.NodeCaseDtor" use
"Block.ShadowEvent" use
"File.File" use
"NameManager.NameManager" use
"Var.Dirty" use
"Var.Dynamic" use
"Var.Field" use
"Var.RefToVar" use
"Var.ShadowReasonCapture" use
"Var.VarInvalid" use
"Var.VarSchema" use
"Var.VarStruct" use
"Var.getVar" use
"astNodeType.IndexArray" use
"astNodeType.MultiParserResult" use
"builtins.initBuiltins" use
"codeNode.addBlock" use
"codeNode.astNodeToCodeNode" use
"codeNode.createVariable" use
"codeNode.finalizeCodeNode" use
"codeNode.killStruct" use
"codeNode.makeStaticity" use
"codeNode.makeStorageStaticity" use
"debugWriter.addDebugProlog" use
"debugWriter.addDebugReserve" use
"debugWriter.addFileDebugInfo" use
"debugWriter.addLinkerOptionsDebugInfo" use
"debugWriter.clearUnusedDebugInfo" use
"debugWriter.correctUnitInfo" use
"declarations.makeShadows" use
"defaultImpl.FailProcForProcessor" use
"defaultImpl.compilable" use
"defaultImpl.findNameInfo" use
"defaultImpl.nodeHasCode" use
"irWriter.addAliasesForUsedNodes" use
"irWriter.addStrToProlog" use
"irWriter.createCallTraceData" use
"irWriter.createCtors" use
"irWriter.createDtors" use
"irWriter.createFloatBuiltins" use
"pathUtils.extractFilename" use
"pathUtils.stripExtension" use
"processSubNodes.clearProcessorResult" use
"processor.NameInfoEntry" use
"processor.Processor" use
"processor.ProcessorOptions" use

debugMemory [
  "memory.getMemoryMetrics" use
] [] uif

{
  program: String Ref;
  result: String Ref;
  unitId: 0;
  options: ProcessorOptions Cref;
  nameManager: NameInfoEntry NameManager Ref;
  multiParserResult: MultiParserResult Cref;
} () {} [
  program:;
  result:;
  copy unitId:;
  options:;
  nameManager:;
  multiParserResult:;

  processor: Processor;

  unitId @processor.@unitId set
  @nameManager move @processor.@nameManager set
  @options @processor.@options set
  multiParserResult @processor.!multiParserResult

  ""           makeStringView @processor findNameInfo @processor.@emptyNameInfo set
  "CALL"       makeStringView @processor findNameInfo @processor.@callNameInfo set
  "PRE"        makeStringView @processor findNameInfo @processor.@preNameInfo set
  "DIE"        makeStringView @processor findNameInfo @processor.@dieNameInfo set
  "INIT"       makeStringView @processor findNameInfo @processor.@initNameInfo set
  "ASSIGN"     makeStringView @processor findNameInfo @processor.@assignNameInfo set
  "self"       makeStringView @processor findNameInfo @processor.@selfNameInfo set
  "closure"    makeStringView @processor findNameInfo @processor.@closureNameInfo set
  "inputs"     makeStringView @processor findNameInfo @processor.@inputsNameInfo set
  "outputs"    makeStringView @processor findNameInfo @processor.@outputsNameInfo set
  "captures"   makeStringView @processor findNameInfo @processor.@capturesNameInfo set
  "variadic"   makeStringView @processor findNameInfo @processor.@variadicNameInfo set
  "failProc"   makeStringView @processor findNameInfo @processor.@failProcNameInfo set
  "convention" makeStringView @processor findNameInfo @processor.@conventionNameInfo set

  @processor addBlock
  TRUE dynamic @processor.@blocks.last.get.@root set

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
  processor.options.pointerSize 32nx = [
    "target datalayout = \"e-m:x-p:32:32-i64:64-f80:32-n8:16:32-a:0:32-S32\"" makeStringView @processor addStrToProlog
    "target triple = \"i386-pc-windows-msvc18.0.0\"" makeStringView @processor addStrToProlog
  ] [
    "target datalayout = \"e-m:w-i64:64-f80:128-n8:16:32:64-S128\"" makeStringView @processor addStrToProlog
    "target triple = \"x86_64-pc-windows\"" makeStringView @processor addStrToProlog
  ] if

  "" makeStringView @processor addStrToProlog
  ("mainPath is \"" makeStringView processor.options.mainPath makeStringView "\"" makeStringView) addLog

  processor.options.callTrace [@processor createCallTraceData] when

  @processor addLinkerOptionsDebugInfo

  processor.options.fileNames.size @processor.@files.resize
  processor.options.fileNames.size [
    File owner i @processor.@files.at set
    i processor.options.fileNames.at copy i @processor.@files.at.get.!name
  ] times

  processor.options.debug [
    @processor [processor:; @processor addDebugProlog @processor.@debugInfo.@unit set] call

    processor.files.size [
      i processor.files.at.get.name @processor addFileDebugInfo i @processor.@files.at.get.!debugId
    ] times
  ] when

  lastFile: File Cref;

  multiParserResult.nodes.dataSize 0 > [

    dependedFiles: String IndexArray HashTable; # string -> array of indexes of dependent files
    cachedGlobalErrorInfoSize: 0;

    runFile: [
      n:;
      file: n @processor.@files.at.get;
      file !lastFile
      fileNode: n processor.multiParserResult.nodes.at;
      rootPositionInfo: CompilerPositionInfo;
      file @rootPositionInfo.@file.set
      1    @rootPositionInfo.!line
      1    @rootPositionInfo.!column

      processor.result.globalErrorInfo.getSize @cachedGlobalErrorInfoSize set
      topNodeIndex: StringView 0 NodeCaseCode fileNode file rootPositionInfo CFunctionSignature @processor astNodeToCodeNode;

      processor.result.findModuleFail [
        # cant compile this file now, add him to queue
        ("postpone compilation of \"" file.name "\" because \"" processor.result.errorInfo.missedModule "\" is not compiled yet") addLog
        fr: processor.result.errorInfo.missedModule makeStringView @dependedFiles.find;
        fr.success [
          n @fr.@value.pushBack
        ] [
          a: IndexArray;
          n @a.pushBack
          @processor.result.@errorInfo.@missedModule @a move @dependedFiles.insert
        ] if

        cachedGlobalErrorInfoSize @processor.@result clearProcessorResult
      ] [
        moduleName: file.name;
        ("compiled file " moduleName) addLog

        topNodeIndex @processor.@blocks.at.get @file.@rootBlock.set

        moduleName stripExtension extractFilename toString !moduleName
        moduleName topNodeIndex @processor.@modules.insert

        # call files which depends from this module
        moduleName.size 0 > [
          fr: moduleName @dependedFiles.find;
          fr.success [
            i: 0 dynamic;
            [
              i fr.value.dataSize < [
                numberOfDependent: fr.value.dataSize 1 - i - fr.value.at;
                (numberOfDependent processor.files.at.get.name " is dependent from it, try to recompile") addLog
                numberOfDependent @unfinishedFiles.pushBack
                i 1 + @i set TRUE
              ] &&
            ] loop

            @fr.@value.clear
          ] when

        ] when
      ] if
    ];

    unfinishedFiles: IndexArray;
    n: 0 dynamic;
    [
      n processor.multiParserResult.nodes.dataSize < [
        processor.multiParserResult.nodes.dataSize 1 - n - @unfinishedFiles.pushBack
        n 1 + @n set TRUE
      ] &&
    ] loop

    [
      0 unfinishedFiles.dataSize < [
        n: unfinishedFiles.last copy;
        @unfinishedFiles.popBack
        n runFile
        processor.result.success copy
      ] &&
    ] loop

    processor.result.success ~ [
      @processor.@result.@errorInfo move @processor.@result.@globalErrorInfo.pushBack
    ] when

    processor.result.globalErrorInfo.getSize 0 > [
      FALSE @processor.@result.@success set
    ] when

    processor.result.success [
      processor.options.debug [
        lastFile @processor correctUnitInfo
      ] when

      0 @processor.@result clearProcessorResult

      dependedFiles.getSize 0 > [
        hasError: FALSE dynamic;
        hasErrorMessage: FALSE dynamic;
        dependedFiles [
          # queue is empty, but has uncompiled files
          pair:;
          pair.value.dataSize 0 > [
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
            pair.value.dataSize 0 > [
              ("need module: " @pair.@key "; used in file: " pair.value.last processor.options.fileNames.at LF) assembleString @processor.@result.@errorInfo.@message.cat
            ] when
          ] each
        ] when

        processor.result.success ~ [
          @processor.@result.@errorInfo move @processor.@result.@globalErrorInfo.pushBack
        ] when
      ] when
    ] when
  ] when


  ("all nodes generated" makeStringView) addLog
  [processor compilable ~ [processor.recursiveNodesStack.getSize 0 =] ||] "Recursive stack is not empty!" assert

  processor.result.success [
    ("nameCount=" processor.nameManager.names.dataSize
      "; irNameCount=" processor.nameBuffer.dataSize "; block count=" processor.blocks.getSize "; block size=" BlockSchema storageSize "; est var count=" processor.variables.getSize 4096 * "; var size=" VarSchema storageSize) addLog

    ("max depth of recursion=" processor.maxDepthOfRecursion) addLog

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

    coordsMemory:
      processor.captureTable.simpleNames  getCoordsMemory
      processor.captureTable.selfNames    getCoordsMemory +
      processor.captureTable.closureNames getCoordsMemory +;

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
    failedCaptureCount: 0;

    eventTagCount: Int32 6 array;

    processor.blocks [
      block: .get;
      block.buildingMatchingInfo.shadowEvents.size beventCount + !beventCount
      block.matchingInfo.shadowEvents.size meventCount + !meventCount
      block.matchingInfo.captures.size captureCount + !captureCount

      block.matchingInfo.shadowEvents [
        event:;
        src: event.getTag @eventTagCount @;
        src 1 + @src set

        event.getTag ShadowReasonCapture = [
          branch: ShadowReasonCapture event.get;
          branch.refToVar getVar processor.varForFails getVar is [
            failedCaptureCount 1 + !failedCaptureCount
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
      "; meventCountByTag=" 0 eventTagCount @ ":" 1 eventTagCount @ ":" 2 eventTagCount @ ":" 3 eventTagCount @ ":" 4 eventTagCount @ ":" 5 eventTagCount @
      "; eventSize=" ShadowEvent storageSize
      "; captureCount=" captureCount "; failedCaptureCount=" failedCaptureCount
      "; captureSize=" Capture storageSize
    ) addLog

    processor.usedFloatBuiltins [@processor createFloatBuiltins] when
    processor.options.callTrace processor.options.threadModel 1 = and @processor createCtors
    @processor createDtors
    @processor clearUnusedDebugInfo
    @processor addAliasesForUsedNodes

    i: 0 dynamic;
    [
      i processor.prolog.dataSize < [
        i @processor.@prolog.at @processor.@result.@program.cat
        LF  @processor.@result.@program.cat
        i 1 + @i set TRUE
      ] &&
    ] loop

    i: 1 dynamic; # 0th node is root fake node
    [
      i processor.blocks.dataSize < [
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
                block.programTemplate.getStringView curInstruction.codeOffset curInstruction.codeSize view @processor.@result.@program.cat
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
  ] when

  processor.result.success ~ [
    processor.result.globalErrorInfo.getSize [
      current: i processor.result.globalErrorInfo @;
      i 0 > [LF @result.cat] when
      current.position.getSize 0 = [
        ("error, "  current.message LF) [@result.cat] each
      ] [
        current.position.getSize [
          nodePosition: i current.position @;
          (nodePosition.file.name "(" nodePosition.line  ","  nodePosition.column "): ") [@result.cat] each

          i 0 = [
            ("error, [" nodePosition.token "], " current.message LF) [@result.cat] each
          ] [
            ("[" nodePosition.token "], called from here" LF) [@result.cat] each
          ] if
        ] times
      ] if
    ] times
  ] [
    @processor.@result.@program move @program set
  ] if
] "process" exportFunction

{
  processor: Processor Ref;
  signature: CFunctionSignature Cref;
  compilerPositionInfo: CompilerPositionInfo Cref;
  refToVar: RefToVar Cref;
} () {} [
  processor:;
  forcedSignature:;
  compilerPositionInfo:;
  refToVar:;

  @processor addBlock
  codeNode: @processor.@blocks.last.get;
  block: @codeNode;
  overload failProc: processor block FailProcForProcessor;

  NodeCaseDtor @codeNode.@nodeCase set
  0 dynamic @codeNode.@parent set
  @compilerPositionInfo @processor.@positions.last set

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
  dtorNameStringView compilerPositionInfo forcedSignature @processor @block finalizeCodeNode
] "createDtorForGlobalVar" exportFunction
