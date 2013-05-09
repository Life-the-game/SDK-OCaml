## ########################################################################## ##
## Project: La Vie Est Un Jeu - Public API, example with OCaml                ##
## Description: Makefile compiling the OCaml example of the API               ##
## Author: Tuxkowo                                                            ##
## Modified by: db0 (db0company@gmail.com, http://db0.fr/)                    ##
## Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   ##
## ########################################################################## ##

NAME		=	api.cma

SRC		=	apiError.ml \
			apiTypes.ml \
			api.ml \
			\
			apiMedia.ml \
			apiUser.ml \
			apiAuth.ml \
			apiAchievement.ml \
			apiActivity.ml \
			apiConversation.ml \
			apiAchievementStatus.ml \
			\
			apiDump.ml

SRCI		=	apiError.mli \
			apiTypes.mli \
			api.mli \
			\
			apiMedia.mli \
			apiUser.mli \
			apiAuth.mli \
			apiAchievement.mli \
			apiActivity.mli \
			apiConversation.mli \
			apiAchievementStatus.mli \
			\
			apiDump.mli

SRCDOC		=	api.ml
PACKS		=	extlib,curl,yojson,calendar

TEST_NAME	=	example
TEST_SRC	=	example.ml

VERSION		=	1.0.0

FLAGS		=	-linkpkg

CMO		=	$(SRC:.ml=.cmo)
CMI		=	$(SRC:.ml=.cmi)

COMPILER	=	ocamlc
DOCCOMPILER	=	ocamldoc
OCAMLFIND	=	ocamlfind
RM		=	rm -f

all		:	
			$(OCAMLFIND) $(COMPILER) -a -o $(NAME) -package $(PACKS) $(SRCI) $(SRC) $(FLAGS)

doc		:
			$(OCAMLFIND) $(DOCCOMPILER) -html -package $(PACKS) $(SRCDOC)

$(TEST_NAME)	:	all
			$(OCAMLFIND) $(COMPILER) -o $(TEST_NAME) $(NAME) $(TEST_SRC) $(FLAGS)

clean		:
			$(RM) $(CMI) $(CMO)

fclean		:	clean
			$(RM) $(NAME)

re		:	fclean all
