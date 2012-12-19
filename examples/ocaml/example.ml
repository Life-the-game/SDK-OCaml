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

let print_user_id user =
  print_endline ("The id of the user " ^ login ^ " is " ^
                    string_of_int user.ApiUser.id)

let _ =

  match ApiAuth.login auth_login auth_password with
    | Api.Failure err_list -> debug_print "Auth Fail:" err_list
    | Api.Success auth     ->
      print_token auth;
      Unix.sleep 1;
      match ApiUser.get_user auth login with
        | Api.Failure err_list -> debug_print "Not Found: " err_list
        | Api.Success user     ->
          print_user_id user;
          match ApiAuth.logout auth with
            | Api.Failure err_list -> debug_print "Logout fail: " err_list
            | Api.Success auth     ->
              Unix.sleep 1;
              print_endline "Get user while logged out - should fail";
              match ApiUser.get_user auth login with
                | Api.Failure err_list -> debug_print "Not Found: " err_list
                | Api.Success user     -> print_user_id user
