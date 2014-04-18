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
      verbose := false;
      (Arg.parse
         [("-u", Arg.String (fun url -> base_url := url),
	   "the URL of the web service")]
         (fun _ -> ()) "./example [-u url]")

(* ************************************************************************** *)
(* Tests configuration                                                        *)
(* ************************************************************************** *)

let print_success = false
let stop_on_error = false

(* ************************************************************************** *)
(* Tools                                                                      *)
(* ************************************************************************** *)

let _ = Random.self_init ()

(* Generate a random string with the given lenght                             *)
let random_string (length : int) : string =
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
and friend = random_string 10
and lang = Lang.default
and firstname = "Barbara"
and lastname = "Lepage"
and gender = Gender.Female
and birthday = Date.of_string "1991-05-30"
and birthday2 = Date.of_string "2000-06-02"
and password = "helloworld"
and old_password = "124%{^#"
and email = random_string 2 ^ "@gmail.com"
and color = "#26b671"
and color2 = "#0f0f0f"
and message = random_string 30
and picture = (["example.png"], "image/png")
and picture2 = (["example2.jpg"], "image/jpeg")
and achievement_name = random_string 15
and achievement_name2 = random_string 15
and achievement_description = random_string 30
and achievement_description2 = random_string 30
and achievement_description3 = random_string 30
and comment_description = random_string 30
and paris_location = (48.8566, 2.3533)

(* ************************************************************************** *)
(* Test generic function                                                      *)
(* ************************************************************************** *)

let test
    ?(f = ApiDump.print) (* function to display the result of the test        *)
    ?(t = false) (* true if the test should fail (so it's a success)          *)
    (result : 'a Api.t) : 'a Api.t =
  let _failure () = total.failure <- total.failure + 1
  and _success () = total.success <- total.success + 1 in
  let failure e = if t then _success () else _failure ()
  and success r = if t then _failure () else _success () in
  let on_error e =
    begin
      failure e;
      ApiDump.error e;
      ApiDump.lprint_endline "\n  ----> FAILURE\n";
      if stop_on_error then (print_total (); exit 1);
    ()
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

(* ************************************************************************** *)
(* It's testing time \o/                                                      *)
(* ************************************************************************** *)

let _ =

  ApiDump.lprint_endline "#################################################";
  ApiDump.lprint_endline "# Users tests                                   #";
  ApiDump.lprint_endline "#################################################";

  print_title "Create a new user with all infos";
  let user = ref
    (test (ApiUser.create
              ~login:login
	      ~email:("prefix" ^ email)
              ~lang:lang
	      ~firstname:(random_string 10)
	      ~lastname:(random_string 10)
	      ~gender:Gender.Male
	      ~birthday:(Some birthday2)
	      ~avatar:(File picture2)
              (Password old_password))) in

  print_title "Create a user with just the minimum";
  ignore (test (ApiUser.create ~login:friend ~email:(friend ^ "@email.com")
		  (Password password)));

  print_title "/!\\ Warning! OAuth user creation not tested!";

  for i = 0 to Random.int 20 do
    (* Create a bunch of users that will follow the main user *)
    let tmpuser = (random_string 5) in
    ignore (ApiUser.create ~login:tmpuser
	      ~email:(tmpuser ^ "@email.com")
	      (Password password));
    ignore (ApiAuth.login tmpuser password);
    ignore (ApiUser.follow login);
    ignore (ApiAuth.logout ());
  done;

  print_title "Edit a user";
  user := test (ApiUser.edit
		  ~email:email
		  ~firstname:firstname
		  ~lastname:lastname
		  ~gender:gender
		  ~birthday:(Some birthday)
		  ~avatar:(File picture)
		  ~password:(Some (old_password, password))
		  login
  );

  print_title "Get one user";
  ignore (test (ApiUser.get_one login));

  print_title "Get users";
  let users = test (ApiUser.get ()) in

  print_title "Get next page of users";
  (match users with (* Check the previous page *)
    | Error e -> impossible "the previous page failed"
    | Result users ->
      match Page.next users with (* Check if there is a next page *)
        | None -> ApiDump.lprint_endline "It was the last page"
        | Some nextpage ->
          ignore (test ~f:pageprint (ApiUser.get ~page:nextpage ())));

  print_title "Authenticate using a login and a password";
  ignore (test (ApiAuth.login login password));

  print_title "/!\\ Warning! OAuth authentication not tested!";

  print_title "Get users after being authentified (info about following)";
  ignore (test (ApiUser.get ()));

  print_title "Get followers";
  ignore (test (ApiUser.get_followers login));

  print_title "Follow someone";
  ignore (test (ApiUser.follow friend));

  print_title "Get following";
  ignore (test (ApiUser.get_followers login));

  print_title "Unfollow someone";
  ignore (test (ApiUser.unfollow friend));

  print_title "Get following again to check previous unfollow";
  ignore (test (ApiUser.get_followers login));

  ApiDump.lprint_endline "\n";
  ApiDump.lprint_endline "#################################################";
  ApiDump.lprint_endline "# Achievements tests                            #";
  ApiDump.lprint_endline "#################################################";

  print_title "Create an achievement with just a name and a description";
  ignore (test (ApiAchievement.create
		  ~name:achievement_name
  		  ~description:achievement_description ()));

  print_title "Create an achievement with all the fields";
  let achievement = test
    (ApiAchievement.create
       ~name:achievement_name2
       ~description:achievement_description2
       ~icon:(File picture)
       ~color:color
       ~secret:false
       ~tags:["usa"; "travel"]
       ~location:(Some paris_location)
       ~radius:5
       ()) in

  print_title "Get achievements";
  let achievements = test ~f:pageprint
    (ApiAchievement.get ~page:(Page.just_limit 2) ()) in

  print_title "Get next page of achievements";
  (match achievements with (* Check the previous page *)
      | Error e -> impossible "the previous page failed"
    | Result achievements ->
      match Page.next achievements with (* Check if there is a next page *)
        | None -> ApiDump.lprint_endline "It was the last page"
        | Some nextpage ->
          ignore (test ~f:pageprint (ApiAchievement.get ~page:nextpage ())));

  print_title "Get achievements with terms";
  ignore (test ~f:pageprint (ApiAchievement.get ~terms:["chick"] ()));

  print_title "Get achievements with tags";
  ignore (test ~f:pageprint (ApiAchievement.get ~tags:["usa"] ()));

  print_title "Get achievements with a location";
  ignore (test ~f:pageprint (ApiAchievement.get ~location:(Some paris_location) ()));

  print_title "Get one achievement";
  (match achievement with (* Check if the list exists *)
    | Error e -> impossible "the previous test (get achievements) failed"
    | Result achievement ->
      let achievement_id = achievement.ApiAchievement.info.Info.id in
      ignore (test (ApiAchievement.get_one achievement_id));

      print_title "Edit one achievement";
      ignore (test
		(ApiAchievement.edit
		   ~description:achievement_description3
		   ~icon:(File picture2)
		   ~color:color2
		   ~add_tags:["play"]
		   ~del_tags:["usa"]
		   achievement_id));

      print_title "Vote (approve)";
      ignore (test (ApiAchievement.vote Vote.Approved achievement_id));

      print_title "Change Vote (disapprove)";
      ignore (test (ApiAchievement.vote Vote.Disapproved achievement_id));      

      print_title "Cancel vote";
      ignore (test (ApiAchievement.cancel_vote achievement_id));

      print_title "Add a comment";
      let comment = test
	(ApiAchievement.add_comment ~content:(random_string 25) achievement_id) in

      for i = 0 to Random.int 20 do
	ignore (ApiAchievement.add_comment ~content:(random_string (Random.int 25)) achievement_id);
      done;

      (match comment with
	| Error e -> impossible "the previous comment could not be added"
	| Result comment ->
	  let comment_id = comment.ApiComment.info.Info.id in
	  print_title "Edit comment";
	  ignore (test (ApiAchievement.edit_comment
			  ~content:(comment.ApiComment.content ^ (random_string 10))
			  comment_id));

	  print_title "Vote Comment (approve)";
	  ignore (test (ApiAchievement.vote_comment Vote.Approved comment_id));      

	  print_title "Change Vote Comment (disapprove)";
	  ignore (test (ApiAchievement.vote_comment Vote.Disapproved comment_id));      

	  print_title "Cancel vote comment";
	  ignore (test (ApiAchievement.cancel_vote_comment comment_id));

	  print_title "Delete comment";
	  ignore (test (ApiAchievement.delete_comment comment_id));
      );

      print_title "Get comments";
      ignore (test (ApiAchievement.comments achievement_id));

      print_title "Delete this achievement";
      ignore (test (ApiAchievement.delete achievement_id));
  );

  ApiDump.lprint_endline "\n";
  ApiDump.lprint_endline "#################################################";
  ApiDump.lprint_endline "# Achievements statuses tests                   #";
  ApiDump.lprint_endline "#################################################";

  ApiDump.lprint_endline "No test";

  ApiDump.lprint_endline "\n";
  ApiDump.lprint_endline "#################################################";
  ApiDump.lprint_endline "# User Activities tests                         #";
  ApiDump.lprint_endline "#################################################";

  ApiDump.lprint_endline "No test";

  ApiDump.lprint_endline "\n";
  ApiDump.lprint_endline "#################################################";
  ApiDump.lprint_endline "# Notifications tests                           #";
  ApiDump.lprint_endline "#################################################";

  ApiDump.lprint_endline "No test";

  ApiDump.lprint_endline "\n";
  ApiDump.lprint_endline "#################################################";
  ApiDump.lprint_endline "# Logout                                        #";
  ApiDump.lprint_endline "#################################################";

  print_title "Logout (remove token)";
  ignore (test (ApiAuth.logout ()));

  print_total ()
