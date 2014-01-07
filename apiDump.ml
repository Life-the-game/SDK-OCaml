(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Tools                                                                      *)
(* ************************************************************************** *)

let lprint_string str = output_string !ApiConf.dump_output str
let lprint_endline str = lprint_string (str ^ "\n"); flush_all ()

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

let page l f =
  lprint_endline "[Page]";
  lprint_endline ("  Total items (server_size): " ^
                    (string_of_int l.ApiTypes.Page.server_size));
  lprint_endline ("  Index: " ^
                    (string_of_int l.ApiTypes.Page.index));
  lprint_endline ("  Limit: " ^
                    (string_of_int l.ApiTypes.Page.limit));
  lprint_endline "  Items:";
  if List.length l.ApiTypes.Page.items = 0
  then lprint_endline "    Empty page"
  else List.iter f l.ApiTypes.Page.items

let print a =
  lprint_endline (ExtLib.dump a)

