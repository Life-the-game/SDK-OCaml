## ########################################################################## ##
## Project: La Vie Est Un Jeu - Public API, example with OCaml                ##
## Description: Makefile compiling the OCaml example of the API               ##
## Author: Tuxkowo                                                            ##
## Modified by: db0 (db0company@gmail.com, http://db0.fr/)                    ##
## Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    ##
## ########################################################################## ##

NAME		=	api.cma

SRC		=	\
			apiTypes.ml \
			apiConf.ml \
			apiDump.ml \
			api.ml \
			\
			apiMedia.ml \
			apiUser.ml \
			apiAuth.ml \
			apiAchievement.ml \
			apiAchievementStatus.ml \
			apiComment.ml \
			apiActivity.ml \
			apiFeed.ml \
			apiGameNetwork.ml \
			apiRoles.ml \
			\

SRCI		=	\
			apiTypes.mli \
			apiDump.mli \
			api.mli \
			\
			apiMedia.mli \
			apiUser.mli \
			apiAuth.mli \
			apiAchievement.mli \
			apiAchievementStatus.mli \
			apiComment.mli \
			apiActivity.mli \
			apiFeed.mli \
			apiGameNetwork.mli \
			apiRoles.mli \
			\

SRCDOC		=	$(SRCI) $(SRC)
PACKS		=	extlib,curl,yojson,calendar

TEST_NAME	=	example
TEST_SRC	=	example.ml

VERSION		=	1.0.0

FLAGS		=	-linkpkg

CMO		=	$(SRC:.ml=.cmo)
yCMI		=	$(SRC:.ml=.cmi)

COMPILER	=	ocamlc
DOCCOMPILER	=	ocamldoc
OCAMLFIND	=	ocamlfind
RM		=	rm -f

all		:	
			$(OCAMLFIND) $(COMPILER) -a -o $(NAME) -package $(PACKS) $(SRCI) $(SRC) $(FLAGS)

doc		:	all
			mkdir -p html/
			$(OCAMLFIND) $(DOCCOMPILER) -html -package $(PACKS) $(SRCDOC) -d html/

$(TEST_NAME)	:	all
			$(OCAMLFIND) $(COMPILER) -o $(TEST_NAME) $(NAME) $(TEST_SRC) $(FLAGS)

clean		:
			$(RM) $(CMI) $(CMO) example.cmi

fclean		:	clean
			$(RM) $(NAME)

re		:	fclean all
