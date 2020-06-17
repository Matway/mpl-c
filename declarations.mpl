"String.String" use
"String.StringView" use
"String.makeStringView" use
"String.toString" use
"control" use

"Block.Block" use
"Block.CFunctionSignature" use
"Block.CompilerPositionInfo" use
"Block.NodeCaseCode" use
"File.File" use
"Var.RefToVar" use
"Var.Variable" use
"astNodeType.AstNode" use
"astNodeType.IndexArray" use
"processor.Processor" use
"processor.RefToVarTable" use

{
  processor: Processor Ref;
  block: Block Cref;
  message: StringView Cref;
} () {} "compilerErrorImpl" importFunction

compilerError: [processor: block:;; makeStringView block @processor compilerErrorImpl];

{
  processor: Processor Ref;

  signature: CFunctionSignature Cref;
  compilerPositionInfo: CompilerPositionInfo Cref;
  file: File Cref;
  indexArray: IndexArray Cref;
  nodeCase: NodeCaseCode;
  parentIndex: 0;
  functionName: StringView Cref;
} 0 {} "astNodeToCodeNode" importFunction

{
  processor: Processor Ref;

  signature: CFunctionSignature Cref;
  compilerPositionInfo: CompilerPositionInfo Cref;
  refToVar: RefToVar Cref;
} () {} "createDtorForGlobalVar" importFunction

{
  block: Block Ref;
  processor: Processor Ref;

  positionInfo: CompilerPositionInfo Cref;
  name: StringView Cref;
  nodeCase: NodeCaseCode;
  indexArray: IndexArray Cref;
} () {} "processCallByIndexArray" importFunction

{
  block: Block Ref;
  processor: Processor Ref;

  index: Int32;
} () {} "callBuiltin" importFunction

{
  block: Block Ref;
  processor: Processor Ref;

  refToVar: RefToVar Cref;
} () {} "processFuncPtr" importFunction

{
  block: Block Ref;
  processor: Processor Ref;

  file: File Cref;
  preAstNodeIndex: Int32;
} Cond {} "processPre" importFunction

{
  block: Block Ref;
  processor: Processor Ref;

  name: StringView Cref;
  file: File Cref;
  callAstNodeIndex: Int32;
} () {} "processCall" importFunction

{
  block: Block Ref;
  processor: Processor Ref;
} () {} "defaultCall" importFunction

{
  block: Block Ref;
  processor: Processor Ref;

  asCodeRef: Cond;
  name: StringView Cref;
  signature: CFunctionSignature Cref;
} Natx {} "processImportFunction" importFunction

{
  block: Block Ref;
  processor: Processor Ref;

  asLambda: Cond;
  name: StringView Cref;
  file: File Cref;
  astNode: AstNode Cref;
  signature: CFunctionSignature Cref;
} Int32 {} "processExportFunction" importFunction

{
  processor: Processor Cref;
  currentMatchingNode: Block Cref;
  comparingMessage: String Ref;
  checkConstness: Cond;
  cacheEntry: RefToVar Cref;
  stackEntry: RefToVar Cref;
} Cond {} "compareOnePair" importFunction

{
  block: Block Cref;
  processor: Processor Ref;

  refToVar: RefToVar Ref;
} () {} "makeVariableType" importFunction

{
  block: Block Ref;
  processor: Processor Ref;

  forMatching: Cond;
  result: RefToVar Ref;
} () {} "popWith" importFunction

{
  block: Block Ref;
  entry: RefToVar Cref;
} () {} "push" importFunction

{
  block: Block Ref;
  processor: Processor Ref;

  dynamicStoraged: Cond;
  reason: Int32;
  refToVar: RefToVar Cref;
  result: RefToVar Ref;
} () {} "makeShadowsWith" importFunction

makeShadows: [
  processor: block:;;
  FALSE @processor @block makeShadowsWith
];

makeShadowsDynamic: [
  processor: block:;;
  TRUE @processor @block makeShadowsWith
];

{
  block: Block Cref;
  processor: Processor Ref;

  refToVar: RefToVar Cref;
} Int32 {} "generateDebugTypeId" importFunction

{
  block: Block Cref;
  processor: Processor Ref;

  refToVar: RefToVar Cref;
} Int32 {} "generateIrTypeId" importFunction

{
  block: Block Cref;
  processor: Processor Cref;

  resultMPL: String Ref;
  refToVar: RefToVar Cref;
} () {}  "getMplTypeImpl" importFunction

getMplType: [
  processor: block: ;;
  result: String;
  @result @processor block getMplTypeImpl
  @result
];

{
  block: Block Cref;
  processor: Processor Cref;
} () {} "defaultPrintStack" importFunction

{
  block: Block Cref;
  processor: Processor Cref;
} () {} "defaultPrintStackTrace" importFunction

{
  block: Block Ref;
  processor: Processor Ref;
  createOperation: Cond;
  mutable: Cond;
  refToVar: RefToVar Cref;
  result: RefToVar Ref;
} () {} "createRefWithImpl" importFunction

createRefWith: [
  refToVar: mutable: createOperation: processor: block: ;;;;;
  result: RefToVar;

  @result refToVar mutable createOperation @processor @block createRefWithImpl
  @result
];

{
  block: Block Ref;
  processor: Processor Ref;
  refToVar: RefToVar Cref;
} () {} "callInit" importFunction

{
  block: Block Ref;
  processor: Processor Ref;
  refToDst: RefToVar Cref;
  refToSrc: RefToVar Cref;
} () {} "callAssign" importFunction

{
  block: Block Ref;
  processor: Processor Ref;
  refToVar: RefToVar Cref;
} () {} "callDie" importFunction

{
  block: Block Ref;
  processor: Processor Ref;
  refToDst: RefToVar Cref;
  refToSrc: RefToVar Cref;
} () {} "setVar" importFunction

TryImplicitLambdaCastResult: [{
  success: FALSE dynamic;
  refToVar: RefToVar;
}];

{
  block: Block Ref;
  processor: Processor Ref;
  refToDst: RefToVar Ref;
  refToSrc: RefToVar Ref;
  result: TryImplicitLambdaCastResult Ref;
} () {} "tryImplicitLambdaCastImpl" importFunction

tryImplicitLambdaCast: [
  refToSrc: refToDst: processor: block: ;;;;
  result: TryImplicitLambdaCastResult;

  @result @refToSrc @refToDst @processor @block tryImplicitLambdaCastImpl
  @result
];

CopyVarFlags: {
  TO_NEW:     [1n8 dynamic];
  FROM_CHILD: [2n8 dynamic];
  FROM_TYPE:  [4n8 dynamic];
};

{
  block: Block Ref;
  processor: Processor Ref;
  flags: Nat8;
  refToVar: RefToVar Cref;
  result: RefToVar Ref;
} () {} "copyVarImpl" importFunction

copyVarWith: [
  refToVar: flags: processor: block: ;;;;

  result: RefToVar;
  @result refToVar flags @processor @block copyVarImpl
  @result
];

copyVar:               [processor: block:;; 0n8 @processor @block copyVarWith]; #fromchild is static arg
copyVarFromChild:      [processor: block:;; CopyVarFlags.FROM_CHILD @processor @block copyVarWith];
copyVarToNew:          [processor: block:;; CopyVarFlags.TO_NEW     @processor @block copyVarWith];
copyVarFromType:       [processor: block:;; CopyVarFlags.FROM_TYPE  @processor @block copyVarWith];

{
  block: Block Ref;
  processor: Processor Ref;

  flags: Nat8;
  refToVar: RefToVar Cref;
  result: RefToVar Ref;
} () {} "copyOneVarWithImpl" importFunction

copyOneVarWith: [
  src: flags: processor: block: ;;;;

  result: RefToVar;
  @result src flags @processor @block copyOneVarWithImpl
  @result
];

copyOneVar: [processor: block:;; 0n8 @processor @block copyOneVarWith];
copyOneVarFromType: [processor: block:;; CopyVarFlags.FROM_TYPE @processor @block copyOneVarWith];

{
  block: Block Ref;
  processor: Processor Ref;
  refToDst: RefToVar Ref;
  refToSrc: RefToVar Ref;
} () {} "createCopyToExists" importFunction

{
  block: Block Ref;
  processor: Processor Ref;
  string: String Ref;
  result: RefToVar Ref;
} () {} "makeVarStringImpl" importFunction

makeVarString: [
  text: processor: block: ;;;

  string: text toString;
  result: RefToVar;
  @result @string @processor @block makeVarStringImpl
  @result
];

{
  block: Block Ref;
  processor: Processor Ref;
} () {} "addDebugLocationForLastInstruction" importFunction


{
  block: Block Ref;
  processor: Processor Ref;
  message: String Ref;
} () {} "createFailWithMessageImpl" importFunction

createFailWithMessage: [
  text: processor: block: ;;;
  string: text String same [@text] [text toString] uif;
  @string @processor @block createFailWithMessageImpl
];
