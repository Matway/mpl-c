"Array.Array" use
"HashTable.HashTable" use
"HashTable.hash" use
"String.String" use
"String.StringView" use
"String.hash" use
"String.toString" use
"control" use

NameManager: [{
  virtual itemSchema: Ref; # Should have a field named "file", which is used as opaque pointer by NameManager

  createName: [
    text:;
    result: text textNameIds.find;
    result.success [result.value copy] [
      string: text String same [@text] [text toString] uif;
      nameId: names.size;
      nameId 1 + @names.enlarge
      string.getStringView nameId @textNameIds.insertUnsafe # Make StringView using the source String object, reference should remain valid when we move String
      @string move @names.last.@text set
      nameId
    ] if
  ];

  addItem: [
    item: nameId:;;

    @item move nameId @names.at.@items.pushBack
  ];

  findItem: [
    index: file: nameId:;; copy;
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

    nameId @names.at.@items.popBack
  ];

  # Private

  Name: [{
    text: String;
    items: @itemSchema Array;
  }];

  names: Name Array;
  textNameIds: StringView Int32 HashTable;
}];
