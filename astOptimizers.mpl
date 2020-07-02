"Array" use
"Owner" use
"String" use
"control" use

"astNodeType" use

optimizeLabels: [
  parserResult:;

  @parserResult.@memory [
    currentIndexArray:;

    newIndexArray: AstNode Array;
    @currentIndexArray [
      current:;
      current.data.getTag AstNodeType.Label = [
        AstNodeType.Label current.data.get.children @parserResult.@memory.at [
          move @newIndexArray.pushBack
        ] each
      ] when

      @current move @newIndexArray.pushBack
    ] each

    @newIndexArray move @currentIndexArray set
  ] each
];

optimizeNamesInCurrentNode: [
  node:;

  optimizeName: [
    nameWithInfo:;
    nameIndex: nameWithInfo.name makeStringView @nameManager.createName;
    nameIndex @nameWithInfo.@nameInfo set
  ];

  (
    AstNodeType.Label           [optimizeName] # must not have children, it must be after label optimizing
    AstNodeType.Name            [optimizeName]
    AstNodeType.NameRead        [optimizeName]
    AstNodeType.NameWrite       [optimizeName]
    AstNodeType.NameMember      [optimizeName]
    AstNodeType.NameReadMember  [optimizeName]
    AstNodeType.NameWriteMember [optimizeName]
  ) @node.@data.visit
];

optimizeNames: [
  parserResult: nameManager: ;;

  @parserResult.@memory [
    [
      optimizeNamesInCurrentNode
    ] each
  ] each
];

concatParserResult: [
  mresult:;
  current:;
  shift: mresult.memory.getSize;
  fileId: mresult.roots.getSize;

  adjustArray: [
    astArrayIndex:;
    astArrayIndex shift + @astArrayIndex set
  ];

  @current.@root adjustArray

  @current.@memory [
    currentArray:;
    @currentArray [
      currentNode:;
      fileId @currentNode.@fileId set

      currentNode.data.getTag AstNodeType.Code = [
        AstNodeType.Code @currentNode.@data.get adjustArray
      ] [
        currentNode.data.getTag AstNodeType.List = [
          AstNodeType.List @currentNode.@data.get adjustArray
        ] [
          currentNode.data.getTag AstNodeType.Object = [
            AstNodeType.Object @currentNode.@data.get adjustArray
          ] when
        ] if
      ] if
    ] each

    @currentArray move @mresult.@memory.pushBack
  ] each

  current.root @mresult.@roots.pushBack
];
