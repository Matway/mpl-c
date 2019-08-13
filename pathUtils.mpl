"pathUtils" module
"control" useModule

extractClearPath: [
  splittedPath: makeStringView.split;
  [
    splittedPath.success [
      position: 0;
      lastPosition: -1;

      splittedPath.chars [
        pair:;
        pair.value "\\" = pair.value "/" = or [
          pair.index @lastPosition set
        ] when
      ] each

      position lastPosition 1 + splittedPath.chars makeSubRange assembleString
    ] [
      String
    ] if
  ] call
];

simplifyPath: [
  splittedPath: makeStringView.split;
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
          pair:;
          lastFragment: @fragments.last;

          pair.value "\\" = pair.value "/" = or [  # slash
            lastFragment textSize 0nx > [

              lastFragment isCurrent [ @fragments.popBack ] when

              lastFragment isBack
              [fragments.getSize 1 >] &&
              [fragments.getSize 2 - @fragments.at isBack not] && [
                @fragments.popBack
                @fragments.popBack
              ] when

              String @fragments.pushBack
            ] when
          ] [
            pair.value @lastFragment.cat
          ] if
        ] each

        fragments [
          pair:;
          i: pair.index copy;
          i 1 + fragments.dataSize < [
            i 0 > ["/" @resultPath.cat] when
            pair.value @resultPath.cat
          ] [
            pair.value @resultFileName.cat
          ] if
        ] each
      ] when

      @resultPath
      @resultFileName
    ] [
      String String
    ] if
  ] call
];
