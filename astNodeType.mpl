# Copyright (C) 2021 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"Array" use
"HashTable" use
"Owner" use
"String" use
"Variant" use
"control" use

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
IndexOfArray: [Int32];

NamedRecursiveBranch:[{
  children: IndexOfArray; # Array of Index
  name: String; # dynamic String
  nameInfo: 0 dynamic; #index in NameInfo pool
}];

NamedBranch: [{
  name: String; # dynamic String
  nameInfo: 0 dynamic; #index in NameInfo pool
}];

makePositionInfo: [{
  token:       String;
  column:      new;
  line:        new;
  offsetStart: new;
  offsetEnd:   new;
  fileId:      new;
}];

PositionInfo: [-1 dynamic -1 dynamic -1 dynamic 1 dynamic 0 dynamic makePositionInfo];

AstNode: [{
  virtual AST_NODE: ();
  positionInfo: PositionInfo;
  data: (
    IndexOfArray         #CodeNode:
    NamedRecursiveBranch #LabelNode:
    IndexOfArray         #ListNode:
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
    IndexOfArray         #ObjectNode:
    Real64               #Real32Node:
    Real64               #Real64Node:
    String               #StringNode:
  ) Variant;

  INIT: []; DIE: []; # default life control, and ban uneffective copy, because object is too big
}];

AstNodeArray: [{
  positionInfo: PositionInfo;
  nodes: AstNode Array;
}];

ParserResult: [{
  virtual PARSER_RESULT: ();
  success: TRUE dynamic;
  errorInfo: {
    message: String;
    position: PositionInfo;
  };

  memory: AstNodeArray Array;
  root: IndexOfArray;

  INIT: []; DIE: []; # default life control, and ban uneffective copy, because object is too big
}];

ParserResults: [ParserResult Array];

MultiParserResult: [{
  memory: AstNodeArray Array;
  roots: IndexOfArray Array; # order of going is not defined before compiling

  INIT: []; DIE: []; # default life control, and ban uneffective copy, because object is too big
}];
