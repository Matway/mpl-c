"control" use

"Array.Array" use
"HashTable.HashTable" use
"String.String" use
"Variant.Variant" use

AstNodeType: {
  Code:            [ 0];
  Label:           [ 1];
  List:            [ 2];
  Name:            [ 3];
  NameMember:      [ 4];
  NameRead:        [ 5];
  NameReadMember:  [ 6];
  NameWrite:       [ 7];
  NameWriteMember: [ 8];
  Numberi16:       [ 9];
  Numberi32:       [10];
  Numberi64:       [11];
  Numberi8:        [12];
  Numberix:        [13];
  Numbern16:       [14];
  Numbern32:       [15];
  Numbern64:       [16];
  Numbern8:        [17];
  Numbernx:        [18];
  Object:          [19];
  Real32:          [20];
  Real64:          [21];
  String:          [22];
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
  data: (
    IndexArray           #CodeNode:
    NamedRecursiveBranch #LabelNode:
    IndexArray           #ListNode:
    NamedBranch          #NameNode:
    NamedBranch          #NameMemberNode:
    NamedBranch          #NameReadNode:
    NamedBranch          #NameReadMemberNode:
    NamedBranch          #NameWriteNode:
    NamedBranch          #NameWriteMemberNode:
    Int64                #Numberi16Node:
    Int64                #Numberi32Node:
    Int64                #Numberi64Node:
    Int64                #Numberi8Node:
    Int64                #NumberixNode:
    Nat64                #Numbern16Node:
    Nat64                #Numbern32Node:
    Nat64                #Numbern64Node:
    Nat64                #Numbern8Node:
    Nat64                #NumbernxNode:
    IndexArray           #ObjectNode:
    Real64               #Real32Node:
    Real64               #Real64Node:
    String               #StringNode:
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
  memory: AstNode Array;
  nodes: IndexArray Array; # order of going is not defined before compiling

  INIT: []; DIE: []; # default life control, and ban uneffective copy, because object is too big
}];
