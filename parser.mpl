"Array.Array" use
"Array.makeSubRange" use
"String.String" use
"String.StringView" use
"String.assembleString" use
"String.codepointToString" use
"String.makeStringView" use
"String.makeStringView2" use
"String.splitString" use
"String.toString" use
"ascii.ascii" use
"control.&&" use
"control.=" use
"control.Cref" use
"control.Cond" use
"control.Int32" use
"control.Nat32" use
"control.Nat8" use
"control.Ref" use
"control.between?" use
"control.case" use
"control.each" use
"control.enum" use
"control.sequence" use
"control.times" use
"control.when" use
"control.within?" use
"control.||" use
"conventions.cdecl" use

"astNodeType.AstNode" use
"astNodeType.AstNodeType" use
"astNodeType.IndexArray" use
"astNodeType.ParserResult" use
"astNodeType.PositionInfo" use

codepointHex?: [
  codepoint:;
  codepoint 48 57 between? [codepoint 65 70 between?] ||
];

codepointHexValue: [
  codepoint:;
  codepoint codepoint 65 < [48] [55] if -
];

codeunitHead?: [
  codeunit:;
  codeunit 0x80n8 < [codeunit 0xC0n8 0xF8n8 within?] ||
];

codeunitTail?: [
  codeunit:;
  codeunit 0xC0n8 and 0x80n8 =
];

fillPositionInfo: [
  astNode:;
  lastPosition.line @astNode.@line set
  lastPosition.column @astNode.@column set
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


  makeLookupTable: [
    av:;
    result: Cond Array;
    256 @result.resize
    @result [p:; FALSE @p set] each
    av [
      v:;
      TRUE v 0 cast @result.at set
    ] each

    result
  ];

  joinLookupTables: [
    right:;
    left:;
    result: Cond Array;
    256 @result.resize

    result.getSize [
      i left.at i right.at or i @result.at set
    ] times

    result
  ];

  starters: (ascii.openRBr ascii.openSBr ascii.openFBr) makeLookupTable;
  terminators: (ascii.null ascii.closeRBr ascii.closeSBr ascii.closeFBr ascii.semicolon) makeLookupTable;
  digits: (ascii.zero ascii.one ascii.two ascii.three ascii.four ascii.five ascii.six ascii.seven ascii.eight ascii.nine) makeLookupTable;
  numberSigns: (ascii.plus ascii.minus) makeLookupTable;
  specials: (ascii.space ascii.cr ascii.lf ascii.colon ascii.grid) makeLookupTable starters joinLookupTables terminators joinLookupTables;
  begExp: (ascii.eCode ascii.eCodeBig) makeLookupTable;
  endNumbers: specials (ascii.comma) makeLookupTable joinLookupTables;
  endNames: specials copy;

  hexDigits: (
    ascii.zero ascii.one ascii.two ascii.three ascii.four ascii.five ascii.six ascii.seven ascii.eight ascii.nine
    ascii.aCode ascii.bCode ascii.cCode ascii.dCode ascii.eCode ascii.fCode
    ascii.aCodeBig ascii.bCodeBig ascii.cCodeBig ascii.dCodeBig ascii.eCodeBig ascii.fCodeBig
  ) makeLookupTable;

  hexToInt: [
    result: Nat32 Array;
    256 @result.resize

    10 [i      0n32 cast ascii.zero     0 cast i + @result.at set] times
    6  [i 10 + 0n32 cast ascii.aCode    0 cast i + @result.at set] times
    6  [i 10 + 0n32 cast ascii.aCodeBig 0 cast i + @result.at set] times
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
    currentPosition.offset 0 < ~ [
      currentPosition.offset splittedString.chars.at @currentSymbol set
      currentSymbol.data Nat8 addressToReference Nat32 cast @currentCode set
    ] [
      StringView @currentSymbol set
      ascii.null @currentCode set
    ] if
  ] when
];

iterate: [
  mainResult.success [
    currentPosition @prevPosition set

    currentCode ascii.lf = [
      0 dynamic @currentPosition.@column set
      currentPosition.line 1 + @currentPosition.@line set
    ] when

    currentPosition.offset 1 + @currentPosition.@offset set
    currentPosition.column 1 + @currentPosition.@column set

    currentPosition.offset splittedString.chars.getSize < [
      currentPosition.offset splittedString.chars.at @currentSymbol set
      currentSymbol.data Nat8 addressToReference Nat32 cast @currentCode set
    ] [
      StringView @currentSymbol set
      ascii.null @currentCode set
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
  iterate
  stop: FALSE;
  error: [lexicalError TRUE !stop];
  [
    skip: FALSE;
    term: [body:; [body TRUE !skip] when];
    (
      [skip ~] [
        currentCode ascii.null = ["unterminated string" error] term
      ] [
        currentCode ascii.quote = [TRUE !stop] term
      ] [
        currentCode ascii.backSlash = ~ [currentSymbol @nameSymbols.pushBack] term
      ] [
        iterate
        currentCode ascii.null = ["unterminated escape sequence" error] term
      ] [
        currentCode ascii.quote = [currentSymbol @nameSymbols.pushBack] term
      ] [
        currentCode ascii.nCode = [LF makeStringView @nameSymbols.pushBack] term
      ] [
        currentCode ascii.rCode = [code: 13n8; code storageAddress 1 makeStringView2 @nameSymbols.pushBack] term
      ] [
        currentCode ascii.tCode = [code: 9n8; code storageAddress 1 makeStringView2 @nameSymbols.pushBack] term
      ] [
        currentCode ascii.backSlash = [currentSymbol @nameSymbols.pushBack] term
      ] [
        currentCode Int32 cast codepointHex? ~ ["invalid escape sequence" error] term
      ] [
        first: currentCode Int32 cast codepointHexValue Nat8 cast;
        iterate
        currentCode ascii.null = ["unterminated hex sequence" error] term
      ] [
        currentCode Int32 cast codepointHex? ~ ["invalid hex sequence" error] term
      ] [
        first 4n8 lshift currentCode Int32 cast codepointHexValue Nat8 cast or !first
        first codeunitHead? ~ ["invalid unicode sequence" error] term
      ] [
        first storageAddress 1 makeStringView2 @nameSymbols.pushBack
        first 0x80n8 < [] term
      ] [
        iterate
        currentCode ascii.null = ["unterminated hex sequence" error] term
      ] [
        currentCode Int32 cast codepointHex? ~ ["invalid hex sequence" error] term
      ] [
        next: currentCode Int32 cast codepointHexValue Nat8 cast;
        iterate
        currentCode ascii.null = ["unterminated hex sequence" error] term
      ] [
        currentCode Int32 cast codepointHex? ~ ["invalid hex sequence" error] term
      ] [
        next 4n8 lshift currentCode Int32 cast codepointHexValue Nat8 cast or !next
        next codeunitTail? ~ ["invalid unicode sequence" error] term
      ] [
        next storageAddress 1 makeStringView2 @nameSymbols.pushBack
        first 0xE0n8 < [] term
      ] [
        iterate
        currentCode ascii.null = ["unterminated hex sequence" error] term
      ] [
        currentCode Int32 cast codepointHex? ~ ["invalid hex sequence" error] term
      ] [
        next: currentCode Int32 cast codepointHexValue Nat8 cast;
        iterate
        currentCode ascii.null = ["unterminated hex sequence" error] term
      ] [
        currentCode Int32 cast codepointHex? ~ ["invalid hex sequence" error] term
      ] [
        next 4n8 lshift currentCode Int32 cast codepointHexValue Nat8 cast or !next
        next codeunitTail? ~ ["invalid unicode sequence" error] term
      ] [
        next storageAddress 1 makeStringView2 @nameSymbols.pushBack
        first 0xF0n8 < [] term
      ] [
        iterate
        currentCode ascii.null = ["unterminated hex sequence" error] term
      ] [
        currentCode Int32 cast codepointHex? ~ ["invalid hex sequence" error] term
      ] [
        next: currentCode Int32 cast codepointHexValue Nat8 cast;
        iterate
        currentCode ascii.null = ["unterminated hex sequence" error] term
      ] [
        currentCode Int32 cast codepointHex? ~ ["invalid hex sequence" error] term
      ] [
        next 4n8 lshift currentCode Int32 cast codepointHexValue Nat8 cast or !next
        next codeunitTail? ~ ["invalid unicode sequence" error] term
      ] [
        next storageAddress 1 makeStringView2 @nameSymbols.pushBack
      ]
    ) sequence

    iterate stop ~
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

dCheck: [currentCode pc.digits inArray ~ ["wrong number constant" lexicalError] when];

xCheck: [
  currentCode pc.digits inArray ~ [
    currentCode ascii.xCode = [
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
      currentCode ascii.zero - 0 cast @currentArray.pushBack
      iterate TRUE
    ] [
      currentCode ascii.dot = [
        stage 0 = ~ [
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
        currentCode ascii.nCode = [
          stage 0 = ~ ["wrong number constant" lexicalError] when
          3 @stage set
          iterate TRUE
          @afterT !currentArray
          xCheck
          1 @typeClass set
        ] [
          currentCode ascii.iCode = [
            stage 0 = ~ ["wrong number constant" lexicalError] when
            3 @stage set
            iterate TRUE
            @afterT !currentArray
            xCheck
          ] [
            currentCode ascii.rCode = [
              stage 1 = stage 2 = or ~ ["wrong number constant" lexicalError] when
              3 @stage set
              iterate TRUE
              @afterT !currentArray
              dCheck
            ] [
              currentCode pc.begExp inArray [
                stage 1 = ~ ["wrong number constant" lexicalError] when
                iterate TRUE
                @afterE !currentArray
                currentCode pc.numberSigns inArray [
                  currentCode ascii.minus = @hasEMinus set
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
    p [currentPosition.offset @tokenEnd set] when
    p mainResult.success and
  ] loop

  token: tokenBegin tokenEnd splittedString.chars makeSubRange assembleString;

  afterT.getSize 2 > [ "error in number constant" lexicalError ] when

  typeName: 0 dynamic;
  afterT.getSize [typeName 100 * i afterT.at + 1 + @typeName set] times

  typeClass 2 = [
    type: 0.0r64 dynamic;
    ten: 10.0r64 dynamic;
    result: 0.0r64 dynamic;
    beforeDot.getSize [result 10.0r64 * i beforeDot.at type cast + @result set] times
    tenRcp: 0.1r64 dynamic;
    fracPartFactor: tenRcp copy;
    afterDot.getSize [
      digit: i afterDot.at type cast;
      digit  fracPartFactor * result + @result set
      fracPartFactor tenRcp * @fracPartFactor set
    ] times

    decOrder: 0.0r64 dynamic;
    afterE.getSize [decOrder 10.0r64 * i afterE.at type cast + @decOrder set] times
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
      beforeDot.getSize [result 10n64 * i beforeDot.at 0i64 cast type cast + @result set] times
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
      beforeDot.getSize [result 10i64 * i beforeDot.at type cast + @result set] times
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
      currentCode ascii.dot = [
        FALSE
      ] [
        currentCode ascii.nCode = [
          stage 0 = ~ ["wrong number constant" lexicalError] when
          3 @stage set
          iterate TRUE
          @afterT !currentArray
          xCheck
          1 @typeClass set
        ] [
          currentCode ascii.iCode = [
            stage 0 = ~ ["wrong number constant" lexicalError] when
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
  afterT.getSize 2 > [ "error in number constant" lexicalError ] when

  typeName: 0 dynamic;
  afterT.getSize [typeName 100 * i afterT.at + 1 + @typeName set] times
  hasMinus ["negative hex constants not allowed" lexicalError] when

  typeClass 1 = [
    type: 0n64;
    ten: 10n64;
    result: 0n64;
    beforeT.getSize 0 = ["empty hex constant" lexicalError] when
    beforeT.getSize [result 16n64 * i beforeT.at 0i64 cast type cast + @result set] times
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
    beforeT.getSize 0 = ["empty hex constant" lexicalError] when
    beforeT.getSize [result 16i64 * i beforeT.at type cast + @result set] times
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
  currentCode ascii.minus = [
    TRUE dynamic @hasMinus set
    iterate
  ] [
    currentCode ascii.plus = [iterate] when
  ] if

  currentCode ascii.zero = [
    iterate
    currentCode ascii.xCode = [
      iterate hasMinus parseHexNumber
    ] [
      currentCode ascii.iCode = currentCode ascii.nCode = or currentCode ascii.dot = or currentCode pc.endNumbers inArray or [
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
  ascii.semicolon @unfinishedTerminators.pushBack
  name toString @unfinishedLabelNames.pushBack
  IndexArray @unfinishedNodes.pushBack
];

parseName: [
  DotState: (
    "UNKNOWN"
    "MULTI_DOT"
    "NOT_A_MEMBER"
    "WAS_FIRST_DOT"
    "MEMBER"
  ) Int32 enum;

  dotState: DotState.UNKNOWN dynamic;
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
      currentCode ascii.quote = [
        "quote cannot be part of identifier" lexicalError
        FALSE
      ] [
        currentCode ascii.dot = [
          dotState (
            DotState.MULTI_DOT [
              currentSymbol @nameSymbols.pushBack
              iterate TRUE
            ]
            DotState.NOT_A_MEMBER [
              currentSymbol @nameSymbols.pushBack
              DotState.MULTI_DOT @dotState set
              iterate TRUE
            ]
            DotState.WAS_FIRST_DOT [
              currentSymbol @nameSymbols.pushBack
              DotState.MULTI_DOT @dotState set
              iterate TRUE
            ]
            [
              nameSymbols.getSize 0 > [
                FALSE
              ] [
                checkFirst
                checkOffset 1 + @checkOffset set
                currentSymbol @nameSymbols.pushBack
                DotState.WAS_FIRST_DOT @dotState set
                iterate TRUE
              ] if
            ]
          ) case
        ] [
          currentCode ascii.at = [
            checkFirst
            dotState DotState.UNKNOWN = [DotState.NOT_A_MEMBER @dotState set] when
            TRUE @read set
            iterate TRUE
          ] [
            currentCode ascii.exclamation = [
              checkFirst
              dotState DotState.UNKNOWN = [DotState.NOT_A_MEMBER @dotState set] when
              TRUE @write set
              iterate TRUE
            ] [
              currentCode ascii.comma = nameSymbols.getSize 0 > and [
                FALSE
              ] [
                currentCode pc.endNames inArray [
                  currentCode ascii.colon = [
                    TRUE @label set
                    iterate
                  ] when
                  FALSE
                ] [
                  dotState
                  (
                    DotState.MULTI_DOT [
                      "identifier cannot start from many dots" lexicalError
                    ]
                    DotState.WAS_FIRST_DOT [
                      DotState.MEMBER @dotState set
                      @nameSymbols.clear
                    ]
                    DotState.MEMBER [
                    ]
                    [
                      DotState.UNKNOWN @dotState set
                    ]
                  ) case

                  nameSymbols.getSize 1 > [0 nameSymbols.at "," =] && [
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

    nameSymbols.getSize 0 = [
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
    ] [
      name: nameSymbols assembleString;

      label [
        dotState DotState.MEMBER = read write or or ["label declaration must be without . @ ! modifiers" lexicalError] when
        name makeLabel FALSE
      ] [
        dotState DotState.MEMBER = [
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

  currentCode ascii.quote = [
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
    currentCode ascii.null = currentCode ascii.lf = or ~
  ] loop
];

addNestedNode: [
  currentPosition @unfinishedPositions.pushBack

  IndexArray @unfinishedNodes.pushBack
  currentCode ascii.openRBr = [
    ascii.closeRBr @unfinishedTerminators.pushBack
  ] [
    currentCode ascii.openFBr = [
      ascii.closeFBr @unfinishedTerminators.pushBack
    ] [
      currentCode ascii.openSBr = [
        ascii.closeSBr @unfinishedTerminators.pushBack
      ] [
        "unknown starter for nested node" lexicalError
      ] if
    ] if
  ] if

  iterate
];

addToLastUnfinished: [
  @mainResult.@memory.pushBack
  mainResult.memory.getSize 1 - @unfinishedNodes.last.pushBack
];

parseNode: [
  [
    currentCode pc.specials inArray [
      currentCode ascii.space = [
        iterate
      ] [
        currentCode pc.starters inArray [
          addNestedNode
        ] [
          currentCode pc.terminators inArray [
            goodTerminator: unfinishedTerminators.last copy;
            lastPosition: unfinishedPositions.last;

            currentCode goodTerminator = ~ [
              ("wrong terminator of block started at (" lastPosition.line ":" lastPosition.column
                "), expected \"" goodTerminator ascii.null = ["END" toString] [goodTerminator codepointToString] if
                "\", but found \"" currentCode ascii.null = ["END" toString] [currentCode codepointToString] if
                "\"") assembleString lexicalError
            ] [

              @unfinishedPositions.popBack

              currentCode ascii.closeRBr = [
                @unfinishedNodes.last makeListNode
                @unfinishedNodes.popBack
                @unfinishedTerminators.popBack
                addToLastUnfinished
              ] [
                currentCode ascii.closeSBr = [
                  @unfinishedNodes.last makeCodeNode
                  @unfinishedNodes.popBack
                  @unfinishedTerminators.popBack
                  addToLastUnfinished
                ] [
                  currentCode ascii.closeFBr = [
                    @unfinishedNodes.last makeObjectNode
                    @unfinishedNodes.popBack
                    @unfinishedTerminators.popBack
                    addToLastUnfinished
                  ] [
                    currentCode ascii.null = [
                      unfinishedNodes.getSize 1 = ~ [
                        "unexpected end of the file!" makeStringView lexicalError
                      ] when
                      0 @unfinishedNodes.at @mainResult.@nodes set
                      @unfinishedNodes.popBack
                      @unfinishedTerminators.popBack
                    ] [
                      currentCode ascii.semicolon = [
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

            currentCode pc.specials inArray ~
            [currentCode ascii.comma = ~] &&
            [currentCode ascii.dot = ~] && [
              "wrong symbol after terminator" lexicalError
            ] when
          ] [
            currentCode ascii.cr = [
              iterate
            ] [
              currentCode ascii.lf = [
                iterate
              ] [
                currentCode ascii.grid = [
                  parseComment
                ] [
                  currentCode ascii.colon = [
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
        mainResult.memory.getSize 1 -   # if made label, dont do it
        @unfinishedNodes.last.pushBack
      ] when
    ] if

    unfinishedNodes.getSize 0 > [mainResult.success copy] &&
  ] loop
];

{
  text: StringView Cref;
  mainResult: ParserResult Ref;
} () {convention: cdecl;} [
  splittedString: splitString;
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
    ascii.null @unfinishedTerminators.pushBack

    iterate parseNode
  ] [
    FALSE @mainResult.@success set
    ("wrong encoding, can not recognize line and column, offset in bytes: " splittedString.errorOffset) assembleString @mainResult.@errorInfo.@message set
    splittedString.errorOffset 0 cast @mainResult.@errorInfo.@position.@offset set
    0 @mainResult.@errorInfo.@position.@line set
    splittedString.errorOffset 0 cast @mainResult.@errorInfo.@position.@column set
  ] if
] "parseString" exportFunction
