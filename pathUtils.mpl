# Copyright (C) 2021 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"Array"     use
"String"    use
"algorithm" use
"control"   use

extractClearPath: [
  splittedPath: splitString;
  [
    splittedPath.success [
      lastPosition: -1;

      splittedPath.chars.size [
        i splittedPath.chars.at "\\" = i splittedPath.chars.at "/" = or [
          i @lastPosition set
        ] when
      ] times

      splittedPath.chars lastPosition 1 + head assembleString
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

      splittedPath.chars.size 0 > [
        position: 0 dynamic;
        fragments: String Array;
        String @fragments.append

        isCurrent: ["." =];
        isBack: [".." =];

        splittedPath.chars [
          char:;
          lastFragment: @fragments.last;

          char "\\" = char "/" = or [  # slash
            lastFragment.size 0 > [

              lastFragment isCurrent [ @fragments.popBack ] when

              lastFragment isBack
              [fragments.size 1 >] &&
              [fragments.size 2 - @fragments.at isBack ~] && [
                @fragments.popBack
                @fragments.popBack
              ] when

              String @fragments.append
            ] when
          ] [
            char @lastFragment.cat
          ] if
        ] each

        fragments.size [
          i 1 + fragments.size < [
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

simplifyFileName: [
  path: name: simplifyPath;;
  path "" = [
    @name new
  ] [
    (path "/" name) assembleString
  ] if
];

findExtensionPosition: [
  view: makeStringView;
  extensionPosition: view.size;
  i: view.size 1 -; [
    i -1 = [FALSE] [
      codeunit: view.data storageAddress i Natx cast + Nat8 addressToReference;
      codeunit 46n8 = [ # '.'
        i new !extensionPosition FALSE
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
      codeunit: view.data storageAddress i Natx cast + Nat8 addressToReference;
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

nameWithoutBadSymbols: [
  splitted: splitString;
  result: String;

  splitted.success [
    splitted.chars [
      symbol:;
      codePoint: symbol.data new;
      codePoint 48n8 < ~ [codePoint 57n8 > ~] &&         #0..9
      [codePoint 65n8 < ~ [codePoint 90n8 > ~] &&] ||    #A..Z
      [codePoint 97n8 < ~ [codePoint 122n8 > ~] &&] || [ #a..z
        symbol @result.cat
      ] when
    ] each
  ] when

  @result
];
