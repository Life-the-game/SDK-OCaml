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

let oauth_id = "db0"
and oauth_secret = "db0secret"
let oauth_facebook_token = "CAACm4DryiWgBAA2iI8mtmggglqjQDG9ZAtS9ZCw9okNS9W4WWsDS13r4SGZBacu1xLryiY9rjPqtADoGYldTYZAPZBuwvloUDUorrR8avT2nwD187DZAiQaVTqBAZA0BPR0GmYMrZAp7ZBlHXtWAIdRps1fDqXgl9vW2zTiiUmUAWqkEx1koAcUBrxBwDYMvr1FcZD"

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
and email =  random_string 2 ^ "@gmail.com"
and color = "#26b671"
and color2 = "#0f0f0f"
and message = random_string 30
and picture = (["example.png"], "image/png")
and picture2 = (["example2.jpg"], "image/jpeg")
and picture3 = (["example3.png"], "image/png")
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

let session = default_session

let _ =

  ApiDump.lprint_endline "#################################################";
  ApiDump.lprint_endline "# Users tests                                   #";
  ApiDump.lprint_endline "#################################################";


  (* print_title "Create a new user with oauth facebook all infos"; *)
  (* let user = ref *)
  (*   (test (ApiUser.create *)
  (*             ~login:login_ *)
  (*             ~email:("prefix" ^ email) *)
  (*             ~lang:lang *)
  (*             ~firstname:(random_string 10) *)
  (*             ~lastname:(random_string 10) *)
  (*             ~gender:Gender.Male *)
  (*             ~birthday:(Some birthday2) *)
  (*             ~avatar:(File picture2) *)
  (*             (OAuth ("facebook", oauth_facebook_token)))) in *)

  (* ignore (ApiAuth.client_logout ()); *)

  (* print_title "Authenticate using a login and an oauth token"; *)
  (* ignore (test (ApiAuth.facebook ~oauth_id:oauth_id ~oauth_secret:oauth_secret *)
  (* 		  ~scope:["life-fe-only--all"] oauth_facebook_token)); *)

  (* print_title "Create a user with oauth facebook just the minimum"; *)
  (* ignore (test (ApiUser.create ~login:friend_ ~email:(friend ^ "@email.com") *)
  (*                 (OAuth ("facebook", oauth_facebook_token)))); *)

  print_title "Create a new user with all infos";
  let user = ref
    (test (ApiUser.create
	     ~session:session
             ~login:login
             ~email:("prefix" ^ email)
             ~lang:lang
             ~firstname:(random_string 10)
             ~lastname:(random_string 10)
             ~gender:Gender.Male
             ~birthday:(Some birthday2)
             (Password old_password))) in

  print_title "Authenticate using a login and a password";
  ignore (test (ApiAuth.login ~session:session ~oauth_id:oauth_id ~oauth_secret:oauth_secret
  		  ~scope:["life-fe-only--all"] login old_password));

  print_title "Upload an avatar";
  ignore (test (ApiUser.avatar ~session:session login (File picture2)));

  ignore (test (ApiUser.get_one ~session:session login));

  (* print_title "Delete avatar"; *)
  (* ignore (test (ApiUser.delete_avatar login)); *)

  ignore (test (ApiUser.get_one ~session:session login));

  (* TODO real logout *)
  ignore (ApiAuth.client_logout ~session:session ());

  print_title "Create a user with just the minimum";
  ignore (test (ApiUser.create ~session:session ~login:friend ~email:(friend ^ "@email.com")
                  (Password password)));

  for i = 0 to Random.int 20 do
    (* Create a bunch of users that will follow the main user *)
    let tmpuser = (random_string 5) in
    ignore (test (ApiUser.create ~session:session ~login:tmpuser
              ~email:(tmpuser ^ "@email.com")
              (Password password)));
    ignore (test (ApiAuth.login ~session:session ~oauth_id:oauth_id ~oauth_secret:oauth_secret
  		    ~scope:["life-fe-only--all"] tmpuser password));
    ignore (test (ApiUser.follow ~session:session login));
    (* ignore (test (ApiAuth.logout ())); *)
    ignore (ApiAuth.client_logout ~session:session ());
  done;

  print_title "Get one user";
  ignore (test (ApiUser.get_one ~session:session login));

  print_title "Get users";
  let users = test ~f:pageprint (ApiUser.get ~session:session ()) in

  print_title "Get next page of users";
  (match users with (* Check the previous page *)
    | Error e -> impossible "the previous page failed"
    | Result users ->
      match Page.next users with (* Check if there is a next page *)
        | None -> ApiDump.lprint_endline "It was the last page"
        | Some nextpage ->
          ignore (test ~f:pageprint (ApiUser.get ~session:session ~page:nextpage ())));

  print_title "Authenticate using a login and a password";
  ignore (test (ApiAuth.login ~session:session ~oauth_id:oauth_id ~oauth_secret:oauth_secret
  		  ~scope:["life-fe-only--all"] login old_password));

  print_title "Edit a user";
  user := test (ApiUser.edit
		  ~session:session
                  ~email:email
                  ~firstname:firstname
                  ~lastname:lastname
                  ~gender:gender
                  ~birthday:(Some birthday)
                  ~password:(Some (old_password, password))
                  login
  );

  print_title "Get users after being authentified (info about following)";
  ignore (test ~f:pageprint (ApiUser.get ~session:session ()));

  print_title "Get followers";
  ignore (test ~f:pageprint (ApiUser.get_followers ~session:session login));

  print_title "Follow someone";
  ignore (test (ApiUser.follow ~session:session friend));

  print_title "Get following";
  ignore (test ~f:pageprint (ApiUser.get_following ~session:session login));

  print_title "Unfollow someone";
  ignore (test (ApiUser.unfollow ~session:session friend));

  print_title "Get following again to check previous unfollow";
  ignore (test ~f:pageprint (ApiUser.get_followers ~session:session login));

  ApiDump.lprint_endline "\n";
  ApiDump.lprint_endline "#################################################";
  ApiDump.lprint_endline "# Achievements tests                            #";
  ApiDump.lprint_endline "#################################################";

  print_title "Create an achievement with just a name and a description";
  ignore (test (ApiAchievement.create
                  ~name:achievement_name
                    ~description:achievement_description ~session:session ()));

  print_title "Create an achievement with all the fields";
  let achievement = test
    (ApiAchievement.create
       ~session:session
       ~name:achievement_name2
       ~description:achievement_description2
       ~color:color
       ~secret:false
       ~location:(Some paris_location)
       ~radius:5
       ()) in

  print_title "Get achievements";
  let achievements = test ~f:pageprint
    (ApiAchievement.get ~session:session ~page:(Page.just_limit 2) ()) in

  print_title "Get next page of achievements";
  (match achievements with (* Check the previous page *)
    | Error e -> impossible "the previous page failed"
    | Result achievements ->
      match Page.next achievements with (* Check if there is a next page *)
        | None -> ApiDump.lprint_endline "It was the last page"
        | Some nextpage ->
          ignore (test ~f:pageprint (ApiAchievement.get ~session:session ~page:nextpage ())));

  print_title "Get achievements with terms";
  ignore (test ~f:pageprint (ApiAchievement.get ~session:session ~terms:["chick"] ()));

  print_title "Get achievements with tags";
  ignore (test ~f:pageprint (ApiAchievement.get ~session:session ~tags:["usa"] ()));

  print_title "Get achievements with a location";
  ignore (test ~f:pageprint (ApiAchievement.get ~session:session ~location:(Some paris_location) ()));

  print_title "Get one achievement";
  (match achievement with (* Check if the list exists *)
    | Error e -> impossible "the previous test (get achievements) failed"
    | Result achievement ->
      let achievement_id = achievement.ApiAchievement.info.Info.id in
      ignore (test (ApiAchievement.get_one ~session:session achievement_id));

      print_title "Add icon to achieement";
      ignore (test (ApiAchievement.icon ~session:session achievement_id (File picture)));

      ignore (test (ApiAchievement.get_one ~session:session achievement_id));

      (* print_title "Delete icon on achieement"; *)
      (* ignore (test (ApiAchievement.delete_icon achievement_id)); *)

      ignore (test (ApiAchievement.get_one ~session:session achievement_id));

      print_title "Add tags to achievement";
      ignore (test (ApiAchievement.add_tags ~session:session ["usa"; "travel"; "play"; "fox"] achievement_id));

      print_title "Delete tags on achievement";
      ignore (test (ApiAchievement.delete_tags ~session:session ["usa"; "play"] achievement_id));

      print_title "Edit one achievement";
      ignore (test
                (ApiAchievement.edit
		   ~session:session
                   ~description:achievement_description3
                   ~icon:(File picture2)
                   ~color:color2
                   achievement_id));

      print_title "Vote (approve)";
      ignore (test (ApiAchievement.vote ~session:session achievement_id Vote.Up));

      print_title "Change Vote (disapprove)";
      ignore (test (ApiAchievement.vote ~session:session achievement_id Vote.Down));

      print_title "Cancel vote";
      ignore (test (ApiAchievement.cancel_vote ~session:session achievement_id));

      print_title "Add a comment";
      let comment = test
        (ApiAchievement.add_comment ~session:session ~content:(random_string 25) 94) in

      print_title "Add a comment";
      let comment = test
        (ApiAchievement.add_comment ~session:session ~content:(random_string 25) achievement_id) in

      for i = 0 to Random.int 20 do
        ignore (ApiAchievement.add_comment ~session:session ~content:(random_string (Random.int 25)) achievement_id);
      done;

      (match comment with
        | Error e -> impossible "the previous comment could not be added"
        | Result comment ->
          let comment_id = comment.ApiComment.info.Info.id in
          print_title "Edit comment";
          ignore (test (ApiAchievement.edit_comment ~session:session
                          ~content:(comment.ApiComment.content ^ (random_string 10))
                          comment_id));

          print_title "Vote Comment (approve)";
          ignore (test (ApiAchievement.vote_comment ~session:session comment_id Vote.Up));

          print_title "Change Vote Comment (disapprove)";
          ignore (test (ApiAchievement.vote_comment ~session:session comment_id Vote.Down));

          print_title "Cancel vote comment";
          ignore (test (ApiAchievement.cancel_vote_comment ~session:session comment_id));

          (* print_title "Delete comment"; *)
          (* ignore (test (ApiAchievement.delete_comment comment_id)); *)
      );

      print_title "Get comments";
      ignore (test ~f:pageprint (ApiAchievement.comments ~session:session achievement_id));

      (* print_title "Delete this achievement"; *)
      (* ignore (test (ApiAchievement.delete achievement_id)); *)
      (* (); *)
  );

  ApiDump.lprint_endline "\n";
  ApiDump.lprint_endline "#################################################";
  ApiDump.lprint_endline "# Achievements statuses tests                   #";
  ApiDump.lprint_endline "#################################################";

  (match achievement with
    | Error e -> impossible "the previous test (get achievement) failed"
    | Result achievement ->
      let achievement_id = achievement.ApiAchievement.info.Info.id in

      print_title "Create an achievement status";
      let achievement_status =
        test (ApiAchievementStatus.create
		~session:session
                ~achievement:achievement_id
                ~status:Status.Objective
                ()) in

      (match achievement_status with
  	| Error e -> impossible "the previous test (create achievement status) failed"
  	| Result achievement_status ->
  	  let achievement_status_id = achievement_status.ApiAchievementStatus.info.Info.id in
  	  print_title "Edit an achievement status";
  	  ignore (test (ApiAchievementStatus.edit ~session:session
  	  		  ~status:(Some Status.Unlocked)
  	  		  ~message:(random_string 20)
  	  		  achievement_status_id
  	  ));

	  print_title "Upload a media to an achievement status";
	  ignore (test (ApiAchievementStatus.add_media ~session:session (File picture) achievement_status_id));

	  print_title "Upload a media to an achievement status";
	  ignore (test (ApiAchievementStatus.add_media ~session:session (File picture2) achievement_status_id));

      	  print_title "Get one achievement status";
      	  ignore (test (ApiAchievementStatus.get_one ~session:session achievement_status_id));

      	  print_title "Vote (approve)";
      	  ignore (test (ApiAchievementStatus.vote ~session:session achievement_status_id Vote.Up));

      	  print_title "Change Vote (disapprove)";
      	  ignore (test (ApiAchievementStatus.vote ~session:session achievement_status_id Vote.Down));

      	  print_title "Cancel vote";
      	  ignore (test (ApiAchievementStatus.cancel_vote ~session:session achievement_status_id));

      	  print_title "Add a comment";
      	  let comment = test
            (ApiAchievementStatus.add_comment ~session:session ~content:(random_string 25) achievement_status_id) in

      	  for i = 0 to Random.int 20 do
            ignore (ApiAchievementStatus.add_comment ~session:session ~content:(random_string (Random.int 25)) achievement_status_id);
      	  done;

      	  (match comment with
            | Error e -> impossible "the previous comment could not be added"
            | Result comment ->
              let comment_id = comment.ApiComment.info.Info.id in
              print_title "Edit comment";
              ignore (test (ApiAchievementStatus.edit_comment ~session:session
                              ~content:(comment.ApiComment.content ^ (random_string 10))
                              comment_id));

              print_title "Vote Comment (approve)";
              ignore (test (ApiAchievementStatus.vote_comment~session:session  comment_id Vote.Up));

              print_title "Change Vote Comment (disapprove)";
              ignore (test (ApiAchievementStatus.vote_comment ~session:session comment_id Vote.Down));

              print_title "Cancel vote comment";
              ignore (test (ApiAchievementStatus.cancel_vote_comment ~session:session comment_id));

              (* print_title "Delete comment"; *)
              (* ignore (test (ApiAchievementStatus.delete_comment comment_id)); *)
      	  );

      	  print_title "Get comments";
      	  ignore (test ~f:pageprint (ApiAchievementStatus.comments ~session:session achievement_status_id));

      	  (* print_title "Delete this achievement status"; *)
      	  (* ignore (test (ApiAchievementStatus.delete achievement_status_id)); *)
      );

      print_title "Get achievement statuses with achievements";
      ignore (test ~f:pageprint (ApiAchievementStatus.get ~session:session ~achievements:[achievement_id] ()));

  );

  (* Create a bunch of achievement statuses *)
  (match achievements with
    | Error e -> ()
    | Result achievements ->
      List.iter (fun achievement ->
        ignore (ApiAchievementStatus.create ~session:session
  		  ~achievement:achievement.ApiAchievement.info.Info.id
  		  ~status:(if Random.bool () then Status.Objective else Status.Unlocked)
  		  ())
      ) achievements.Page.items
  );

  print_title "Get achievement statuses";
  let achievement_statuses = test ~f:pageprint (ApiAchievementStatus.get ~session:session ()) in

  print_title "Get next page of achievement statuses";
  (match achievement_statuses with (* Check the previous page *)
    | Error e -> impossible "the previous page failed"
    | Result achievement_statuses ->
      match Page.next achievement_statuses with (* Check if there is a next page *)
        | None -> ApiDump.lprint_endline "It was the last page"
        | Some nextpage ->
          ignore (test ~f:pageprint (ApiAchievementStatus.get ~session:session ~page:nextpage ())));

  print_title "Get achievement statuses with owners";
  ignore (test ~f:pageprint (ApiAchievementStatus.get ~session:session ~owners:[login] ()));

  print_title "Get all objectives";
  ignore (test ~f:pageprint (ApiAchievementStatus.get ~session:session ~statuses:[Status.Objective] ()));

  print_title "Get achievement statuses with terms (a)";
  ignore (test ~f:pageprint (ApiAchievementStatus.get ~session:session ~terms:["a"] ()));

  ApiDump.lprint_endline "\n";
  ApiDump.lprint_endline "#################################################";
  ApiDump.lprint_endline "# User Activities tests                         #";
  ApiDump.lprint_endline "#################################################";

  print_title "Get all user activities (hot feed)";
  let activities = test ~f:pageprint (ApiActivity.user ~session:session ()) in

  print_title "Get next page of activities";
  (match activities with (* Check the previous page *)
    | Error e -> impossible "the previous page failed"
    | Result activities ->
      match Page.next activities with (* Check if there is a next page *)
        | None -> ApiDump.lprint_endline "It was the last page"
        | Some nextpage ->
          ignore (test ~f:pageprint (ApiActivity.user ~session:session ~page:nextpage ())));

  print_title "Get user activities of a user";
  ignore (test ~f:pageprint (ApiActivity.user ~session:session ~owner:friend ()));

  print_title "Get user activities of a user";
  ignore (test ~f:pageprint (ApiActivity.user ~session:session ~owner:login ()));

  print_title "Get feed (following)";
  ignore (test ~f:pageprint (ApiActivity.following ~session:session ()));

  ApiDump.lprint_endline "\n";
  ApiDump.lprint_endline "#################################################";
  ApiDump.lprint_endline "# Notifications tests                           #";
  ApiDump.lprint_endline "#################################################";

  print_title "Get notifications";
  let notifications = test ~f:pageprint (ApiActivity.notifications ~session:session ()) in

  print_title "Get next page of notifications";
  (match notifications with (* Check the previous page *)
    | Error e -> impossible "the previous page failed"
    | Result notifications ->
      match Page.next notifications with (* Check if there is a next page *)
        | None -> ApiDump.lprint_endline "It was the last page"
        | Some nextpage ->
          ignore (test ~f:pageprint (ApiActivity.notifications ~session:session ~page:nextpage ())));

  ApiDump.lprint_endline "\n";
  ApiDump.lprint_endline "#################################################";
  ApiDump.lprint_endline "# Logout                                        #";
  ApiDump.lprint_endline "#################################################";

  (* print_title "Logout (remove token)"; *)
  (* ignore (test (ApiAuth.logout ())); *)

  print_total ()
