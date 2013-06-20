(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: Test cases                                                    *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Library configuration                                                      *)
(* ************************************************************************** *)

let _ =
  let open ApiConf in
      verbose := true;
      base_url := "http://paysdu42.fr:2048/api/v1";
      set_all_output "test.txt"

(* ************************************************************************** *)
(* Tests configuration                                                        *)
(* ************************************************************************** *)

let print_success = true
let stop_on_error = false

(* ************************************************************************** *)
(* Tools                                                                      *)
(* ************************************************************************** *)

(* Generate a random string with the given lenght                             *)
let random_string (length : int) : string =
  let _ = Random.self_init () in
  let gen () =
    match Random.int (26 + 26 + 10) with
      | n when n < 26      -> int_of_char 'a' + n
      | n when n < 26 + 26 -> int_of_char 'A' + n - 26
      | n                  -> int_of_char '0' + n - 26 - 26 in
  let gen _ = String.make 1 (char_of_int (gen ())) in
    String.concat "" (Array.to_list (Array.init length gen))

(* Display the message that explains the test                                 *)
let print_title str =
  ApiDump.lprint_endline ("\n\n\n## " ^ str)

(* Function to display a list (give it to the test function)                  *)
let listprint res = ApiDump.list res ApiDump.print

(* Calculate the number of success/failure to display the result at the end   *)
type result = { mutable success: int; mutable failure: int; }
let total = { success = 0; failure = 0; }

(* Print the total at the end                                                 *)
let print_total () =
  let t = string_of_int (total.success + total.failure) in
  ApiDump.lprint_endline ("
####################################################

                      T O T A L

  Success    : " ^ (string_of_int total.success) ^ " / " ^ t ^ "
  Failure    : " ^ (string_of_int total.failure) ^ " / " ^ t ^ "

####################################################

")

(* ************************************************************************** *)
(* Data used by the tests                                                     *)
(* ************************************************************************** *)

let login = random_string 5
and lang = ApiTypes.Lang.default
and firstname = "Barbara"
and lastname = "Lepage"
and gender = ApiTypes.Gender.Female
and birthday = ApiTypes.Date.of_string "1991-05-30"
and password = "helloworld"
and email = random_string 2 ^ "@gmail.com"
and auth = ref (ApiTypes.Error ApiError.generic)
and someone_else = "db0"

(* ************************************************************************** *)
(* Test generic function                                                      *)
(* ************************************************************************** *)

let test
    ?(f = ApiDump.print) (* function to display the result of the test        *)
    ?(t = false)         (* true if the test should fail (so it's a success)  *)
    (result : 'a Api.t) : unit =
  let _failure () = total.failure <- total.failure + 1
  and _success () = total.success <- total.success + 1 in
  let failure () = if t then _success () else _failure ()
  and success () = if t then _failure () else _success () in
  let on_error e =
    begin
      failure ();
      ApiDump.error e;
      ApiDump.lprint_endline "\n  ----> FAILURE\n";
      if stop_on_error then exit 1
    end
  and on_result r =
    begin
      success ();
      if print_success
      then ApiDump.lprint_endline "\n  ## OCaml object generated:\n";
      f r;
      ApiDump.lprint_endline "\n  ----> SUCCESS\n"
    end in
  match result with
    | ApiTypes.Error  e -> on_error e
    | ApiTypes.Result r -> on_result r

(* ************************************************************************** *)
(* It's testing time \o/                                                      *)
(* ************************************************************************** *)

let test_with_auth auth =
  let auth = match auth with
  | ApiTypes.Error e -> ApiTypes.Curl (login, password)
  | ApiTypes.Result auth -> ApiTypes.Token auth.ApiAuth.token in
  begin
    print_title "Get my tokens";
    test ~f:listprint (ApiAuth.get_user ~auth:auth login);

    print_title "Add an achievement";
    test (ApiAchievement.post
            ~auth:auth
            ~name:(random_string 5)
            ~description:(Some (random_string 10))
            ());

    (* print_title "Get users"; *)
    (* test  ~f:listprint (ApiUser.get ~auth:auth *)
    (*                       ~term:(Some "a") ~limit:(Some 2) ()); *)

    (* print_title "Get one user"; *)
    (* test (ApiUser.get_user ~auth:(Some auth) login); *)

(*     print_title "Delete a user (myself)"; *)
(*     test (ApiUser.delete ~auth:auth login); *)

(*     print_title "Get the user I just deleted (should fail because the \ *)
(* auth token should not exists anymore)"; *)
(*     test ~t:true (ApiUser.get_user ~auth:(Some auth) login); *)

    (* print_title "Get my own authentication tokens"; *)
    (* test ~f:listprint (ApiAuth.get auth); *)

    (* print_title "Get someone else's authentication tokens"; *)
    (* test ~f:listprint (ApiAuth.get_user ~auth:auth someone_else); *)

    ApiDump.lprint_endline "End of auth test"
  end

let _ =

  print_title "Get achievements without being logged in";
  test ~f:listprint (ApiAchievement.get ~lang:(Some lang) ());

  (* print_title "Get one user without login"; *)
  (* test (ApiUser.get_user ~lang:(Some lang) someone_else); *)

  print_title "Create a new user";
  test (ApiUser.create
          ~login:login
          ~email:email
          ~password:password
          ~lang:lang
          ~firstname:(Some firstname)
          ~lastname:(Some lastname)
          ~gender:(Some gender)
          ~birthday:(Some birthday)
          ());

  print_title "Get an authentication token using this user";
  test (let _auth = ApiAuth.login login password in
        auth := _auth; _auth);

  test_with_auth !auth;

(*   print_title "Get the user I just deleted (should fail because the \ *)
(* user does not exists anymore)"; *)
(*   test ~t:true (ApiUser.get_user ~lang:(Some lang) login); *)

  print_total ()
