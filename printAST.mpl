"printAST" module
"control" useModule

printLabelNode: [
  cref data:;
  ("; Label:" data.name "; id:" data.nameInfo) printList
  data.children cref @unfinishedNodes.pushBack
  0n32 @unfinishedIndexes.pushBack
] func;

printCodeNode: [
  cref data:;
  ("; Code:") printList
  data deref cref @unfinishedNodes.pushBack
  0n32 @unfinishedIndexes.pushBack
] func;

printObjectNode: [
  cref data:;
  ("; Object:") printList
  data deref cref @unfinishedNodes.pushBack
  0n32 @unfinishedIndexes.pushBack
] func;

printListNode: [
  cref data:;
  ("; List:") printList
  data deref cref @unfinishedNodes.pushBack
  0n32 @unfinishedIndexes.pushBack
] func;

printNameNode: [
  cref data:;
  ("; Name:" data.name "; id:" data.nameInfo) printList
] func;

printNameReadNode: [
  cref data:;
  ("; NameRead:" data.name "; id:" data.nameInfo) printList
] func;

printNameWriteNode: [
  cref data:;
  ("; NameWrite:" data.name "; id:" data.nameInfo) printList
] func;

printNameMemberNode: [
  cref data:;
  ("; NameMember:" data.name "; id:" data.nameInfo) printList
] func;

printNameReadMemberNode: [
  cref data:;
  ("; NameReadMember:" data.name "; id:" data.nameInfo) printList
] func;

printNameWriteMemberNode: [
  cref data:;
  ("; NameWriteMember:" data.name "; id:" data.nameInfo) printList
] func;

printStringNode: [
  cref data:;
  ("; String:" data deref) printList
] func;

printInt8Node: [
  cref data:;
  ("; Int8:" data deref) printList
] func;

printInt16Node: [
  cref data:;
  ("; Int16:" data deref) printList
] func;

printInt32Node: [
  cref data:;
  ("; Int32:" data deref) printList
] func;

printInt64Node: [
  cref data:;
  ("; Int64:" data deref) printList
] func;

printIntXNode: [
  cref data:;
  ("; IntX:" data deref) printList
] func;

printNat8Node: [
  cref data:;
  ("; Nat8:" data deref) printList
] func;

printNat16Node: [
  cref data:;
  ("; Nat16:" data deref) printList
] func;

printNat32Node: [
  cref data:;
  ("; Nat32:" data deref) printList
] func;

printNat64Node: [
  cref data:;
  ("; Nat64:" data deref) printList
] func;

printNatXNode: [
  cref data:;
  ("; NatX:" data deref) printList
] func;

printReal32Node: [
  cref data:;
  ("; Real32:" data deref) printList
] func;

printReal64Node: [
  cref data:;
  ("; Real64:" data deref) printList
] func;

printCurrentNode: [
  cref node:;
  unfinishedNodes.dataSize 2n32 * [" " print] times
  ("offset:" node.offset "; coord:" node.line ":" node.column) printList
  node.data.getTag (
    AstNodeType.Label           [AstNodeType.Label node.data.get printLabelNode]
    AstNodeType.Code            [AstNodeType.Code node.data.get printCodeNode]
    AstNodeType.Object          [AstNodeType.Object node.data.get printObjectNode]
    AstNodeType.List            [AstNodeType.List node.data.get printListNode]
    AstNodeType.Name            [AstNodeType.Name node.data.get printNameNode]
    AstNodeType.NameRead        [AstNodeType.NameRead node.data.get printNameReadNode]
    AstNodeType.NameWrite       [AstNodeType.NameWrite node.data.get printNameWriteNode]
    AstNodeType.NameMember      [AstNodeType.NameMember node.data.get printNameMemberNode]
    AstNodeType.NameReadMember  [AstNodeType.NameReadMember node.data.get printNameReadMemberNode]
    AstNodeType.NameWriteMember [AstNodeType.NameWriteMember node.data.get printNameWriteMemberNode]
    AstNodeType.String          [AstNodeType.String node.data.get printStringNode]
    AstNodeType.Numberi8        [AstNodeType.Numberi8 node.data.get printInt8Node]
    AstNodeType.Numberi16       [AstNodeType.Numberi16 node.data.get printInt16Node]
    AstNodeType.Numberi32       [AstNodeType.Numberi32 node.data.get printInt32Node]
    AstNodeType.Numberi64       [AstNodeType.Numberi64 node.data.get printInt64Node]
    AstNodeType.Numberix        [AstNodeType.Numberix node.data.get printIntXNode]
    AstNodeType.Numbern8        [AstNodeType.Numbern8 node.data.get printNat8Node]
    AstNodeType.Numbern16       [AstNodeType.Numbern16 node.data.get printNat16Node]
    AstNodeType.Numbern32       [AstNodeType.Numbern32 node.data.get printNat32Node]
    AstNodeType.Numbern64       [AstNodeType.Numbern64 node.data.get printNat64Node]
    AstNodeType.Numbernx        [AstNodeType.Numbernx node.data.get printNatXNode]
    AstNodeType.Real32          [AstNodeType.Real32 node.data.get printReal32Node]
    AstNodeType.Real64          [AstNodeType.Real64 node.data.get printReal64Node]
    [[FALSE] "Unknown node type!" assert]
  ) case

  ("; token:" node.token) printList
  LF print
] func;

printAST: [
  ref parserResult:;
  unfinishedNodes: IndexArray cref Array;
  unfinishedIndexes: 0n32 unconst Array;
  parserResult.nodes cref @unfinishedNodes.pushBack
  0n32 @unfinishedIndexes.pushBack

  [
    uSize: unfinishedIndexes.dataSize 1n32 -;
    index: uSize unfinishedIndexes.at;
    nodes: unfinishedNodes.last deref;

    index nodes.dataSize < [
      index nodes.at parserResult.memory.at printCurrentNode # reallocation here
      indexAfterPrinting: uSize @unfinishedIndexes.at;
      indexAfterPrinting 1n32 + @indexAfterPrinting set
      TRUE
    ] [
      @unfinishedIndexes.popBack
      @unfinishedNodes.popBack

      unfinishedNodes.dataSize 0n32 >
    ] if
  ] loop
] func;
