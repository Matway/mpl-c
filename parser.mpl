"parser" module
"control" includeModule
"String" includeModule
"astNodeType" includeModule

fillPositionInfo: [
  astNode:;
  lastPosition.offset @astNode.@offset set
  lastPosition.line @astNode.@line set
  lastPosition.column @astNode.@column set
  currentFileNumber @astNode.@fileNumber set
];

makeLabelNode: [
  children:;
  name:;
  result: AstNode;
  @result fillPositionInfo
  (name ":") assembleString @result.@token set
  AstNodeType.Label @result.@data.setTag
  branch: AstNodeType.Label @result.@data.get;
  children @branch.@children set
  name @branch.@name set
  @result
];

makeCodeNode: [
  children:;
  result: AstNode;
  @result fillPositionInfo
  "[" toString @result.@token set
  AstNodeType.Code @result.@data.setTag
  branch: AstNodeType.Code @result.@data.get;
  children @branch set
  @result
];

makeObjectNode: [
  children:;
  result: AstNode;
  @result fillPositionInfo
  "{" toString @result.@token set
  AstNodeType.Object @result.@data.setTag
  branch: AstNodeType.Object @result.@data.get;
  children @branch set
  @result
];

makeListNode: [
  children:;
  result: AstNode;
  @result fillPositionInfo
  "(" toString @result.@token set
  AstNodeType.List @result.@data.setTag
  branch: AstNodeType.List @result.@data.get;
  children @branch set
  @result
];

makeNameNode: [
  name:;
  result: AstNode;
  @result fillPositionInfo
  name toString @result.@token set
  AstNodeType.Name @result.@data.setTag
  branch: AstNodeType.Name @result.@data.get;
  name toString @branch.@name set
  @result
];

makeNameReadNode: [
  name:;
  result: AstNode;
  @result fillPositionInfo
  ("@" name) assembleString @result.@token set
  AstNodeType.NameRead @result.@data.setTag
  branch: AstNodeType.NameRead @result.@data.get;
  name toString @branch.@name set
  @result
];

makeNameWriteNode: [
  name:;
  result: AstNode;
  @result fillPositionInfo
  ("!" name) assembleString @result.@token set
  AstNodeType.NameWrite @result.@data.setTag
  branch: AstNodeType.NameWrite @result.@data.get;
  name toString @branch.@name set
  @result
];

makeNameMemberNode: [
  name:;
  result: AstNode;
  @result fillPositionInfo
  ("." name) assembleString @result.@token set
  AstNodeType.NameMember @result.@data.setTag
  branch: AstNodeType.NameMember @result.@data.get;
  name toString @branch.@name set
  @result
];

makeNameReadMemberNode: [
  name:;
  result: AstNode;
  @result fillPositionInfo
  (".@" name) assembleString @result.@token set
  AstNodeType.NameReadMember @result.@data.setTag
  branch: AstNodeType.NameReadMember @result.@data.get;
  name toString @branch.@name set
  @result
];

makeNameWriteMemberNode: [
  name:;
  result: AstNode;
  @result fillPositionInfo
  (".!" name) assembleString @result.@token set
  AstNodeType.NameWriteMember @result.@data.setTag
  branch: AstNodeType.NameWriteMember @result.@data.get;
  name toString @branch.@name set
  @result
];

makeStringNode: [
  value:;
  result: AstNode;
  @result fillPositionInfo
  "TEXT" toString @result.@token set
  AstNodeType.String @result.@data.setTag
  branch: AstNodeType.String @result.@data.get;
  value @branch set
  @result
];

makeNumberi8Node: [
  token:;
  copy number:;
  result: AstNode;
  @result fillPositionInfo
  token @result.@token set
  AstNodeType.Numberi8 @result.@data.setTag
  branch: AstNodeType.Numberi8 @result.@data.get;
  number @branch set
  @result
];

makeNumberi16Node: [
  token:;
  copy number:;
  result: AstNode;
  @result fillPositionInfo
  token @result.@token set
  AstNodeType.Numberi16 @result.@data.setTag
  branch: AstNodeType.Numberi16 @result.@data.get;
  number @branch set
  @result
];

makeNumberi32Node: [
  token:;
  copy number:;
  result: AstNode;
  @result fillPositionInfo
  token @result.@token set
  AstNodeType.Numberi32 @result.@data.setTag
  branch: AstNodeType.Numberi32 @result.@data.get;
  number @branch set
  @result
];

makeNumberi64Node: [
  token:;
  copy number:;
  result: AstNode;
  @result fillPositionInfo
  token @result.@token set
  AstNodeType.Numberi64 @result.@data.setTag
  branch: AstNodeType.Numberi64 @result.@data.get;
  number @branch set
  @result
];

makeNumberixNode: [
  token:;
  copy number:;
  result: AstNode;
  @result fillPositionInfo
  token @result.@token set
  AstNodeType.Numberix @result.@data.setTag
  branch: AstNodeType.Numberix @result.@data.get;
  number @branch set
  @result
];

makeNumbern8Node: [
  token:;
  copy number:;
  result: AstNode;
  @result fillPositionInfo
  token @result.@token set
  AstNodeType.Numbern8 @result.@data.setTag
  branch: AstNodeType.Numbern8 @result.@data.get;
  number @branch set
  @result
];

makeNumbern16Node: [
  token:;
  copy number:;
  result: AstNode;
  @result fillPositionInfo
  token @result.@token set
  AstNodeType.Numbern16 @result.@data.setTag
  branch: AstNodeType.Numbern16 @result.@data.get;
  number @branch set
  @result
];

makeNumbern32Node: [
  token:;
  copy number:;
  result: AstNode;
  @result fillPositionInfo
  token @result.@token set
  AstNodeType.Numbern32 @result.@data.setTag
  branch: AstNodeType.Numbern32 @result.@data.get;
  number @branch set
  @result
];

makeNumbern64Node: [
  token:;
  copy number:;
  result: AstNode;
  @result fillPositionInfo
  token @result.@token set
  AstNodeType.Numbern64 @result.@data.setTag
  branch: AstNodeType.Numbern64 @result.@data.get;
  number @branch set
  @result
];

makeNumbernxNode: [
  token:;
  copy number:;
  result: AstNode;
  @result fillPositionInfo
  token @result.@token set
  AstNodeType.Numbernx @result.@data.setTag
  branch: AstNodeType.Numbernx @result.@data.get;
  number @branch set
  @result
];

makeReal32Node: [
  token:;
  copy number:;
  result: AstNode;
  @result fillPositionInfo
  token @result.@token set
  AstNodeType.Real32 @result.@data.setTag
  branch: AstNodeType.Real32 @result.@data.get;
  number @branch set
  @result
];

makeReal64Node: [
  token:;
  copy number:;
  result: AstNode;
  @result fillPositionInfo
  token @result.@token set
  AstNodeType.Real64 @result.@data.setTag
  branch: AstNodeType.Real64 @result.@data.get;
  number @branch set
  @result
];

makeParserConstants: [{
  eof:        [  0n32];

  cr:         [ 13n32];
  lf:         [ 10n32];
  space:      [ 32n32];
  exclamation:[ 33n32];
  quote:      [ 34n32];
  grid:       [ 35n32];
  openRBr:    [ 40n32];
  closeRBr:   [ 41n32];
  openSBr:    [ 91n32];
  closeSBr:   [ 93n32];
  openFBr:    [123n32];
  closeFBr:   [125n32];
  plus:       [ 43n32];
  comma:      [ 44n32];
  minus:      [ 45n32];
  dot:        [ 46n32];
  zero:       [ 48n32];
  colon:      [ 58n32];
  semicolon:  [ 59n32];
  dog:        [ 64n32];
  backSlash:  [ 92n32];
  # it is for numbers
  aCode:      [ 97n32];
  aCodeBig:   [ 65n32];
  eCode:      [101n32];
  eCodeBig:   [ 69n32];
  iCode:      [105n32];
  nCode:      [110n32];
  rCode:      [114n32];
  xCode:      [120n32];

  makeLookupTable: [
    av:;
    result: Cond Array;
    256 @result.resize
    @result [.@value p:; FALSE @p set] each
    av [
      v: .value;
      TRUE v 0 cast @result.at set
    ] each

    result
  ];

  joinLookupTables: [
    right:;
    left:;
    result: Cond Array;
    256 @result.resize

    @result [
      pair:;
      i: pair.index copy;
      i left.at i right.at or @pair.@value set
    ] each

    result
  ];

  starters: (openRBr openSBr openFBr) makeLookupTable;
  terminators: (eof closeRBr closeSBr closeFBr semicolon) makeLookupTable;
  digits: (zero zero 1n32 + zero 2n32 + zero 3n32 + zero 4n32 + zero 5n32 + zero 6n32 + zero 7n32 + zero 8n32 + zero 9n32 +) makeLookupTable;
  numberSigns: (plus minus) makeLookupTable;
  specials: (space cr lf colon grid) makeLookupTable starters joinLookupTables terminators joinLookupTables;
  begExp: (eCode eCodeBig) makeLookupTable;
  endNumbers: specials (comma) makeLookupTable joinLookupTables;
  endNames: specials copy;

  hexDigits: (
    zero zero 1n32 + zero 2n32 + zero 3n32 + zero 4n32 + zero 5n32 + zero 6n32 + zero 7n32 + zero 8n32 + zero 9n32 +
    aCode aCode 1n32 + aCode 2n32 + aCode 3n32 + aCode 4n32 + aCode 5n32 +
    aCodeBig aCodeBig 1n32 + aCodeBig 2n32 + aCodeBig 3n32 + aCodeBig 4n32 + aCodeBig 5n32 +
  ) makeLookupTable;

  hexToInt: [
    result: Nat32 Array;
    256 @result.resize

    10n32 [i 0n32 cast zero 0 cast i + @result.at set] times
    6n32  [i 10 + 0n32 cast aCode    0 cast i + @result.at set] times
    6n32  [i 10 + 0n32 cast aCodeBig 0 cast i + @result.at set] times
    result
  ] call;
}];

inArray: [
  where:;
  copy code:;
  code 256n32 < [code 0 cast where.at copy] &&
];

undo: [
  mainResult.success [
    prevPosition @currentPosition set
    currentPosition.offset 0 < not [
      currentPosition.offset splittedString.chars.at @currentSymbol set
      currentSymbol stringMemory Nat8 addressToReference Nat32 cast @currentCode set
    ] [
      StringView @currentSymbol set
      pc.eof @currentCode set
    ] if
  ] when
];

iterate: [
  mainResult.success [
    currentPosition @prevPosition set

    currentCode pc.lf = [
      0 dynamic @currentPosition.@column set
      currentPosition.line 1 + @currentPosition.@line set
    ] when

    currentPosition.offset 1 + @currentPosition.@offset set
    currentPosition.column 1 + @currentPosition.@column set

    currentPosition.offset splittedString.chars.getSize < [
      currentPosition.offset splittedString.chars.at @currentSymbol set
      currentSymbol stringMemory Nat8 addressToReference Nat32 cast @currentCode set
    ] [
      StringView @currentSymbol set
      pc.eof @currentCode set
    ] if
  ] when
];

lexicalError: [
  toString @mainResult.@errorInfo.@message set
  currentPosition @mainResult.@errorInfo.@position set
  FALSE @mainResult.@success set
];

parseStringConstant: [
  nameSymbols: StringView Array;
  slashed: FALSE dynamic;
  iterate

  [
    currentCode pc.backSlash = [
      slashed [
        currentSymbol @nameSymbols.pushBack
        FALSE @slashed set
      ] [
        TRUE @slashed set
      ] if
      TRUE
    ] [
      currentCode pc.quote = [
        slashed [
          currentSymbol @nameSymbols.pushBack
          TRUE
        ] [
          FALSE
        ] if
        FALSE @slashed set
      ] [
        currentCode pc.eof = [
          "unterminated string" lexicalError
          FALSE
        ] [
          currentSymbol @nameSymbols.pushBack
          FALSE @slashed set
          TRUE
        ] if
      ] if
    ] if

    iterate
  ] loop

  nameSymbols assembleString makeStringNode @mainResult.@memory.pushBack
  TRUE
];

tryParseNumberAfterSign: [
  currentCode pc.digits inArray [
    undo parseNumber
  ] [
    undo parseName
  ] if
];

dCheck: [currentCode pc.digits inArray not ["wrong number constant" lexicalError] when ];
xCheck: [
  currentCode pc.digits inArray not [
    currentCode pc.xCode = [
      -2 @currentArray.pushBack
      iterate
    ] [
      "wrong number constant" lexicalError
    ] if
  ] when
];

parseDecNumber: [
  copy hasMinus:;

  IntArray: [Int32 Array];
  beforeDot: IntArray;
  afterDot: IntArray;
  afterE: IntArray;
  afterT: IntArray;
  currentArray: @beforeDot;
  hasEMinus: FALSE;
  typeClass: 0 dynamic;
  stage: 0 dynamic;
  #0 before dot or else
  #1 after dot
  #2 after e
  #3 after n/r

  result: 0 dynamic;
  tokenBegin: currentPosition.offset hasMinus [1 -][copy] if;
  tokenEnd: tokenBegin copy;

  [
    currentCode pc.digits inArray [
      currentCode pc.zero - 0 cast @currentArray.pushBack
      iterate TRUE
    ] [
      currentCode pc.dot = [
        stage 0 = not [
          FALSE
        ] [
          1 @stage set
          iterate
          currentCode pc.digits inArray [
            @afterDot !currentArray
            2 @typeClass set
            TRUE
          ] [
            undo FALSE
          ] if
        ] if
      ] [
        currentCode pc.nCode = [
          stage 0 = not ["wrong number constant" lexicalError] when
          3 @stage set
          iterate TRUE
          @afterT !currentArray
          xCheck
          1 @typeClass set
        ] [
          currentCode pc.iCode = [
            stage 0 = not ["wrong number constant" lexicalError] when
            3 @stage set
            iterate TRUE
            @afterT !currentArray
            xCheck
          ] [
            currentCode pc.rCode = [
              stage 1 = stage 2 = or not ["wrong number constant" lexicalError] when
              3 @stage set
              iterate TRUE
              @afterT !currentArray
              dCheck
            ] [
              currentCode pc.begExp inArray [
                stage 1 = not ["wrong number constant" lexicalError] when
                iterate TRUE
                @afterE !currentArray
                currentCode pc.numberSigns inArray [
                  currentCode pc.minus = @hasEMinus set
                  iterate
                ] when
                dCheck
              ] [
                currentCode pc.endNumbers inArray [
                  FALSE
                ] [
                  "error in number constant" lexicalError
                  FALSE
                ] if
              ] if
            ] if
          ] if
        ] if
      ] if
    ] if

    p:;
    p [ currentPosition.offset @tokenEnd set ] when
    p mainResult.success and
  ] loop

  token: tokenBegin tokenEnd splittedString.chars makeSubRange assembleString;

  afterT.dataSize 2 > [ "error in number constant" lexicalError ] when

  typeName: 0 dynamic;
  afterT.dataSize [typeName 100 * i afterT.at + 1 + @typeName set] times


  typeClass 2 = [
    type: 0.0r64 dynamic;
    ten: 10.0r64 dynamic;
    result: 0.0r64 dynamic;
    beforeDot.dataSize [result 10.0r64 * i beforeDot.at type cast + @result set] times
    tenRcp: 0.1r64 dynamic;
    fracPartFactor: tenRcp copy;
    afterDot.dataSize [
      digit: i afterDot.at type cast;
      digit  fracPartFactor * result + @result set
      fracPartFactor tenRcp * @fracPartFactor set
    ] times

    decOrder: 0.0r64 dynamic;
    afterE.dataSize [decOrder 10.0r64 * i afterE.at type cast + @decOrder set] times
    hasEMinus [decOrder neg @decOrder set] when
    hasMinus [result neg @result set] when
    result 10.0r64 decOrder ^ * @result set

    typeName 705 = typeName 0 = or [
      result token makeReal64Node @mainResult.@memory.pushBack
    ] [
      typeName 403 = [
        result token makeReal32Node @mainResult.@memory.pushBack
      ] [
        "wrong real constant suffix" lexicalError
      ] if
    ] if
  ] [
    typeClass 1 = [
      hasMinus ["negative natural constants not allowed" lexicalError] when
      type: 0n64 dynamic;
      ten: 10n64 dynamic;
      result: 0n64 dynamic;
      beforeDot.dataSize [result 10n64 * i beforeDot.at 0i64 cast type cast + @result set] times
      typeName 705 = [
        result token makeNumbern64Node @mainResult.@memory.pushBack
      ] [
        typeName 403 = typeName 0 = or [
          result token makeNumbern32Node @mainResult.@memory.pushBack
        ] [
          typeName 207 = [
            result token makeNumbern16Node @mainResult.@memory.pushBack
          ] [
            typeName 9 = [
              result token makeNumbern8Node @mainResult.@memory.pushBack
            ] [
              typeName -1 = [
                result token makeNumbernxNode @mainResult.@memory.pushBack
              ] [
                "wrong natural constant suffix" lexicalError
              ] if
            ] if
          ] if
        ] if
      ] if
    ] [
      type: 0i64 dynamic;
      ten: 10i64 dynamic;
      result: 0i64 dynamic;
      beforeDot.dataSize [result 10i64 * i beforeDot.at type cast + @result set] times
      hasMinus [result neg @result set] when
      typeName 705 = [
        result token makeNumberi64Node @mainResult.@memory.pushBack
      ] [
        typeName 403 = typeName 0 = or [
          result token makeNumberi32Node @mainResult.@memory.pushBack
        ] [
          typeName 207 = [
            result token makeNumberi16Node @mainResult.@memory.pushBack
          ] [
            typeName 9 = [
              result token makeNumberi8Node @mainResult.@memory.pushBack
            ] [
              typeName -1 = [
                result token makeNumberixNode @mainResult.@memory.pushBack
              ] [
                "wrong integer constant suffix" lexicalError
              ] if
            ] if
          ] if
        ] if
      ] if
    ] if
  ] if

  mainResult.success copy
];

parseHexNumber: [
  copy hasMinus:;
  IntArray: [Int32 Array];
  beforeT: IntArray;
  afterT: IntArray;
  currentArray: @beforeT;
  typeClass: 0 dynamic;
  stage: 0 dynamic;
  #0 before n
  #1 after n

  result: 0 dynamic;
  tokenBegin: currentPosition.offset hasMinus [3 -][2 -] if;
  tokenEnd: tokenBegin copy;

  [
    currentCode pc.hexDigits inArray [
      currentCode 0 cast pc.hexToInt.at 0 cast @currentArray.pushBack
      iterate TRUE
    ] [
      currentCode pc.dot = [
        FALSE
      ] [
        currentCode pc.nCode = [
          stage 0 = not ["wrong number constant" lexicalError] when
          3 @stage set
          iterate TRUE
          @afterT !currentArray
          xCheck
          1 @typeClass set
        ] [
          currentCode pc.iCode = [
            stage 0 = not ["wrong number constant" lexicalError] when
            3 @stage set
            iterate TRUE
            @afterT !currentArray
            xCheck
          ] [
            currentCode pc.endNumbers inArray [
              FALSE
            ] [
              "error in number constant" lexicalError
              FALSE
            ] if
          ] if
        ] if
      ] if
    ] if

    p:;
    p [ currentPosition.offset @tokenEnd set ] when
    p mainResult.success and
  ] loop

  token: tokenBegin tokenEnd splittedString.chars makeSubRange assembleString;
  afterT.dataSize 2 > [ "error in number constant" lexicalError ] when

  typeName: 0 dynamic;
  afterT.dataSize [typeName 100 * i afterT.at + 1 + @typeName set] times
  hasMinus ["negative hex constants not allowed" lexicalError] when

  typeClass 1 = [
    type: 0n64;
    ten: 10n64;
    result: 0n64;
    beforeT.dataSize [result 16n64 * i beforeT.at 0i64 cast type cast + @result set] times
    typeName 705 = [
      result token makeNumbern64Node @mainResult.@memory.pushBack
    ] [
      typeName 403 = typeName 0 = or [
        result token makeNumbern32Node @mainResult.@memory.pushBack
      ] [
        typeName 207 = [
          result token makeNumbern16Node @mainResult.@memory.pushBack
        ] [
          typeName 9 = [
            result token makeNumbern8Node @mainResult.@memory.pushBack
          ] [
            typeName -1 = [
              result token makeNumbernxNode @mainResult.@memory.pushBack
            ] [
              "wrong natural constant suffix" lexicalError
            ] if
          ] if
        ] if
      ] if
    ] if
  ] [
    type: 0i64 dynamic;
    ten: 10i64 dynamic;
    result: 0i64 dynamic;
    beforeT.dataSize [result 16i64 * i beforeT.at type cast + @result set] times
    typeName 705 = [
      result token makeNumberi64Node @mainResult.@memory.pushBack
    ] [
      typeName 403 = typeName 0 = or [
        result token makeNumberi32Node @mainResult.@memory.pushBack
      ] [
        typeName 207 = [
          result token makeNumberi16Node @mainResult.@memory.pushBack
        ] [
          typeName 9 = [
            result token makeNumberi8Node @mainResult.@memory.pushBack
          ] [
            typeName -1 = [
              result token makeNumberixNode @mainResult.@memory.pushBack
            ] [
              "wrong integer constant suffix" lexicalError
            ] if
          ] if
        ] if
      ] if
    ] if
  ] if

  mainResult.success copy
];

parseNumber: [
  hasMinus: FALSE dynamic;
  currentCode pc.minus = [
    TRUE dynamic @hasMinus set
    iterate
  ] [
    currentCode pc.plus = [iterate] when
  ] if

  currentCode pc.zero = [
    iterate
    currentCode pc.xCode = [
      iterate hasMinus parseHexNumber
    ] [
      currentCode pc.iCode = currentCode pc.nCode = or currentCode pc.dot = or currentCode pc.endNumbers inArray or [
        undo hasMinus parseDecNumber
      ] [
        "lead zeros in number are not allowed" lexicalError
        FALSE
      ] if
    ] if
  ] [
    hasMinus parseDecNumber
  ] if
];

makeLabel: [
  name:;
  lastPosition @unfinishedPositions.pushBack
  pc.semicolon @unfinishedTerminators.pushBack
  name toString @unfinishedLabelNames.pushBack
  IndexArray @unfinishedNodes.pushBack
];

parseName: [
  member: FALSE dynamic;
  read: FALSE dynamic;
  write: FALSE dynamic;
  label: FALSE dynamic;
  checkOffset: currentPosition.offset copy;
  checkFirst: [currentPosition.offset checkOffset > ["invalid identifier" lexicalError] when];
  nameSymbols: StringView Array;
  first: TRUE dynamic;

  [
    first [currentCode pc.digits inArray] && [
      "idendifiers can't begin from number" lexicalError
      FALSE
    ] [
      currentCode pc.quote = [
        "quote cannot be part of identifier" lexicalError
        FALSE
      ] [
        currentCode pc.dot = [
          nameSymbols.dataSize 0 > [
            FALSE
          ] [
            checkFirst
            checkOffset 1 + @checkOffset set
            TRUE @member set
            iterate
            TRUE
          ] if
        ] [
          currentCode pc.dog = [
            checkFirst
            TRUE @read set
            iterate TRUE
          ] [
            currentCode pc.exclamation = [
              checkFirst
              TRUE @write set
              iterate TRUE
            ] [
              currentCode pc.comma = nameSymbols.dataSize 0 > and [
                FALSE
              ] [
                currentCode pc.endNames inArray [
                  currentCode pc.colon = [
                    TRUE @label set
                    iterate
                  ] when
                  FALSE
                ] [
                  nameSymbols.dataSize 1 > [0 nameSymbols.at "," =] && [
                    "identifier cannot start from comma" lexicalError
                  ] when
                  currentSymbol @nameSymbols.pushBack
                  iterate
                  FALSE @first set
                  TRUE
                ] if
              ] if
            ] if
          ] if
        ] if
      ] if
    ] if

    mainResult.success and
  ] loop

  mainResult.success [
    read write and ["wrong identifier" lexicalError] when

    nameSymbols.dataSize 0 = [
      member [
        read write or [undo "wrong identifier" lexicalError] when
        "." makeNameNode @mainResult.@memory.pushBack
        TRUE
      ] [
        read [
          label ["@" makeLabel FALSE]["@" makeNameNode @mainResult.@memory.pushBack TRUE] if
        ] [
          write [
            label ["!" makeLabel FALSE]["!" makeNameNode @mainResult.@memory.pushBack TRUE] if
          ] [
            "empty name" lexicalError
            FALSE
          ] if
        ] if
      ] if
    ] [
      name: nameSymbols assembleString;

      label [
        member read write or or ["label declaration must be without . @ ! modifiers" lexicalError] when
        name makeLabel FALSE
      ] [
        member [
          read [
            name makeNameReadMemberNode @mainResult.@memory.pushBack TRUE
          ] [
            write [
              name makeNameWriteMemberNode @mainResult.@memory.pushBack TRUE
            ] [
              name makeNameMemberNode @mainResult.@memory.pushBack TRUE
            ] if
          ] if
        ] [
          read [
            name makeNameReadNode @mainResult.@memory.pushBack TRUE
          ] [
            write [
              name makeNameWriteNode @mainResult.@memory.pushBack TRUE
            ] [
              name makeNameNode @mainResult.@memory.pushBack TRUE
            ] if
          ] if
        ] if
      ] if
    ] if
  ] [
    FALSE
  ] if
];

parseIdentifier: [
  compileOnce

  currentCode pc.quote = [
    parseStringConstant
  ] [
    currentCode pc.digits inArray [
      parseNumber
    ] [
      currentCode pc.numberSigns inArray [
        iterate tryParseNumberAfterSign
      ] [
        parseName
      ] if
    ] if
  ] if
];

parseComment: [
  [
    iterate
    currentCode pc.eof = currentCode pc.lf = or not
  ] loop
];

addNestedNode: [
  currentPosition @unfinishedPositions.pushBack

  IndexArray @unfinishedNodes.pushBack
  currentCode pc.openRBr = [
    pc.closeRBr @unfinishedTerminators.pushBack
  ] [
    currentCode pc.openFBr = [
      pc.closeFBr @unfinishedTerminators.pushBack
    ] [
      currentCode pc.openSBr = [
        pc.closeSBr @unfinishedTerminators.pushBack
      ] [
        "unknown starter for nested node" lexicalError
      ] if
    ] if
  ] if

  iterate
];

addToLastUnfinished: [
  @mainResult.@memory.pushBack
  mainResult.memory.dataSize 1 - @unfinishedNodes.last.pushBack
];

parseNode: [
  [
    currentCode pc.specials inArray [
      currentCode pc.space = [
        iterate
      ] [
        currentCode pc.starters inArray [
          addNestedNode
        ] [
          currentCode pc.terminators inArray [
            goodTerminator: unfinishedTerminators.last copy;
            lastPosition: unfinishedPositions.last;

            currentCode goodTerminator = not [
              ("wrong terminator of block started at (" lastPosition.line ":" lastPosition.column
                "), expected \"" goodTerminator pc.eof = ["END" toString] [goodTerminator codepointToString] if
                "\", but found \"" currentCode pc.eof = ["END" toString] [currentCode codepointToString] if
                "\"") assembleString lexicalError
            ] [

              @unfinishedPositions.popBack

              currentCode pc.closeRBr = [
                @unfinishedNodes.last makeListNode
                @unfinishedNodes.popBack
                @unfinishedTerminators.popBack
                addToLastUnfinished
              ] [
                currentCode pc.closeSBr = [
                  @unfinishedNodes.last makeCodeNode
                  @unfinishedNodes.popBack
                  @unfinishedTerminators.popBack
                  addToLastUnfinished
                ] [
                  currentCode pc.closeFBr = [
                    @unfinishedNodes.last makeObjectNode
                    @unfinishedNodes.popBack
                    @unfinishedTerminators.popBack
                    addToLastUnfinished
                  ] [
                    currentCode pc.eof = [
                      unfinishedNodes.dataSize 1 = not [
                        "unexpected end of the file!" makeStringView lexicalError
                      ] when
                      0 @unfinishedNodes.at @mainResult.@nodes set
                      @unfinishedNodes.popBack
                      @unfinishedTerminators.popBack
                    ] [
                      currentCode pc.semicolon = [
                        @unfinishedLabelNames.last @unfinishedNodes.last makeLabelNode
                        @unfinishedNodes.popBack
                        @unfinishedTerminators.popBack
                        @unfinishedLabelNames.popBack
                        addToLastUnfinished
                      ] [
                        "unknown terminator" makeStringView lexicalError
                      ] if
                    ] if
                  ] if
                ] if
              ] if
            ] if
            iterate

            currentCode pc.specials inArray not
            [currentCode pc.comma = not] &&
            [currentCode pc.dot = not] && [
              "wrong symbol after terminator" lexicalError
            ] when
          ] [
            currentCode pc.cr = [
              iterate
            ] [
              currentCode pc.lf = [
                iterate
              ] [
                currentCode pc.grid = [
                  parseComment
                ] [
                  currentCode pc.colon = [
                    "separated \":\"" lexicalError
                  ] [
                    "unknown symbol" lexicalError
                  ] if
                ] if
              ] if
            ] if
          ] if
        ] if
      ] if
    ] [
      lastPosition: currentPosition copy;
      parseIdentifier [
        mainResult.memory.dataSize 1 -   # if made label, dont do it
        @unfinishedNodes.last.pushBack
      ] when
    ] if

    unfinishedNodes.dataSize 0 > [mainResult.success copy] &&
  ] loop
];

{
  currentFileNumber: Int32;
  text: StringView Cref;
  mainResult: ParserResult Ref;
} () {convention: cdecl;} [
  copy currentFileNumber:;
  splittedString: .split;
  mainResult:;
  splittedString.success [
    currentPosition: PositionInfo;
    prevPosition: PositionInfo;

    currentCode: 0n32 dynamic;
    currentSymbol: StringView;

    pc: makeParserConstants;

    unfinishedPositions: PositionInfo Array;
    unfinishedLabelNames: String Array;
    unfinishedNodes: IndexArray Array;
    unfinishedTerminators: Nat32 Array;

    currentPosition @unfinishedPositions.pushBack
    IndexArray @unfinishedNodes.pushBack
    pc.eof @unfinishedTerminators.pushBack

    iterate parseNode
  ] [
    FALSE @mainResult.@success set
    ("wrong encoding, can not recognize line and column, offset in bytes: " splittedString.errorOffset) assembleString @mainResult.@errorInfo.@message set
    splittedString.errorOffset 0 cast @mainResult.@errorInfo.@position.@offset set
    0 @mainResult.@errorInfo.@position.@line set
    splittedString.errorOffset 0 cast @mainResult.@errorInfo.@position.@column set
  ] if
] "parseString" exportFunction
