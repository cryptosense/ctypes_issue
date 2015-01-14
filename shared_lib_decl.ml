open Ctypes


module RevBindings(I : Cstubs_inverted.INTERNAL) = struct

  let double =
    I.internal "xxx_double_fun" (int @-> returning int) (fun x -> x + x)

  let check =
    I.internal "check_compare" (void @-> returning void) (fun () ->
        (* make sure to use the polymorphic version *)
        let f x = compare x in
        ignore (f 1 2);

        (* check *)
        let x = "t" in
        let y = "t" in
        let res = f x y in
        Printf.printf "In dll: compare %S %S = %d\n%!" x y res;
        flush_all ();
        ()
      )

end
