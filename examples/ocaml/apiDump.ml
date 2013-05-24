(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: Module to pretty print the values returned by the API library *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Dump results in a human readable format                                    *)
(* ************************************************************************** *)

let available_languages () =
  print_string "  Available languages: ";
  print_endline (String.concat ", " ApiTypes.Lang.list)

let error e =
  let open ApiError in
      print_endline "[Error]";
      print_endline ("  Message: " ^ e.message);
      print_endline ("  Type: " ^ e.stype);
      print_endline ("  Code: " ^ (string_of_int e.code))

let list l f =
  print_endline "[List]";
  print_endline ("  Total items (server_size): " ^
		    (string_of_int l.ApiTypes.List.server_size));
  print_endline ("  Index: " ^
		    (string_of_int l.ApiTypes.List.index));
  print_endline ("  Limit: " ^
		    (string_of_int l.ApiTypes.List.limit));
  print_endline "  Items:";
  if List.length l.ApiTypes.List.items = 0
  then print_endline "    Empty list"
  else List.iter f l.ApiTypes.List.items

let print a =
  print_endline (ExtLib.dump a)

