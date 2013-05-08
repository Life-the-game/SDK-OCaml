(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: Example of usage of the API library                           *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

let input msg =
  print_string (msg ^ "? ");
  flush stdout;
  input_line stdin

(* ************************************************************************** *)
(* Example of usage of the API library                                        *)
(* ************************************************************************** *)

let _ =

  print_endline "## Get achievements without being logged in";
  
  match
    ApiAchievement.get
      ~lang:(Some (ApiTypes.Lang.from_string (ApiDump.available_languages ();
  				     input "Language"))) () with
  	| ApiTypes.Error e -> ApiDump.error e
  	| ApiTypes.Result achievements ->
  	  ApiDump.list achievements ApiDump.print;
    
  print_endline "## Create a new user";

  let login = input "Login"
  and password = input "Password"
  and email = input "Email" in

  match
    ApiUser.create
      ~login:login
      ~email:email
      ~password:password
      ~lang:(ApiTypes.Lang.from_string "en")
      (* additional parameters available: name, gender, birthday, ... *)
      () with
  	| ApiTypes.Error e -> ApiDump.error e
  	| ApiTypes.Result user -> ApiDump.print user;

  	  print_endline "## Get an authentication token using this user";
	  match ApiAuth.login login password with 
	    | ApiTypes.Error e -> ApiDump.error e
	    | ApiTypes.Result auth -> ApiDump.print auth;


