#######################################################
#
#   simple periodic markov chain test program
#
#######################################################

CC = g++ 
FLAGS = -Wall -pedantic -Werror -std=c++17 -pthread

SOURCES = 
MAIN = main.cpp

HEADERS = 
FILE = simpleMarkovPeriodic
MAKE = make

.PHONY : 

all : $(FILE)

debug : FLAGS += -DDEBUG -g
debug: $(FILE)

clean :
	rm -f $(FILE)
	rm -f $(TEST_FILE)
	rm -rf *.o	


$(FILE) : $(SOURCES) $(HEADERS) $(MAIN)
	$(CC) $(SOURCES) $(MAIN) $(FLAGS) -o $(FILE)

