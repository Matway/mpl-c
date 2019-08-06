"astOptimizers" module
"control" useModule

optimizeLabelsInCurrentNode: [
  node:;

  addDataToProcess: [
    copy isLabel:; recData:;
    isLabel @needToSwap.pushBack
    IndexArray @processedNodes.pushBack
    @recData AsRef @unfinishedNodes.pushBack
    0 @unfinishedIndexes.pushBack
  ];

  node.data.getTag AstNodeType.Label = [
    AstNodeType.Label @node.@data.get.@children TRUE addDataToProcess
  ] [
    node.data.getTag AstNodeType.Code = [
      AstNodeType.Code @node.@data.get FALSE addDataToProcess
    ] [
      node.data.getTag AstNodeType.Object = [
        AstNodeType.Object @node.@data.get FALSE addDataToProcess
      ] [
        node.data.getTag AstNodeType.List = [
          AstNodeType.List @node.@data.get FALSE addDataToProcess
        ] [
          # do nothing
        ] if
      ] if
    ] if
  ] if
];

optimizeLabels: [
  parserResult:;
  unfinishedNodes: IndexArray AsRef Array;
  processedNodes: IndexArray Array;
  unfinishedIndexes: Int32 Array;
  needToSwap: Cond Array;

  FALSE @needToSwap.pushBack
  IndexArray @processedNodes.pushBack
  @parserResult.@nodes AsRef @unfinishedNodes.pushBack
  0 dynamic @unfinishedIndexes.pushBack

  [
    uSize: unfinishedIndexes.dataSize 1 -;
    index: uSize unfinishedIndexes.at copy;
    nodes: @unfinishedNodes.last.data;

    index nodes.dataSize < [
      nodeIndex: index @nodes.at copy;
      nodeIndex @processedNodes.last.pushBack
      nodeIndex @parserResult.@memory.at optimizeLabelsInCurrentNode

      indexAfter: uSize @unfinishedIndexes.at;
      indexAfter 1 + @indexAfter set
      TRUE
    ] [
      needToSwap.last [
        sz: processedNodes.dataSize copy;
        src: sz 1 - @processedNodes.at;
        dst: sz 2 - @processedNodes.at;
        ll: dst.last copy;
        @dst.popBack
        src.dataSize [
          i src.at @dst.pushBack
        ] times
        ll @dst.pushBack
        @src.clear
      ] when

      lastUnfinished: @unfinishedNodes.last.@data;
      processedNodes.last @lastUnfinished set

      @needToSwap.popBack
      @processedNodes.popBack
      @unfinishedIndexes.popBack
      @unfinishedNodes.popBack

      unfinishedNodes.getSize 0 >
    ] if
  ] loop
];

optimizeNamesInCurrentNode: [
  node:;

  optimizeName: [
    nameWithInfo:;
    fr: nameWithInfo.name makeStringView ids.find;
    fr.success [
      fr.value @nameWithInfo.@nameInfo set
    ] [
      ids.dataSize @nameWithInfo.@nameInfo set
      nameWithInfo.name ids.dataSize @ids.insert # copy string here
    ] if
  ];

  addToProcess: [
    data:;
    @data AsRef @unfinishedNodes.pushBack
    0 @unfinishedIndexes.pushBack
  ];

  node.data.getTag AstNodeType.Name < [
    node.data.getTag AstNodeType.Label = [
      AstNodeType.Label @node.@data.get optimizeName # must not have children, it must be after label optimizing
    ] [
      node.data.getTag AstNodeType.Code = [
        AstNodeType.Code @node.@data.get addToProcess # must not have children, it must be after label optimizing
      ] [
        node.data.getTag AstNodeType.Object = [
          AstNodeType.Object @node.@data.get addToProcess # must not have children, it must be after label optimizing
        ] [
          node.data.getTag AstNodeType.List = [
            AstNodeType.List @node.@data.get addToProcess # must not have children, it must be after label optimizing
          ] [
            # ok
          ] if
        ] if
      ] if
    ] if
  ] [
    node.data.getTag AstNodeType.Name = [
      AstNodeType.Name @node.@data.get optimizeName
    ] [
      node.data.getTag AstNodeType.NameRead = [
        AstNodeType.NameRead @node.@data.get optimizeName
      ] [
        node.data.getTag AstNodeType.NameWrite = [
          AstNodeType.NameWrite @node.@data.get optimizeName
        ] [
          node.data.getTag AstNodeType.NameMember = [
            AstNodeType.NameMember @node.@data.get optimizeName
          ] [
            node.data.getTag AstNodeType.NameReadMember = [
              AstNodeType.NameReadMember @node.@data.get optimizeName
            ] [
              node.data.getTag AstNodeType.NameWriteMember = [
                AstNodeType.NameWriteMember @node.@data.get optimizeName
              ] [
                # ok
              ] if
            ] if
          ] if
        ] if
      ] if
    ] if
  ] if
];

optimizeNames: [
  multiParserResult:;
  ids: @multiParserResult.@names;

  i: 0 dynamic;
  [
    i multiParserResult.nodes.dataSize < [
      currentNodesArray: i @multiParserResult.@nodes.at;

      unfinishedNodes: IndexArray AsRef Array;
      unfinishedIndexes: Int32 Array;
      @currentNodesArray AsRef @unfinishedNodes.pushBack
      0 dynamic @unfinishedIndexes.pushBack

      [
        uSize: unfinishedIndexes.dataSize 1 -;
        index: uSize unfinishedIndexes.at copy;
        nodes: unfinishedNodes.last.data;

        index nodes.dataSize < [
          index nodes.at @multiParserResult.@memory.at optimizeNamesInCurrentNode # reallocation here

          indexAfter: uSize @unfinishedIndexes.at;
          indexAfter 1 + @indexAfter set
          TRUE
        ] [
          @unfinishedIndexes.popBack
          @unfinishedNodes.popBack

          unfinishedNodes.getSize 0 >
        ] if
      ] loop

      i 1 + @i set TRUE
    ] &&
  ] loop
];

concatParserResults: [
  mresult:;
  results:;
  p: 0;
  shift: 0;

  adjustArray: [
    indexArray:;
    @indexArray [
      cur: .@value;
      cur shift + @cur set
    ] each
  ];

  r: @results makeArrayRange;

  @results [
    current: .@value;
    @current.@nodes adjustArray
    @current.@memory [
      currentNode: .@value;
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

      @currentNode move @mresult.@memory.pushBack
    ] each

    @current.@nodes move @mresult.@nodes.pushBack

    shift current.memory.dataSize + @shift set
  ] each

];
