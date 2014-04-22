(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
(* ************************************************************************** *)

open ApiTypes

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
  lprint_endline (String.concat ", " Lang.list)

let error e =
  lprint_endline "[Error]";
  match e with
    | BadRequest r -> lprint_endline "  BadRequest";
      List.iter (function
	| Invalid (message, list) -> lprint_endline ("    Invalid: " ^ message);
	  lprint_endline ("      " ^ (String.concat ", " list))
	| Requested (message, list) -> lprint_endline ("    Requested: " ^ message);
	  lprint_endline ("      " ^ (String.concat ", " list))
      ) r
    | NotFound -> lprint_endline "  Not found"
    | NotAllowed -> lprint_endline "  NotAllowed"
    | NotAcceptable (mimetypes, languages) -> lprint_endline "  NotAcceptable";
      lprint_endline ("    Accept-media: " ^ (String.concat ", " mimetypes));
      lprint_endline ("    Accept-language: " ^ (String.concat ", " (List.map Lang.to_string languages)));
    | InternalServerError -> lprint_endline "  InternalServerError"
    | NotImplemented -> lprint_endline "  NotImplemented"
    | Client str -> lprint_endline ("  Client-side: " ^ str)
    | Unknown code -> lprint_endline ("  Unknown Error " ^ (string_of_int code))

let page l f =
  lprint_endline "[Page]";
  lprint_endline ("  Total items (server_size): " ^
                    (string_of_int l.Page.server_size));
  lprint_endline ("  Index: " ^
                    (string_of_int l.Page.index));
  lprint_endline ("  Limit: " ^
                    (string_of_int l.Page.limit));
  lprint_endline "  Items:";
  if List.length l.Page.items = 0
  then lprint_endline "    Empty page"
  else List.iter f l.Page.items

let print a =
  lprint_endline (ExtLib.dump a)

