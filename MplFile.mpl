"Mref" use
"String" use
"control" use

File: [{
  name: String;
  usedInParams: Cond;
  fileId: Int32;
  text: String;
  debugId: Int32;
  rootBlock: ["Block.BlockSchema" use BlockSchema] Mref;
}];

virtual FileSchema: File Ref;
