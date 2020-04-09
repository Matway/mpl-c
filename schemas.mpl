"control" includeModule
"String" includeModule

makeVariableSchema: [
  var:;
  varSchema: VariableSchema;
  var.data.getTag (
    VarImport [
      VariableSchemaTags.FUNCTION_SCHEMA @varSchema.@data.setTag
      functionSchema: VariableSchemaTags.FUNCTION_SCHEMA @varSchema.@data.get;
      functionId: VarImport var.data.get;
      node: functionId processor.nodes.at.get;
      signature: node.csignature;
      signature.inputs.getSize @functionSchema.@inputSchemaIds.resize
      signature.inputs.getSize [
        i signature.inputs @ getVar.mplSchemaId copy i @functionSchema.@inputSchemaIds !
      ] times

      signature.outputs.getSize @functionSchema.@outputSchemaIds.resize
      signature.outputs.getSize [
        i signature.outputs @ getVar.mplSchemaId copy i @functionSchema.@outputSchemaIds !
      ] times

      signature.variadic copy @functionSchema.!variadic
      signature.convention copy @functionSchema.!convention
    ]
    VarRef [
      VariableSchemaTags.REF_SCHEMA @varSchema.@data.setTag
      refSchema: VariableSchemaTags.REF_SCHEMA @varSchema.@data.get;
      ref: VarRef var.data.get;
      pointee: ref getVar;
      ref.mutable copy @refSchema.!mutable
      pointee.mplSchemaId copy @refSchema.!pointeeSchemaId
    ]
    VarStruct [
      VariableSchemaTags.STRUCT_SCHEMA @varSchema.@data.setTag
      structSchema: VariableSchemaTags.STRUCT_SCHEMA @varSchema.@data.get;
      struct: VarStruct var.data.get.get;
      struct.fields.getSize @structSchema.@data.resize
      struct.fields.getSize [
        field: i struct.fields @;
        fieldSchema: FieldSchema;
        field.refToVar getVar.mplSchemaId @fieldSchema.@valueSchemaId set
        field.nameInfo copy @fieldSchema.!nameInfo
        @fieldSchema i @structSchema.@data @ set
      ] times
    ]
    [
      VariableSchemaTags.BUILTIN_TYPE_SCHEMA @varSchema.@data.setTag
      builtinTypeSchema: VariableSchemaTags.BUILTIN_TYPE_SCHEMA @varSchema.@data.get;
      var.data.getTag @builtinTypeSchema.@tag set
    ]
  ) case

  refToVar isVirtual [
    schemaId: varSchema getVariableSchemaId;
    VariableSchemaTags.VIRTUAL_VALUE_SCHEMA @varSchema.@data.setTag
    virtualValueSchema: VariableSchemaTags.VIRTUAL_VALUE_SCHEMA @varSchema.@data.get;
    schemaId copy @virtualValueSchema.!schemaId
    refToVar getVirtualValue @virtualValueSchema.!vitrualValue
  ] when

  @varSchema
];

getVariableSchemaId: [
  varSchemaIsMoved: isMoved;
  varSchema:;
  findResult: varSchema processor.schemaTable.find;
  findResult.success [
    findResult.value copy
  ] [
    schemaId: processor.schemaBuffer.getSize;
    varSchema schemaId @processor.@schemaTable.insert
    @varSchema varSchemaIsMoved moveIf @processor.@schemaBuffer.pushBack
    schemaId copy
  ] if
];

VariableSchema: [{
  VARIABLE_SCHEMA: ();
  irTypeId: -1;
  dbgTypeId: -1;
  dbgTypeDeclarationId: -1;
  data: (
    BuiltinTypeSchema
    FunctionSchema
    RefSchema
    StructSchema
    VirtualValueSchema
  ) Variant;
}];

VariableSchemaTags: (
  "BUILTIN_TYPE_SCHEMA"
  "FUNCTION_SCHEMA"
  "REF_SCHEMA"
  "STRUCT_SCHEMA"
  "VIRTUAL_VALUE_SCHEMA"
) Int32 enum;

BuiltinTypeSchema: [{
  BUILTIN_TYPE_SCHEMA: ();
  tag: Int32;
}];

RefSchema: [{
  REF_SCHEMA: ();
  pointeeSchemaId: Int32;
  mutable: Cond;
}];

FieldSchema: [{
  FIELD_SCHEMA: ();
  nameInfo: Int32;
  valueSchemaId: Int32;
}];

FunctionSchema: [{
  FUNCTION_SCHEMA: ();
  inputSchemaIds: Int32 Array;
  outputSchemaIds: Int32 Array;
  convention: String;
  variadic: Cond;
}];

VirtualValueSchema: [{
  VIRTUAL_VALUE_SCHEMA: ();
  schemaId: Int32;
  vitrualValue: String;
}];

StructSchema: [{
  STRUCT_SCHEMA: ();
  data: FieldSchema Array;
}];

twoWith: [
  predicate:;
  x:y:;;
  @x predicate
  @y predicate and
];

=: [["VARIABLE_SCHEMA" has] twoWith] [
  x: .data;
  y: .data;
  tag: x.getTag;
  tag y.getTag = [
    tag (
      VariableSchemaTags fieldCount [
        i copy i copy [
          tag:;
          tag x.get
          tag y.get =
        ] bind
      ] times
      [
        [FALSE] "invalid tag in VariableSchema" assert
        FALSE
      ]
    ) case
  ] [
    FALSE
  ] if
] pfunc;

=: [["REF_SCHEMA" has] twoWith] [
  x:y:;;
  x.pointeeSchemaId y.pointeeSchemaId = [x.mutable y.mutable =] &&
] pfunc;

=: [["STRUCT_SCHEMA" has] twoWith] [
  x: .data;
  y: .data;
  result: x.getSize y.getSize =;
  fieldIndex0: 0;
  [result [fieldIndex0 x.getSize <] &&] [
    fieldIndex0 x @ fieldIndex0 y @ = !result
    fieldIndex0 1 + !fieldIndex0
  ] while

  result
] pfunc;

=: [["FIELD_SCHEMA" has] twoWith] [
  x:y:;;
  x.nameInfo y.nameInfo = [x.valueSchemaId y.valueSchemaId =] &&
] pfunc;

=: [["FUNCTION_SCHEMA" has] twoWith] [
  x:y:;;
  result: TRUE;
  (
    [result]
    [x.convention y.convention = !result]
    [x.variadic y.variadic = !result]
    [
      x.inputSchemaIds.getSize
      y.inputSchemaIds.getSize = !result
    ]
    [
      x.outputSchemaIds.getSize
      y.outputSchemaIds.getSize = !result
    ]
    [
      inputIndex: 0;
      [result [inputIndex x.inputSchemaIds.getSize <] &&] [
        inputIndex x.inputSchemaIds @
        inputIndex y.inputSchemaIds @ = !result
        inputIndex 1 + !inputIndex
      ] while
    ]
    [
      outputIndex: 0;
      [result [outputIndex x.outputSchemaIds.getSize <] &&] [
        outputIndex x.outputSchemaIds @
        outputIndex y.outputSchemaIds @ = !result
        outputIndex 1 + !outputIndex
      ] while
    ]
  ) sequence

  result
] pfunc;

=: [["VIRTUAL_VALUE_SCHEMA" has] twoWith] [
  x:y:;;
  x.schemaId y.schemaId = [x.vitrualValue y.vitrualValue =] &&
] pfunc;

=: [["BUILTIN_TYPE_SCHEMA" has] twoWith] [
  x:;
  y:;
  x.tag y.tag =
] pfunc;

hash: ["VARIABLE_SCHEMA" has] [
  variableSchema: .data;
  seed: 0n32;
  @seed variableSchema.getTag hashCombine
  variableSchema [value:; @seed value hashSchema] visit
  @seed
] pfunc;

hashSchema: ["FIELD_SCHEMA" has] [
  fieldSchema:;
  seed:;
  @seed fieldSchema.nameInfo hashCombine
  @seed fieldSchema.valueSchemaId hashCombine
] pfunc;

hashSchema: ["REF_SCHEMA" has] [
  refSchema:;
  seed:;
  @seed refSchema.pointeeSchemaId hashCombine
  @seed refSchema.mutable hashCombine
] pfunc;

hashSchema: ["FUNCTION_SCHEMA" has] [
  functionSchema:;
  seed:;
  functionSchema.inputSchemaIds [
    value:;
    @seed value hashCombine
  ] each

  functionSchema.outputSchemaIds [
    value:;
    @seed value hashCombine
  ] each

  @seed functionSchema.convention hash hashCombine
  @seed functionSchema.variadic hashCombine
] pfunc;

hashSchema: ["VIRTUAL_VALUE_SCHEMA" has] [
  virtualValueSchema:;
  seed:;
  @seed virtualValueSchema.schemaId hashCombine
  @seed virtualValueSchema.vitrualValue hash hashCombine
] pfunc;

hashSchema: ["STRUCT_SCHEMA" has] [
  structSchema: .data;
  seed:;
  structSchema [
    value:;
    @seed value hashSchema
  ] each
] pfunc;

hashSchema: ["BUILTIN_TYPE_SCHEMA" has] [.tag Nat32 cast hashCombine] pfunc;

visit: [
  variant:callback:;;
  variant.getTag (
    variant.typeList fieldCount [
      i copy i copy [@variant.get callback] bind
    ] times

    ["invalid tag in variant" failProc]
  ) case
];

hashCombine: [
  seed:value:;;
  value hashValue 0x9e3779b9n32 + seed 6n32 lshift + seed 2n32 rshift + @seed set
];

hashValue: [Int8 same] [Nat32 cast] pfunc;
hashValue: [Int16 same] [Nat32 cast] pfunc;
hashValue: [Int32 same] [Nat32 cast] pfunc;
hashValue: [Int64 same] [Nat64 cast Nat32 cast] pfunc;
hashValue: [IntX same] [Nat64 cast Nat32 cast] pfunc;
hashValue: [Nat8 same] [Nat32 cast] pfunc;
hashValue: [Nat16 same] [Nat32 cast] pfunc;
hashValue: [Nat32 same] [Nat32 cast] pfunc;
hashValue: [Nat32 same] [Nat32 cast] pfunc;
hashValue: [Nat64 same] [Nat32 cast] pfunc;
hashValue: [NatX same] [Nat32 cast] pfunc;
hashValue: [Cond same] [[1n32] [0n32] if] pfunc;
