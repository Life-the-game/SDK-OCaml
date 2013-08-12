(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: Test cases                                                    *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/SDK-OCaml   *)
(* ************************************************************************** *)

open ApiTypes

(* ************************************************************************** *)
(* Library configuration                                                      *)
(* ************************************************************************** *)

let _ =
  let open ApiConf in
      verbose := true;
      base_url := "http://paysdu42.fr:2048/api/v1"

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

(* Function to display a page (give it to the test function)                  *)
let pageprint res = ApiDump.page res ApiDump.print

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
and lang = Lang.default
and firstname = "Barbara"
and lastname = "Lepage"
and gender = Gender.Female
and birthday = Date.of_string "1991-05-30"
and password = "helloworld"
and email = random_string 2 ^ "@gmail.com"
and someone_else = "db0"

(* ************************************************************************** *)
(* Test generic function                                                      *)
(* ************************************************************************** *)

let test
    ?(f = ApiDump.print) (* function to display the result of the test        *)
    ?(t = false)         (* true if the test should fail (so it's a success)  *)
    (result : 'a Api.t) : 'a Api.t =
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
  (match result with
    | Error  e -> on_error e
    | Result r -> on_result r);
  result

let auth_test
    ?(f = ApiDump.print) (* function to display the result of the test        *)
    ?(t = false)         (* true if the test should fail (so it's a success)  *)
    (test_launcher : auth -> 'a Api.t) = function
  | Error e -> print_endline "Auth test skipped"; Error e
  | Result auth ->
    test ~f:f ~t:t (test_launcher (ApiAuth.auth_to_api auth))

(* ************************************************************************** *)
(* It's testing time \o/                                                      *)
(* ************************************************************************** *)

let _ =

  ApiDump.lprint_endline "#################################################";
  ApiDump.lprint_endline "# Users tests (without auth)                    #";
  ApiDump.lprint_endline "#################################################";

  (* print_title "Create a new user"; *)
  (* test (ApiUser.create *)
  (* 	  ~login:login *)
  (* 	  ~email:email *)
  (* 	  ~password:password *)
  (* 	  ~lang:lang *)
  (* 	  ~firstname:(Some firstname) *)
  (* 	  ~lastname:(Some lastname) *)
  (* 	  ~gender:(Some gender) *)
  (* 	  ~birthday:(Some birthday) *)
  (* 	  ()); *)
  ApiDump.lprint_endline "No test";

  ApiDump.lprint_endline "\n";
  ApiDump.lprint_endline "#################################################";
  ApiDump.lprint_endline "# Authentication tests                          #";
  ApiDump.lprint_endline "#################################################";

  (* print_title "Authenticate using a login and a password"; *)
  (* let auth = test (ApiAuth.login ...); *)
  ApiDump.lprint_endline "No test";

  ApiDump.lprint_endline "\n";
  ApiDump.lprint_endline "#################################################";
  ApiDump.lprint_endline "# Achievements tests                            #";
  ApiDump.lprint_endline "#################################################";

  print_title "Get achievements";
  let page1 = test (ApiAchievement.get ~req:(Lang lang) ()) in
  (* Note: It is also possible to search through achievements using "term" *)

  print_title "Get next page of achievements";
  (match page1 with (* Check the previous page*)
    | Error e -> ApiDump.lprint_endline "The previous page failed"
    | Result page1 ->
      match Page.next page1 with (* Check if there is a next page *)
	| None -> ApiDump.lprint_endline "It was the last page"
	| Some nextpage ->
	  ignore (test (ApiAchievement.get ~req:(Lang lang)
			  ~page:nextpage ())));

  print_title "Get one achievement";
  (match page1 with (* Check if the list exists *)
    | Error e -> ApiDump.lprint_endline "The previous tests failed"
    | Result page ->
      if page.Page.server_size == 0 (* Check if there are elements to get *)
      then ApiDump.lprint_endline "No elements available"
      else ignore
	(test (ApiAchievement.get_one ~req:(Lang lang)
		 (* Get the id of the first element *)
		 ((List.hd page.Page.items).ApiAchievement.info.Info.id))));

  ApiDump.lprint_endline "\n";
  ApiDump.lprint_endline "#################################################";
  ApiDump.lprint_endline "# Users tests (with auth)                       #";
  ApiDump.lprint_endline "#################################################";

  ApiDump.lprint_endline "No test";

(* PRIVATE *)
  ApiDump.lprint_endline "\n";
  ApiDump.lprint_endline "#################################################";
  ApiDump.lprint_endline "# Roles tests                                   #";
  ApiDump.lprint_endline "#################################################";

  ApiDump.lprint_endline "No test";
(* /PRIVATE *)

  ApiDump.lprint_endline "\n";
  ApiDump.lprint_endline "#################################################";
  ApiDump.lprint_endline "# Game Network tests                            #";
  ApiDump.lprint_endline "#################################################";

  ApiDump.lprint_endline "No test";

  ApiDump.lprint_endline "\n";
  ApiDump.lprint_endline "#################################################";
  ApiDump.lprint_endline "# Achievements statuses tests                   #";
  ApiDump.lprint_endline "#################################################";

  ApiDump.lprint_endline "No test";

  ApiDump.lprint_endline "\n";
  ApiDump.lprint_endline "#################################################";
  ApiDump.lprint_endline "# Achievement statuses comments tests           #";
  ApiDump.lprint_endline "#################################################";

  ApiDump.lprint_endline "No test";

  ApiDump.lprint_endline "\n";
  ApiDump.lprint_endline "#################################################";
  ApiDump.lprint_endline "# Playground tests                              #";
  ApiDump.lprint_endline "#################################################";

  ApiDump.lprint_endline "No test";

  ApiDump.lprint_endline "\n";
  ApiDump.lprint_endline "#################################################";
  ApiDump.lprint_endline "# Feed tests                                    #";
  ApiDump.lprint_endline "#################################################";

  ApiDump.lprint_endline "No test";

  ApiDump.lprint_endline "\n";
  ApiDump.lprint_endline "#################################################";
  ApiDump.lprint_endline "# Notifications tests                           #";
  ApiDump.lprint_endline "#################################################";

  ApiDump.lprint_endline "No test";

  ApiDump.lprint_endline "\n";
  ApiDump.lprint_endline "#################################################";
  ApiDump.lprint_endline "# News tests                                    #";
  ApiDump.lprint_endline "#################################################";

  ApiDump.lprint_endline "No test";

  print_total ()
