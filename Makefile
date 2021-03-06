CC = gcc
AR = ar

DEFINES +=
CFLAGS = $(DEFINES) -c -O2 -Wall
INCLUDES +=
LIBS +=
LDFLAGS +=
LINKCMD = $(AR) -rcs $(TARGET) $(OBJECTS)

RAGEL = ragel
RAGELFLAGS = -C -T1

.PHONY: clean test

TARGETDIR = bin
OBJDIR = obj
TARGET = $(TARGETDIR)/libcsv.a
TEST = $(TARGETDIR)/test.exe

all: $(TARGETDIR) $(OBJDIR) $(TARGET)
	@:

clean:
	rm -f $(TARGET)
	rm -rf $(OBJDIR)
	rm src/csv.c

test:
	$(MAKE)
	$(CC) -o "$(TEST)" test/test.c -Isrc $(TARGET)
	$(TEST) $(TARGETDIR)/header.csv

$(TARGETDIR):
	mkdir $(subst /,\\,$(TARGETDIR))

$(OBJDIR):
	mkdir $(subst /,\\,$(OBJDIR))

OBJECTS := \
	$(OBJDIR)/csv.o \

$(TARGET): $(OBJECTS)
	$(LINKCMD)

src/csv.c: src/csv.rl
	$(RAGEL) $(RAGELFLAGS) "$<" -o "$@"

$(OBJDIR)/csv.o: src/csv.c
	$(CC) -o "$@" $(CFLAGS) $(INCLUDES) "$<"


