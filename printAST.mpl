"printAST" module
"control" useModule

printLabelNode: [
  cref data:;
  ("; Label:" data.name "; id:" data.nameInfo) printList
  data.children cref @unfinishedNodes.pushBack
  0n32 @unfinishedIndexes.pushBack
];

printCodeNode: [
  cref data:;
  ("; Code:") printList
  data deref cref @unfinishedNodes.pushBack
  0n32 @unfinishedIndexes.pushBack
];

printObjectNode: [
  cref data:;
  ("; Object:") printList
  data deref cref @unfinishedNodes.pushBack
  0n32 @unfinishedIndexes.pushBack
];

printListNode: [
  cref data:;
  ("; List:") printList
  data deref cref @unfinishedNodes.pushBack
  0n32 @unfinishedIndexes.pushBack
];

printNameNode: [
  cref data:;
  ("; Name:" data.name "; id:" data.nameInfo) printList
];

printNameReadNode: [
  cref data:;
  ("; NameRead:" data.name "; id:" data.nameInfo) printList
];

printNameWriteNode: [
  cref data:;
  ("; NameWrite:" data.name "; id:" data.nameInfo) printList
];

printNameMemberNode: [
  cref data:;
  ("; NameMember:" data.name "; id:" data.nameInfo) printList
];

printNameReadMemberNode: [
  cref data:;
  ("; NameReadMember:" data.name "; id:" data.nameInfo) printList
];

printNameWriteMemberNode: [
  cref data:;
  ("; NameWriteMember:" data.name "; id:" data.nameInfo) printList
];

printStringNode: [
  cref data:;
  ("; String:" data deref) printList
];

printInt8Node: [
  cref data:;
  ("; Int8:" data deref) printList
];

printInt16Node: [
  cref data:;
  ("; Int16:" data deref) printList
];

printInt32Node: [
  cref data:;
  ("; Int32:" data deref) printList
];

printInt64Node: [
  cref data:;
  ("; Int64:" data deref) printList
];

printIntXNode: [
  cref data:;
  ("; IntX:" data deref) printList
];

printNat8Node: [
  cref data:;
  ("; Nat8:" data deref) printList
];

printNat16Node: [
  cref data:;
  ("; Nat16:" data deref) printList
];

printNat32Node: [
  cref data:;
  ("; Nat32:" data deref) printList
];

printNat64Node: [
  cref data:;
  ("; Nat64:" data deref) printList
];

printNatXNode: [
  cref data:;
  ("; NatX:" data deref) printList
];

printReal32Node: [
  cref data:;
  ("; Real32:" data deref) printList
];

printReal64Node: [
  cref data:;
  ("; Real64:" data deref) printList
];

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
];

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
];
