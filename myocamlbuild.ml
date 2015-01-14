let mark_tag_used _ = ()

open Ocamlbuild_plugin

let _ = Options.use_ocamlfind := true
let _ = Options.hygiene := false
let os = match Sys.os_type with
  | "Unix" -> `Linux
  | "Win32" | "Cygwin" -> `Win
  | _ -> failwith "Unknown OS"
(* Copy/Pasted/Updated from ocamlbuild/ocaml_specific.ml *)
module C_tools = struct
  let link_dll clib dll env build =
    let clib = env clib and dll = env dll in
    let objs = string_list_of_file clib in
    let include_dirs = Pathname.include_dirs_of (Pathname.dirname dll) in
    let obj_of_o x =
      if Filename.check_suffix x ".o" && !Options.ext_obj <> "o" then
        Pathname.update_extension !Options.ext_obj x
      else x in
    let resluts = build (List.map (fun o -> List.map (fun dir -> dir / obj_of_o o) include_dirs) objs) in
    let objs = List.map begin function
      | Outcome.Good o -> o
      | Outcome.Bad exn -> raise exn
    end resluts in
    Cmd(S[!Options.ocamlopt; A"-o"; Px dll; T(tags_of_pathname dll++"c"++"dll"++"ocaml"++"link"++"native"++"output_obj"); Command.atomize objs]);;
  let _ = flag ["ocaml"; "link"; "dll"] & A"-linkpkg"
end

let after_rules () =
  (* Somehow Options.ext_dll may be wrong *)
  let ext_dll = match os with
    | `Win -> "dll"
    | `Linux -> "so" in

  (* include ctypes lib path so ctypes generated files can see ctypes' headers *)
  let ocaml_ctypes_lib_path = Filename.dirname (Findlib.((query "ctypes").location)) in
  flag ["compile"; "c"] (S [A "-I"; A "."; A "-I"; P ocaml_ctypes_lib_path]);

  (* generate a Dll from a lib*.clib file *)
  rule "dll: clib & (o|obj)* -> (so|dll)"
    ~prod:("%(path:<**/>)dll%(libname:<*> and not <*.*>)"-.- ext_dll)
    ~dep:"%(path)lib%(libname).clib"
    ~insert:`top
    (C_tools.link_dll "%(path)lib%(libname).clib" ("%(path)dll%(libname)"-.- ext_dll));

  (* TODO: DOCUMENT *)
  let ctypes_generator name base : unit =
    rule ("ctypes generator: " ^ name)
      ~dep:"%(name)_generator.native"
      ~prods:[ base -.- "ml";
               base ^ "_stubs.c";
             ]
      (fun env build ->
         let exe = env "./%(name)_generator.native" in
         let arg = env "%(name)" in
         Cmd (S [P exe; A arg])
      ) in
  ctypes_generator "from *_generator.ml" "%(name: <*> and not <*_generator>)";
  ctypes_generator "from **/*_generator.ml" "%(name: <**/*> and not <**/*_generator>)";

  ()

let () = dispatch (function After_rules -> after_rules () | _ -> ())
