"Array.Array" use
"Array.makeSubRange" use
"String.String" use
"String.assembleString" use
"String.makeStringView" use
"String.splitString" use
"control" use

extractClearPath: [
  splittedPath: splitString;
  [
    splittedPath.success [
      position: 0;
      lastPosition: -1;

      splittedPath.chars.getSize [
        i splittedPath.chars.at "\\" = i splittedPath.chars.at "/" = or [
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
            lastFragment.size 0 > [

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
            i fragments.at @resultPath.cat
          ] [
            i fragments.at @resultFileName.cat
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

findExtensionPosition: [
  view: makeStringView;
  extensionPosition: view.size copy;
  i: view.size 1 -; [
    i -1 = [FALSE] [
      codeunit: view.data i Natx cast + Nat8 addressToReference;
      codeunit 46n8 = [ # '.'
        i copy !extensionPosition FALSE
      ] [
        codeunit 47n8 = [codeunit 92n8 =] || [FALSE] [ # '/' or '\\'
          i 1 - !i TRUE
        ] if
      ] if
    ] if
  ] loop

  extensionPosition
];

findFilenamePosition: [
  view: makeStringView;
  filenamePosition: 0;
  i: view.size 1 -; [
    i -1 = [FALSE] [
      codeunit: view.data i Natx cast + Nat8 addressToReference;
      codeunit 47n8 = [codeunit 92n8 =] || [ # '/' or '\\'
        i 1 + !filenamePosition FALSE
      ] [
        i 1 - !i TRUE
      ] if
    ] if
  ] loop

  filenamePosition
];

extractExtension: [
  view: makeStringView;
  view view findExtensionPosition 1 + view.size min unhead
];

extractFilename: [
  view: makeStringView;
  view view findFilenamePosition unhead
];

stripExtension: [
  view: makeStringView;
  view view findExtensionPosition head
];

stripFilename: [
  view: makeStringView;
  view view findFilenamePosition 1 - 0 max head
];
