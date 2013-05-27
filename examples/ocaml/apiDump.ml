(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: Module to pretty print the values returned by the API library *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Tools                                                                      *)
(* ************************************************************************** *)

let lprint_string str = output_string !ApiConf.dump_output str
let lprint_endline str = lprint_string (str ^ "\n")

let verbose str =
  if !ApiConf.verbose
  then output_string !ApiConf.verbose_output (str ^ "\n")

(* ************************************************************************** *)
(* Dump results in a human readable format                                    *)
(* ************************************************************************** *)

let available_languages () =
  lprint_string "  Available languages: ";
  lprint_endline (String.concat ", " ApiTypes.Lang.list)

let error e =
  let open ApiError in
      lprint_endline "[Error]";
      lprint_endline ("  Message: " ^ e.message);
      lprint_endline ("  Type: " ^ e.stype);
      lprint_endline ("  Code: " ^ (string_of_int e.code))

let list l f =
  lprint_endline "[List]";
  lprint_endline ("  Total items (server_size): " ^
		    (string_of_int l.ApiTypes.List.server_size));
  lprint_endline ("  Index: " ^
		    (string_of_int l.ApiTypes.List.index));
  lprint_endline ("  Limit: " ^
		    (string_of_int l.ApiTypes.List.limit));
  lprint_endline "  Items:";
  if List.length l.ApiTypes.List.items = 0
  then lprint_endline "    Empty list"
  else List.iter f l.ApiTypes.List.items

let print a =
  lprint_endline (ExtLib.dump a)

