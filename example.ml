(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
(* ************************************************************************** *)
(** Test cases                                                                *)

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

let impossible str =
  ApiDump.lprint_endline ("  IMPOSSIBLE to run this test because "
                          ^ str)

(* Function to display a page (give it to the test function)                  *)
let pageprint res = ApiDump.page res ApiDump.print

(* Calculate the number of success/failure to display the result at the end   *)
type result = { mutable success: int; mutable failure: int; }
let total = { success = 0; failure = 0; }

(* Print the total at the end                                                 *)
let print_total () =
  let t = string_of_int (total.success + total.failure) in
  ApiDump.lprint_endline ("
#################################################

                      T O T A L

  Success    : " ^ (string_of_int total.success) ^ " / " ^ t ^ "
  Failure    : " ^ (string_of_int total.failure) ^ " / " ^ t ^ "

#################################################

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
and message = random_string 30
and picture = ["example.png"]
and picture2 = ["example2.jpg"]
and achievement_name = random_string 15
and achievement_description = random_string 30

(* ************************************************************************** *)
(* Test generic function                                                      *)
(* ************************************************************************** *)

let test
    ?(f = ApiDump.print) (* function to display the result of the test        *)
    ?(t = "") (* not empty if the test should fail (so it's a success)        *)
    (result : 'a Api.t) : 'a Api.t =
  let _failure () = total.failure <- total.failure + 1
  and _success () = total.success <- total.success + 1 in
  let failure e = if t = "" || t != e.ApiError.stype
    then _failure () else _success ()
  and success r = if t != "" then _failure () else _success () in
  let on_error e =
    begin
      failure e;
      ApiDump.error e;
      ApiDump.lprint_endline "\n  ----> FAILURE\n";
      if stop_on_error then exit 1
    end
  and on_result r =
    begin
      success r;
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
    ?(f = ApiDump.print) ?(t = "")
    (test_launcher : auth -> 'a Api.t) = function
  | Error e -> impossible "it requires authentication that previously failed";
    Error e
  | Result auth ->
    test ~f:f ~t:t (test_launcher (ApiAuth.auth_to_api auth))

(* ************************************************************************** *)
(* It's testing time \o/                                                      *)
(* ************************************************************************** *)

let _ =

  ApiDump.lprint_endline "#################################################";
  ApiDump.lprint_endline "# Users tests (without auth)                    #";
  ApiDump.lprint_endline "#################################################";

  print_title "Create a new user";
  let user =
    test (ApiUser.create
              ~login:login
              ~email:email
              ~password:password
              ~lang:lang
              ~firstname:firstname
              ~lastname:lastname
              ~gender:gender
              ~birthday:(Some birthday)
            ~avatar:picture
              ()) in

  ApiDump.lprint_endline "\n";
  ApiDump.lprint_endline "#################################################";
  ApiDump.lprint_endline "# Authentication tests                          #";
  ApiDump.lprint_endline "#################################################";

  print_title "Authenticate using a login and a password";
  let auth = test (ApiAuth.login login password) in

  ApiDump.lprint_endline "\n";
  ApiDump.lprint_endline "#################################################";
  ApiDump.lprint_endline "# Achievements tests                            #";
  ApiDump.lprint_endline "#################################################";

(* PRIVATE *)
  print_title "Create an achievement";
  ignore (auth_test (fun auth ->
    ApiAchievement.create ~auth:auth ~name:achievement_name
      ~description:achievement_description ~badge:picture
      ~keywords:["hello"; "world"] ()) auth);
(* /PRIVATE *)

  print_title "Get achievements";
  let achievements = test ~f:pageprint (ApiAchievement.get ~req:(Lang lang) ()) in
  (* Note: It is also possible to search through achievements using "term" *)

  print_title "Get next page of achievements";
  (match achievements with (* Check the previous page*)
    | Error e -> impossible "the previous page failed"
    | Result achievements ->
      match Page.next achievements with (* Check if there is a next page *)
        | None -> ApiDump.lprint_endline "It was the last page"
        | Some nextpage ->
          ignore (test ~f:pageprint (ApiAchievement.get ~req:(Lang lang)
                                       ~page:nextpage ())));

  print_title "Get one achievement";
  (match achievements with (* Check if the list exists *)
    | Error e -> impossible "the previous tests failed"
    | Result page ->
      if page.Page.server_size == 0 (* Check if there are elements to get *)
      then ApiDump.lprint_endline "No elements available"
      else
        let achievement_id =
          (List.hd page.Page.items).ApiAchievement.info.Info.id in
        ignore (test (ApiAchievement.get_one
                        ~req:(Lang lang) achievement_id)));

  ApiDump.lprint_endline "\n";
  ApiDump.lprint_endline "#################################################";
  ApiDump.lprint_endline "# Users tests (with auth)                       #";
  ApiDump.lprint_endline "#################################################";

  print_title "Get users";
  let users = auth_test (fun auth ->
    ApiUser.get ~auth:auth ~term:["th"] ()) auth in

  print_title "Get one user...";
  (match users with (* Check if the list exists *)
    | Error e -> impossible "the previous tests failed"
    | Result page ->
      if page.Page.server_size == 0 (* Check if there are elements to get *)
      then ApiDump.lprint_endline "No elements available"
      else
        let user_id = (List.hd page.Page.items).ApiUser.info.Info.id in

  print_title "with auth";
        ignore (auth_test (fun auth ->
          (ApiUser.get_one ~auth:(Some auth) user_id)) auth);

  print_title "without auth";
        ignore (test (ApiUser.get_one user_id)); ());

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

  print_title "Create an achievement status";
  (match achievements with (* Check if some achievements exists *)
    | Error e -> impossible "previously failed to get achievements"
    | Result page ->
      if page.Page.server_size == 0 (* Check if there are elements to get *)
      then ApiDump.lprint_endline "there's no achievement available"
      else
        let achievement_id =
          (List.hd page.Page.items).ApiAchievement.info.Info.id in
        ignore (auth_test (fun auth ->
          ApiAchievementStatus.create ~auth:auth
            ~achievement:achievement_id
            ~status:ApiAchievementStatus.Status.Objective
            ~message:message ()) auth));

  print_title "Get my objectives ordered by name limit 2 with auth";
  let achievements_statuses =
    auth_test ~f:pageprint (fun auth ->
      ApiAchievementStatus.get
        ~req:(Auth auth)
        ~page:(None, Some 2, Some Page.Alphabetic, None)
        ~status:(Some ApiAchievementStatus.Status.Objective)
        login) auth in

  print_title "Get one achievement status...";
  (match achievements_statuses with (* Check if the list exists *)
    | Error e -> impossible "the previous tests failed"
    | Result page ->
      if page.Page.server_size == 0 (* Check if there are elements to get *)
      then ApiDump.lprint_endline "there's no elements available"
      else
        (match user with
          | Error e -> impossible "the user has not been created"
          | Result user ->
            let achievement_status_id =
              (List.hd page.Page.items).ApiAchievementStatus.info.Info.id
            and user_id = user.ApiUser.info.Info.id in

  print_title "with auth";
            ignore (auth_test (fun auth ->
              ApiAchievementStatus.get_one ~req:(Auth auth)
                user_id achievement_status_id) auth);

  print_title "with lang";
            ignore (test (ApiAchievementStatus.get_one ~req:(Lang lang)
                            user_id achievement_status_id));

  print_title "Unlock this ojective + add pictures + remove message";
            ignore (auth_test (fun auth ->
              ApiAchievementStatus.edit ~auth:auth
                ~status:(Some ApiAchievementStatus.Status.Achieved)
                ~message:(Some "")
                ~add_medias:[picture; picture2]
                achievement_status_id) auth);
        ));

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

  ApiDump.lprint_endline "\n";
  ApiDump.lprint_endline "#################################################";
  ApiDump.lprint_endline "# Client Errors tests                           #";
  ApiDump.lprint_endline "#################################################";

  print_title "Invalid file format";
  (match achievements_statuses with (* Check if the list exists *)
    | Error e -> impossible "the previous achievement_status tests failed"
    | Result page ->
      if page.Page.server_size == 0 (* Check if there are elements to get *)
      then ApiDump.lprint_endline "there's no elements available"
      else
        let achievement_status_id =
          (List.hd page.Page.items).ApiAchievementStatus.info.Info.id in
        ignore (auth_test ~t:"CLIENT_InvalidFileFormat" (fun auth ->
          ApiAchievementStatus.edit ~auth:auth
            ~add_medias:[["hack.sh"]] achievement_status_id) auth));

  ApiDump.lprint_endline "#################################################";
  ApiDump.lprint_endline "# Logout                                        #";
  ApiDump.lprint_endline "#################################################";

  print_title "Logout (remove token)";
  ignore (match auth with
    | Error e -> impossible "it requires authentication that previously failed";
      Error e
    | Result auth -> test (ApiAuth.logout auth));

  print_total ()
