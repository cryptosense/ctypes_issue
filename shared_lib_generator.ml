(* generator *)

open Format

let with_formatter filename f =
  let fd = open_out filename in
  let fmt = formatter_of_out_channel fd in
  f fmt;
  close_out fd

let () =
  begin
    let filename_prefix = Sys.argv.(1) in
    let file ext = filename_prefix ^ ext in
    let prefix = "shared_lib" in
    let stubs_c = file "_stubs.c" in
    let ml = file ".ml" in
    let outl fmt l = List.iter (Format.fprintf fmt "%s\n") l in

    with_formatter stubs_c (fun fmt ->
        Cstubs_inverted.write_c fmt ~prefix (module Shared_lib_decl.RevBindings);

        (* initialization of the dll *)
        (* We must initialize the caml runtime *)
        let all s = s in
        outl fmt [
          all"#define _GNU_SOURCE";
          (* Setting _GNU_SOURCE doesn't seems to work.
             So we need to set __USE_GNU *)
          all"#define __USE_GNU";
          all"#include <dlfcn.h>";
          all"#include <string.h>";
          all "#include <stdio.h>";
          all "#include <caml/fail.h>";


          (* initialization function *)
          all "static void initialize_ocaml_runtime(){";
          all "  char *caml_argv[1] = { NULL };";
          all "  caml_startup(caml_argv);";
          all "}";

          (* inialization for linux *)
          all"__attribute__((constructor))";
          all"static void initialize_dll(){";
          all"  initialize_ocaml_runtime();";
          all"}";
        ]
      );
    with_formatter ml (fun fmt ->
        Cstubs_inverted.write_ml fmt ~prefix (module Shared_lib_decl.RevBindings)
      );
  end
