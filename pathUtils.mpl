"control" useModule

extractClearPath: [
  splittedPath: splitString;
  [
    splittedPath.success [
      position: 0;
      lastPosition: -1;

      splittedPath.chars.getSize [
        i splittedPath.chars @ "\\" = i splittedPath.chars @ "/" = or [
          i @lastPosition set
        ] when
      ] times

      position lastPosition 1 + splittedPath.chars makeSubRange assembleString
    ] [
      String
    ] if
  ] call
];

simplifyPath: [
  splittedPath: splitString;
  [
    splittedPath.success [

      resultPath: String;
      resultFileName: String;

      splittedPath.chars.dataSize 0 > [
        position: 0 dynamic;
        fragments: String Array;
        String @fragments.pushBack

        isCurrent: ["." =];
        isBack: [".." =];

        splittedPath.chars [
          char:;
          lastFragment: @fragments.last;

          char "\\" = char "/" = or [  # slash
            lastFragment textSize 0nx > [

              lastFragment isCurrent [ @fragments.popBack ] when

              lastFragment isBack
              [fragments.getSize 1 >] &&
              [fragments.getSize 2 - @fragments.at isBack ~] && [
                @fragments.popBack
                @fragments.popBack
              ] when

              String @fragments.pushBack
            ] when
          ] [
            char @lastFragment.cat
          ] if
        ] each

        fragments.getSize [
          i 1 + fragments.dataSize < [
            i 0 > ["/" @resultPath.cat] when
            i fragments @ @resultPath.cat
          ] [
            i fragments @ @resultFileName.cat
          ] if
        ] times
      ] when

      @resultPath
      @resultFileName
    ] [
      String String
    ] if
  ] call
];

stripExtension: [
  splitResult: splitString;
  splitResult.success [
    extensionPosition: splitResult.chars.getSize;
    splitResult.chars.getSize [
      i splitResult.chars @ "/" = [i splitResult.chars @ "\\" =] || [
        splitResult.chars.getSize !extensionPosition
      ] [
        i splitResult.chars @ "." = [
          i copy !extensionPosition
        ] when
      ] if
    ] times

    0 extensionPosition splitResult.chars makeSubRange assembleString
  ] [
    String
  ] if
];

stripPath: [
  splitResult: splitString;
  splitResult.success [
    filePosition: 0;
    splitResult.chars.getSize [
      i splitResult.chars @ "/" = [i splitResult.chars @ "\\" =] || [
        i 1 + !filePosition
      ] when
    ] times

    filePosition splitResult.chars.getSize splitResult.chars makeSubRange assembleString
  ] [
    String
  ] if
];
