"Mref.Mref" use
"String.String" use
"control" use

File: [{
  name: String;
  text: String;
  debugId: Int32;
  rootBlock: ["Block.BlockSchema" use BlockSchema] Mref;
}];

virtual FileSchema: File Ref;
