CC = gcc
DEFINES += -D__TEST__
CFLAGS = $(DEFINES) -c -O2 -Wall
INCLUDES +=
LIBS +=
LDFLAGS +=
LINKCMD = $(CC) -o $(TARGET) $(OBJECTS) $(LDFLAGS) $(LIBS)

RAGEL = ragel
RAGELFLAGS = -C -G2

.PHONY: clean test

TARGETDIR = bin
OBJDIR = obj
TARGET = $(TARGETDIR)/csv

all: $(TARGETDIR) $(OBJDIR) $(TARGET)
	@:

clean:
	rm -f $(TARGET)
	rm -rf $(OBJDIR)
	rm src/csv.c

test:
	$(TARGET) $(TARGETDIR)/header.csv

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

