"astNodeType" module

"Array"     includeModule
"HashTable" includeModule
"String"    includeModule
"Variant"   includeModule

AstNodeType: {
  Empty:           [ 0 static] func;
  Label:           [ 1 static] func;
  Code:            [ 2 static] func;
  Object:          [ 3 static] func;
  List:            [ 4 static] func;
  Name:            [ 5 static] func;
  NameRead:        [ 6 static] func;
  NameWrite:       [ 7 static] func;
  NameMember:      [ 8 static] func;
  NameReadMember:  [ 9 static] func;
  NameWriteMember: [10 static] func;
  String:          [11 static] func;
  Numberi8:        [12 static] func;
  Numberi16:       [13 static] func;
  Numberi32:       [14 static] func;
  Numberi64:       [15 static] func;
  Numberix:        [16 static] func;
  Numbern8:        [17 static] func;
  Numbern16:       [18 static] func;
  Numbern32:       [19 static] func;
  Numbern64:       [20 static] func;
  Numbernx:        [21 static] func;
  Real32:          [22 static] func;
  Real64:          [23 static] func;
};

#AST Nodes
IndexArray: [Int32 Array] func;

NamedRecursiveBranch:[{
  children: IndexArray; # Array of Index
  name: String; # dynamic String
  nameInfo: 0 dynamic; #index in NameInfo pool
}] func;

NamedBranch: [{
  name: String; # dynamic String
  nameInfo: 0 dynamic; #index in NameInfo pool
}] func;

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
}] func;

makePositionInfo: [{
  column: copy;
  line: copy;
  offset: copy;
}] func;

PositionInfo: [-1 dynamic 1 dynamic 0 dynamic makePositionInfo] func;

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
}] func;

ParserResults: [ParserResult Array] func;

MultiParserResult: [{
  names: String Int32 HashTable;
  memory: AstNode Array;
  nodes: IndexArray Array; # order of going is not defined before compiling

  INIT: []; DIE: []; # default life control, and ban uneffective copy, because object is too big
}] func;
