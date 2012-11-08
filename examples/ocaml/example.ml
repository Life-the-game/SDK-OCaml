(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: Example of usage of these modules                             *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

let _ =

  let login = "toto" in
  let user = ApiUser.get_user login in
  print_endline ("The id of the user " ^ login ^ " is " ^
		    (string_of_int user.ApiUser.id))

