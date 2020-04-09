"Array"     includeModule
"HashTable" includeModule
"String"    includeModule
"Variant"   includeModule

AstNodeType: {
  Empty:           [ 0 static];
  Label:           [ 1 static];
  Code:            [ 2 static];
  Object:          [ 3 static];
  List:            [ 4 static];
  Name:            [ 5 static];
  NameRead:        [ 6 static];
  NameWrite:       [ 7 static];
  NameMember:      [ 8 static];
  NameReadMember:  [ 9 static];
  NameWriteMember: [10 static];
  String:          [11 static];
  Numberi8:        [12 static];
  Numberi16:       [13 static];
  Numberi32:       [14 static];
  Numberi64:       [15 static];
  Numberix:        [16 static];
  Numbern8:        [17 static];
  Numbern16:       [18 static];
  Numbern32:       [19 static];
  Numbern64:       [20 static];
  Numbernx:        [21 static];
  Real32:          [22 static];
  Real64:          [23 static];
};

#AST Nodes
IndexArray: [Int32 Array];

NamedRecursiveBranch:[{
  children: IndexArray; # Array of Index
  name: String; # dynamic String
  nameInfo: 0 dynamic; #index in NameInfo pool
}];

NamedBranch: [{
  name: String; # dynamic String
  nameInfo: 0 dynamic; #index in NameInfo pool
}];

AstNode: [{
  virtual AST_NODE: ();
  token:     String;
  column:    -1 dynamic;
  line:      -1 dynamic;
  offset:    -1 dynamic;
  fileNumber: 0 dynamic;
  data: (
    Cond                 #EmptyNode:
    NamedRecursiveBranch #LabelNode:
    IndexArray           #CodeNode:
    IndexArray           #ObjectNode:
    IndexArray           #ListNode:
    NamedBranch          #NameNode:
    NamedBranch          #NameReadNode:
    NamedBranch          #NameWriteNode:
    NamedBranch          #NameMemberNode:
    NamedBranch          #NameReadMemberNode:
    NamedBranch          #NameWriteMemberNode:
    String               #StringNode:
    Int64                #Numberi8Node:
    Int64                #Numberi16Node:
    Int64                #Numberi32Node:
    Int64                #Numberi64Node:
    Int64                #NumberixNode:
    Nat64                #Numbern8Node:
    Nat64                #Numbern16Node:
    Nat64                #Numbern32Node:
    Nat64                #Numbern64Node:
    Nat64                #NumbernxNode:
    Real64               #Real32Node:
    Real64               #Real64Node:
  ) Variant;

  INIT: []; DIE: []; # default life control, and ban uneffective copy, because object is too big
}];

makePositionInfo: [{
  column: copy;
  line: copy;
  offset: copy;
}];

PositionInfo: [-1 dynamic 1 dynamic 0 dynamic makePositionInfo];

ParserResult: [{
  virtual PARSER_RESULT: ();
  success: TRUE dynamic;
  errorInfo: {
    message: String;
    position: PositionInfo;
  };
  memory: AstNode Array;
  nodes: IndexArray;

  INIT: []; DIE: []; # default life control, and ban uneffective copy, because object is too big
}];

ParserResults: [ParserResult Array];

MultiParserResult: [{
  names: String Int32 HashTable;
  memory: AstNode Array;
  nodes: IndexArray Array; # order of going is not defined before compiling

  INIT: []; DIE: []; # default life control, and ban uneffective copy, because object is too big
}];
