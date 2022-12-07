# Copyright (C) 2021 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"Array" use
"HashTable" use
"String" use
"control" use

NameManager: [{
  virtual itemSchema: Ref; # Should have a field named "file", which is used as opaque pointer by NameManager

  createName: [
    text:;
    result: text textNameIds.find;
    result.success [result.value new] [
      string: text String same [@text] [text toString] uif;
      nameId: names.size;
      nameId 1 + @names.enlarge
      string.getStringView nameId @textNameIds.insertUnsafe # Make StringView using the source String object, reference should remain valid when we move String
      @string @names.last.@text set
      0 @names.last.!overloadCount
      0 @names.last.!localCount
      nameId
    ] if
  ];

  addItem: [
    item: nameId:;;

    current: nameId @names.at;
    item.file isNil [current.overloadCount 1 + @current.!overloadCount] when
    item.isLocal [current.localCount 1 + @current.!localCount] when
    @item @current.@items.append
  ];

  findItem: [
    index: file: nameId:;; new;
    items: nameId names.at.items;

    index -1 = [items.size !index] when
    [
      index 1 - !index
      index -1 = [
        itemFile: index items.at.file;
        itemFile isNil [file isNil] || [itemFile file is] ||
      ] || ~
    ] loop

    index
  ];

  findItemStrong: [
    index: file: nameId:;; new;
    items: nameId names.at.items;

    index -1 = [items.size !index] when
    [
      index 1 - !index
      index -1 = [
        itemFile: index items.at.file;
        file isNil [itemFile file is] ||
      ] || ~
    ] loop

    index
  ];

  hasOverload: [
    nameId: new;
    nameId @names.at.overloadCount 0 >
  ];

  hasLocalDefinition: [
    nameId: new;
    nameId @names.at.localCount 0 >
  ];

  getItem: [
    index: nameId:;;
    index nameId @names.at.@items.at
  ];

  getText: [
    nameId:;
    nameId names.at.text.getStringView
  ];

  removeItem: [
    nameId:;

    current: nameId @names.at;
    current.items.last.file isNil [current.overloadCount 1 - @current.!overloadCount] when
    current.items.last.isLocal [current.localCount 1 - @current.!localCount] when

    @current.@items.popBack

  ];

  # Private

  Name: [{
    text: String;
    items: @itemSchema Array;
    overloadCount: Int32;
    localCount: Int32;
  }];

  names: Name Array;
  textNameIds: StringView Int32 HashTable;
}];
