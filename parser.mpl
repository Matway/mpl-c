# Copyright (C) 2021 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"Array"     use
"String"    use
"algorithm" use
"ascii"     use
"control"   use

"astNodeType" use

codepointHex?: [
  codepoint:;
  codepoint 48 57 between [codepoint 65 70 between] ||
];

codepointHexValue: [
  codepoint:;
  codepoint codepoint 65 < [48] [55] if -
];

codeunitHead?: [
  codeunit:;
  codeunit 0x80n8 < [codeunit 0xC0n8 0xF8n8 within] ||
];

codeunitTail?: [
  codeunit:;
  codeunit 0xC0n8 and 0x80n8 =
];

fillPositionInfo: [
  astNode:;
  lastPosition @astNode.@positionInfo set
  currentPosition.offsetStart new @astNode.@positionInfo.!offsetEnd
];

addToMainResult: [
  astArray:;

  newIndex: mainResult.memory.size;
  @astArray @mainResult.@memory.append
  newIndex
];

addToLastUnfinished: [
  astNode:;
  @astNode @unfinishedNodes.last.@nodes.append
];

makeLabelNode: [
  children:;
  name:;
  result: AstNode;
  @result fillPositionInfo
  (name ":") assembleString @result.@positionInfo.@token set
  AstNodeType.Label @result.@data.setTag
  branch: AstNodeType.Label @result.@data.get;
  @children addToMainResult @branch.@children set
  name @branch.@name set
  @result
];

makeCodeNode: [
  children:;
  result: AstNode;
  @result fillPositionInfo
  "[" toString @result.@positionInfo.@token set
  AstNodeType.Code @result.@data.setTag
  branch: AstNodeType.Code @result.@data.get;
  @children addToMainResult @branch set
  @result
];

makeObjectNode: [
  children:;
  result: AstNode;
  @result fillPositionInfo
  "{" toString @result.@positionInfo.@token set
  AstNodeType.Object @result.@data.setTag
  branch: AstNodeType.Object @result.@data.get;
  @children addToMainResult @branch set
  @result
];

makeListNode: [
  children:;
  result: AstNode;
  @result fillPositionInfo
  "(" toString     @result.@positionInfo.@token set
  AstNodeType.List @result.@data.setTag
  branch: AstNodeType.List @result.@data.get;
  @children addToMainResult @branch set
  @result
];

makeNameNode: [
  name:;
  result: AstNode;
  @result fillPositionInfo
  name toString @result.@positionInfo.@token set
  AstNodeType.Name @result.@data.setTag
  branch: AstNodeType.Name @result.@data.get;
  name toString @branch.@name set
  @result
];

makeNameReadNode: [
  name:;
  result: AstNode;
  @result fillPositionInfo
  ("@" name) assembleString @result.@positionInfo.@token set
  AstNodeType.NameRead @result.@data.setTag
  branch: AstNodeType.NameRead @result.@data.get;
  name toString @branch.@name set
  @result
];

makeNameWriteNode: [
  name:;
  result: AstNode;
  @result fillPositionInfo
  ("!" name) assembleString @result.@positionInfo.@token set
  AstNodeType.NameWrite @result.@data.setTag
  branch: AstNodeType.NameWrite @result.@data.get;
  name toString @branch.@name set
  @result
];

makeNameMemberNode: [
  name:;
  result: AstNode;
  @result fillPositionInfo
  ("." name) assembleString @result.@positionInfo.@token set
  AstNodeType.NameMember @result.@data.setTag
  branch: AstNodeType.NameMember @result.@data.get;
  name toString @branch.@name set
  @result
];

makeNameReadMemberNode: [
  name:;
  result: AstNode;
  @result fillPositionInfo
  (".@" name) assembleString @result.@positionInfo.@token set
  AstNodeType.NameReadMember @result.@data.setTag
  branch: AstNodeType.NameReadMember @result.@data.get;
  name toString @branch.@name set
  @result
];

makeNameWriteMemberNode: [
  name:;
  result: AstNode;
  @result fillPositionInfo
  (".!" name) assembleString @result.@positionInfo.@token set
  AstNodeType.NameWriteMember @result.@data.setTag
  branch: AstNodeType.NameWriteMember @result.@data.get;
  name toString @branch.@name set
  @result
];

makeStringNode: [
  value:;
  result: AstNode;
  @result fillPositionInfo
  "TEXT" toString @result.@positionInfo.@token set
  AstNodeType.String @result.@data.setTag
  branch: AstNodeType.String @result.@data.get;
  value @branch set
  @result
];

makeNumberi8Node: [
  token:;
  number: new;
  result: AstNode;
  @result fillPositionInfo
  token @result.@positionInfo.@token set
  AstNodeType.Numberi8 @result.@data.setTag
  branch: AstNodeType.Numberi8 @result.@data.get;
  number @branch set
  @result
];

makeNumberi16Node: [
  token:;
  number: new;
  result: AstNode;
  @result fillPositionInfo
  token @result.@positionInfo.@token set
  AstNodeType.Numberi16 @result.@data.setTag
  branch: AstNodeType.Numberi16 @result.@data.get;
  number @branch set
  @result
];

makeNumberi32Node: [
  token:;
  number: new;
  result: AstNode;
  @result fillPositionInfo
  token @result.@positionInfo.@token set
  AstNodeType.Numberi32 @result.@data.setTag
  branch: AstNodeType.Numberi32 @result.@data.get;
  number @branch set
  @result
];

makeNumberi64Node: [
  token:;
  number: new;
  result: AstNode;
  @result fillPositionInfo
  token @result.@positionInfo.@token set
  AstNodeType.Numberi64 @result.@data.setTag
  branch: AstNodeType.Numberi64 @result.@data.get;
  number @branch set
  @result
];

makeNumberixNode: [
  token:;
  number: new;
  result: AstNode;
  @result fillPositionInfo
  token @result.@positionInfo.@token set
  AstNodeType.Numberix @result.@data.setTag
  branch: AstNodeType.Numberix @result.@data.get;
  number @branch set
  @result
];

makeNumbern8Node: [
  token:;
  number: new;
  result: AstNode;
  @result fillPositionInfo
  token @result.@positionInfo.@token set
  AstNodeType.Numbern8 @result.@data.setTag
  branch: AstNodeType.Numbern8 @result.@data.get;
  number @branch set
  @result
];

makeNumbern16Node: [
  token:;
  number: new;
  result: AstNode;
  @result fillPositionInfo
  token @result.@positionInfo.@token set
  AstNodeType.Numbern16 @result.@data.setTag
  branch: AstNodeType.Numbern16 @result.@data.get;
  number @branch set
  @result
];

makeNumbern32Node: [
  token:;
  number: new;
  result: AstNode;
  @result fillPositionInfo
  token @result.@positionInfo.@token set
  AstNodeType.Numbern32 @result.@data.setTag
  branch: AstNodeType.Numbern32 @result.@data.get;
  number @branch set
  @result
];

makeNumbern64Node: [
  token:;
  number: new;
  result: AstNode;
  @result fillPositionInfo
  token @result.@positionInfo.@token set
  AstNodeType.Numbern64 @result.@data.setTag
  branch: AstNodeType.Numbern64 @result.@data.get;
  number @branch set
  @result
];

makeNumbernxNode: [
  token:;
  number: new;
  result: AstNode;
  @result fillPositionInfo
  token @result.@positionInfo.@token set
  AstNodeType.Numbernx @result.@data.setTag
  branch: AstNodeType.Numbernx @result.@data.get;
  number @branch set
  @result
];

makeReal32Node: [
  token:;
  number: new;
  result: AstNode;
  @result fillPositionInfo
  token @result.@positionInfo.@token set
  AstNodeType.Real32 @result.@data.setTag
  branch: AstNodeType.Real32 @result.@data.get;
  number @branch set
  @result
];

makeReal64Node: [
  token:;
  number: new;
  result: AstNode;
  @result fillPositionInfo
  token @result.@positionInfo.@token set
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

    result.size [
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
  endNames: specials new;

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
  code: new;
  code 256n32 < [code 0 cast where.at new] &&
];

undo: [
  mainResult.success [
    prevPosition @currentPosition set
    currentPosition.offsetStart 0 < ~ [
      currentPosition.offsetStart splittedString.chars.at @currentSymbol set
      currentSymbol.data Nat32 cast @currentCode set
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

    fileId                          @currentPosition.@fileId      set
    currentPosition.offsetStart 1 + @currentPosition.@offsetStart set
    currentPosition.column      1 + @currentPosition.@column      set

    currentPosition.offsetStart splittedString.chars.size < [
      currentPosition.offsetStart splittedString.chars.at @currentSymbol set
      currentSymbol.data Nat32 cast @currentCode set
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
  nameSymbols: String;
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
        currentCode ascii.backSlash = ~ [currentSymbol @nameSymbols.cat] term
      ] [
        iterate
        currentCode ascii.null = ["unterminated escape sequence" error] term
      ] [
        currentCode ascii.quote = [currentSymbol @nameSymbols.cat] term
      ] [
        currentCode ascii.nCode = [LF makeStringView @nameSymbols.cat] term
      ] [
        currentCode ascii.rCode = [code: 13n8; (code storageAddress Nat8 addressToReference const 1) toStringView @nameSymbols.cat] term
      ] [
        currentCode ascii.tCode = [code: 9n8; (code storageAddress Nat8 addressToReference const 1) toStringView @nameSymbols.cat] term
      ] [
        currentCode ascii.backSlash = [currentSymbol @nameSymbols.cat] term
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
        (first storageAddress Nat8 addressToReference const 1) toStringView @nameSymbols.cat
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
        (next storageAddress Nat8 addressToReference const 1) toStringView @nameSymbols.cat
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
        (next storageAddress Nat8 addressToReference const 1) toStringView @nameSymbols.cat
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
        (next storageAddress Nat8 addressToReference const 1) toStringView @nameSymbols.cat
      ]
    ) sequence

    iterate stop ~
  ] loop

  @nameSymbols makeStringNode addToLastUnfinished
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
      -2 @currentArray.append
      iterate
    ] [
      "wrong number constant" lexicalError
    ] if
  ] when
];

parseDecNumber: [
  hasMinus: new;

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
  tokenBegin: currentPosition.offsetStart hasMinus [1 -][new] if;
  tokenEnd: tokenBegin new;

  [
    currentCode pc.digits inArray [
      currentCode ascii.zero - 0 cast @currentArray.append
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
    p [currentPosition.offsetStart @tokenEnd set] when
    p mainResult.success and
  ] loop

  token: splittedString.chars tokenBegin tokenEnd range assembleString;

  afterT.size 2 > [ "error in number constant" lexicalError ] when

  typeName: 0 dynamic;
  afterT.size [typeName 100 * i afterT.at + 1 + @typeName set] times

  typeClass 2 = [
    type: 0.0r64 dynamic;
    ten: 10.0r64 dynamic;
    result: 0.0r64 dynamic;
    beforeDot.size [result 10.0r64 * i beforeDot.at type cast + @result set] times
    tenRcp: 0.1r64 dynamic;
    fracPartFactor: tenRcp new;
    afterDot.size [
      digit: i afterDot.at type cast;
      digit  fracPartFactor * result + @result set
      fracPartFactor tenRcp * @fracPartFactor set
    ] times

    decOrder: 0.0r64 dynamic;
    afterE.size [decOrder 10.0r64 * i afterE.at type cast + @decOrder set] times
    hasEMinus [decOrder neg @decOrder set] when
    hasMinus [result neg @result set] when
    result 10.0r64 decOrder ^ * @result set

    typeName 705 = typeName 0 = or [
      result token makeReal64Node addToLastUnfinished
    ] [
      typeName 403 = [
        result token makeReal32Node addToLastUnfinished
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
      beforeDot.size [result 10n64 * i beforeDot.at 0i64 cast type cast + @result set] times
      typeName 705 = [
        result token makeNumbern64Node addToLastUnfinished
      ] [
        typeName 403 = typeName 0 = or [
          result token makeNumbern32Node addToLastUnfinished
        ] [
          typeName 207 = [
            result token makeNumbern16Node addToLastUnfinished
          ] [
            typeName 9 = [
              result token makeNumbern8Node addToLastUnfinished
            ] [
              typeName -1 = [
                result token makeNumbernxNode addToLastUnfinished
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
      beforeDot.size [result 10i64 * i beforeDot.at type cast + @result set] times
      hasMinus [result neg @result set] when
      typeName 705 = [
        result token makeNumberi64Node addToLastUnfinished
      ] [
        typeName 403 = typeName 0 = or [
          result token makeNumberi32Node addToLastUnfinished
        ] [
          typeName 207 = [
            result token makeNumberi16Node addToLastUnfinished
          ] [
            typeName 9 = [
              result token makeNumberi8Node addToLastUnfinished
            ] [
              typeName -1 = [
                result token makeNumberixNode addToLastUnfinished
              ] [
                "wrong integer constant suffix" lexicalError
              ] if
            ] if
          ] if
        ] if
      ] if
    ] if
  ] if

  mainResult.success new
];

parseHexNumber: [
  hasMinus: new;
  IntArray: [Int32 Array];
  beforeT: IntArray;
  afterT: IntArray;
  currentArray: @beforeT;
  typeClass: 0 dynamic;
  stage: 0 dynamic;
  #0 before n
  #1 after n

  result: 0 dynamic;
  tokenBegin: currentPosition.offsetStart hasMinus [3 -][2 -] if;
  tokenEnd: tokenBegin new;

  [
    currentCode pc.hexDigits inArray [
      currentCode 0 cast pc.hexToInt.at 0 cast @currentArray.append
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
    p [ currentPosition.offsetStart @tokenEnd set ] when
    p mainResult.success and
  ] loop

  token: splittedString.chars tokenBegin tokenEnd range assembleString;
  afterT.size 2 > [ "error in number constant" lexicalError ] when

  typeName: 0 dynamic;
  afterT.size [typeName 100 * i afterT.at + 1 + @typeName set] times
  hasMinus ["negative hex constants not allowed" lexicalError] when

  typeClass 1 = [
    type: 0n64;
    ten: 10n64;
    result: 0n64;
    beforeT.size 0 = ["empty hex constant" lexicalError] when
    beforeT.size [result 16n64 * i beforeT.at 0i64 cast type cast + @result set] times
    typeName 705 = [
      result token makeNumbern64Node addToLastUnfinished
    ] [
      typeName 403 = typeName 0 = or [
        result token makeNumbern32Node addToLastUnfinished
      ] [
        typeName 207 = [
          result token makeNumbern16Node addToLastUnfinished
        ] [
          typeName 9 = [
            result token makeNumbern8Node addToLastUnfinished
          ] [
            typeName -1 = [
              result token makeNumbernxNode addToLastUnfinished
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
    beforeT.size 0 = ["empty hex constant" lexicalError] when
    beforeT.size [result 16i64 * i beforeT.at type cast + @result set] times
    typeName 705 = [
      result token makeNumberi64Node addToLastUnfinished
    ] [
      typeName 403 = typeName 0 = or [
        result token makeNumberi32Node addToLastUnfinished
      ] [
        typeName 207 = [
          result token makeNumberi16Node addToLastUnfinished
        ] [
          typeName 9 = [
            result token makeNumberi8Node addToLastUnfinished
          ] [
            typeName -1 = [
              result token makeNumberixNode addToLastUnfinished
            ] [
              "wrong integer constant suffix" lexicalError
            ] if
          ] if
        ] if
      ] if
    ] if
  ] if

  mainResult.success new
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
  lastPosition @unfinishedPositions.append
  ascii.semicolon @unfinishedTerminators.append
  name toString @unfinishedLabelNames.append
  newAstNodeArray: AstNodeArray;
  lastPosition @newAstNodeArray.@positionInfo set
  @newAstNodeArray @unfinishedNodes.append
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
  checkOffset: currentPosition.offsetStart new;
  checkFirst: [currentPosition.offsetStart checkOffset > ["invalid identifier" lexicalError] when];
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
              currentSymbol @nameSymbols.append
              iterate TRUE
            ]
            DotState.NOT_A_MEMBER [
              currentSymbol @nameSymbols.append
              DotState.MULTI_DOT @dotState set
              iterate TRUE
            ]
            DotState.WAS_FIRST_DOT [
              currentSymbol @nameSymbols.append
              DotState.MULTI_DOT @dotState set
              iterate TRUE
            ]
            [
              nameSymbols.size 0 > [
                FALSE
              ] [
                checkFirst
                checkOffset 1 + @checkOffset set
                currentSymbol @nameSymbols.append
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
              currentCode ascii.comma = nameSymbols.size 0 > and [
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

                  nameSymbols.size 1 > [0 nameSymbols.at "," =] && [
                    "identifier cannot start from comma" lexicalError
                  ] when
                  currentSymbol @nameSymbols.append
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

    nameSymbols.size 0 = [
      read [
        label ["@" makeLabel FALSE]["@" makeNameNode addToLastUnfinished TRUE] if
      ] [
        write [
          label ["!" makeLabel FALSE]["!" makeNameNode addToLastUnfinished TRUE] if
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
            name makeNameReadMemberNode addToLastUnfinished TRUE
          ] [
            write [
              name makeNameWriteMemberNode addToLastUnfinished TRUE
            ] [
              name makeNameMemberNode addToLastUnfinished TRUE
            ] if
          ] if
        ] [
          read [
            name makeNameReadNode addToLastUnfinished TRUE
          ] [
            write [
              name makeNameWriteNode addToLastUnfinished TRUE
            ] [
              name makeNameNode addToLastUnfinished TRUE
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
  currentPosition @unfinishedPositions.append

  newAstNodeArray: AstNodeArray;
  currentPosition @newAstNodeArray.@positionInfo set
  @newAstNodeArray @unfinishedNodes.append

  currentCode ascii.openRBr = [
    ascii.closeRBr @unfinishedTerminators.append
  ] [
    currentCode ascii.openFBr = [
      ascii.closeFBr @unfinishedTerminators.append
    ] [
      currentCode ascii.openSBr = [
        ascii.closeSBr @unfinishedTerminators.append
      ] [
        "unknown starter for nested node" lexicalError
      ] if
    ] if
  ] if

  iterate
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
            goodTerminator: unfinishedTerminators.last new;
            lastPosition: unfinishedPositions.last;

            currentCode goodTerminator = ~ [
              ("wrong terminator of block started at (" lastPosition.line ":" lastPosition.column
                "), expected \"" goodTerminator ascii.null = ["END" toString] [goodTerminator Int32 cast toChar toString] if
                "\", but found \"" currentCode ascii.null = ["END" toString] [currentCode Int32 cast toChar toString] if
                "\"") assembleString lexicalError
            ] [

              @unfinishedPositions.popBack

              currentCode ascii.closeRBr = [
                iterate
                @unfinishedNodes.last makeListNode
                @unfinishedNodes.popBack
                @unfinishedTerminators.popBack
                addToLastUnfinished
              ] [
                currentCode ascii.closeSBr = [
                  iterate
                  @unfinishedNodes.last makeCodeNode
                  @unfinishedNodes.popBack
                  @unfinishedTerminators.popBack
                  addToLastUnfinished
                ] [
                  currentCode ascii.closeFBr = [
                    iterate
                    @unfinishedNodes.last makeObjectNode
                    @unfinishedNodes.popBack
                    @unfinishedTerminators.popBack
                    addToLastUnfinished
                  ] [
                    currentCode ascii.semicolon = [
                      iterate
                      @unfinishedLabelNames.last @unfinishedNodes.last makeLabelNode
                      @unfinishedNodes.popBack
                      @unfinishedTerminators.popBack
                      @unfinishedLabelNames.popBack
                      addToLastUnfinished
                    ] [
                      currentCode ascii.null = [
                        unfinishedNodes.size 1 = ~ [
                          "unexpected end of the file!" makeStringView lexicalError
                        ] when
                        0 @unfinishedNodes.at addToMainResult @mainResult.@root set
                        @unfinishedNodes.popBack
                        @unfinishedTerminators.popBack
                      ] [
                        "unknown terminator" makeStringView lexicalError
                      ] if

                      iterate
                    ] if
                  ] if
                ] if
              ] if
            ] if

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
      lastPosition: currentPosition new;
      success: parseIdentifier;
    ] if

    unfinishedNodes.size 0 > [mainResult.success new] &&
  ] loop
];

{
  text: StringView Cref;
  fileId: Int32;
  mainResult: ParserResult Ref;
} () {} [
  splittedString: splitString;
  fileId:;
  mainResult:;

  splittedString.success [

    currentPosition: PositionInfo;
    prevPosition: PositionInfo;

    currentCode: 0n32 dynamic;
    currentSymbol: StringView dynamic;

    pc: makeParserConstants;

    unfinishedPositions: PositionInfo Array;
    unfinishedLabelNames: String Array dynamic;
    unfinishedNodes: AstNodeArray Array dynamic;
    unfinishedTerminators: Nat32 Array;

    fileId          @currentPosition.@fileId set
    currentPosition @unfinishedPositions.append
    newAstNodeArray: AstNodeArray;
    currentPosition @newAstNodeArray.@positionInfo set
    @newAstNodeArray @unfinishedNodes.append

    ascii.null @unfinishedTerminators.append

    iterate
    parseNode
  ] [
    FALSE @mainResult.@success set
    ("wrong encoding, can not recognize line and column, offset in bytes: " splittedString.errorOffset) assembleString @mainResult.@errorInfo.@message set
    splittedString.errorOffset 0 cast @mainResult.@errorInfo.@position.@offsetStart set
    0 @mainResult.@errorInfo.@position.@line set
    splittedString.errorOffset 0 cast @mainResult.@errorInfo.@position.@column set
  ] if
] "parseString" exportFunction
