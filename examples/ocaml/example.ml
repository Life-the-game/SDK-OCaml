(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: Test cases                                                    *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

let print_success = true
let stop_on_error = false

(* ************************************************************************** *)

let _ =
  let open ApiConf in
      verbose := false;
      base_url := "http://paysdu42.fr:2048/api/v1"

(* ************************************************************************** *)

type result = { mutable success: int; mutable failure: int; }
let total = { success = 0; failure = 0; }

let test ?(f = ApiDump.print) = function
  | ApiTypes.Error e -> total.failure <- total.failure + 1;
    ApiDump.error e; if stop_on_error then exit 1
  | ApiTypes.Result res -> total.success <- total.success + 1;
    if print_success
    then f res else ApiDump.lprint_endline "OK"

let test_list = test ~f:(fun res -> ApiDump.list res ApiDump.print)

let _ =

  let login = "db0"
  and lang = ApiTypes.Lang.default
  and firstname = "Barbara"
  and lastname = "Lepage"
  and gender = ApiTypes.Gender.Female
  and birthday = ApiTypes.Date.of_string "1991-05-30"
  and password = "helloworld"
  and email = "db0lol@gmail.com" in

  ApiDump.lprint_endline "## Get achievements without being logged in";
  test_list (ApiAchievement.get ~lang:(Some lang) ());

  ApiDump.lprint_endline "## Create a new user";
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

  ApiDump.lprint_endline "## Get an authentication token using this user";
  test (ApiAuth.login login password)


let _ =
  let t = string_of_int (total.success + total.failure) in
  ApiDump.lprint_endline ("
####################################################

                      T O T A L

  Success    : " ^ (string_of_int total.success) ^ " / " ^ t ^ "
  Failure    : " ^ (string_of_int total.failure) ^ " / " ^ t ^ "

####################################################

")
