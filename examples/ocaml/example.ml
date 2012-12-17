(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: Example of usage of these modules                             *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

let auth_login = "bonjour"
and auth_password = "bonjour"
and login = "db0"

let debug_print err =
  let printer (code, msg) =
    print_endline (err ^ " [" ^ (string_of_int code) ^ "] " ^ msg) in
  List.iter printer

let print_token auth =
  print_endline ("[Token] " ^ auth.ApiAuth.token)

let get_user auth login =
  let user = ApiUser.get_user auth login in
  match user with
    | Api.Failure err_list -> debug_print "Not Found: " err_list
    | Api.Success user     ->
      print_endline ("The id of the user " ^ login ^ " is " ^
                        string_of_int user.ApiUser.id)

let _ =

  let auth = ApiAuth.login auth_login auth_password in

  match auth with
    | Api.Failure err_list -> debug_print "Auth Fail:" err_list
    | Api.Success auth     -> print_token auth; get_user auth login

