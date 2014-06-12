(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Tools                                                                      *)
(* ************************************************************************** *)

let convert_each_ (c : Yojson.Basic.json) (f : Yojson.Basic.json -> 'a) : 'a list =
  let open Yojson.Basic.Util in
  match c |> to_option (convert_each f) with
    | Some l -> l
    | None -> []
let convert_each = convert_each_

let to_int_option_ c =
  let open Yojson.Basic.Util in
      match (to_int_option c) with
  	| Some i -> i
  	| None -> 0
let to_int_option = to_int_option_

let to_string_option_ c =
  let open Yojson.Basic.Util in
      match (to_string_option c) with
  	| Some i -> i
  	| None -> ""
let to_string_option = to_string_option_

(* ************************************************************************** *)
(* Explicit types for parameters                                              *)
(* ************************************************************************** *)

type id       = int
let id_to_string = string_of_int
let id_of_string = int_of_string

type login    = string
type password = string
type email    = string
type url      = string
type token    = string
type color    = string
type mimetype = string

type oauth_provider = string
type oauth_token    = token

type either =
  | Password of password
  | OAuth of (oauth_provider * oauth_token)

type parameters = (string (* key *) * string (* value *)) list

(* ************************************************************************** *)
(* Files                                                                      *)
(* ************************************************************************** *)

type filename = string
type contenttype = string
type path = string list
type file = (path * contenttype)
type either_file =
  | FileUrl of url
  | File of file
  | NoFile
type file_parameter = (filename * file)

let path_to_string = String.concat "/" (* todo dirsep unix *)

(* ************************************************************************** *)
(* Network stuff (GET POST ...)                                               *)
(* ************************************************************************** *)

module type NETWORK =
sig
  type t =
    | GET
    | POST
    | PUT
    | PATCH
    | DELETE
  type post =
    | PostText of string
    | PostList of parameters
    | PostMultiPart of parameters * file_parameter list * (contenttype -> bool)
    | PostEmpty
  type code = int
  val default   : t
  val to_string : t -> string
  val of_string : string -> t
  val option_filter  : (string * string option) list -> parameters
  val empty_filter   :  parameters -> parameters
  val files_filter   : (filename * either_file) list -> file_parameter list
  val multiple_files_filter : string -> either_file list -> file_parameter list
  val multiple_files_url_filter : string -> either_file list -> parameters
  val list_parameter : string list -> string
end
module Network : NETWORK =
struct
  type t =
    | GET
    | POST
    | PUT
    | PATCH
    | DELETE
  type parameters = (string (* key *) * string (* value *)) list
  type post =
    | PostText of string
    | PostList of parameters
    | PostMultiPart of parameters * file_parameter list * (contenttype -> bool)
    | PostEmpty
  type code = int
  let default = GET
  let to_string = function
    | GET    -> "GET"
    | POST   -> "POST"
    | PUT    -> "PUT"
    | PATCH  -> "PATCH"
    | DELETE -> "DELETE"
  let of_string = function
    | "GET"    -> GET
    | "POST"   -> POST
    | "PUT"    -> PUT
    | "PATCH"  -> PATCH
    | "DELETE" -> DELETE
    | _        -> default
  let option_filter l =
    let rec aux acc = function
      | []   -> acc
      | (k, v)::t ->
        (match v with
          | Some "" -> aux acc t
          | Some v -> aux ((k, v)::acc) t
          | None   -> aux acc t) in
    aux [] l
  let empty_filter l =
    let rec aux acc = function
      | []   -> acc
      | (k, v)::t ->
        if v = ""
        then aux acc t
        else aux ((k, v)::acc) t in
    aux [] l
  let files_filter l =
    let rec aux acc = function
      | []   -> acc
      | (name, File f)::t -> aux ((name, f)::acc) t
      | _::t -> aux acc t
    in
    aux [] l
  let multiple_files_filter name l =
    List.map (function | File file -> (name, file))
      (List.filter (function | File _ -> true | _ -> false) l)
  let multiple_files_url_filter name l =
    List.map (function | FileUrl url -> (name, url))
      (List.filter (function | FileUrl _ -> true | _ -> false) l)
  let list_parameter = String.concat ","
end

(* ************************************************************************** *)
(* Languages                                                                  *)
(* ************************************************************************** *)

module type LANG =
sig
  type t
  val list        : string list
  val default     : t
  val is_valid    : string -> bool
  val of_string : string -> t
  val to_string   : t      -> string
end
module Lang : LANG =
struct
  type t = string
  let list = ["en"; "fr"]
  let default = List.hd list
  let is_valid l = List.exists ((=) l) list
  let of_string s =
    match is_valid s with
      | true  -> s
      | false -> default
  let to_string l = l
end

type auth =
  | Token       of token
  | OAuthHTTP   of token  (* todo *)
  | OAuthToken  of token  (* todo *)
  | OAuthSecret of (login * token) (* todo *)

type requirements =
  | Auth of auth
  | Lang of Lang.t
  | Auto of (auth option * Lang.t)
  | Both of (auth * Lang.t)

let opt_auth = function
  | Some auth -> Some (Auth auth)
  | None      -> None

(* ************************************************************************** *)
(* Date & Time                                                                *)
(* ************************************************************************** *)

(* Full time with date + hour                                                 *)
module type DATETIME =
sig
  type t = CalendarLib.Calendar.t
  val format : string

  val to_string : t -> string
  val to_simple_string : t -> string
  val of_string : string -> t

  val empty : t
  val now : unit -> t
  val is_past : t -> bool
end

(* Only date                                                                  *)
module type DATE =
sig
  type t = CalendarLib.Date.t
  val format : string

  val to_string : t -> string
  val of_string : string -> t

  val empty : t
  val today : unit -> t
end

(* Only date                                                                  *)
module Date : DATE =
struct
  type t =  CalendarLib.Date.t
  let format = "%Y-%m-%d"

  let to_string date =
    CalendarLib.Printer.Date.sprint format date
  let of_string str_date =
    CalendarLib.Printer.Date.from_fstring format str_date

  let empty = CalendarLib.Date.make 0 0 0
  let today () = CalendarLib.Date.today ()
end
(* Full time with date + hour                                                 *)
module DateTime : DATETIME =
struct
  type t = CalendarLib.Calendar.t
  let format = Date.format ^ "T%H:%M:%SZ"
  let simple_format = Date.format ^ " %H:%M"

  let to_string date =
    CalendarLib.Printer.Calendar.sprint format date
  let to_simple_string date =
    CalendarLib.Printer.Calendar.sprint simple_format date
  let of_string str_date =
    CalendarLib.Printer.Calendar.from_fstring format str_date

  let empty = CalendarLib.Calendar.make 0 0 0 0 0 0
  let now () = CalendarLib.Calendar.now ()
  let is_past date =
    CalendarLib.Calendar.compare (now ()) date >= 0
end

(* ************************************************************************** *)
(* Information Element                                                        *)
(*   Almost all API object contain this object                                *)
(* ************************************************************************** *)

module type INFO =
sig
  type t =
      {
        id           : id;
        creation     : DateTime.t;
        modification : DateTime.t;
      }
  val from_json : Yojson.Basic.json -> t
  val creation : Yojson.Basic.json -> DateTime.t
  val modification : Yojson.Basic.json -> DateTime.t
end
module Info : INFO =
struct
  type t =
      {
        id           : id;
        creation     : DateTime.t;
        modification : DateTime.t;
      }
  let creation c = 
    let open Yojson.Basic.Util in
        DateTime.of_string (c |> member "creation" |> to_string)
  let modification c = 
    let open Yojson.Basic.Util in
        DateTime.of_string (c |> member "modification" |> to_string)
  let from_json c =
    let open Yojson.Basic.Util in
        {
          id           = c |> member "id" |> to_int;
          creation     = creation c;
          modification = modification c;
        }
end

(* ************************************************************************** *)
(* Vote elements                                                              *)
(*   Vote elements contain this object AND MUST contain Info as well          *)
(* ************************************************************************** *)

module type VOTE =
sig
  type vote = Up | Down
  type t =
      {
	downvotes : int;
	upvotes   : int;
	score     : int;
	vote      : vote option;
      }
  val from_json : Yojson.Basic.json -> t
  val to_string : vote -> string
  val of_string : string -> vote
end
module Vote : VOTE =
struct
  type vote = Up | Down
  type t =
      {
	downvotes : int;
	upvotes   : int;
	score     : int;
	vote      : vote option;
      }
  let to_string = function
    | Up     -> "up"
    | Down   -> "down"
  let of_string = function
    | "up"     -> Up
    | "down"   -> Down
    | _        -> Up
  let from_json c =
    let open Yojson.Basic.Util in
        {
          upvotes   = c |> member "upvotes"   |> to_int_option_;
          downvotes = c |> member "downvotes" |> to_int_option_;
          score     = c |> member "score"     |> to_int_option_;
	  vote      = c |> member "vote"      |> to_option
	      (fun vote -> of_string (vote |> to_string));
        }
end

(* ************************************************************************** *)
(* List Pagination                                                            *)
(* ************************************************************************** *)

module type PAGE =
sig
  type order = string
  type filter = (string * string) list
  type size = int
  type number = int
  type 'a t =
      {
	total       : size;
	size        : size;
	number      : number;
	next        : number option;
	previous    : number option;
	last        : number;
        items       : 'a list;
      }
  type parameters = (number * size option * order option * filter)
  val default_parameters : parameters
  (** Take a page and return the arguments to get the next one,
      or None if there's no next page *)
  val next : ?order:string -> ?filter:filter -> 'a t -> parameters option
  val previous : ?order:string -> ?filter:filter -> 'a t -> parameters option
  (** Generate a page from the JSON tree using a converter function *)
  val from_json :
    (Yojson.Basic.json -> 'a)
    -> Yojson.Basic.json
    -> 'a t
  val just_limit : size -> parameters
  val get_total: 'a t -> size
end
module Page : PAGE =
struct
  type order = string
  type filter = (string * string) list
  type size = int
  type number = int
  type 'a t =
      {
	total    : size;
	size     : size;
	number   : number;
	next     : number option;
	previous : number option;
	last     : number;
        items    : 'a list;
      }
  type parameters = (number * size option * order option * filter)
  let default_parameters = (1, None, None, [])
  let next ?(order = "") ?(filter = []) page =
    Option.map (fun number ->
      (number, Some page.size,
       (match order with "" -> None | o -> Some o), filter)) page.next
  let previous ?(order = "") ?(filter = []) page =
    Option.map (fun number ->
      (number, Some page.size,
       (match order with "" -> None | o -> Some o), filter)) page.previous
  let from_json f c =
    let open Yojson.Basic.Util in {
      total       = c |> member "total"    |> to_int_option_;
      size        = c |> member "size"     |> to_int_option_;
      number      = c |> member "number"   |> to_int_option_;
      next        = c |> member "next"     |> to_int_option;
      previous    = c |> member "previous" |> to_int_option;
      last        = c |> member "last"     |> to_int_option_;
      items       = convert_each_ (c |> member "items") f;
    }
  let just_limit limit = (1, Some limit, None, [])
  let get_total page = page.total
end

(* ************************************************************************** *)
(* Gender                                                                     *)
(* ************************************************************************** *)

module type GENDER =
sig
  type t = Male | Female | Other | Undefined
  val default   : t
  val to_string : t -> string
  val of_string : string -> t
end
module Gender : GENDER =
struct
  type t = Male | Female | Other | Undefined
  let default = Undefined
  let to_string = function
    | Male      -> "male"
    | Female    -> "female"
    | Other     -> "other"
    | Undefined -> "undefined"
  let of_string = function
    | "male"      -> Male
    | "female"    -> Female
    | "other"     -> Other
    | "undefined" -> Other
    | _           -> default
end

(* ************************************************************************** *)
(* Status                                                                     *)
(* ************************************************************************** *)

module type STATUS =
sig
  type t =
    | Objective
    | Unlocked
  val to_string : t -> string
  val of_string : string -> t
end
module Status : STATUS =
struct
  type t =
    | Objective
    | Unlocked
  let to_string = function
    | Objective -> "objective"
    | Unlocked  -> "unlocked"
  let of_string = function
    | "objective" -> Objective
    | "unlocked"  -> Unlocked
    | _           -> Objective
end

(* ************************************************************************** *)
(* Privacy                                                                    *)
(* ************************************************************************** *)

module type PRIVACY =
sig
  type t = Enemy | Pure | Hardcore | Discutable
  val default   : t
  val to_string : t -> string
  val of_string : string -> t
end
module Privacy : PRIVACY =
struct
  type t = Enemy | Pure | Hardcore | Discutable
  let default = Discutable
  let to_string = function
    | Enemy      -> "enemy"
    | Pure       -> "pure"
    | Hardcore   -> "hardcore"
    | Discutable -> "discutable"
  let of_string = function
    | "enemy"      -> Enemy
    | "pure"       -> Pure
    | "hardcore"   -> Hardcore
    | "discutable" -> Hardcore
    | _            -> default
end

(* ************************************************************************** *)
(* Color                                                                      *)
(* ************************************************************************** *)

let colors =
  [
    ("lightlightgreen", "#8ee7bc");
    ("lightgreen", "#4eda97");
    ("green", "#26b671");
    ("darkgreen", "#14623d");
    ("darkdarkgreen", "#115334");
    ("lightlightblue", "#b6daf2");
    ("lightblue", "#75b9e7");
    ("blue", "#3498db");
    ("darkblue", "#196090");
    ("darkdarkblue", "#16527a");
    ("lightlightpurple", "#dbc3e5");
    ("lightpurple", "#bb8ecd");
    ("purple", "#9b59b6");
    ("darkpurple", "#623475");
    ("darkdarkpurple", "#542c64");
    ("lightlightnightblue", "#7795b4");
    ("lightnightblue", "#4f6f8f");
    ("nightblue", "#34495e");
    ("darknightblue", "#10161c");
    ("darkdarknightblue", "#0d1318");
    ("lightlightyellow", "#f9e8a0");
    ("lightyellow", "#f5d657");
    ("yellow", "#f1c40f");
    ("darkyellow", "#927608");
    ("darkdarkyellow", "#7c6407");
    ("lightlightorange", "#ffb686");
    ("lightorange", "#ff883a");
    ("orange", "#ec5e00");
    ("darkorange", "#863500");
    ("darkdarkorange", "#722d00");
    ("lightlightred", "#f5b4ae");
    ("lightred", "#ef8b80");
    ("red", "#e74c3c");
    ("darkred", "#a82315");
    ("darkdarkred", "#8f1d12");
    ("lightlightgrey", "#ffffff");
    ("lightgrey", "#e6e9ea");
    ("grey", "#bdc3c7");
    ("darkgrey", "#869198");
    ("darkdarkgrey", "#727b81");
    ("lightlightpink", "#fffdfd");
    ("lightpink", "#f8b8c3");
    ("pink", "#f17288");
    ("darkpink", "#e6173b");
    ("darkdarkpink", "#c41332");
    (* ("main", "#26b671"); *)
    (* ("lightmain", "#4eda97"); *)
    (* ("lightlightmain", "#8ee7bc"); *)
    (* ("darkmain", "#14623d"); *)
    (* ("darkdarkmain", "#115334"); *)
  ]

let name_to_color color = List.assoc color colors

let main_colors =
  let is_main (name, _) =
    try
      if (String.sub name 0 8) = "darkdark"
      then false
      else if (String.sub name 0 10) = "lightlight"
      then false
      else true
    with Invalid_argument _ -> true in
  List.filter is_main colors

let light_colors =
  let is_light (name, _) =
    try
      if (String.sub name 0 4) = "dark"
      then false
      else if (String.sub name 0 8) = "darkdark"
      then false
      else true
    with Invalid_argument _ -> true in
  List.filter is_light colors

(* ************************************************************************** *)
(* Location                                                                   *)
(* ************************************************************************** *)

module type LOCATION =
sig
  type t = {
    latitude: float;
    longitude: float;
    radius: int;
  }
  type parameters = (float * float)
  val to_string : parameters -> string
  val of_string : ?radius : int -> string -> t
  val from_json : Yojson.Basic.json -> t
end
module Location : LOCATION =
struct
  type t = {
    latitude: float;
    longitude: float;
    radius: int;
  }
  type parameters = (float * float)
  let of_string ?(radius = 0) s = {
    latitude = 0.; (* todo *)
    longitude = 0.; (* todo *)
    radius = radius;
  }
  let to_string (latitude, longitude) =
    "lat" ^ (string_of_float latitude) ^ "long" ^ (string_of_float longitude)
  let from_json c =
    let open Yojson.Basic.Util in
    of_string ~radius:(c |> member "radius" |> to_int)
      (c |> member "location" |> to_string)
end

(* ************************************************************************** *)
(* Visibility                                                                 *)
(* ************************************************************************** *)

module type VISIBILITY =
sig
  type t =
    | Official
    | Community
    | Sponsored
    | Unknown
  val default : t
  val to_string : t -> string
  val of_string : string -> t
end
module Visibility : VISIBILITY =
struct
  type t =
    | Official
    | Community
    | Sponsored
    | Unknown
  let default = Unknown
  let of_string = function
    | "official" -> Official
    | "community" -> Community
    | "sponsored" -> Sponsored
    | _ -> default
  let to_string = function
    | Official -> "official"
    | Community -> "community"
    | Sponsored -> "sponsored"
    | Unknown -> "unknown"
end

(* ************************************************************************** *)
(* Error                                                                      *)
(* ************************************************************************** *)

type error =
  | BadRequest of string
  | NotFound of string
  | NotAllowed of string
  | NotAcceptable of string
  | InternalServerError of string
  | NotImplemented of string
  | Client of string
  | Unknown of (Network.code * string)

let error_from_json code c =

  (* let c = try String.sub c 0 800 *)
  (*   with _ -> c in *)

  (* let open Yojson.Basic.Util in *)
  (* let get_json c = Yojson.Basic.from_string c in *)
  match code with
    | 400 -> BadRequest c
    | 404 -> NotFound c
    | 405 -> NotAllowed c
    | 406 -> NotAcceptable c
    | 500 -> InternalServerError c
    | 501 -> NotImplemented c
    | code -> Unknown (code, c)

(* ************************************************************************** *)
(* Client-side errors                                                         *)
(* ************************************************************************** *)

let generic = Client "Something went wrong"
let network msg = Client ("Network error: " ^ msg)
let invalid_json msg = Client ("The JSON tree response is not formatted as expected: " ^ msg)
let requirement_missing = Client "One requirement is missing"
let invalid_format = Client "Invalid file format"
let invalid_argument msg = Client ("Invalid Argument: " ^ msg)
let auth_required = Client "Authentication required"
let file_not_found = Client "File not found"
let notfound = Client "Not found"

(* ************************************************************************** *)
(* API Response                                                               *)
(* ************************************************************************** *)

type 'a t =
  | Result of 'a
  | Error of error

exception OtherError of error

(* ************************************************************************** *)
(* Tools                                                                      *)
(* ************************************************************************** *)

(* todo check what happens if the exetions are raised *)
let extension filename =
  let start = try (String.rindex filename '.') + 1 with Not_found -> 0
  in try String.sub filename start ((String.length filename) - start)
    with Invalid_argument s -> ""

let extension_of_path path =
  try extension (List.hd (List.rev path))
  with Failure _ -> ""

let checker l contenttype = List.exists ((=) contenttype) l

let guess_contenttype_from_extension extension =
  match String.lowercase extension with
  | "jpg" | "jpeg" | "jpe" -> "image/jpeg"
  | "png" -> "image/png"
  | "bmp" -> "image/bmp"
  | "gif" -> "image/gif"
  | "mp4" | "mp4v" | "mpg4" -> "video/mp4"
  | "mpeg" | "mpg" | "mpe" | "m1v" | "m2v" -> "video/mpeg"
  | _ -> "text/plain"

let guess_contenttype filename =
  guess_contenttype_from_extension (extension filename)

let guess_contenttype_from_path path =
  guess_contenttype_from_extension (extension_of_path path)

(* ************************************************************************** *)
(* Picture                                                                    *)
(* ************************************************************************** *)

module type PICTURE =
sig
  type t =
    {
      info      : Info.t;
      url_small : url;
      url_big   : url;
    }
  val from_json : ?id:id -> Yojson.Basic.json -> t
  val contenttypes : contenttype list
  val checker : contenttype -> bool
end

module Picture : PICTURE =
struct
  type t =
    {
      info      : Info.t;
      url_small : url;
      url_big   : url;
    }

  let date =
    CalendarLib.Calendar.make 2013 12 01 9 5 6
  let from_json ?(id = (id_of_string "0")) c =
    let open Yojson.Basic.Util in
    let str = !ApiConf.base_url ^ (c |> to_string) in
    {
      info = (let open Info in {
	id = id;
	creation = date;
	modification = date;
      });
      url_small = str;
      url_big = str;
    }
    (* { *)
    (*   info      = Info.from_json c; *)
    (*   url_small = c |> member "url_small" |> to_string; *)
    (*   url_big   = c |> member "url_big"   |> to_string; *)
    (* } *)
  let contenttypes = [
    "image/jpeg";
    "image/png";
    "image/bmp";
  ]
  let checker = checker contenttypes
end

(* ************************************************************************** *)
(* Video                                                                      *)
(* ************************************************************************** *)

module type VIDEO =
sig
  type t =
    {
      info      : Info.t;
      url       : url;
      thumbnail : Picture.t;
    }
  val from_json : Yojson.Basic.json -> t
  val contenttypes : contenttype list
  val checker : contenttype -> bool
end

module Video : VIDEO =
struct
  type t =
    {
      info      : Info.t;
      url       : url;
      thumbnail : Picture.t;
    }
  let from_json c =
    let open Yojson.Basic.Util in
    {
      info      = Info.from_json c;
      url       = c |> member "url" |> to_string;
      thumbnail = Picture.from_json (c |> member "thumbnail");
    }
  let contenttypes = [
    "video/mp4";
  ]
  let checker = checker contenttypes
end

module type EXTERNALVIDEO =
sig
  type provider =
    | Youtube
    | DailyMotion
    | Vimeo
    | Unknown
  type t =
    {
      info      : Info.t;
      provider  : provider;
      video_url : url;
      thumbnail : Picture.t;
    }
  val from_json : Yojson.Basic.json -> t
  val provider_to_string : provider -> string
  val provider_of_string : string -> provider
end
module ExternalVideo : EXTERNALVIDEO =
struct
  type provider =
    | Youtube
    | DailyMotion
    | Vimeo
    | Unknown
  type t =
    {
      info      : Info.t;
      provider  : provider;
      video_url : url;
      thumbnail : Picture.t;
    }
  let provider_to_string = function
    | Youtube     -> "youtube"
    | DailyMotion -> "dailymotion"
    | Vimeo       -> "vimeo"
    | Unknown     -> "unknown"
  let provider_of_string = function
    | "youtube"     -> Youtube
    | "dailymotion" -> DailyMotion
    | "vimeo"       -> Vimeo
    | _             -> Unknown
  let from_json c =
    let open Yojson.Basic.Util in
    {
      info      = Info.from_json c;
      provider  = provider_of_string (c |> member "provider" |> to_string);
      video_url = c |> member "url" |> to_string;
      thumbnail = Picture.from_json (c |> member "thumbnail");
    }
end

(* ************************************************************************** *)
(* Media                                                                      *)
(* ************************************************************************** *)

type media =
  | Picture of Picture.t
  | Video   of Video.t
  | ExternalVideo of ExternalVideo.t
  | Media   of (string * string)
  | Id      of string

let media_from_json c =
  let open Yojson.Basic.Util in
  match c |> member "type" |> to_string with
    | "picture" -> Picture (Picture.from_json
			      ~id:(c |> member "id" |> to_int)
			      (c |> member "picture"))
    | _ -> Id (c |> to_string)

let checker = checker (Picture.contenttypes @ Video.contenttypes)

let media_thumbnail = function
  | Picture p -> p.Picture.url_small
  | Video v -> v.Video.thumbnail.Picture.url_small
  | ExternalVideo v -> v.ExternalVideo.thumbnail.Picture.url_small
  | _ -> ""

let media_url = function
  | Picture p -> p.Picture.url_big
  | Video v -> v.Video.thumbnail.Picture.url_big
  | ExternalVideo v -> v.ExternalVideo.thumbnail.Picture.url_big
  | _ -> ""

let media_id = function
  | Picture p -> p.Picture.info.Info.id
  | Video v -> v.Video.info.Info.id
  | ExternalVideo v -> v.ExternalVideo.info.Info.id
  | _ -> 0

(* ************************************************************************** *)
(* Session Types Dependency                                                   *)
(* ************************************************************************** *)

type _auth =
    {
      access_token  : token;
      token_type    : string;
      expires_in    : int;
      refresh_token : token;
      scope         : string list;
    }

type _user =
    {
      creation                 : DateTime.t;
      modification             : DateTime.t;
      login                    : login;
      firstname                : string;
      lastname                 : string;
      name                     : string;
      mutable avatar           : Picture.t option;
      gender                   : Gender.t;
      birthday                 : Date.t option;
      email                    : email option;
      (* score                    : int; *)
      (* level                    : int; *)
      following                : bool option;
      url                      : url;
    }

(* ************************************************************************** *)
(* Session                                                                    *)
(* ************************************************************************** *)

type session = {
  mutable auth : (_auth * _user) option;
  mutable lang : Lang.t;
  mutable connection : Curl.t option;
}

let default_session = {
  auth = None;
  lang = Lang.default;
  connection = None;
}
