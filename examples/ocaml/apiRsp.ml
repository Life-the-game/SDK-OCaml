(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: Responses Codes                                               *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

type code = int
type msg  = string
type t    = (code * msg)

let rspcode : (t -> code) = fst
let rspmsg  : (t ->  msg) = snd

(* ************************************************************************** *)
(* Success                                                                    *)
(* ************************************************************************** *)

let success : t = (0, "SUCCESS")

(* ************************************************************************** *)
(* Standard Unix Error codes                                                  *)
(* ************************************************************************** *)

let permission : code = 1 (* This operation is not permitted                  *)
let existence  : code = 2 (* The data you are searching for does not exsts    *)
let action     : code = 3 (* This action does not exist                       *)
let stopped    : code = 4 (* The request has been interrupted                 *)
let io         : code = 5 (* Input/Output error                               *)
let incorrect  : code = 6 (* The information you provided are wrong           *)
let invalid    : code = 7 (* The information you provided are invalid         *)

(* ************************************************************************** *)
(* Authentification                                                           *)
(* ************************************************************************** *)

let auth_fail : t = (permission, "AUTH_FAIL")
let wrong_pwd : t = (incorrect,  (rspmsg auth_fail) ^ "_PASSWORD")
let wrong_usr : t = (existence,  (rspmsg auth_fail) ^ "_LOGIN")
let auth_req  : t = (permission, "AUTH_REQUIRED")

(* ************************************************************************** *)
(* User                                                                       *)
(* ************************************************************************** *)

let no_user : t = (existence, "USER_NOT_EXISTS")
let login_exist : t = (incorrect, "USER_LOGIN_ALREADY_EXISTS")

(* ************************************************************************** *)
(* Data Validity                                                              *)
(* ************************************************************************** *)

let invalid_token : t = (invalid, "INVALID_TOKEN")
let invalid_data  : t = (invalid, "INVALID_DATA")
let invalid_login : t = (invalid, "INVALID_LOGIN")
let invalid_name  : t = (invalid, "INVALID_NAME")
let invalid_email : t = (invalid, "INVALID_EMAIL")
let invalid_passw : t = (invalid, "INVALID_PASSWORD")

let unmatch_user : t = (incorrect, "USER_DOES_NOT_MATCH")
let unmatch_password : t = (incorrect, "PASSWORD_DOES_NOT_MATCH")
