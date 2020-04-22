"Array.Array" use
"HashTable.HashTable" use
"String.String" use
"String.StringView" use
"String.toString" use
"control.=" use
"control.Int32" use
"control.dup" use
"control.isNil" use
"control.when" use
"control.||" use

NameManager: [{
  schema Item:; # Should have a field named "file", which is used as opaque pointer by NameManager

  createName: [
    text: dup String same [] [toString] uif;
    result: text textNameIds.find;
    result.success [result.value copy] [
      nameId: names.size;
      nameId 1 + @names.enlarge
      text.getStringView nameId @textNameIds.insertUnsafe # Make StringView using the source String object, reference should remain valid when we move String
      @text move @names.last.@text set
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
    index -1 = [items.size 1 - !index] when
    [
      index -1 = [FALSE] [
        itemFile: index items.at.file;
        itemFile isNil [itemFile file is] || [FALSE] [
          index 1 + !index
          TRUE
        ] if
      ] if
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
    items: Item Array;
  }];

  names: Name Array;
  textNameIds: StringView Int32 HashTable;
}];
