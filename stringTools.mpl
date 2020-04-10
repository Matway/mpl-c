"control" useModule

slice: [index: size:;; StringView same] [
  view: index: size:;;;
  size view.dataBegin storageAddress index Natx cast + Nat8 addressToReference makeStringViewRaw
] pfunc;

head: [size:; StringView same] [
  view: size:;;
  view 0 size slice
] pfunc;

tail: [size:; StringView same] [
  view: size:;;
  view view.dataSize size - size slice
] pfunc;

range: [index0: index1:;; StringView same] [
  view: index0: index1:;;;
  view index0 index1 index0 - slice
] pfunc;

unhead: [size:; StringView same] [
  view: size:;;
  view size view.dataSize size - slice
] pfunc;

untail: [size:; StringView same] [
  view: size:;;
  view 0 view.dataSize size - slice
] pfunc;
