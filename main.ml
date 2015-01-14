
open Ctypes

let lib = Dl.dlopen ~filename:Sys.argv.(1) ~flags: [ Dl.RTLD_NOW]

let double_ext = Foreign.foreign ~from:lib ~stub:true "xxx_double_fun" (int @-> returning int)
let check_compare = Foreign.foreign ~from:lib ~stub:true "check_compare" (int @-> returning int)


let _ =
  (* make sure to use the polymorphic version *)
  let f x = compare x in
  ignore (f 1 2);

  (* check *)
  let x = "t" in
  let y = "t" in
  let res = f x y in
  Printf.printf "In main: compare %S %S = %d\n%!" x y res;
  flush_all ();
  ()

let _ =
  let x = 5 in
  let d = double_ext x in
  let expected = x + x in
  if d <> expected
  then Printf.printf "Wrong result: %d <> %d\n%!" d x
  else print_endline "We are able to use symbol from the Dll with correct result, BUT ..";
  check_compare 0 (* compare "t" "t" = -1  *)
